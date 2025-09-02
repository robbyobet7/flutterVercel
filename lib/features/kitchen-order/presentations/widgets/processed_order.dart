import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/models/kitchen_order.dart';
import 'package:rebill_flutter/core/theme/app_theme.dart';
import 'package:rebill_flutter/core/widgets/app_search_bar.dart';
import 'package:rebill_flutter/features/home/providers/search_provider.dart';
import 'package:rebill_flutter/features/kitchen-order/presentations/widgets/kitchen_order_container.dart';
import 'package:rebill_flutter/features/kitchen-order/providers/kitchen_order_provider.dart';

final processingSearchProvider = StateNotifierProvider<SearchNotifier, String>((
  ref,
) {
  return SearchNotifier();
});

final filteredProcessingOrdersProvider = Provider<List<KitchenOrder>>((ref) {
  final allOrders = ref.watch(processingKitchenOrdersProvider);
  final query = ref.watch(processingSearchProvider);

  if (query.isEmpty) {
    return allOrders;
  }

  return allOrders.where((order) {
    final queryLower = query.toLowerCase();
    final customerLower = order.customer.toLowerCase();
    final tableLower = order.table.toLowerCase();
    final billIdLower = order.cBillId.toLowerCase();

    return customerLower.contains(queryLower) ||
        tableLower.contains(queryLower) ||
        billIdLower.contains(queryLower);
  }).toList();
});

class ProcessedOrder extends ConsumerWidget {
  const ProcessedOrder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filteredOrders = ref.watch(filteredProcessingOrdersProvider);
    final searchQuery = ref.watch(processingSearchProvider);

    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: AppTheme.kBoxShadow,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
      child: Column(
        spacing: 12,
        children: [
          SizedBox(
            height: 40,
            width: double.infinity,
            child: Row(
              spacing: 12,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Processing',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: AppSearchBar(
                    hintText: 'Search Orders...',
                    searchProvider: processingSearchProvider,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child:
                filteredOrders.isEmpty
                    ? Center(
                      child: Text(
                        searchQuery.isEmpty
                            ? 'No Orders Found'
                            : 'Orders not found',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    )
                    : ListView.builder(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      itemCount: filteredOrders.length,
                      cacheExtent: 10,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            KitchenOrderContainer(
                              key: ValueKey(filteredOrders[index].ordersId),
                              order: filteredOrders[index],
                              type: KitchenOrderType.processing,
                            ),
                            const SizedBox(height: 10),
                          ],
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
