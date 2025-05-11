import 'dart:async';
import 'package:rebill_flutter/core/repositories/table_bill_repository.dart';

import '../models/bill.dart';

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
      await _repository.initialize();
      refreshBills();
    } catch (e) {
      _billErrorController.add('Failed to initialize bill data: $e');
    }
  }

  // Load and broadcast all bills
  Future<void> refreshBills() async {
    try {
      final bills = await _repository.getAllBills();
      _billStreamController.add(bills);
    } catch (e) {
      _billErrorController.add('Failed to load bills: $e');
    }
  }

  // Dispose resources
  void dispose() {
    _billStreamController.close();
    _billErrorController.close();
  }
}
