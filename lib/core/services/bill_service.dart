import 'package:rebill_flutter/core/models/bill.dart';

class BillService {
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

  // Get bills by status
  List<BillModel> getBillsByStatus(List<BillModel> bills, String status) {
    return bills.where((bill) => bill.states == status).toList();
  }

  // Get bills by customer
  List<BillModel> getBillsByCustomer(
    List<BillModel> bills,
    String customerName,
  ) {
    return bills
        .where(
          (bill) => bill.customerName.toLowerCase().contains(
            customerName.toLowerCase(),
          ),
        )
        .toList();
  }

  // Get bills by date range
  List<BillModel> getBillsByDateRange(
    List<BillModel> bills,
    DateTime start,
    DateTime end,
  ) {
    return bills.where((bill) {
      return bill.createdAt.isAfter(start) &&
          bill.createdAt.isBefore(end.add(Duration(days: 1)));
    }).toList();
  }

  // Get bills by payment method
  List<BillModel> getBillsByPaymentMethod(
    List<BillModel> bills,
    String method,
  ) {
    return bills
        .where(
          (bill) =>
              bill.paymentMethod != null &&
              bill.paymentMethod!.toLowerCase() == method.toLowerCase(),
        )
        .toList();
  }

  // Get refunded bills
  List<BillModel> getRefundedBills(List<BillModel> bills) {
    return bills.where((bill) => bill.refund != null).toList();
  }

  // Search bills by bill number or customer name
  List<BillModel> searchBills(List<BillModel> bills, String query) {
    query = query.toLowerCase();
    return bills.where((bill) {
      return bill.cBillId.toLowerCase().contains(query) ||
          bill.customerName.toLowerCase().contains(query);
    }).toList();
  }

  // Get today's bills
  List<BillModel> getTodaysBills(List<BillModel> bills) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));

    return bills.where((bill) {
      return bill.createdAt.isAfter(today) && bill.createdAt.isBefore(tomorrow);
    }).toList();
  }

  // Get total sales for a specific period
  double getTotalSales(List<BillModel> bills, DateTime start, DateTime end) {
    final filteredBills = getBillsByDateRange(bills, start, end);
    return filteredBills
        .where((bill) => bill.states == 'closed')
        .fold(0, (sum, bill) => sum + bill.finalTotal);
  }

  // Get average sales value
  double getAverageSaleValue(List<BillModel> bills) {
    final closedBills = bills.where((bill) => bill.states == 'closed').toList();
    if (closedBills.isEmpty) return 0;

    final total = closedBills.fold(0.0, (sum, bill) => sum + bill.finalTotal);
    return total / closedBills.length;
  }

  // Group bills by payment method
  Map<String, List<BillModel>> groupBillsByPaymentMethod(
    List<BillModel> bills,
  ) {
    final result = <String, List<BillModel>>{};

    for (var bill in bills) {
      final method = bill.paymentMethod ?? 'Unknown';
      if (!result.containsKey(method)) {
        result[method] = [];
      }
      result[method]!.add(bill);
    }

    return result;
  }
}
