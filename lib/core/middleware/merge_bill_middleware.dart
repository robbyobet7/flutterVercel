import 'dart:async';
import '../models/bill.dart';
import '../middleware/bill_middleware.dart';

class MergeBillMiddleware {
  final BillMiddleware _billMiddleware;

  // Stream controllers for bill events
  final _billStreamController = StreamController<List<BillModel>>.broadcast();
  final _billErrorController = StreamController<String>.broadcast();

  // Streams that components can listen to
  Stream<List<BillModel>> get billsStream => _billStreamController.stream;
  Stream<String> get errorStream => _billErrorController.stream;

  // Singleton instance
  static final MergeBillMiddleware _instance = MergeBillMiddleware._internal();

  // Factory constructor
  factory MergeBillMiddleware() {
    return _instance;
  }

  // Private constructor
  MergeBillMiddleware._internal() : _billMiddleware = BillMiddleware();

  // Initialize the middleware
  Future<void> initialize() async {
    try {
      if (!_billMiddleware.isInitialized) {
        await _billMiddleware.initialize();
      }
      refreshBills();
    } catch (e) {
      _billErrorController.add('Failed to initialize bill data: $e');
    }
  }

  // Load bills from JSON
  Future<void> _loadBillsFromJson() async {
    try {
      await _billMiddleware.initialize();
    } catch (e) {
      _billErrorController.add('Failed to load bills from JSON: $e');
    }
  }

  // Load and broadcast all bills
  Future<void> refreshBills() async {
    try {
      final bills = _billMiddleware.getAllBills();
      _billStreamController.add(bills);
    } catch (e) {
      _billErrorController.add('Failed to load bills: $e');
    }
  }

  // Get a single bill by ID
  Future<BillModel?> getBill(int id) async {
    try {
      return _billMiddleware.getBillById(id);
    } catch (e) {
      _billErrorController.add('Failed to get bill with ID $id: $e');
      return null;
    }
  }

  // Get bills by customer ID
  Future<List<BillModel>> getBillsByCustomerId(int customerId) async {
    try {
      return _billMiddleware.getBillsByCustomerId(customerId);
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
      return _billMiddleware.getBillsByStatus(status);
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
