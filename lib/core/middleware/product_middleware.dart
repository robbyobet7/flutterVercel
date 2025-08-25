import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../constants/app_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rebill_flutter/core/models/product_category.dart';

// Top-level function for compute()
List<Product> parseProductsJson(String jsonString) {
  final Map<String, dynamic> jsonData = json.decode(jsonString);
  final productList = jsonData['products'] as List<dynamic>;
  return productList.map((item) => Product.fromJson(item)).toList();
}

class ProductMiddleware {
  // Cache to save products
  List<Product> cachedProducts = [];
  final Dio dio = Dio();

  // Stream controllers
  final productStreamController = StreamController<List<Product>>.broadcast();
  final productErrorController = StreamController<String>.broadcast();

  //  Subscribeable streams
  Stream<List<Product>> get productsStream => productStreamController.stream;
  Stream<String> get errorStream => productErrorController.stream;

  // Constructor
  ProductMiddleware() {
    loadProductsFromJson();
  }

  // Setter untuk cache produk
  void setProducts(List<Product> products) {
    cachedProducts = products;
  }

  // Load products from JSON using compute() in a background thread
  Future<void> loadProductsFromJson() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/product.json',
      );

      // Parse JSON
      final products = await compute(parseProductsJson, jsonString);
      setProducts(products);

      productStreamController.add(products);
    } catch (e) {
      productErrorController.add('Failed to load products from JSON: $e');
    }
  }

  // Method for fetch products with API
  Future<List<Product>> fetchProductsFromAPI() async {
    try {
      final storage = FlutterSecureStorage();
      final token = await storage.read(key: AppConstants.authTokenStaffKey);

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      dio.options.headers['Authorization'] = token;

      // Make login request
      final response = await dio.get(
        AppConstants.productUrl,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data['data'];
        final List<dynamic> productList = responseData['products'] ?? [];
        final products =
            productList.map((item) => Product.fromJson(item)).toList();

        // Update products cache
        setProducts(products);

        // Update stream with new data
        productStreamController.add(products);

        return products;
      } else if (response.statusCode == 401) {
        // Handle unauthorized error (token expired/invalid)
        productErrorController.add('Unauthorized: Please log in again');
        throw Exception('Unauthorized: Please log in again');
      } else {
        final errorMessage =
            response.data['message'] ?? 'Failed to fetch products';
        productErrorController.add(errorMessage);
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['message'] ?? 'Network error occurred';
      productErrorController.add(errorMessage);
      throw Exception(errorMessage);
    } catch (e) {
      productErrorController.add(e.toString());
      throw Exception('Failed to load all products');
    }
  }

  // Method for load products from API
  Future<List<Product>> loadProductsFromAPI() async {
    try {
      return await fetchProductsFromAPI();
    } catch (e) {
      throw Exception('Failed to load all products');
    }
  }

  // Override the getAllProducts method to use the fetch API
  Future<List<Product>> getAllProducts() async {
    try {
      return await fetchProductsFromAPI();
    } catch (e) {
      throw Exception('Failed to load all products');
    }
  }

  // Override the getProductsInStock method to use the fetch API
  Future<List<Product>> getProductsInStock() async {
    try {
      final products = await fetchProductsFromAPI();
      return products.where((p) => p.status == 1 && p.isInStock).toList();
    } catch (e) {
      throw Exception('Failed to load products');
    }
  }

  //Override the getProductsByType method to use the fetch API
  Future<List<Product>> getProductsByType(String type) async {
    try {
      // Coba fetch dari API
      final products = await fetchProductsFromAPI();
      return products
          .where((p) => p.productsType == type || p.type == type)
          .toList();
    } catch (e) {
      throw Exception('Failed to load products');
    }
  }

  void refreshProducts() {
    // Delete cache products
    cachedProducts = [];

    // Trying fecth API again
    fetchProductsFromAPI().catchError((e) {
      productErrorController.add('Failed to load products');
      return <Product>[];
    });
  }

  // Dispose resources
  void dispose() {
    productStreamController.close();
    productErrorController.close();
  }

  Future<List<ProductCategory>> getProductCategories() async {
    try {
      final storage = FlutterSecureStorage();
      final token = await storage.read(key: AppConstants.authTokenStaffKey);

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Configuration with header token
      dio.options.headers['Authorization'] = token;

      final response = await dio.get(
        AppConstants.productCategoriesUrl,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      // Check response
      if (response.statusCode == 200) {
        final List<dynamic> categoryList = response.data['data'] as List;

        // Parsing data with ProductCategory Model
        final categories =
            categoryList.map((item) => ProductCategory.fromJson(item)).toList();

        return categories;
      } else if (response.statusCode == 401) {
        final errorMessage = 'Unauthorized: Token is not valid or expired';
        productErrorController.add(errorMessage);
        throw Exception(errorMessage);
      } else {
        final errorMessage =
            response.data['message'] ?? 'Failed to take products category';
        productErrorController.add(errorMessage);
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['message'] ??
          'Network Error when taking product with caregory';
      throw Exception(errorMessage);
    } catch (e) {
      productErrorController.add(e.toString());
      throw Exception('Failed to load products');
    }
  }
}
