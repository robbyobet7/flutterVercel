import 'package:flutter/material.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_divider.dart';

class CheckoutActionRow extends StatelessWidget {
  const CheckoutActionRow({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      spacing: 16,
      children: [
        AppDivider(),
        SizedBox(
          height: 40,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppButton(onPressed: () {}, text: 'Copy Link'),
              Row(
                spacing: 8,
                children: [
                  AppButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    text: 'Cancel',
                    backgroundColor: theme.colorScheme.errorContainer,
                    textStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  AppButton(
                    onPressed: () {},
                    text: 'Print Bill',
                    backgroundColor: theme.colorScheme.primaryContainer,
                    textStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  AppButton(
                    onPressed: () {},
                    text: 'Checkout',
                    backgroundColor: theme.colorScheme.primary,
                    textStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
