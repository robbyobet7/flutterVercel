import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/providers/merchant_provider.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_divider.dart';
import 'package:rebill_flutter/core/widgets/app_material.dart';
import 'package:rebill_flutter/features/main-bill/constants/bill_constants.dart';
import 'package:rebill_flutter/features/main-bill/providers/main_bill_provider.dart';

class MerchantDialog extends ConsumerWidget {
  const MerchantDialog({super.key});

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

  // // Cache physics to avoid recreation
  // static const BouncingScrollPhysics _physics = BouncingScrollPhysics(
  //   parent: AlwaysScrollableScrollPhysics(),
  // );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // final mainBillNotifier = ref.watch(mainBillProvider.notifier);
    // final billTypeNotifier = ref.watch(billTypeProvider.notifier);
    final merchantState = ref.watch(merchantProvider);

    return Expanded(
      child: Column(
        children: [
          const AppDivider(),
          Expanded(child: _buildContent(context, ref, merchantState)),
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

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    MerchantState state,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            state.errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (state.merchants.isEmpty) {
      return const Center(child: Text('Tidak ada merchant yang ditemukan.'));
    }

    // Jika data ada, tampilkan GridView
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: _gridDelegate,
      itemCount: state.merchants.length,
      itemBuilder: (context, index) {
        final merchant = state.merchants[index];
        return _MerchantItem(
          merchantName: merchant.channelName,
          theme: Theme.of(context),
          onTap: () => _handleMerchantTap(context, ref),
        );
      },
    );
  }
}

// Extract callback to method to avoid closure recreation
void _handleMerchantTap(BuildContext context, WidgetRef ref) {
  Navigator.pop(context);
  ref
      .read(mainBillProvider.notifier)
      .setMainBill(MainBillComponent.currentBillComponent);
  ref.read(billTypeProvider.notifier).setBillType(BillType.merchantBill);
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
