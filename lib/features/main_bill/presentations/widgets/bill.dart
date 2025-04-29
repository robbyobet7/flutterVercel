import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rebill_flutter/core/providers/cart_provider.dart';

class Bill extends ConsumerWidget {
  const Bill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final theme = Theme.of(context);
    final currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: '',
      decimalDigits: 0,
    );

    // Round up to nearest thousand (Indonesian common practice)
    int roundUpToThousand(double value) {
      return ((value / 1000).ceil()) * 1000;
    }

    final subtotal = cart.subtotal;
    final serviceFee = cart.serviceFee;
    final tax = cart.taxTotal;
    final totalBeforeRounding = subtotal + serviceFee + tax;
    final roundingAmount =
        roundUpToThousand(totalBeforeRounding) - totalBeforeRounding;
    final total = totalBeforeRounding + roundingAmount;

    return Expanded(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: Text('Created at')),
                      Text(': '),
                      Expanded(flex: 2, child: Text('Today, 14.24')),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: Text('Bill No.')),
                      Text(': '),
                      Expanded(flex: 2, child: Text('1234-567890')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Cart table
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Table header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer,
                      borderRadius: const BorderRadius.only(),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Name',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Qty',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Subtotal',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...cart.items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Tooltip(
                                  message:
                                      item.product.productsName ??
                                      'Unnamed Product',
                                  child: Text(
                                    item.product.productsName ??
                                        'Unnamed Product',
                                    style: theme.textTheme.bodyMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color:
                                              theme
                                                  .colorScheme
                                                  .surfaceContainer,
                                          borderRadius: BorderRadius.circular(
                                            9999,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.remove,
                                          size: 14,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ),

                                    // Quantity display
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      height: 24,
                                      constraints: const BoxConstraints(
                                        minWidth: 30,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${item.quantity}',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
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
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary,
                                          borderRadius: BorderRadius.circular(
                                            9999,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.add,
                                          size: 14,
                                          color: theme.colorScheme.onPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  currencyFormatter.format(item.totalPrice),
                                  style: theme.textTheme.bodyMedium,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (index != cart.items.length - 1)
                          Divider(
                            height: 1,
                            thickness: 1,
                            indent: 12,
                            endIndent: 12,
                            color: theme.colorScheme.surfaceContainer,
                          ),
                      ],
                    );
                  }),

                  // Summary section
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer.withOpacity(
                        0.3,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        // Subtotal row
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Subtotal',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                              Text(
                                currencyFormatter.format(subtotal),
                                style: theme.textTheme.bodyMedium,
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                        ),

                        // Service fee row
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Service Fee (${cart.serviceFeePercentage.toStringAsFixed(0)}%)',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                              Text(
                                currencyFormatter.format(serviceFee),
                                style: theme.textTheme.bodyMedium,
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                        ),

                        // Tax row
                        if (tax > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Tax (${cart.taxPercentage.toStringAsFixed(0)}%)',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                                Text(
                                  currencyFormatter.format(tax),
                                  style: theme.textTheme.bodyMedium,
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                          ),

                        // Rounding row
                        if (roundingAmount > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Rounding',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                                Text(
                                  currencyFormatter.format(roundingAmount),
                                  style: theme.textTheme.bodyMedium,
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                          ),

                        const Divider(),

                        // Total row
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Total',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              currencyFormatter.format(total),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                              textAlign: TextAlign.right,
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
      ),
    );
  }
}
