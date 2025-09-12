import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/providers/bill_provider.dart';
import 'package:rebill_flutter/core/providers/cart_provider.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_dialog.dart';
import 'package:rebill_flutter/core/widgets/table_dialog.dart';
import 'package:rebill_flutter/features/main-bill/constants/bill_constants.dart';
import 'package:rebill_flutter/features/main-bill/presentations/widgets/known_individual_dialog.dart';
import 'package:rebill_flutter/features/main-bill/presentations/widgets/bill.dart';
import 'package:rebill_flutter/features/main-bill/presentations/widgets/empty_cart.dart';
import 'package:rebill_flutter/features/main-bill/presentations/widgets/total_price_card.dart';
import 'package:rebill_flutter/features/main-bill/providers/main_bill_provider.dart';
import 'package:rebill_flutter/features/main-bill/presentations/widgets/customer_expandable.dart';

class MainBillPage extends ConsumerWidget {
  const MainBillPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void cancelBill() {
      resetMainBill(ref);
    }

    final billType = ref.watch(billTypeProvider);
    final theme = Theme.of(context);
    final cart = ref.watch(cartProvider);
    final mainBillComponent = ref.watch(mainBillProvider);

    final billState = ref.watch(billProvider);
    final isClosed = billState.selectedBill?.states.toLowerCase() == 'closed';
    final customerTypes = [
      {
        'icon': Icons.person_rounded,
        'label': 'Guest',
        'onTap': () {
          ref
              .read(customerTypeProvider.notifier)
              .setCustomerType(CustomerType.guest);
          ref.read(knownIndividualProvider.notifier).setKnownIndividual(null);
        },
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
                dialogType: DialogType.large,
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
                          if (isClosed)
                            Tooltip(
                              message: 'Delete Bill',
                              child: GestureDetector(
                                onTap: () async {
                                  final selectedBill =
                                      ref.read(billProvider).selectedBill;
                                  if (selectedBill == null) return;
                                  final theme = Theme.of(context);
                                  final bool?
                                  isConfirmed = await AppDialog.showCustom(
                                    context,
                                    title: 'Delete Bill',
                                    dialogType: DialogType.small,
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.warning_amber_rounded,
                                          color: theme.colorScheme.error,
                                          size: 80,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Are you sure you want to permanently delete this bill (${selectedBill.cBillId})?',
                                          style: theme.textTheme.bodyLarge,
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'This action cannot be undone.',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color:
                                                    theme
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 16),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: AppButton(
                                                onPressed:
                                                    () => Navigator.pop(
                                                      context,
                                                      false,
                                                    ),
                                                text: 'Cancel',
                                                backgroundColor:
                                                    theme
                                                        .colorScheme
                                                        .surfaceContainer,
                                                textStyle: theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color:
                                                          theme
                                                              .colorScheme
                                                              .onSurface,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: AppButton(
                                                onPressed:
                                                    () => Navigator.pop(
                                                      context,
                                                      true,
                                                    ),
                                                text: 'Delete',
                                                backgroundColor:
                                                    theme.colorScheme.error,
                                                textStyle: theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color:
                                                          theme
                                                              .colorScheme
                                                              .onError,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );

                                  // Delete bill logic
                                  if (isConfirmed == true && context.mounted) {
                                    ref
                                        .read(billProvider.notifier)
                                        .deleteBill(selectedBill.billId);
                                    cancelBill();
                                  }
                                },
                                child: Icon(
                                  Icons.delete_forever_outlined,
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
                if (!isClosed && billType != BillType.merchantBill)
                  CustomerExpandable(
                    customerTypes: customerTypes,
                    disabled: false,
                  ),
                cart.items.isEmpty ? EmptyCart() : Bill(),
              ],
            ),
          ),
        ),
        if (cart.items.isNotEmpty && !isClosed)
          SizedBox(
            height: 50,
            child: Row(
              spacing: 6,
              children: [
                Expanded(
                  child: AppButton(
                    onPressed: () {
                      AppDialog.showCustom(
                        context,
                        content: TableDialog(tableType: TableType.bill),
                        dialogType: DialogType.large,
                        title: 'Assign Table',
                      );
                    },
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
