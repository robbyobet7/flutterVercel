import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/models/table.dart';
import 'package:rebill_flutter/core/providers/orientation_provider.dart';
import 'package:rebill_flutter/core/providers/table_provider.dart';
import 'package:rebill_flutter/core/widgets/actions_row.dart';
import 'package:rebill_flutter/core/widgets/app_dialog.dart';
import 'package:rebill_flutter/core/widgets/app_divider.dart';
import 'package:rebill_flutter/core/widgets/bill_table_dialog.dart';
import 'package:rebill_flutter/core/widgets/table_card.dart';

enum TableType { nav, qr, bill }

final selectedQRTable = StateProvider<TableModel?>((ref) => null);

class TableDialog extends ConsumerWidget {
  const TableDialog({super.key, this.tableType = TableType.nav});

  final TableType tableType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tables = ref.watch(tableProvider).tables;
    final isLandscape = ref.watch(orientationProvider);

    void navTableTap(int index) {
      if (tableType == TableType.nav) {
        AppDialog.showCustom(
          context,
          dialogType: DialogType.large,
          title: '${tables[index].tableName} - Bills',
          content: BillTableDialog(table: tables[index]),
        );
      } else if (tableType == TableType.qr) {
        ref.read(selectedQRTable.notifier).state = tables[index];
      }
    }

    return Expanded(
      child: Column(
        children: [
          if (tableType != TableType.nav) const AppDivider(),
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: EdgeInsets.only(top: 12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isLandscape ? 5 : 3,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
              ),
              cacheExtent: 100,
              itemCount: tables.length,
              itemBuilder: (context, index) {
                return TableCard(
                  index: index,
                  tableType: tableType,
                  onTap: () => navTableTap(index),
                );
              },
            ),
          ),
          if (tableType != TableType.nav) const AppDivider(),
          if (tableType != TableType.nav) const SizedBox(height: 12),
          if (tableType != TableType.nav) ActionsRow(tableType: tableType),
        ],
      ),
    );
  }
}
