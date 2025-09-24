import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/widgets/qr_product.dart';
import 'package:rebill_flutter/features/home/providers/category_mode_provider.dart';
import 'package:rebill_flutter/core/theme/app_theme.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/providers/product_provider.dart';
import 'package:rebill_flutter/core/providers/products_providers.dart';
import 'package:rebill_flutter/features/home/presentation/widgets/categories_grid.dart';
import 'package:rebill_flutter/features/home/presentation/widgets/products_grid.dart';
import 'package:rebill_flutter/core/widgets/app_search_bar.dart';
import 'package:rebill_flutter/features/home/providers/search_provider.dart';

class HomeProducts extends ConsumerWidget {
  const HomeProducts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isCategoryMode = ref.watch(categoryModeProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final activeSearchProvider =
        isCategoryMode ? searchProvider : productSearchQueryProvider;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: AppTheme.kBoxShadow,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            width: double.infinity,
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isCategoryMode ? 'Categories' : 'Products',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    AppButton(
                      onPressed: () {
                        if (selectedCategory != null) {
                          ref.read(selectedCategoryProvider.notifier).state =
                              null;
                          final currentProductQuery = ref.read(
                            productSearchQueryProvider,
                          );
                          ref
                              .read(paginatedProductsProvider.notifier)
                              .applyFilter(
                                category: null,
                                query: currentProductQuery,
                              );
                        } else {
                          if (isCategoryMode) {
                            ref.read(searchProvider.notifier).clearSearch();
                          } else {
                            ref
                                .read(productSearchQueryProvider.notifier)
                                .clearSearch();
                            ref
                                .read(paginatedProductsProvider.notifier)
                                .applyFilter(
                                  query: '',
                                  category: ref.read(selectedCategoryProvider),
                                );
                          }
                          ref
                              .read(categoryModeProvider.notifier)
                              .toggleCategoryMode();
                        }
                      },
                      text: '',
                      backgroundColor: theme.colorScheme.surfaceContainer,
                      child: Row(
                        children: [
                          if (selectedCategory != null)
                            Row(
                              children: [
                                Icon(
                                  Icons.cancel,
                                  size: 14,
                                  color: theme.colorScheme.onSurface,
                                ),
                                const SizedBox(width: 6),
                              ],
                            ),
                          Text(
                            isCategoryMode
                                ? 'View Products'
                                : selectedCategory ?? 'View Category',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const QRProduct(
                              qrData:
                                  'https://pos-qa.rebill-pos.com/menu/eyJpdiI6ImhPSkoza1dqNkxsdTdpYytHN094bkE9PSIsInZhbHVlIjoialh5QWNxTmxuVlB3cXVSenkvYlZNQT09IiwibWFjIjoiYmQ5N2U4NmEyNTk2OGE4MjRlNzcyYWU0MjkzZDI3YjdlMjYwOGE4N2I2MWIxZjQ5YmVmNWQyYjlkNzEzMWUxNCIsInRhZyI6IiJ9',
                            );
                          },
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        width: 40,
                        height: double.infinity,
                        child: Icon(
                          Icons.qr_code_scanner,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppSearchBar(
            key: ValueKey(
              isCategoryMode ? 'categories_search' : 'products_search',
            ),
            searchProvider: activeSearchProvider,
            onSearch: (value) {
              ref.read(activeSearchProvider.notifier).updateSearchQuery(value);
              if (!isCategoryMode) {
                ref
                    .read(paginatedProductsProvider.notifier)
                    .applyFilter(query: value, category: selectedCategory);
              }
            },
            onClear: () {
              ref.read(activeSearchProvider.notifier).clearSearch();
              if (!isCategoryMode) {
                ref
                    .read(paginatedProductsProvider.notifier)
                    .applyFilter(query: '', category: selectedCategory);
              }
            },
          ),
          const SizedBox(height: 12),
          isCategoryMode ? const CategoriesGrid() : const ProductsGrid(),
        ],
      ),
    );
  }
}
