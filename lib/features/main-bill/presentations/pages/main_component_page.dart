import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/features/main-bill/constants/bill_constants.dart';
import 'package:rebill_flutter/features/main-bill/presentations/pages/main_bill_page.dart';
import 'package:rebill_flutter/features/main-bill/providers/main_bill_provider.dart';
import 'package:rebill_flutter/features/main-bill/models/main_bill.dart';
import 'package:rebill_flutter/features/main-bill/presentations/pages/main_default_page.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mainBill = ref.watch(mainBillProvider);

    final mainBillComponents = [
      MainBill(
        id: MainBillComponent.defaultComponent,
        component: MainDefaultPage(),
      ),
      MainBill(
        id: MainBillComponent.currentBillComponent,
        component: MainBillPage(),
      ),
      MainBill(id: MainBillComponent.billsComponent, component: MainBillPage()),
    ];

    // Find the component that matches the current mainBill ID
    // and return its widget component
    return mainBillComponents
        .firstWhere(
          (component) => component.id == mainBill,
          orElse:
              () =>
                  mainBillComponents
                      .first, // Default to first component if not found
        )
        .component;
  }
}
