import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/core_exports.dart';
import 'package:rebill_flutter/core/providers/merge_bill_provider.dart';
import 'package:rebill_flutter/core/utils/extensions.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_material.dart';
import 'package:rebill_flutter/core/widgets/app_popup_menu.dart';
import 'package:rebill_flutter/core/widgets/app_search_bar.dart';

final tempSelectedBillsProvider = StateProvider<List<BillModel>>((ref) => []);

class MergeBillDialog extends ConsumerWidget {
  const MergeBillDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mergeBills = ref.watch(mergeBillProvider);
    final tempSelectedBills = ref.watch(tempSelectedBillsProvider);
    final selectedBill = ref.watch(selectedMergeBillProvider);
    return Expanded(
      child: Column(
        spacing: 16,
        children: [
          SizedBox(width: double.infinity, child: AppSearchBar()),
          Expanded(
            child: Column(
              children: [
                // Table header
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    spacing: 12,
                    children: [
                      Expanded(
                        child: Text(
                          'Bill ID',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Name',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Table',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Total',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Status',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Date',
                          textAlign: TextAlign.center,

                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Product List',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Table body
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    cacheExtent: 100,
                    itemCount: mergeBills.bills.length,
                    itemBuilder: (context, index) {
                      // Get customer data
                      final bill = mergeBills.bills[index];
                      final isSelected = tempSelectedBills.any(
                        (selected) => selected.billId == bill.billId,
                      );
                      final isFixedSelected =
                          selectedBill?.billId == bill.billId;

                      return Column(
                        children: [
                          AppMaterial(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              final notifier = ref.read(
                                tempSelectedBillsProvider.notifier,
                              );
                              final currentSelected = [...tempSelectedBills];

                              if (isSelected) {
                                // If already selected, remove it
                                currentSelected.removeWhere(
                                  (item) => item.billId == bill.billId,
                                );
                                notifier.state = currentSelected;
                              } else {
                                // If not selected, check if we already have 2 selections
                                if (currentSelected.length >= 2) {
                                  // Reset selection and select only this one
                                  notifier.state = [bill];
                                } else {
                                  // Add this one to selection
                                  currentSelected.add(bill);
                                  notifier.state = currentSelected;
                                }
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 60,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color:
                                    isSelected || isFixedSelected
                                        ? theme.colorScheme.primaryContainer
                                        : index % 2 == 0
                                        ? theme.colorScheme.surfaceContainer
                                        : theme.colorScheme.surface,
                                border: Border.all(
                                  color:
                                      isSelected || isFixedSelected
                                          ? theme.colorScheme.primary
                                          : index % 2 == 0
                                          ? Colors.transparent
                                          : theme.colorScheme.onSurface
                                              .withAlpha(127),
                                ),
                              ),
                              child: Row(
                                spacing: 12,
                                children: [
                                  Expanded(
                                    child: Text(
                                      bill.cBillId,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      bill.customerName,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w400,
                                          ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      bill.tableName ?? '-',
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w400,
                                          ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      bill.total.toCurrency(),
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w400,
                                          ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color:
                                            bill.states == 'open'
                                                ? theme.colorScheme.primary
                                                : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          bill.states,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                color:
                                                    bill.states == 'open'
                                                        ? Colors.white
                                                        : theme
                                                            .colorScheme
                                                            .onSurface,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      bill.posBillDate.toDateOnly(),
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            color: theme.colorScheme.onSurface,
                                            fontWeight: FontWeight.w400,
                                          ),
                                    ),
                                  ),
                                  MergeBillProductList(bill: bill),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Row(
              spacing: 12,
              mainAxisAlignment: MainAxisAlignment.end,
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
                  onPressed: tempSelectedBills.length == 2 ? () {} : null,
                  text: 'Merge Bills',
                  disabled: tempSelectedBills.length != 2,
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

class MergeBillProductList extends StatelessWidget {
  const MergeBillProductList({super.key, required this.bill});

  final BillModel bill;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: AppPopupMenu(
        borderRadius: 8,
        items:
            bill.items?.isNotEmpty == true
                ? bill.items!
                    .map(
                      (e) => AppPopupMenuItem(
                        text: e.name,
                        value: e.name,
                        trailing: Text(' : ${e.quantity.toInt()}'),
                        height: 25,
                      ),
                    )
                    .toList()
                : [AppPopupMenuItem(value: 'empty', text: 'Empty')],
        onSelected: (value) {},
        child: Container(
          height: 30,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border.all(color: theme.colorScheme.primary),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text('Show', style: theme.textTheme.titleSmall?.copyWith()),
          ),
        ),
      ),
    );
  }
}
