import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/features/checkout/models/checkout_discount.dart';

class CheckoutDiscountState {
  final List<DiscountModel> appliedDiscounts;
  final double totalDiscountAmount;
  final double subtotalBeforeDiscount;
  final double subtotalAfterDiscount;

  const CheckoutDiscountState({
    this.appliedDiscounts = const [],
    this.totalDiscountAmount = 0.0,
    this.subtotalBeforeDiscount = 0.0,
    this.subtotalAfterDiscount = 0.0,
  });

  CheckoutDiscountState copyWith({
    List<DiscountModel>? appliedDiscounts,
    double? totalDiscountAmount,
    double? subtotalBeforeDiscount,
    double? subtotalAfterDiscount,
  }) {
    return CheckoutDiscountState(
      appliedDiscounts: appliedDiscounts ?? this.appliedDiscounts,
      totalDiscountAmount: totalDiscountAmount ?? this.totalDiscountAmount,
      subtotalBeforeDiscount:
          subtotalBeforeDiscount ?? this.subtotalBeforeDiscount,
      subtotalAfterDiscount:
          subtotalAfterDiscount ?? this.subtotalAfterDiscount,
    );
  }
}

class CheckoutDiscountNotifier extends StateNotifier<CheckoutDiscountState> {
  CheckoutDiscountNotifier() : super(const CheckoutDiscountState());

  void applyDiscounts(List<DiscountModel> discounts, double subtotal) {
    double totalDiscount = 0.0;

    for (final discount in discounts) {
      if (discount.type == 'percentage') {
        // Calculate percentage discount
        final discountAmount = (subtotal * discount.amount) / 100;
        totalDiscount += discountAmount;
      } else {
        // Fixed amount discount
        totalDiscount += discount.amount;
      }
    }

    final subtotalAfterDiscount = subtotal - totalDiscount;

    state = state.copyWith(
      appliedDiscounts: discounts,
      totalDiscountAmount: totalDiscount,
      subtotalBeforeDiscount: subtotal,
      subtotalAfterDiscount:
          subtotalAfterDiscount < 0 ? 0 : subtotalAfterDiscount,
    );
  }

  void clearDiscounts() {
    state = const CheckoutDiscountState();
  }

  void updateSubtotal(double newSubtotal) {
    if (state.appliedDiscounts.isNotEmpty) {
      applyDiscounts(state.appliedDiscounts, newSubtotal);
    } else {
      state = state.copyWith(
        subtotalBeforeDiscount: newSubtotal,
        subtotalAfterDiscount: newSubtotal,
      );
    }
  }
}

final checkoutDiscountProvider =
    StateNotifierProvider<CheckoutDiscountNotifier, CheckoutDiscountState>((
      ref,
    ) {
      return CheckoutDiscountNotifier();
    });
