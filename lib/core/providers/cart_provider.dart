import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/models/cart_item.dart';
import 'dart:convert';
import 'package:rebill_flutter/core/models/product.dart';
import 'package:rebill_flutter/core/models/bill.dart';
import 'package:rebill_flutter/core/providers/bill_provider.dart';
import 'package:rebill_flutter/core/providers/product_provider.dart';

/// Class representing the full state of a cart
class CartState {
  final List<CartItem> items;
  final double? additionalDiscount;
  final String? discountNote;
  final double serviceFeePercentage;
  final double taxPercentage;
  final bool taxIncluded;
  final double gratuityPercentage;

  const CartState({
    this.items = const [],
    this.additionalDiscount,
    this.discountNote,
    this.serviceFeePercentage = 5.0, // Default 5% service fee
    this.taxPercentage = 10.0, // Default 10% tax
    this.taxIncluded = false,
    this.gratuityPercentage = 0.0, // Default 0% gratuity
  });

  // Calculate the subtotal of all items (before tax and service fee)
  // This actually gives us the total with per-item discounts already applied,
  // since the item.totalPrice calculation is price * quantity, and price
  // has already been reduced by the discount amount in CartItem.fromJson
  double get subtotal {
    return items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  // Calculate service fee (serviceFeePercentage% of subtotal)
  double get serviceFee {
    return subtotal * (serviceFeePercentage / 100);
  }

  // Calculate gratuity amount (gratuityPercentage% of subtotal)
  double get gratuity {
    return subtotal * (gratuityPercentage / 100);
  }

  // Calculate the total tax (taxPercentage% of (subtotal + service fee))
  double get taxTotal {
    if (taxIncluded) {
      return 0; // If tax is included in price, we don't add extra tax
    }
    return (subtotal + serviceFee) * (taxPercentage / 100);
  }

  // Calculate the total product discount of all items in cart
  double get totalProductDiscount {
    return items.fold(0, (sum, item) => sum + item.totalDiscountAmount);
  }

  // Calculate any additional discount
  double get discountAmount {
    if (additionalDiscount == null) return 0;
    return additionalDiscount!;
  }

  // Calculate the grand total
  double get total {
    // No need to subtract product discounts here as they've already been applied
    // in the subtotal calculation through each item's price
    return subtotal + serviceFee + taxTotal + gratuity - discountAmount;
  }

  // Calculate total with checkout discount applied
  double getTotalWithCheckoutDiscount(double checkoutDiscountAmount) {
    return subtotal -
        checkoutDiscountAmount +
        serviceFee +
        taxTotal +
        gratuity -
        discountAmount;
  }

  // Get the total number of items in the cart
  int get itemCount {
    return items.fold(0, (sum, item) => sum + item.quantity.toInt());
  }

  // Create a copy of the cart with updated properties
  CartState copyWith({
    List<CartItem>? items,
    double? additionalDiscount,
    String? discountNote,
    double? serviceFeePercentage,
    double? taxPercentage,
    bool? taxIncluded,
    double? gratuityPercentage,
  }) {
    return CartState(
      items: items ?? this.items,
      additionalDiscount: additionalDiscount ?? this.additionalDiscount,
      discountNote: discountNote ?? this.discountNote,
      serviceFeePercentage: serviceFeePercentage ?? this.serviceFeePercentage,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      taxIncluded: taxIncluded ?? this.taxIncluded,
      gratuityPercentage: gratuityPercentage ?? this.gratuityPercentage,
    );
  }
}

/// Notifier that manages the cart state
class CartNotifier extends StateNotifier<CartState> {
  final StateNotifierProviderRef ref;

  CartNotifier(this.ref) : super(const CartState());

