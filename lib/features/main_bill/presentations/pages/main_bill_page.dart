import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/theme/app_theme.dart';
import 'package:rebill_flutter/features/main_bill/providers/main_bill_provider.dart';
import 'package:rebill_flutter/features/main_bill/presentations/widgets/customer_expandable.dart';
import 'package:rebill_flutter/features/main_bill/providers/new_bill_provider.dart';

class MainBillPage extends ConsumerWidget {
  const MainBillPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billType = ref.watch(newBillProvider);
    final theme = Theme.of(context);

    final customerTypes = [
      {
        'icon': Icons.person_rounded,
        'label': 'Guest',
        'onTap':
            () => ref
                .read(customerTypeProvider.notifier)
                .setCustomerType(CustomerType.guest),
      },
      {
        'icon': Icons.person_pin_rounded,
        'label': 'Known Individual',
        'onTap':
            () => ref
                .read(customerTypeProvider.notifier)
                .setCustomerType(CustomerType.knownIndividual),
      },
    ];
    return Column(
      spacing: 12,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: AppTheme.kBoxShadow,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  width: double.infinity,
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Bill',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Tooltip(
                        message: 'Cancel',
                        child: GestureDetector(
                          onTap: () {
                            ref
                                .watch(mainBillProvider.notifier)
                                .setMainBill('');
                          },
                          child: Icon(
                            Icons.cancel_rounded,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                billType != 'merchant_bill'
                    ? CustomerExpandable(
                      customerTypes: customerTypes,
                      theme: theme,
                    )
                    : const SizedBox.shrink(),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 12,
                    children: [
                      Icon(
                        Icons.shopping_cart_rounded,
                        size: 72,
                        color: theme.colorScheme.primary,
                      ),
                      Column(
                        children: [
                          Text('No Items in cart'),
                          Text('Click product on your left to add to cart'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: AppTheme.kBoxShadow,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total ',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'IDR ',
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                      text: '200.000',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
