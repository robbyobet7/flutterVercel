import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/models/product.dart';
import 'package:rebill_flutter/core/models/product_category.dart';
import '../middleware/product_middleware.dart';

// Provider for the ProductMiddleware
final productMiddlewareProvider = Provider<ProductMiddleware>((ref) {
  return ProductMiddleware();
});

// Provider for the currently selected category
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// Provider for the search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider for all available products - using built-in loading state management
final availableProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(productMiddlewareProvider);
  final products = await repository.getProductsInStock();
  return products.where((product) => product.status == 1).toList();
});

final availableCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(productMiddlewareProvider);

  final List<ProductCategory> categoryObjects =
      await repository.getProductCategories();

  final List<String> categoryNames =
      categoryObjects.map((category) => category.categoriesName).toList();

  categoryNames.sort();
  return categoryNames;
});

// Provider to check if products are loading based on availableProductsProvider state
final productsLoadingProvider = Provider<bool>((ref) {
  final productsState = ref.watch(availableProductsProvider);
  return productsState.isLoading;
});

// Provider for filtered products (combines search and category filters)
final filteredProductsProvider = Provider<List<Product>>((ref) {
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  // watch the value from availableProductsProvider
  final productsAsyncValue = ref.watch(availableProductsProvider);
  return productsAsyncValue.maybeWhen(
    data: (products) {
      List<Product> filteredList = products;

      // Filter by category
      if (selectedCategory != null && selectedCategory.isNotEmpty) {
        filteredList =
            filteredList
                .where(
                  (product) =>
                      product.productsType == selectedCategory ||
                      product.type == selectedCategory,
                )
                .toList();
      }

      // Filter by search
      if (searchQuery.isNotEmpty) {
        final lowercaseQuery = searchQuery.toLowerCase();
        filteredList =
            filteredList
                .where(
                  (product) =>
                      product.productsName?.toLowerCase().contains(
                        lowercaseQuery,
                      ) ??
                      false,
                )
                .toList();
      }

      return filteredList;
    },
    orElse: () => [],
  );
});

// Provider for refresh a products
final refreshProductsProvider = Provider<void Function()>((ref) {
  return () {
    ref.read(productMiddlewareProvider).refreshProducts();
    ref.invalidate(availableProductsProvider);
  };
});
