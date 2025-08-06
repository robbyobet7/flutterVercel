import 'dart:convert';

class Product {
  final int? id;
  final int? productsId;
  final double? productsPrice;
  final double? purchPrice;
  final dynamic productsStock; // Can be a number or "∞" (infinity)
  final double? tax;
  final int? outletId;
  final String? createdAt;
  final String? updatedAt;
  final int? status;
  final int? infinitystock;
  final String? deletedAt;
  final int? sold;
  final dynamic billPrinter; // Can be a string or an array
  final String? productsName;
  final String? productsType;
  final double? productsDiscount;
  final dynamic productsDiscountValue; // Can be a number or a string
  final String? productsDiscountName;
  final String? discountProducts;
  final String? discountType2;
  final int? discountRules;
  final int? discountId;
  final bool? discountPin;
  final List<ProductDiscount>? multipleDiscounts;
  final String? option;
  final String type;
  final String? productImage;

  Product({
    this.id,
    this.productsId,
    this.productsPrice,
    this.purchPrice,
    this.productsStock,
    this.tax,
    this.outletId,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.infinitystock,
    this.deletedAt,
    this.sold,
    this.billPrinter,
    this.productsName,
    this.productsType,
    this.productsDiscount,
    this.productsDiscountValue,
    this.productsDiscountName,
    this.discountProducts,
    this.discountType2,
    this.discountRules,
    this.discountId,
    this.discountPin,
    this.multipleDiscounts,
    this.option,
    required this.type,
    this.productImage,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['products_id'], // Gunakan products_id sebagai id
      productsId: json['products_id'],
      productsPrice: json['products_price']?.toDouble(),
      purchPrice: json['purchPrice']?.toDouble(),
      productsStock: json['products_stock'],
      tax: json['tax']?.toDouble(),
      outletId: json['owner_id'], // Gunakan owner_id sebagai outletId
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      status: json['status'],
      infinitystock: json['infinitystock'],
      deletedAt: json['deleted_at'],
      sold: json['sold'],
      billPrinter: json['bill_printer'],
      productsName: json['products_name'],
      productsType: json['products_type'],
      productsDiscount: json['products_discount']?.toDouble(),
      productsDiscountValue: json['products_discount_value'],
      productsDiscountName: json['products_discount_name'],
      discountProducts: json['discount_products'],
      discountType2: json['discount_type2'],
      discountRules: json['discount_rules'],
      discountId: json['discount_id'],
      discountPin: json['discount_pin'],
      multipleDiscounts:
          json['discounts'] != null
              ? List<ProductDiscount>.from(
                (json['discounts'] as List).map(
                  (discount) => ProductDiscount.fromJson(
                    discount as Map<String, dynamic>,
                  ),
                ),
              )
              : null,
      option:
          json['option'] != null
              ? jsonEncode(json['option'])
              : null, // Encode option sebagai string JSON
      type: json['products_type'] ?? 'product',
      productImage:
          json['product_image'] ??
          json['product_image_s3'], // Gunakan product_image atau product_image_s3
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (id != null) data['id'] = id;
    if (productsId != null) data['products_id'] = productsId;
    if (productsPrice != null) data['products_price'] = productsPrice;
    if (purchPrice != null) data['purchPrice'] = purchPrice;
    data['products_stock'] = productsStock;
    if (tax != null) data['tax'] = tax;
    if (outletId != null) data['outlet_id'] = outletId;
    if (createdAt != null) data['created_at'] = createdAt;
    if (updatedAt != null) data['updated_at'] = updatedAt;
    if (status != null) data['status'] = status;
    if (infinitystock != null) data['infinitystock'] = infinitystock;
    if (deletedAt != null) data['deleted_at'] = deletedAt;
    if (sold != null) data['sold'] = sold;
    if (billPrinter != null) data['bill_printer'] = billPrinter;
    if (productsName != null) data['products_name'] = productsName;
    if (productsType != null) data['products_type'] = productsType;
    if (productsDiscount != null) data['products_discount'] = productsDiscount;
    if (productsDiscountValue != null) {
      data['products_discount_value'] = productsDiscountValue;
    }
    if (productsDiscountName != null) {
      data['products_discount_name'] = productsDiscountName;
    }
    if (discountProducts != null) data['discount_products'] = discountProducts;
    if (discountType2 != null) data['discount_type2'] = discountType2;
    if (discountRules != null) data['discount_rules'] = discountRules;
    if (discountId != null) data['discount_id'] = discountId;
    if (discountPin != null) data['discount_pin'] = discountPin;
    if (multipleDiscounts != null) {
      data['multipleDiscounts'] =
          multipleDiscounts!.map((discount) => discount.toJson()).toList();
    }
    if (option != null) data['option'] = option;
    data['type'] = type;
    if (productImage != null) data['product_image'] = productImage;
    return data;
  }

  // Helper method to check if a product has infinite stock
  bool get hasInfiniteStock => infinitystock == 1 || productsStock == "∞";

  // Helper to get the available stock (returns a large number for infinite stock)
  int get availableStock {
    if (hasInfiniteStock) return 999999;

    if (productsStock is int) {
      return productsStock;
    } else if (productsStock is String && productsStock != "∞") {
      return int.tryParse(productsStock) ?? 0;
    }

    return 0;
  }

  // Helper to check if product is in stock
  bool get isInStock => hasInfiniteStock || availableStock > 0;

  // Get the final price after discount
  double get defaultPrice {
    return productsPrice ?? 0;
  }

  static List<Product> parseProducts(String jsonString) {
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    final List<dynamic> products = jsonData['products'];
    return products.map((product) => Product.fromJson(product)).toList();
  }
}

// Add a class for the multiple discounts
class ProductDiscount {
  final int? id;
  final String? discountName;
  final String? discountType;
  final dynamic amount; // Can be percentage or fixed amount
  final int? status;
  final int? outletId;
  final String? createdAt;
  final String? updatedAt;
  final int? discountRules;
  final dynamic discountCapped;
  final int? count;
  final dynamic discountPin; // Can be boolean or string (encrypted pin)
  final String? discountProducts;
  final int? isCashProductDiscount;
  final dynamic discountDailyLimit;
  final dynamic total;
  final Map<String, dynamic>? discount;
  final double? productsDiscount;
  final dynamic productsDiscountValue;
  final String? productsDiscountName;
  final String? discountType2;
  final int? discountId;

