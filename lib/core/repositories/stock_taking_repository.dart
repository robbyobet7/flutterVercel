import 'package:rebill_flutter/features/stock-taking/models/stock_taking.dart';

class StockTakingRepository {
  List<StockTaking> _stockTakings = [];
  bool _isInitialized = false;

  // Singleton pattern
  StockTakingRepository._();
  static final StockTakingRepository _instance = StockTakingRepository._();
  static StockTakingRepository get instance => _instance;

  void setStockTakings(List<StockTaking> stockTakings) {
    _stockTakings = stockTakings;
    _isInitialized = true;
  }

  bool get isInitialized => _isInitialized;

  List<StockTaking> getAllStockTakings() {
    if (!_isInitialized) {
      throw Exception('Stock taking repository not initialized');
    }
    return _stockTakings;
  }
}
