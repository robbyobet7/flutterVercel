import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/providers/cart_provider.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_dialog.dart';
import 'package:rebill_flutter/features/main_bill/constants/bill_constants.dart';
import 'package:rebill_flutter/features/main_bill/presentations/pages/known_individual_dialog.dart';
import 'package:rebill_flutter/features/main_bill/presentations/widgets/bill.dart';
import 'package:rebill_flutter/features/main_bill/presentations/widgets/empty_cart.dart';
import 'package:rebill_flutter/features/main_bill/presentations/widgets/total_price_card.dart';
import 'package:rebill_flutter/features/main_bill/providers/main_bill_provider.dart';
import 'package:rebill_flutter/features/main_bill/presentations/widgets/customer_expandable.dart';

class MainBillPage extends ConsumerWidget {
  const MainBillPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billType = ref.watch(billTypeProvider);
    final theme = Theme.of(context);
    final cart = ref.watch(cartProvider);
    final mainBillComponent = ref.watch(mainBillProvider);
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
            () => {
              AppDialog.showCustom(
                context,
                content: KnownIndividualDialog(),
                title: 'Known Individual',
                onClose: () {
                  ref
                      .read(knownIndividualProvider.notifier)
                      .setKnownIndividual(null);
                },
              ),
            },
      },
    ];
    return Column(
      spacing: 6,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.hardEdge,
            padding:
                mainBillComponent != MainBillComponent.defaultComponent
                    ? EdgeInsets.only(top: 12)
                    : EdgeInsets.only(top: 12, left: 12, right: 12, bottom: 12),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
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
                            ref.read(cartProvider.notifier).clearCart();

                            ref
                                .watch(mainBillProvider.notifier)
                                .setMainBill(
                                  MainBillComponent.defaultComponent,
                                );
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
                billType != BillType.merchantBill
                    ? CustomerExpandable(
                      customerTypes: customerTypes,
                      theme: theme,
                    )
                    : const SizedBox.shrink(),
                cart.items.isEmpty ? EmptyCart() : Bill(),
              ],
            ),
          ),
        ),
        if (cart.items.isNotEmpty)
          Container(
            height: 50,
            child: Row(
              spacing: 6,
              children: [
                Expanded(
                  child: AppButton(
                    onPressed: () {},
                    height: 50,
                    text: 'Assign Table',
                    backgroundColor: theme.colorScheme.primaryContainer,
                    textStyle: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                Expanded(
                  child: AppButton(
                    onPressed: () {},
                    height: 50,
                    text: 'Captain Order',
                    backgroundColor: theme.colorScheme.primaryContainer,
                    textStyle: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                Expanded(
                  child: AppButton(
                    onPressed: () {},
                    height: 50,
                    text: 'Split Bill',
                    backgroundColor: theme.colorScheme.primaryContainer,
                    textStyle: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        TotalPriceCard(),
      ],
    );
  }
}
