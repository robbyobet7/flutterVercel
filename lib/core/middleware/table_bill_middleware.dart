import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import '../models/bill.dart';
import '../repositories/table_bill_repository.dart';

class TableBillMiddleware {
  final TableBillRepository _repository;

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
  TableBillMiddleware._internal() : _repository = TableBillRepository.instance;

  // Initialize the middleware
  Future<void> initialize() async {
    try {
      if (!_repository.isInitialized) {
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
      _repository.setBills(bills);
    } catch (e) {
      _billErrorController.add('Failed to load table bills from JSON: $e');
    }
  }

  // Load and broadcast all bills
  Future<void> refreshBills() async {
    try {
      final bills = _repository.getAllBills();
      _billStreamController.add(bills);
    } catch (e) {
      _billErrorController.add('Failed to load table bills: $e');
    }
  }

  // Get a bill by ID
  Future<BillModel?> getBillById(int id) async {
    try {
      return _repository.getBillById(id);
    } catch (e) {
      _billErrorController.add('Failed to get table bill with ID $id: $e');
      return null;
    }
  }

  // Get bills by table ID
  Future<List<BillModel>> getBillsByTableId(int tableId) async {
    try {
      return _repository.getBillsByTableId(tableId);
    } catch (e) {
      _billErrorController.add('Failed to get bills for table ID $tableId: $e');
      return [];
    }
  }

  // Dispose resources
  void dispose() {
    _billStreamController.close();
    _billErrorController.close();
  }
}
