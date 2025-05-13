import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/product.dart';

class ProductRepository {
  // Singleton pattern
  static final ProductRepository _instance = ProductRepository._internal();
  factory ProductRepository() => _instance;
  ProductRepository._internal();

  // Cache for products
  List<Product>? _products;
  bool _isInitialized = false;

  // Stream controllers for product events
  final _productStreamController = StreamController<List<Product>>.broadcast();
  final _productErrorController = StreamController<String>.broadcast();

  // Streams that components can listen to
  Stream<List<Product>> get productsStream => _productStreamController.stream;
  Stream<String> get errorStream => _productErrorController.stream;

  // Check if initialized
  bool get isInitialized => _isInitialized;

  // Initialize repository with data
  Future<void> initialize() async {
    if (_isInitialized) return;
    await loadProducts();
  }

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

      _isInitialized = true;

      // Broadcast the loaded products
      _productStreamController.add(_products!);
      return _products!;
    } catch (e) {
      _productErrorController.add('Failed to load products: $e');
      return [];
    }
  }

  // Get all products
  Future<List<Product>> getAllProducts() async {
    if (!_isInitialized) {
      await initialize();
    }
    return _products ?? [];
  }

  // Get a product by ID
  Future<Product?> getProductById(int id) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      return _products?.firstWhere((product) => product.id == id);
    } catch (e) {
      _productErrorController.add('Product not found with ID: $id');
      return null;
    }
  }

  // Get products by type
  Future<List<Product>> getProductsByType(String type) async {
    if (!_isInitialized) {
      await initialize();
    }

    return _products?.where((product) => product.type == type).toList() ?? [];
  }

  // Get products in stock
  Future<List<Product>> getProductsInStock() async {
    if (!_isInitialized) {
      await initialize();
    }

    return _products?.where((product) => product.isInStock).toList() ?? [];
  }

  // Search products by name
  Future<List<Product>> searchProductsByName(String query) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (query.isEmpty) return _products ?? [];

    final lowercaseQuery = query.toLowerCase();
    return _products
            ?.where(
              (product) =>
                  product.productsName?.toLowerCase().contains(
                    lowercaseQuery,
                  ) ??
                  false,
            )
            .toList() ??
        [];
  }

  // Refresh product data (clear cache)
  Future<void> refreshProducts() async {
    _products = null;
    _isInitialized = false;
    await initialize();
  }

  // Get products for serialization
  List<Map<String, dynamic>> getProductsForSerialization() {
    if (!_isInitialized) {
      throw Exception('Product repository not initialized');
    }
    return _products?.map((p) => p.toJson()).toList() ?? [];
  }

  // Dispose resources
  void dispose() {
    _productStreamController.close();
    _productErrorController.close();
  }
}
