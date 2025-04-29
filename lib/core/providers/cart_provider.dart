import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/models/cart_item.dart';
import 'package:rebill_flutter/core/models/product.dart';

/// Class representing the full state of a cart
class CartState {
  final List<CartItem> items;
  final double? additionalDiscount;
  final String? discountNote;
  final double serviceFeePercentage;
  final double taxPercentage;
  final bool taxIncluded;

  const CartState({
    this.items = const [],
    this.additionalDiscount,
    this.discountNote,
    this.serviceFeePercentage = 5.0, // Default 5% service fee
    this.taxPercentage = 10.0, // Default 10% tax
    this.taxIncluded = false,
  });

  // Calculate the subtotal of all items (before tax and service fee)
  double get subtotal {
    return items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  // Calculate service fee (5% of subtotal)
  double get serviceFee {
    return subtotal * (serviceFeePercentage / 100);
  }

  // Calculate the total tax (10% of (subtotal + service fee))
  double get taxTotal {
    if (taxIncluded)
      return 0; // If tax is included in price, we don't add extra tax
    return (subtotal + serviceFee) * (taxPercentage / 100);
  }

  // Calculate any additional discount
  double get discountAmount {
    if (additionalDiscount == null) return 0;
    return additionalDiscount!;
  }

  // Calculate the grand total
  double get total {
    return subtotal + serviceFee + taxTotal - discountAmount;
  }

  // Get the total number of items in the cart
  int get itemCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  // Create a copy of the cart with updated properties
  CartState copyWith({
    List<CartItem>? items,
    double? additionalDiscount,
    String? discountNote,
    double? serviceFeePercentage,
    double? taxPercentage,
    bool? taxIncluded,
  }) {
    return CartState(
      items: items ?? this.items,
      additionalDiscount: additionalDiscount ?? this.additionalDiscount,
      discountNote: discountNote ?? this.discountNote,
      serviceFeePercentage: serviceFeePercentage ?? this.serviceFeePercentage,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      taxIncluded: taxIncluded ?? this.taxIncluded,
    );
  }
}

/// Notifier that manages the cart state
class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  // Add an item to the cart
  void addItem(CartItem item) {
    final items = [...state.items];

    // Check if the item already exists in the cart
    final index = items.indexWhere((cartItem) => cartItem == item);

    if (index >= 0) {
      // Update quantity if the item exists
      items[index] = items[index].copyWith(
        quantity: items[index].quantity + item.quantity,
      );
    } else {
      // Add the new item to the cart
      items.add(item);
    }

    state = state.copyWith(items: items);
  }

  // Add a product to the cart with specified quantity, notes, and options
  void addProduct({
    required Product product,
    required int quantity,
    String? notes,
    Map<String, dynamic>? selectedOptions,
    Set<String>? selectedExtras,
  }) {
    final cartItem = CartItem(
      product: product,
      quantity: quantity,
      notes: notes,
      selectedOptions: selectedOptions,
      selectedExtras: selectedExtras,
    );

    addItem(cartItem);
  }

  // Update an existing item in the cart
  void updateItem(CartItem item, {required int index}) {
    if (index < 0 || index >= state.items.length) return;

    final items = [...state.items];
    items[index] = item;

    state = state.copyWith(items: items);
  }

  // Remove an item from the cart
  void removeItem(int index) {
    if (index < 0 || index >= state.items.length) return;

    final items = [...state.items];
    items.removeAt(index);

    state = state.copyWith(items: items);
  }

  // Increment the quantity of an item
  void incrementQuantity(int index) {
    if (index < 0 || index >= state.items.length) return;

    final items = [...state.items];
    final item = items[index];

    // Check if incrementing would exceed available stock
    final product = item.product;
    if (!product.hasInfiniteStock && item.quantity >= product.availableStock) {
      return; // Don't increment beyond available stock
    }

    items[index] = item.copyWith(quantity: item.quantity + 1);
    state = state.copyWith(items: items);
  }

  // Decrement the quantity of an item
  void decrementQuantity(int index) {
    if (index < 0 || index >= state.items.length) return;

    final items = [...state.items];
    final item = items[index];

    if (item.quantity > 1) {
      items[index] = item.copyWith(quantity: item.quantity - 1);
      state = state.copyWith(items: items);
    } else {
      // Remove item if quantity would become 0
      removeItem(index);
    }
  }

  // Update the quantity of an item
  void updateQuantity(int index, int quantity) {
    if (index < 0 || index >= state.items.length) return;
    if (quantity <= 0) {
      removeItem(index);
      return;
    }

    final items = [...state.items];
    final item = items[index];

    // Check if the new quantity exceeds available stock
    final product = item.product;
    if (!product.hasInfiniteStock && quantity > product.availableStock) {
      quantity = product.availableStock;
    }

    items[index] = item.copyWith(quantity: quantity);
    state = state.copyWith(items: items);
  }

  // Apply an additional discount to the cart
  void applyDiscount(double amount, {String? note}) {
    state = state.copyWith(additionalDiscount: amount, discountNote: note);
  }

  // Remove the additional discount
  void removeDiscount() {
    state = state.copyWith(additionalDiscount: null, discountNote: null);
  }

  // Update service fee percentage
  void updateServiceFeePercentage(double percentage) {
    state = state.copyWith(serviceFeePercentage: percentage);
  }

  // Update tax percentage
  void updateTaxPercentage(double percentage) {
    state = state.copyWith(taxPercentage: percentage);
  }

  // Set whether tax is included in the price
  void setTaxIncluded(bool included) {
    state = state.copyWith(taxIncluded: included);
  }

  // Clear all items from the cart
  void clearCart() {
    state = const CartState();
  }
}

// Provider for the cart state
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

// Convenience providers to access specific cart properties

// Provider for the total number of items in the cart
final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).itemCount;
});

// Provider for the cart subtotal
final cartSubtotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).subtotal;
});

// Provider for the service fee
final cartServiceFeeProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).serviceFee;
});

// Provider for the cart total tax
final cartTaxProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).taxTotal;
});

// Provider for any additional discount
final cartDiscountProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).discountAmount;
});

// Provider for the cart grand total
final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).total;
});
