import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:rebill_flutter/core/widgets/app_divider.dart';
import 'package:rebill_flutter/core/widgets/app_text_field.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/label_text.dart';
import 'package:rebill_flutter/core/widgets/outline_app_button.dart';

class CardInfo extends StatefulWidget {
  const CardInfo({super.key});

  @override
  State<CardInfo> createState() => _CardInfoState();
}

class _CardInfoState extends State<CardInfo> {
  String? selectedIssuer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<String> issuer = ['Visa', 'Mastercard', 'American Express', 'Other'];
    return Expanded(
      child: Column(
        spacing: 16,
        children: [
          AppDivider(),
          Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              child: Column(
                spacing: 16,
                children: [
                  Column(
                    children: [
                      LabelText(text: 'Issuer'),
                      Row(
                        spacing: 8,
                        children:
                            issuer
                                .map(
                                  (e) => OutlineAppButton(
                                    text: e,
                                    isSelected: selectedIssuer == e,
                                    onTap: () {
                                      setState(() {
                                        selectedIssuer = e;
                                      });
                                    },
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  ),
                  if (selectedIssuer == 'Other')
                    AppTextField(
                      controller: TextEditingController(),
                      showLabel: false,
                      hintText: 'Input Card Issuer',
                    ),
                  Column(
                    children: [
                      LabelText(text: 'Last 4 Digits'),
                      Pinput(
                        length: 4,
                        mainAxisAlignment: MainAxisAlignment.start,
                        defaultPinTheme: PinTheme(
                          height: 45,
                          width: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: theme.colorScheme.surfaceContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AppDivider(),
          SizedBox(
            height: 45,
            child: Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppButton(
                  text: 'Cancel',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  backgroundColor: theme.colorScheme.errorContainer,
                  borderSide: BorderSide(color: theme.colorScheme.error),
                  textStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                AppButton(
                  text: 'Save',
                  onPressed: () {},
                  backgroundColor: theme.colorScheme.primary,
                  textStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
