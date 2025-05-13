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

  // Get bills by date range
  List<BillModel> getBillsByDateRange(DateTime start, DateTime end) {
    if (!_isInitialized) {
      throw Exception('Bill repository not initialized');
    }
    return _bills.where((bill) {
      return bill.createdAt.isAfter(start) && bill.createdAt.isBefore(end);
    }).toList();
  }

  // Get refunded bills
  List<BillModel> getRefundedBills() {
    if (!_isInitialized) {
      throw Exception('Bill repository not initialized');
    }
    return _bills.where((bill) => bill.refund != null).toList();
  }

  // Add a new bill
  BillModel addBill(BillModel bill) {
    if (!_isInitialized) {
      throw Exception('Bill repository not initialized');
    }

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
  BillModel updateBill(BillModel updatedBill) {
    if (!_isInitialized) {
      throw Exception('Bill repository not initialized');
    }

    final index = _bills.indexWhere((b) => b.billId == updatedBill.billId);

    if (index == -1) {
      throw Exception('Bill not found with ID: ${updatedBill.billId}');
    }

    _bills[index] = updatedBill;
    return updatedBill;
  }

  // Delete a bill
  void deleteBill(int id) {
    if (!_isInitialized) {
      throw Exception('Bill repository not initialized');
    }

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

  // Get bills for serialization
  List<Map<String, dynamic>> getBillsForSerialization() {
    if (!_isInitialized) {
      throw Exception('Bill repository not initialized');
    }
    return _bills.map((b) => b.toJson()).toList();
  }
}
