import 'package:flutter/services.dart';
import 'package:rebill_flutter/core/models/kitchen_order.dart';
import 'package:rebill_flutter/core/repositories/kitchen_order_repository.dart';

class KitchenOrderMiddleware {
  // Singleton pattern
  KitchenOrderMiddleware._();
  static final KitchenOrderMiddleware _instance = KitchenOrderMiddleware._();
  static KitchenOrderMiddleware get instance => _instance;

  // Flag to track initialization status
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

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
      KitchenOrderRepository.instance.setKitchenOrders(kitchenOrders);

      // Mark as initialized
      _isInitialized = true;
    } catch (e) {
      // Initialize with empty list in case of error
      KitchenOrderRepository.instance.setKitchenOrders([]);
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
