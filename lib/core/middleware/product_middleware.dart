import 'dart:async';
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
  bool _isInitialized = false;

  // Stream controllers for product events
  final _productStreamController = StreamController<List<Product>>.broadcast();
  final _productErrorController = StreamController<String>.broadcast();

  // Streams that components can listen to
  Stream<List<Product>> get productsStream => _productStreamController.stream;
  Stream<String> get errorStream => _productErrorController.stream;

  // Check if initialized
  bool get isInitialized => _isInitialized;

  // Initialize the middleware
  Future<void> initialize() async {
    try {
      if (!_isInitialized) {
        await _loadProductsFromJson();
      }
      refreshProducts();
    } catch (e) {
      _productErrorController.add('Failed to initialize product data: $e');
    }
  }

  // Load products from JSON file
  Future<void> _loadProductsFromJson() async {
    try {
      // Load the JSON file
      final String jsonString = await rootBundle.loadString(
        'assets/product.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final products = Product.parseProducts(jsonString);
      setProducts(products);
    } catch (e) {
      _productErrorController.add('Failed to load products from JSON: $e');
    }
  }

  // Set products data
  void setProducts(List<Product> products) {
    _products = products;
    _isInitialized = true;
  }

  // Get a product by ID
  Future<Product?> getProductById(int id) async {
    if (!_isInitialized) {
      await initialize();
    } else {
      return _products?.firstWhere((product) => product.id == id);
    }

    try {
      return _products?.firstWhere((product) => product.id == id);
    } catch (e) {
      _productErrorController.add('Product not found with ID: $id');
      return null;
    }
  }

  // Get all products
  Future<List<Product>> getAllProducts() async {
    if (!_isInitialized) {
      await initialize();
    }
    return _products ?? [];
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
  List<Product> searchProductsByName(String query) {
    if (!_isInitialized) {
      throw Exception('Product repository not initialized');
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
