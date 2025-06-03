import 'package:flutter/material.dart';
import 'package:rebill_flutter/core/widgets/app_checkbox.dart';
import 'package:rebill_flutter/core/widgets/app_divider.dart';
import 'package:rebill_flutter/features/printer-settings/presentations/widgets/printer_popup_menu.dart';

class NonEpsonSetting extends StatelessWidget {
  const NonEpsonSetting({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        AppDivider(),
        Text(
          'Non-Epson Settings',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        Row(
          spacing: 12,
          children: [
            Expanded(
              child: PrinterPopupMenu(
                label: 'Paper Size',
                items: [],
                hintText: 'Select paper size',
              ),
            ),
            Expanded(
              child: PrinterPopupMenu(
                label: 'Resolution',
                items: [],
                hintText: 'Select resolution',
              ),
            ),
          ],
        ),
        Row(
          spacing: 8,
          children: [
            AppCheckbox(size: 20),
            Text(
              'Disable Logo',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        Row(
          spacing: 8,
          children: [
            AppCheckbox(size: 20),
            Text(
              'Open cash drawer after print bill',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
      ],
    );
  }
}
