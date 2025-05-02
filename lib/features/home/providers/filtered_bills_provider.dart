import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bill_day.dart';
import 'bill_search_provider.dart';
import 'selected_user_bill_provider.dart';

/// Provider that combines search query and selected user to filter bills
/// This makes the filtering reactive to both inputs
final filteredBillsProvider = Provider<List<BillDay>>((ref) {
  final searchQuery = ref.watch(billSearchProvider);
  final selectedUser = ref.watch(selectedUserBillProvider);

  final dummyBillData = BillDay.dummyBillData;

  // First filter by user if needed (for specific implementations)
  // For now, we're just demonstrating the pattern
  var userFilteredBills = dummyBillData;

  // If user is "All Bills", no filtering needed
  if (selectedUser.id != "5") {
    // Here we could add user-specific filtering logic
    // For example, filtering bills that belong to the selected user
  }

  // Then filter by search query
  if (searchQuery.isEmpty) {
    return userFilteredBills;
  }

  final query = searchQuery.toLowerCase();

  return userFilteredBills
      .map((billDay) {
        // Filter bills within each day
        final filteredBills =
            billDay.bills.where((bill) {
              return bill.name.toLowerCase().contains(query) ||
                  bill.total.contains(query) ||
                  bill.status.toLowerCase().contains(query);
            }).toList();

        // Return a new BillDay with filtered bills
        return BillDay(date: billDay.date, bills: filteredBills);
      })
      .where((billDay) => billDay.bills.isNotEmpty)
      .toList();
});
