import 'package:rebill_flutter/core/models/bill.dart';

class TableBillService {
  // Load bills from assets
  Future<List<BillModel>> loadBills() async {
    try {
      final bills = await BillModel.loadBillsFromAsset('assets/bills.json');
      return bills;
    } catch (e) {
      throw Exception('Failed to load bills: $e');
    }
  }

  // Get bill by ID
  BillModel? getBillById(List<BillModel> bills, int id) {
    try {
      return bills.firstWhere((bill) => bill.billId == id);
    } catch (e) {
      return null;
    }
  }
}
