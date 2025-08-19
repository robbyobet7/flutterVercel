import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rebill_flutter/core/providers/table_provider.dart';
import 'package:rebill_flutter/core/theme/app_theme.dart';
import 'package:rebill_flutter/core/widgets/app_divider.dart';
import 'package:rebill_flutter/core/widgets/app_material.dart';
import 'package:rebill_flutter/core/widgets/table_dialog.dart';

class TableCard extends ConsumerWidget {
  const TableCard({
    super.key,
    required this.index,
    required this.tableType,
    required this.onTap,
  });

  final int index;
  final TableType tableType;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final table = ref.watch(tableProvider).tables[index];
    final selectedQRTableValue = ref.watch(selectedQRTable);

    // Check if this table is selected for QR type
    final isSelectedForQR =
        tableType == TableType.qr &&
        selectedQRTableValue != null &&
        selectedQRTableValue.id == table.id;

    final numberFormat = NumberFormat.currency(
      locale: 'id',
      symbol: '',
      decimalDigits: 0,
    );

    List<Color> getStatusColor(String status) {
      switch (status) {
        case 'reserved':
          return [AppTheme.warning, AppTheme.warningContainer];
        case 'bill_open':
          return [AppTheme.success, AppTheme.successContainer];
        default:
          return [theme.colorScheme.error, theme.colorScheme.errorContainer];
      }
    }

    return AppMaterial(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color:
              isSelectedForQR
                  ? theme.colorScheme.primary
                  : getStatusColor(table.status)[1],
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            width: 2,
            color:
                isSelectedForQR
                    ? theme.colorScheme.primary
                    : getStatusColor(table.status)[0],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                decoration: BoxDecoration(
                  color:
                      isSelectedForQR
                          ? theme.colorScheme.primary
                          : getStatusColor(table.status)[1],
                  borderRadius:
                      tableType != TableType.nav
                          ? BorderRadius.circular(12.0)
                          : BorderRadius.only(
                            topLeft: Radius.circular(12.0),
                            topRight: Radius.circular(12.0),
                          ),
                ),
                child: Center(
                  child: Text(
                    table.tableName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color:
                          isSelectedForQR
                              ? theme.colorScheme.onPrimary
                              : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            if (tableType == TableType.nav)
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${table.countBillOpen}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: ' Bill(s)',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      AppDivider(color: getStatusColor(table.status)[0]),
                      Expanded(
                        child: Center(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'IDR ',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: numberFormat.format(
                                    table.totalBillOpen,
                                  ),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      AppDivider(color: getStatusColor(table.status)[0]),
                      Expanded(
                        child: Center(
                          child: Text(
                            'min. IDR ${numberFormat.format(table.minimumCharge)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.black,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
