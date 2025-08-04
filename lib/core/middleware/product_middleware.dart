import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';

// Top-level function untuk compute()
List<Product> _parseProductsJson(String jsonString) {
  final Map<String, dynamic> jsonData = json.decode(jsonString);
  final productList = jsonData['products'] as List<dynamic>;
  return productList.map((item) => Product.fromJson(item)).toList();
}

class ProductMiddleware {
  // Cache untuk menyimpan produk
  List<Product> _cachedProducts = [];

  // Stream controllers
  final _productStreamController = StreamController<List<Product>>.broadcast();
  final _productErrorController = StreamController<String>.broadcast();

  // Streams yang bisa di-subscribe
  Stream<List<Product>> get productsStream => _productStreamController.stream;
  Stream<String> get errorStream => _productErrorController.stream;

  // Konstruktor
  ProductMiddleware() {
    // Load produk saat instance dibuat
    _loadProductsFromJson();
  }

  // Setter untuk cache produk
  void setProducts(List<Product> products) {
    _cachedProducts = products;
  }

  // Load products dari JSON menggunakan compute() di background thread
  Future<void> _loadProductsFromJson() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/product.json',
      );

      // Parse JSON di background thread dengan compute()
      final products = await compute(_parseProductsJson, jsonString);
      setProducts(products);

      // Update stream dengan data baru
      _productStreamController.add(products);
    } catch (e) {
      _productErrorController.add('Failed to load products from JSON: $e');
    }
  }

  // Metode untuk mendapatkan semua produk
  Future<List<Product>> getAllProducts() async {
    if (_cachedProducts.isEmpty) {
      await _loadProductsFromJson();
    }
    return _cachedProducts;
  }

  // Metode untuk mendapatkan produk in stock
  Future<List<Product>> getProductsInStock() async {
    final products = await getAllProducts();
    return products.where((p) => p.isInStock).toList();
  }

  // Metode untuk mendapatkan produk berdasarkan tipe
  Future<List<Product>> getProductsByType(String type) async {
    final products = await getAllProducts();
    return products
        .where((p) => p.productsType == type || p.type == type)
        .toList();
  }

  // Refresh cache produk
  void refreshProducts() {
    _cachedProducts = [];
    _loadProductsFromJson();
  }

  // Dispose resources
  void dispose() {
    _productStreamController.close();
    _productErrorController.close();
  }
}
