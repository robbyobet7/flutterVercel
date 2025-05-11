import 'package:flutter/services.dart' show rootBundle;
import '../models/bill.dart';

class TableBillRepository {
  // In-memory cache of bills
  List<BillModel> _bills = [];
  bool _isInitialized = false;

  // Singleton pattern
  TableBillRepository._();
  static final TableBillRepository _instance = TableBillRepository._();
  static TableBillRepository get instance => _instance;

  // Initialize the repository with data from the JSON file
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final jsonString = await rootBundle.loadString('assets/bills.json');
      _bills = BillModel.parseBills(jsonString);
      _isInitialized = true;
    } catch (e) {
      _bills = [];
    }
  }

  // Get all bills
  Future<List<BillModel>> getAllBills() async {
    if (!_isInitialized) await initialize();
    return _bills;
  }

  // Delete a bill
  Future<void> deleteBill(int id) async {
    if (!_isInitialized) await initialize();

    final index = _bills.indexWhere((b) => b.billId == id);
    if (index == -1) {
      throw Exception('Bill not found with ID: $id');
    }

    _bills.removeAt(index);
  }
}
