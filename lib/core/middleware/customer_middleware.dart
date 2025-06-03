import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/customers.dart';
import '../repositories/customer_repository.dart';

class CustomerMiddleware {
  final CustomerRepository _repository;

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
  CustomerMiddleware._internal() : _repository = CustomerRepository.instance;

  // Initialize the middleware
  Future<void> initialize() async {
    try {
      if (!_repository.isInitialized) {
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
      _repository.setCustomers(customers);
    } catch (e) {
      _customerErrorController.add('Failed to load customers from JSON: $e');
    }
  }

  // Load and broadcast all customers
  Future<void> refreshCustomers() async {
    try {
      final customers = _repository.getAllCustomers();
      _customerStreamController.add(customers);
    } catch (e) {
      _customerErrorController.add('Failed to load customers: $e');
    }
  }

  // Get a single customer by ID
  Future<CustomerModel?> getCustomer(int id) async {
    try {
      return _repository.getCustomerById(id);
    } catch (e) {
      _customerErrorController.add('Failed to get customer with ID $id: $e');
      return null;
    }
  }

  // Add a new customer
  Future<void> addCustomer(CustomerModel customer) async {
    try {
      _repository.addCustomer(customer);
      refreshCustomers();
    } catch (e) {
      _customerErrorController.add('Failed to add customer: $e');
    }
  }

  // Update an existing customer
  Future<void> updateCustomer(CustomerModel customer) async {
    try {
      _repository.updateCustomer(customer);
      refreshCustomers();
    } catch (e) {
      _customerErrorController.add('Failed to update customer: $e');
    }
  }

  // Delete a customer
  Future<void> deleteCustomer(int id) async {
    try {
      _repository.deleteCustomer(id);
      refreshCustomers();
    } catch (e) {
      _customerErrorController.add('Failed to delete customer: $e');
    }
  }

  // Search customers by name
  Future<List<CustomerModel>> searchCustomers(String query) async {
    try {
      if (query.isEmpty) {
        return _repository.getAllCustomers();
      }
      return _repository.searchCustomersByName(query);
    } catch (e) {
      _customerErrorController.add('Failed to search customers: $e');
      return [];
    }
  }

  // Get customers with loyalty points
  Future<List<CustomerModel>> getCustomersWithPoints() async {
    try {
      return _repository.getCustomersWithPoints();
    } catch (e) {
      _customerErrorController.add('Failed to get loyalty customers: $e');
      return [];
    }
  }

  // Save all customer data
  Future<void> saveCustomers() async {
    try {
      // This would be implemented to save to JSON/DB in a real app
      final jsonList = _repository.getCustomersForSerialization();
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
