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
          debugPrint('Running scheduled token refresh');
          await refreshToken();
        });
        debugPrint('Refresh token timer started successfully');
      } else {
        debugPrint('Initial token validation failed, not starting timer');
      }
    });
  }

  // Stop Refresh Token Timer
  void _stopRefreshTokenTimer() {
    _refreshTokenTimer?.cancel();
    _refreshTokenTimer = null;
  }

  // Login
  Future<void> login(String identity, String password) async {
    try {
      await authMiddleware.login(identity, password);
      _startRefreshTokenTimer();
    } catch (e) {
      rethrow;
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
  Future<void> refreshToken() async {
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
        debugPrint('Token missing during refresh attempt, logging out');
        await logout();
        throw Exception('Token missing during refresh attempt, logging out');
      }

      // Try to refresh the token
      await authMiddleware.refreshToken();

      debugPrint('Token refreshed successfully');
    } catch (e) {
      debugPrint('Error in refresh token: $e');
      await logout();
      rethrow;
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
        throw Exception('No valid token found in storage');
      }
    } catch (e) {
      debugPrint('Error getting token: $e');
      rethrow;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  void setIsLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
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

final obscureProvider = StateProvider<bool>((ref) => true);