  void addSimpleProduct(Product product, WidgetRef ref, {int quantity = 1}) {
    final productNotifier = ref.read(productProvider.notifier);

    if (product.id != null) {
      productNotifier.selectProduct(product.id!);
    }

    final basePrice = product.productsPrice ?? 0;
    final finalPrice = productNotifier.getTotalPrice(product);

    double discountAmount = 0;
    String? discountType;
    dynamic discountValue;
    String? discountName;

    final activeDiscount = productNotifier.getActiveDiscount(product.id!);
    if (activeDiscount != null) {
      discountAmount = basePrice - productNotifier.getDiscountedPrice(product);
      discountType = activeDiscount.discountType ?? 'percentage';
      discountValue =
          discountType == 'percentage'
              ? activeDiscount.amount
              : activeDiscount.total;
      discountName = activeDiscount.discountName;
    } else if (product.productsDiscount != null &&
        product.productsDiscount! > 0) {
      discountAmount = basePrice - productNotifier.getDiscountedPrice(product);
      discountType = product.discountType2 ?? 'percentage';
      discountValue = product.productsDiscount;
      discountName = product.productsDiscountName;
    }

    addProduct(
      id: product.id ?? 0,
      name: product.productsName ?? 'Unknown',
      price: finalPrice, // <-- Price after discount
      quantity: quantity.toDouble(),
      type: product.type,
      purchprice: product.purchPrice ?? 0,
      includedtax: product.tax ?? 0,
      options: null, // No option for simpleProduct
      category: product.productsType ?? 'Unknown',
      productNotes: null,
      originalPrice: basePrice, // Real price before discount
      discount: discountAmount,
      discountType: discountType,
      discountValue: discountValue,
      discountName: discountName,
    );
  }

  void _updateBillTotals() {
    // Use safe ref to read other providers
    final billNotifier = ref.read(billProvider.notifier);
    final selectedBill = ref.read(billProvider).selectedBill;
    final cartState = state; // 'state' adalah state saat ini dari CartNotifier

    if (selectedBill != null && selectedBill.states.toLowerCase() == 'open') {
      int roundUpToThousand(double value) => ((value / 1000).ceil()) * 1000;
      final roundedTotal = roundUpToThousand(cartState.total);

      billNotifier.updateSelectedBillTotals(
        cartState.total,
        roundedTotal.toDouble(),
      );
    }
  }

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
    _updateBillTotals();
  }

  // Add a product to the cart directly
  void addProduct({
    required int id,
    required String name,
    required double price,
    required double quantity,
    required String type,
    required double purchprice,
    required double includedtax,
    List<CartItemOption>? options,
    required String category,
    List<String>? categoryBillPrinter,
    String? productNotes,
    double? originalPrice,
    double? originalPurchprice,
    String? discountType,
    dynamic discountValue,
    double discount = 0,
    String? discountName,
    String? discountProducts,
    dynamic discountRules,
    String? discountType2,
    dynamic discountId,
    String? productDiscountType,
    bool? isCashProductDiscount,
    double? totalDiscountRules,
  }) {
    final cartItem = CartItem(
      id: id,
      name: name,
      price: price,
      quantity: quantity,
      type: type,
      purchprice: purchprice,
      includedtax: includedtax,
      options: options,
      category: category,
      categoryBillPrinter: categoryBillPrinter,
      productNotes: productNotes,
      originalPrice: originalPrice ?? price,
      originalPurchprice: originalPurchprice ?? purchprice,
      discountType: discountType,
      discountValue: discountValue,
      discount: discount,
      discountName: discountName,
      discountProducts: discountProducts,
      discountRules: discountRules,
      discountType2: discountType2,
      discountId: discountId,
      productDiscountType: productDiscountType,
      isCashProductDiscount: isCashProductDiscount,
      totalDiscountRules: totalDiscountRules,
    );

    addItem(cartItem);
  }

