// ignore_for_file: unused_local_variable

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../models/product.dart';
import 'package:intl/intl.dart';

// Class to represent a selected option or extra
class ProductOptionItem {
  final String id; // Option ID
  final dynamic
  value; // Selected value (can be a map for options or bool for extras)
  final String type; // Type: 'option' or 'extra'

  ProductOptionItem({
    required this.id,
    required this.value,
    required this.type,
  });
}

// Product state class
class ProductState {
  final List<Product> products;
  final Map<int, ProductDiscount?> activeDiscounts;
  final int? selectedProductId; // Track the currently selected product
  final Map<int, Map<String, ProductOptionItem>>
  productOptions; // ProductId -> OptionId -> Option value

  ProductState({
    this.products = const [],
    this.activeDiscounts = const {},
    this.selectedProductId,
    this.productOptions = const {},
  });

  // Create a copy with updated fields
  ProductState copyWith({
    List<Product>? products,
    Map<int, ProductDiscount?>? activeDiscounts,
    int? selectedProductId,
    Map<int, Map<String, ProductOptionItem>>? productOptions,
    bool clearSelectedProduct = false,
  }) {
    return ProductState(
      products: products ?? this.products,
      activeDiscounts: activeDiscounts ?? this.activeDiscounts,
      selectedProductId:
          clearSelectedProduct
              ? null
              : selectedProductId ?? this.selectedProductId,
      productOptions: productOptions ?? this.productOptions,
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
      if (state.products.isEmpty) {
        return null;
      }

      try {
        return state.products.firstWhere((product) => product.id == id);
      } catch (e) {
        // Log available product IDs for debugging
        final availableIds = state.products.map((p) => p.id).toList();
        return null;
      }
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

  // Get available options for a product
  List<dynamic> getProductOptions(int productId) {
    final product = getProductById(productId);
    if (product == null ||
        product.option == null ||
        !product.option!.startsWith('[')) {
      return [];
    }

    try {
      return json.decode(product.option!) as List;
    } catch (e) {
      return [];
    }
  }

  // Initialize options for a product without setting defaults
  void initializeProductOptions(int productId) {
    final options = getProductOptions(productId);
    if (options.isEmpty) {
      return;
    }

    // Only create an entry if one doesn't already exist, but don't set defaults
    if (!state.productOptions.containsKey(productId)) {
      final updatedOptions = Map<int, Map<String, ProductOptionItem>>.from(
        state.productOptions,
      );
      updatedOptions[productId] = {};
      state = state.copyWith(productOptions: updatedOptions);
    }
  }

  // Set an option for a product
  void setProductOption(
    int productId,
    String optionId,
    dynamic value,
    String type,
  ) {
    // Debug print to see what's being set

    // Get current options for this product
    final updatedOptions = Map<int, Map<String, ProductOptionItem>>.from(
      state.productOptions,
    );
    final productOptions = updatedOptions[productId] ?? {};

    // Update or add the option
    productOptions[optionId] = ProductOptionItem(
      id: optionId,
      value: value,
      type: type,
    );

    // Update state
    updatedOptions[productId] = productOptions;

    // Debug: print before and after

    state = state.copyWith(productOptions: updatedOptions);

    // Print updated state
  }

  // Remove an option from a product
  void removeProductOption(int productId, String optionId) {
    if (!state.productOptions.containsKey(productId)) {
      return;
    }

    // Make sure we copy everything deeply
    final updatedOptions = Map<int, Map<String, ProductOptionItem>>.from(
      state.productOptions,
    );

    if (!updatedOptions[productId]!.containsKey(optionId)) {
      return;
    }

    // Create a new map for this product's options
    final productOptions = Map<String, ProductOptionItem>.from(
      updatedOptions[productId]!,
    );

    // Remove the specific option
    productOptions.remove(optionId);

    // Update the state with the new options map
    updatedOptions[productId] = productOptions;

    // Debug: print before and after

    state = state.copyWith(productOptions: updatedOptions);
  }

  // Clear all options for a product
  void clearProductOptions(int productId) {
    final updatedOptions = Map<int, Map<String, ProductOptionItem>>.from(
      state.productOptions,
    );
    updatedOptions.remove(productId);
    state = state.copyWith(productOptions: updatedOptions);
  }

  // Toggle an extra option for a product
  void toggleProductExtra(
    int productId,
    String extraId,
    Map<String, dynamic> extraData,
  ) {
    final updatedOptions = Map<int, Map<String, ProductOptionItem>>.from(
      state.productOptions,
    );
    final productOptions = updatedOptions[productId] ?? {};

    // Check if the extra is already selected
    if (productOptions.containsKey(extraId)) {
      // Remove if already selected
      productOptions.remove(extraId);
    } else {
      // Add if not selected
      productOptions[extraId] = ProductOptionItem(
        id: extraId,
        value: extraData,
        type: 'extra',
      );
    }

    updatedOptions[productId] = productOptions;
    state = state.copyWith(productOptions: updatedOptions);
  }

  // Check if an extra is selected
  bool isExtraSelected(int productId, String extraId) {
    return state.productOptions[productId]?.containsKey(extraId) ?? false;
  }

  // Get selected option value
  dynamic getSelectedOption(int productId, String optionId) {
    final option = state.productOptions[productId]?[optionId];

    if (option == null) {
      return null;
    }

    return option.value;
  }

  // Compare two option choices to check if they're the same
  bool isSameOption(dynamic option1, dynamic option2) {
    if (option1 == null || option2 == null) {
      return false;
    }

    // If they're maps, compare by uid or id
    if (option1 is Map && option2 is Map) {
      // Try to compare by uid or id
      final id1 = option1['id'] ?? option1['uid'];
      final id2 = option2['id'] ?? option2['uid'];

      if (id1 != null && id2 != null) {
        final result = id1.toString() == id2.toString();
        return result;
      }

      // If no id/uid, try to compare by name
      final name1 = option1['name'];
      final name2 = option2['name'];

      if (name1 != null && name2 != null) {
        final result = name1.toString() == name2.toString();
        return result;
      }

      // If we have a price field, include it in the comparison
      final price1 = option1['price'];
      final price2 = option2['price'];

      if (price1 != null &&
          price2 != null &&
          name1 != null &&
          name2 != null &&
          name1.toString() == name2.toString() &&
          price1.toString() == price2.toString()) {
        return true;
      }

      // As a last resort, try to compare the maps directly
      try {
        // Convert maps to strings and compare
        final str1 = option1.toString();
        final str2 = option2.toString();
        final result = str1 == str2;
        return result;
      } catch (e) {
        return false;
      }
    }

    // Direct comparison for other types
    final result = option1 == option2;
    return result;
  }

  // Get all selected options for a product
  Map<String, ProductOptionItem> getSelectedOptions(int productId) {
    return state.productOptions[productId] ?? {};
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

  // Calculate total price including options
  double getTotalPrice(Product product) {
    if (product.id == null) return product.productsPrice ?? 0;

    // Start with the discounted base price
    double totalPrice = getDiscountedPrice(product);

    // Add prices from selected options
    final selectedOptions = getSelectedOptions(product.id!);
    if (selectedOptions.isNotEmpty) {
      for (final option in selectedOptions.values) {
        if (option.type == 'option' && option.value is Map) {
          // For dropdown options
          final optionPrice = option.value['price'];
          final isComplimentary = option.value['isComplimentary'] == true;

          // Skip adding price for complimentary items
          if (optionPrice != null && !isComplimentary) {
            double priceToAdd = 0;
            if (optionPrice is int) {
              priceToAdd = optionPrice.toDouble();
            } else if (optionPrice is double) {
              priceToAdd = optionPrice;
            } else if (optionPrice is String) {
              priceToAdd = double.tryParse(optionPrice) ?? 0;
            }

            // Check if we should apply discount to option price
            final optionDiscountable = option.value['discountable'] ?? false;
            if (optionDiscountable && hasDiscount(product)) {
              // Apply the same discount percentage to the option price
              final basePrice = product.productsPrice ?? 0;
              if (basePrice > 0) {
                final discountRatio = getDiscountedPrice(product) / basePrice;
                priceToAdd *= discountRatio;
              }
            }

            totalPrice += priceToAdd;
          }
        } else if (option.type == 'extra' && option.value is Map) {
          // For extras
          final extraPrice = option.value['price'];
          if (extraPrice != null) {
            double priceToAdd = 0;
            if (extraPrice is int) {
              priceToAdd = extraPrice.toDouble();
            } else if (extraPrice is double) {
              priceToAdd = extraPrice;
            } else if (extraPrice is String) {
              priceToAdd = double.tryParse(extraPrice) ?? 0;
            }

            // Check if we should apply discount to extra price
            final extraDiscountable = option.value['discountable'] ?? false;
            if (extraDiscountable && hasDiscount(product)) {
              // Apply the same discount percentage to the extra price
              final basePrice = product.productsPrice ?? 0;
              if (basePrice > 0) {
                final discountRatio = getDiscountedPrice(product) / basePrice;
                priceToAdd *= discountRatio;
              }
            }

            totalPrice += priceToAdd;
          }
        }
      }
    }

    return totalPrice;
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

    // Remove any options for this product
    final updatedOptions = Map<int, Map<String, ProductOptionItem>>.from(
      state.productOptions,
    );
    updatedOptions.remove(productId);

    state = state.copyWith(
      products: updatedProducts,
      activeDiscounts: updatedDiscounts,
      productOptions: updatedOptions,
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

  // Format total price as currency string
  String getFormattedTotalPrice(
    Product product, {
    String locale = 'id',
    String symbol = 'Rp',
    int decimalDigits = 0,
  }) {
    final totalPrice = getTotalPrice(product);
    try {
      return NumberFormat.currency(
        locale: locale,
        symbol: symbol,
        decimalDigits: decimalDigits,
      ).format(totalPrice);
    } catch (e) {
      // Fallback formatting if NumberFormat fails
      return '$symbol ${totalPrice.toStringAsFixed(decimalDigits)}';
    }
  }

  // Get a summary of selected options for display
  String getSelectedOptionsDisplay(int productId) {
    final options = getSelectedOptions(productId);
    if (options.isEmpty) return '';

    final buffer = StringBuffer();
    int count = 0;

    for (final option in options.values) {
      if (option.type == 'option' && option.value is Map) {
        final name = option.value['name'];
        if (name != null) {
          if (count > 0) buffer.write(', ');
          buffer.write(name);
          count++;
        }
      } else if (option.type == 'extra' && option.value is Map) {
        final name = option.value['name'];
        if (name != null) {
          if (count > 0) buffer.write(', ');
          buffer.write('+ $name');
          count++;
        }
      }

      // Limit display length
      if (count >= 3) {
        buffer.write('...');
        break;
      }
    }

    return buffer.toString();
  }

  // Calculate additional price from options only
  double getOptionsPrice(Product product) {
    if (product.id == null) return 0;

    double optionsPrice = 0;
    final selectedOptions = getSelectedOptions(product.id!);

    if (selectedOptions.isEmpty) return 0;

    for (final option in selectedOptions.values) {
      if (option.type == 'option' && option.value is Map) {
        // For dropdown options
        final optionPrice = option.value['price'];
        final isComplimentary = option.value['isComplimentary'] == true;

        // Skip adding price for complimentary items
        if (optionPrice != null && !isComplimentary) {
          double priceToAdd = 0;
          if (optionPrice is int) {
            priceToAdd = optionPrice.toDouble();
          } else if (optionPrice is double) {
            priceToAdd = optionPrice;
          } else if (optionPrice is String) {
            priceToAdd = double.tryParse(optionPrice) ?? 0;
          }

          // Check if we should apply discount to option price
          final optionDiscountable = option.value['discountable'] ?? false;
          if (optionDiscountable && hasDiscount(product)) {
            // Apply the same discount percentage to the option price
            final basePrice = product.productsPrice ?? 0;
            if (basePrice > 0) {
              final discountRatio = getDiscountedPrice(product) / basePrice;
              priceToAdd *= discountRatio;
            }
          }

          optionsPrice += priceToAdd;
        }
      } else if (option.type == 'extra' && option.value is Map) {
        // For extras
        final extraPrice = option.value['price'];
        if (extraPrice != null) {
          double priceToAdd = 0;
          if (extraPrice is int) {
            priceToAdd = extraPrice.toDouble();
          } else if (extraPrice is double) {
            priceToAdd = extraPrice;
          } else if (extraPrice is String) {
            priceToAdd = double.tryParse(extraPrice) ?? 0;
          }

          // Check if we should apply discount to extra price
          final extraDiscountable = option.value['discountable'] ?? false;
          if (extraDiscountable && hasDiscount(product)) {
            // Apply the same discount percentage to the extra price
            final basePrice = product.productsPrice ?? 0;
            if (basePrice > 0) {
              final discountRatio = getDiscountedPrice(product) / basePrice;
              priceToAdd *= discountRatio;
            }
          }

          optionsPrice += priceToAdd;
        }
      }
    }

    return optionsPrice;
  }

  // Format options price as currency string with + sign
  String getFormattedOptionsPrice(
    Product product, {
    String locale = 'id',
    String symbol = 'Rp',
    int decimalDigits = 0,
  }) {
    final optionsPrice = getOptionsPrice(product);
    if (optionsPrice <= 0) return '';

    try {
      return '+${NumberFormat.currency(locale: locale, symbol: symbol, decimalDigits: decimalDigits).format(optionsPrice)}';
    } catch (e) {
      // Fallback formatting if NumberFormat fails
      return '+$symbol ${optionsPrice.toStringAsFixed(decimalDigits)}';
    }
  }

  // Check if a product has any options selected
  bool hasSelectedOptions(int productId) {
    return state.productOptions.containsKey(productId) &&
        state.productOptions[productId]?.isNotEmpty == true;
  }

  // Count the number of selected options and extras
  int countSelectedOptions(int productId) {
    if (!state.productOptions.containsKey(productId)) return 0;
    return state.productOptions[productId]?.length ?? 0;
  }

  // Toggle a discount for a product (apply if none exists, remove if one exists)
  void toggleProductDiscount(int productId, ProductDiscount discount) {
    // Check if this product already has this discount
    final existingDiscount = state.activeDiscounts[productId];

    if (existingDiscount != null) {
      // If same discount, remove it
      if (existingDiscount.id == discount.id) {
        removeDiscountFromProduct(productId);
      } else {
        // If different discount, replace it
        applyDiscountToProduct(productId, discount);
      }
    } else {
      // If no discount, apply this one
      applyDiscountToProduct(productId, discount);
    }
  }

  // Apply or remove a single discount based on its current state
  void toggleDiscountById(int productId, int discountId) {
    // Get product and check if it exists
    final product = getProductById(productId);
    if (product == null) return;

    // Check if product has multiple discounts
    if (product.multipleDiscounts == null ||
        product.multipleDiscounts!.isEmpty) {
      return;
    }

    // Find the discount with this ID
    try {
      final discount = product.multipleDiscounts!.firstWhere(
        (d) => d.id == discountId,
      );
      toggleProductDiscount(productId, discount);
    } catch (e) {
      rethrow;
    }
  }

  // Toggle a specific option for a product (select or deselect)
  void toggleOption(int productId, String optionGroup, dynamic optionValue) {
    final options = getProductOptions(productId);
    if (options.isEmpty) {
      return;
    }

    // Find the option group
    try {
      dynamic optionGroupData;
      try {
        optionGroupData = options.firstWhere(
          (opt) => opt['uid'] == optionGroup,
        );
      } catch (e) {
        return;
      }

      final String optionType = optionGroupData['type'] ?? 'option';
      final bool isRequired = optionGroupData['required'] == true;

      if (optionType == 'option') {
        // Check if the same option is already selected
        final selectedOption = getSelectedOption(productId, optionGroup);

        final bool isSame = isSameOption(selectedOption, optionValue);

        if (isSame && !isRequired) {
          // If it's the same option and not required, remove it
          removeProductOption(productId, optionGroup);
        } else {
          // Otherwise, set the new option value
          setProductOption(productId, optionGroup, optionValue, optionType);
        }
      } else if (optionType == 'extra') {
        // For extras, toggle the selection
        final bool isCurrentlySelected = isExtraSelected(
          productId,
          optionGroup,
        );

        if (isCurrentlySelected) {
          removeProductOption(productId, optionGroup);
        } else {
          setProductOption(productId, optionGroup, optionValue, optionType);
        }
      }

      // Print the updated options state
      final updatedOptions = state.productOptions[productId];
    } catch (e) {
      rethrow;
    }
  }

  // Clear all options and discounts for a product
  void clearAllProductCustomizations(int productId) {
    // Remove discounts
    if (state.activeDiscounts.containsKey(productId)) {
      final updatedDiscounts = Map<int, ProductDiscount?>.from(
        state.activeDiscounts,
      );
      updatedDiscounts.remove(productId);

      // Remove options
      final updatedOptions = Map<int, Map<String, ProductOptionItem>>.from(
        state.productOptions,
      );
      updatedOptions.remove(productId);

      state = state.copyWith(
        activeDiscounts: updatedDiscounts,
        productOptions: updatedOptions,
      );
    }
  }

  // Copy options and discounts from one product to another
  void copyCustomizations(int sourceProductId, int targetProductId) {
    final sourceOptions = state.productOptions[sourceProductId];
    final sourceDiscount = state.activeDiscounts[sourceProductId];

    // Only copy if there's something to copy
    if (sourceOptions != null || sourceDiscount != null) {
      final updatedOptions = Map<int, Map<String, ProductOptionItem>>.from(
        state.productOptions,
      );
      final updatedDiscounts = Map<int, ProductDiscount?>.from(
        state.activeDiscounts,
      );

      // Copy options if available
      if (sourceOptions != null) {
        updatedOptions[targetProductId] = Map<String, ProductOptionItem>.from(
          sourceOptions,
        );
      }

      // Copy discount if available
      if (sourceDiscount != null) {
        updatedDiscounts[targetProductId] = sourceDiscount;
      }

      state = state.copyWith(
        activeDiscounts: updatedDiscounts,
        productOptions: updatedOptions,
      );
    }
  }

  // Check if a product has a specific discount applied
  bool hasSpecificDiscount(int productId, int discountId) {
    final activeDiscount = state.activeDiscounts[productId];
    return activeDiscount != null && activeDiscount.id == discountId;
  }

  // Get the current active discount for a product, if any
  ProductDiscount? getActiveDiscount(int productId) {
    return state.activeDiscounts[productId];
  }

  // Verify if a product with the given ID exists in the state
  bool hasProduct(int id) {
    if (state.products.isEmpty) {
      return false;
    }

    final exists = state.products.any((product) => product.id == id);
    if (!exists) {
      final availableIds = state.products.map((p) => p.id).toList();
    }

    return exists;
  }

  // Check if a product has any customizations (options or discounts)
  bool hasCustomizations(int productId) {
    return hasSelectedOptions(productId) ||
        state.activeDiscounts.containsKey(productId);
  }

  // Get a summary of all customizations for display
  String getCustomizationSummary(int productId) {
    final buffer = StringBuffer();

    // Get discount info if any
    final discount = getActiveDiscount(productId);
    if (discount != null) {
      final discountName = discount.discountName ?? 'Discount';
      final discountAmount = discount.amount;
      final discountType = discount.discountType ?? 'percentage';

      buffer.write('$discountName: ');
      if (discountType == 'percentage') {
        buffer.write('$discountAmount%');
      } else {
        buffer.write('\$$discountAmount');
      }
    }

    // Get options summary
    final optionsSummary = getSelectedOptionsDisplay(productId);
    if (optionsSummary.isNotEmpty) {
      if (buffer.isNotEmpty) buffer.write(' • ');
      buffer.write(optionsSummary);
    }

    return buffer.toString();
  }
}

// Provider definition
final productProvider = StateNotifierProvider<ProductNotifier, ProductState>((
  ref,
) {
  return ProductNotifier();
});
