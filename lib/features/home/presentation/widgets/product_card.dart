import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/models/product.dart';
import 'package:rebill_flutter/core/providers/cart_provider.dart';
import 'package:rebill_flutter/core/theme/app_theme.dart';
import 'package:rebill_flutter/core/widgets/app_dialog.dart';
import 'package:rebill_flutter/features/home/presentation/widgets/product_detail.dart';

class ProductCard extends ConsumerWidget {
  const ProductCard({
    super.key,
    required this.price,
    required this.stock,
    required this.product,
  });

  final String price;
  final String stock;
  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final items = ref.watch(cartProvider);
    final bool isInCart = items.items.any(
      (item) => item.id == product.productsId,
    );
    final int count =
        items.items
            .where((item) => item.id == product.productsId)
            .firstOrNull
            ?.quantity
            .toInt() ??
        0;

    return GestureDetector(
      onTap: () {
        AppDialog.showCustom(
          context,
          content: ProductDetail(product: product),
          width: MediaQuery.of(context).size.width * .7,
          height:
              (product.multipleDiscounts!.isEmpty && product.option == null)
                  ? MediaQuery.of(context).size.height * .43
                  : MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(12),
        );
      },
      child: Container(
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
                child: Stack(
                  fit: StackFit.expand,
                  children: [
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
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
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

                    // Check if the product is in the cart
                    isInCart
                        ? Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: theme.colorScheme.primary,
                            child: Text(
                              count.toString(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                        : const SizedBox(),
                  ],
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
                    spacing: 2,
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
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        spacing: 4,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            color: theme.colorScheme.onSurface,
                            size: 12,
                          ),
                          Text(
                            stock,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
