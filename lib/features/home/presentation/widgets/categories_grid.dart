import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/providers/orientation_provider.dart';
import 'package:rebill_flutter/core/providers/product_provider.dart';
import 'package:rebill_flutter/core/theme/app_theme.dart';
import 'package:rebill_flutter/features/home/providers/category_mode_provider.dart';
import 'package:rebill_flutter/core/providers/products_providers.dart';

class CategoriesGrid extends ConsumerWidget {
  const CategoriesGrid({super.key});

  // Generate a color based on the index
  Color _generateColor(int index) {
    // List of bright, distinct colors
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
      Colors.cyan,
      Colors.brown,
      Colors.deepOrange,
    ];

    // For indices beyond our predefined list, generate colors using HSV
    if (index < colors.length) {
      return colors[index];
    } else {
      // Generate evenly distributed hues based on the index
      final hue = (index * 137.508) % 360; // Golden ratio for nice distribution
      return HSVColor.fromAHSV(1.0, hue, 0.7, 0.9).toColor();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isLandscape = ref.watch(orientationProvider);
    // Watch the categories provider
    final categoriesAsync = ref.watch(availableCategoriesProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Expanded(
      child: categoriesAsync.when(
        data: (categories) {
          final filteredCategories =
              searchQuery.isEmpty
                  ? categories
                  : categories
                      .where(
                        (category) => category.toLowerCase().contains(
                          searchQuery.toLowerCase(),
                        ),
                      )
                      .toList();
          if (filteredCategories.isEmpty) {
            return Center(
              child: Text(
                'No categories available',
                style: theme.textTheme.bodyMedium,
              ),
            );
          }

          return GridView.builder(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            cacheExtent: 100,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isLandscape ? 3 : 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemCount: filteredCategories.length,
            itemBuilder: (context, index) {
              final categoryName = filteredCategories[index];
              final color = _generateColor(index);
              return _buildCategoryItem(
                context,
                categoryName,
                color,
                theme,
                () {
                  // Set the selected category and exit category mode
                  ref.read(selectedCategoryProvider.notifier).state =
                      categoryName;
                  ref.read(categoryModeProvider.notifier).toggleCategoryMode();
                  ref.read(searchQueryProvider.notifier).state = '';
                  ref
                      .read(paginatedProductsProvider.notifier)
                      .applyFilter(
                        category: categoryName,
                        query: '', // Reset query
                      );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stackTrace) => Center(
              child: Text(
                'Error loading categories: $error',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    String categoryName,
    Color color,
    ThemeData theme,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: AppTheme.kBoxShadow,
          color: color.withOpacity(0.8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                categoryName,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
