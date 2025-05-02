import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/product.dart';

class ProductMiddleware {
  // Singleton pattern
  static final ProductMiddleware _instance = ProductMiddleware._internal();
  factory ProductMiddleware() => _instance;
  ProductMiddleware._internal();

  // Cache for products
  List<Product>? _products;

  // Load products from JSON file
  Future<List<Product>> loadProducts() async {
    if (_products != null) {
      return _products!;
    }

    try {
      // Load the JSON file
      final String jsonString = await rootBundle.loadString(
        'assets/product.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Check if data contains a list of products
      if (jsonData.containsKey('products') && jsonData['products'] is List) {
        _products =
            (jsonData['products'] as List)
                .map((item) => Product.fromJson(item))
                .toList();
      } else {
        // If JSON structure is just an array of products
        _products =
            (jsonData as List).map((item) => Product.fromJson(item)).toList();
      }

      return _products!;
    } catch (e) {
      print('Error loading products: $e');
      return [];
    }
  }

  // Get all products
  Future<List<Product>> getProducts() async {
    return await loadProducts();
  }

  // Get a specific product by ID
  Future<Product?> getProductById(int id) async {
    final products = await loadProducts();
    try {
      return products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get products by type
  Future<List<Product>> getProductsByType(String type) async {
    final products = await loadProducts();
    return products.where((product) => product.type == type).toList();
  }

  // Get products in stock
  Future<List<Product>> getProductsInStock() async {
    final products = await loadProducts();
    return products.where((product) => product.isInStock).toList();
  }

  // Clear cache (useful when data needs to be refreshed)
  void clearCache() {
    _products = null;
  }
}
