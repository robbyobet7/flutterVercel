import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/models/product.dart';
import 'package:rebill_flutter/core/providers/orientation_provider.dart';
import 'package:rebill_flutter/core/theme/app_theme.dart';
import 'package:rebill_flutter/core/providers/product_providers.dart';

class ProductsGrid extends ConsumerWidget {
  const ProductsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isLandscape = ref.watch(orientationProvider);
    final productsAsyncValue = ref.watch(filteredProductsProvider);
    // final isLoading = ref.watch(productsLoadingProvider);

    return Expanded(
      child: productsAsyncValue.when(
        data: (products) {
          if (products.isEmpty) {
            return Center(
              child: Text(
                'No products found',
                style: theme.textTheme.bodyLarge,
              ),
            );
          }

          return GridView.builder(
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
            // Use actual product count
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              // Use actual product data
              return _buildProductItem(context, product, theme);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stackTrace) => Center(
              child: Text(
                'Error loading products: $error',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
      ),
    );
  }

  // Updated method to build product item with real data
  Widget _buildProductItem(
    BuildContext context,
    Product product,
    ThemeData theme,
  ) {
    // Format price with proper separators
    final price =
        product.productsPrice
            ?.toStringAsFixed(0)
            .replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]}.',
            ) ??
        '0';

    // Get stock information
    final stock =
        product.hasInfiniteStock ? '∞' : product.availableStock.toString();

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
              child:
                  product.productImage != null &&
                          product.productImage!.isNotEmpty
                      ? Image.network(
                        product.productImage!,
                        fit: BoxFit.cover,
                        cacheWidth: 300,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/product_placeholder.webp',
                            fit: BoxFit.cover,
                            cacheWidth: 300,
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                            ),
                          );
                        },
                      )
                      : Image.asset(
                        'assets/images/product_placeholder.webp',
                        fit: BoxFit.cover,
                        cacheWidth: 300,
                        frameBuilder: (
                          context,
                          child,
                          frame,
                          wasSynchronouslyLoaded,
                        ) {
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
                  product.productsName ?? 'Unnamed Product',
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
