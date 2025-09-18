import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/providers/bill_provider.dart';
import 'package:rebill_flutter/core/providers/cart_provider.dart';
import 'package:rebill_flutter/core/providers/checkout_discount_provider.dart';
import 'package:rebill_flutter/core/providers/checkout_rewards_provider.dart';
import 'package:rebill_flutter/core/utils/extensions.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_dialog.dart';
import 'package:rebill_flutter/core/widgets/table_dialog.dart';
import 'package:rebill_flutter/features/main-bill/constants/bill_constants.dart';
import 'package:rebill_flutter/features/main-bill/presentations/widgets/known_individual_dialog.dart';
import 'package:rebill_flutter/features/main-bill/presentations/widgets/bill.dart';
import 'package:rebill_flutter/features/main-bill/presentations/widgets/empty_cart.dart';
import 'package:rebill_flutter/features/main-bill/presentations/widgets/total_price_card.dart';
import 'package:rebill_flutter/features/main-bill/providers/main_bill_provider.dart';
import 'package:rebill_flutter/features/main-bill/presentations/widgets/customer_expandable.dart';
import 'package:share_plus/share_plus.dart';
import 'package:rebill_flutter/features/login/providers/staff_auth_provider.dart';

class MainBillPage extends ConsumerWidget {
  const MainBillPage({super.key});

  // Function to cancel and reset bill
  void _cancelBill(WidgetRef ref) {
    resetMainBill(ref);
  }

  // Function to create receipt text and share it
  void _shareBill(BuildContext context, WidgetRef ref) async {
    final cart = ref.read(cartProvider);
    final billState = ref.read(billProvider);
    final selectedBill = billState.selectedBill;
    final checkoutDiscount = ref.read(checkoutDiscountProvider);
    final checkoutRewards = ref.read(checkoutRewardsProvider);
    final isClosed = selectedBill?.states.toLowerCase() == 'closed';
    // Also get current staff for fallback cashier name
    final staffState = ref.read(staffAuthProvider);
    final fallbackCashierName = staffState.loggedInStaff?.name ?? '-';

    if (selectedBill == null) return;

    // Rounded
    int roundUpToThousand(double value) => ((value / 1000).ceil()) * 1000;

    // Calculating the final total, the logic is the same as that in the Bill widget.
    final double finalTotal;
    if (isClosed) {
      finalTotal = selectedBill.finalTotal;
    } else {
      double total = cart.total;
      if (checkoutDiscount.appliedDiscounts.isNotEmpty) {
        total = cart.getTotalWithCheckoutDiscount(
          checkoutDiscount.totalDiscountAmount,
        );
      }
      if (checkoutRewards.selectedReward != null) {
        total = checkoutRewards.subtotalAfterDiscount;
      }
      final roundingAmount = roundUpToThousand(total) - total;
      finalTotal = total + roundingAmount;
    }

    // Creating a structure string using StringBuffer
    final buffer = StringBuffer();
    buffer.writeln('--- Bill Details ---');
    buffer.writeln('Bill No: ${selectedBill.cBillId}');
    buffer.writeln(
      'Date: ${selectedBill.createdAt.toString().split('.').first}',
    );
    if (isClosed) {
      buffer.writeln(
        'Cashier: ${selectedBill.cashier.isNotEmpty ? selectedBill.cashier : fallbackCashierName}',
      );
    }
    buffer.writeln('--------------------');

    for (var item in cart.items) {
      buffer.writeln(
        '${item.quantity}x ${item.name} \t ${item.totalPrice.toCurrency()}',
      );
      if (item.options?.isNotEmpty ?? false) {
        for (var option in item.options!) {
          buffer.writeln('  - ${option.name} (+${option.price.toCurrency()})');
        }
      }
      if (item.discount > 0) {
        buffer.writeln(
          '  Discount: -${(item.discount * item.quantity).toCurrency()}',
        );
      }
      if (item.productNotes?.isNotEmpty ?? false) {
        buffer.writeln('  Note: ${item.productNotes}');
      }
    }

    buffer.writeln('--------------------');
    buffer.writeln('Subtotal: \t ${cart.subtotal.toCurrency()}');
    if (cart.totalProductDiscount > 0) {
      buffer.writeln(
        'Product Discounts: \t -${cart.totalProductDiscount.toCurrency()}',
      );
    }
    if (checkoutDiscount.appliedDiscounts.isNotEmpty) {
      for (var discount in checkoutDiscount.appliedDiscounts) {
        buffer.writeln(
          'Discount (${discount.name}): \t -${discount.amount.toCurrency()}',
        );
      }
    }
    buffer.writeln(
      'Service (${cart.serviceFeePercentage.toStringAsFixed(0)}%): \t ${cart.serviceFee.toCurrency()}',
    );
    if (cart.gratuity > 0) {
      buffer.writeln(
        'Gratuity (${cart.gratuityPercentage.toStringAsFixed(0)}%): \t ${cart.gratuity.toCurrency()}',
      );
    }
    buffer.writeln(
      'Tax (${cart.taxPercentage.toStringAsFixed(0)}%): \t ${cart.taxTotal.toCurrency()}',
    );
    buffer.writeln('--------------------');
    buffer.writeln('TOTAL: \t ${finalTotal.toCurrency()}');
    buffer.write('\nThank you!');
    buffer.writeln('\nThis bill is generated by ReBill POS');

    // Calls the Share package to display the share dialog.
    await SharePlus.instance.share(
      ShareParams(
        text: buffer.toString(),
        subject: 'Bill Details - ${selectedBill.cBillId}',
      ),
    );
  }

