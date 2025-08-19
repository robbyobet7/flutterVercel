import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rebill_flutter/core/constants/app_constants.dart';
import 'package:rebill_flutter/core/models/merchant.dart';

class MerchantMiddleware {
  static final MerchantMiddleware _instance = MerchantMiddleware._internal();
  factory MerchantMiddleware() => _instance;
  MerchantMiddleware._internal();

  final Dio dio = Dio();
  final FlutterSecureStorage storage = FlutterSecureStorage();

  // Stream Controller
  final merchantStreamController = StreamController<List<Merchant>>.broadcast();
  final errorStreamController = StreamController<String>.broadcast();

  //Public Streams
  Stream<List<Merchant>> get merchantStream => merchantStreamController.stream;
  Stream<String> get errorStream => errorStreamController.stream;

  //State
  bool isInitialized = false;

  Future<void> initialize() async {
    if (!isInitialized) {
      await loadMerchantsFromApi();
      isInitialized = true;
    } else {
      throw Exception('Failed to load merchant');
    }
  }

  Future<void> loadMerchantsFromApi() async {
    try {
      final token = await storage.read(key: AppConstants.authTokenStaffKey);
      debugPrint('Trying to take merchant data with token staff: $token');

      if (token == null) {
        throw Exception('Staff authentication token not found');
      }

      dio.options.headers['Authorization'] = token;

      final response = await dio.get(AppConstants.merchantsUrl);

      if (response.statusCode == 200) {
        final List<dynamic> merchantListJson = response.data['data'] ?? [];
        final merchants =
            merchantListJson.map((json) => Merchant.fromJson(json)).toList();
        merchantStreamController.add(merchants);
      } else {
        throw Exception(
          'Failed to load merchants: ${response.data['message']}',
        );
      }
    } catch (e) {
      final errorMessage = 'Failed to load merchants: $e';
      debugPrint('!!! ERROR: $e');
      errorStreamController.add(errorMessage);
    }
  }

  void dispose() {
    merchantStreamController.close();
    errorStreamController.close();
  }
}
