import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/theme/app_theme.dart';
import 'package:rebill_flutter/core/widgets/app_dialog.dart';
import 'package:rebill_flutter/core/widgets/table_dialog.dart';
import 'package:rebill_flutter/features/main-bill/constants/bill_constants.dart';
import 'package:rebill_flutter/features/main-bill/presentations/widgets/main_default_card.dart';

class MainDefaultPage extends ConsumerWidget {
  const MainDefaultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final curBillFeature = [
      {'id': BillType.newBill, 'icon': Icons.receipt, 'title': 'New Bill'},
      {
        'id': BillType.qrBill,
        'icon': Icons.qr_code,
        'title': 'QR Bill',
        'event': () {
          AppDialog.showCustom(
            context,
            content: TableDialog(tableType: TableType.qr),
            dialogType: DialogType.large,
            title: 'Select Table',
          );
        },
      },
      {
        'id': BillType.merchantBill,
        'icon': Icons.store,
        'title': 'Merchant Bill',
      },
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
                        .map((e) => MainDefaultCard(feature: e))
                        .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
