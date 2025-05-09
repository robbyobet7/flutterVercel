import 'package:flutter/foundation.dart';

class CartItemOption {
  final String? optionName;
  final String name;
  final String type;
  final double price;
  final double purchPrice;
  final List<dynamic>? relationItem;

  // For complimentary item
  final int? productId;
  final dynamic productStock;
  final String? productType;
  final bool? isComplimentary;

  CartItemOption({
    this.optionName,
    required this.name,
    required this.type,
    required this.price,
    required this.purchPrice,
    this.relationItem,
    this.productId,
    this.productStock,
    this.productType,
    this.isComplimentary,
  });

  factory CartItemOption.fromJson(Map<String, dynamic> json) {
    try {
      // Helper functions for safe type conversion
      String? safeString(dynamic value) {
        if (value == null) return null;
        return value.toString();
      }

      double safeDouble(dynamic value, {double defaultValue = 0.0}) {
        if (value == null) return defaultValue;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) {
          try {
            return double.parse(value);
          } catch (_) {
            return defaultValue;
          }
        }
        return defaultValue;
      }

      return CartItemOption(
        optionName: json['optionName'],
        name: safeString(json['name']) ?? 'Unknown',
        type: safeString(json['type']) ?? 'Unknown',
        price: safeDouble(json['price']),
        purchPrice: safeDouble(json['purchPrice']),
        relationItem: json['relation_item'],
        productId: json['product_id'],
        productStock: json['product_stock'],
        productType: json['product_type'],
      );
    } catch (e) {
      print('❌ Error in CartItemOption.fromJson: $e');
      print('❌ Problem JSON: $json');
      throw FormatException('Failed to parse CartItemOption: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      if (optionName != null) 'optionName': optionName,
      'name': name,
      'type': type,
      'price': price,
      'purchPrice': purchPrice,
      if (relationItem != null) 'relation_item': relationItem,
      if (productId != null) 'product_id': productId,
      if (productStock != null) 'product_stock': productStock,
      if (productType != null) 'product_type': productType,
    };
  }
}

class CartItem {
  final int id;
  final String name;
  final double price;
  final double quantity;
  final String type; // product or recipe
  final double purchprice;
  final double includedtax;
  final List<CartItemOption>? options;
  final String category;
  final List<String>? categoryBillPrinter;
  final String? productNotes;
  final double originalPrice;
  final double originalPurchprice;

