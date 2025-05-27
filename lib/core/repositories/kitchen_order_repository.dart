import '../models/kitchen_order.dart';

class KitchenOrderRepository {
  // In-memory cache of kitchen orders
  List<KitchenOrder> _kitchenOrders = [];
  bool _isInitialized = false;

  // Singleton pattern
  KitchenOrderRepository._();
  static final KitchenOrderRepository _instance = KitchenOrderRepository._();
  static KitchenOrderRepository get instance => _instance;

  // Set kitchen orders data (called from middleware)
  void setKitchenOrders(List<KitchenOrder> kitchenOrders) {
    _kitchenOrders = kitchenOrders;
    _isInitialized = true;
  }

  // Check if initialized
  bool get isInitialized => _isInitialized;

  // Get all kitchen orders
  List<KitchenOrder> getAllKitchenOrders() {
    if (!_isInitialized) {
      throw Exception('Kitchen order repository not initialized');
    }
    return _kitchenOrders;
  }

  // Get kitchen order by ID
  KitchenOrder? getKitchenOrderById(int id) {
    if (!_isInitialized) {
      throw Exception('Kitchen order repository not initialized');
    }
    return _kitchenOrders.firstWhere(
      (order) => order.ordersId == id,
      orElse: () => throw Exception('Kitchen order not found with ID: $id'),
    );
  }

  // Get kitchen orders by bill ID
  List<KitchenOrder> getKitchenOrdersByBillId(int billId) {
    if (!_isInitialized) {
      throw Exception('Kitchen order repository not initialized');
    }
    return _kitchenOrders.where((order) => order.billId == billId).toList();
  }

  // Get kitchen orders by status
  List<KitchenOrder> getKitchenOrdersByStatus(String status) {
    if (!_isInitialized) {
      throw Exception('Kitchen order repository not initialized');
    }
    return _kitchenOrders.where((order) => order.states == status).toList();
  }

  // Get kitchen orders by outlet ID
  List<KitchenOrder> getKitchenOrdersByOutletId(int outletId) {
    if (!_isInitialized) {
      throw Exception('Kitchen order repository not initialized');
    }
    return _kitchenOrders.where((order) => order.outletId == outletId).toList();
  }

  // Get kitchen orders by table
  List<KitchenOrder> getKitchenOrdersByTable(String table) {
    if (!_isInitialized) {
      throw Exception('Kitchen order repository not initialized');
    }
    return _kitchenOrders.where((order) => order.table == table).toList();
  }

  // Get kitchen orders for serialization
  List<Map<String, dynamic>> getKitchenOrdersForSerialization() {
    if (!_isInitialized) {
      throw Exception('Kitchen order repository not initialized');
    }
    return _kitchenOrders.map((order) => order.toJson()).toList();
  }
}
