import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/middleware/stock_taking_middleware.dart';
import 'package:rebill_flutter/features/stock-taking/models/stock_taking.dart';

// ==================== Stock Taking State ====================

class StockTakingState {
  final List<StockTaking> stockTakings;
  final bool isLoading;
  final String? error;

  StockTakingState({
    required this.stockTakings,
    this.isLoading = false,
    this.error,
  });

  StockTakingState copyWith({
    List<StockTaking>? stockTakings,
    bool? isLoading,
    String? error,
  }) {
    return StockTakingState(
      stockTakings: stockTakings ?? this.stockTakings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ==================== Stock Taking Notifier ====================

class StockTakingNotifier extends StateNotifier<StockTakingState> {
  StockTakingNotifier() : super(StockTakingState(stockTakings: []));

  // Load all stock takings
  Future<void> loadStockTakings() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final stockTakings = StockTakingMiddleware.instance.getAllStockTakings();
      state = state.copyWith(stockTakings: stockTakings, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load stock takings: $e',
      );
    }
  }
}

// ==================== Providers ====================

final stockTakingNotifierProvider =
    StateNotifierProvider<StockTakingNotifier, StockTakingState>((ref) {
      return StockTakingNotifier();
    });

// Provider to get submitted kitchen orders
final productStockProvider = Provider<List<StockTaking>>((ref) {
  final allStockTakings = ref.watch(stockTakingsProvider);
  return allStockTakings
      .where((stockTaking) => stockTaking.type == StockTakingType.product)
      .toList();
});

final ingredientsProvider = Provider<List<StockTaking>>((ref) {
  final allStockTakings = ref.watch(stockTakingsProvider);
  return allStockTakings
      .where(
        (stockTaking) =>
            stockTaking.type != StockTakingType.product &&
            stockTaking.type != StockTakingType.prep,
      )
      .toList();
});

final prepsProvider = Provider<List<StockTaking>>((ref) {
  final allStockTakings = ref.watch(stockTakingsProvider);
  return allStockTakings
      .where((stockTaking) => stockTaking.type == StockTakingType.prep)
      .toList();
});

final stockTakingsProvider = Provider<List<StockTaking>>((ref) {
  try {
    return StockTakingMiddleware.instance.getAllStockTakings();
  } catch (e) {
    return [];
  }
});

final stockTakingsLoadingProvider = StateProvider<bool>((ref) => false);

// ==================== Helper Functions ====================

Future<void> initializeStockTakings() async {
  if (!StockTakingMiddleware.instance.isInitialized) {
    await StockTakingMiddleware.instance.loadStockTakings();
  }
}

Future<void> reloadStockTakings(WidgetRef ref) async {
  ref.read(stockTakingsLoadingProvider.notifier).state = true;
  await StockTakingMiddleware.instance.reloadStockTakings();
  ref.read(stockTakingsLoadingProvider.notifier).state = false;

  // Also reload the notifier state
  await ref.read(stockTakingNotifierProvider.notifier).loadStockTakings();
}
