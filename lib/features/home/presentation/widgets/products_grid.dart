import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/providers/orientation_provider.dart';
import 'package:rebill_flutter/core/theme/app_theme.dart';

class ProductsGrid extends ConsumerWidget {
  const ProductsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isLandscape = ref.watch(orientationProvider);

    return Expanded(
      child: GridView.builder(
        // Add physics for smoother scrolling
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        // Add padding to improve visual experience
        padding: const EdgeInsets.symmetric(horizontal: 4),
        // Add cacheExtent to improve scroll performance by pre-rendering
        cacheExtent: 100,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isLandscape ? 2 : 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: .8,
        ),
        // Use itemCount to avoid unnecessary calculations
        itemCount: 100, // Adjust with your actual item count
        itemBuilder: (context, index) {
          // Extract the product widget creation for better readability
          return _buildProductItem(context, index, theme);
        },
      ),
    );
  }

  // Extracted method to build product item
  Widget _buildProductItem(BuildContext context, int index, ThemeData theme) {
    // Calculate price once
    final price = (index * 10000).toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );

    // Calculate stock once
    final stock = index * 100;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: AppTheme.kBoxShadow,
        color: theme.colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.hardEdge,
              child: Image.asset(
                'assets/images/product_placeholder.webp',
                fit: BoxFit.cover,
                // Add caching for smoother scrolling with images
                cacheWidth: 300,
                // Add frame building callback to optimize image loading
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded || frame != null) {
                    return child;
                  }
                  return AnimatedOpacity(
                    opacity: frame != null ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    child: child,
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Product $index',
                  textAlign: TextAlign.start,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'IDR ',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          TextSpan(
                            text: price,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Stock: $stock',
                      textAlign: TextAlign.start,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
