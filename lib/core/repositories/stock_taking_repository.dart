import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:rebill_flutter/features/stock-taking/models/stock_taking.dart';

class StockTakingRepository {
  Future<List<StockTaking>> getStockTakings() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/stocks.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Get the dataProducts array from the JSON
      final List<dynamic> productsData =
          jsonData['dataProducts'] as List<dynamic>;

      // Convert the data to StockTaking objects
      final List<StockTaking> stockTakings =
          productsData.map((item) => StockTaking.fromJson(item)).toList();

      return stockTakings;
    } catch (e) {
      print('Error loading stock takings: $e');
      return [];
    }
  }
}
