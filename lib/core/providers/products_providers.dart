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

final allProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(productMiddlewareProvider);
  return repository.getAllProducts();
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
