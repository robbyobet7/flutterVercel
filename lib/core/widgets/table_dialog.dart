import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/providers/table_provider.dart';
import 'package:rebill_flutter/core/widgets/actions_row.dart';
import 'package:rebill_flutter/core/widgets/app_dialog.dart';
import 'package:rebill_flutter/core/widgets/app_divider.dart';
import 'package:rebill_flutter/core/widgets/bill_table_dialog.dart';
import 'package:rebill_flutter/core/widgets/table_card.dart';

enum TableType { nav, qr, bill }

class TableDialog extends ConsumerWidget {
  const TableDialog({super.key, this.tableType = TableType.nav});

  final TableType tableType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tables = ref.watch(tableProvider).tables;

    void navTableTap(int index) {
      AppDialog.showCustom(
        context,
        dialogType: DialogType.large,
        title: '${tables[index].tableName} - Bills',
        content: BillTableDialog(table: tables[index]),
      );
    }

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
                crossAxisCount: 5,
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
          const AppDivider(),
          const SizedBox(height: 12),
          ActionsRow(tableType: tableType),
        ],
      ),
    );
  }
}
