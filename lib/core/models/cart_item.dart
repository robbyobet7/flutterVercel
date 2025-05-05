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
  });

  factory CartItemOption.fromJson(Map<String, dynamic> json) {
    return CartItemOption(
      optionName: json['optionName'],
      name: json['name'],
      type: json['type'],
      price:
          json['price'] is int
              ? (json['price'] as int).toDouble()
              : (json['price'] ?? 0).toDouble(),
      purchPrice:
          json['purchPrice'] is int
              ? (json['purchPrice'] as int).toDouble()
              : (json['purchPrice'] ?? 0).toDouble(),
      relationItem: json['relation_item'],
      productId: json['product_id'],
      productStock: json['product_stock'],
      productType: json['product_type'],
    );
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
  double get totalDiscountAmount => discount * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    List<CartItemOption>? optionsList;
    if (json['options'] != null) {
      if (json['options'] is List) {
        optionsList =
            (json['options'] as List)
                .map((option) => CartItemOption.fromJson(option))
                .toList();
      }
    }

    List<String>? printerList;
    if (json['category_bill_printer'] != null) {
      if (json['category_bill_printer'] is List) {
        printerList =
            (json['category_bill_printer'] as List)
                .map((p) => p.toString())
                .toList();
      }
    }

    return CartItem(
      id: json['id'],
      name: json['name'],
      price:
          (json['price'] is int)
              ? (json['price'] as int).toDouble()
              : json['price'],
      quantity:
          (json['quantity'] is int)
              ? (json['quantity'] as int).toDouble()
              : json['quantity'],
      type: json['type'],
      purchprice:
          (json['purchprice'] is int)
              ? (json['purchprice'] as int).toDouble()
              : json['purchprice'],
      includedtax:
          (json['includedtax'] is int)
              ? (json['includedtax'] as int).toDouble()
              : (json['includedtax'] ?? 0),
      options: optionsList,
      category: json['category'],
      categoryBillPrinter: printerList,
      productNotes: json['productNotes'],
      originalPrice:
          (json['original_price'] is int)
              ? (json['original_price'] as int).toDouble()
              : json['original_price'],
      originalPurchprice:
          (json['original_purchprice'] is int)
              ? (json['original_purchprice'] as int).toDouble()
              : json['original_purchprice'],
      discountType: json['discount_type'],
      discountValue: json['discount_value'],
      discount:
          (json['discount'] is int)
              ? (json['discount'] as int).toDouble()
              : (json['discount'] ?? 0).toDouble(),
      discountName: json['discount_name'],
      discountProducts: json['discount_products'],
      discountRules: json['discount_rules'],
      discountType2: json['discount_type2'],
      discountId: json['discount_id'],
      productDiscountType: json['productDiscountType'],
      isCashProductDiscount: json['isCashProductDiscount'],
      totalDiscountRules:
          json['totaldiscountrules'] != null
              ? (json['totaldiscountrules'] is int)
                  ? (json['totaldiscountrules'] as int).toDouble()
                  : json['totaldiscountrules']
              : null,
    );
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
