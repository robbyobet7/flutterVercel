import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rebill_flutter/core/providers/discounts_provider.dart';
import 'package:rebill_flutter/core/providers/payment_amount_provider.dart';
import 'package:rebill_flutter/core/providers/checkout_discount_provider.dart';
import 'package:rebill_flutter/core/widgets/app_dialog.dart';
import 'package:rebill_flutter/core/widgets/app_divider.dart';
import 'package:rebill_flutter/core/widgets/label_text.dart';
import 'package:rebill_flutter/features/checkout/models/checkout_discount.dart';
import 'package:rebill_flutter/features/checkout/presetantions/available_rewards_dialog.dart';
import 'package:rebill_flutter/features/checkout/presetantions/widges/available_discounts_dialog.dart';
import 'package:rebill_flutter/features/checkout/presetantions/widges/checkout_action_row.dart';
import 'package:rebill_flutter/features/checkout/presetantions/widges/checkout_button.dart';
import 'package:rebill_flutter/features/checkout/presetantions/widges/payment_amount.dart';
import 'package:rebill_flutter/core/providers/cart_provider.dart';
import 'package:rebill_flutter/core/providers/bill_provider.dart';
import 'package:rebill_flutter/core/models/bill.dart';
import 'package:rebill_flutter/features/main-bill/providers/main_bill_provider.dart';

enum PaymentType { full, split }

class CheckoutDialog extends ConsumerStatefulWidget {
  const CheckoutDialog({super.key});

