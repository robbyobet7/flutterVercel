import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/features/main-bill/constants/bill_constants.dart';
import 'package:rebill_flutter/features/main-bill/providers/main_bill_provider.dart';

class MainDefaultCard extends ConsumerWidget {
  const MainDefaultCard({super.key, required this.feature});

  final Map<String, dynamic> feature;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mainBillNotifier = ref.watch(mainBillProvider.notifier);
    final billTypeNotifier = ref.watch(billTypeProvider.notifier);

    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          if (feature['event'] != null) {
            feature['event']();
          }
          mainBillNotifier.setMainBill(MainBillComponent.currentBillComponent);
          billTypeNotifier.setBillType(feature['id']);
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
