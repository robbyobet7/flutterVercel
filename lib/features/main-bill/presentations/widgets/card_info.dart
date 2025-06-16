import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:rebill_flutter/core/widgets/app_divider.dart';
import 'package:rebill_flutter/core/widgets/app_material.dart';
import 'package:rebill_flutter/core/widgets/app_text_field.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/features/reservation/presentations/widgets/add_reservation_dialog.dart';

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
                                  (e) => IssuerContainer(
                                    issuer: e,
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

class IssuerContainer extends StatelessWidget {
  const IssuerContainer({
    super.key,
    required this.issuer,
    this.isSelected = false,
    this.onTap,
  });

  final String issuer;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: AppMaterial(
        onTap: onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          height: 45,
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.primary, width: 1),
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? theme.colorScheme.primaryContainer : null,
          ),
          child: Center(
            child: Text(
              issuer,
              style: theme.textTheme.bodyMedium?.copyWith(
                color:
                    isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
