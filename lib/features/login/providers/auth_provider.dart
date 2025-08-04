import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rebill_flutter/core/constants/app_constants.dart';
import 'package:rebill_flutter/core/middleware/auth_middleware.dart';

class AuthProvider extends StateNotifier<AuthState> {
  AuthProvider() : super(AuthState());
  AuthMiddleware authMiddleware = AuthMiddleware();
  Timer? _refreshTokenTimer;

  @override
  void dispose() {
    _stopRefreshTokenTimer();
    super.dispose();
  }

  // Start Refresh Token Timer
  void _startRefreshTokenTimer() {
    _stopRefreshTokenTimer();

    // First, set a short timer (10 seconds) to verify the token works initially
    Future.delayed(const Duration(seconds: 10), () async {
      // Check if token is still valid
      final isValid = await isLoggedIn();
      if (isValid) {
        // If valid, set up the regular 15-minute refresh cycle
        _refreshTokenTimer = Timer.periodic(const Duration(minutes: 15), (
          _,
        ) async {
          print('Running scheduled token refresh');
          await refreshToken();
        });
        print('Refresh token timer started successfully');
      } else {
        print('Initial token validation failed, not starting timer');
      }
    });
  }

  // Stop Refresh Token Timer
  void _stopRefreshTokenTimer() {
    _refreshTokenTimer?.cancel();
    _refreshTokenTimer = null;
  }

  // Login
  Future<bool> login(String identity, String password) async {
    try {
      state = state.copyWith(isLoading: true);
      final token = await authMiddleware.login(identity, password);
      state = state.copyWith(isLoading: false);

      if (token != null && token != '') {
        _startRefreshTokenTimer();
        return true;
      }
      return false;
    } catch (e) {
      // Make sure to reset loading state even when errors occur
      state = state.copyWith(isLoading: false);
      rethrow; // Rethrow to let UI handle the error
    }
  }

  // Logout
  Future<void> logout() async {
    _stopRefreshTokenTimer();
    final secureStorage = FlutterSecureStorage();
    await secureStorage.delete(key: AppConstants.authTokenKey);
    await secureStorage.delete(key: AppConstants.refreshTokenKey);
    state = AuthState();
  }

  // Refresh Token
  Future<bool> refreshToken() async {
    try {
      // Get current token status first to confirm we need to refresh
      final secureStorage = FlutterSecureStorage();
      final currentToken = await secureStorage.read(
        key: AppConstants.authTokenKey,
      );
      final refreshTokenValue = await secureStorage.read(
        key: AppConstants.refreshTokenKey,
      );

      // If either token is missing, we should logout
      if (currentToken == null || refreshTokenValue == null) {
        print('Token missing during refresh attempt, logging out');
        await logout();
        return false;
      }

      // Try to refresh the token
      final success = await authMiddleware.refreshToken();

      if (success) {
        print('Token refreshed successfully');
      } else {
        print('Token refresh failed, logging out');
        await logout();
      }

      return success;
    } catch (e) {
      print('Error in refresh token: $e');
      await logout();
      return false;
    }
  }

  // Get Token
  Future<String?> getToken() async {
    try {
      final secureStorage = FlutterSecureStorage();
      final token = await secureStorage.read(key: AppConstants.authTokenKey);

      if (token != null && token.isNotEmpty) {
        // If we have a valid token, ensure the refresh timer is running
        _startRefreshTokenTimer();
        return token;
      } else {
        // No valid token found
        print('No valid token found in storage');
        return null;
      }
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  // Check token and refresh if needed
  Future<String?> getValidToken() async {
    final token = await getToken();

    // If no token, nothing we can do
    if (token == null) {
      return null;
    }

    // Check if we have a refresh token too
    final secureStorage = FlutterSecureStorage();
    final refreshTokenValue = await secureStorage.read(
      key: AppConstants.refreshTokenKey,
    );

    if (refreshTokenValue == null || refreshTokenValue.isEmpty) {
      // We have a token but no refresh token - unusual state
      print('Token found but no refresh token - invalid state');
      await logout();
      return null;
    }

    // All good, return token
    return token;
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}

class AuthState {
  final String? token;
  final String? identity;
  final bool isLoading;

  AuthState({this.token, this.identity, this.isLoading = false});

  AuthState copyWith({String? token, String? identity, bool? isLoading}) {
    return AuthState(
      token: token ?? this.token,
      identity: identity ?? this.identity,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final authProvider = StateNotifierProvider<AuthProvider, AuthState>((ref) {
  return AuthProvider();
});

// Auth Controller
final identityControllerProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController(text: '');
  ref.onDispose(() => controller.dispose());
  return controller;
});
final passwordControllerProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController(text: '');
  ref.onDispose(() => controller.dispose());
  return controller;
});
