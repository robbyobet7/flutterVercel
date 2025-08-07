import 'package:dio/dio.dart';
import 'package:rebill_flutter/core/constants/app_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthMiddleware {
  final Dio dio = Dio();

  AuthMiddleware();

  // Save Token
  Future<void> saveToken(String token, String refreshToken) async {
    final secureStorage = FlutterSecureStorage();
    await secureStorage.write(key: AppConstants.authTokenKey, value: token);
    await secureStorage.write(
      key: AppConstants.refreshTokenKey,
      value: refreshToken,
    );
  }

  // Login
  Future<void> login(String identity, String password) async {
    try {
      final response = await dio.post(
        AppConstants.loginUrl,
        data: {'identity': identity, 'password': password},
      );

      // Success Status Code
      if (response.statusCode == 200 && response.data != null) {
        // Get Token From Response
        if (response.data['data'] != null) {
          final data = response.data['data'];

          // Try to get token and refresh token with various possible key names
          final token =
              data['token'] ?? data['access_token'] ?? data['accessToken'];

          final refreshToken =
              data['refresh_token'] ?? data['refreshToken'] ?? data['refresh'];

          // Check if both tokens are valid
          if (token != null &&
              refreshToken != null &&
              token is String &&
              refreshToken is String &&
              token.isNotEmpty &&
              refreshToken.isNotEmpty) {
            await saveToken(token, refreshToken);
          }
        }
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  // Refresh Token
  Future<void> refreshToken() async {
    try {
      final secureStorage = FlutterSecureStorage();
      final authTokenKey = await secureStorage.read(
        key: AppConstants.authTokenKey,
      );
      final refreshToken = await secureStorage.read(
        key: AppConstants.refreshTokenKey,
      );

      // Check if we have a refresh token
      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception('Refresh token is null or empty');
      }

      // Try with primary format - refresh_token in body
      final response = await dio.post(
        AppConstants.refreshTokenUrl,
        data: {'refreshToken': ''},
        options: Options(
          headers: {'Authorization': authTokenKey},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        processRefreshResponse(response, refreshToken);
      }

      throw Exception('Failed to refresh token');
    } catch (e) {
      throw Exception(e);
    }
  }

  // Login Staff
  Future<Map<String, dynamic>> loginStaff(
    String outletId,
    String staffId,
    String password,
  ) async {
    try {
      final dio = Dio();
      final storage = FlutterSecureStorage();

      // Take token from secure storage for header authorization
      final token = await storage.read(key: AppConstants.authTokenKey);

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Header configuration with token
      dio.options.headers['Authorization'] = token;

      // Prepare login data - pastikan konversi tipe data
      final loginData = {
        'outlet_id': int.tryParse(outletId) ?? 0,
        'staff_id': int.tryParse(staffId) ?? 0,
        'password': password,
      };

      // Make login request
      final response = await dio.post(
        AppConstants.staffLoginUrl,
        data: loginData,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      // Check response
      if (response.statusCode == 200) {
        // Extract tokens from response
        final Map<String, dynamic> responseData = response.data['data'];
        final String token = responseData['token'];
        final String refreshToken = responseData['refreshToken'];

        // Save tokens to secure storage
        await storage.write(key: AppConstants.authTokenStaffKey, value: token);
        await storage.write(
          key: AppConstants.refreshTokenStaffKey,
          value: refreshToken,
        );

        // Return full response data for additional processing if needed
        return responseData;
      } else {
        // Handle error response
        final errorMessage = response.data['message'] ?? 'Staff login failed';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  void processRefreshResponse(Response response, String oldRefreshToken) {
    try {
      final data = response.data['data'];
      if (data == null) throw Exception('Data is null');

      // Get new tokens
      final token = data['token'];
      // Check if refresh_token is in the response, otherwise reuse old one
      final newRefreshToken = data['refresh_token'] ?? oldRefreshToken;

      // Validate token
      if (token != null && token is String && token.isNotEmpty) {
        saveToken(token, newRefreshToken);
      }
      throw Exception('Failed to process refresh response');
    } catch (e) {
      throw Exception(e);
    }
  }
}
