import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/widgets/app_material.dart';
import 'package:rebill_flutter/features/printer-settings/providers/printer_provider.dart';
import 'package:rebill_flutter/features/reservation/presentations/widgets/add_reservation_dialog.dart';

class PrintLayout extends ConsumerWidget {
  const PrintLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    const layout = ['Normal', 'Compact'];
    final printerLayout = ref.watch(printerLayoutProvider);
    final isSelected = (String layout) => printerLayout == layout;

    return Column(
      children: [
        LabelText(text: 'Print Layout'),
        Row(
          spacing: 12,
          children:
              layout
                  .map(
                    (e) => Expanded(
                      child: AppMaterial(
                        onTap:
                            () => ref
                                .read(printerLayoutProvider.notifier)
                                .setLayout(e),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 45,
                          decoration: BoxDecoration(
                            color:
                                isSelected(e)
                                    ? theme.colorScheme.primaryContainer
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              e,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color:
                                    isSelected(e)
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }
}
