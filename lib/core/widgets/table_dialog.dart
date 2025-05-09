import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/providers/table_provider.dart';
import 'package:rebill_flutter/core/widgets/actions_row.dart';
import 'package:rebill_flutter/core/widgets/table_card.dart';

enum TableType { nav, qr, bill }

class TableDialog extends ConsumerWidget {
  const TableDialog({super.key, this.tableType = TableType.nav});

  final TableType tableType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tables = ref.watch(tableProvider).tables;
    return Expanded(
      child: Column(
        spacing: 12,
        children: [
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
              ),
              itemCount: tables.length,
              itemBuilder: (context, index) {
                return TableCard(index: index, tableType: tableType);
              },
            ),
          ),
          ActionsRow(tableType: tableType),
        ],
      ),
    );
  }
}
