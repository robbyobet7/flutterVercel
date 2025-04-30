import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/features/home/providers/category_mode_provider.dart';
import 'package:rebill_flutter/core/theme/app_theme.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/providers/products_providers.dart';
import 'package:rebill_flutter/features/home/presentation/widgets/categories_grid.dart';
import 'package:rebill_flutter/features/home/presentation/widgets/products_grid.dart';
import 'package:rebill_flutter/core/widgets/app_search_bar.dart';

class HomeProducts extends ConsumerWidget {
  const HomeProducts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isCategoryMode = ref.watch(categoryModeProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: AppTheme.kBoxShadow,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        spacing: 12,
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
                  spacing: 6,
                  children: [
                    AppButton(
                      onPressed: () {
                        if (selectedCategory != null) {
                          ref.read(selectedCategoryProvider.notifier).state =
                              null;
                        } else {
                          ref
                              .read(categoryModeProvider.notifier)
                              .toggleCategoryMode();
                        }
                        if (isCategoryMode) {
                          ref.read(selectedCategoryProvider.notifier).state =
                              null;
                        }
                      },
                      text: '',
                      backgroundColor: theme.colorScheme.surfaceContainer,
                      child: Row(
                        children: [
                          selectedCategory != null
                              ? Row(
                                children: [
                                  Icon(
                                    Icons.cancel,
                                    size: 14,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  const SizedBox(width: 6),
                                ],
                              )
                              : const SizedBox(),
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
                    Container(
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
                  ],
                ),
              ],
            ),
          ),
          AppSearchBar(
            hintText: 'Search Product...',
            onSearch: (value) {
              ref.read(searchQueryProvider.notifier).state = value;
            },
            onClear: () {
              ref.read(searchQueryProvider.notifier).state = '';
            },
          ),
          isCategoryMode ? const CategoriesGrid() : const ProductsGrid(),
        ],
      ),
    );
  }
}
