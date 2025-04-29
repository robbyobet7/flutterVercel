import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rebill_flutter/core/models/cart_item.dart';
import 'package:rebill_flutter/core/providers/cart_provider.dart';
import 'package:rebill_flutter/core/theme/app_theme.dart';

class CartItemCard extends ConsumerWidget {
  const CartItemCard({super.key, required this.item, required this.index});

  final CartItem item;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.kBoxShadow,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child:
                      item.product.productImage != null &&
                              item.product.productImage!.isNotEmpty
                          ? Image.network(
                            item.product.productImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/product_placeholder.webp',
                                fit: BoxFit.cover,
                              );
                            },
                          )
                          : Image.asset(
                            'assets/images/product_placeholder.webp',
                            fit: BoxFit.cover,
                          ),
                ),
                const SizedBox(width: 12),

                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.product.productsName ?? 'Unnamed Product',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: theme.colorScheme.error,
                              size: 20,
                            ),
                            onPressed: () {
                              ref.read(cartProvider.notifier).removeItem(index);
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),

                      // Display options if any
                      if (item.selectedOptions != null &&
                          item.selectedOptions!.isNotEmpty)
                        ...buildSelectedOptions(
                          item.selectedOptions!,
                          theme,
                          currencyFormatter,
                        ),

                      // Display extras if any
                      if (item.selectedExtras != null &&
                          item.selectedExtras!.isNotEmpty)
                        ...buildSelectedExtras(
                          item.selectedExtras!,
                          item.product.option,
                          theme,
                          currencyFormatter,
                        ),

                      // Display notes if any
                      if (item.notes != null && item.notes!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.note,
                                size: 14,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Note: ${item.notes}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 8),

                      // Price and quantity controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Price
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    currencyFormatter.format(item.totalPrice),
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.primary,
                                        ),
                                  ),
                                  if (item.tax > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: Tooltip(
                                        message:
                                            'Includes ${currencyFormatter.format(item.tax)} tax',
                                        child: Icon(
                                          Icons.info_outline,
                                          size: 16,
                                          color:
                                              theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              if (item.optionsPrice > 0)
                                Text(
                                  'Options: +${currencyFormatter.format(item.optionsPrice)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),

                          // Quantity controls
                          Row(
                            children: [
                              // Decrement button
                              InkWell(
                                onTap: () {
                                  ref
                                      .read(cartProvider.notifier)
                                      .decrementQuantity(index);
                                },
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceContainer,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Icon(
                                    Icons.remove,
                                    size: 16,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),

                              // Quantity display
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                height: 28,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: theme.colorScheme.outline,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${item.quantity}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              // Increment button
                              InkWell(
                                onTap: () {
                                  ref
                                      .read(cartProvider.notifier)
                                      .incrementQuantity(index);
                                },
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    size: 16,
                                    color: theme.colorScheme.onPrimary,
                                  ),
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
        ],
      ),
    );
  }

  // Helper method to build a list of selected options
  List<Widget> buildSelectedOptions(
    Map<String, dynamic> selectedOptions,
    ThemeData theme,
    NumberFormat formatter,
  ) {
    final widgets = <Widget>[];

    selectedOptions.forEach((key, value) {
      if (value is Map<String, dynamic> && value.containsKey('name')) {
        final name = value['name'];
        final price = value['price'] ?? 0;

        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(name, style: theme.textTheme.bodySmall),
                if (price > 0) ...[
                  const SizedBox(width: 4),
                  Text(
                    '(+${formatter.format(price)})',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }
    });

    return widgets;
  }

  // Helper method to build a list of selected extras
  List<Widget> buildSelectedExtras(
    Set<String> selectedExtras,
    String? optionData,
    ThemeData theme,
    NumberFormat formatter,
  ) {
    final widgets = <Widget>[];

    if (optionData == null || !optionData.startsWith('[')) {
      return widgets;
    }

    try {
      final options = List<dynamic>.from(json.decode(optionData));

      for (final extraId in selectedExtras) {
        for (final opt in options) {
          if (opt['type'] == 'extra' && opt['uid'] == extraId) {
            final name = opt['name'] ?? 'Extra';
            final price = opt['price'] ?? 0;

            widgets.add(
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      size: 14,
                      color: theme.colorScheme.tertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(name, style: theme.textTheme.bodySmall),
                    if (price > 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        '(+${formatter.format(price)})',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      // Ignore parsing errors
    }

    return widgets;
  }
}
