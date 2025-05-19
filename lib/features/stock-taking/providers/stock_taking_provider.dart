import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/repositories/stock_taking_repository.dart';
import 'package:rebill_flutter/features/stock-taking/models/stock_taking.dart';

class StockTakingState {
  final List<List<StockTaking>> stockTakings;
  final bool isLoading;
  final String? error;

  const StockTakingState({
    this.stockTakings = const [],
    this.isLoading = false,
    this.error,
  });

  StockTakingState copyWith({
    List<List<StockTaking>>? stockTakings,
    bool? isLoading,
    String? error,
  }) {
    return StockTakingState(
      stockTakings: stockTakings ?? this.stockTakings,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

final stockTakingRepositoryProvider = Provider<StockTakingRepository>((ref) {
  return StockTakingRepository();
});

class StockTakingNotifier extends StateNotifier<StockTakingState> {
  final StockTakingRepository _repository;

  StockTakingNotifier(this._repository) : super(const StockTakingState());

  Future<void> fetchStockTakings() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final stockTakings = await _repository.getStockTakings();
      state = state.copyWith(stockTakings: stockTakings, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  final stockTakingProvider =
      StateNotifierProvider<StockTakingNotifier, StockTakingState>((ref) {
        final repository = ref.watch(stockTakingRepositoryProvider);
        return StockTakingNotifier(repository);
      });
}
