import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
    // Ensure bills are loaded (and synced with current BillMiddleware state)
    if (mergeBills.bills.isEmpty && mergeBills.isLoading == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(mergeBillProvider.notifier).loadBills();
      });
    }
    final tempSelectedBills = ref.watch(tempSelectedBillsProvider);
    final selectedBill = ref.watch(selectedMergeBillProvider);

    // Get available height without considering keyboard (dialog stays behind keyboard)
    final mediaQuery = MediaQuery.of(context);
    final availableHeight =
        mediaQuery.size.height - 200; // Reserve space for dialog padding

    return Expanded(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: availableHeight),
        child: GestureDetector(
          onTap: () {
            // Dismiss keyboard when tapping outside
            FocusScope.of(context).unfocus();
          },
          child: Column(
            spacing: 16,
            children: [
              SizedBox(
                width: double.infinity,
                child: AppSearchBar(
                  onSearch: (query) {
                    ref.read(mergeBillProvider.notifier).searchBills(query);
                  },
                  onClear: () {
                    ref.read(mergeBillProvider.notifier).resetSearch();
                  },
                ),
              ),
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
                        children: [
                          const SizedBox(width: 34),
                          Expanded(
                            child: Text(
                              'Bill ID',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Text(
                              'Name',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Table',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Total',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Status',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Date',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Product List',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                    ),
                    // Table body
                    Expanded(
                      child:
                          mergeBills.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : mergeBills.bills
                                  .where((b) => b.states == 'open')
                                  .isEmpty
                              ? SingleChildScrollView(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight:
                                        availableHeight *
                                        0.3, // Minimum 30% of available height
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.receipt_long_outlined,
                                            size: 48, // Reduced from 64
                                            color:
                                                theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                          ),
                                          const SizedBox(
                                            height: 12,
                                          ), // Reduced from 16
                                          Text(
                                            mergeBills.searchQuery != null
                                                ? 'No bills found matching "${mergeBills.searchQuery}"'
                                                : 'No open bills available for merging',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  // Changed from bodyLarge
                                                  color:
                                                      theme
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                ),
                                            textAlign: TextAlign.center,
                                          ),
                                          if (mergeBills.searchQuery !=
                                              null) ...[
                                            const SizedBox(height: 8),
                                            TextButton(
                                              onPressed: () {
                                                ref
                                                    .read(
                                                      mergeBillProvider
                                                          .notifier,
                                                    )
                                                    .resetSearch();
                                              },
                                              child: const Text('Clear search'),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              : ListView.builder(
                                physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics(),
                                ),
                                cacheExtent: 100,
                                shrinkWrap: true, // Allow ListView to shrink
                                itemCount:
                                    mergeBills.bills
                                        .where((b) => b.states == 'open')
                                        .length,
                                itemBuilder: (context, index) {
                                  // Only show OPEN bills for merging
                                  final openBills =
                                      mergeBills.bills
                                          .where((b) => b.states == 'open')
                                          .toList();
                                  final bill = openBills[index];
                                  final selectionIndex = tempSelectedBills
                                      .indexWhere(
                                        (selected) =>
                                            selected.billId == bill.billId,
                                      );
                                  final isSelected = selectionIndex != -1;
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
                                          final currentSelected = [
                                            ...tempSelectedBills,
                                          ];

                                          if (isSelected) {
                                            // If selected, remove it and shift order
                                            final idx = selectionIndex;
                                            currentSelected.removeAt(idx);
                                            notifier.state = currentSelected;
                                          } else {
                                            // Add to selection (no limit)
                                            currentSelected.add(bill);
                                            notifier.state = currentSelected;
                                          }
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          height: 60,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            color:
                                                isSelected || isFixedSelected
                                                    ? theme
                                                        .colorScheme
                                                        .primaryContainer
                                                    : index % 2 == 0
                                                    ? theme
                                                        .colorScheme
                                                        .surfaceContainer
                                                    : theme.colorScheme.surface,
                                            border: Border.all(
                                              color:
                                                  isSelected || isFixedSelected
                                                      ? theme
                                                          .colorScheme
                                                          .primary
                                                      : index % 2 == 0
                                                      ? Colors.transparent
                                                      : theme
                                                          .colorScheme
                                                          .onSurface
                                                          .withAlpha(127),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              // Order badge if selected
                                              if (isSelected)
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                    right: 12,
                                                  ),
                                                  width: 24,
                                                  height: 24,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        theme
                                                            .colorScheme
                                                            .primary,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          9999,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    '${selectionIndex + 1}',
                                                    style: theme
                                                        .textTheme
                                                        .labelSmall
                                                        ?.copyWith(
                                                          color:
                                                              theme
                                                                  .colorScheme
                                                                  .onPrimary,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                )
                                              else
                                                const SizedBox(width: 36),
                                              Expanded(
                                                child: Text(
                                                  bill.cBillId,
                                                  style: theme
                                                      .textTheme
                                                      .titleSmall
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                              ),
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: Text(
                                                  bill.customerName,
                                                  style: theme
                                                      .textTheme
                                                      .titleSmall
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  bill.tableName ?? '-',
                                                  textAlign: TextAlign.center,
                                                  style: theme
                                                      .textTheme
                                                      .titleSmall
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  bill.finalTotal.toCurrency(),
                                                  textAlign: TextAlign.center,
                                                  style: theme
                                                      .textTheme
                                                      .titleSmall
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Container(
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        bill.states == 'open'
                                                            ? theme
                                                                .colorScheme
                                                                .primary
                                                            : Colors
                                                                .transparent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      bill.states,
                                                      style: theme
                                                          .textTheme
                                                          .titleSmall
                                                          ?.copyWith(
                                                            color:
                                                                bill.states ==
                                                                        'open'
                                                                    ? Colors
                                                                        .white
                                                                    : theme
                                                                        .colorScheme
                                                                        .onSurface,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8.0,
                                                      ),
                                                  child: Text(
                                                    DateFormat(
                                                      'dd/MM/yyyy',
                                                    ).format(bill.createdAt),
                                                    textAlign: TextAlign.center,
                                                    style: theme
                                                        .textTheme
                                                        .titleSmall
                                                        ?.copyWith(
                                                          color:
                                                              theme
                                                                  .colorScheme
                                                                  .onSurface,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
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
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppButton(
                      onPressed: () {
                        ref.read(tempSelectedBillsProvider.notifier).state = [];
                        ref
                            .read(mergeBillProvider.notifier)
                            .clearSelectedBill();
                        Navigator.pop(context);
                      },
                      text: 'Cancel',
                      backgroundColor: theme.colorScheme.errorContainer,
                      textStyle: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(width: 12),
                    AppButton(
                      onPressed:
                          tempSelectedBills.length >= 2
                              ? () async {
                                final navigator = Navigator.of(context);
                                // Merge multiple bills: first is primary, merge others sequentially
                                final primary = tempSelectedBills.first;
                                final others =
                                    tempSelectedBills.skip(1).toList();

                                BillModel? result = primary;

                                // Merge each additional bill into the primary
                                for (final bill in others) {
                                  result = await ref
                                      .read(mergeBillProvider.notifier)
                                      .mergeSelectedBills(
                                        primary: result!,
                                        secondary: bill,
                                      );
                                  if (result == null)
                                    break; // Stop if merge fails
                                }

                                if (result != null) {
                                  // Clear selections after successful merge
                                  ref
                                      .read(tempSelectedBillsProvider.notifier)
                                      .state = [];
                                  ref
                                      .read(mergeBillProvider.notifier)
                                      .clearSelectedBill();
                                  // Close dialog on success
                                  navigator.pop();
                                }
                              }
                              : null,
                      text: 'Merge Bills',
                      disabled: tempSelectedBills.length < 2,
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
        ),
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
