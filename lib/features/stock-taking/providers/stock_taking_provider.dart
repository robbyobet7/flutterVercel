import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/repositories/stock_taking_repository.dart';
import 'package:rebill_flutter/features/stock-taking/models/stock_taking.dart';

class StockTakingState {
  final List<StockTaking> stockTakings;
  final List<StockTaking> productStockTakings;
  final List<StockTaking> ingredientStockTakings;
  final List<StockTaking> prepStockTakings;
  final bool isLoading;
  final String? error;

  const StockTakingState({
    this.stockTakings = const [],
    this.productStockTakings = const [],
    this.ingredientStockTakings = const [],
    this.prepStockTakings = const [],
    this.isLoading = false,
    this.error,
  });

  StockTakingState copyWith({
    List<StockTaking>? stockTakings,
    List<StockTaking>? productStockTakings,
    List<StockTaking>? ingredientStockTakings,
    List<StockTaking>? prepStockTakings,
    bool? isLoading,
    String? error,
  }) {
    return StockTakingState(
      stockTakings: stockTakings ?? this.stockTakings,
      productStockTakings: productStockTakings ?? this.productStockTakings,
      ingredientStockTakings:
          ingredientStockTakings ?? this.ingredientStockTakings,
      prepStockTakings: prepStockTakings ?? this.prepStockTakings,
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

  StockTakingNotifier(this._repository) : super(const StockTakingState()) {
    fetchStockTakings();
  }

  Future fetchStockTakings() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final stockTakings = await _repository.getStockTakings();

      // Pre-filter data for better performance
      final productStockTakings =
          stockTakings.where((e) => e.type == StockTakingType.product).toList();

      final prepStockTakings =
          stockTakings.where((e) => e.type == StockTakingType.prep).toList();

      final ingredientStockTakings =
          stockTakings
              .where(
                (e) =>
                    e.type != StockTakingType.product &&
                    e.type != StockTakingType.prep,
              )
              .toList();

      state = state.copyWith(
        stockTakings: stockTakings,
        productStockTakings: productStockTakings,
        ingredientStockTakings: ingredientStockTakings,
        prepStockTakings: prepStockTakings,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final stockTakingProvider =
    StateNotifierProvider<StockTakingNotifier, StockTakingState>((ref) {
      final repository = ref.watch(stockTakingRepositoryProvider);
      return StockTakingNotifier(repository);
    });

// These providers now just return pre-filtered data, avoiding repetitive filtering
final prepStockTakingProvider = Provider<List<StockTaking>>((ref) {
  return ref.watch(stockTakingProvider).prepStockTakings;
});

final productStockTakingProvider = Provider<List<StockTaking>>((ref) {
  return ref.watch(stockTakingProvider).productStockTakings;
});

final ingredientStockTakingProvider = Provider<List<StockTaking>>((ref) {
  return ref.watch(stockTakingProvider).ingredientStockTakings;
});
