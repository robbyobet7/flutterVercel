import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:rebill_flutter/features/home/presentation/pages/kitchen_order_page.dart';
import 'package:rebill_flutter/features/home/presentation/pages/reservation_page.dart';
import 'package:rebill_flutter/features/home/presentation/pages/table_page.dart';
import 'package:rebill_flutter/features/home/presentation/widgets/home_features.dart';

enum HomeComponent { tables, home, reservations, kitchenOrders }

// Extension to get component data
extension HomeComponentExtension on HomeComponent {
  String get name {
    switch (this) {
      case HomeComponent.tables:
        return 'Tables';
      case HomeComponent.home:
        return 'Home';
      case HomeComponent.reservations:
        return 'Reservations';
      case HomeComponent.kitchenOrders:
        return 'Kitchen Orders';
    }
  }

  Widget get widget {
    switch (this) {
      case HomeComponent.tables:
        return const TablePage();
      case HomeComponent.home:
        return const HomeFeatures();
      case HomeComponent.reservations:
        return const ReservationPage();
      case HomeComponent.kitchenOrders:
        return const KitchenOrderPage();
    }
  }
}

final homeComponentProvider = StateProvider<HomeComponent>((ref) {
  return HomeComponent.home;
});
