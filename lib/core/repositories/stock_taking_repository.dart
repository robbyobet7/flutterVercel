import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:rebill_flutter/features/stock-taking/models/stock_taking.dart';

class StockTakingRepository {
  Future<List<List<StockTaking>>> getStockTakings() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/stocks.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);

      List<List<StockTaking>> result = [];

      for (var group in jsonData) {
        List<StockTaking> groupStockTakings = [];
        for (var item in group) {
          groupStockTakings.add(StockTaking.fromJson(item));
        }
        result.add(groupStockTakings);
      }

      return result;
    } catch (e) {
      print('Error loading stock takings: $e');
      return [];
    }
  }
}
