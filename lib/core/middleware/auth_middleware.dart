import 'package:dio/dio.dart';
import 'package:rebill_flutter/core/constants/app_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthMiddleware {
  final Dio dio = Dio();

  AuthMiddleware();

  // Save Owner Tokens
  Future<void> saveOwnerTokens(String token, String refreshToken) async {
    final secureStorage = FlutterSecureStorage();
    await secureStorage.write(key: AppConstants.authTokenKey, value: token);
    await secureStorage.write(
      key: AppConstants.refreshTokenOwnerKey,
      value: refreshToken,
    );
  }

  // Save Staff Tokens
  Future<void> saveStaffTokens(String token, String refreshToken) async {
    final secureStorage = FlutterSecureStorage();
    await secureStorage.write(
      key: AppConstants.authTokenStaffKey,
      value: token,
    );
    await secureStorage.write(
      key: AppConstants.refreshTokenStaffKey,
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
            await saveOwnerTokens(token, refreshToken);
          }
        }
      }
    } catch (e) {
      throw 'Login failed, please check your identity or password';
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
      final tokenOwner = await storage.read(key: AppConstants.authTokenKey);
      if (tokenOwner == null) {
        throw Exception('Owner authentication token not found');
      }
      dio.options.headers['Authorization'] = tokenOwner;

      // Prepare login data
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
        final Map<String, dynamic> responseData = response.data['data'];
        final String token = responseData['token'];
        final String refreshToken = responseData['refreshToken'];

        // Save tokens to secure storage
        await storage.write(key: AppConstants.authTokenStaffKey, value: token);
        await storage.write(
          key: AppConstants.refreshTokenStaffKey,
          value: refreshToken,
        );
        return responseData;
      } else {
        final errorMessage = response.data['message'] ?? 'Staff login failed';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Refresh Token Owner
  Future<void> refreshTokenOwner() async {
    try {
      final secureStorage = FlutterSecureStorage();
      final refreshToken = await secureStorage.read(
        key: AppConstants.refreshTokenOwnerKey,
      );

      // Check if we have a refresh token
      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception('Refresh token owner not found in local storage');
      }

      final currentToken = await secureStorage.read(
        key: AppConstants.authTokenKey,
      );

      // Try with primary format - refresh_token in body
      final response = await dio.post(
        AppConstants.refreshTokenOwnerUrl,
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {'Authorization': currentToken},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        await processOwnerRefreshResponse(response, refreshToken);
        return;
      }

      throw Exception(
        'Failed to refresh owner token: ${response.statusCode}, Body: ${response.data}',
      );
    } catch (e) {
      rethrow;
    }
  }

  // Refresh Token Staff
  Future<void> refreshTokenStaff() async {
    try {
      final secureStorage = FlutterSecureStorage();
      final refreshToken = await secureStorage.read(
        key: AppConstants.refreshTokenStaffKey,
      );

      // Check if we have a refresh token
      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception('Refresh token staff not found, cannot refresh');
      }

      final currenToken = await secureStorage.read(
        key: AppConstants.authTokenStaffKey,
      );

      // Try with primary format - refresh_token in body
      final response = await dio.post(
        AppConstants.refreshTokenStaffUrl,
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {'Authorization': currenToken},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        await processStaffRefreshResponse(response, refreshToken);
        return;
      }

      throw Exception('Failed to refresh staff token');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> processOwnerRefreshResponse(
    Response response,
    String oldRefreshToken,
  ) async {
    final data = response.data['data'];
    if (data == null) throw Exception('Data is null in refresh response');

    final token = data['token'];
    final newRefreshToken =
        data['refresh_token'] ?? data['refreshToken'] ?? oldRefreshToken;

    if (token != null && token is String && token.isNotEmpty) {
      await saveOwnerTokens(token, newRefreshToken);
    } else {
      throw Exception('New token is null in refresh response');
    }
  }

  Future<void> processStaffRefreshResponse(
    Response response,
    String oldRefreshToken,
  ) async {
    final data = response.data['data'];
    if (data == null) throw Exception('Data is null in refresh response');

    final token = data['token'];
    final newRefreshToken =
        data['refresh_token'] ?? data['refreshToken'] ?? oldRefreshToken;

    if (token != null && token is String && token.isNotEmpty) {
      await saveStaffTokens(token, newRefreshToken);
    } else {
      throw Exception('New token is null in refresh response');
    }
  }
}
