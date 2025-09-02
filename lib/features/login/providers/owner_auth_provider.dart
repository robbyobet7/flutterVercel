import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rebill_flutter/core/constants/app_constants.dart';
import 'package:rebill_flutter/core/middleware/auth_middleware.dart';
import 'package:rebill_flutter/core/providers/product_provider.dart';
import 'package:rebill_flutter/core/providers/products_providers.dart';

class AuthProvider extends StateNotifier<AuthState> {
  final Ref ref;
  late final AuthMiddleware authMiddleware;

  AuthProvider(this.ref) : super(AuthState()) {
    authMiddleware = AuthMiddleware(ref);
  }

  // Login Owner
  Future<void> login(String identity, String password) async {
    try {
      await authMiddleware.login(identity, password);
    } catch (e) {
      rethrow;
    }
  }

  // Logout Owner
  Future<void> logoutOwner() async {
    // no-op for owner provider
    final secureStorage = FlutterSecureStorage();

    await secureStorage.delete(key: AppConstants.authTokenKey);
    await secureStorage.delete(key: AppConstants.refreshTokenOwnerKey);
    await secureStorage.delete(key: AppConstants.authTokenStaffKey);
    await secureStorage.delete(key: AppConstants.refreshTokenStaffKey);
    await secureStorage.delete(key: AppConstants.userDataKey);

    // Reset state
    state = AuthState();

    // Invalidate product-related providers so next login refetches
    ref.invalidate(productMiddlewareProvider);
    await ref.read(paginatedProductsProvider.notifier).refresh();
    ref.invalidate(availableCategoriesProvider);
  }

  // Validate PIN format
  bool isValidPinFormat(String pin) {
    return RegExp(r'^[0-9]{6}$').hasMatch(pin);
  }

  bool shouldAutoLogin(String pin) {
    return pin.length == 6 && isValidPinFormat(pin);
  }

  // Refresh Token Owner
  Future<void> refreshTokenOwner() async {
    try {
      final secureStorage = FlutterSecureStorage();
      final currentToken = await secureStorage.read(
        key: AppConstants.authTokenKey,
      );
      final refreshTokenValue = await secureStorage.read(
        key: AppConstants.refreshTokenOwnerKey,
      );

      // logout automatically as user might be on login page
      if (currentToken == null || refreshTokenValue == null) {
        debugPrint(
          'Token or Refresh Token missing, cannot refresh. Forcing logout.',
        );
        await logoutOwner();
        return;
      }

      // Try to refresh the token
      await authMiddleware.refreshTokenOwner();
      debugPrint("Owner token successfully refreshed by timer.");
    } catch (e) {
      debugPrint('Error in refresh token: $e');
      await logoutOwner();
      rethrow;
    }
  }

  // Get Token
  Future<String?> getToken() async {
    try {
      final secureStorage = FlutterSecureStorage();
      final tokenOwner = await secureStorage.read(
        key: AppConstants.authTokenKey,
      );

      if (tokenOwner != null && tokenOwner.isNotEmpty) {
        // If we have a valid token, ensure the refresh timer is running
        return tokenOwner;
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
    final tokenOwner = await getToken();
    return tokenOwner != null && tokenOwner.isNotEmpty;
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
  return AuthProvider(ref);
});

// Auth Owner Controller
final identityControllerProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController(text: 'premium123321');
  ref.onDispose(() => controller.dispose());
  return controller;
});

final passwordControllerProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController(text: 'bond666');
  ref.onDispose(() => controller.dispose());
  return controller;
});

final obscureProvider = StateProvider<bool>((ref) => true);
