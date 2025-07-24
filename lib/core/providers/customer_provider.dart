import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../models/customers.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../middleware/customer_middleware.dart';

// Customer state
class CustomerState {
  final List<CustomerModel> customers;
  final List<CustomerModel> allCustomers;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;

  CustomerState({
    required this.customers,
    List<CustomerModel>? allCustomers,
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
  }) : allCustomers = allCustomers ?? customers;

  CustomerState copyWith({
    List<CustomerModel>? customers,
    List<CustomerModel>? allCustomers,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
  }) {
    return CustomerState(
      customers: customers ?? this.customers,
      allCustomers: allCustomers ?? this.allCustomers,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// Customer notifier
class CustomerNotifier extends StateNotifier<CustomerState> {
  final CustomerMiddleware _middleware;
  final _customerStreamController =
      StreamController<List<CustomerModel>>.broadcast();
  final _errorStreamController = StreamController<String>.broadcast();

  Stream<List<CustomerModel>> get customersStream =>
      _customerStreamController.stream;
  Stream<String> get errorStream => _errorStreamController.stream;

  CustomerNotifier(this._middleware) : super(CustomerState(customers: [])) {
    _initialize();
    _setupStreams();
  }

  // Initialize the provider
  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    try {
      if (!_middleware.isInitialized) {
        await _loadCustomersFromJson();
      }
      refreshCustomers();
    } catch (e) {
      _errorStreamController.add('Failed to initialize customer data: $e');
    }
  }

  // Load customers from JSON
  Future<void> _loadCustomersFromJson() async {
    try {
      final jsonString = await rootBundle.loadString('assets/customers.json');
      final customers = CustomerModel.parseCustomers(jsonString);
      _middleware.setCustomers(customers);
    } catch (e) {
      _errorStreamController.add('Failed to load customers from JSON: $e');
    }
  }

  // Setup streams
  void _setupStreams() {
    customersStream.listen((customers) {
      state = state.copyWith(
        customers: state.searchQuery.isEmpty ? customers : state.customers,
        allCustomers: customers,
        isLoading: false,
      );
    });

    errorStream.listen((error) {
      state = state.copyWith(errorMessage: error, isLoading: false);
    });
  }

  // Refresh customer list
  Future<void> refreshCustomers() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final customers = _middleware.getAllCustomers();
      _customerStreamController.add(customers);
    } catch (e) {
      _errorStreamController.add('Failed to load customers: $e');
    }
  }

  // Add a new customer
  Future<void> addCustomer(CustomerModel customer) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      _middleware.addCustomer(customer);
      refreshCustomers();
    } catch (e) {
      _errorStreamController.add('Failed to add customer: $e');
    }
  }

  // Update an existing customer
  Future<void> updateCustomer(CustomerModel customer) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      _middleware.updateCustomer(customer);
      refreshCustomers();
    } catch (e) {
      _errorStreamController.add('Failed to update customer: $e');
    }
  }

  // Delete a customer
  Future<void> deleteCustomer(int id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      _middleware.deleteCustomer(id);
      refreshCustomers();
    } catch (e) {
      _errorStreamController.add('Failed to delete customer: $e');
    }
  }

  // Search customers
  Future<void> searchCustomers(String query) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      searchQuery: query,
    );

    if (query.isEmpty) {
      state = state.copyWith(customers: state.allCustomers, isLoading: false);
      return;
    }

    try {
      final results = _middleware.searchCustomersByName(query);
      state = state.copyWith(customers: results, isLoading: false);
    } catch (e) {
      _errorStreamController.add('Failed to search customers: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  // Clear search
  void clearSearch() {
    state = state.copyWith(searchQuery: '', customers: state.allCustomers);
  }

  // Get customer by ID
  Future<CustomerModel?> getCustomerById(int id) async {
    try {
      return _middleware.getCustomerById(id);
    } catch (e) {
      _errorStreamController.add('Failed to get customer with ID $id: $e');
      return null;
    }
  }

  // Get customers with loyalty points
  Future<void> getLoyaltyCustomers() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final loyaltyCustomers = _middleware.getCustomersWithPoints();
      state = state.copyWith(
        customers: loyaltyCustomers,
        // Don't update allCustomers here, as this is a filtered view
        isLoading: false,
      );
    } catch (e) {
      _errorStreamController.add('Failed to get loyalty customers: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  // Save changes
  Future<void> saveChanges() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // This would be implemented to save to JSON/DB in a real app
      final jsonList = _middleware.getCustomersForSerialization();
      // ignore: unused_local_variable
      final jsonString = json.encode(jsonList);

      // In a real app: await file.writeAsString(jsonString);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      _errorStreamController.add('Failed to save customers: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  // Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  @override
  void dispose() {
    _customerStreamController.close();
    _errorStreamController.close();
    super.dispose();
  }
}

// Provider definitions

// Singleton repository provider
final customerMiddlewareProvider = Provider<CustomerMiddleware>((ref) {
  return CustomerMiddleware();
});

// Customer state provider
final customerProvider = StateNotifierProvider<CustomerNotifier, CustomerState>(
  (ref) {
    final middleware = ref.read(customerMiddlewareProvider);
    return CustomerNotifier(middleware);
  },
);

// Filtered customer providers
final loyaltyCustomersProvider = Provider<List<CustomerModel>>((ref) {
  final state = ref.watch(customerProvider);
  return state.customers.where((c) => c.point > 0).toList();
});

final searchResultsProvider = Provider.family<List<CustomerModel>, String>((
  ref,
  query,
) {
  final state = ref.watch(customerProvider);
  if (query.isEmpty) return state.customers;

  return state.customers
      .where(
        (customer) =>
            customer.customerName.toLowerCase().contains(query.toLowerCase()),
      )
      .toList();
});
