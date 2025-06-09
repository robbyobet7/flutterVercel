import 'package:flutter/material.dart';
import 'package:rebill_flutter/core/widgets/app_dialog.dart';
import 'package:rebill_flutter/core/widgets/app_divider.dart';
import 'package:rebill_flutter/features/checkout/models/checkout_discount.dart';
import 'package:rebill_flutter/features/checkout/models/payment_method.dart';
import 'package:rebill_flutter/features/checkout/presetantions/widges/available_discounts_dialog.dart';
import 'package:rebill_flutter/features/checkout/presetantions/widges/checkout_action_row.dart';
import 'package:rebill_flutter/features/checkout/presetantions/widges/checkout_button.dart';
import 'package:rebill_flutter/features/checkout/presetantions/widges/payment_amount.dart';
import 'package:rebill_flutter/features/reservation/presentations/widgets/add_reservation_dialog.dart';

enum Method { cash, bank, other }

enum PaymentType { full, split }

class CheckoutDialog extends StatefulWidget {
  const CheckoutDialog({super.key});

  @override
  State<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<CheckoutDialog> {
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
  late final List<PaymentMethod> _paymentMethods;

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

    _paymentMethods = [
      PaymentMethod(name: 'Cash', method: Method.cash),
      PaymentMethod(name: 'BCA', method: Method.bank),
      PaymentMethod(name: 'Mandiri', method: Method.bank),
      PaymentMethod(name: 'Midtrans', method: Method.other),
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

  Widget _buildSection({required String title, required List<Widget> buttons}) {
    return Column(
      children: [
        LabelText(text: title),
        Container(
          width: double.infinity,
          height: 45,
          child: Row(spacing: 8, children: buttons),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Cache buttons if not already cached or if selection changed
    _cachedDeliveryButtons ??= _buildDeliveryButtons();
    _cachedDiscountButtons ??= _buildDiscountButtons();
    _cachedPaymentButtons ??= _buildPaymentButtons();

    return Expanded(
      child: Column(
        spacing: 16,
        children: [
          const AppDivider(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              child: Column(
                spacing: 16,
                children: [
                  _buildSection(
                    title: 'Delivery',
                    buttons: _cachedDeliveryButtons!,
                  ),
                  _buildSection(
                    title: 'Discounts',
                    buttons: _cachedDiscountButtons!,
                  ),
                  _buildSection(
                    title: 'Payment',
                    buttons: _cachedPaymentButtons!,
                  ),
                  PaymentAmount(
                    paymentType: selectedPayment ?? PaymentType.full,
                    paymentMethods: _paymentMethods,
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