  // Add cart items from bill JSON
  void addItemsFromBill(String ordersJson) {
    try {
      final orderCollection = json.decode(ordersJson);

      // Process each item to ensure correct types before passing to CartItem.fromJson
      final processedItems =
          (orderCollection as List).map((item) {
            // Convert item to a new map to avoid modifying the original
            final Map<String, dynamic> processedItem =
                Map<String, dynamic>.from(item);

            // Ensure these fields are strings
            if (processedItem['discount_type'] != null &&
                processedItem['discount_type'] is int) {
              processedItem['discount_type'] =
                  processedItem['discount_type'].toString();
            }

            if (processedItem['discount_name'] != null &&
                processedItem['discount_name'] is int) {
              processedItem['discount_name'] =
                  processedItem['discount_name'].toString();
            }

            // Special handling for discount_products which might be complex
            if (processedItem['discount_products'] != null) {
              if (processedItem['discount_products'] is! String) {
                // Convert to string if it's a complex type
                try {
                  processedItem['discount_products'] = json.encode(
                    processedItem['discount_products'],
                  );
                } catch (e) {
                  processedItem['discount_products'] = null;
                }
              }
            }

            // Ensure original_price exists for discount calculations
            if (processedItem['original_price'] == null &&
                processedItem['price'] != null) {
              processedItem['original_price'] = processedItem['price'];
            }

            // Handle options array that might contain invalid data
            if (processedItem['options'] != null) {
              if (processedItem['options'] is List) {
                try {
                  // Filter out null or invalid options
                  processedItem['options'] =
                      (processedItem['options'] as List)
                          .where((option) => option != null && option is Map)
                          .toList();
                } catch (e) {
                  processedItem['options'] = null;
                }
              } else if (processedItem['options'] is! List) {
                // If options is not a list, set it to null
                processedItem['options'] = null;
              }
            }

            return processedItem;
          }).toList();

      // Collect all valid CartItems first
      final List<CartItem> validItems = [];

      // Convert processed items to CartItem objects
      for (final item in processedItems) {
        try {
          final cartItem = CartItem.fromJson(item);

          validItems.add(cartItem);
        } catch (e) {
          // Continue with next item instead of breaking the whole process
          continue;
        }
      }

      // Batch add all items to cart
      if (validItems.isNotEmpty) {
        final items = [...state.items, ...validItems];
        state = state.copyWith(items: items);
      } else {}
    } catch (e) {
      rethrow;
    }
  }

  // Update an existing item in the cart
  void updateItem(CartItem item, {required int index}) {
    if (index < 0 || index >= state.items.length) return;

    final items = [...state.items];
    items[index] = item;

    state = state.copyWith(items: items);
    _updateBillTotals();
  }

  // Remove an item from the cart
  void removeItem(int index) {
    if (index < 0 || index >= state.items.length) return;

    final items = [...state.items];
    items.removeAt(index);

    state = state.copyWith(items: items);
    _updateBillTotals();
  }

  // Increment the quantity of an item
  void incrementQuantity(int index) {
    if (index < 0 || index >= state.items.length) return;

    final items = [...state.items];
    final item = items[index];

    items[index] = item.copyWith(quantity: item.quantity + 1);
    state = state.copyWith(items: items);
    _updateBillTotals();
  }

  // Decrement the quantity of an item
  void decrementQuantity(int index) {
    if (index < 0 || index >= state.items.length) return;

    final items = [...state.items];
    final item = items[index];

    if (item.quantity > 1) {
      items[index] = item.copyWith(quantity: item.quantity - 1);
      state = state.copyWith(items: items);
      _updateBillTotals();
    } else {
      // Remove item if quantity would become 0
      removeItem(index);
    }
  }

  // Update the quantity of an item
  void updateQuantity(int index, double quantity) {
    if (index < 0 || index >= state.items.length) return;
    if (quantity <= 0) {
      removeItem(index);
      return;
    }

    final items = [...state.items];
    items[index] = items[index].copyWith(quantity: quantity);
    state = state.copyWith(items: items);
    _updateBillTotals();
  }

  // Update service fee percentage
  void updateServiceFeePercentage(double percentage) {
    state = state.copyWith(serviceFeePercentage: percentage);
    _updateBillTotals();
  }

  // Update tax percentage
  void updateTaxPercentage(double percentage) {
    state = state.copyWith(taxPercentage: percentage);
    _updateBillTotals();
  }

  // Update gratuity percentage
  void updateGratuityPercentage(double percentage) {
    state = state.copyWith(gratuityPercentage: percentage);
    _updateBillTotals();
  }

  //Load cart from Bill
  void loadCartFromBill(BillModel bill) {
    clearCart();

    state = CartState(items: List.from(bill.items ?? []));
    _updateBillTotals();
  }

  // Clear all items from the cart
  void clearCart() {
    state = const CartState();
    _updateBillTotals();
  }

  // Add a method to convert a Product to a CartItem
  void addProductFromProduct({
    required Product product,
    required int quantity,
    List<CartItemOption>? options,
    String? productNotes,
  }) {
    final cartItem = CartItem(
      id: product.id ?? 0,
      name: product.productsName ?? 'Unknown',
      price: product.productsPrice ?? 0,
      quantity: quantity.toDouble(),
      type: product.type,
      purchprice: product.purchPrice ?? 0,
      includedtax: product.tax ?? 0,
      options: options,
      category: product.productsType ?? 'Unknown',
      productNotes: productNotes,
      originalPrice: product.productsPrice ?? 0,
      originalPurchprice: product.purchPrice ?? 0,
    );

    addItem(cartItem);
  }

