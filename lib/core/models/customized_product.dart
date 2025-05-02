import 'package:rebill_flutter/core/models/product.dart';

class CustomizedProduct {
  int id;
  double basePrice;
  double? optionsPrice;
  double? discountedPrice;
  double totalPrice;
  Map<String, dynamic>? options;
  ProductDiscount? discount;
  Product product;

  CustomizedProduct({
    required this.id,
    required this.basePrice,
    required this.product,
    this.optionsPrice,
    this.discountedPrice,
    required this.totalPrice,
    this.discount,
    this.options,
  });
}
