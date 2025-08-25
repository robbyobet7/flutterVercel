import 'package:dio/dio.dart';
import 'package:rebill_flutter/core/constants/app_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
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

  final Dio dio = Dio();
  final FlutterSecureStorage storage = FlutterSecureStorage();

  Future<List<BillModel>> fetchBillsFromAPI() async {
    try {
      final token = await storage.read(key: AppConstants.authTokenStaffKey);
      if (token == null) {
        throw Exception('Token unauthorized');
      }

      // Request to API
      final response = await dio.get(
        AppConstants.billsUrl,
        options: Options(
          headers: {'Authorization': ' $token'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      // Check Response
      if (response.statusCode == 200) {
        final List<dynamic> billListJson = response.data['data'] as List;

        // JSON Parsing to List<BillModel>
        final bills =
            billListJson.map((json) => BillModel.fromJson(json)).toList();
        return bills;
      } else {
        throw Exception('Bill not found');
      }
    } on DioException catch (e) {
      throw Exception('Network Error: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  // Factory constructor
  factory BillMiddleware() {
    return _instance;
  }

  // Private constructor
  BillMiddleware._internal();

  // Initialize the middleware
  Future<void> initialize() async {
    if (!_isInitialized) {
      await refreshBills();
      _isInitialized = true;
    }
  }

  // Load and broadcast all bills
  Future<void> refreshBills() async {
    try {
      final newBills = await fetchBillsFromAPI();

      // Save data to internal cache
      setBills(newBills);

      // Send a new data for update UI
      _billStreamController.add(newBills);
    } catch (e) {
      _billErrorController.add('Failed to refresh bills $e');
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
