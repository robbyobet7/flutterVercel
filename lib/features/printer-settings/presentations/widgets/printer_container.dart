import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/features/printer-settings/models/printer.dart';
import 'package:rebill_flutter/features/printer-settings/providers/printer_provider.dart';

class PrinterContainer extends ConsumerWidget {
  const PrinterContainer({super.key, required this.printer});

  final PrinterModel printer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isSelected = ref.watch(printerProvider)?.name == printer.name;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ref.read(printerProvider.notifier).selectPrinter(printer);
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? theme.colorScheme.primaryContainer
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.primary),
            ),
            child: Row(
              spacing: 12,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(printer.icon, color: theme.colorScheme.primary, size: 32),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        printer.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        printer.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                        ),
                      ),
                      if (printer.requirements != null)
                        Row(
                          spacing: 4,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              printer.requirements!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 8,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            Icon(
                              Icons.link_rounded,
                              color: theme.colorScheme.primary,
                              size: 10,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
