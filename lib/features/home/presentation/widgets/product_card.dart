import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rebill_flutter/core/models/product.dart';
import 'package:rebill_flutter/core/providers/bill_provider.dart';
import 'package:rebill_flutter/core/providers/cart_provider.dart';
import 'package:rebill_flutter/core/widgets/app_material.dart';
import 'package:rebill_flutter/features/main-bill/constants/bill_constants.dart';
import 'package:rebill_flutter/features/main-bill/providers/main_bill_provider.dart';

class ProductCard extends ConsumerWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final cartItems = ref.watch(cartProvider).items;
    final itemInCart = cartItems.firstWhereOrNull(
      (item) => item.id == product.productsId,
    );
    final bool isInCart = itemInCart != null;
    final int count = itemInCart?.quantity.toInt() ?? 0;

    final price = NumberFormat.decimalPattern(
      'id_ID',
    ).format(product.productsPrice ?? 0);
    final stock =
        product.hasInfiniteStock
            ? 'Stock: ∞'
            : 'Stock: ${product.availableStock}';

    return AppMaterial(
      onTap: () {
        final selectedBill = ref.read(selectedBillProvider);
        final isBillClosed = selectedBill?.states.toLowerCase() == 'closed';

        // Notification can't add product while it's closed
        if (isBillClosed) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This bill is closed and cannot be modified.'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        final mainBillComponent = ref.read(mainBillProvider);
        if (mainBillComponent == MainBillComponent.defaultComponent) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select or create a bill first.'),
              duration: Duration(milliseconds: 1500),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        ref.read(cartProvider.notifier).addSimpleProduct(product, ref);

        // Succes add product
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${product.productsName ?? "Product"} added to bill.',
            ),
            duration: const Duration(milliseconds: 1000),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gambar Produk
          Expanded(
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: theme.colorScheme.surfaceContainer,
              ),
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
                  if (isInCart)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: theme.colorScheme.primary,
                        child: Text(
                          count.toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Detail Produk
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productsName ?? 'No Name',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Rp $price',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stock,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
