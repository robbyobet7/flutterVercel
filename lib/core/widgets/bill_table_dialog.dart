import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/providers/table_bill_provider.dart';
import 'package:rebill_flutter/core/table_exports.dart';
import 'package:rebill_flutter/core/widgets/app_divider.dart';

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
    final tableBills = ref.watch(tableBillProvider);
    print(tableBills.bills.length);
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
              itemCount: tableBills.bills.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(children: [Text(index.toString())]),
                );
              },
            ),
          ),
          const AppDivider(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
