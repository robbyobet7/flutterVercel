import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/providers/orientation_provider.dart';
import 'package:rebill_flutter/core/theme/app_theme.dart';
import 'package:rebill_flutter/features/home/providers/category_mode_provider.dart';
import 'package:rebill_flutter/core/providers/product_providers.dart';

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

    // Category data - color will be generated automatically
    final categories = [
      'Food & Beverages',
      'Electronics',
      'Clothing',
      'Health & Beauty',
      'Home & Living',
      'Sports',
      'Books',
      'Toys',
      'Stationery',
      'Digital Goods',
      'Services',
      'Others',
    ];

    return Expanded(
      child: GridView.builder(
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
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final categoryName = categories[index];
          final color = _generateColor(index);
          return _buildCategoryItem(context, categoryName, color, theme, () {
            // Set the selected category and exit category mode
            ref.read(selectedCategoryProvider.notifier).state = categoryName;
            ref.read(categoryModeProvider.notifier).toggleCategoryMode();
          });
        },
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: AppTheme.kBoxShadow,
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Text(
            categoryName,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
