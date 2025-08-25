import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rebill_flutter/core/constants/app_constants.dart';
import 'package:rebill_flutter/features/checkout/models/checkout_discount.dart';

class DiscountMiddleware {
  final Dio dio;
  final FlutterSecureStorage storage;

  DiscountMiddleware(this.dio, this.storage);

  Future<List<DiscountModel>> fetchDiscounts() async {
    try {
      final token = await storage.read(key: AppConstants.authTokenStaffKey);
      if (token == null) {
        throw Exception('Authentication token not found, please log in again');
      }

      final response = await dio.get(
        AppConstants.discountsUrl,
        options: Options(headers: {'Authorization': token}),
      );

      if (response.statusCode == 200 && response.data['data'] is List) {
        final List<dynamic> discountData = response.data['data'];
        return discountData
            .map((json) => DiscountModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load discount: ${response.data['message']}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response?.statusCode == 401) {
          throw Exception('Token is not valid or expired (Unauthorized).');
        }
        throw Exception(
          'Error ${e.response?.statusCode}: ${e.response?.data?['message'] ?? 'Unknown Error'}',
        );
      } else {
        throw Exception('A network problem occurred: ${e.message}');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }
}
