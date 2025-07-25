import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import '../models/bill.dart';

class BillMiddleware {
  List<BillModel> _bills = [];
  bool _isInitialized = false;

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
  BillMiddleware._internal();

  // Initialize the middleware
  Future<void> initialize() async {
    try {
      if (!_isInitialized) {
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
      setBills(bills);
    } catch (e) {
      _billErrorController.add('Failed to load bills from JSON: $e');
    }
  }

  // Load and broadcast all bills
  Future<void> refreshBills() async {
    try {
      final bills = getAllBills();
      _billStreamController.add(bills);
    } catch (e) {
      _billErrorController.add('Failed to load bills: $e');
    }
  }

  // Set bills data
  void setBills(List<BillModel> bills) {
    _bills = bills;
    _isInitialized = true;
  }

  // Check if initialized
  bool get isInitialized => _isInitialized;

  // Get all bills
  List<BillModel> getAllBills() {
    if (!_isInitialized) {
      throw Exception('Bill middleware not initialized');
    }
    return _bills;
  }

  // Get a single bill by ID
  BillModel? getBillById(int id) {
    if (!_isInitialized) {
      throw Exception('Bill middleware not initialized');
    }
    return _bills.firstWhere(
      (bill) => bill.billId == id,
      orElse: () => throw Exception('Bill not found with ID: $id'),
    );
  }

  // Get bills by customer ID
  List<BillModel> getBillsByCustomerId(int customerId) {
    if (!_isInitialized) {
      throw Exception('Bill middleware not initialized');
    }
    return _bills.where((bill) => bill.customerId == customerId).toList();
  }

  // Get bills by status
  List<BillModel> getBillsByStatus(String status) {
    if (!_isInitialized) {
      throw Exception('Bill middleware not initialized');
    }
    return _bills.where((bill) => bill.states == status).toList();
  }

  // Get bills for serialization
  List<Map<String, dynamic>> getBillsForSerialization() {
    if (!_isInitialized) {
      throw Exception('Bill middleware not initialized');
    }
    return _bills.map((b) => b.toJson()).toList();
  }

  // Dispose resources
  void dispose() {
    _billStreamController.close();
    _billErrorController.close();
  }
}
