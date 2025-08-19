import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rebill_flutter/core/constants/app_constants.dart';
import 'package:rebill_flutter/features/checkout/models/payment_method.dart';

class PaymentMethodMiddleware {
  // Singleton pattern
  static final PaymentMethodMiddleware _instance =
      PaymentMethodMiddleware._internal();
  factory PaymentMethodMiddleware() => _instance;
  PaymentMethodMiddleware._internal();

  // Dependencies & Stream Controllers
  final Dio dio = Dio();
  final FlutterSecureStorage storage = FlutterSecureStorage();
  final paymentMethodStreamController =
      StreamController<List<PaymentMethod>>.broadcast();
  final errorStreamController = StreamController<String>.broadcast();

  // Public Streams
  Stream<List<PaymentMethod>> get paymentMethodStream =>
      paymentMethodStreamController.stream;
  Stream<String> get errorStream => errorStreamController.stream;

  // Initialize
  bool isInitialized = false;

  Future<void> initialize() async {
    if (!isInitialized) {
      await fecthPaymentMethods();
      isInitialized = true;
    }
  }

  Future<void> fecthPaymentMethods() async {
    try {
      final token = await storage.read(key: AppConstants.authTokenStaffKey);

      if (token == null) {
        throw Exception('Staff authentication token not found.');
      }
      // Header token and take URL payments
      dio.options.headers['Authorization'] = token;
      final response = await dio.get(AppConstants.paymentsUrl);

      if (response.statusCode == 200) {
        final List<dynamic> paymentListJson =
            response.data['data']['generalPaymentMethods'] ?? [];
        final paymentMethods =
            paymentListJson
                .map((json) => PaymentMethod.fromJson(json))
                .toList();
        paymentMethodStreamController.add(paymentMethods);
      } else {
        throw Exception(
          'Failed to load payment methods ${response.data['message']}',
        );
      }
    } catch (e) {
      final errorMessage = 'Gagal memuat payment method: $e';
      debugPrint('!!! ERROR SAAT MENGAMBIL PAYMENT METHOD: $e');
      errorStreamController.add(errorMessage);
    }
  }

  void dispose() {
    paymentMethodStreamController.close();
    errorStreamController.close();
  }
}
