import 'package:flutter/services.dart';
import 'package:rebill_flutter/core/repositories/stock_taking_repository.dart';
import 'package:rebill_flutter/features/stock-taking/models/stock_taking.dart';

class StockTakingMiddleware {
  // Singleton pattern
  StockTakingMiddleware._();
  static final StockTakingMiddleware _instance = StockTakingMiddleware._();
  static StockTakingMiddleware get instance => _instance;

  // Flag to track initialization status
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> loadStockTakings() async {
    if (_isInitialized) return;

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/stocks.json',
      );

      final List<StockTaking> stockTakings = StockTaking.parseStockTakings(
        jsonString,
      );

      StockTakingRepository.instance.setStockTakings(stockTakings);

      _isInitialized = true;
    } catch (e) {
      // Initialize with empty list in case of error
      StockTakingRepository.instance.setStockTakings([]);
    }
  }

  // Method to reload stock takings (for refreshing data)
  Future<void> reloadStockTakings() async {
    _isInitialized = false;
    await loadStockTakings();
  }
}
