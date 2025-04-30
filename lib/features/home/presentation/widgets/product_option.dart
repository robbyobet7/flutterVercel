import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rebill_flutter/core/models/product.dart';
import 'package:rebill_flutter/core/providers/product_providers.dart';
import 'package:rebill_flutter/core/theme/app_theme.dart';
import 'package:rebill_flutter/features/home/presentation/widgets/option_preview.dart';

class ProductOption extends ConsumerWidget {
  const ProductOption({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    // Check if there are multiple discounts available
    final hasMultipleDiscounts =
        product.multipleDiscounts != null &&
        product.multipleDiscounts!.isNotEmpty;

    // Get active discount from provider or product
    final activeDiscount =
        ref.watch(activeDiscountProvider) ?? product.activeDiscount;

    // Calculate the final price based on the active discount
    double finalPrice =
        product.productsPrice != null ? product.productsPrice! : 0;
    if (activeDiscount != null && activeDiscount.total != null) {
      finalPrice = finalPrice - (activeDiscount.total as num).toDouble();
    } else {
      finalPrice = product.defaultPrice;
    }

    // Update the final price provider with the new value
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(finalPriceProvider.notifier).update((state) => finalPrice);
    });

    return Expanded(
      flex: 3,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppTheme.kBoxShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.productsName ?? 'Product Name',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product.productsType ?? 'Category',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                product.hasInfiniteStock
                                    ? Icons.all_inclusive
                                    : Icons.inventory_2_outlined,
                                size: 14,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                product.hasInfiniteStock
                                    ? 'Unlimited'
                                    : '${product.availableStock} in stock',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Display product options or additional info
                    if (product.option != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Product Options',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      OptionPreview(option: product.option!),
                    ],

                    // Show available discounts if any
                    if (hasMultipleDiscounts) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Available Discounts',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 60,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          cacheExtent: 10,
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          itemCount: product.multipleDiscounts!.length,
                          itemBuilder: (context, index) {
                            final discount = product.multipleDiscounts![index];
                            final discountName =
                                discount.discountName ?? 'Discount';
                            final discountAmount = discount.total ?? 0;
                            final needsPin = discount.discountPin == true;

                            return GestureDetector(
                              onTap: () {
                                ref
                                    .read(activeDiscountProvider.notifier)
                                    .state = discount;
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      discount == activeDiscount
                                          ? theme.colorScheme.errorContainer
                                          : theme.colorScheme.surfaceContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          discountName,
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    discount == activeDiscount
                                                        ? theme
                                                            .colorScheme
                                                            .error
                                                        : theme
                                                            .colorScheme
                                                            .onSurface,
                                              ),
                                        ),
                                        if (needsPin) ...[
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.lock,
                                            size: 12,
                                            color:
                                                discount == activeDiscount
                                                    ? theme.colorScheme.error
                                                    : theme
                                                        .colorScheme
                                                        .onSurface,
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.discount,
                                          size: 12,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          currencyFormatter.format(
                                            discountAmount,
                                          ),
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Price section
            if (product.discountAmount > 0) ...[
              Row(
                children: [
                  Text(
                    currencyFormatter.format(product.productsPrice),
                    style: theme.textTheme.titleMedium?.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.productsPrice != null &&
                              product.productsPrice! > 0
                          ? '${(product.discountAmount / product.productsPrice! * 100).toStringAsFixed(0)}% OFF'
                          : 'DISCOUNT',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormatter.format(finalPrice),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    height: 1.3,
                  ),
                ),
                const Spacer(),
                if (product.sold != null && product.sold! > 0) ...[
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${product.sold} sold',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
