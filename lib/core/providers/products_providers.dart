import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/models/product.dart';
import '../middleware/product_middleware.dart';

// Provider for the ProductMiddleware
final ProductMiddlewareProvider = Provider<ProductMiddleware>((ref) {
  return ProductMiddleware();
});

// Provider for the currently selected category
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// Provider for the search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider for all available products - using built-in loading state management
final availableProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(ProductMiddlewareProvider);
  final products = await repository.getProductsInStock();
  return products.where((product) => product.status == 1).toList();
});

// Provider to check if products are loading based on availableProductsProvider state
final productsLoadingProvider = Provider<bool>((ref) {
  final productsState = ref.watch(availableProductsProvider);
  return productsState.isLoading;
});

// Provider for filtered products (combines search and category filters)
final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final productsAsyncValue = ref.watch(availableProductsProvider);

  return productsAsyncValue.whenData((products) {
    // Start with all products
    List<Product> filteredProducts = products;

    // Apply category filter if selected
    if (selectedCategory != null && selectedCategory.isNotEmpty) {
      filteredProducts =
          filteredProducts
              .where(
                (product) =>
                    product.productsType == selectedCategory ||
                    product.type == selectedCategory,
              )
              .toList();
    }

    // Apply search filter if query exists
    if (searchQuery.isNotEmpty) {
      final lowercaseQuery = searchQuery.toLowerCase();
      filteredProducts =
          filteredProducts
              .where(
                (product) =>
                    product.productsName?.toLowerCase().contains(
                      lowercaseQuery,
                    ) ??
                    false,
              )
              .toList();
    }

    return filteredProducts;
  });
});

// Provider for refreshing products data
final refreshProductsProvider = Provider<void Function()>((ref) {
  return () {
    // Clear the cache in the repository
    ref.read(ProductMiddlewareProvider).refreshProducts();

    // Invalidate the products provider to trigger a refresh
    ref.invalidate(availableProductsProvider);
  };
});

// Provider for all available categories - fetches unique category types from products
final availableCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(ProductMiddlewareProvider);
  final products = await repository.getProductsInStock();
  final availableProducts =
      products.where((product) => product.status == 1).toList();

  // Extract unique category types from products
  final Set<String> categories = {};

  for (var product in availableProducts) {
    if (product.productsType != null && product.productsType!.isNotEmpty) {
      categories.add(product.productsType!);
    }
    if (product.type != 'product' && product.type.isNotEmpty) {
      categories.add(product.type);
    }
  }

  return categories.toList()..sort();
});
