import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/middleware/rewards_middleware.dart';
import 'package:rebill_flutter/features/checkout/models/checkout_rewards.dart';

final selectedRewardProvider = StateProvider<CheckoutRewards?>((ref) => null);

final rewardsProvider =
    AsyncNotifierProvider<RewardsProvider, List<CheckoutRewards>>(() {
      return RewardsProvider();
    });

class RewardsProvider extends AsyncNotifier<List<CheckoutRewards>> {
  @override
  Future<List<CheckoutRewards>> build() async {
    return fetchRewards();
  }

  Future<List<CheckoutRewards>> fetchRewards() async {
    final provider = ref.read(rewardsRepositoryProvider);
    return provider.getRewards();
  }

  Future<void> refreshRewards() async {
    state = const AsyncValue.loading();
    try {
      final rewards = await fetchRewards();
      state = AsyncValue.data(rewards);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}
