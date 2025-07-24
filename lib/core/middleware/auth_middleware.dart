import 'package:dio/dio.dart';
import 'package:rebill_flutter/core/constants/app_constants.dart';

class AuthMiddleware {
  final Dio dio = Dio();

  AuthMiddleware();

  Future<void> login(String identity, String password) async {
    final response = await dio.post(
      AppConstants.loginUrl,
      data: {'identity': identity, 'password': password},
    );

    if (response.statusCode == 200) {
      print('Login berhasil');
    } else {
      print('Login gagal');
    }
  }
}
