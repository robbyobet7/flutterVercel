import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/theme/app_theme.dart';
import 'package:rebill_flutter/features/main_bill/providers/main_component_provider.dart';
import 'package:rebill_flutter/features/new_bill/providers/new_bill_provider.dart';

class NewBillPage extends ConsumerWidget {
  const NewBillPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billType = ref.watch(newBillProvider);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: AppTheme.kBoxShadow,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          IconButton(
            onPressed: () {
              ref.watch(mainComponentProvider.notifier).setMainComponent('');
            },
            icon: const Icon(Icons.arrow_back),
          ),
          Text(billType, style: theme.textTheme.titleLarge),
        ],
      ),
    );
  }
}
