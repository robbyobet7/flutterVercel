// import '../models/bill.dart';

// class TableBillRepository {
//   // In-memory cache of bills
//   List<BillModel> _bills = [];
//   bool _isInitialized = false;

//   // Singleton pattern
//   TableBillRepository._();
//   static final TableBillRepository _instance = TableBillRepository._();
//   static TableBillRepository get instance => _instance;

//   // Set bills data (called from middleware)
//   void setBills(List<BillModel> bills) {
//     _bills = bills;
//     _isInitialized = true;
//   }

//   // Check if initialized
//   bool get isInitialized => _isInitialized;

//   // Get all bills
//   List<BillModel> getAllBills() {
//     if (!_isInitialized) {
//       throw Exception('TableBill repository not initialized');
//     }
//     return _bills;
//   }

//   // Get bill by ID
//   BillModel? getBillById(int id) {
//     if (!_isInitialized) {
//       throw Exception('TableBill repository not initialized');
//     }
//     try {
//       return _bills.firstWhere(
//         (bill) => bill.billId == id,
//         orElse: () => throw Exception('Bill not found with ID: $id'),
//       );
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // Get bills by table ID
//   List<BillModel> getBillsByTableId(int tableId) {
//     if (!_isInitialized) {
//       throw Exception('TableBill repository not initialized');
//     }
//     try {
//       return _bills.where((bill) => bill.tableId == tableId).toList();
//     } catch (e) {
//       return [];
//     }
//   }

//   // Get bills for serialization
//   List<Map<String, dynamic>> getBillsForSerialization() {
//     if (!_isInitialized) {
//       throw Exception('TableBill repository not initialized');
//     }
//     return _bills.map((b) => b.toJson()).toList();
//   }
// }
