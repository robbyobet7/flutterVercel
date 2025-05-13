import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import '../models/bill.dart';
import '../repositories/bill_repository.dart';

class BillMiddleware {
  final BillRepository _repository;

  // Stream controllers for bill events
  final _billStreamController = StreamController<List<BillModel>>.broadcast();
  final _billErrorController = StreamController<String>.broadcast();

  // Streams that components can listen to
  Stream<List<BillModel>> get billsStream => _billStreamController.stream;
  Stream<String> get errorStream => _billErrorController.stream;

  // Singleton instance
  static final BillMiddleware _instance = BillMiddleware._internal();

  // Factory constructor
  factory BillMiddleware() {
    return _instance;
  }

  // Private constructor
  BillMiddleware._internal() : _repository = BillRepository.instance;

  // Initialize the middleware
  Future<void> initialize() async {
    try {
      if (!_repository.isInitialized) {
        await _loadBillsFromJson();
      }
      refreshBills();
    } catch (e) {
      _billErrorController.add('Failed to initialize bill data: $e');
    }
  }

  // Load bills from JSON
  Future<void> _loadBillsFromJson() async {
    try {
      final jsonString = await rootBundle.loadString('assets/bills.json');
      final bills = BillModel.parseBills(jsonString);
      _repository.setBills(bills);
    } catch (e) {
      _billErrorController.add('Failed to load bills from JSON: $e');
    }
  }

  // Load and broadcast all bills
  Future<void> refreshBills() async {
    try {
      final bills = _repository.getAllBills();
      _billStreamController.add(bills);
    } catch (e) {
      _billErrorController.add('Failed to load bills: $e');
    }
  }

  // Get a single bill by ID
  Future<BillModel?> getBill(int id) async {
    try {
      return _repository.getBillById(id);
    } catch (e) {
      _billErrorController.add('Failed to get bill with ID $id: $e');
      return null;
    }
  }

  // Get bills by customer ID
  Future<List<BillModel>> getBillsByCustomerId(int customerId) async {
    try {
      return _repository.getBillsByCustomerId(customerId);
    } catch (e) {
      _billErrorController.add(
        'Failed to get bills for customer $customerId: $e',
      );
      return [];
    }
  }

  // Get bills by status
  Future<List<BillModel>> getBillsByStatus(String status) async {
    try {
      return _repository.getBillsByStatus(status);
    } catch (e) {
      _billErrorController.add('Failed to get bills with status $status: $e');
      return [];
    }
  }

  // Dispose resources
  void dispose() {
    _billStreamController.close();
    _billErrorController.close();
  }
}
