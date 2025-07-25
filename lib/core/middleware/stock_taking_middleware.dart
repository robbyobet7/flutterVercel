import 'package:flutter/services.dart';
import 'package:rebill_flutter/features/stock-taking/models/stock_taking.dart';

class StockTakingMiddleware {
  List<StockTaking> _stockTakings = [];
  // Singleton pattern
  StockTakingMiddleware._();
  static final StockTakingMiddleware _instance = StockTakingMiddleware._();
  static StockTakingMiddleware get instance => _instance;

  void setStockTakings(List<StockTaking> stockTakings) {
    _stockTakings = stockTakings;
    _isInitialized = true;
  }

  // Flag to track initialization status
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Get all stock takings
  List<StockTaking> getAllStockTakings() {
    if (!_isInitialized) {
      throw Exception('Stock taking middleware not initialized');
    }
    return _stockTakings;
  }

  Future<void> loadStockTakings() async {
    if (_isInitialized) return;

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/stocks.json',
      );

      final List<StockTaking> stockTakings = StockTaking.parseStockTakings(
        jsonString,
      );

      StockTakingMiddleware.instance.setStockTakings(stockTakings);

      _isInitialized = true;
    } catch (e) {
      // Initialize with empty list in case of error
      StockTakingMiddleware.instance.setStockTakings([]);
    }
  }

  // Method to reload stock takings (for refreshing data)
  Future<void> reloadStockTakings() async {
    _isInitialized = false;
    await loadStockTakings();
  }
}
