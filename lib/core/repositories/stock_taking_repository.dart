import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:rebill_flutter/features/stock-taking/models/stock_taking.dart';

class StockTakingRepository {
  List<StockTaking>? _cachedStockTakings;

  Future<List<StockTaking>> getStockTakings() async {
    // Return cached data if available
    if (_cachedStockTakings != null) {
      return _cachedStockTakings!;
    }

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/stocks.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Get the dataProducts array from the JSON
      final List<dynamic> productsData =
          jsonData['dataProducts'] as List<dynamic>;

      // Convert the data to StockTaking objects
      _cachedStockTakings =
          productsData.map((item) => StockTaking.fromJson(item)).toList();

      return _cachedStockTakings!;
    } catch (e) {
      print('Error loading stock takings: $e');
      return [];
    }
  }

  // Method to clear cache if needed
  void clearCache() {
    _cachedStockTakings = null;
  }
}
