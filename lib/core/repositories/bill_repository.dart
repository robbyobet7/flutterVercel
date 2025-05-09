import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/bill.dart';

class BillRepository {
  // In-memory cache of bills
  List<BillModel> _bills = [];
  bool _isInitialized = false;

  // Singleton pattern
  BillRepository._();
  static final BillRepository _instance = BillRepository._();
  static BillRepository get instance => _instance;

  // Initialize the repository with data from the JSON file
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final jsonString = await rootBundle.loadString('assets/bills.json');
      _bills = BillModel.parseBills(jsonString);
      _isInitialized = true;
    } catch (e) {
      _bills = [];
    }
  }

  // Get all bills
  Future<List<BillModel>> getAllBills() async {
    if (!_isInitialized) await initialize();
    return _bills;
  }

  // Get bill by ID
  Future<BillModel?> getBillById(int id) async {
    if (!_isInitialized) await initialize();
    return _bills.firstWhere(
      (bill) => bill.billId == id,
      orElse: () => throw Exception('Bill not found with ID: $id'),
    );
  }

  // Get bills by customer ID
  Future<List<BillModel>> getBillsByCustomerId(int customerId) async {
    if (!_isInitialized) await initialize();
    return _bills.where((bill) => bill.customerId == customerId).toList();
  }

  // Get bills by status
  Future<List<BillModel>> getBillsByStatus(String status) async {
    if (!_isInitialized) await initialize();
    return _bills.where((bill) => bill.states == status).toList();
  }

  // Get bills by date range
  Future<List<BillModel>> getBillsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    if (!_isInitialized) await initialize();
    return _bills.where((bill) {
      return bill.createdAt.isAfter(start) && bill.createdAt.isBefore(end);
    }).toList();
  }

  // Get refunded bills
  Future<List<BillModel>> getRefundedBills() async {
    if (!_isInitialized) await initialize();
    return _bills.where((bill) => bill.refund != null).toList();
  }

  // Add a new bill
  Future<BillModel> addBill(BillModel bill) async {
    if (!_isInitialized) await initialize();

    // Assign a new ID if none provided
    final newBill =
        bill.billId == 0
            ? BillModel(
              billId: _getNextBillId(),
              customerName: bill.customerName,
              orderCollection: bill.orderCollection,
              total: bill.total,
              finalTotal: bill.finalTotal,
              downPayment: bill.downPayment,
              usersId: bill.usersId,
              states: bill.states,
              delivery: bill.delivery,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              outletId: bill.outletId,
              servicefee: bill.servicefee,
              gratuity: bill.gratuity,
              vat: bill.vat,
              billDiscount: bill.billDiscount,
              totalDiscount: bill.totalDiscount,
              hashBill: bill.hashBill,
              rewardPoints: bill.rewardPoints,
              totalReward: bill.totalReward,
              rewardBill: bill.rewardBill,
              cBillId: _generateBillId(),
              rounding: bill.rounding,
              isQR: bill.isQR,
              amountPaid: bill.amountPaid,
              productDiscount: bill.productDiscount,
              key: _getNextBillId(),
              totaldiscount: bill.totaldiscount,
              totalafterdiscount: bill.totalafterdiscount,
              cashier: bill.cashier,
              lastcashier: bill.lastcashier,
              firstcashier: bill.firstcashier,
              totalgratuity: bill.totalgratuity,
              totalservicefee: bill.totalservicefee,
              totalbeforetax: bill.totalbeforetax,
              totalvat: bill.totalvat,
              totalaftertax: bill.totalaftertax,
              roundingSetting: bill.roundingSetting,
              totalafterrounding: bill.totalafterrounding,
              div: bill.div,
              billDate: _formatBillDate(DateTime.now()),
              posBillDate: _formatBillDate(DateTime.now()),
              posPaidBillDate: _formatBillDate(DateTime.now()),
              rewardoption: bill.rewardoption,
              return_: bill.return_,
              fromProcessBill: bill.fromProcessBill,
            )
            : bill;

    _bills.add(newBill);
    return newBill;
  }

  // Update an existing bill
  Future<BillModel> updateBill(BillModel updatedBill) async {
    if (!_isInitialized) await initialize();

    final index = _bills.indexWhere((b) => b.billId == updatedBill.billId);

    if (index == -1) {
      throw Exception('Bill not found with ID: ${updatedBill.billId}');
    }

    _bills[index] = updatedBill;
    return updatedBill;
  }

  // Delete a bill
  Future<void> deleteBill(int id) async {
    if (!_isInitialized) await initialize();

    final index = _bills.indexWhere((b) => b.billId == id);
    if (index == -1) {
      throw Exception('Bill not found with ID: $id');
    }

    _bills.removeAt(index);
  }

  // Generate the next available bill ID
  int _getNextBillId() {
    if (_bills.isEmpty) return 1;
    return _bills.map((b) => b.billId).reduce((a, b) => a > b ? a : b) + 1;
  }

  // Generate a formatted bill ID (e.g., "20250505-1793")
  String _generateBillId() {
    final now = DateTime.now();
    final dateStr =
        "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
    final counter =
        (_bills.isEmpty) ? 1 : int.parse(_bills.last.cBillId.split('-')[1]) + 1;
    return "$dateStr-$counter";
  }

  // Format bill date string
  String _formatBillDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final dayOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return "${dayOfWeek[date.weekday % 7]} ${months[date.month - 1]} ${date.day} ${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}";
  }

  // Save bills to JSON
  Future<void> saveBillsToJson() async {
    // This is just a placeholder - in a real app, you would save to a database or file
    final jsonList = _bills.map((b) => b.toJson()).toList();
    // ignore: unused_local_variable
    final jsonString = json.encode(jsonList);

    // Here you might write to a file, API or database
  }
}
