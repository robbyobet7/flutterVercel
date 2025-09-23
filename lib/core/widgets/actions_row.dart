import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/table_dialog.dart';
import 'package:rebill_flutter/features/main-bill/constants/bill_constants.dart';
import 'package:rebill_flutter/features/main-bill/providers/main_bill_provider.dart';

class ActionsRow extends ConsumerWidget {
  const ActionsRow({super.key, required this.tableType});

  final TableType tableType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mainBillNotifier = ref.watch(mainBillProvider.notifier);
    final billTypeNotifier = ref.watch(billTypeProvider.notifier);

    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment:
            tableType == TableType.nav
                ? MainAxisAlignment.end
                : MainAxisAlignment.spaceBetween,
        children: [
          if (tableType != TableType.nav)
            Row(
              spacing: 12,
              children: [
                AppButton(
                  onPressed: () {
                    Navigator.pop(context);
                    mainBillNotifier.setMainBill(
                      MainBillComponent.currentBillComponent,
                    );
                    billTypeNotifier.setBillType(BillType.qrBill);
                  },
                  text: 'No Table',
                ),
              ],
            ),
          Row(
            spacing: 12,
            children: [
              AppButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Clear selected table so it doesn't stay active next time
                  ref.read(selectedQRTable.notifier).state = null;
                },
                text: 'Cancel',
                backgroundColor: theme.colorScheme.errorContainer,
                textStyle: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              if (tableType != TableType.nav)
                AppButton(
                  onPressed: () {
                    Navigator.pop(context);

                    mainBillNotifier.setMainBill(
                      MainBillComponent.currentBillComponent,
                    );
                    billTypeNotifier.setBillType(BillType.qrBill);

                    // Clear selection after successful submit
                    ref.read(selectedQRTable.notifier).state = null;
                  },
                  text: 'Submit',
                  disabled: ref.watch(selectedQRTable) == null,
                  backgroundColor: theme.colorScheme.primary,
                  textStyle: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
