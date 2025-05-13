import '../models/bill.dart';

class BillRepository {
  // In-memory cache of bills
  List<BillModel> _bills = [];
  bool _isInitialized = false;

  // Singleton pattern
  BillRepository._();
  static final BillRepository _instance = BillRepository._();
  static BillRepository get instance => _instance;

  // Set bills data (called from middleware)
  void setBills(List<BillModel> bills) {
    _bills = bills;
    _isInitialized = true;
  }

  // Check if initialized
  bool get isInitialized => _isInitialized;

  // Get all bills
  List<BillModel> getAllBills() {
    if (!_isInitialized) {
      throw Exception('Bill repository not initialized');
    }
    return _bills;
  }

  // Get bill by ID
  BillModel? getBillById(int id) {
    if (!_isInitialized) {
      throw Exception('Bill repository not initialized');
    }
    return _bills.firstWhere(
      (bill) => bill.billId == id,
      orElse: () => throw Exception('Bill not found with ID: $id'),
    );
  }

  // Get bills by customer ID
  List<BillModel> getBillsByCustomerId(int customerId) {
    if (!_isInitialized) {
      throw Exception('Bill repository not initialized');
    }
    return _bills.where((bill) => bill.customerId == customerId).toList();
  }

  // Get bills by status
  List<BillModel> getBillsByStatus(String status) {
    if (!_isInitialized) {
      throw Exception('Bill repository not initialized');
    }
    return _bills.where((bill) => bill.states == status).toList();
  }

  // Get bills for serialization
  List<Map<String, dynamic>> getBillsForSerialization() {
    if (!_isInitialized) {
      throw Exception('Bill repository not initialized');
    }
    return _bills.map((b) => b.toJson()).toList();
  }
}
