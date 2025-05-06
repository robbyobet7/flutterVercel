import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/models/bill.dart';
import 'package:rebill_flutter/core/providers/bill_provider.dart';
import 'package:rebill_flutter/core/widgets/app_popup_menu.dart';

enum BillFilterType {
  all('All Bills'),
  open('Open Bills'),
  closed('Closed Bills');

  final String label;
  const BillFilterType(this.label);
}

/// A state provider to keep track of the currently selected filter
final selectedBillFilterProvider = StateProvider<BillFilterType>((ref) {
  return BillFilterType.all;
});

/// A reusable dropdown for filtering bills by their status.
/// This component can be used across different pages for consistency.
class BillFilterDropdown extends ConsumerWidget {
  /// Optional callback to be triggered when a filter is selected
  final Function(BillFilterType)? onFilterSelected;

  /// Optional decoration to customize the appearance
  final BoxDecoration? decoration;

  /// Optional height for the dropdown button
  final double height;

  const BillFilterDropdown({
    Key? key,
    this.onFilterSelected,
    this.decoration,
    this.height = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedFilter = ref.watch(selectedBillFilterProvider);
    final billNotifier = ref.read(billProvider.notifier);

    // Get bill counts
    final billState = ref.watch(billProvider);
    final allBillsCount = billState.bills.length;
    final openBillsCount = billState.openBills.length;
    final closedBillsCount = billState.closedBills.length;

    return AppPopupMenu<BillFilterType>(
      items:
          BillFilterType.values
              .map(
                (filter) => AppPopupMenuItem<BillFilterType>(
                  value: filter,
                  text: _getLabelWithCount(
                    filter,
                    allBillsCount,
                    openBillsCount,
                    closedBillsCount,
                  ),
                  textColor:
                      filter == selectedFilter
                          ? theme.colorScheme.primary
                          : null,
                ),
              )
              .toList(),
      onSelected: (BillFilterType filter) {
        // Update the selected filter
        ref.read(selectedBillFilterProvider.notifier).state = filter;

        // Apply the appropriate filter using our bill provider
        switch (filter) {
          case BillFilterType.all:
            billNotifier.resetFilters();
            break;
          case BillFilterType.open:
            billNotifier.filterByStatus('open');
            break;
          case BillFilterType.closed:
            billNotifier.filterByStatus('closed');
            break;
        }

        // Call the optional callback if provided
        if (onFilterSelected != null) {
          onFilterSelected!(filter);
        }
      },
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration:
            decoration ??
            BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border.all(color: theme.colorScheme.surfaceContainer),
              borderRadius: BorderRadius.circular(6),
            ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      _getLabelWithCount(
                        selectedFilter,
                        allBillsCount,
                        openBillsCount,
                        closedBillsCount,
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.expand_more,
              size: 18,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get the label with the count
  String _getLabelWithCount(
    BillFilterType filter,
    int allBillsCount,
    int openBillsCount,
    int closedBillsCount,
  ) {
    switch (filter) {
      case BillFilterType.all:
        return '${filter.label} ($allBillsCount)';
      case BillFilterType.open:
        return '${filter.label} ($openBillsCount)';
      case BillFilterType.closed:
        return '${filter.label} ($closedBillsCount)';
    }
  }
}

/// Dropdown for customer selection and viewing their bills
class CustomerBillsDropdown extends ConsumerWidget {
  /// Optional callback to be triggered when a customer is selected
  final Function(String)? onCustomerSelected;

  /// Optional decoration to customize the appearance
  final BoxDecoration? decoration;

  /// Optional height for the dropdown button
  final double height;

  const CustomerBillsDropdown({
    Key? key,
    this.onCustomerSelected,
    this.decoration,
    this.height = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final billState = ref.watch(billProvider);
    final billNotifier = ref.read(billProvider.notifier);

    // Get unique customer names from bills
    final customers = _getUniqueCustomers(billState.bills);

    // Selected customer or default text
    final selectedCustomer = billState.searchQuery ?? 'Select Customer';

    return AppPopupMenu<String>(
      items: [
        // Add an "All Customers" option
        AppPopupMenuItem<String>(
          value: '',
          text: 'All Customers',
          textColor:
              selectedCustomer.isEmpty ? theme.colorScheme.primary : null,
        ),
        // Add all customer options
        ...customers.map(
          (customer) => AppPopupMenuItem<String>(
            value: customer,
            text: customer,
            textColor:
                customer == selectedCustomer ? theme.colorScheme.primary : null,
          ),
        ),
      ],
      onSelected: (String customer) {
        if (customer.isEmpty) {
          // Reset to all bills if empty customer selected
          billNotifier.resetSearch();
        } else {
          // Filter by selected customer
          billNotifier.getBillsByCustomer(customer);
        }

        // Call the optional callback if provided
        if (onCustomerSelected != null) {
          onCustomerSelected!(customer);
        }
      },
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration:
            decoration ??
            BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border.all(color: theme.colorScheme.surfaceContainer),
              borderRadius: BorderRadius.circular(6),
            ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      selectedCustomer.isEmpty
                          ? 'All Customers'
                          : selectedCustomer,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.expand_more,
              size: 18,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get unique customer names
  List<String> _getUniqueCustomers(List<BillModel> bills) {
    final customers = <String>{};
    for (final bill in bills) {
      if (bill.customerName.isNotEmpty && bill.customerName != 'Guest') {
        customers.add(bill.customerName);
      }
    }
    return customers.toList()..sort();
  }
}
