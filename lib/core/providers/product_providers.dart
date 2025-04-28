import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/models/product.dart';
import 'package:rebill_flutter/core/services/product_service.dart';

// Provider for the ProductService
final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

// Provider for the currently selected category
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// Provider for the search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider for all available products - using built-in loading state management
final availableProductsProvider = FutureProvider<List<Product>>((ref) async {
  final productService = ref.watch(productServiceProvider);
  final products = await productService.getAvailableProducts();
  return products;
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
    // Clear the cache in the service
    ref.read(productServiceProvider).refreshProducts();

    // Invalidate the products provider to trigger a refresh
    ref.invalidate(availableProductsProvider);
  };
});
