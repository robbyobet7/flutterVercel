import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/utils/extensions.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_dialog.dart';
import 'package:rebill_flutter/core/widgets/app_material.dart';
import 'package:rebill_flutter/core/widgets/app_search_bar.dart';
import 'package:rebill_flutter/features/checkout/presetantions/widges/checkout_dialog.dart';

// Discount model
class DiscountModel {
  final String id;
  final String name;
  final String type; // 'percentage' or 'fixed'
  final double amount;
  final int todayRemaining;
  final double minimum;
  final double cappedTo;
  final bool isActive;

  DiscountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.amount,
    required this.todayRemaining,
    required this.minimum,
    required this.cappedTo,
    this.isActive = true,
  });
}

// Provider for selected discounts
final selectedDiscountsProvider = StateProvider<List<DiscountModel>>(
  (ref) => [],
);

// Provider for dummy discount data
final discountsProvider = Provider<List<DiscountModel>>((ref) {
  return [
    DiscountModel(
      id: '1',
      name: 'Early Bird',
      type: 'percentage',
      amount: 15,
      todayRemaining: 25,
      minimum: 50000,
      cappedTo: 20000,
    ),
    DiscountModel(
      id: '2',
      name: 'Student Discount',
      type: 'percentage',
      amount: 10,
      todayRemaining: 50,
      minimum: 30000,
      cappedTo: 15000,
    ),
    DiscountModel(
      id: '3',
      name: 'Weekend Special',
      type: 'fixed',
      amount: 25000,
      todayRemaining: 15,
      minimum: 100000,
      cappedTo: 25000,
    ),
    DiscountModel(
      id: '4',
      name: 'Loyalty Reward',
      type: 'percentage',
      amount: 20,
      todayRemaining: 30,
      minimum: 75000,
      cappedTo: 30000,
    ),
    DiscountModel(
      id: '5',
      name: 'First Time Customer',
      type: 'fixed',
      amount: 15000,
      todayRemaining: 100,
      minimum: 40000,
      cappedTo: 15000,
    ),
    DiscountModel(
      id: '6',
      name: 'Birthday Special',
      type: 'percentage',
      amount: 25,
      todayRemaining: 10,
      minimum: 60000,
      cappedTo: 35000,
    ),
    DiscountModel(
      id: '7',
      name: 'Corporate Discount',
      type: 'percentage',
      amount: 12,
      todayRemaining: 40,
      minimum: 200000,
      cappedTo: 50000,
    ),
    DiscountModel(
      id: '8',
      name: 'Flash Sale',
      type: 'fixed',
      amount: 30000,
      todayRemaining: 5,
      minimum: 150000,
      cappedTo: 30000,
    ),
  ];
});

class AvailableDiscountsDialog extends ConsumerWidget {
  const AvailableDiscountsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final discounts = ref.watch(discountsProvider);
    final selectedDiscounts = ref.watch(selectedDiscountsProvider);

    return Expanded(
      child: Column(
        spacing: 16,
        children: [
          SizedBox(width: double.infinity, child: AppSearchBar()),
          Expanded(
            child: Column(
              children: [
                // Table header
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    spacing: 12,
                    children: [
                      Expanded(
                        child: Text(
                          'Discount',
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Amount',
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Today Remaining',
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Minimum',
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Capped to',
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Table body
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    cacheExtent: 100,
                    itemCount: discounts.length,
                    itemBuilder: (context, index) {
                      final discount = discounts[index];
                      final isSelected = selectedDiscounts.any(
                        (selected) => selected.id == discount.id,
                      );

                      return Column(
                        children: [
                          AppMaterial(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              final notifier = ref.read(
                                selectedDiscountsProvider.notifier,
                              );
                              final currentSelected = [...selectedDiscounts];

                              if (isSelected) {
                                // If already selected, remove it
                                currentSelected.removeWhere(
                                  (item) => item.id == discount.id,
                                );
                                notifier.state = currentSelected;
                              } else {
                                // Add this discount to selection
                                currentSelected.add(discount);
                                notifier.state = currentSelected;
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 60,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color:
                                    isSelected
                                        ? theme.colorScheme.primaryContainer
                                        : index % 2 == 0
                                        ? theme.colorScheme.surfaceContainer
                                        : theme.colorScheme.surface,
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? theme.colorScheme.primary
                                          : index % 2 == 0
                                          ? Colors.transparent
                                          : theme.colorScheme.onSurface
                                              .withOpacity(0.05),
                                ),
                              ),
                              child: Row(
                                spacing: 12,
                                children: [
                                  Expanded(
                                    child: Text(
                                      discount.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      discount.type == 'percentage'
                                          ? '${discount.amount.toInt()}%'
                                          : discount.amount.toCurrency(),

                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w400,
                                          ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      discount.todayRemaining.toString(),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w400,
                                          ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      discount.minimum.toCurrency(),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w400,
                                          ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      discount.cappedTo.toCurrency(),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w400,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            width: double.infinity,
            child: Row(
              spacing: 12,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppButton(
                  onPressed: () {
                    Navigator.pop(context);
                    AppDialog.showCustom(
                      context,
                      content: CheckoutDialog(),
                      dialogType: DialogType.medium,
                      title: 'Checkout',
                    );
                  },
                  text: 'Back to Checkout',
                  backgroundColor: theme.colorScheme.errorContainer,
                  textStyle: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                AppButton(
                  onPressed: () {},
                  text: 'Discount',
                  backgroundColor: theme.colorScheme.primary,
                  textStyle: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
