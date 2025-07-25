// import '../models/customers.dart';

// class CustomerRepository {
//   // In-memory cache of customers
//   List<CustomerModel> _customers = [];
//   bool _isInitialized = false;

//   // Singleton pattern
//   CustomerRepository._();
//   static final CustomerRepository _instance = CustomerRepository._();
//   static CustomerRepository get instance => _instance;

//   // Set customers data (called from middleware)
//   void setCustomers(List<CustomerModel> customers) {
//     _customers = customers;
//     _isInitialized = true;
//   }

//   // Check if initialized
//   bool get isInitialized => _isInitialized;

//   // Get all customers
//   List<CustomerModel> getAllCustomers() {
//     if (!_isInitialized) {
//       throw Exception('Customer repository not initialized');
//     }
//     return _customers;
//   }

//   // Get customer by ID
//   CustomerModel? getCustomerById(int id) {
//     if (!_isInitialized) {
//       throw Exception('Customer repository not initialized');
//     }
//     return _customers.firstWhere(
//       (customer) => customer.customerId == id,
//       orElse: () => throw Exception('Customer not found with ID: $id'),
//     );
//   }

//   // Search customers by name
//   List<CustomerModel> searchCustomersByName(String query) {
//     if (!_isInitialized) {
//       throw Exception('Customer repository not initialized');
//     }
//     final lowercaseQuery = query.toLowerCase();
//     return _customers
//         .where(
//           (customer) =>
//               customer.customerName.toLowerCase().contains(lowercaseQuery),
//         )
//         .toList();
//   }

//   // Add a new customer
//   CustomerModel addCustomer(CustomerModel customer) {
//     if (!_isInitialized) {
//       throw Exception('Customer repository not initialized');
//     }

//     // Assign a new ID if none provided
//     final newCustomer =
//         customer.customerId == null
//             ? customer.copyWith(
//               customerId: _getNextCustomerId(),
//               key: _getNextCustomerId(),
//               createdAt: DateTime.now(),
//               updatedAt: DateTime.now(),
//             )
//             : customer;

//     _customers.add(newCustomer);
//     return newCustomer;
//   }

//   // Update an existing customer
//   CustomerModel updateCustomer(CustomerModel updatedCustomer) {
//     if (!_isInitialized) {
//       throw Exception('Customer repository not initialized');
//     }

//     final index = _customers.indexWhere(
//       (c) => c.customerId == updatedCustomer.customerId,
//     );

//     if (index == -1) {
//       throw Exception(
//         'Customer not found with ID: ${updatedCustomer.customerId}',
//       );
//     }

//     final customer = updatedCustomer.copyWith(updatedAt: DateTime.now());

//     _customers[index] = customer;
//     return customer;
//   }

//   // Delete a customer
//   void deleteCustomer(int id) {
//     if (!_isInitialized) {
//       throw Exception('Customer repository not initialized');
//     }

//     final index = _customers.indexWhere((c) => c.customerId == id);
//     if (index == -1) {
//       throw Exception('Customer not found with ID: $id');
//     }

//     _customers.removeAt(index);
//   }

//   // Get customers with loyalty points
//   List<CustomerModel> getCustomersWithPoints() {
//     if (!_isInitialized) {
//       throw Exception('Customer repository not initialized');
//     }
//     return _customers.where((c) => c.point > 0).toList();
//   }

//   // Generate the next available customer ID
//   int _getNextCustomerId() {
//     if (_customers.isEmpty) return 1;
//     return _customers
//             .map((c) => c.customerId ?? 0)
//             .reduce((a, b) => a > b ? a : b) +
//         1;
//   }

//   // Get customers for serialization
//   List<Map<String, dynamic>> getCustomersForSerialization() {
//     if (!_isInitialized) {
//       throw Exception('Customer repository not initialized');
//     }
//     return _customers.map((c) => c.toJson()).toList();
//   }
// }
