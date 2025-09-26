import 'dart:async';
import 'dart:convert';
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
      // Always refresh from BillMiddleware's current in-memory state
      await _billMiddleware.initialize();
      // Subscribe to BillMiddleware stream to reflect live changes (dummy/new bills)
      _billMiddleware.billsStream.listen((bills) {
        _billStreamController.add(bills);
      });
      refreshBills();
    } catch (e) {
      _billErrorController.add('Failed to initialize bill data: $e');
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

  // Merge two OPEN bills: secondary into primary. Primary keeps its identity
  Future<BillModel?> mergeOpenBills({
    required int primaryBillId,
    required int secondaryBillId,
  }) async {
    try {
      final primary = _billMiddleware.getBillById(primaryBillId);
      final secondary = _billMiddleware.getBillById(secondaryBillId);

      if (primary == null || secondary == null) {
        throw Exception('Bill not found');
      }
      if (primary.states != 'open' || secondary.states != 'open') {
        throw Exception('Only OPEN bills can be merged');
      }

      // Merge order collections
      List<dynamic> safeJsonDecode(String s) {
        try {
          return s.isEmpty ? [] : (jsonDecode(s) as List<dynamic>);
        } catch (_) {
          return [];
        }
      }

      final primaryOrders = safeJsonDecode(primary.orderCollection);
      final secondaryOrders = safeJsonDecode(secondary.orderCollection);
      final mergedOrders = <dynamic>[...primaryOrders, ...secondaryOrders];
      final mergedOrderCollection = jsonEncode(mergedOrders);

      // Sum totals
      double sumDouble(double a, double b) => (a) + (b);
      int sumInt(int a, int b) => (a) + (b);

      final double mergedBeforeTax = sumDouble(
        primary.totalbeforetax,
        secondary.totalbeforetax,
      );
      final double mergedGratuity = sumDouble(
        primary.totalgratuity,
        secondary.totalgratuity,
      );
      final double mergedServiceFee = sumDouble(
        primary.totalservicefee,
        secondary.totalservicefee,
      );
      final double mergedVat = sumDouble(primary.totalvat, secondary.totalvat);
      final double mergedAfterTax = sumDouble(
        primary.totalaftertax,
        secondary.totalaftertax,
      );

      int roundUpTo(int value, int multiple) =>
          ((value / multiple).ceil()) * multiple;
      final int mergedRounded = roundUpTo(
        mergedAfterTax.toInt(),
        primary.roundingSetting,
      );

      final updatedPrimary = primary.copyWith(
        orderCollection: mergedOrderCollection,
        items: [
          if (primary.items != null) ...primary.items!,
          if (secondary.items != null) ...secondary.items!,
        ],
        totalbeforetax: mergedBeforeTax,
        totalgratuity: mergedGratuity,
        totalservicefee: mergedServiceFee,
        totalvat: mergedVat,
        totalaftertax: mergedAfterTax,
        totalafterrounding: mergedRounded.toDouble(),
        finalTotal: mergedRounded.toDouble(),
        total: sumDouble(primary.total, secondary.total),
        totalDiscount: sumInt(primary.totalDiscount, secondary.totalDiscount),
        productDiscount: sumInt(
          primary.productDiscount,
          secondary.productDiscount,
        ),
        updatedAt: DateTime.now(),
      );

      // Persist changes: update primary, delete secondary
      _billMiddleware.updateBill(updatedPrimary);
      _billMiddleware.deleteBill(secondary.billId);

      // Broadcast updated list
      await refreshBills();
      return updatedPrimary;
    } catch (e) {
      _billErrorController.add('Failed to merge bills: $e');
      return null;
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
