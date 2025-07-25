import 'package:flutter/services.dart';
import 'package:rebill_flutter/core/models/kitchen_order.dart';

class KitchenOrderMiddleware {
  List<KitchenOrder> _kitchenOrders = [];
  // Singleton pattern
  KitchenOrderMiddleware._();
  static final KitchenOrderMiddleware _instance = KitchenOrderMiddleware._();
  static KitchenOrderMiddleware get instance => _instance;

  // Flag to track initialization status
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Get all kitchen orders
  List<KitchenOrder> getAllKitchenOrders() {
    if (!_isInitialized) {
      throw Exception('Kitchen order middleware not initialized');
    }
    return _kitchenOrders;
  }

  void setKitchenOrders(List<KitchenOrder> kitchenOrders) {
    _kitchenOrders = kitchenOrders;
    _isInitialized = true;
  }

  // Get kitchen order by ID
  KitchenOrder? getKitchenOrderById(int id) {
    if (!_isInitialized) {
      throw Exception('Kitchen order middleware not initialized');
    }
    return _kitchenOrders.firstWhere(
      (order) => order.ordersId == id,
      orElse: () => throw Exception('Kitchen order not found with ID: $id'),
    );
  }

  // Get kitchen orders by bill ID
  List<KitchenOrder> getKitchenOrdersByBillId(int billId) {
    if (!_isInitialized) {
      throw Exception('Kitchen order middleware not initialized');
    }
    return _kitchenOrders.where((order) => order.billId == billId).toList();
  }

  // Get kitchen orders by status
  List<KitchenOrder> getKitchenOrdersByStatus(String status) {
    if (!_isInitialized) {
      throw Exception('Kitchen order middleware not initialized');
    }
    return _kitchenOrders.where((order) => order.states == status).toList();
  }

  // Get kitchen orders by outlet ID
  List<KitchenOrder> getKitchenOrdersByOutletId(int outletId) {
    if (!_isInitialized) {
      throw Exception('Kitchen order middleware not initialized');
    }
    return _kitchenOrders.where((order) => order.outletId == outletId).toList();
  }

  // Get kitchen orders by table
  List<KitchenOrder> getKitchenOrdersByTable(String table) {
    if (!_isInitialized) {
      throw Exception('Kitchen order middleware not initialized');
    }
    return _kitchenOrders.where((order) => order.table == table).toList();
  }

  // Get kitchen orders for serialization
  List<Map<String, dynamic>> getKitchenOrdersForSerialization() {
    if (!_isInitialized) {
      throw Exception('Kitchen order middleware not initialized');
    }
    return _kitchenOrders.map((order) => order.toJson()).toList();
  }

  // Method to load kitchen orders from assets
  Future<void> loadKitchenOrders() async {
    if (_isInitialized) return;

    try {
      // Load kitchen.json from assets
      final String jsonString = await rootBundle.loadString(
        'assets/kitchen.json',
      );

      // Parse the JSON data into KitchenOrder objects
      final List<KitchenOrder> kitchenOrders = KitchenOrder.parseKitchenOrders(
        jsonString,
      );

      // Initialize the repository with the parsed kitchen orders
      KitchenOrderMiddleware.instance.setKitchenOrders(kitchenOrders);

      // Mark as initialized
      _isInitialized = true;
    } catch (e) {
      // Initialize with empty list in case of error
      KitchenOrderMiddleware.instance.setKitchenOrders([]);
    }
  }

  // Method to reload kitchen orders (for refreshing data)
  Future<void> reloadKitchenOrders() async {
    _isInitialized = false;
    await loadKitchenOrders();
  }

  // Method to fetch kitchen orders from API (for future implementation)
  Future<void> fetchKitchenOrdersFromApi(String apiUrl) async {
    // This is a placeholder for future implementation
    // Would make an HTTP request to fetch kitchen orders from an API
    throw UnimplementedError('API fetching not implemented yet');
  }
}
