import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/customers.dart';
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
    _listenToCustomerChanges();
    _listenToErrors();
  }

  // Initialize the provider
  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    await _middleware.initialize();
  }

  // Listen for customer changes
  void _listenToCustomerChanges() {
    _middleware.customersStream.listen((customers) {
      state = state.copyWith(
        customers: state.searchQuery.isEmpty ? customers : state.customers,
        allCustomers: customers,
        isLoading: false,
      );
    });
  }

  // Listen for errors
  void _listenToErrors() {
    _middleware.errorStream.listen((error) {
      state = state.copyWith(errorMessage: error, isLoading: false);
    });
  }

  // Refresh customer list
  Future<void> refreshCustomers() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await _middleware.refreshCustomers();
  }

  // Add a new customer
  Future<void> addCustomer(CustomerModel customer) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await _middleware.addCustomer(customer);
    // refreshCustomers will update both customers and allCustomers via _listenToCustomerChanges
  }

  // Update an existing customer
  Future<void> updateCustomer(CustomerModel customer) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await _middleware.updateCustomer(customer);
    // refreshCustomers will update both customers and allCustomers via _listenToCustomerChanges
  }

  // Delete a customer
  Future<void> deleteCustomer(int id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await _middleware.deleteCustomer(id);
    // refreshCustomers will update both customers and allCustomers via _listenToCustomerChanges
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

    final results = await _middleware.searchCustomers(query);
    state = state.copyWith(customers: results, isLoading: false);
  }

  // Clear search
  void clearSearch() {
    state = state.copyWith(searchQuery: '', customers: state.allCustomers);
  }

  // Get customer by ID
  Future<CustomerModel?> getCustomerById(int id) async {
    return await _middleware.getCustomer(id);
  }

  // Get customers with loyalty points
  Future<void> getLoyaltyCustomers() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final loyaltyCustomers = await _middleware.getCustomersWithPoints();

    state = state.copyWith(
      customers: loyaltyCustomers,
      // Don't update allCustomers here, as this is a filtered view
      isLoading: false,
    );
  }

  // Save changes
  Future<void> saveChanges() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await _middleware.saveCustomers();
    state = state.copyWith(isLoading: false);
  }

  // Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  @override
  void dispose() {
    // Not disposing the middleware here as it's a singleton
    super.dispose();
  }
}

// Provider definitions

// Singleton middleware provider
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
