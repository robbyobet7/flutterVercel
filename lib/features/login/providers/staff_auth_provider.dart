import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rebill_flutter/core/constants/app_constants.dart';
import 'package:rebill_flutter/core/middleware/auth_middleware.dart';
import 'package:rebill_flutter/core/providers/products_providers.dart';
import 'package:rebill_flutter/features/login/models/staff_account.dart';

class StaffAuthState {
  final String? token;
  final String? identity;
  final bool isLoading; // UI loading (e.g., navigating after login)
  final List<StaffAccount> outlets; // fetched outlets for staff selection
  final bool accountsLoading; // loading state for fetching outlets
  final String? accountsError;

  const StaffAuthState({
    this.token,
    this.identity,
    this.isLoading = false,
    this.outlets = const [],
    this.accountsLoading = false,
    this.accountsError,
  });

  StaffAuthState copyWith({
    String? token,
    String? identity,
    bool? isLoading,
    List<StaffAccount>? outlets,
    bool? accountsLoading,
    String? accountsError,
  }) {
    return StaffAuthState(
      token: token ?? this.token,
      identity: identity ?? this.identity,
      isLoading: isLoading ?? this.isLoading,
      outlets: outlets ?? this.outlets,
      accountsLoading: accountsLoading ?? this.accountsLoading,
      accountsError: accountsError ?? this.accountsError,
    );
  }
}

class StaffAuthProvider extends StateNotifier<StaffAuthState> {
  final Ref ref;
  StaffAuthProvider(this.ref) : super(const StaffAuthState());

  final AuthMiddleware authMiddleware = AuthMiddleware();
  Timer? _refreshTokenTimer;
  final Dio dio = Dio();

  @override
  void dispose() {
    stopRefreshTokenTimer();
    super.dispose();
  }

  Future<void> loginStaff(
    String outletId,
    String staffId,
    String password,
  ) async {
    try {
      final storage = FlutterSecureStorage();
      await authMiddleware.loginStaff(outletId, staffId, password);

      state = state.copyWith(
        token: await storage.read(key: AppConstants.authTokenStaffKey),
        identity: staffId,
      );

      startRefreshTokenTimer();

      // Refresh products after login
      try {
        ref.read(productMiddlewareProvider).refreshProducts();
      } catch (_) {}
      ref.invalidate(availableProductsProvider);
      ref.invalidate(availableCategoriesProvider);
    } catch (e) {
      rethrow;
    }
  }

  // Merge: fetch staff accounts (previously in staff_account_provider)
  Future<void> fetchStaffAccounts() async {
    try {
      state = state.copyWith(accountsLoading: true, accountsError: null);

      final storage = FlutterSecureStorage();
      final token = await storage.read(key: AppConstants.authTokenKey);
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      dio.options.headers['Authorization'] = token;

      final response = await dio.get(
        '${AppConstants.baseUrl}${AppConstants.service}${AppConstants.apiVersion}masterdata/staff-accounts',
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> outletList = response.data['data'] ?? [];
        final outlets =
            outletList
                .map((outletJson) => StaffAccount.fromJson(outletJson))
                .toList();
        state = state.copyWith(outlets: outlets, accountsLoading: false);
      } else {
        final errorMessage =
            response.data['message'] ?? 'Failed to fetch staff accounts';
        state = state.copyWith(
          accountsLoading: false,
          accountsError: errorMessage,
        );
        throw Exception(errorMessage);
      }
    } catch (e) {
      state = state.copyWith(
        accountsLoading: false,
        accountsError: e.toString(),
      );
      rethrow;
    }
  }

  List<Staff> getStaffForOutlet(int outletId) {
    final outlet = state.outlets.firstWhere(
      (o) => o.id == outletId,
      orElse: () => StaffAccount(id: -1, name: '', staff: []),
    );
    return outlet.staff;
  }

  void startRefreshTokenTimer() {
    stopRefreshTokenTimer();
    () async {
      try {
        await refreshTokenStaff();
      } catch (e) {
        debugPrint('Initial staff token refresh failed: $e');
      }
    }();
    _refreshTokenTimer = Timer.periodic(const Duration(minutes: 15), (_) async {
      await refreshTokenStaff();
      debugPrint('Refresh token timer started');
    });
  }

  void stopRefreshTokenTimer() {
    _refreshTokenTimer?.cancel();
    _refreshTokenTimer = null;
  }

  Future<void> refreshTokenStaff() async {
    try {
      final secureStorage = FlutterSecureStorage();
      final currentToken = await secureStorage.read(
        key: AppConstants.authTokenStaffKey,
      );
      final refreshTokenValue = await secureStorage.read(
        key: AppConstants.refreshTokenStaffKey,
      );

      if (currentToken == null || refreshTokenValue == null) {
        debugPrint('Staff token or refresh token missing, stopping timer');
        stopRefreshTokenTimer();
        return;
      }

      await authMiddleware.refreshTokenStaff();
      final newToken = await secureStorage.read(
        key: AppConstants.authTokenStaffKey,
      );
      if (newToken != null && newToken.isNotEmpty) {
        state = state.copyWith(token: newToken);
      }
    } catch (e) {
      debugPrint('Error in refresh token: $e');
      stopRefreshTokenTimer();
    }
  }

  void setIsLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  Future<void> logoutStaff() async {
    stopRefreshTokenTimer();
    final secureStorage = FlutterSecureStorage();
    await secureStorage.delete(key: AppConstants.authTokenStaffKey);
    await secureStorage.delete(key: AppConstants.refreshTokenStaffKey);
    await secureStorage.delete(key: AppConstants.userDataKey);

    state = const StaffAuthState();

    ref.invalidate(productMiddlewareProvider);
    ref.invalidate(availableProductsProvider);
    ref.invalidate(availableCategoriesProvider);
  }

  bool isValidPinFormat(String pin) {
    return RegExp(r'^[0-9]{6}$').hasMatch(pin);
  }

  bool shouldAutoLogin(String pin) {
    return pin.length == 6 && isValidPinFormat(pin);
  }
}

final staffAuthProvider =
    StateNotifierProvider<StaffAuthProvider, StaffAuthState>(
      (ref) => StaffAuthProvider(ref),
    );
