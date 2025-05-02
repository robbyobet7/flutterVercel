import '../repositories/product_repository.dart';
import '../models/product.dart';

class ProductService {
  final ProductRepository _repository = ProductRepository();

  // Get all available products
  Future<List<Product>> getAvailableProducts() async {
    // Get products that are in stock and have active status
    final products = await _repository.getProductsInStock();
    return products.where((product) => product.status == 1).toList();
  }

  // Get popular products (based on sold count)
  Future<List<Product>> getPopularProducts({int limit = 10}) async {
    final products = await _repository.getAllProducts();

    // Sort by sold count in descending order
    products.sort((a, b) => (b.sold ?? 0).compareTo(a.sold ?? 0));

    // Return top products based on limit
    return products.take(limit).toList();
  }

  // Get products by category/type
  Future<List<Product>> getProductsByCategory(String category) async {
    return await _repository.getProductsByType(category);
  }

  // Search products with filtering
  Future<List<Product>> searchProducts({
    String? query,
    String? type,
    bool? inStockOnly,
    bool? discountedOnly,
  }) async {
    List<Product> products = await _repository.getAllProducts();

    // Apply search query filter
    if (query != null && query.isNotEmpty) {
      final lowercaseQuery = query.toLowerCase();
      products =
          products
              .where(
                (product) =>
                    product.productsName?.toLowerCase().contains(
                      lowercaseQuery,
                    ) ??
                    false,
              )
              .toList();
    }

    // Apply type filter
    if (type != null && type.isNotEmpty) {
      products =
          products
              .where(
                (product) =>
                    product.productsType == type || product.type == type,
              )
              .toList();
    }

    // Apply in-stock filter
    if (inStockOnly == true) {
      products = products.where((product) => product.isInStock).toList();
    }

    // Apply discounted filter
    if (discountedOnly == true) {
      products =
          products
              .where(
                (product) =>
                    product.productsDiscount != null &&
                        product.productsDiscount! > 0 ||
                    product.multipleDiscounts != null &&
                        product.multipleDiscounts!.isNotEmpty,
              )
              .toList();
    }

    return products;
  }

  // Refresh product data
  void refreshProducts() {
    _repository.refreshProducts();
  }
}
