import 'package:flutter/material.dart';
import 'package:rebill_flutter/core/models/product.dart';
import 'package:rebill_flutter/core/theme/app_theme.dart';
import 'package:rebill_flutter/core/widgets/app_dialog.dart';
import 'package:rebill_flutter/features/home/presentation/widgets/product_detail.dart';

class ProductCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
      ),
    );
  }
}
