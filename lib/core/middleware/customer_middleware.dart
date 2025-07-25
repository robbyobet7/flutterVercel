import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/customers.dart';

class CustomerMiddleware {
  List<CustomerModel> _customers = [];
  bool _isInitialized = false;

  // Stream controllers for customer events
  final _customerStreamController =
      StreamController<List<CustomerModel>>.broadcast();
  final _customerErrorController = StreamController<String>.broadcast();

  // Streams that components can listen to
  Stream<List<CustomerModel>> get customersStream =>
      _customerStreamController.stream;
  Stream<String> get errorStream => _customerErrorController.stream;

  // Singleton instance
  static final CustomerMiddleware _instance = CustomerMiddleware._internal();

  // Factory constructor
  factory CustomerMiddleware() {
    return _instance;
  }

  // Private constructor
  CustomerMiddleware._internal();

  // Initialize the middleware
  Future<void> initialize() async {
    try {
      if (!_isInitialized) {
        await _loadCustomersFromJson();
      }
      refreshCustomers();
    } catch (e) {
      _customerErrorController.add('Failed to initialize customer data: $e');
    }
  }

  // Load customers from JSON
  Future<void> _loadCustomersFromJson() async {
    try {
      final jsonString = await rootBundle.loadString('assets/customers.json');
      final customers = CustomerModel.parseCustomers(jsonString);
      setCustomers(customers);
    } catch (e) {
      _customerErrorController.add('Failed to load customers from JSON: $e');
    }
  }

  // Set customers data
  void setCustomers(List<CustomerModel> customers) {
    _customers = customers;
    _isInitialized = true;
  }

  // Check if initialized
  bool get isInitialized => _isInitialized;

  // Get all customers
  List<CustomerModel> getAllCustomers() {
    if (!_isInitialized) {
      throw Exception('Customer middleware not initialized');
    }
    return _customers;
  }

  // Get a single customer by ID
  CustomerModel? getCustomerById(int id) {
    if (!_isInitialized) {
      throw Exception('Customer middleware not initialized');
    }
    return _customers.firstWhere(
      (customer) => customer.customerId == id,
      orElse: () => throw Exception('Customer not found with ID: $id'),
    );
  }

  List<CustomerModel> searchCustomersByName(String query) {
    if (!_isInitialized) {
      throw Exception('Customer repository not initialized');
    }
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
    refreshCustomers();

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
    refreshCustomers();
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
    refreshCustomers();
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

  // Search customers by name
  Future<void> refreshCustomers() async {
    try {
      if (_isInitialized) {
        _customerStreamController.add(_customers);
      }
    } catch (e) {
      _customerErrorController.add('Failed to load customers: $e');
    }
  }

  // Search customers by name (public method for API consistency)
  Future<List<CustomerModel>> searchCustomers(String query) async {
    try {
      if (query.isEmpty) {
        return getAllCustomers();
      }
      return searchCustomersByName(query);
    } catch (e) {
      _customerErrorController.add('Failed to search customers: $e');
      return [];
    }
  }

  // Save all customer data
  Future<void> saveCustomers() async {
    try {
      // This would be implemented to save to JSON/DB in a real app
      final jsonList = getCustomersForSerialization();
      // ignore: unused_local_variable
      final jsonString = json.encode(jsonList);

      // In a real app: await file.writeAsString(jsonString);
    } catch (e) {
      _customerErrorController.add('Failed to save customers: $e');
    }
  }

  // Dispose resources
  void dispose() {
    _customerStreamController.close();
    _customerErrorController.close();
  }
}
