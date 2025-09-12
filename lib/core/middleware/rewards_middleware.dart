import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rebill_flutter/core/constants/app_constants.dart';
import 'package:rebill_flutter/features/checkout/models/checkout_rewards.dart';

// Provider for Dio instance, so it can be mocked in tests
final dioProvider = Provider<Dio>((ref) => Dio());
final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

// Provider for RewardsRepository
final rewardsRepositoryProvider = Provider<RewardsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final storage = ref.watch(secureStorageProvider);
  return RewardsRepository(dio, storage);
});

class RewardsRepository {
  final Dio dio;
  final FlutterSecureStorage storage;
  RewardsRepository(this.dio, this.storage);

  Future<List<CheckoutRewards>> getRewards() async {
    try {
      final token = await storage.read(key: AppConstants.authTokenStaffKey);
      if (token == null) {
        throw Exception('Authentication token not found or expired.');
      }

      final options = Options(headers: {'Authorization': token});
      final response = await dio.get(AppConstants.rewardsUrl, options: options);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final rewards =
            data.map((json) => CheckoutRewards.fromJson(json)).toList();
        return rewards;
      } else {
        throw Exception(
          'Failed to load rewards: Status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Failed to load rewards: ${e.message}');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }
}
