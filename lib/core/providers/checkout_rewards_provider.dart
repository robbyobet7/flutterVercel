import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/features/checkout/models/checkout_rewards.dart';

class CheckoutRewardsState {
  final CheckoutRewards? selectedReward;
  final double discountAmount;
  final double subtotalAfterDiscount;
  final bool isValid;

  const CheckoutRewardsState({
    this.selectedReward,
    this.discountAmount = 0.0,
    this.subtotalAfterDiscount = 0.0,
    this.isValid = false,
  });

  CheckoutRewardsState copyWith({
    CheckoutRewards? selectedReward,
    double? discountAmount,
    double? subtotalAfterDiscount,
    bool? isValid,
  }) {
    return CheckoutRewardsState(
      selectedReward: selectedReward ?? this.selectedReward,
      discountAmount: discountAmount ?? this.discountAmount,
      subtotalAfterDiscount:
          subtotalAfterDiscount ?? this.subtotalAfterDiscount,
      isValid: isValid ?? this.isValid,
    );
  }
}

class CheckoutRewardsNotifier extends StateNotifier<CheckoutRewardsState> {
  CheckoutRewardsNotifier() : super(const CheckoutRewardsState());

  void applyReward(CheckoutRewards reward, double total) {
    // Validasi minimum transaction
    if (reward.rewardRules > 0 && total < reward.rewardRules) {
      state = state.copyWith(
        selectedReward: null,
        discountAmount: 0.0,
        subtotalAfterDiscount: total,
        isValid: false,
      );
      return;
    }

    double discountAmount = 0.0;

    if (reward.rewardType == 'percent') {
      // Hitung discount berdasarkan persentase
      discountAmount = (total * reward.amount) / 100;

      // Terapkan maksimum discount jika ada
      if (reward.rewardCapped > 0 && discountAmount > reward.rewardCapped) {
        discountAmount = reward.rewardCapped.toDouble();
      }
    } else if (reward.rewardType == 'flat') {
      // Discount flat amount
      discountAmount = reward.amount.toDouble();

      // Pastikan discount tidak melebihi total
      if (discountAmount > total) {
        discountAmount = total;
      }
    }

    // Jika discount amount adalah 0, tidak ada perubahan pada total
    final subtotalAfterDiscount =
        discountAmount > 0 ? total - discountAmount : total;

    state = state.copyWith(
      selectedReward: reward,
      discountAmount: discountAmount,
      subtotalAfterDiscount: subtotalAfterDiscount,
      isValid: true,
    );
  }

  void clearReward() {
    state = const CheckoutRewardsState();
  }

  bool canApplyReward(CheckoutRewards reward, double total) {
    // Cek minimum transaction
    if (reward.rewardRules > 0 && total < reward.rewardRules) {
      return false;
    }

    // Cek apakah reward masih tersedia (count > 0)
    if (reward.count <= 0) {
      return false;
    }

    return true;
  }
}

final checkoutRewardsProvider =
    StateNotifierProvider<CheckoutRewardsNotifier, CheckoutRewardsState>((ref) {
      return CheckoutRewardsNotifier();
    });
