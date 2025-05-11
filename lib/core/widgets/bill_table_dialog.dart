import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/models/table.dart';
import 'package:rebill_flutter/core/providers/table_bill_provider.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_divider.dart';
import 'package:rebill_flutter/core/widgets/table_bill_card.dart';

class BillTableDialog extends ConsumerStatefulWidget {
  const BillTableDialog({super.key, required this.table});

  final TableModel table;

  @override
  ConsumerState<BillTableDialog> createState() => _BillTableDialogState();
}

class _BillTableDialogState extends ConsumerState<BillTableDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tableBillProvider.notifier).loadBills();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tableBills = ref.watch(tableBillProvider);
    return Expanded(
      child: Column(
        children: [
          const AppDivider(),
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: EdgeInsets.only(top: 12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
              ),
              itemCount: tableBills.bills.length,
              itemBuilder: (context, index) {
                return TableBillCard(bill: tableBills.bills[index]);
              },
            ),
          ),
          const AppDivider(),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  spacing: 12,
                  children: [
                    AppButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      text: 'Return to overview',
                      backgroundColor: theme.colorScheme.errorContainer,
                      textStyle: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
