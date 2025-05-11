import 'package:flutter/services.dart' show rootBundle;
import '../models/customers.dart';

class CustomerRepository {
  // In-memory cache of customers
  List<CustomerModel> _customers = [];
  bool _isInitialized = false;

  // Singleton pattern
  CustomerRepository._();
  static final CustomerRepository _instance = CustomerRepository._();
  static CustomerRepository get instance => _instance;

  // Initialize the repository with data from the JSON file
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final jsonString = await rootBundle.loadString('assets/customers.json');
      _customers = CustomerModel.parseCustomers(jsonString);
      _isInitialized = true;
    } catch (e) {
      _customers = [];
    }
  }

  // Get all customers
  Future<List<CustomerModel>> getAllCustomers() async {
    if (!_isInitialized) await initialize();
    return _customers;
  }

  // Get customer by ID
  Future<CustomerModel?> getCustomerById(int id) async {
    if (!_isInitialized) await initialize();
    return _customers.firstWhere(
      (customer) => customer.customerId == id,
      orElse: () => throw Exception('Customer not found with ID: $id'),
    );
  }

  // Search customers by name
  Future<List<CustomerModel>> searchCustomersByName(String query) async {
    if (!_isInitialized) await initialize();
    final lowercaseQuery = query.toLowerCase();
    return _customers
        .where(
          (customer) =>
              customer.customerName.toLowerCase().contains(lowercaseQuery),
        )
        .toList();
  }

  // Add a new customer
  Future<CustomerModel> addCustomer(CustomerModel customer) async {
    if (!_isInitialized) await initialize();

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
    return newCustomer;
  }

  // Update an existing customer
  Future<CustomerModel> updateCustomer(CustomerModel updatedCustomer) async {
    if (!_isInitialized) await initialize();

    final index = _customers.indexWhere(
      (c) => c.customerId == updatedCustomer.customerId,
    );

    if (index == -1) {
      throw Exception(
        'Customer not found with ID: ${updatedCustomer.customerId}',
      );
    }

    final customer = updatedCustomer.copyWith(updatedAt: DateTime.now());

    _customers[index] = customer;
    return customer;
  }

  // Delete a customer
  Future<void> deleteCustomer(int id) async {
    if (!_isInitialized) await initialize();

    final index = _customers.indexWhere((c) => c.customerId == id);
    if (index == -1) {
      throw Exception('Customer not found with ID: $id');
    }

    _customers.removeAt(index);
  }

  // Get customers with loyalty points
  Future<List<CustomerModel>> getCustomersWithPoints() async {
    if (!_isInitialized) await initialize();
    return _customers.where((c) => c.point > 0).toList();
  }

  // Generate the next available customer ID
  int _getNextCustomerId() {
    if (_customers.isEmpty) return 1;
    return _customers
            .map((c) => c.customerId ?? 0)
            .reduce((a, b) => a > b ? a : b) +
        1;
  }

  // Save customers to JSON
  Future<void> saveCustomersToJson() async {
    // This is just a placeholder - in a real app, you would save to a database or file
    // final jsonList = _customers.map((c) => c.toJson()).toList();
    // final jsonString = json.encode(jsonList);

    // Here you might write to a file, API or database
  }
}
