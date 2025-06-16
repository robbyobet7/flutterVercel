import 'package:flutter/material.dart';
import 'package:rebill_flutter/core/widgets/app_text_field.dart';
import 'package:rebill_flutter/core/widgets/label_text.dart';
import 'package:rebill_flutter/features/checkout/models/payment_method.dart';
import 'package:rebill_flutter/features/checkout/presetantions/widges/checkout_button.dart';
import 'package:rebill_flutter/features/checkout/presetantions/widges/checkout_dialog.dart';

class PaymentAmount extends StatefulWidget {
  const PaymentAmount({
    super.key,
    required this.paymentType,
    required this.paymentMethods,
  });

  final PaymentType paymentType;
  final List<PaymentMethod> paymentMethods;

  @override
  State<PaymentAmount> createState() => _PaymentAmountState();
}

class _PaymentAmountState extends State<PaymentAmount> {
  PaymentMethod? selectedPaymentMethod;
  PaymentMethod? selectedPaymentMethod2;

  late final TextEditingController _receivedAmountController;
  late final TextEditingController _receivedAmount2Controller;

  List<Widget>? _cachedPaymentButtons;
  List<Widget>? _cachedPaymentButtons2;

  @override
  void initState() {
    super.initState();
    _receivedAmountController = TextEditingController();
    _receivedAmount2Controller = TextEditingController();
  }

  @override
  void dispose() {
    _receivedAmountController.dispose();
    _receivedAmount2Controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PaymentAmount oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Clear cache if payment methods changed
    if (oldWidget.paymentMethods != widget.paymentMethods) {
      _cachedPaymentButtons = null;
      _cachedPaymentButtons2 = null;
    }
  }

  List<Widget> _buildPaymentMethodButtons({bool isSecondary = false}) {
    return widget.paymentMethods.map((e) {
      final isSelected =
          isSecondary
              ? selectedPaymentMethod2?.name == e.name
              : selectedPaymentMethod?.name == e.name;

      return CheckoutButton(
        text: e.name,
        icon: _getPaymentMethodIcon(e.method),
        isSelected: isSelected,
        onTap: () {
          setState(() {
            if (isSecondary) {
              selectedPaymentMethod2 = e;
              _cachedPaymentButtons2 =
                  null; // Clear cache to rebuild with new selection
            } else {
              selectedPaymentMethod = e;
              _cachedPaymentButtons =
                  null; // Clear cache to rebuild with new selection
            }
          });
        },
      );
    }).toList();
  }

  IconData _getPaymentMethodIcon(Method method) {
    switch (method) {
      case Method.cash:
        return Icons.money;
      case Method.bank:
        return Icons.account_balance;
      case Method.other:
        return Icons.payment;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cache payment buttons if not already cached or if selection changed
    _cachedPaymentButtons ??= _buildPaymentMethodButtons();
    if (widget.paymentType == PaymentType.split) {
      _cachedPaymentButtons2 ??= _buildPaymentMethodButtons(isSecondary: true);
    }

    return Column(
      spacing: 16,
      children: [
        AppTextField(
          controller: _receivedAmountController,
          labelText: 'Received Amount/Down Payment',
        ),
        _PaymentMethodSection(
          title: 'Payment Method',
          buttons: _cachedPaymentButtons!,
        ),
        if (widget.paymentType == PaymentType.split) ...[
          AppTextField(
            controller: _receivedAmount2Controller,
            labelText: 'Received Amount 2',
          ),
          _PaymentMethodSection(
            title: 'Payment Method 2',
            buttons: _cachedPaymentButtons2!,
          ),
        ],
      ],
    );
  }
}

class _PaymentMethodSection extends StatelessWidget {
  const _PaymentMethodSection({required this.title, required this.buttons});

  final String title;
  final List<Widget> buttons;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LabelText(text: title),
        SizedBox(
          width: double.infinity,
          child: Row(spacing: 8, children: buttons),
        ),
      ],
    );
  }
}
