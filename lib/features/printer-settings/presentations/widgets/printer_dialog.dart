import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_divider.dart';
import 'package:rebill_flutter/features/printer-settings/models/printer.dart';
import 'package:rebill_flutter/features/printer-settings/presentations/widgets/printer_setting.dart';
import 'package:rebill_flutter/features/printer-settings/presentations/widgets/printer_container.dart';

class PrinterDialog extends StatelessWidget {
  const PrinterDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          AppDivider(),
          SizedBox(height: 12),
          PrinterDialogContent(),
          AppDivider(),
          SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 12,
              children: [
                AppButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  text: 'Cancel',
                  backgroundColor: theme.colorScheme.errorContainer,
                  textStyle: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                AppButton(
                  onPressed: () {},
                  text: 'Save',
                  backgroundColor: theme.colorScheme.primary,
                  textStyle: theme.textTheme.bodySmall?.copyWith(
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

class PrinterDialogContent extends ConsumerWidget {
  const PrinterDialogContent({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final printers = [
      PrinterModel(
        name: 'System Printing',
        description: 'All Printers',
        icon: Icons.receipt_long_rounded,
      ),
      PrinterModel(
        name: 'Direct Printing',
        description: 'Epson Printers Only',
        requirements: 'Requires Extra App',
        icon: Icons.print_rounded,
        advanced: true,
      ),
      PrinterModel(
        name: 'SDK Printing',
        description: 'Android Only',
        icon: Icons.print_rounded,
      ),
      PrinterModel(
        name: 'Network Printing',
        description: 'Windows Only',
        requirements: 'Download Driver',
        icon: Icons.wifi,
        advanced: true,
      ),
    ];

    return Expanded(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        child: Column(
          children: [
            SizedBox(height: 12),
            GridView.builder(
              cacheExtent: 4,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 80,
              ),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder:
                  (context, index) =>
                      PrinterContainer(printer: printers[index]),
              itemCount: printers.length,
            ),
            PrinterSetting(),
          ],
        ),
      ),
    );
  }
}
