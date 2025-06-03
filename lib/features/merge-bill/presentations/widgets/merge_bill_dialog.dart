import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rebill_flutter/core/core_exports.dart';
import 'package:rebill_flutter/core/providers/merge_bill_provider.dart';
import 'package:rebill_flutter/core/utils/extensions.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_material.dart';
import 'package:rebill_flutter/core/widgets/app_search_bar.dart';

final tempSelectedBillProvider = StateProvider<BillModel?>((ref) => null);

class MergeBillDialog extends ConsumerWidget {
  const MergeBillDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: '',
      decimalDigits: 0,
    );

    final theme = Theme.of(context);
    final mergeBills = ref.watch(mergeBillProvider);
    final tempSelectedBill = ref.watch(tempSelectedBillProvider);
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
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      // Get customer data
                      final bill = mergeBills.bills[index];

                      return Column(
                        children: [
                          AppMaterial(
                            borderRadius: BorderRadius.circular(8),

                            onTap: () {
                              ref
                                  .read(tempSelectedBillProvider.notifier)
                                  .state = bill;
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
                                    tempSelectedBill?.billId == bill.billId ||
                                            selectedBill?.billId == bill.billId
                                        ? theme.colorScheme.primaryContainer
                                        : index % 2 == 0
                                        ? theme.colorScheme.surfaceContainer
                                        : theme.colorScheme.surface,
                                border: Border.all(
                                  color:
                                      tempSelectedBill?.billId == bill.billId ||
                                              selectedBill?.billId ==
                                                  bill.billId
                                          ? theme.colorScheme.primary
                                          : index % 2 == 0
                                          ? Colors.transparent
                                          : theme.colorScheme.onSurface
                                              .withOpacity(0.05),
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
                                      currencyFormatter.format(bill.total),
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
                                  Expanded(
                                    child: AppMaterial(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.surface,
                                          border: Border.all(
                                            color: theme.colorScheme.primary,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Show',
                                            style:
                                                theme.textTheme.titleSmall
                                                    ?.copyWith(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
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
                  onPressed: () {},
                  text: 'Cancel',
                  backgroundColor: theme.colorScheme.errorContainer,
                  textStyle: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                AppButton(
                  onPressed: () {},
                  text: 'Merge Bills',
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
