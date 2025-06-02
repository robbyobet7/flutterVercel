import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/providers/orientation_provider.dart';
import 'package:rebill_flutter/features/kitchen-order/providers/kitchen_order_provider.dart';
import 'package:rebill_flutter/features/main_bill/presentations/pages/main_component_page.dart';
import 'package:rebill_flutter/features/home/presentation/widgets/home_bill.dart';
import 'package:rebill_flutter/features/home/presentation/widgets/home_products.dart';
import 'package:rebill_flutter/features/kitchen-order/presentations/widgets/processed_order.dart';
import 'package:rebill_flutter/features/kitchen-order/presentations/widgets/submitted_order.dart';
import 'package:rebill_flutter/features/kitchen-order/presentations/widgets/finished_order.dart';

class HomeFeatures extends ConsumerStatefulWidget {
  const HomeFeatures({super.key});

  @override
  ConsumerState<HomeFeatures> createState() => _HomeFeaturesState();
}

class _HomeFeaturesState extends ConsumerState<HomeFeatures> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // This ensures kitchen orders are loaded before they are displayed
    await Future.wait([initializeKitchenOrders()]);
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = ref.watch(orientationProvider);
    final theme = Theme.of(context);
    final kitchenMode = ref.watch(isKitchenOrderModeProvider);

    const homeFeatures = [HomeProducts(), MainPage(), HomeBill()];
    const kitchenOrderFeatures = [
      SubmittedOrder(),
      ProcessedOrder(),
      FinishedOrder(),
    ];

    // If kitchen orders are still initializing, show a loading indicator
    if (kitchenMode && !_isInitialized) {
      return Flexible(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading kitchen orders...'),
            ],
          ),
        ),
      );
    }

    if (isLandscape) {
      // Landscape layout with Row
      return Flexible(
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            reverseDuration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              final slideAnimation = Tween<Offset>(
                begin: const Offset(0, 1.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                  reverseCurve: Curves.easeInOut,
                ),
              );

              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                ),
                child: SlideTransition(position: slideAnimation, child: child),
              );
            },
            child:
                kitchenMode
                    ? Row(
                      spacing: 12,
                      key: const ValueKey<int>(0),
                      children:
                          kitchenOrderFeatures
                              .map((e) => Expanded(child: e))
                              .toList(),
                    )
                    : Row(
                      spacing: 12,
                      key: const ValueKey<int>(1),
                      children:
                          homeFeatures.map((e) => Expanded(child: e)).toList(),
                    ),
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
