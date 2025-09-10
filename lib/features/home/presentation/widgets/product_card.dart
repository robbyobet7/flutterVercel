// product_card.dart (Versi Final dengan Optimasi Gambar)

import 'package:cached_network_image/cached_network_image.dart'; // <-- IMPORT BARU
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/models/product.dart';
import 'package:rebill_flutter/core/providers/cart_provider.dart';
import 'package:rebill_flutter/core/theme/app_theme.dart';
import 'package:rebill_flutter/core/widgets/app_dialog.dart';
import 'package:rebill_flutter/features/home/presentation/widgets/product_detail.dart';
import 'package:rebill_flutter/features/main-bill/constants/bill_constants.dart';
import 'package:rebill_flutter/features/main-bill/providers/main_bill_provider.dart';

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
        final bool isComplexProduct =
            product.hasOptions || product.hasMultipleDiscounts;
        final mainBillComponent = ref.read(mainBillProvider);

        if (isComplexProduct) {
          AppDialog.showCustom(
            context,
            content: ProductDetail(product: product),
            dialogType: DialogType.large,
            padding: const EdgeInsets.all(12),
          );
        } else {
          if (mainBillComponent == MainBillComponent.defaultComponent) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('There is no active bill.'),
                duration: Duration(milliseconds: 1500),
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }
          ref.read(cartProvider.notifier).addSimpleProduct(product, ref);

          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${product.productsName ?? "Product"} added to bill.',
              ),
              duration: const Duration(milliseconds: 1000),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          );
        }
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
                        ? CachedNetworkImage(
                          imageUrl: product.productImage!,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) =>
                                  Container(color: Colors.grey[200]),
                          errorWidget:
                              (context, url, error) => Image.asset(
                                'assets/images/product_placeholder.webp',
                                fit: BoxFit.cover,
                              ),
                        )
                        : Image.asset(
                          'assets/images/product_placeholder.webp',
                          fit: BoxFit.cover,
                        ),

                    // Check if the product is in the cart
                    if (isInCart)
                      Positioned(
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
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            color: theme.colorScheme.onSurface.withAlpha(179),
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            stock,
                            textAlign: TextAlign.start,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(179),
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
