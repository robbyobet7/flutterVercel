import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/providers/rewards_provider.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_material.dart';
import 'package:rebill_flutter/core/widgets/app_search_bar.dart';

extension CurrencyFormatting on num {
  String toCurrency() {
    return 'Rp ${toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}

class AvailableRewardsDialog extends ConsumerWidget {
  const AvailableRewardsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final rewardsAsyncValue = ref.watch(rewardsProvider);
    final selectedReward = ref.watch(selectedRewardProvider);

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
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      _buildHeader(theme, 'Reward / Discount', flex: 2),
                      _buildHeader(theme, 'Points Needed'),
                      _buildHeader(theme, 'Quantity'),
                      _buildHeader(theme, 'Min. Transaction'),
                      _buildHeader(theme, 'Max. Discount'),
                    ],
                  ),
                ),
                // Table body
                Expanded(
                  child: rewardsAsyncValue.when(
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error:
                        (err, stack) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Failed to load rewards:\n$err',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    data: (rewards) {
                      if (rewards.isEmpty) {
                        return const Center(
                          child: Text('No reward available.'),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.only(top: 8),
                        physics: const BouncingScrollPhysics(),
                        itemCount: rewards.length,
                        itemBuilder: (context, index) {
                          final reward = rewards[index];
                          final isSelected = selectedReward?.id == reward.id;

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
                                      selectedRewardProvider.notifier,
                                    );
                                    notifier.state = isSelected ? null : reward;
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
                                        _buildCell(
                                          theme,
                                          reward.rewardType == 'percent'
                                              ? 'Diskon ${reward.amount}%'
                                              : 'Potongan ${reward.rewardRules.toCurrency()}',
                                          flex: 2,
                                          isBold: true,
                                        ),
                                        _buildCell(theme, '${reward.points}'),
                                        _buildCell(
                                          theme,
                                          reward.count.toString(),
                                        ),
                                        _buildCell(
                                          theme,
                                          reward.rewardType == 'flat' &&
                                                  reward.rewardRules > 0
                                              ? reward.rewardRules.toCurrency()
                                              : '-',
                                        ),
                                        _buildCell(
                                          theme,
                                          reward.rewardCapped > 0
                                              ? reward.rewardCapped.toCurrency()
                                              : '-',
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
                AppButton(
                  onPressed: () => Navigator.pop(context),
                  text: 'Cancel',
                  backgroundColor: theme.colorScheme.errorContainer,
                  textStyle: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(width: 12),
                AppButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  text: 'Apply Reward',
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

  Widget _buildHeader(ThemeData theme, String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCell(
    ThemeData theme,
    String text, {
    int flex = 1,
    bool isBold = false,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
