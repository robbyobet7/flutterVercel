import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';

// Product state class
class ProductState {
  final List<Product> products;
  final Map<int, ProductDiscount?> activeDiscounts;
  final int? selectedProductId; // Track the currently selected product

  ProductState({
    this.products = const [],
    this.activeDiscounts = const {},
    this.selectedProductId,
  });

  // Create a copy with updated fields
  ProductState copyWith({
    List<Product>? products,
    Map<int, ProductDiscount?>? activeDiscounts,
    int? selectedProductId,
    bool clearSelectedProduct = false,
  }) {
    return ProductState(
      products: products ?? this.products,
      activeDiscounts: activeDiscounts ?? this.activeDiscounts,
      selectedProductId:
          clearSelectedProduct
              ? null
              : selectedProductId ?? this.selectedProductId,
    );
  }
}

// Product notifier class
class ProductNotifier extends StateNotifier<ProductState> {
  ProductNotifier() : super(ProductState());

  // Set products from API or storage
  void setProducts(List<Product> products) {
    state = state.copyWith(products: products);
  }

  // Get a product by ID
  Product? getProductById(int id) {
    try {
      return state.products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  // Set currently selected product
  void selectProduct(int productId) {
    // Clear active discounts for other products when selecting a new product
    if (state.selectedProductId != productId) {
      final updatedDiscounts = <int, ProductDiscount?>{};
      // Only keep discounts for the newly selected product
      if (state.activeDiscounts.containsKey(productId)) {
        updatedDiscounts[productId] = state.activeDiscounts[productId];
      }

      state = state.copyWith(
        selectedProductId: productId,
        activeDiscounts: updatedDiscounts,
      );
    }
  }

  // Clear selected product
  void clearSelectedProduct() {
    state = state.copyWith(clearSelectedProduct: true);
  }

  // Apply a discount to a specific product
  void applyDiscountToProduct(int productId, ProductDiscount discount) {
    // First ensure this product is selected
    selectProduct(productId);

    // Then apply the discount
    final updatedDiscounts = Map<int, ProductDiscount?>.from(
      state.activeDiscounts,
    );
    updatedDiscounts[productId] = discount;
    state = state.copyWith(activeDiscounts: updatedDiscounts);
  }

  // Remove discount from a product
  void removeDiscountFromProduct(int productId) {
    final updatedDiscounts = Map<int, ProductDiscount?>.from(
      state.activeDiscounts,
    );
    updatedDiscounts.remove(productId);
    state = state.copyWith(activeDiscounts: updatedDiscounts);
  }

  // Clear all active discounts
  void clearAllDiscounts() {
    state = state.copyWith(activeDiscounts: {});
  }

  // Calculate the final price of a product after discount
  double getDiscountedPrice(Product product) {
    if (product.id == null) return product.productsPrice ?? 0;

    final basePrice = product.productsPrice ?? 0;
    double discountAmount = 0;

    // Check if there is an active discount for this product
    final activeDiscount = state.activeDiscounts[product.id];
    if (activeDiscount == null) {
      // If no active custom discount, check if product has its own discount
      if (product.productsDiscount != null && product.productsDiscount! > 0) {
        // Apply the product's default discount
        discountAmount = calculateDiscountAmount(
          basePrice,
          product.productsDiscount!,
          product.discountType2 ?? 'percentage',
        );
      }
    } else {
      // Apply the active discount
      final amount = activeDiscount.amount;
      final discountType = activeDiscount.discountType ?? 'percentage';

      if (amount != null) {
        discountAmount = calculateDiscountAmount(
          basePrice,
          amount,
          discountType,
        );
      }

      // If discount has a total field, use it directly
      if (activeDiscount.total != null) {
        double? totalDiscount;
        if (activeDiscount.total is double) {
          totalDiscount = activeDiscount.total;
        } else if (activeDiscount.total is int) {
          totalDiscount = (activeDiscount.total as int).toDouble();
        } else if (activeDiscount.total is String) {
          totalDiscount = double.tryParse(activeDiscount.total as String);
        }

        if (totalDiscount != null) {
          discountAmount = totalDiscount;
        }
      }
    }

    // Calculate final price by subtracting the discount amount from base price
    final finalPrice = basePrice - discountAmount;

    // Ensure price doesn't go below zero
    return finalPrice < 0 ? 0 : finalPrice;
  }

  // Helper method to calculate discount amount
  double calculateDiscountAmount(
    double basePrice,
    dynamic discountAmount,
    String discountType,
  ) {
    double amount;

    // Convert discount amount to double if it's a string
    if (discountAmount is String) {
      amount = double.tryParse(discountAmount) ?? 0;
    } else if (discountAmount is int) {
      amount = discountAmount.toDouble();
    } else if (discountAmount is double) {
      amount = discountAmount;
    } else {
      return 0; // Return zero if discount is invalid
    }

    // Calculate discount amount based on type
    if (discountType == 'percentage') {
      return (amount / 100) * basePrice;
    } else if (discountType == 'fixed') {
      return amount;
    }

    return 0;
  }

  // Helper method to calculate discounted price (kept for backward compatibility)
  double calculateDiscountedPrice(
    double basePrice,
    dynamic discountAmount,
    String discountType,
  ) {
    double amountToDeduct = calculateDiscountAmount(
      basePrice,
      discountAmount,
      discountType,
    );
    return basePrice - amountToDeduct < 0 ? 0 : basePrice - amountToDeduct;
  }

  // Get all available discounts for a product
  List<ProductDiscount> getAvailableDiscountsForProduct(int productId) {
    final product = getProductById(productId);
    if (product == null) return [];

    return product.multipleDiscounts ?? [];
  }

  // Add a new product
  void addProduct(Product product) {
    final updatedProducts = [...state.products, product];
    state = state.copyWith(products: updatedProducts);
  }

  // Update an existing product
  void updateProduct(Product updatedProduct) {
    final index = state.products.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      final updatedProducts = List<Product>.from(state.products);
      updatedProducts[index] = updatedProduct;
      state = state.copyWith(products: updatedProducts);
    }
  }

  // Remove a product
  void removeProduct(int productId) {
    final updatedProducts =
        state.products.where((product) => product.id != productId).toList();

    // Also remove any active discounts for this product
    final updatedDiscounts = Map<int, ProductDiscount?>.from(
      state.activeDiscounts,
    );
    updatedDiscounts.remove(productId);

    state = state.copyWith(
      products: updatedProducts,
      activeDiscounts: updatedDiscounts,
    );
  }

  // Check if product has any discount applied (either active or default)
  bool hasDiscount(Product product) {
    return state.activeDiscounts.containsKey(product.id) ||
        (product.productsDiscount != null && product.productsDiscount! > 0);
  }

  // Get discount percentage or fixed amount as formatted string
  String getDiscountDisplay(Product product) {
    final activeDiscount = state.activeDiscounts[product.id];

    if (activeDiscount != null) {
      final amount = activeDiscount.amount;
      final type = activeDiscount.discountType ?? 'percentage';

      if (amount == null) return '';

      return type == 'percentage' ? '$amount%' : '\$$amount';
    } else if (product.productsDiscount != null &&
        product.productsDiscount! > 0) {
      final type = product.discountType2 ?? 'percentage';
      return type == 'percentage'
          ? '${product.productsDiscount}%'
          : '\$${product.productsDiscount}';
    }

    return '';
  }
}

// Provider definition
final productProvider = StateNotifierProvider<ProductNotifier, ProductState>((
  ref,
) {
  return ProductNotifier();
});
