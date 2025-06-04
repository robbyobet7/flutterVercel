import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/models/kitchen_order.dart';
import 'package:rebill_flutter/core/repositories/kitchen_order_repository.dart';
import 'package:rebill_flutter/core/middleware/kitchen_order_middleware.dart';

// ==================== Kitchen Order State ====================

class KitchenOrderState {
  final List<KitchenOrder> orders;
  final bool isLoading;
  final String? error;

  KitchenOrderState({required this.orders, this.isLoading = false, this.error});

  KitchenOrderState copyWith({
    List<KitchenOrder>? orders,
    bool? isLoading,
    String? error,
  }) {
    return KitchenOrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ==================== Kitchen Order Notifier ====================

class KitchenOrderNotifier extends StateNotifier<KitchenOrderState> {
  KitchenOrderNotifier() : super(KitchenOrderState(orders: []));

  // Load all kitchen orders
  Future<void> loadKitchenOrders() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final orders = KitchenOrderRepository.instance.getAllKitchenOrders();
      state = state.copyWith(orders: orders, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load kitchen orders: $e',
      );
    }
  }

  // Update kitchen order status
  Future<void> updateKitchenOrderStatus(int orderId, String newStatus) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // This is a placeholder for actual implementation
      // In a real app, you would call an API to update the status

      // For now, we'll just update the local state
      final updatedOrders =
          state.orders.map((order) {
            if (order.ordersId == orderId) {
              // In a real implementation, we would create a new KitchenOrder with the updated status
              // For now, we're just pretending the status was updated
              return order;
            }
            return order;
          }).toList();

      state = state.copyWith(orders: updatedOrders, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update order status: $e',
      );
    }
  }

  // Filter orders by status
  List<KitchenOrder> getOrdersByStatus(String status) {
    return state.orders.where((order) => order.states == status).toList();
  }
}

// ==================== Providers ====================

// Main kitchen order notifier provider
final kitchenOrderNotifierProvider =
    StateNotifierProvider<KitchenOrderNotifier, KitchenOrderState>((ref) {
      return KitchenOrderNotifier();
    });

// Provider to get all kitchen orders
final kitchenOrdersProvider = Provider<List<KitchenOrder>>((ref) {
  try {
    return KitchenOrderRepository.instance.getAllKitchenOrders();
  } catch (e) {
    return [];
  }
});

// Provider to get submitted kitchen orders
final submittedKitchenOrdersProvider = Provider<List<KitchenOrder>>((ref) {
  final allOrders = ref.watch(kitchenOrdersProvider);
  return allOrders.where((order) => order.states == 'submitted').toList();
});

// Provider to get processing kitchen orders
final processingKitchenOrdersProvider = Provider<List<KitchenOrder>>((ref) {
  final allOrders = ref.watch(kitchenOrdersProvider);
  return allOrders.where((order) => order.states == 'processing').toList();
});

// Provider to get completed kitchen orders
final finishedKitchenOrdersProvider = Provider<List<KitchenOrder>>((ref) {
  final allOrders = ref.watch(kitchenOrdersProvider);
  return allOrders.where((order) => order.states == 'finished').toList();
});

// Provider to get kitchen orders by status
final kitchenOrdersByStatusProvider =
    Provider.family<List<KitchenOrder>, String>((ref, status) {
      final allOrders = ref.watch(kitchenOrdersProvider);
      return allOrders.where((order) => order.states == status).toList();
    });

// Provider to get kitchen orders by table
final kitchenOrdersByTableProvider =
    Provider.family<List<KitchenOrder>, String>((ref, table) {
      final allOrders = ref.watch(kitchenOrdersProvider);
      return allOrders.where((order) => order.table == table).toList();
    });

// Provider to get kitchen orders by bill ID
final kitchenOrdersByBillIdProvider = Provider.family<List<KitchenOrder>, int>((
  ref,
  billId,
) {
  final allOrders = ref.watch(kitchenOrdersProvider);
  return allOrders.where((order) => order.billId == billId).toList();
});

// Provider to get a single kitchen order by ID
final kitchenOrderByIdProvider = Provider.family<KitchenOrder?, int>((
  ref,
  orderId,
) {
  try {
    return KitchenOrderRepository.instance.getKitchenOrderById(orderId);
  } catch (e) {
    return null;
  }
});

// Provider for loading state of kitchen orders
final kitchenOrdersLoadingProvider = StateProvider<bool>((ref) => false);

// ==================== Helper Functions ====================

// Function to initialize kitchen orders data
Future<void> initializeKitchenOrders() async {
  if (!KitchenOrderMiddleware.instance.isInitialized) {
    await KitchenOrderMiddleware.instance.loadKitchenOrders();
  }
}

// Function to reload kitchen orders data
Future<void> reloadKitchenOrders(WidgetRef ref) async {
  ref.read(kitchenOrdersLoadingProvider.notifier).state = true;
  await KitchenOrderMiddleware.instance.reloadKitchenOrders();
  ref.read(kitchenOrdersLoadingProvider.notifier).state = false;

  // Also reload the notifier state
  await ref.read(kitchenOrderNotifierProvider.notifier).loadKitchenOrders();
}
