import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_divider.dart';
import 'package:rebill_flutter/core/widgets/app_material.dart';
import 'package:rebill_flutter/features/main-bill/constants/bill_constants.dart';
import 'package:rebill_flutter/features/main-bill/providers/main_bill_provider.dart';

class MerchantDialog extends ConsumerWidget {
  const MerchantDialog({super.key});

  // Move merchants list to static const to avoid recreation on every build
  static const List<String> _merchants = [
    'GrabFood',
    'Shopee',
    'Lazada',
    'Tokopedia',
    'JD.com',
    'TikTok',
    'WeChat',
  ];

  // Cache border radius to avoid recreation
  static const BorderRadius _borderRadius = BorderRadius.all(
    Radius.circular(8),
  );

  // Cache grid delegate to avoid recreation
  static const SliverGridDelegateWithFixedCrossAxisCount _gridDelegate =
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        mainAxisExtent: 45,
      );

  // Cache physics to avoid recreation
  static const BouncingScrollPhysics _physics = BouncingScrollPhysics(
    parent: AlwaysScrollableScrollPhysics(),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mainBillNotifier = ref.watch(mainBillProvider.notifier);
    final billTypeNotifier = ref.watch(billTypeProvider.notifier);

    return Expanded(
      child: Column(
        children: [
          const AppDivider(),
          Expanded(
            child: GridView.builder(
              physics: _physics,
              gridDelegate: _gridDelegate,
              cacheExtent: 5,
              itemCount: _merchants.length,
              itemBuilder: (context, index) {
                return _MerchantItem(
                  merchantName: _merchants[index],
                  theme: theme,
                  onTap:
                      () => _handleMerchantTap(
                        context,
                        mainBillNotifier,
                        billTypeNotifier,
                      ),
                );
              },
            ),
          ),
          const AppDivider(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppButton(
                  text: 'Cancel',
                  backgroundColor: theme.colorScheme.errorContainer,
                  textStyle: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Extract callback to method to avoid closure recreation
  void _handleMerchantTap(
    BuildContext context,
    MainBillNotifier mainBillNotifier,
    BillTypeNotifier billTypeNotifier,
  ) {
    Navigator.pop(context);
    mainBillNotifier.setMainBill(MainBillComponent.currentBillComponent);
    billTypeNotifier.setBillType(BillType.merchantBill);
  }
}

// Extract merchant item to separate widget for better performance
class _MerchantItem extends StatelessWidget {
  const _MerchantItem({
    required this.merchantName,
    required this.theme,
    required this.onTap,
  });

  final String merchantName;
  final ThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppMaterial(
      borderRadius: MerchantDialog._borderRadius,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border.all(color: theme.colorScheme.primary),
          borderRadius: MerchantDialog._borderRadius,
        ),
        child: Center(
          child: Text(merchantName, style: theme.textTheme.bodyMedium),
        ),
      ),
    );
  }
}
