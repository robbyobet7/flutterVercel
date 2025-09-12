import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../models/customers.dart';
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

  CustomerNotifier(this._middleware) : super(CustomerState(customers: [])) {
    _initialize();
  }

  // Initialize the provider
  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    _middleware.customersStream.listen((customers) {
      state = state.copyWith(
        customers: state.searchQuery.isEmpty ? customers : state.customers,
        allCustomers: customers,
        isLoading: false,
      );
    });

    _middleware.errorStream.listen((error) {
      state = state.copyWith(errorMessage: error, isLoading: false);
    });

    try {
      await _middleware.initialize();
    } catch (e) {
      // Error already take it by errorStream.
    }
  }

  // Refresh customer list
  Future<void> refreshCustomers() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _middleware.fetchCustomersFromApi();
    } catch (e) {
      // Error already take it by errorStream.
    }
  }

  // Add a new customer
  CustomerModel addCustomer(CustomerModel customer) {
    return _middleware.addCustomer(customer);
  }

  // Update an existing customer
  void updateCustomer(CustomerModel customer) {
    _middleware.updateCustomer(customer);
  }

  // Delete a customer
  void deleteCustomer(int id) {
    _middleware.deleteCustomer(id);
  }

  // Search customers
  Future<void> searchCustomers(String query) async {
    state = state.copyWith(searchQuery: query);

    if (query.isEmpty) {
      state = state.copyWith(customers: state.allCustomers);
    } else {
      final results = _middleware.searchCustomersByName(query);
      state = state.copyWith(customers: results);
    }
  }

  // Clear search
  void clearSearch() {
    state = state.copyWith(searchQuery: '', customers: state.allCustomers);
  }

  // Get customer by ID
  CustomerModel? getCustomerById(int id) {
    return _middleware.getCustomerById(id);
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
      state = state.copyWith(isLoading: false);
      throw Exception(e);
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
      state = state.copyWith(isLoading: false);
      throw Exception(e);
    }
  }

  // Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

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
