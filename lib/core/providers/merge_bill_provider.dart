import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/middleware/merge_bill_middleware.dart';
import 'package:rebill_flutter/core/models/bill.dart';
import 'package:rebill_flutter/core/providers/cart_provider.dart';
import 'package:rebill_flutter/core/utils/extensions.dart';
import 'package:rebill_flutter/features/main-bill/constants/bill_constants.dart';
import 'package:rebill_flutter/features/main-bill/providers/main_bill_provider.dart';

class MergeBillState {
  final List<BillModel> bills;
  final BillModel? selectedBill;
  final bool isLoading;
  final String? error;
  final String? searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? filterStatus;

  const MergeBillState({
    this.bills = const [],
    this.selectedBill,
    this.isLoading = false,
    this.error,
    this.searchQuery,
    this.startDate,
    this.endDate,
    this.filterStatus,
  });

  MergeBillState copyWith({
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
    return MergeBillState(
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

class MergeBillNotifier extends StateNotifier<MergeBillState> {
  final MergeBillMiddleware _mergeBillMiddleware;

  MergeBillNotifier(this._mergeBillMiddleware) : super(const MergeBillState()) {
    // Set up listeners for the middleware streams
    _mergeBillMiddleware.billsStream.listen((bills) {
      state = state.copyWith(bills: bills, isLoading: false);
    });

    _mergeBillMiddleware.errorStream.listen((errorMessage) {
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
      await _mergeBillMiddleware.initialize();
      await _mergeBillMiddleware.refreshBills();
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
      final filteredBills = await _mergeBillMiddleware.getBillsByStatus(status);
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
    WidgetRef? ref,
  ) async {
    final bill = await _mergeBillMiddleware.getBill(billId);
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

final mergeBillMiddlewareProvider = Provider<MergeBillMiddleware>((ref) {
  return MergeBillMiddleware();
});

// Provider for the bill state
final mergeBillProvider =
    StateNotifierProvider<MergeBillNotifier, MergeBillState>((ref) {
      final mergeBillMiddleware = ref.read(mergeBillMiddlewareProvider);
      return MergeBillNotifier(mergeBillMiddleware);
    });

// Provider for open bills
final openBillsProvider = Provider<List<BillModel>>((ref) {
  return ref.watch(mergeBillProvider).openBills;
});

// Provider for closed bills
final closedBillsProvider = Provider<List<BillModel>>((ref) {
  return ref.watch(mergeBillProvider).closedBills;
});

// Provider for selected bill
final selectedMergeBillProvider = Provider<BillModel?>((ref) {
  return ref.watch(mergeBillProvider).selectedBill;
});

// Provider for loading state
final mergeBillLoadingProvider = Provider<bool>((ref) {
  return ref.watch(mergeBillProvider).isLoading;
});
