import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/middleware/payment_method_middleware.dart';
import 'package:rebill_flutter/features/checkout/models/payment_method.dart';

class PaymentMethodState {
  final List<PaymentMethod> paymentMethods;
  final bool isLoading;
  final String? errorMessage;

  PaymentMethodState({
    this.paymentMethods = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  PaymentMethodState copyWith({
    List<PaymentMethod>? paymentMethods,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PaymentMethodState(
      paymentMethods: paymentMethods ?? this.paymentMethods,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class PaymentMethodNotifier extends StateNotifier<PaymentMethodState> {
  final PaymentMethodMiddleware middleware;

  PaymentMethodNotifier(this.middleware) : super(PaymentMethodState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    middleware.paymentMethodStream.listen((methods) {
      state = state.copyWith(paymentMethods: methods, isLoading: false);
    });
    middleware.errorStream.listen((error) {
      state = state.copyWith(errorMessage: error, isLoading: false);
    });
    await middleware.initialize();
  }
}

final paymentMethodMiddlewareProvider = Provider<PaymentMethodMiddleware>((
  ref,
) {
  // Makesure middleware is closed when it is not used
  final middleware = PaymentMethodMiddleware();
  ref.onDispose(() => middleware.dispose());
  return middleware;
});

final paymentMethodProvider =
    StateNotifierProvider<PaymentMethodNotifier, PaymentMethodState>((ref) {
      final middleware = ref.watch(paymentMethodMiddlewareProvider);
      return PaymentMethodNotifier(middleware);
    });
