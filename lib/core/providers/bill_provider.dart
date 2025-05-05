import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/models/bill.dart';
import 'package:rebill_flutter/core/models/bill_details.dart';
import 'package:rebill_flutter/core/providers/cart_provider.dart';
import 'package:rebill_flutter/core/services/bill_service.dart';

class BillState {
  final List<BillModel> bills;
  final BillModel? selectedBill;
  final bool isLoading;
  final String? error;
  final String? searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? filterStatus;

  const BillState({
    this.bills = const [],
    this.selectedBill,
    this.isLoading = false,
    this.error,
    this.searchQuery,
    this.startDate,
    this.endDate,
    this.filterStatus,
  });

  BillState copyWith({
    List<BillModel>? bills,
    BillModel? selectedBill,
    bool? isLoading,
    String? error,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    String? filterStatus,
    bool clearSelectedBill = false,
    bool clearSearch = false,
    bool clearDateRange = false,
    bool clearFilterStatus = false,
  }) {
    return BillState(
      bills: bills ?? this.bills,
      selectedBill:
          clearSelectedBill ? null : selectedBill ?? this.selectedBill,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: clearSearch ? null : searchQuery ?? this.searchQuery,
      startDate: clearDateRange ? null : startDate ?? this.startDate,
      endDate: clearDateRange ? null : endDate ?? this.endDate,
      filterStatus:
          clearFilterStatus ? null : filterStatus ?? this.filterStatus,
    );
  }

  // Get open bills
  List<BillModel> get openBills =>
      bills.where((bill) => bill.states == 'open').toList();

  // Get closed bills
  List<BillModel> get closedBills =>
      bills.where((bill) => bill.states == 'closed').toList();

  // Get refunded bills
  List<BillModel> get refundedBills =>
      bills.where((bill) => bill.isRefunded).toList();
}

class BillNotifier extends StateNotifier<BillState> {
  final BillService _billService;

  BillNotifier(this._billService) : super(const BillState());

  // Load bills from asset file
  Future<void> loadBills() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final bills = await _billService.loadBills();
      state = state.copyWith(bills: bills, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load bills: $e',
      );
    }
  }

  // Select a bill
  void selectBill(BillModel bill) {
    state = state.copyWith(selectedBill: bill);
  }

  // Clear selected bill
  void clearSelectedBill() {
    state = state.copyWith(clearSelectedBill: true);
  }

  // Filter bills by status
  void filterByStatus(String status) {
    state = state.copyWith(
      filterStatus: status,
      isLoading: true,
      clearSearch: true,
      clearDateRange: true,
    );

    final filteredBills = _billService.getBillsByStatus(state.bills, status);
    state = state.copyWith(bills: filteredBills, isLoading: false);
  }

  // Filter bills by date range
  void filterByDateRange(DateTime start, DateTime end) {
    state = state.copyWith(
      startDate: start,
      endDate: end,
      isLoading: true,
      clearSearch: true,
      clearFilterStatus: true,
    );

    final filteredBills = _billService.getBillsByDateRange(
      state.bills,
      start,
      end,
    );
    state = state.copyWith(bills: filteredBills, isLoading: false);
  }

  // Search bills
  void searchBills(String query) {
    if (query.isEmpty) {
      resetSearch();
      return;
    }

    state = state.copyWith(searchQuery: query, isLoading: true);

    final searchResults = _billService.searchBills(state.bills, query);
    state = state.copyWith(bills: searchResults, isLoading: false);
  }

  // Reset search
  void resetSearch() {
    state = state.copyWith(clearSearch: true);
    resetFilters();
  }

  // Reset all filters
  Future<void> resetFilters() async {
    state = state.copyWith(
      isLoading: true,
      clearSearch: true,
      clearDateRange: true,
      clearFilterStatus: true,
    );

    await loadBills();
  }

  // Get today's bills
  void getTodaysBills() {
    state = state.copyWith(
      isLoading: true,
      clearSearch: true,
      clearFilterStatus: true,
    );

    final todayBills = _billService.getTodaysBills(state.bills);
    state = state.copyWith(bills: todayBills, isLoading: false);
  }

  // Get bills by customer name
  void getBillsByCustomer(String customerName) {
    state = state.copyWith(isLoading: true, clearFilterStatus: true);

    final customerBills = _billService.getBillsByCustomer(
      state.bills,
      customerName,
    );
    state = state.copyWith(bills: customerBills, isLoading: false);
  }

  // Get bills by payment method
  void getBillsByPaymentMethod(String method) {
    state = state.copyWith(
      isLoading: true,
      clearSearch: true,
      clearFilterStatus: true,
    );

    final methodBills = _billService.getBillsByPaymentMethod(
      state.bills,
      method,
    );
    state = state.copyWith(bills: methodBills, isLoading: false);
  }

  // Get refunded bills
  void getRefundedBills() {
    state = state.copyWith(
      isLoading: true,
      clearSearch: true,
      clearFilterStatus: true,
    );

    final refundedBills = _billService.getRefundedBills(state.bills);
    state = state.copyWith(bills: refundedBills, isLoading: false);
  }

  // Load a bill into the cart
  void loadBillIntoCart(int billId, CartNotifier cartNotifier) {
    final bill = _billService.getBillById(state.bills, billId);
    if (bill != null) {
      bill.loadIntoCart(cartNotifier);
    }
  }

  // Get bill details for today
  BillDetails getTodayDetails() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));

    final todayBills = _billService.getBillsByDateRange(
      state.bills,
      today,
      tomorrow,
    );
    return BillDetails.fromBills(todayBills, date: today);
  }

  // Get bill details for a specific date
  BillDetails getDateDetails(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final nextDay = day.add(Duration(days: 1));

    final dayBills = _billService.getBillsByDateRange(
      state.bills,
      day,
      nextDay,
    );
    return BillDetails.fromBills(dayBills, date: day);
  }

  // Get bill details for a date range
  BillDetails getDateRangeDetails(DateTime start, DateTime end) {
    final rangeBills = _billService.getBillsByDateRange(
      state.bills,
      start,
      end,
    );
    return BillDetails.fromBills(rangeBills, date: start);
  }

  // Get weekly bill details
  BillDetails getWeeklyDetails() {
    final now = DateTime.now();
    final weekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(Duration(days: 6));

    return getDateRangeDetails(weekStart, weekEnd);
  }

  // Get monthly bill details
  BillDetails getMonthlyDetails() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(
      now.year,
      now.month + 1,
      0,
    ); // Last day of current month

    return getDateRangeDetails(monthStart, monthEnd);
  }
}

