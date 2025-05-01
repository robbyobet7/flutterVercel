import 'package:flutter/foundation.dart';
import 'package:rebill_flutter/core/models/customized_product.dart';

class CartItem {
  final CustomizedProduct customizedProduct;
  final int quantity;
  final String? notes;
  final Map<String, dynamic>? selectedOptions;
  final Set<String>? selectedExtras;

  CartItem({
    required this.customizedProduct,
    required this.quantity,
    this.notes,
    this.selectedOptions,
    this.selectedExtras,
  });

  // Calculate the base price of the product
  double get basePrice => customizedProduct.basePrice;

  // Calculate the price after applying product discounts, multiplied by quantity
  double get totalPrice => customizedProduct.totalPrice * quantity;

  CartItem copyWith({
    CustomizedProduct? customizedProduct,
    int? quantity,
    String? notes,
    Map<String, dynamic>? selectedOptions,
    Set<String>? selectedExtras,
  }) {
    return CartItem(
      customizedProduct: customizedProduct ?? this.customizedProduct,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      selectedExtras: selectedExtras ?? this.selectedExtras,
    );
  }

  // Check if two cart items are equal (for comparison in the cart)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! CartItem) return false;

    // Two cart items are considered equal if they have the same product ID,
    // options and extras
    return other.customizedProduct.id == customizedProduct.id &&
        mapEquals(other.selectedOptions, selectedOptions) &&
        setEquals(other.selectedExtras, selectedExtras);
  }

  @override
  int get hashCode {
    return Object.hash(
      customizedProduct.id,
      Object.hashAll(selectedOptions?.entries.toList() ?? []),
      Object.hashAll(selectedExtras?.toList() ?? []),
    );
  }
}
