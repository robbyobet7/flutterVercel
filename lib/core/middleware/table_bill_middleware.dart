import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import '../models/bill.dart';

class TableBillMiddleware {
  List<BillModel> _bills = [];
  bool _isInitialized = false;

  // Stream controllers for bill events
  final _billStreamController = StreamController<List<BillModel>>.broadcast();
  final _billErrorController = StreamController<String>.broadcast();

  // Streams that components can listen to
  Stream<List<BillModel>> get billsStream => _billStreamController.stream;
  Stream<String> get errorStream => _billErrorController.stream;

  // Singleton instance
  static final TableBillMiddleware _instance = TableBillMiddleware._internal();

  // Factory constructor
  factory TableBillMiddleware() {
    return _instance;
  }

  // Private constructor
  TableBillMiddleware._internal();

  // Set bills data (called from middleware)
  void setBills(List<BillModel> bills) {
    _bills = bills;
    _isInitialized = true;
  }

  // Get all bills
  List<BillModel> getAllBills() {
    if (!_isInitialized) {
      throw Exception('TableBill repository not initialized');
    }
    return _bills;
  }

  // Initialize the middleware
  Future<void> initialize() async {
    try {
      if (!_isInitialized) {
        await _loadBillsFromJson();
      }
      refreshBills();
    } catch (e) {
      _billErrorController.add('Failed to initialize table bill data: $e');
    }
  }

  // Load bills from JSON
  Future<void> _loadBillsFromJson() async {
    try {
      final jsonString = await rootBundle.loadString('assets/tableBills.json');
      final bills = BillModel.parseBills(jsonString);
      setBills(bills);
    } catch (e) {
      _billErrorController.add('Failed to load table bills from JSON: $e');
    }
  }

  // Load and broadcast all bills
  Future<void> refreshBills() async {
    try {
      final bills = getAllBills();
      _billStreamController.add(bills);
    } catch (e) {
      _billErrorController.add('Failed to load table bills: $e');
    }
  }

  // Get a bill by ID
  Future<BillModel?> getBillById(int id) async {
    try {
      return _bills.firstWhere((bill) => bill.billId == id);
    } catch (e) {
      _billErrorController.add('Failed to get table bill with ID $id: $e');
      return null;
    }
  }

  // Get bills by table ID
  Future<List<BillModel>> getBillsByTableId(int tableId) async {
    try {
      return _bills.where((bill) => bill.tableId == tableId).toList();
    } catch (e) {
      _billErrorController.add('Failed to get bills for table ID $tableId: $e');
      return [];
    }
  }

  // Get bills for serialization

  // Dispose resources
  void dispose() {
    _billStreamController.close();
    _billErrorController.close();
  }
}
