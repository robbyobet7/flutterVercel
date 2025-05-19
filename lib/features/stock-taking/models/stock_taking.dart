import 'dart:convert';

import 'package:rebill_flutter/core/models/product.dart';

class StockTaking {
  final List<Product> products;

  StockTaking({required this.products});

  factory StockTaking.fromJson(Map<String, dynamic> json) {
    return StockTaking(
      products:
          (json['dataProducts'] as List)
              .map((product) => Product.fromJson(product))
              .toList(),
    );
  }

  factory StockTaking.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return StockTaking.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'dataProducts': products.map((product) => product.toJson()).toList(),
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
