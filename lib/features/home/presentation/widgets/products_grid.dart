import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/models/product.dart';
import 'package:rebill_flutter/core/providers/orientation_provider.dart';
import 'package:rebill_flutter/core/providers/product_providers.dart';
import 'package:rebill_flutter/features/home/presentation/widgets/product_card.dart';

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

    return ProductCard(price: price, stock: stock, product: product);
  }
}
