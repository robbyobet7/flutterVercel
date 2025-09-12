import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/formatters/currency_input_formatter.dart';
import 'package:rebill_flutter/core/providers/payment_method_provider.dart';
import 'package:rebill_flutter/core/widgets/app_text_field.dart';
import 'package:rebill_flutter/core/widgets/label_text.dart';
import 'package:rebill_flutter/features/checkout/models/payment_method.dart';
import 'package:rebill_flutter/features/checkout/presetantions/widges/checkout_button.dart';
import 'checkout_dialog.dart';

class PaymentAmount extends ConsumerStatefulWidget {
  const PaymentAmount({
    super.key,
    required this.paymentType,
    required this.receivedAmountController,
    required this.receivedAmount2Controller,
  });

  final PaymentType paymentType;
  final TextEditingController receivedAmountController;
  final TextEditingController receivedAmount2Controller;

  @override
  ConsumerState<PaymentAmount> createState() => _PaymentAmountState();
}

class _PaymentAmountState extends ConsumerState<PaymentAmount> {
  PaymentMethod? selectedPaymentMethod;
  PaymentMethod? selectedPaymentMethod2;

  // Payment Method
  List<Widget> _buildPaymentMethodButtons(
    List<PaymentMethod> methods, {
    bool isSecondary = false,
  }) {
    return methods.map((e) {
      final isSelected =
          isSecondary
              ? selectedPaymentMethod2?.id == e.id
              : selectedPaymentMethod?.id == e.id;

      return CheckoutButton(
        text: e.paymentName,
        icon: _getPaymentMethodIcon(e.methodType),
        isSelected: isSelected,
        onTap: () {
          setState(() {
            if (isSecondary) {
              selectedPaymentMethod2 = e;
            } else {
              selectedPaymentMethod = e;
            }
          });
        },
      );
    }).toList();
  }

  IconData _getPaymentMethodIcon(PaymentMethodType method) {
    switch (method) {
      case PaymentMethodType.cash:
        return Icons.money;
      case PaymentMethodType.transfer:
        return Icons.account_balance;
      case PaymentMethodType.other:
        return Icons.payment;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final paymentState = ref.watch(paymentMethodProvider);
    final theme = Theme.of(context);

    return Column(
      children: [
        AppTextField(
          controller: widget.receivedAmountController,
          labelText: 'Received Amount / Down Payment',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            CurrencyInputFormatter(locale: locale),
          ],
        ),
        const SizedBox(height: 16),
        paymentState.isLoading
            ? const CircularProgressIndicator()
            : paymentState.errorMessage != null
            ? Text(
              paymentState.errorMessage!,
              style: TextStyle(color: theme.colorScheme.error),
            )
            : _PaymentMethodSection(
              title: 'Payment Method',
              buttons: _buildPaymentMethodButtons(paymentState.paymentMethods),
            ),
        if (widget.paymentType == PaymentType.split) ...[
          const SizedBox(height: 16),
          AppTextField(
            controller: widget.receivedAmount2Controller,
            labelText: 'Received Amount 2',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CurrencyInputFormatter(locale: locale),
            ],
          ),
          const SizedBox(height: 16),
          paymentState.isLoading
              ? const SizedBox.shrink()
              : paymentState.errorMessage != null
              ? const SizedBox.shrink()
              : _PaymentMethodSection(
                title: 'Payment Method 2',
                buttons: _buildPaymentMethodButtons(
                  paymentState.paymentMethods,
                  isSecondary: true,
                ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        const int columns = 3;
        const double spacing = 8;
        final double totalSpacing = spacing * (columns - 1);
        final double itemWidth =
            (constraints.maxWidth - totalSpacing) / columns;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
}
