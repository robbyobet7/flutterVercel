import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rebill_flutter/core/core_exports.dart';
import 'package:rebill_flutter/core/providers/bill_provider.dart';
import 'package:rebill_flutter/core/providers/cart_provider.dart';
import 'package:rebill_flutter/core/providers/checkout_discount_provider.dart';
import 'package:rebill_flutter/core/providers/merge_bill_provider.dart';
import 'package:rebill_flutter/core/theme/app_theme.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_dialog.dart';
import 'package:rebill_flutter/core/widgets/app_material.dart';
import 'package:rebill_flutter/features/checkout/models/checkout_discount.dart';
import 'package:rebill_flutter/features/home/presentation/widgets/user_bills_dropdown.dart';
import 'package:rebill_flutter/features/main-bill/constants/bill_constants.dart';
import 'package:rebill_flutter/features/main-bill/providers/main_bill_provider.dart';
import 'package:rebill_flutter/features/merge-bill/presentations/widgets/merge_bill_dialog.dart';

class HomeBill extends ConsumerStatefulWidget {
  const HomeBill({super.key});

  @override
  ConsumerState<HomeBill> createState() => _HomeBillState();
}

class _HomeBillState extends ConsumerState<HomeBill> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load bills when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(billProvider.notifier).loadBills();
      ref.read(mergeBillProvider.notifier).loadBills();
      ref.read(customerProvider.notifier).refreshCustomers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // Original color calculation logic
  Color _calculateStatusColor(String status) {
    // Get theme inside the method each time it's called
    final theme = Theme.of(context);

    switch (status.toLowerCase()) {
      case 'closed':
        return theme.colorScheme.errorContainer;
      case 'open':
        return theme.colorScheme.primary;
      default:
        return theme.colorScheme.surfaceContainer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allBills = ref.watch(allBillsProvider);
    final isLoading = ref.watch(billLoadingProvider);
    final customerType = ref.watch(customerTypeProvider);
    final knownIndividual = ref.watch(knownIndividualProvider);
    final cart = ref.watch(cartProvider);
    final checkoutDiscount = ref.watch(checkoutDiscountProvider);
    final mainBillComponent = ref.watch(mainBillProvider);
    final selectedBill = ref.watch(selectedBillProvider);
    int roundUpToThousand(double value) => ((value / 1000).ceil()) * 1000;

    // Calculate total with checkout discount
    final total =
        checkoutDiscount.appliedDiscounts.isNotEmpty
            ? cart.getTotalWithCheckoutDiscount(
              checkoutDiscount.totalDiscountAmount,
            )
            : cart.total;

    BillItem? activeBill;
    if (mainBillComponent != MainBillComponent.defaultComponent &&
        selectedBill == null) {
      activeBill = BillItem(
        billId: 9999,
        name:
            customerType == CustomerType.knownIndividual &&
                    knownIndividual != null
                ? knownIndividual.customerName
                : 'Guest',
        total: roundUpToThousand(total).toDouble(),
        finalTotal: roundUpToThousand(total).toDouble(),
        status: 'open',
        createdAt: DateTime.now(),
      );
    }

    // Combine activeBill with the first billsByDate group (or create a new one if empty)
    List<BillsByDate> displayBills = List.from(allBills);
    if (activeBill != null) {
      if (displayBills.isNotEmpty && displayBills[0].date == 'Today') {
        final todayBills = displayBills[0].bills;
        // Remove the previous activeBill if any to avoid duplicates
        todayBills.removeWhere((b) => b.billId == 9999);
        todayBills.insert(0, activeBill);
      } else {
        // If there is no "Today" group, create a new one and put it at the top
        displayBills.insert(0, BillsByDate(date: 'Today', bills: [activeBill]));
      }
    }

    final totalBillItems = displayBills.fold<int>(
      0,
      (sum, b) => sum + b.bills.length,
    );
    final totalOpenItems = displayBills.fold<int>(
      0,
      (sum, b) =>
          sum +
          b.bills.where((bill) => bill.status.toLowerCase() == 'open').length,
    );
    final totalClosedItems = displayBills.fold<int>(
      0,
      (sum, b) =>
          sum +
          b.bills.where((bill) => bill.status.toLowerCase() == 'closed').length,
    );

    final List<BillsByDate> filteredBills;
    if (_searchQuery.isEmpty) {
      filteredBills = displayBills;
    } else {
      filteredBills = [];
      for (var billsByDate in displayBills) {
        final matchingBills =
            billsByDate.bills.where((bill) {
              return bill.name.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              );
            }).toList();

        if (matchingBills.isNotEmpty) {
          filteredBills.add(
            BillsByDate(date: billsByDate.date, bills: matchingBills),
          );
        }
      }
    }

    return GestureDetector(
      // Dismiss keyboard when tapping outside
      onTap: () => FocusScope.of(context).unfocus(),
      // Avoid registering as a tap when the user is interacting with children
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: AppTheme.kBoxShadow,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.hardEdge,
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          spacing: 12,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bills',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppButton(
                      onPressed: () {
                        AppDialog.showCustom(
                          context,
                          content: MergeBillDialog(),
                          dialogType: DialogType.large,
                          title: 'Merge Bills',
                        );
                      },
                      text: 'Merge Bills',
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: BillFilterDropdown(
                      allBillsCount: totalBillItems,
                      openBillsCount: totalOpenItems,
                      closedBillsCount: totalClosedItems,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        border: Border.all(
                          color: theme.colorScheme.surfaceContainer,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              // Set autofocus to false to prevent automatic focus
                              autofocus: false,
                              onTapOutside: (value) {
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              decoration: const InputDecoration(
                                hintText: 'Search Bill...',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                              style: theme.textTheme.bodyMedium,
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                              // Handle tap on the text field explicitly
                              onTap: () {
                                // Only handle focus if explicitly tapped
                                _searchFocusNode.requestFocus();
                              },
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              // Stop the parent gesture detector from receiving this tap
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                // Also unfocus to hide keyboard
                                _searchFocusNode.unfocus();
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Icon(Icons.clear, size: 16),
                              ),
                            ),
                          GestureDetector(
                            // Stop the parent gesture detector from receiving this tap
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              // Toggle focus - if focused, unfocus, otherwise focus
                              if (_searchFocusNode.hasFocus) {
                                _searchFocusNode.unfocus();
                              } else {
                                _searchFocusNode.requestFocus();
                              }
                            },
                            child: const Icon(Icons.search, size: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  // Fixed table header that's only rendered once
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer.withAlpha(127),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      border: Border.all(
                        color: theme.colorScheme.surfaceContainer,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            'Name',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Total',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Status',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 1,
                  ), // Slight gap between header and content
                  // Scrollable content
                  Expanded(
                    child:
                        isLoading
                            ? Center(
                              child: CircularProgressIndicator(
                                color: theme.colorScheme.primary,
                              ),
                            )
                            : RepaintBoundary(
                              child:
                                  filteredBills.isEmpty
                                      ? Center(
                                        child: Text(
                                          'No bills found',
                                          style: theme.textTheme.bodyLarge,
                                        ),
                                      )
                                      : ListView.builder(
                                        physics: const BouncingScrollPhysics(
                                          parent:
                                              AlwaysScrollableScrollPhysics(),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        itemCount: filteredBills.length,
                                        // Add these performance optimization parameters
                                        addAutomaticKeepAlives: false,
                                        addRepaintBoundaries: true,
                                        clipBehavior: Clip.hardEdge,
                                        // Use cacheExtent to pre-render items outside the visible area
                                        cacheExtent: 100,
                                        itemBuilder: (context, index) {
                                          final billsByDate =
                                              filteredBills[index];
                                          // Use KeyedSubtree to maintain state when items move
                                          return KeyedSubtree(
                                            key: ValueKey(
                                              'bills-date-${billsByDate.date}',
                                            ),
                                            child: _buildBillItem(
                                              context,
                                              billsByDate,
                                              theme,
                                            ),
                                          );
                                        },
                                      ),
                            ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillItem(
    BuildContext context,
    BillsByDate dayData,
    ThemeData theme,
  ) {
    // Add spacing after each day section except the last one
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header with date
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8),
            child: Text(
              dayData.date,
              textAlign: TextAlign.start,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(127),
              ),
            ),
          ),
          // Bills container
          Container(
            clipBehavior: Clip.hardEdge,

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.surfaceContainer),
            ),
            child: Column(children: _buildBillItems(dayData.bills)),
          ),
        ],
      ),
    );
  }

  // Extract bill items building to a separate method
  List<Widget> _buildBillItems(List<BillItem> bills) {
    final selectedBill = ref.watch(selectedBillProvider);
    final theme = Theme.of(context);
    // Sign active billId
    final int activeBillId = selectedBill != null ? selectedBill.billId : 9999;
    return List.generate(bills.length, (index) {
      final bill = bills[index];
      final statusColor = _calculateStatusColor(bill.status);
      final isFirstItem = index == 0;
      final billTotal = bill.finalTotal;
      final formattedTotal = NumberFormat.currency(
        locale: 'id_ID',
        symbol: '',
        decimalDigits: 0,
      ).format(billTotal);
      final textColor =
          statusColor == theme.colorScheme.primary
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.error;
      final bool isActive = bill.billId == activeBillId;
      return AppMaterial(
        borderRadius: BorderRadius.circular(0),
        onTap: () {
          // Get the FULL BillModel from state using billId from BillItem
          final fullBillModel = ref
              .read(billProvider)
              .bills
              .firstWhereOrNull((model) => model.billId == bill.billId);

          if (fullBillModel == null) {
            // If for some reason the complete bill is not found, do nothing.
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: Could not find bill details.')),
            );
            return;
          }

          // Check the status of the complete bill that we found
          if (fullBillModel.states.toLowerCase() == 'closed') {
            // Logic for closed bill
            ref.read(billProvider.notifier).selectBill(fullBillModel);
            ref.read(cartProvider.notifier).loadCartFromBill(fullBillModel);

            // <-- MULAI PERUBAHAN DI SINI UNTUK BILL CLOSED
            // Memuat kembali diskon yang tersimpan di bill
            if (fullBillModel.discountList != null &&
                fullBillModel.discountList!.isNotEmpty) {
              try {
                final List<dynamic> decodedList = jsonDecode(
                  fullBillModel.discountList!,
                );
                final List<DiscountModel> appliedDiscounts =
                    decodedList
                        .map(
                          (item) => DiscountModel.fromJson(
                            item as Map<String, dynamic>,
                          ),
                        )
                        .toList();

                final subtotal = ref.read(cartProvider).subtotal;
                ref
                    .read(checkoutDiscountProvider.notifier)
                    .applyDiscounts(appliedDiscounts, subtotal);
              } catch (e) {
                // Jika gagal parse JSON, bersihkan provider diskon
                ref.read(checkoutDiscountProvider.notifier).clearDiscounts();
              }
            } else {
              // Jika bill tidak punya diskon, pastikan provider bersih
              ref.read(checkoutDiscountProvider.notifier).clearDiscounts();
            }
            // <-- AKHIR PERUBAHAN

            ref
                .read(mainBillProvider.notifier)
                .setMainBill(MainBillComponent.billsComponent);
          } else {
            // Logic for open bill

            // <-- TAMBAHKAN INI UNTUK BILL OPEN
            // Bersihkan diskon dari bill sebelumnya sebelum memuat bill baru
            ref.read(checkoutDiscountProvider.notifier).clearDiscounts();

            ref
                .read(billProvider.notifier)
                .loadBillIntoCart(
                  fullBillModel.billId,
                  ref.read(cartProvider.notifier),
                  ref.read(knownIndividualProvider.notifier),
                  ref.read(customerTypeProvider.notifier),
                );
            ref
                .read(mainBillProvider.notifier)
                .setMainBill(MainBillComponent.billsComponent);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color:
                isActive
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surface,
            border: Border(
              top:
                  isFirstItem
                      ? BorderSide.none
                      : BorderSide(color: theme.colorScheme.surfaceContainer),
            ),
          ),
          child: Row(
            children: [
              Expanded(flex: 4, child: Text(bill.name)),
              Expanded(
                flex: 3,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formattedTotal,
                    style: theme.textTheme.labelLarge,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Status indicator
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    bill.status,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
