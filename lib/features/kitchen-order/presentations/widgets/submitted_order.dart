import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/theme/app_theme.dart';
import 'package:rebill_flutter/core/widgets/app_search_bar.dart';
import 'package:rebill_flutter/features/kitchen-order/presentations/widgets/kitchen_order_container.dart';
import 'package:rebill_flutter/features/kitchen-order/providers/kitchen_order_provider.dart';

class SubmittedOrder extends ConsumerWidget {
  const SubmittedOrder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final submittedOrders = ref.watch(submittedKitchenOrdersProvider);
    print(submittedOrders.length);
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
              spacing: 16,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'New Orders',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: AppSearchBar(
                    onSearch: (value) {},
                    hintText: 'Search Orders...',
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              itemCount: submittedOrders.length,
              cacheExtent: 10,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    KitchenOrderContainer(order: submittedOrders[index]),
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
