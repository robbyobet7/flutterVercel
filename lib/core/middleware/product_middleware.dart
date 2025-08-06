import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../constants/app_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Top-level function untuk compute()
List<Product> parseProductsJson(String jsonString) {
  final Map<String, dynamic> jsonData = json.decode(jsonString);
  final productList = jsonData['products'] as List<dynamic>;
  return productList.map((item) => Product.fromJson(item)).toList();
}

class ProductMiddleware {
  // Cache untuk menyimpan produk
  List<Product> _cachedProducts = [];
  final Dio dio = Dio();

  // Stream controllers
  final productStreamController = StreamController<List<Product>>.broadcast();
  final productErrorController = StreamController<String>.broadcast();

  // Streams yang bisa di-subscribe
  Stream<List<Product>> get productsStream => productStreamController.stream;
  Stream<String> get errorStream => productErrorController.stream;

  // Konstruktor
  ProductMiddleware() {
    // Load produk saat instance dibuat
    loadProductsFromJson();
  }

  // Setter untuk cache produk
  void setProducts(List<Product> products) {
    _cachedProducts = products;
  }

  // Load products dari JSON menggunakan compute() di background thread
  Future<void> loadProductsFromJson() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/product.json',
      );

      // Parse JSON di background thread dengan compute()
      final products = await compute(parseProductsJson, jsonString);
      setProducts(products);

      // Update stream dengan data baru
      productStreamController.add(products);
    } catch (e) {
      productErrorController.add('Failed to load products from JSON: $e');
    }
  }

  // Metode untuk fetch produk dari API
  Future<List<Product>> fetchProductsFromAPI() async {
    try {
      // Ambil token dari secure storage
      final storage = FlutterSecureStorage();
      final token = await storage.read(key: AppConstants.authTokenStaffKey);

      if (token == null) {
        print('Authentication token not found'); // Debug: Cetak pesan
        throw Exception('Authentication token not found');
      }

      // Konfigurasi header dengan token
      dio.options.headers['Authorization'] = '$token';

      // Make login request
      final response = await dio.get(
        AppConstants.productUrl,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      // Periksa status response
      if (response.statusCode == 200) {
        // Parse data produk dari response dengan struktur baru
        final Map<String, dynamic> responseData = response.data['data'];
        final List<dynamic> productList = responseData['products'] ?? [];
        final products =
            productList.map((item) => Product.fromJson(item)).toList();

        // Update cache produk
        setProducts(products);

        // Update stream dengan data baru
        productStreamController.add(products);

        return products;
      } else if (response.statusCode == 401) {
        // Handle unauthorized error (token expired/invalid)
        productErrorController.add('Unauthorized: Please log in again');
        throw Exception('Unauthorized: Please log in again');
      } else {
        // Handle error response
        final errorMessage =
            response.data['message'] ?? 'Failed to fetch products';
        productErrorController.add(errorMessage);
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      // Handle network atau koneksi error
      final errorMessage =
          e.response?.data?['message'] ?? 'Network error occurred';
      print('Dio Error: $errorMessage'); // Debug: Cetak error Dio
      print('Error Details: ${e.toString()}'); // Debug: Cetak detail error
      productErrorController.add(errorMessage);
      throw Exception(errorMessage);
    } catch (e) {
      // Handle error umum
      print(
        'Unexpected Error: ${e.toString()}',
      ); // Debug: Cetak error tidak terduga
      productErrorController.add(e.toString());
      throw Exception('Gagal load product');
    }
  }

  // Metode untuk load produk dari API
  Future<List<Product>> loadProductsFromAPI() async {
    try {
      return await fetchProductsFromAPI();
    } catch (e) {
      // Lempar exception dengan pesan error
      throw Exception('Gagal load product');
    }
  }

  // Override metode getAllProducts untuk menggunakan fetch API terlebih dahulu
  Future<List<Product>> getAllProducts() async {
    try {
      // Coba fetch dari API terlebih dahulu
      return await fetchProductsFromAPI();
    } catch (e) {
      // Jika fetch API gagal, lempar exception
      throw Exception('Gagal load product');
    }
  }

  // Override metode getProductsInStock untuk menggunakan fetch API
  Future<List<Product>> getProductsInStock() async {
    try {
      // Coba fetch dari API
      final products = await fetchProductsFromAPI();
      return products.where((p) => p.status == 1 && p.isInStock).toList();
    } catch (e) {
      // Jika fetch API gagal, lempar exception
      throw Exception('Gagal load product');
    }
  }

  // Override metode getProductsByType untuk menggunakan fetch API
  Future<List<Product>> getProductsByType(String type) async {
    try {
      // Coba fetch dari API
      final products = await fetchProductsFromAPI();
      return products
          .where((p) => p.productsType == type || p.type == type)
          .toList();
    } catch (e) {
      // Jika fetch API gagal, lempar exception
      throw Exception('Gagal load product');
    }
  }

  // Override metode refreshProducts untuk melakukan fetch ulang dari API
  void refreshProducts() {
    // Hapus cache produk
    _cachedProducts = [];

    // Coba fetch ulang dari API
    fetchProductsFromAPI().catchError((e) {
      // Jika fetch gagal, tampilkan error
      productErrorController.add('Gagal load product');
    });
  }

  // Dispose resources
  void dispose() {
    productStreamController.close();
    productErrorController.close();
  }
}
