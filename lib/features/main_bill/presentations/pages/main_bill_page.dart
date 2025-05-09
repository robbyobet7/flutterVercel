import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/providers/bill_provider.dart';
import 'package:rebill_flutter/core/providers/cart_provider.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_dialog.dart';
import 'package:rebill_flutter/features/main_bill/constants/bill_constants.dart';
import 'package:rebill_flutter/features/main_bill/presentations/widgets/known_individual_dialog.dart';
import 'package:rebill_flutter/features/main_bill/presentations/widgets/bill.dart';
import 'package:rebill_flutter/features/main_bill/presentations/widgets/empty_cart.dart';
import 'package:rebill_flutter/features/main_bill/presentations/widgets/total_price_card.dart';
import 'package:rebill_flutter/features/main_bill/providers/main_bill_provider.dart';
import 'package:rebill_flutter/features/main_bill/presentations/widgets/customer_expandable.dart';

class MainBillPage extends ConsumerWidget {
  const MainBillPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void cancelBill() {
      //clear cart
      ref.read(cartProvider.notifier).clearCart();

      ref.read(billProvider.notifier).clearSelectedBill();

      //set main bill to default component
      ref
          .watch(mainBillProvider.notifier)
          .setMainBill(MainBillComponent.defaultComponent);

      //set known individual to null
      ref.read(knownIndividualProvider.notifier).setKnownIndividual(null);

      //set customer type to guest
      ref
          .read(customerTypeProvider.notifier)
          .setCustomerType(CustomerType.guest);
    }

    final billType = ref.watch(billTypeProvider);
    final theme = Theme.of(context);
    final cart = ref.watch(cartProvider);
    final mainBillComponent = ref.watch(mainBillProvider);
    final bill = ref.watch(billProvider.notifier);
    final isClosed = bill.billStatus == 'closed';
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
                        '${isClosed ? 'Closed' : 'Open'} Bill',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        spacing: 12,
                        children: [
                          if (!isClosed)
                            Tooltip(
                              message: 'QR',
                              child: GestureDetector(
                                onTap: () {},
                                child: Icon(
                                  Icons.qr_code_rounded,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          if (!isClosed)
                            Tooltip(
                              message: 'Delete Bill',
                              child: GestureDetector(
                                onTap: () {},
                                child: Icon(
                                  Icons.delete_forever_outlined,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          Tooltip(
                            message: 'Share',
                            child: GestureDetector(
                              onTap: () {},
                              child: Icon(
                                Icons.share_outlined,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Tooltip(
                            message: 'Cancel',
                            child: GestureDetector(
                              onTap: cancelBill,
                              child: Icon(
                                Icons.cancel_rounded,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                billType != BillType.merchantBill
                    ? CustomerExpandable(
                      customerTypes: customerTypes,
                      disabled: isClosed,
                    )
                    : const SizedBox.shrink(),
                cart.items.isEmpty ? EmptyCart() : Bill(),
              ],
            ),
          ),
        ),
        if (cart.items.isNotEmpty && !isClosed)
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
