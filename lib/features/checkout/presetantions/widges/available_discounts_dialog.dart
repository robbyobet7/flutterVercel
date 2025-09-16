import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/providers/discounts_provider.dart';
import 'package:rebill_flutter/core/utils/extensions.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_material.dart';
import 'package:rebill_flutter/core/widgets/app_search_bar.dart';

class AvailableDiscountsDialog extends ConsumerWidget {
  const AvailableDiscountsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final discountsAsyncValue = ref.watch(discountsProvider);
    final tempSelectedDiscounts = ref.watch(tempSelectedDiscountsProvider);

    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SizedBox(width: double.infinity, child: AppSearchBar()),
          ),
          Expanded(
            child: Column(
              children: [
                // Table header
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Discount',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Amount',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Remaining',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Minimum',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Capped to',
                          textAlign: TextAlign.center,
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
                  child: discountsAsyncValue.when(
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error:
                        (err, stack) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Failed to load discount:\n$err',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    data: (discounts) {
                      if (discounts.isEmpty) {
                        return const Center(
                          child: Text('No discounts available.'),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.only(top: 8),
                        physics: const BouncingScrollPhysics(),
                        itemCount: discounts.length,
                        itemBuilder: (context, index) {
                          final discount = discounts[index];
                          final isSelected = tempSelectedDiscounts.any(
                            (selected) => selected.id == discount.id,
                          );

                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: AppMaterial(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () {
                                    final notifier = ref.read(
                                      tempSelectedDiscountsProvider.notifier,
                                    );
                                    if (isSelected) {
                                      notifier.state = [];
                                    } else {
                                      notifier.state = [discount];
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
                                              ? theme
                                                  .colorScheme
                                                  .primaryContainer
                                              : (index % 2 == 0
                                                  ? theme
                                                      .colorScheme
                                                      .surfaceContainer
                                                  : theme.colorScheme.surface),
                                      border: Border.all(
                                        color:
                                            isSelected
                                                ? theme.colorScheme.primary
                                                : Colors.transparent,
                                      ),
                                    ),
                                    child: Row(
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
                                            style: theme.textTheme.titleSmall,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            discount.todayRemaining
                                                    ?.toString() ??
                                                '-',
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.titleSmall,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            discount.minimum > 0
                                                ? discount.minimum.toCurrency()
                                                : '-',
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.titleSmall,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            discount.cappedTo > 0
                                                ? discount.cappedTo.toCurrency()
                                                : '-',
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.titleSmall,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(width: 12),
                AppButton(
                  onPressed: () => Navigator.pop(context, false),
                  text: 'Cancel',
                  backgroundColor: theme.colorScheme.errorContainer,
                  textStyle: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(width: 12),
                AppButton(
                  onPressed: () {
                    ref.read(selectedDiscountsProvider.notifier).state = ref
                        .read(tempSelectedDiscountsProvider);
                    Navigator.pop(context);
                  },
                  text: 'Apply Discount',
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