  // Discount related fields
  final String? discountType;
  final dynamic discountValue;
  final double discount;
  final String? discountName;
  final String? discountProducts;
  final dynamic discountRules;
  final String? discountType2;
  final dynamic discountId;
  final String? productDiscountType;
  final bool? isCashProductDiscount;
  final double? totalDiscountRules;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.type,
    required this.purchprice,
    required this.includedtax,
    this.options,
    required this.category,
    this.categoryBillPrinter,
    this.productNotes,
    required this.originalPrice,
    required this.originalPurchprice,
    this.discountType,
    this.discountValue,
    this.discount = 0,
    this.discountName,
    this.discountProducts,
    this.discountRules,
    this.discountType2,
    this.discountId,
    this.productDiscountType,
    this.isCashProductDiscount,
    this.totalDiscountRules,
  });

  // Calculate the base price of the product
  double get basePrice => originalPrice;

  // Calculate the price after applying product discounts, multiplied by quantity
  double get totalPrice => price * quantity;

  // Calculate the total discount amount
  double get totalDiscountAmount {
    // We already store the per-unit discount amount in the discount field
    // So we just multiply it by the quantity to get the total discount
    return discount * quantity;
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    // Helper function to convert a value to a string safely
    String? safeString(dynamic value) {
      if (value == null) return null;
      return value.toString();
    }

    // Helper function to convert int to bool (1 = true, 0 = false)
    bool? intToBool(dynamic value) {
      if (value == null) return null;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) {
        if (value.toLowerCase() == 'true' || value == '1') return true;
        if (value.toLowerCase() == 'false' || value == '0') return false;
      }
      return null;
    }

    // Helper function to safely convert to double
    double safeDouble(dynamic value, {double defaultValue = 0.0}) {
      if (value == null) return defaultValue;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (_) {
          return defaultValue;
        }
      }
      return defaultValue;
    }

    try {
      // First ensure we have all the necessary fields with default values
      final double originalPrice = safeDouble(json['original_price']);
      double price = safeDouble(json['price']);
      final double quantity = safeDouble(json['quantity'], defaultValue: 1.0);

      // Parse discount values
      final String? discountType = safeString(json['discount_type']);
      final dynamic discountValue = json['discount_value'];
      double discount = safeDouble(json['discount']);

      // Make a more robust check for discount
      // If discount is missing but we have discountType and discountValue,
      // calculate the discount amount
      if (discount == 0 && discountType != null && discountValue != null) {
        if (discountType == 'percentage') {
          // If discount type is percentage, calculate discount amount
          double percentage = safeDouble(discountValue);
          discount = (percentage / 100) * originalPrice;
          print('📊 Recalculated discount from percentage: $discount');
        } else if (discountType == 'fixed') {
          // If discount type is fixed, use the value directly
          discount = safeDouble(discountValue);
          print('📊 Recalculated discount from fixed value: $discount');
        }
      }

      // For debugging: Check if original price and price match
      if (originalPrice > 0 && price < originalPrice) {
        print(
          '🔍 Price ($price) is less than originalPrice ($originalPrice), possible discount: ${originalPrice - price}',
        );

        // If the price is already less than originalPrice and there's no discount,
        // calculate the implied discount
        if (discount == 0) {
          discount = originalPrice - price;
          print('🔄 Setting discount based on price difference: $discount');
        }
      } else if (originalPrice > 0 && discount > 0) {
        // Check if price already includes the discount
        if (originalPrice - price >= discount - 0.01) {
          // Allow for small rounding errors
          // Price is already discounted, keep the price and discount as is
          print('✅ Price already reflects the discount, keeping values as is');
        } else {
          // Price doesn't reflect discount yet, adjust it
          double discountedPrice = originalPrice - discount;
          if (discountedPrice != price) {
            print(
              '🔄 Adjusting price to reflect discount: old=$price, new=$discountedPrice',
            );
            price = discountedPrice > 0 ? discountedPrice : 0;
          }
        }
      }

      // Process options with error handling
      List<CartItemOption>? optionsList;
      if (json['options'] != null) {
        if (json['options'] is List) {
          try {
            optionsList =
                (json['options'] as List)
                    .where((option) => option != null)
                    .map((option) {
                      try {
                        return CartItemOption.fromJson(option);
                      } catch (e) {
                        print('⚠️ Skipping invalid option: $e');
                        return null;
                      }
                    })
                    .whereType<CartItemOption>() // Remove nulls
                    .toList();
          } catch (e) {
            print('⚠️ Error processing options list: $e');
            optionsList = null;
          }
        }
      }

      // Process category bill printer
      List<String>? printerList;
      if (json['category_bill_printer'] != null) {
        if (json['category_bill_printer'] is List) {
          try {
            printerList =
                (json['category_bill_printer'] as List)
                    .map((p) => p.toString())
                    .toList();
          } catch (e) {
            print('⚠️ Error processing printer list: $e');
            printerList = null;
          }
        }
      }

      // Final check to ensure originalPrice is set correctly
      double finalOriginalPrice =
          originalPrice > 0 ? originalPrice : price + discount;

      // Print final values for debugging
      print('📊 Final values for item: ${json['name']}');
      print('   - Original price: $finalOriginalPrice');
      print('   - Final price: $price');
      print('   - Discount: $discount');
      print('   - Total item price (with qty=$quantity): ${price * quantity}');
      print('   - Total discount: ${discount * quantity}');

      return CartItem(
        id:
            json['id'] is String
                ? int.tryParse(json['id']) ?? 0
                : json['id'] ?? 0,
        name: json['name'] ?? 'Unknown',
        price: price, // Use the potentially adjusted price
        quantity: quantity,
        type: safeString(json['type']) ?? 'product',
        purchprice: safeDouble(json['purchprice']),
        includedtax: safeDouble(json['includedtax']),
        options: optionsList,
        category: safeString(json['category']) ?? 'Unknown',
        categoryBillPrinter: printerList,
        productNotes: safeString(json['productNotes']),
        originalPrice: finalOriginalPrice,
        originalPurchprice: safeDouble(json['original_purchprice']),
        discountType: discountType,
        discountValue: discountValue,
        discount: discount,
        discountName: safeString(json['discount_name']),
        discountProducts: safeString(json['discount_products']),
        discountRules: json['discount_rules'],
        discountType2: safeString(json['discount_type2']),
        discountId: json['discount_id'],
        productDiscountType: safeString(json['productDiscountType']),
        isCashProductDiscount: intToBool(json['isCashProductDiscount']),
        totalDiscountRules: safeDouble(json['totaldiscountrules']),
      );
    } catch (e) {
      print('❌ Error in CartItem.fromJson: $e');
      print('❌ Problem JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'type': type,
      'purchprice': purchprice,
      'includedtax': includedtax,
      'options': options?.map((o) => o.toJson()).toList(),
      'category': category,
      'category_bill_printer': categoryBillPrinter,
      'productNotes': productNotes,
      'original_price': originalPrice,
      'original_purchprice': originalPurchprice,
      'discount_type': discountType,
      'discount_value': discountValue,
      'discount': discount,
      'discount_name': discountName,
      'discount_products': discountProducts,
      'discount_rules': discountRules,
      'discount_type2': discountType2,
      'discount_id': discountId,
      'productDiscountType': productDiscountType,
      'isCashProductDiscount': isCashProductDiscount,
      'totaldiscountrules': totalDiscountRules,
    };
  }

  CartItem copyWith({
    int? id,
    String? name,
    double? price,
    double? quantity,
    String? type,
    double? purchprice,
    double? includedtax,
    List<CartItemOption>? options,
    String? category,
    List<String>? categoryBillPrinter,
    String? productNotes,
    double? originalPrice,
    double? originalPurchprice,
    String? discountType,
    dynamic discountValue,
    double? discount,
    String? discountName,
    String? discountProducts,
    dynamic discountRules,
    String? discountType2,
    dynamic discountId,
    String? productDiscountType,
    bool? isCashProductDiscount,
    double? totalDiscountRules,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      type: type ?? this.type,
      purchprice: purchprice ?? this.purchprice,
      includedtax: includedtax ?? this.includedtax,
      options: options ?? this.options,
      category: category ?? this.category,
      categoryBillPrinter: categoryBillPrinter ?? this.categoryBillPrinter,
      productNotes: productNotes ?? this.productNotes,
      originalPrice: originalPrice ?? this.originalPrice,
      originalPurchprice: originalPurchprice ?? this.originalPurchprice,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      discount: discount ?? this.discount,
      discountName: discountName ?? this.discountName,
      discountProducts: discountProducts ?? this.discountProducts,
      discountRules: discountRules ?? this.discountRules,
      discountType2: discountType2 ?? this.discountType2,
      discountId: discountId ?? this.discountId,
      productDiscountType: productDiscountType ?? this.productDiscountType,
      isCashProductDiscount:
          isCashProductDiscount ?? this.isCashProductDiscount,
      totalDiscountRules: totalDiscountRules ?? this.totalDiscountRules,
    );
  }

  // Check if two cart items are equal (for comparison in the cart)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! CartItem) return false;

    // Two cart items are considered equal if they have the same product ID and options
    return other.id == id && listEquals(other.options, options);
  }

  @override
  int get hashCode {
    return Object.hash(id, Object.hashAll(options ?? []));
  }
}
