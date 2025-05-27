import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/theme/app_theme.dart';

class FinishedOrder extends ConsumerWidget {
  const FinishedOrder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.red,
        boxShadow: AppTheme.kBoxShadow,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
