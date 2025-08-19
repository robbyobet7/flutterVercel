import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rebill_flutter/core/constants/app_constants.dart';
import '../models/customers.dart';

class CustomerMiddleware {
  // Singleton Pattern
  static final CustomerMiddleware _instance = CustomerMiddleware._internal();
  factory CustomerMiddleware() => _instance;
  CustomerMiddleware._internal();

  // State & Dependencies
  List<CustomerModel> _customers = [];
  bool _isInitialized = false;
  final Dio dio = Dio();
  final FlutterSecureStorage storage = FlutterSecureStorage();

  // Stream controllers for customer events
  final customerStreamController =
      StreamController<List<CustomerModel>>.broadcast();
  final customerErrorController = StreamController<String>.broadcast();

  // Public Streams
  Stream<List<CustomerModel>> get customersStream =>
      customerStreamController.stream;
  Stream<String> get errorStream => customerErrorController.stream;

  // Public getter
  bool get isInitialized => _isInitialized;

  // Initialize middleware, fetch data only once
  Future<void> initialize() async {
    if (!_isInitialized) {
      await fetchCustomersFromApi();
      _isInitialized = true;
    }
  }

  // Fetch customers from API
  Future<void> fetchCustomersFromApi() async {
    try {
      final token = await storage.read(key: AppConstants.authTokenStaffKey);
      if (token == null) {
        throw Exception('Staff authentication token not found');
      }

      // Request headers with token
      dio.options.headers['Authorization'] = token;
      final response = await dio.get(AppConstants.customerUrl);

      if (response.statusCode == 200) {
        List<dynamic> customerListJson = response.data['data'] ?? [];
        final customers =
            customerListJson
                .map((json) => CustomerModel.fromJson(json))
                .toList();
        // Update local cache
        _customers = customers;
        // Broadcast new data to all listeners
        customerStreamController.add(customers);
      } else {
        throw Exception(
          'Failed to load customers: ${response.data['message']}',
        );
      }
    } catch (e) {
      final errorMessage = 'Failed to load customers data $e';
      customerErrorController.add(errorMessage);
    }
  }

  Future<void> refreshCustomers() async {
    // Memastikan data selalu diambil ulang dari API saat di-refresh
    await fetchCustomersFromApi();
  }

  // Get all customers from local cache
  List<CustomerModel> getAllCustomers() => _customers;
  CustomerModel? getCustomerById(int id) {
    try {
      return _customers.firstWhere((c) => c.customerId == id);
    } catch (e) {
      return null;
    }
  }

  // Search customers from local cache
  List<CustomerModel> searchCustomersByName(String query) {
    if (query.isEmpty) return _customers;
    final lowercaseQuery = query.toLowerCase();
    return _customers
        .where(
          (customer) =>
              customer.customerName.toLowerCase().contains(lowercaseQuery),
        )
        .toList();
  }

  // Add a new customer
  CustomerModel addCustomer(CustomerModel customer) {
    if (!_isInitialized) {
      throw Exception('Customer middleware not initialized');
    }
    // Assign a new ID if none provided
    final newCustomer =
        customer.customerId == null
            ? customer.copyWith(
              customerId: _getNextCustomerId(),
              key: _getNextCustomerId(),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            )
            : customer;

    _customers.add(newCustomer);

    //Notify listeners
    fetchCustomersFromApi();

    return newCustomer;
  }

  // Update an existing customer
  CustomerModel updateCustomer(CustomerModel customer) {
    if (!_isInitialized) {
      throw Exception('Customer middleware not initialized');
    }

    final index = _customers.indexWhere(
      (c) => c.customerId == customer.customerId,
    );

    if (index == -1) {
      throw Exception('Customer not found with ID: ${customer.customerId}');
    }

    final updatedCustomer = customer.copyWith(updatedAt: DateTime.now());
    _customers[index] = updatedCustomer;
    fetchCustomersFromApi();
    return updatedCustomer;
  }

  // Delete a customer
  void deleteCustomer(int id) {
    if (!_isInitialized) {
      throw Exception('Customer middleware not initialized');
    }
    final index = _customers.indexWhere((c) => c.customerId == id);

    if (index == -1) {
      throw Exception('Customer not found with ID: $id');
    }

    _customers.removeAt(index);
    fetchCustomersFromApi();
  }

  // Generate the next available customer ID
  int _getNextCustomerId() {
    if (_customers.isEmpty) return 1;
    return _customers
            .map((c) => c.customerId ?? 0)
            .reduce((a, b) => a > b ? a : b) +
        1;
  }

  // Get customers for serialization
  List<Map<String, dynamic>> getCustomersForSerialization() {
    if (!_isInitialized) {
      throw Exception('Customer middleware not initialized');
    }
    return _customers.map((c) => c.toJson()).toList();
  }

  // Get customers with loyalty points
  List<CustomerModel> getCustomersWithPoints() {
    if (!_isInitialized) {
      throw Exception('Customer middleware not initialized');
    }
    return _customers.where((c) => c.point > 0).toList();
  }

  // Search customers by name (public method for API consistency)
  Future<List<CustomerModel>> searchCustomers(String query) async {
    try {
      if (query.isEmpty) {
        return getAllCustomers();
      }
      return searchCustomersByName(query);
    } catch (e) {
      customerErrorController.add('Failed to search customers: $e');
      return [];
    }
  }

  // Dispose resources
  void dispose() {
    customerStreamController.close();
    customerErrorController.close();
  }
}