  ProductDiscount({
    this.id,
    this.discountName,
    this.discountType,
    this.amount,
    this.status,
    this.outletId,
    this.createdAt,
    this.updatedAt,
    this.discountRules,
    this.discountCapped,
    this.count,
    this.discountPin,
    this.discountProducts,
    this.isCashProductDiscount,
    this.discountDailyLimit,
    this.total,
    this.discount,
    this.productsDiscount,
    this.productsDiscountValue,
    this.productsDiscountName,
    this.discountType2,
    this.discountId,
  });

  factory ProductDiscount.fromJson(Map<String, dynamic> json) {
    return ProductDiscount(
      id: json['discount_id'], // Gunakan discount_id sebagai id
      discountName: json['discount_name'],
      discountType: json['discount_type'],
      amount: json['amount'],
      status: json['status'],
      outletId: json['outlet_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      discountRules: json['discount_rules'],
      discountCapped: json['discount_capped'],
      count: json['count'],
      discountPin: json['discount_pin'],
      discountProducts: json['discount_products'],
      isCashProductDiscount: json['is_cash_product_discount'],
      discountDailyLimit: json['discount_daily_limit'],
      total: json['total'],
      discount: json['discount'],
      productsDiscount: json['products_discount']?.toDouble(),
      productsDiscountValue: json['products_discount_value'],
      productsDiscountName: json['products_discount_name'],
      discountType2: json['discount_type2'],
      discountId: json['discount_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (id != null) data['id'] = id;
    if (discountName != null) data['discount_name'] = discountName;
    if (discountType != null) data['discount_type'] = discountType;
    if (amount != null) data['amount'] = amount;
    if (status != null) data['status'] = status;
    if (outletId != null) data['outlet_id'] = outletId;
    if (createdAt != null) data['created_at'] = createdAt;
    if (updatedAt != null) data['updated_at'] = updatedAt;
    if (discountRules != null) data['discount_rules'] = discountRules;
    if (discountCapped != null) data['discount_capped'] = discountCapped;
    if (count != null) data['count'] = count;
    if (discountPin != null) data['discount_pin'] = discountPin;
    if (discountProducts != null) data['discount_products'] = discountProducts;
    if (isCashProductDiscount != null) {
      data['is_cash_product_discount'] = isCashProductDiscount;
    }
    if (discountDailyLimit != null) {
      data['discount_daily_limit'] = discountDailyLimit;
    }
    if (total != null) data['total'] = total;
    if (discount != null) data['discount'] = discount;
    if (productsDiscount != null) data['products_discount'] = productsDiscount;
    if (productsDiscountValue != null) {
      data['products_discount_value'] = productsDiscountValue;
    }
    if (productsDiscountName != null) {
      data['products_discount_name'] = productsDiscountName;
    }
    if (discountType2 != null) data['discount_type2'] = discountType2;
    if (discountId != null) data['discount_id'] = discountId;
    return data;
  }
}
