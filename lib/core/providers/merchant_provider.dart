import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/middleware/merchant_middleware.dart';
import 'package:rebill_flutter/core/models/merchant.dart';

class MerchantState {
  final List<Merchant> merchants;
  final bool isLoading;
  final String? errorMessage;

  MerchantState({
    this.merchants = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  MerchantState copyWith({
    List<Merchant>? merchants,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MerchantState(
      merchants: merchants ?? this.merchants,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// Merchant notifier
class MerchantNotifier extends StateNotifier<MerchantState> {
  final MerchantMiddleware middleware;

  MerchantNotifier(this.middleware) : super(MerchantState()) {
    initialize();
  }

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);
    middleware.merchantStream.listen((merchants) {
      state = state.copyWith(merchants: merchants, isLoading: false);
    });
    middleware.errorStream.listen((error) {
      state = state.copyWith(errorMessage: error, isLoading: false);
    });
    await middleware.initialize();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await middleware.loadMerchantsFromApi();
  }
}

final merchantMiddlewareProvider = Provider<MerchantMiddleware>((ref) {
  return MerchantMiddleware();
});

final merchantProvider = StateNotifierProvider<MerchantNotifier, MerchantState>(
  (ref) {
    final middleware = ref.read(merchantMiddlewareProvider);
    return MerchantNotifier(middleware);
  },
);
