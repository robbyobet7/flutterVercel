import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/models/bill.dart';
import 'package:rebill_flutter/core/providers/cart_provider.dart';
import 'package:rebill_flutter/core/services/table_bill_service.dart';
import 'package:rebill_flutter/core/utils/extensions.dart';
import 'package:rebill_flutter/features/main_bill/constants/bill_constants.dart';
import 'package:rebill_flutter/features/main_bill/providers/main_bill_provider.dart';

class TableBillState {
  final List<BillModel> bills;
  final BillModel? selectedBill;
  final bool isLoading;
  final String? error;
  final String? searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? filterStatus;

  const TableBillState({
    this.bills = const [],
    this.selectedBill,
    this.isLoading = false,
    this.error,
    this.searchQuery,
    this.startDate,
    this.endDate,
    this.filterStatus,
  });

  TableBillState copyWith({
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
    return TableBillState(
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

class TableBillNotifier extends StateNotifier<TableBillState> {
  final TableBillService _tableBillService;

  TableBillNotifier(this._tableBillService) : super(const TableBillState());

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

  // Load bills from asset file
  Future<void> loadBills() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final bills = await _tableBillService.loadBills();
      state = state.copyWith(bills: bills, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load bills: $e',
      );
    }
  }

  // Load a bill into the cart
  Future<void> loadBillIntoCart(
    int billId,
    CartNotifier cartNotifier,
    KnownIndividualNotifier knownIndividualNotifier,
    CustomerTypeNotifier customerTypeNotifier,
  ) async {
    final bill = _tableBillService.getBillById(state.bills, billId);
    if (bill != null) {
      state = state.copyWith(selectedBill: bill);
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

// Provider for the TableBillService
final tableBillServiceProvider = Provider<TableBillService>((ref) {
  return TableBillService();
});

// Provider for the bill state
final tableBillProvider =
    StateNotifierProvider<TableBillNotifier, TableBillState>((ref) {
      final tableBillService = ref.read(tableBillServiceProvider);
      return TableBillNotifier(tableBillService);
    });
