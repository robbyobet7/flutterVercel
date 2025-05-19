import 'dart:convert';

class StockTaking {
  final int id;
  final int productId;
  final String productName;
  final int productStock;
  final int productInfinityStock;
  final String productCategory;
  final int status;
  final StockTakingType type;
  final String? barcodeProduct;
  final String? qrCodeProduct;

  StockTaking({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productStock,
    required this.productInfinityStock,
    required this.productCategory,
    required this.status,
    required this.type,
    this.barcodeProduct,
    this.qrCodeProduct,
  });
  factory StockTaking.fromJson(Map<String, dynamic> json) {
    return StockTaking(
      id: json['id'],
      productId: json['product_id'],
      productName: json['product_name'],
      productStock: json['product_stock'],
      productInfinityStock: json['product_infinity_stock'],
      productCategory: json['product_category'],
      status: json['status'],
      type:
          json['type'] == 'prep'
              ? StockTakingType.prep
              : json['type'] == 'product'
              ? StockTakingType.product
              : json['type'] == 'volume' || json['type'] == 'prep_volume'
              ? StockTakingType.volume
              : json['type'] == 'piece' || json['type'] == 'prep_piece'
              ? StockTakingType.piece
              : StockTakingType.weight,
      barcodeProduct: json['barcode_product'],
      qrCodeProduct: json['qr_code_product'],
    );
  }

  factory StockTaking.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return StockTaking.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'product_stock': productStock,
      'product_infinity_stock': productInfinityStock,
      'product_category': productCategory,
      'status': status,
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}

enum StockTakingType { prep, product, volume, weight, piece }
