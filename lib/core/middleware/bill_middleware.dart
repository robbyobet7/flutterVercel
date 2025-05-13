import 'dart:async';
import 'dart:convert';
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

  // Get refunded bills
  Future<List<BillModel>> getRefundedBills() async {
    try {
      return _repository.getRefundedBills();
    } catch (e) {
      _billErrorController.add('Failed to get refunded bills: $e');
      return [];
    }
  }

  // Add a new bill
  Future<void> addBill(BillModel bill) async {
    try {
      _repository.addBill(bill);
      refreshBills();
    } catch (e) {
      _billErrorController.add('Failed to add bill: $e');
    }
  }

  // Update an existing bill
  Future<void> updateBill(BillModel bill) async {
    try {
      _repository.updateBill(bill);
      refreshBills();
    } catch (e) {
      _billErrorController.add('Failed to update bill: $e');
    }
  }

  // Delete a bill
  Future<void> deleteBill(int id) async {
    try {
      _repository.deleteBill(id);
      refreshBills();
    } catch (e) {
      _billErrorController.add('Failed to delete bill: $e');
    }
  }

  // Get bills by date range
  Future<List<BillModel>> getBillsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      return _repository.getBillsByDateRange(start, end);
    } catch (e) {
      _billErrorController.add('Failed to get bills by date range: $e');
      return [];
    }
  }

  // Get today's bills
  Future<List<BillModel>> getTodaysBills() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      return _repository.getBillsByDateRange(today, tomorrow);
    } catch (e) {
      _billErrorController.add('Failed to get today\'s bills: $e');
      return [];
    }
  }

  // Get bills for a specific day
  Future<List<BillModel>> getBillsForDay(DateTime date) async {
    try {
      final day = DateTime(date.year, date.month, date.day);
      final nextDay = day.add(const Duration(days: 1));
      return _repository.getBillsByDateRange(day, nextDay);
    } catch (e) {
      _billErrorController.add('Failed to get bills for specified day: $e');
      return [];
    }
  }

  // Save all bill data
  Future<void> saveBills() async {
    try {
      // This would be implemented to save to JSON/DB in a real app
      final jsonList = _repository.getBillsForSerialization();
      // ignore: unused_local_variable
      final jsonString = json.encode(jsonList);

      // In a real app: await file.writeAsString(jsonString);
    } catch (e) {
      _billErrorController.add('Failed to save bills: $e');
    }
  }

  // Dispose resources
  void dispose() {
    _billStreamController.close();
    _billErrorController.close();
  }
}