  @override
  ConsumerState<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends ConsumerState<CheckoutDialog> {
  String? selectedDelivery;
  PaymentType? selectedPayment;
  String? tableNumber;
  String? customerName;
  double roundUpToThousand(double value) => ((value / 1000).ceil()) * 1000;

  // Static data - created once
  static const List<String> _delivery = ['Direct', 'Takeaway'];
  static const List<PaymentType> _payment = [
    PaymentType.full,
    PaymentType.split,
  ];

  late final List<CheckoutDiscount> _discounts;
  late final TextEditingController _receivedAmountController;
  late final TextEditingController _receivedAmount2Controller;

  // Cached widget lists
  List<Widget>? _cachedDeliveryButtons;
  List<Widget>? _cachedPaymentButtons;

  @override
  void dispose() {
    _receivedAmountController.dispose();
    _receivedAmount2Controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _receivedAmountController = TextEditingController();
    _receivedAmount2Controller = TextEditingController();

    // Initialize data once
    _discounts = [
      CheckoutDiscount(
        name: 'Show Available Discount',
        onTap: () {
          AppDialog.showCustom(
            context,
            content: const AvailableDiscountsDialog(),
            dialogType: DialogType.large,
            title: 'Available Discounts',
          ).then((_) {
            // Update checkout discount when dialog is closed
            _updateCheckoutDiscount();
          });
        },
      ),
      CheckoutDiscount(
        name: 'Reward',
        onTap: () {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              AppDialog.showCustom(
                context,
                content: AvailableRewardsDialog(),
                dialogType: DialogType.large,
                title: 'Reward',
              );
            }
          });
        },
      ),
      CheckoutDiscount(
        name: 'Custom Reward',
        onTap: () {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              AppDialog.showCustom(
                context,
                content: const AvailableDiscountsDialog(),
                dialogType: DialogType.large,
                title: 'Custom Reward',
              );
            }
          });
        },
      ),
    ];
  }

  List<Widget> _buildDeliveryButtons() {
    return _delivery
        .map(
          (e) => CheckoutButton(
            text: e,
            isSelected: selectedDelivery == e,
            onTap: () {
              setState(() {
                selectedDelivery = e;
                _cachedDeliveryButtons =
                    null; // Clear cache to rebuild with new selection
              });
            },
          ),
        )
        .toList();
  }

  List<Widget> _buildDiscountButtons(List<DiscountModel> appliedDiscounts) {
    final isDiscountApplied = appliedDiscounts.isNotEmpty;

    return _discounts
        .map(
          (e) => CheckoutButton(
            text: e.name,
            isSelected:
                e.name == 'Show Available Discount' ? isDiscountApplied : false,
            onTap: e.onTap,
          ),
        )
        .toList();
  }

  List<Widget> _buildPaymentButtons() {
    final numberFormat = NumberFormat.currency(
      locale: 'id',
      symbol: '',
      decimalDigits: 0,
    );
    return _payment
        .map(
          (e) => CheckoutButton(
            text: e == PaymentType.full ? 'Full Payment' : 'Split Payment',
            isSelected: selectedPayment == e,
            onTap: () {
              setState(() {
                selectedPayment = e;
                _cachedPaymentButtons =
                    null; // Clear cache to rebuild with new selection

                // Auto-fill received amount when Full Payment is selected
                if (e == PaymentType.full) {
                  final cart = ref.read(cartProvider);
                  final checkoutDiscount = ref.read(checkoutDiscountProvider);
                  final total =
                      checkoutDiscount.appliedDiscounts.isNotEmpty
                          ? cart.getTotalWithCheckoutDiscount(
                            checkoutDiscount.totalDiscountAmount,
                          )
                          : cart.total;
                  final roundedTotal = roundUpToThousand(total);
                  _receivedAmountController.text = numberFormat.format(
                    roundedTotal,
                  );
                  ref
                      .read(paymentAmountProvider.notifier)
                      .setReceivedAmount(roundedTotal.toDouble());
                  _receivedAmount2Controller.clear();
                } else if (e == PaymentType.split) {
                  final cart = ref.read(cartProvider);
                  final checkoutDiscount = ref.read(checkoutDiscountProvider);
                  final total =
                      checkoutDiscount.appliedDiscounts.isNotEmpty
                          ? cart.getTotalWithCheckoutDiscount(
                            checkoutDiscount.totalDiscountAmount,
                          )
                          : cart.total;
                  final roundedTotal = roundUpToThousand(total);
                  final splitAmount = roundedTotal / 2;

                  _receivedAmountController.text = numberFormat.format(
                    splitAmount,
                  );
                  _receivedAmount2Controller.text = numberFormat.format(
                    splitAmount,
                  );

                  ref
                      .read(paymentAmountProvider.notifier)
                      .setReceivedAmount(splitAmount);
                  ref
                      .read(paymentAmountProvider.notifier)
                      .setReceivedAmount2(splitAmount);
                }
              });
            },
          ),
        )
        .toList();
  }

  // Build discount info widget
  Widget _buildDiscountInfo(CheckoutDiscountState checkoutDiscount) {
    final theme = Theme.of(context);
    final numberFormat = NumberFormat.currency(
      locale: 'id',
      symbol: '',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Applied Discounts',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          ...checkoutDiscount.appliedDiscounts.map(
            (discount) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(discount.name, style: theme.textTheme.bodyMedium),
                  Text(
                    discount.type == 'percentage'
                        ? '${discount.amount.toInt()}%'
                        : numberFormat.format(discount.amount),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Discount',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '-${numberFormat.format(checkoutDiscount.totalDiscountAmount)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Update checkout discount
  void _updateCheckoutDiscount() {
    final selectedDiscounts = ref.read(selectedDiscountsProvider);
    final cart = ref.read(cartProvider);
    final subtotal = cart.subtotal;

    ref
        .read(checkoutDiscountProvider.notifier)
        .applyDiscounts(selectedDiscounts, subtotal);
  }

  // Validation method
  bool _validateCheckout() {
    // Check if delivery is selected
    if (selectedDelivery == null) {
      _showValidationErrorDialog('Please chose an option for delivery.');
      return false;
    }

    // Check if payment type is selected
    if (selectedPayment == null) {
      _showValidationErrorDialog('Please chose an option for payment.');
      return false;
    }

    // Check if payment method is selected
    final paymentAmount = ref.read(paymentAmountProvider);
    if (paymentAmount.selectedPaymentMethod == null) {
      _showValidationErrorDialog('Please chose an option for payment method.');
      return false;
    }

    // Check if received amount is filled
    if (_receivedAmountController.text.trim().isEmpty) {
      _showValidationErrorDialog('Please enter the amount received.');
      return false;
    }

    return true;
  }

  // DUMMY CHECKOUT
  void _handleCheckout() async {
    // Validate required fields
    if (!_validateCheckout()) {
      return;
    }

    final navigator = Navigator.of(context);
    // Loading dialog
    showDialog(
      context: navigator.context,
      barrierDismissible: false,
      builder:
          (ctx) => const Dialog(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text("Processing Payment..."),
                ],
              ),
            ),
          ),
    );

    // Simulation payment process
    await Future.delayed(const Duration(seconds: 2));

    final selectedCustomer = ref.read(knownIndividualProvider);
    final String finalCustomerName =
        selectedCustomer?.customerName ?? customerName ?? 'Guest';
    final int? finalCustomerId = selectedCustomer?.customerId;

    final cartNotifier = ref.read(cartProvider.notifier);
    final checkoutDiscount = ref.read(checkoutDiscountProvider);
    var bill = cartNotifier.createBill(
      customerName: customerName ?? finalCustomerName,
      delivery: selectedDelivery ?? 'Direct',
    );

    // Apply checkout discount to bill
    if (checkoutDiscount.appliedDiscounts.isNotEmpty) {
      final cart = ref.read(cartProvider);
      final discountedTotal = cart.getTotalWithCheckoutDiscount(
        checkoutDiscount.totalDiscountAmount,
      );
      final roundedTotal = roundUpToThousand(discountedTotal);

      bill = bill.copyWith(
        total: cart.total, // Original total before discount
        finalTotal: roundedTotal.toDouble(),
        totalafterrounding: roundedTotal.toDouble(),
        totalDiscount: checkoutDiscount.totalDiscountAmount.toInt(),
        totalafterdiscount: checkoutDiscount.subtotalAfterDiscount,
        discountList: jsonEncode(
          checkoutDiscount.appliedDiscounts.map((d) => d.toJson()).toList(),
        ),
      );
    } else {
      final cart = ref.read(cartProvider);
      final roundedTotal = roundUpToThousand(cart.total);

      bill = bill.copyWith(
        total: cart.total,
        finalTotal: roundedTotal.toDouble(),
        totalafterrounding: roundedTotal.toDouble(),
      );
    }

    final roundedTotal = roundUpToThousand(bill.finalTotal);
    bill = BillModel(
      customerId: finalCustomerId,
      billId: bill.billId,
      customerName: bill.customerName,
      orderCollection: bill.orderCollection,
      total: bill.total,
      finalTotal: roundedTotal.toDouble(),
      totalafterrounding: roundedTotal.toDouble(),
      downPayment: bill.downPayment,
      usersId: bill.usersId,
      states: 'closed',
      paymentMethod: bill.paymentMethod,
      splitPayment: bill.splitPayment,
      delivery: bill.delivery,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      deletedAt: bill.deletedAt,
      outletId: bill.outletId,
      servicefee: bill.servicefee,
      gratuity: bill.gratuity,
      vat: bill.vat,
      billDiscount: bill.billDiscount,
      tableId: tableNumber,
      totalDiscount: bill.totalDiscount,
      hashBill: bill.hashBill,
      rewardPoints: bill.rewardPoints,
      totalReward: bill.totalReward,
      rewardBill: bill.rewardBill,
      cBillId: bill.cBillId,
      rounding: bill.rounding,
      isQR: bill.isQR,
      notes: bill.notes,
      amountPaid: bill.amountPaid,
      ccNumber: bill.ccNumber,
      ccType: bill.ccType,
      productDiscount: bill.productDiscount,
      merchantOrderId: bill.merchantOrderId,
      discountList: bill.discountList,
      key: bill.key,
      affiliate: bill.affiliate,
      customerPhone: bill.customerPhone,
      totaldiscount: bill.totaldiscount,
      totalafterdiscount: bill.totalafterdiscount,
      cashier: bill.cashier,
      lastcashier: bill.lastcashier,
      firstcashier: bill.firstcashier,
      totalgratuity: bill.totalgratuity,
      totalservicefee: bill.totalservicefee,
      totalbeforetax: bill.totalbeforetax,
      totalvat: bill.totalvat,
      totalaftertax: bill.totalaftertax,
      roundingSetting: bill.roundingSetting,
      div: bill.div,
      billDate: bill.billDate,
      posBillDate: bill.posBillDate,
      posPaidBillDate: DateTime.now().toIso8601String(),
      rewardoption: bill.rewardoption,
      return_: bill.return_,
      proof: bill.proof,
      proofStaffId: bill.proofStaffId,
      tableName: bill.tableName,
      fromProcessBill: bill.fromProcessBill,
      refund: bill.refund,
      items: bill.items,
    );

    // Add to BillProvider with safe method
    ref.read(billProvider.notifier).addBill(bill);

    // Reset Bill
    resetMainBill(ref);

    // Clear checkout discount
    ref.read(checkoutDiscountProvider.notifier).clearDiscounts();

    //Clear checkout payment
    ref.read(paymentAmountProvider.notifier).reset();

    // Close loading dialog
    navigator.pop();

    // Close checkout dialog
    navigator.pop();

    // Succes Checkout
    showDialog(
      context: navigator.context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Checkout Success'),
            content: const Text('Order successfully checked out and saved.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showValidationErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Chose an option'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> buttons,
    int columns = 2,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double spacing = 8;
        final double totalSpacing = spacing * (columns - 1);
        final double itemWidth =
            (constraints.maxWidth - totalSpacing) / columns;

        return Column(
          children: [
            LabelText(text: title),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children:
                    buttons
                        .map((w) => SizedBox(width: itemWidth, child: w))
                        .toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Cache buttons if not already cached or if selection changed
    final appliedDiscounts = ref.watch(selectedDiscountsProvider);
    final checkoutDiscount = ref.watch(checkoutDiscountProvider);
    _cachedDeliveryButtons ??= _buildDeliveryButtons();
    _cachedPaymentButtons ??= _buildPaymentButtons();
    final discountButtons = _buildDiscountButtons(appliedDiscounts);

    // Intentionally left for future keyboard-aware adjustments if needed.
    return Expanded(
      child: Column(
        children: [
          const AppDivider(),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'Delivery',
                    buttons: _cachedDeliveryButtons!,
                    columns: 2,
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'Discounts',
                    buttons: discountButtons,
                    columns: 3,
                  ),
                  // Show applied discount information
                  if (checkoutDiscount.appliedDiscounts.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildDiscountInfo(checkoutDiscount),
                  ],
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'Payment',
                    buttons: _cachedPaymentButtons!,
                    columns: 2,
                  ),
                  const SizedBox(height: 16),
                  PaymentAmount(
                    paymentType: selectedPayment ?? PaymentType.full,
                    receivedAmountController: _receivedAmountController,
                    receivedAmount2Controller: _receivedAmount2Controller,
                  ),
                ],
              ),
            ),
          ),
          CheckoutActionRow(onCheckout: _handleCheckout),
        ],
      ),
    );
  }
}
