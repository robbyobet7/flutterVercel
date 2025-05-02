import '../middleware/product_middleware.dart';
import '../models/product.dart';

class ProductRepository {
  final ProductMiddleware _middleware = ProductMiddleware();

  // Get all products
  Future<List<Product>> getAllProducts() async {
    return await _middleware.getProducts();
  }

  // Get a product by ID
  Future<Product?> getProductById(int id) async {
    return await _middleware.getProductById(id);
  }

  // Get products by type
  Future<List<Product>> getProductsByType(String type) async {
    return await _middleware.getProductsByType(type);
  }

  // Get products in stock
  Future<List<Product>> getProductsInStock() async {
    return await _middleware.getProductsInStock();
  }

  // Search products by name
  Future<List<Product>> searchProductsByName(String query) async {
    if (query.isEmpty) return await getAllProducts();

    final products = await getAllProducts();
    final lowercaseQuery = query.toLowerCase();

    return products
        .where(
          (product) =>
              product.productsName?.toLowerCase().contains(lowercaseQuery) ??
              false,
        )
        .toList();
  }

  // Get products with discounts
  Future<List<Product>> getDiscountedProducts() async {
    final products = await getAllProducts();
    return products
        .where(
          (product) =>
              product.productsDiscount != null && product.productsDiscount! > 0,
        )
        .toList();
  }

  // Refresh product data (clear cache)
  void refreshProducts() {
    _middleware.clearCache();
  }
}