  // Export cart items to JSON format for bill
  String exportOrderCollection() {
    return jsonEncode(state.items.map((item) => item.toJson()).toList());
  }

  // Add a method to load a BillModel directly into the cart
  void loadBill(BillModel bill) {
    // Set state awal tanpa memicu update berulang
    double serviceFeePercent = double.tryParse(bill.servicefee) ?? 5.0;
    double taxPercent = double.tryParse(bill.vat) ?? 10.0;
    double gratuityPercent = double.tryParse(bill.gratuity) ?? 0.0;

    List<CartItem> itemsFromBill = [];
    if (bill.items != null && bill.items!.isNotEmpty) {
      itemsFromBill = List.from(bill.items!);
    } else if (bill.orderCollection.isNotEmpty) {
      // If bill only has order collection string, parse and add items
      addItemsFromBill(bill.orderCollection);
    }

    state = state.copyWith(
      items: itemsFromBill,
      serviceFeePercentage: serviceFeePercent,
      taxPercentage: taxPercent,
      gratuityPercentage: gratuityPercent,
    );

    // Once the state is set, call update just once at the end
    _updateBillTotals();

    // Check individual items
    for (int i = 0; i < state.items.length; i++) {
      // ignore: unused_local_variable
      final item = state.items[i];
    }
  }

  // Create a new bill from the current cart state
  BillModel createBill({
    String customerName = 'Guest',
    int? customerId,
    String? customerPhone,
    String delivery = 'direct',
    int outletId = 1, // Default outlet ID
    int cashierId = 1, // Default cashier ID
    String cashierName = 'Cashier', // Default cashier name
  }) {
    final timestamp = DateTime.now();
    final orderCollection = exportOrderCollection();

    return BillModel(
      billId: 0, // Will be assigned by server
      customerName: customerName,
      orderCollection: orderCollection,
      total: state.subtotal,
      finalTotal: state.total,
      downPayment: 0, // Not paid yet
      usersId: cashierId,
      states: 'open', // New bill is open
      paymentMethod: null, // Not paid yet
      splitPayment: null,
      delivery: delivery,
      createdAt: timestamp,
      updatedAt: timestamp,
      deletedAt: null,
      outletId: outletId,
      servicefee: state.serviceFeePercentage.toString(),
      gratuity: state.gratuityPercentage.toString(),
      vat: state.taxPercentage.toString(),
      customerId: customerId,
      billDiscount: "0.00",
      tableId: null,
      totalDiscount: state.totalProductDiscount.toInt(),
      hashBill: '', // Will be assigned by server
      rewardPoints: '{"initial":0,"redeem":0,"earn":0}',
      totalReward: 0,
      rewardBill: "0.00",
      cBillId: '', // Will be assigned by server
      rounding: 0, // Calculated by server
      isQR: 0,
      notes: null,
      amountPaid: 0, // Not paid yet
      ccNumber: null,
      ccType: null,
      productDiscount: state.totalProductDiscount.toInt(),
      merchantOrderId: null,
      discountList: null,
      key: 0, // Will be assigned by server
      affiliate: null,
      customerPhone: customerPhone,
      totaldiscount: state.discountAmount.toInt(),
      totalafterdiscount: state.subtotal - state.discountAmount,
      cashier: cashierName,
      lastcashier: cashierName,
      firstcashier: cashierName,
      totalgratuity: state.gratuity,
      totalservicefee: state.serviceFee,
      totalbeforetax: state.subtotal + state.serviceFee + state.gratuity,
      totalvat: state.taxTotal,
      totalaftertax:
          state.subtotal + state.serviceFee + state.gratuity + state.taxTotal,
      roundingSetting: 1000, // Default rounding to nearest 1000
      totalafterrounding: state.total,
      div: 1,
      billDate: timestamp.toString(),
      posBillDate: timestamp.toString(),
      posPaidBillDate: timestamp.toString(),
      rewardoption: "true",
      return_: 0,
      proof: null,
      proofStaffId: null,
      tableName: null,
      fromProcessBill: true,
      refund: null,
      items: state.items,
    );
  }
}

// Provider for the cart state
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier(ref);
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

// Provider for the gratuity amount
final cartGratuityProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).gratuity;
});

// Provider for the cart grand total
final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).total;
});

// Provider for the total product discount
final cartProductDiscountProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).totalProductDiscount;
});
