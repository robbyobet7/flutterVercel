import 'package:flutter/material.dart';
import 'package:rebill_flutter/core/theme/app_theme.dart';

class HomeCurrentBill extends StatelessWidget {
  const HomeCurrentBill({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final curBillFeature = [
      {'icon': Icons.receipt, 'title': 'New Bill', 'onPressed': () {}},
      {'icon': Icons.qr_code, 'title': 'New QR Bill', 'onPressed': () {}},
      {'icon': Icons.store, 'title': 'New Merchant Bill', 'onPressed': () {}},
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: AppTheme.kBoxShadow,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        spacing: 24,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text('Current Bill', style: theme.textTheme.titleLarge),
          Flexible(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 12,
                children:
                    curBillFeature
                        .map((e) => CurrentBillCard(feature: e))
                        .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CurrentBillCard extends StatelessWidget {
  const CurrentBillCard({super.key, required this.feature});

  final Map<String, dynamic> feature;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: ElevatedButton(
        onPressed: () {},
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
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
