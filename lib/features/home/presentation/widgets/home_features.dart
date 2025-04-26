import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/providers/orientation_provider.dart';
import 'package:rebill_flutter/features/home/presentation/widgets/home_bill.dart';
import 'package:rebill_flutter/features/home/presentation/widgets/home_current_bill.dart';
import 'package:rebill_flutter/features/home/presentation/widgets/home_products.dart';

class HomeFeatures extends ConsumerWidget {
  const HomeFeatures({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLandscape = ref.watch(orientationProvider);
    final theme = Theme.of(context);

    const homeFeatures = [HomeProducts(), HomeCurrentBill(), HomeBill()];

    if (isLandscape) {
      // Landscape layout with Row
      return Flexible(
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
          child: Row(
            spacing: 12,
            children: homeFeatures.map((e) => Expanded(child: e)).toList(),
          ),
        ),
      );
    } else {
      // Portrait layout with TabBar at bottom
      return Flexible(
        child: DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TabBarView(
                clipBehavior: Clip.none,
                children:
                    homeFeatures
                        .map(
                          (feature) => Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: feature,
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
              ),
            ),
            bottomNavigationBar: TabBar(
              tabs: const [
                Tab(icon: Icon(Icons.inventory)),
                Tab(icon: Icon(Icons.receipt)),
                Tab(icon: Icon(Icons.account_balance_wallet)),
              ],
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: theme.colorScheme.primary,
              indicatorColor: theme.colorScheme.primary,
              unselectedLabelColor: Colors.grey,
            ),
          ),
        ),
      );
    }
  }
}
