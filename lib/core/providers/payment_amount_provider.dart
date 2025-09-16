import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/features/checkout/models/payment_method.dart';

class PaymentAmountState {
  final PaymentMethod? selectedPaymentMethod;
  final PaymentMethod? selectedPaymentMethod2;
  final double receivedAmount;
  final double receivedAmount2;

  const PaymentAmountState({
    this.selectedPaymentMethod,
    this.selectedPaymentMethod2,
    this.receivedAmount = 0.0,
    this.receivedAmount2 = 0.0,
  });

  PaymentAmountState copyWith({
    PaymentMethod? selectedPaymentMethod,
    PaymentMethod? selectedPaymentMethod2,
    double? receivedAmount,
    double? receivedAmount2,
  }) {
    return PaymentAmountState(
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
      selectedPaymentMethod2:
          selectedPaymentMethod2 ?? this.selectedPaymentMethod2,
      receivedAmount: receivedAmount ?? this.receivedAmount,
      receivedAmount2: receivedAmount2 ?? this.receivedAmount2,
    );
  }
}

class PaymentAmountNotifier extends StateNotifier<PaymentAmountState> {
  PaymentAmountNotifier() : super(const PaymentAmountState());

  void setPaymentMethod(PaymentMethod? method) {
    state = state.copyWith(selectedPaymentMethod: method);
  }

  void setPaymentMethod2(PaymentMethod? method) {
    state = state.copyWith(selectedPaymentMethod2: method);
  }

  void setReceivedAmount(double amount) {
    state = state.copyWith(receivedAmount: amount);
  }

  void setReceivedAmount2(double amount) {
    state = state.copyWith(receivedAmount2: amount);
  }

  void reset() {
    state = const PaymentAmountState();
  }
}

final paymentAmountProvider =
    StateNotifierProvider<PaymentAmountNotifier, PaymentAmountState>((ref) {
      return PaymentAmountNotifier();
    });
