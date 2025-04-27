import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/features/home/providers/category_mode_provider.dart';
import 'package:rebill_flutter/core/theme/app_theme.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/features/home/presentation/widgets/categories_grid.dart';
import 'package:rebill_flutter/features/home/presentation/widgets/products_grid.dart';
import 'package:rebill_flutter/features/home/presentation/widgets/search_bar.dart';

class HomeProducts extends ConsumerWidget {
  const HomeProducts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isCategoryMode = ref.watch(categoryModeProvider);

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
                  children: [
                    AppButton(
                      onPressed: () {
                        ref
                            .read(categoryModeProvider.notifier)
                            .toggleCategoryMode();
                      },
                      text:
                          isCategoryMode ? 'View Products' : 'Select Category',
                      backgroundColor: theme.colorScheme.surfaceContainer,
                    ),
                    const SizedBox(width: 6),
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
          const HomeSearchBar(),
          isCategoryMode ? const CategoriesGrid() : const ProductsGrid(),
        ],
      ),
    );
  }
}
