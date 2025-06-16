import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/widgets/app_popup_menu.dart';
import 'package:rebill_flutter/core/widgets/app_text_field.dart';
import 'package:rebill_flutter/core/widgets/decrement_button.dart';
import 'package:rebill_flutter/core/widgets/increment_button.dart';
import 'package:rebill_flutter/core/widgets/label_text.dart';
import 'package:rebill_flutter/features/printer-settings/presentations/widgets/advanced_setting.dart';
import 'package:rebill_flutter/features/printer-settings/presentations/widgets/non_epson_setting.dart';
import 'package:rebill_flutter/features/printer-settings/presentations/widgets/print_layout.dart';
import 'package:rebill_flutter/features/printer-settings/presentations/widgets/printer_popup_menu.dart';
import 'package:rebill_flutter/features/printer-settings/providers/printer_provider.dart';

class PrinterSetting extends ConsumerWidget {
  const PrinterSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPrinter = ref.watch(printerProvider);

    final theme = Theme.of(context);
    return Column(
      spacing: 12,
      children: [
        SizedBox.shrink(),
        selectedPrinter?.advanced == true
            ? AdvancedSetting()
            : PrinterPopupMenu(
              label: 'Printer',
              items: [
                AppPopupMenuItem(value: 'Printer 1', text: 'Printer 1'),
                AppPopupMenuItem(value: 'Printer 2', text: 'Printer 2'),
              ],
              hintText: 'Select Printer',
              leading: Icon(
                Icons.print_rounded,
                color: theme.colorScheme.primary,
              ),
            ),
        PrintLayout(),
        Row(
          spacing: 12,
          children: [
            Expanded(
              child: PrinterPopupMenu(
                label: 'Bill Language',
                items: [
                  AppPopupMenuItem(value: 'English', text: 'English'),
                  AppPopupMenuItem(value: 'French', text: 'French'),
                  AppPopupMenuItem(value: 'Spanish', text: 'Spanish'),
                ],
                hintText: 'Select Language',
              ),
            ),

            SizedBox(
              width: 150,
              child: Column(
                children: [
                  LabelText(text: 'Font Size'),
                  Row(
                    spacing: 12,
                    children: [
                      DecrementButton(),
                      Expanded(
                        child: AppTextField(
                          controller: TextEditingController(),
                          showLabel: false,
                        ),
                      ),
                      IncrementButton(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        selectedPrinter?.name == 'Direct Printing'
            ? SizedBox.shrink()
            : NonEpsonSetting(),
      ],
    );
  }
}
