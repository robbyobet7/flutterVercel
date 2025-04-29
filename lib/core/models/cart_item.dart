import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:rebill_flutter/core/models/product.dart';

class CartItem {
  final Product product;
  final int quantity;
  final String? notes;
  final Map<String, dynamic>? selectedOptions;
  final Set<String>? selectedExtras;

  CartItem({
    required this.product,
    required this.quantity,
    this.notes,
    this.selectedOptions,
    this.selectedExtras,
  });

  // Calculate the base price of the product
  double get basePrice => product.productsPrice ?? 0;

  // Calculate the price after applying product discounts
  double get discountedPrice => product.finalPrice;

  // Calculate the tax for this item
  double get tax => (product.tax ?? 0) * quantity;

  // Calculate additional costs from options
  double get optionsPrice {
    double additionalPrice = 0;

    // Add prices from selected options
    if (selectedOptions != null && selectedOptions!.isNotEmpty) {
      selectedOptions!.forEach((optionId, option) {
        if (option is Map<String, dynamic> && option.containsKey('price')) {
          additionalPrice += (option['price'] as num).toDouble();
        }
      });
    }

    // Add prices from selected extras
    if (selectedExtras != null &&
        selectedExtras!.isNotEmpty &&
        product.option != null) {
      try {
        List<dynamic> options = List<dynamic>.from(
          product.option!.startsWith('[') ? json.decode(product.option!) : [],
        );

        for (final opt in options) {
          if (opt['type'] == 'extra' &&
              opt['uid'] != null &&
              selectedExtras!.contains(opt['uid'])) {
            additionalPrice += (opt['price'] as num?)?.toDouble() ?? 0;
          }
        }
      } catch (e) {
        // Handle parsing errors silently
      }
    }

    return additionalPrice * quantity;
  }

  // Calculate the total price for this item including options and quantity
  double get totalPrice {
    return (discountedPrice + optionsPrice) * quantity;
  }

  // Calculate the total price including tax
  double get totalPriceWithTax {
    return totalPrice + tax;
  }

  // Create a copy of this cart item with updated properties
  CartItem copyWith({
    Product? product,
    int? quantity,
    String? notes,
    Map<String, dynamic>? selectedOptions,
    Set<String>? selectedExtras,
  }) {
    return CartItem(
      product: product ?? this.product,
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
    return other.product.id == product.id &&
        mapEquals(other.selectedOptions, selectedOptions) &&
        setEquals(other.selectedExtras, selectedExtras);
  }

  @override
  int get hashCode {
    return Object.hash(
      product.id,
      Object.hashAll(selectedOptions?.entries.toList() ?? []),
      Object.hashAll(selectedExtras?.toList() ?? []),
    );
  }
}
