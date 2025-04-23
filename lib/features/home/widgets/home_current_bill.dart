import 'package:flutter/material.dart';
import 'package:rebill_flutter/core/theme/app_theme.dart';

class HomeCurrentBill extends StatelessWidget {
  const HomeCurrentBill({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: AppTheme.kBoxShadow,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