  // Function to display confirmation dialog and delete bill
  Future<void> _handleDeleteBill(BuildContext context, WidgetRef ref) async {
    final selectedBill = ref.read(billProvider).selectedBill;
    if (selectedBill == null) return;

    final theme = Theme.of(context);
    final bool? isConfirmed = await AppDialog.showCustom(
      context,
      title: 'Delete Bill',
      dialogType: DialogType.small,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: theme.colorScheme.error,
            size: 80,
          ),
          const SizedBox(height: 16),
          Text(
            'Are you sure you want to permanently delete this bill (${selectedBill.cBillId})?',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'This action cannot be undone.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: AppButton(
                  onPressed: () => Navigator.pop(context, false),
                  text: 'Cancel',
                  backgroundColor: theme.colorScheme.surfaceContainer,
                  textStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppButton(
                  onPressed: () => Navigator.pop(context, true),
                  text: 'Delete',
                  backgroundColor: theme.colorScheme.error,
                  textStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onError,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (isConfirmed == true && context.mounted) {
      ref.read(billProvider.notifier).deleteBill(selectedBill.billId);
      _cancelBill(ref);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billType = ref.watch(billTypeProvider);
    final theme = Theme.of(context);
    final cart = ref.watch(cartProvider);
    final mainBillComponent = ref.watch(mainBillProvider);
    final billState = ref.watch(billProvider);
    final isClosed = billState.selectedBill?.states.toLowerCase() == 'closed';

    final customerTypes = [
      {
        'icon': Icons.person_rounded,
        'label': 'Guest',
        'onTap': () {
          ref
              .read(customerTypeProvider.notifier)
              .setCustomerType(CustomerType.guest);
          ref.read(knownIndividualProvider.notifier).setKnownIndividual(null);
        },
      },
      {
        'icon': Icons.person_pin_rounded,
        'label': 'Known Individual',
        'onTap': () {
          AppDialog.showCustom(
            context,
            content: KnownIndividualDialog(),
            title: 'Known Individual',
            dialogType: DialogType.large,
          );
        },
      },
    ];

    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.hardEdge,
            padding:
                mainBillComponent != MainBillComponent.defaultComponent
                    ? const EdgeInsets.only(top: 12)
                    : const EdgeInsets.only(
                      top: 12,
                      left: 12,
                      right: 12,
                      bottom: 12,
                    ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  width: double.infinity,
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${isClosed ? 'Closed' : 'Open'} Bill',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          if (!isClosed)
                            Tooltip(
                              message: 'QR',
                              child: GestureDetector(
                                onTap: () {},
                                child: Icon(
                                  Icons.qr_code_rounded,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          if (!isClosed) const SizedBox(width: 12),
                          Tooltip(
                            message: 'Share',
                            child: GestureDetector(
                              onTap: () => _shareBill(context, ref),
                              child: Icon(
                                Icons.share_outlined,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (isClosed)
                            Tooltip(
                              message: 'Delete Bill',
                              child: GestureDetector(
                                onTap: () => _handleDeleteBill(context, ref),
                                child: Icon(
                                  Icons.delete_forever_outlined,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          if (isClosed) const SizedBox(width: 12),
                          Tooltip(
                            message: 'Cancel',
                            child: GestureDetector(
                              onTap: () => _cancelBill(ref),
                              child: Icon(
                                Icons.cancel_rounded,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (!isClosed && billType != BillType.merchantBill)
                  CustomerExpandable(
                    customerTypes: customerTypes,
                    disabled: false,
                  ),
                cart.items.isEmpty ? EmptyCart() : Bill(),
              ],
            ),
          ),
        ),
        if (cart.items.isNotEmpty && !isClosed)
          SizedBox(
            height: 50,
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    onPressed: () {
                      AppDialog.showCustom(
                        context,
                        content: TableDialog(tableType: TableType.bill),
                        dialogType: DialogType.large,
                        title: 'Assign Table',
                      );
                    },
                    height: 50,
                    text: 'Assign Table',
                    backgroundColor: theme.colorScheme.primaryContainer,
                    textStyle: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: AppButton(
                    onPressed: () {},
                    height: 50,
                    text: 'Captain Order',
                    backgroundColor: theme.colorScheme.primaryContainer,
                    textStyle: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: AppButton(
                    onPressed: () {},
                    height: 50,
                    text: 'Split Bill',
                    backgroundColor: theme.colorScheme.primaryContainer,
                    textStyle: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 1),
        TotalPriceCard(),
      ],
    );
  }
}
