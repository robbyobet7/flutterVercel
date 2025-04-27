import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/features/main_bill/providers/main_component_provider.dart';
import 'package:rebill_flutter/features/new_bill/providers/new_bill_provider.dart';

class MainDefaultCard extends ConsumerWidget {
  const MainDefaultCard({super.key, required this.feature});

  final Map<String, dynamic> feature;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          ref.watch(mainComponentProvider.notifier).setMainBill('new_bill');
          ref.watch(newBillProvider.notifier).setNewBill(feature['id']);
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, double.infinity),
          backgroundColor: theme.colorScheme.primary,
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 12,
          children: [
            Icon(feature['icon'], size: 32, color: theme.colorScheme.onPrimary),
            Text(
              feature['title'],
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
