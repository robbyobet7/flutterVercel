import 'package:dio/dio.dart';
import 'package:rebill_flutter/core/constants/app_constants.dart';

class AuthMiddleware {
  final Dio dio = Dio();

  AuthMiddleware();

  Future<String?> login(String identity, String password) async {
    try {
      final response = await dio.post(
        AppConstants.loginUrl,
        data: {'identity': identity, 'password': password},
      );

      // Succes Status Code
      if (response.statusCode == 200 && response.data != null) {
        // Get Token From Response
        final String token = response.data['data']['token'];
        print('Login Success, $token. Token received .');
        return token;
      }
      return null; // Return null if response is not as expected
    } on DioException catch (e) {
      // Handle Dio error (e.g. connection failed, server error 4xx/5xx)
      print('Login gagal: ${e.response?.data['message'] ?? e.message}');
      return null;
    }
  }
}
