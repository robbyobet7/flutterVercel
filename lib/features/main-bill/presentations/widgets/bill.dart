import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/providers/bill_provider.dart';
import 'package:rebill_flutter/core/providers/cart_provider.dart';
import 'package:rebill_flutter/core/providers/device_provider.dart';
import 'package:rebill_flutter/core/utils/extensions.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_dialog.dart';
import 'package:rebill_flutter/features/main-bill/presentations/widgets/card_info.dart';
import 'package:rebill_flutter/features/main-bill/presentations/widgets/refund_dialog.dart';

class Bill extends ConsumerWidget {
  const Bill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final theme = Theme.of(context);
    final isWeb = ref.watch(isWebProvider);
    // Round up to nearest thousand (Indonesian common practice)
    int roundUpToThousand(double value) {
      return ((value / 1000).ceil()) * 1000;
    }

    final bill = ref.watch(billProvider.notifier);
    final isClosed = bill.billStatus == 'closed';

    final subtotal = cart.subtotal;
    final serviceFee = cart.serviceFee;
    final tax = cart.taxTotal;
    final gratuity = cart.gratuity;
    final totalBeforeRounding = subtotal + serviceFee + tax + gratuity;
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
                      Expanded(
                        flex: 2,
                        child: Text(bill.createdAt ?? 'Today, 14.24'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: Text('Bill No.')),
                      Text(': '),
                      Expanded(
                        flex: 2,
                        child: Text(bill.billNumber ?? '1234-467890'),
                      ),
                    ],
                  ),
                  if (isClosed)
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text('Paid at')),
                            Text(': '),
                            Expanded(
                              flex: 2,
                              child: Text(bill.paidAt ?? '1234-467890'),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(child: Text('Cashier')),
                            Text(': '),
                            Expanded(
                              flex: 2,
                              child: Text(bill.cashier ?? '1234-467890'),
                            ),
                          ],
                        ),
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
                          flex: 3,
                          child: Text(
                            'Name',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Tooltip(
                                  message: item.name,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: theme.textTheme.bodyMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (item.discount > 0)
                                        SizedBox(
                                          width: double.infinity,
                                          child: Row(
                                            spacing: 2,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '${item.discountName ?? "Discount"} (-${(item.discount * item.quantity).toCurrency()})',
                                                  style: theme
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(fontSize: 8),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                      if (item.options != null &&
                                          item.options!.isNotEmpty)
                                        Container(
                                          constraints: BoxConstraints(
                                            maxWidth: double.infinity,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children:
                                                item.options!.map((option) {
                                                  final isComplimentary =
                                                      option.type ==
                                                      'complimentary';

                                                  return Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          isComplimentary
                                                              ? '${option.name} (FREE)'
                                                              : '${option.name} (+${option.price.toCurrency()})',
                                                          style: theme
                                                              .textTheme
                                                              .bodySmall
                                                              ?.copyWith(
                                                                fontSize: 8,
                                                                color:
                                                                    isComplimentary
                                                                        ? theme
                                                                            .colorScheme
                                                                            .primary
                                                                        : null,
                                                              ),
                                                          maxLines: 1,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }).toList(),
                                          ),
                                        ),

                                      if (item.productNotes != null &&
                                          item.productNotes!.isNotEmpty)
                                        Container(
                                          constraints: BoxConstraints(
                                            maxWidth: double.infinity,
                                          ),
                                          child: Text(
                                            'Note: ${item.productNotes}',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  fontSize: 8,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (!isClosed)
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

                                    if (!isClosed)
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
                                  item.totalPrice.toCurrency(),
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
                      color: theme.colorScheme.surfaceContainer.withAlpha(77),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      spacing: 8,
                      children: [
                        // Product Discounts row
                        if (cart.totalProductDiscount > 0)
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Product Discounts',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                              Text(
                                "-${cart.totalProductDiscount.toCurrency()}",
                                style: theme.textTheme.bodyMedium,
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),

                        // Subtotal row
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Subtotal',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                            Text(
                              subtotal.toCurrency(),
                              style: theme.textTheme.bodyMedium,
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),

                        // Service fee row
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Service Fee (${cart.serviceFeePercentage.toStringAsFixed(0)}%)',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                            Text(
                              serviceFee.toCurrency(),
                              style: theme.textTheme.bodyMedium,
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),

                        // Gratuity row
                        if (gratuity > 0)
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Gratuity (${cart.gratuityPercentage.toStringAsFixed(0)}%)',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                              Text(
                                gratuity.toCurrency(),
                                style: theme.textTheme.bodyMedium,
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),

                        // Tax row
                        if (tax > 0)
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Tax (${cart.taxPercentage.toStringAsFixed(0)}%)',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                              Text(
                                tax.toCurrency(),
                                style: theme.textTheme.bodyMedium,
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),

                        // Rounding row
                        if (roundingAmount != 0)
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Rounding',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                              Text(
                                roundingAmount.toCurrency(),
                                style: theme.textTheme.bodyMedium,
                                textAlign: TextAlign.right,
                              ),
                            ],
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
                              total.toCurrency(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),

                        const Divider(),

                        if (isClosed)
                          Column(
                            spacing: isWeb ? 8 : 0,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: AppButton(
                                  backgroundColor:
                                      theme.colorScheme.primaryContainer,
                                  onPressed: () {},
                                  text: 'Print Bill',
                                  textStyle: theme.textTheme.bodyMedium
                                      ?.copyWith(
                                        color: theme.colorScheme.primary,
                                      ),
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: AppButton(
                                  backgroundColor:
                                      theme.colorScheme.primaryContainer,
                                  onPressed: () {},
                                  text: 'Send to WhatsApp / SMS',
                                  textStyle: theme.textTheme.bodyMedium
                                      ?.copyWith(
                                        color: theme.colorScheme.primary,
                                      ),
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: AppButton(
                                  backgroundColor:
                                      theme.colorScheme.primaryContainer,
                                  onPressed: () {},
                                  text: 'Upload Payment Proof',
                                  textStyle: theme.textTheme.bodyMedium
                                      ?.copyWith(
                                        color: theme.colorScheme.primary,
                                      ),
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: AppButton(
                                  backgroundColor:
                                      theme.colorScheme.primaryContainer,
                                  onPressed: () {
                                    AppDialog.showCustom(
                                      context,
                                      dialogType: DialogType.small,
                                      title: 'Debit/Credit Card Info',
                                      content: CardInfo(),
                                    );
                                  },
                                  text: 'Debit/Credit Card Info',
                                  textStyle: theme.textTheme.bodyMedium
                                      ?.copyWith(
                                        color: theme.colorScheme.primary,
                                      ),
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: AppButton(
                                  backgroundColor:
                                      theme.colorScheme.errorContainer,
                                  onPressed: () {
                                    AppDialog.showCustom(
                                      context,
                                      dialogType: DialogType.medium,
                                      title:
                                          'Refund / Retour Bill - ${bill.billNumber ?? '0'}',
                                      content: RefundDialog(
                                        items: cart.items,
                                        totalPrice: total,
                                      ),
                                    );
                                  },
                                  text: 'Refund / Retour',
                                  textStyle: theme.textTheme.bodyMedium
                                      ?.copyWith(
                                        color: theme.colorScheme.error,
                                      ),
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
          ],
        ),
      ),
    );
  }
}
