import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/features/new_bill/presentations/pages/new_bill_page.dart';
import 'package:rebill_flutter/features/main_bill/providers/main_component_provider.dart';
import 'package:rebill_flutter/features/main_bill/models/main_component.dart';
import 'package:rebill_flutter/features/main_bill/presentations/pages/main_default_page.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mainBill = ref.watch(mainComponentProvider);

    final mainBillComponents = [
      MainComponent(id: '', component: MainDefaultPage()),
      MainComponent(id: 'new_bill', component: NewBillPage()),
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
