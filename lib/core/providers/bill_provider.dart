import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/models/bill.dart';
import 'package:rebill_flutter/core/providers/cart_provider.dart';
import 'package:rebill_flutter/core/middleware/bill_middleware.dart';
import 'package:rebill_flutter/core/utils/extensions.dart';
import 'package:rebill_flutter/features/main-bill/constants/bill_constants.dart';
import 'package:rebill_flutter/features/main-bill/providers/main_bill_provider.dart';

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
}

class BillNotifier extends StateNotifier<BillState> {
  final BillMiddleware _billMiddleware;

  BillNotifier(this._billMiddleware) : super(const BillState()) {
    // Set up listeners for the middleware streams
    _billMiddleware.billsStream.listen((bills) {
      state = state.copyWith(bills: bills, isLoading: false);
    });

    _billMiddleware.errorStream.listen((errorMessage) {
      state = state.copyWith(error: errorMessage, isLoading: false);
    });
  }

  String? get createdAt {
    final String? dateTime = state.selectedBill?.posPaidBillDate;
    if (dateTime == null) return null;

    return dateTime.toBillDate();
  }

  String? get billNumber {
    final String? billNumber = state.selectedBill?.cBillId;
    if (billNumber == null) return null;

    return billNumber;
  }

  String? get billStatus {
    final String? status = state.selectedBill?.states;
    if (status == null) return null;

    return status;
  }

  String? get cashier {
    final String? cashier = state.selectedBill?.cashier;
    if (cashier == null) return null;

    return cashier;
  }

  String? get paidAt {
    final String? paidAt = state.selectedBill?.posPaidBillDate;
    if (paidAt == null) return null;

    return paidAt.toBillDate();
  }

  // Load bills from repository via middleware
  Future<void> loadBills() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _billMiddleware.initialize();
      await _billMiddleware.refreshBills();
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
  Future<void> filterByStatus(String status) async {
    state = state.copyWith(
      filterStatus: status,
      isLoading: true,
      clearSearch: true,
      clearDateRange: true,
    );

    try {
      final filteredBills = _billMiddleware.getBillsByStatus(status);
      state = state.copyWith(bills: filteredBills, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to filter bills by status: $e',
      );
    }
  }

  // Search bills
  void searchBills(String query) {
    if (query.isEmpty) {
      resetSearch();
      return;
    }

    state = state.copyWith(searchQuery: query, isLoading: true);

    // Simple search implementation that filters the current state's bills
    final searchResults =
        state.bills.where((bill) {
          final queryLower = query.toLowerCase();
          return bill.cBillId.toLowerCase().contains(queryLower) ||
              bill.customerName.toLowerCase().contains(queryLower);
        }).toList();

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

  // Get bills by customer name
  void getBillsByCustomer(String customerName) {
    state = state.copyWith(isLoading: true, clearFilterStatus: true);

    // Filter the current bills by customer name
    final customerBills =
        state.bills
            .where(
              (bill) => bill.customerName.toLowerCase().contains(
                customerName.toLowerCase(),
              ),
            )
            .toList();

    state = state.copyWith(bills: customerBills, isLoading: false);
  }

  // Load a bill into the cart
  Future<void> loadBillIntoCart(
    int billId,
    CartNotifier cartNotifier,
    KnownIndividualNotifier knownIndividualNotifier,
    CustomerTypeNotifier customerTypeNotifier,
  ) async {
    final bill = _billMiddleware.getBillById(billId);
    if (bill != null) {
      selectBill(bill);
      bill.loadIntoCart(cartNotifier);
      if (bill.customerId != null) {
        final customer = await knownIndividualNotifier.getCustomerById(
          bill.customerId!,
        );
        knownIndividualNotifier.setKnownIndividual(customer);

        customerTypeNotifier.setCustomerType(CustomerType.knownIndividual);
      } else {
        customerTypeNotifier.setCustomerType(CustomerType.guest);
      }
    }
  }
}

final billMiddlewareProvider = Provider<BillMiddleware>((ref) {
  return BillMiddleware();
});

// Provider for the bill state
final billProvider = StateNotifierProvider<BillNotifier, BillState>((ref) {
  final billMiddleware = ref.read(billMiddlewareProvider);
  return BillNotifier(billMiddleware);
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
      billId: bill.billId,
      name: bill.customerName,
      total: bill.total.toDouble(),
      finalTotal: bill.finalTotal,
      status: bill.states,
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

// Provider for selected bill
final selectedBillProvider = Provider<BillModel?>((ref) {
  return ref.watch(billProvider).selectedBill;
});

// Provider for loading state
final billLoadingProvider = Provider<bool>((ref) {
  return ref.watch(billProvider).isLoading;
});

class BillsByDate {
  final String date;
  final List<BillItem> bills;

  BillsByDate({required this.date, required this.bills});
}

// Simple model for bill list item display
class BillItem {
  final int billId;
  final String name;
  final double total;
  final double finalTotal;
  final String status;

  BillItem({
    required this.billId,
    required this.name,
    required this.total,
    required this.finalTotal,
    required this.status,
  });
}
