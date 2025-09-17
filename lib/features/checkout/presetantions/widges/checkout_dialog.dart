import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rebill_flutter/core/providers/discounts_provider.dart';
import 'package:rebill_flutter/core/providers/payment_amount_provider.dart';
import 'package:rebill_flutter/core/providers/checkout_discount_provider.dart';
import 'package:rebill_flutter/core/providers/checkout_rewards_provider.dart';
import 'package:rebill_flutter/core/providers/rewards_provider.dart';
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
import 'package:rebill_flutter/features/login/providers/staff_auth_provider.dart';

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

    // Clear any existing reward state when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(checkoutRewardsProvider.notifier).clearReward();
      ref.read(selectedRewardProvider.notifier).state = null;
    });

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
    final checkoutRewards = ref.watch(checkoutRewardsProvider);
    final isRewardApplied = checkoutRewards.selectedReward != null;

    return _discounts
        .map(
          (e) => CheckoutButton(
            text: e.name,
            isSelected:
                e.name == 'Show Available Discount'
                    ? isDiscountApplied
                    : e.name == 'Reward'
                    ? isRewardApplied
                    : false,
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
                  final checkoutRewards = ref.read(checkoutRewardsProvider);

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
                  final checkoutRewards = ref.read(checkoutRewardsProvider);

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
        color: theme.colorScheme.primaryContainer.withAlpha(77),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.primary.withAlpha(128)),
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
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  // Remove discount
                  ref.read(checkoutDiscountProvider.notifier).clearDiscounts();
                  ref.read(selectedDiscountsProvider.notifier).state = [];
                  // Re-apply reward if still active
                  final checkoutRewards = ref.read(checkoutRewardsProvider);
                  final selectedReward = checkoutRewards.selectedReward;
                  final cart = ref.read(cartProvider);

                  double total = cart.total;
                  if (selectedReward != null) {
                    // If reward is still active, apply reward to new total
                    ref
                        .read(checkoutRewardsProvider.notifier)
                        .applyReward(selectedReward, cart.total);
                    total =
                        ref.read(checkoutRewardsProvider).subtotalAfterDiscount;
                  }

                  // Update received amount (and receivedAmount2 if split)
                  final numberFormat = NumberFormat.currency(
                    locale: 'id',
                    symbol: '',
                    decimalDigits: 0,
                  );
                  final roundedTotal = roundUpToThousand(total);
                  _receivedAmountController.text = numberFormat.format(
                    roundedTotal,
                  );
                  ref
                      .read(paymentAmountProvider.notifier)
                      .setReceivedAmount(roundedTotal.toDouble());
                  _receivedAmount2Controller.clear();
                },
                icon: Icon(
                  Icons.close,
                  size: 16,
                  color: theme.colorScheme.error,
                ),
                label: Text(
                  'Remove Discount',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build reward info widget
  Widget _buildRewardInfo(CheckoutRewardsState checkoutRewards) {
    final theme = Theme.of(context);
    final numberFormat = NumberFormat.currency(
      locale: 'id',
      symbol: '',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withAlpha(77),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.secondary..withAlpha(128)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Applied Reward',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                checkoutRewards.selectedReward!.rewardType == 'percent'
                    ? 'Discount ${checkoutRewards.selectedReward!.amount}%'
                    : 'Discount ${checkoutRewards.selectedReward!.amount.toCurrency()}',
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                '-${numberFormat.format(checkoutRewards.discountAmount)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Points Used: ${checkoutRewards.selectedReward!.points}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface..withAlpha(179),
                ),
              ),
              Text(
                'Final Amount: ${numberFormat.format(roundUpToThousand(checkoutRewards.subtotalAfterDiscount))}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  // Remove reward
                  ref.read(checkoutRewardsProvider.notifier).clearReward();
                  ref.read(selectedRewardProvider.notifier).state = null;
                },
                icon: Icon(
                  Icons.close,
                  size: 16,
                  color: theme.colorScheme.error,
                ),
                label: Text(
                  'Remove Reward',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
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

    // --- Additional: update received amount ---
    final checkoutDiscount = ref.read(checkoutDiscountProvider);
    final checkoutRewards = ref.read(checkoutRewardsProvider);

    double total = cart.total;
    if (checkoutDiscount.appliedDiscounts.isNotEmpty) {
      total = cart.getTotalWithCheckoutDiscount(
        checkoutDiscount.totalDiscountAmount,
      );
    }
    if (checkoutRewards.selectedReward != null) {
      total = checkoutRewards.subtotalAfterDiscount;
    }
    final numberFormat = NumberFormat.currency(
      locale: 'id',
      symbol: '',
      decimalDigits: 0,
    );
    final roundedTotal = roundUpToThousand(total);
    _receivedAmountController.text = numberFormat.format(roundedTotal);
    ref
        .read(paymentAmountProvider.notifier)
        .setReceivedAmount(roundedTotal.toDouble());
    _receivedAmount2Controller.clear();
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
    final checkoutRewards = ref.read(checkoutRewardsProvider);

    // Resolve logged-in staff for cashier info
    final staffState = ref.read(staffAuthProvider);
    final cashierName = staffState.loggedInStaff?.name ?? 'Cashier';
    final cashierId = staffState.loggedInStaff?.id ?? 1;

    var bill = cartNotifier.createBill(
      customerName: customerName ?? finalCustomerName,
      delivery: selectedDelivery ?? 'Direct',
      cashierId: cashierId,
      cashierName: cashierName,
    );

    final cart = ref.read(cartProvider);
    double finalTotal = cart.total;
    double totalDiscountAmount = 0.0;
    String discountListJson = '[]';
    String rewardListJson = '[]';

    // Apply checkout discount first
    if (checkoutDiscount.appliedDiscounts.isNotEmpty) {
      finalTotal = cart.getTotalWithCheckoutDiscount(
        checkoutDiscount.totalDiscountAmount,
      );
      totalDiscountAmount += checkoutDiscount.totalDiscountAmount;
      discountListJson = jsonEncode(
        checkoutDiscount.appliedDiscounts.map((d) => d.toJson()).toList(),
      );
    }

    // Apply reward discount
    if (checkoutRewards.selectedReward != null) {
      finalTotal = checkoutRewards.subtotalAfterDiscount;
      totalDiscountAmount += checkoutRewards.discountAmount;
      rewardListJson = jsonEncode({
        'reward_id': checkoutRewards.selectedReward!.id,
        'reward_type': checkoutRewards.selectedReward!.rewardType,
        'discount_amount': checkoutRewards.discountAmount,
        'points_used': checkoutRewards.selectedReward!.points,
      });
    }

    final roundedTotal = roundUpToThousand(finalTotal);

    bill = bill.copyWith(
      total: cart.total, // Original total before any discount
      finalTotal: roundedTotal.toDouble(),
      totalafterrounding: roundedTotal.toDouble(),
      totalDiscount: totalDiscountAmount.toInt(),
      totalafterdiscount: finalTotal,
      discountList: discountListJson,
      rewardBill: rewardListJson,
      rewardPoints: checkoutRewards.selectedReward?.points.toString() ?? '0',
      totalReward: checkoutRewards.discountAmount.toInt(),
    );

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

    // Clear checkout rewards
    ref.read(checkoutRewardsProvider.notifier).clearReward();

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
    final checkoutRewards = ref.watch(checkoutRewardsProvider);
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
                  // Show applied reward information
                  if (checkoutRewards.selectedReward != null) ...[
                    const SizedBox(height: 16),
                    _buildRewardInfo(checkoutRewards),
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
