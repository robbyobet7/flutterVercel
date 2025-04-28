import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/features/main_bill/presentations/pages/main_bill_page.dart';
import 'package:rebill_flutter/features/main_bill/providers/main_bill_provider.dart';
import 'package:rebill_flutter/features/main_bill/models/main_bill.dart';
import 'package:rebill_flutter/features/main_bill/presentations/pages/main_default_page.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mainBill = ref.watch(mainBillProvider);

    final mainBills = [
      MainBill(id: '', component: MainDefaultPage()),
      MainBill(id: 'new_bill', component: MainBillPage()),
    ];

    // Find the component that matches the current mainBill ID
    // and return its widget component
    return mainBills
        .firstWhere(
          (component) => component.id == mainBill,
          orElse:
              () => mainBills.first, // Default to first component if not found
        )
        .component;
  }
}
