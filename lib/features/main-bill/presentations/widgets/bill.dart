import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rebill_flutter/core/models/bill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/providers/bill_provider.dart';
import 'package:rebill_flutter/core/providers/cart_provider.dart';
import 'package:rebill_flutter/core/providers/checkout_discount_provider.dart';
import 'package:rebill_flutter/core/providers/checkout_rewards_provider.dart';
import 'package:rebill_flutter/core/utils/extensions.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_dialog.dart';
import 'package:rebill_flutter/features/main-bill/presentations/widgets/card_info.dart';
import 'package:rebill_flutter/features/main-bill/presentations/widgets/refund_dialog.dart';
import 'package:rebill_flutter/core/models/cart_item.dart';
import 'package:intl/intl.dart';

class Bill extends ConsumerWidget {
  const Bill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final checkoutDiscount = ref.watch(checkoutDiscountProvider);
    final checkoutRewards = ref.watch(checkoutRewardsProvider);
    final theme = Theme.of(context);

    int roundUpToThousand(double value) {
      return ((value / 1000).ceil()) * 1000;
    }

    final billState = ref.watch(billProvider);
    final selectedBill = billState.selectedBill;
    final isClosed = billState.selectedBill?.states.toLowerCase() == 'closed';

    // Formatters and formatted strings
    final DateFormat dateFormatter = DateFormat('dd/MM/yyyy HH.mm');

    String _formatDateTime(DateTime? dt) {
      if (dt == null) return '-';
      return dateFormatter.format(dt);
    }

    String _formatIsoString(String? iso) {
      if (iso == null || iso.isEmpty) return '-';
      try {
        return dateFormatter.format(DateTime.parse(iso));
      } catch (_) {
        return iso;
      }
    }

    final String createdAtText = _formatDateTime(selectedBill?.createdAt);
    final String paidAtText = _formatIsoString(selectedBill?.posPaidBillDate);
    final String billNoText =
        ((selectedBill?.cBillId ?? '').replaceFirst(
              RegExp(r'^BILL-'),
              '',
            )).trim().isNotEmpty
            ? (selectedBill!.cBillId.replaceFirst(RegExp(r'^BILL-'), ''))
            : '-';

    // Calculate basic values
    final subtotal = cart.subtotal;
    final serviceFee = cart.serviceFee;
    final tax = cart.taxTotal;
    final gratuity = cart.gratuity;

    // Calculate totals based on bill status
    final double totalBeforeRounding;
    final double finalTotal;

    if (isClosed && selectedBill != null) {
      totalBeforeRounding = selectedBill.totalaftertax;
      finalTotal = selectedBill.finalTotal;
    } else {
      double total = cart.total;

      // Apply checkout discount first
      if (checkoutDiscount.appliedDiscounts.isNotEmpty) {
        total = cart.getTotalWithCheckoutDiscount(
          checkoutDiscount.totalDiscountAmount,
        );
      }

      // Apply reward discount
      if (checkoutRewards.selectedReward != null) {
        total = checkoutRewards.subtotalAfterDiscount;
      }

      totalBeforeRounding = total;
      final roundingAmount =
          roundUpToThousand(totalBeforeRounding) - totalBeforeRounding;
      finalTotal = totalBeforeRounding + roundingAmount;
    }

    // Build items for display: use closed bill items when bill is closed
    List<CartItem> _itemsForDisplay() {
      if (isClosed && selectedBill != null) {
        if (selectedBill.items != null && selectedBill.items!.isNotEmpty) {
          return selectedBill.items!;
        }
        try {
          final List<dynamic> parsed = jsonDecode(selectedBill.orderCollection);
          return parsed.map((e) => CartItem.fromJson(e)).toList();
        } catch (_) {
          return const <CartItem>[];
        }
      }
      return cart.items;
    }

    final List<CartItem> displayedItems = _itemsForDisplay();

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
                      const Expanded(child: Text('Created at')),
                      const Text(': '),
                      Expanded(flex: 2, child: Text(createdAtText)),
                    ],
                  ),
                  Row(
                    children: [
                      const Expanded(child: Text('Bill No.')),
                      const Text(': '),
                      Expanded(flex: 2, child: Text(billNoText)),
                    ],
                  ),
                  if (isClosed)
                    Column(
                      children: [
                        Row(
                          children: [
                            const Expanded(child: Text('Paid at')),
                            const Text(': '),
                            Expanded(flex: 2, child: Text(paidAtText)),
                          ],
                        ),
                        Row(
                          children: [
                            const Expanded(child: Text('Cashier')),
                            const Text(': '),
                            Expanded(
                              flex: 2,
                              child: Text(
                                selectedBill?.cashier ?? '1234-467890',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
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
                  ...displayedItems.asMap().entries.map((entry) {
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
                                          constraints: const BoxConstraints(
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
                                          constraints: const BoxConstraints(
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
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: Text(item.totalPrice.toCurrency()),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (index != displayedItems.length - 1)
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
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer.withAlpha(77),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
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
                        if (isClosed && selectedBill?.discountList != null)
                          ..._buildClosedBillDiscounts(selectedBill!, theme)
                        else if (checkoutDiscount.appliedDiscounts.isNotEmpty)
                          ..._buildOpenBillDiscounts(checkoutDiscount, theme),
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
                        const Divider(),
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
                              finalTotal.toCurrency(),
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
                                      content: const CardInfo(),
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
                                          'Refund / Retour Bill - ${selectedBill?.cBillId ?? '0'}',
                                      content: RefundDialog(
                                        items: cart.items,
                                        totalPrice: finalTotal,
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

  List<Widget> _buildClosedBillDiscounts(
    BillModel selectedBill,
    ThemeData theme,
  ) {
    try {
      final List<dynamic> discounts = jsonDecode(
        selectedBill.discountList ?? '[]',
      );
      if (discounts.isEmpty) return [];

      return discounts.map<Widget>((discount) {
        final Map<String, dynamic> d = discount as Map<String, dynamic>;
        return Row(
          children: [
            Expanded(
              child: Text(
                'Discount (${d['name']})',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            Text(
              d['type'] == 'percentage'
                  ? '${d['amount']}%'
                  : '-${d['amount'].toDouble().toCurrency()}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  List<Widget> _buildOpenBillDiscounts(
    CheckoutDiscountState checkoutDiscount,
    ThemeData theme,
  ) {
    return checkoutDiscount.appliedDiscounts.map((discount) {
      return Row(
        children: [
          Expanded(
            child: Text(
              'Discount (${discount.name})',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Text(
            discount.type == 'percentage'
                ? '${discount.amount.toInt()}%'
                : '-${discount.amount.toCurrency()}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      );
    }).toList();
  }
}