// Provider for the BillService
final billServiceProvider = Provider<BillService>((ref) {
  return BillService();
});

// Provider for the bill state
final billProvider = StateNotifierProvider<BillNotifier, BillState>((ref) {
  final billService = ref.read(billServiceProvider);
  return BillNotifier(billService);
});

// Provider for all bills
final allBillsProvider = Provider<List<BillsByDate>>((ref) {
  final billState = ref.watch(billProvider);

  // Group bills by date
  final Map<String, List<BillItem>> billsByDate = {};

  for (final bill in billState.bills) {
    // Format date as readable string (e.g., "Monday, Jan 1, 2023")
    final dateKey = bill.createdAt.toString().split(' ')[0];
    final dateString = dateKey;

    // Convert bill to simplified BillItem
    final billItem = BillItem(
      billId: bill.billId.toString(),
      name: bill.customerName,
      total: bill.total.toDouble(),
      status: bill.states,
    );

    // Add debug print to see actual total value
    print(
      '💰 Bill ${bill.billId}: Total type: ${bill.total.runtimeType}, value: ${bill.total}',
    );

    if (billsByDate.containsKey(dateString)) {
      billsByDate[dateString]!.add(billItem);
    } else {
      billsByDate[dateString] = [billItem];
    }
  }

  // Convert map to list and sort by date (most recent first)
  final result =
      billsByDate.entries
          .map((entry) => BillsByDate(date: entry.key, bills: entry.value))
          .toList();

  // Sort by date (most recent first)
  result.sort((a, b) => b.date.compareTo(a.date));

  return result;
});

// Provider for open bills
final openBillsProvider = Provider<List<BillModel>>((ref) {
  return ref.watch(billProvider).openBills;
});

// Provider for closed bills
final closedBillsProvider = Provider<List<BillModel>>((ref) {
  return ref.watch(billProvider).closedBills;
});

// Provider for refunded bills
final refundedBillsProvider = Provider<List<BillModel>>((ref) {
  return ref.watch(billProvider).refundedBills;
});

// Provider for selected bill
final selectedBillProvider = Provider<BillModel?>((ref) {
  return ref.watch(billProvider).selectedBill;
});

// Provider for loading state
final billLoadingProvider = Provider<bool>((ref) {
  return ref.watch(billProvider).isLoading;
});

// Provider for error state
final billErrorProvider = Provider<String?>((ref) {
  return ref.watch(billProvider).error;
});

// Provider for total sales from closed bills
final totalSalesProvider = Provider<double>((ref) {
  final closedBills = ref.watch(closedBillsProvider);
  return closedBills.fold(0.0, (sum, bill) => sum + bill.finalTotal);
});

// Provider for average sale amount
final averageSaleProvider = Provider<double>((ref) {
  final closedBills = ref.watch(closedBillsProvider);
  if (closedBills.isEmpty) return 0;
  final total = closedBills.fold(0.0, (sum, bill) => sum + bill.finalTotal);
  return total / closedBills.length;
});

// Provider for today's bill details
final todayBillDetailsProvider = Provider<BillDetails>((ref) {
  final billNotifier = ref.read(billProvider.notifier);
  return billNotifier.getTodayDetails();
});

// Provider for weekly bill details
final weeklyBillDetailsProvider = Provider<BillDetails>((ref) {
  final billNotifier = ref.read(billProvider.notifier);
  return billNotifier.getWeeklyDetails();
});

// Provider for monthly bill details
final monthlyBillDetailsProvider = Provider<BillDetails>((ref) {
  final billNotifier = ref.read(billProvider.notifier);
  return billNotifier.getMonthlyDetails();
});

// Provider for bill details by date (family provider)
final dateBillDetailsProvider = Provider.family<BillDetails, DateTime>((
  ref,
  date,
) {
  final billNotifier = ref.read(billProvider.notifier);
  return billNotifier.getDateDetails(date);
});

// Provider for bill details by date range (family provider)
final dateRangeBillDetailsProvider =
    Provider.family<BillDetails, (DateTime, DateTime)>((ref, dateRange) {
      final billNotifier = ref.read(billProvider.notifier);
      return billNotifier.getDateRangeDetails(dateRange.$1, dateRange.$2);
    });

// Model to represent bills grouped by date for display
class BillsByDate {
  final String date;
  final List<BillItem> bills;

  BillsByDate({required this.date, required this.bills});
}

// Simple model for bill list item display
class BillItem {
  final String billId;
  final String name;
  final double total;
  final String status;

  BillItem({
    required this.billId,
    required this.name,
    required this.total,
    required this.status,
  });
}
