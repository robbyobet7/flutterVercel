import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_divider.dart';
import 'package:rebill_flutter/core/widgets/app_popup_menu.dart';
import 'package:rebill_flutter/features/printer-settings/models/printer.dart';
import 'package:rebill_flutter/features/printer-settings/presentations/widgets/printer_container.dart';
import 'package:rebill_flutter/features/printer-settings/providers/printer_provider.dart';
import 'package:rebill_flutter/features/reservation/presentations/widgets/add_reservation_dialog.dart';

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
    final selectedPrinter = ref.watch(printerProvider);

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
            selectedPrinter?.advanced == true
                ? AdvancedSetting()
                : CompactSetting(),
          ],
        ),
      ),
    );
  }
}

class CompactSetting extends StatelessWidget {
  const CompactSetting({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        SizedBox(height: 12),
        Column(
          children: [
            LabelText(text: 'Printer'),
            AppPopupMenu(
              onSelected: (value) {},
              items: [
                AppPopupMenuItem(value: 'Printer 1', text: 'Printer 1'),
                AppPopupMenuItem(value: 'Printer 2', text: 'Printer 2'),
              ],
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.surfaceContainer),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.print_rounded,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(width: 12),
                        Text('Select Printer'),
                      ],
                    ),
                    Icon(Icons.arrow_drop_down_rounded),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class AdvancedSetting extends StatelessWidget {
  const AdvancedSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [AppDivider()]);
  }
}
