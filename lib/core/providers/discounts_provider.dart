import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rebill_flutter/core/middleware/discounts_middleware.dart';
import 'package:rebill_flutter/features/checkout/models/checkout_discount.dart';

final dioProvider = Provider<Dio>((ref) => Dio());
final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final discountMiddlewareProvider = Provider<DiscountMiddleware>((ref) {
  final dio = ref.watch(dioProvider);
  final storage = ref.watch(secureStorageProvider);

  return DiscountMiddleware(dio, storage);
});

final discountsProvider = FutureProvider<List<DiscountModel>>((ref) {
  final discountMiddleware = ref.watch(discountMiddlewareProvider);
  return discountMiddleware.fetchDiscounts();
});

final selectedDiscountsProvider = StateProvider<List<DiscountModel>>(
  (ref) => [],
);

final tempSelectedDiscountsProvider =
    StateProvider.autoDispose<List<DiscountModel>>((ref) {
      final currentSelected = ref.watch(selectedDiscountsProvider);
      return List<DiscountModel>.from(currentSelected);
    });
