import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/models/bill.dart';

// State class for the bill loader
class BillLoaderState {
  final List<BillModel> availableBills;
  final BillModel? selectedBill;
  final bool isLoading;
  final String? error;

  BillLoaderState({
    this.availableBills = const [],
    this.selectedBill,
    this.isLoading = false,
    this.error,
  });

  BillLoaderState copyWith({
    List<BillModel>? availableBills,
    BillModel? selectedBill,
    bool? isLoading,
    String? error,
    bool clearSelectedBill = false,
    bool clearError = false,
  }) {
    return BillLoaderState(
      availableBills: availableBills ?? this.availableBills,
      selectedBill:
          clearSelectedBill ? null : selectedBill ?? this.selectedBill,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

// Notifier class for bill loading operations
class BillLoaderNotifier extends StateNotifier<BillLoaderState> {
  BillLoaderNotifier() : super(BillLoaderState());

  // Load bills from the assets file
  Future<void> loadBillsFromAsset() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final bills = await BillModel.loadBillsFromAsset('assets/bills.json');
      state = state.copyWith(availableBills: bills, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load bills: ${e.toString()}',
      );
    }
  }

  // Select a bill by its ID
  void selectBill(int billId) {
    final bill = state.availableBills.firstWhere(
      (bill) => bill.billId == billId,
      orElse: () => throw Exception('Bill not found with ID: $billId'),
    );

    state = state.copyWith(selectedBill: bill);
  }

  // Clear the selected bill
  void clearSelectedBill() {
    state = state.copyWith(clearSelectedBill: true);
  }
}

// Provider for the bill loader
final billLoaderProvider =
    StateNotifierProvider<BillLoaderNotifier, BillLoaderState>((ref) {
      return BillLoaderNotifier();
    });

// Provider for the available bills list
final availableBillsProvider = Provider<List<BillModel>>((ref) {
  return ref.watch(billLoaderProvider).availableBills;
});

// Provider for the selected bill
final selectedBillProvider = Provider<BillModel?>((ref) {
  return ref.watch(billLoaderProvider).selectedBill;
});

// Provider to check if bills are loading
final billsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(billLoaderProvider).isLoading;
});

// Provider for any bill loading errors
final billLoadingErrorProvider = Provider<String?>((ref) {
  return ref.watch(billLoaderProvider).error;
});
