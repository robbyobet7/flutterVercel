import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/widgets/app_dialog.dart';
import 'package:rebill_flutter/core/widgets/app_divider.dart';
import 'package:rebill_flutter/core/widgets/label_text.dart';
import 'package:rebill_flutter/features/checkout/models/checkout_discount.dart';
import 'package:rebill_flutter/features/checkout/presetantions/widges/available_discounts_dialog.dart';
import 'package:rebill_flutter/features/checkout/presetantions/widges/checkout_action_row.dart';
import 'package:rebill_flutter/features/checkout/presetantions/widges/checkout_button.dart';
import 'package:rebill_flutter/features/checkout/presetantions/widges/payment_amount.dart';

enum PaymentType { full, split }

class CheckoutDialog extends ConsumerStatefulWidget {
  const CheckoutDialog({super.key});

  @override
  ConsumerState<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends ConsumerState<CheckoutDialog> {
  String? selectedDelivery;
  String? selectedDiscount;
  PaymentType? selectedPayment;

  // Static data - created once
  static const List<String> _delivery = ['Direct', 'Takeaway'];
  static const List<PaymentType> _payment = [
    PaymentType.full,
    PaymentType.split,
  ];

  late final List<CheckoutDiscount> _discounts;

  // Cached widget lists
  List<Widget>? _cachedDeliveryButtons;
  List<Widget>? _cachedDiscountButtons;
  List<Widget>? _cachedPaymentButtons;

  @override
  void initState() {
    super.initState();

    // Initialize data once
    _discounts = [
      CheckoutDiscount(
        name: 'Show Available Discount',
        onTap: () {
          Navigator.pop(context);
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              AppDialog.showCustom(
                context,
                content: const AvailableDiscountsDialog(),
                dialogType: DialogType.large,
                title: 'Available Discounts',
              );
            }
          });
        },
      ),
      CheckoutDiscount(
        name: 'Reward',
        onTap: () {
          Navigator.pop(context);
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              AppDialog.showCustom(
                context,
                content: const AvailableDiscountsDialog(),
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
          Navigator.pop(context);
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

  List<Widget> _buildDiscountButtons() {
    return _discounts
        .map(
          (e) => CheckoutButton(
            text: e.name,
            isSelected: selectedDiscount == e.name,
            onTap: () {
              setState(() {
                selectedDiscount = e.name;
                _cachedDiscountButtons =
                    null; // Clear cache to rebuild with new selection
              });
              e.onTap();
            },
          ),
        )
        .toList();
  }

  List<Widget> _buildPaymentButtons() {
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
              });
            },
          ),
        )
        .toList();
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
    _cachedDeliveryButtons ??= _buildDeliveryButtons();
    _cachedDiscountButtons ??= _buildDiscountButtons();
    _cachedPaymentButtons ??= _buildPaymentButtons();

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
                  _buildSection(
                    title: 'Delivery',
                    buttons: _cachedDeliveryButtons!,
                    columns: 2,
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'Discounts',
                    buttons: _cachedDiscountButtons!,
                    columns: 3,
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'Payment',
                    buttons: _cachedPaymentButtons!,
                    columns: 2,
                  ),
                  const SizedBox(height: 16),
                  PaymentAmount(
                    paymentType: selectedPayment ?? PaymentType.full,
                  ),
                ],
              ),
            ),
          ),
          const CheckoutActionRow(),
        ],
      ),
    );
  }
}
