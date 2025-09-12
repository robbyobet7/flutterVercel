import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rebill_flutter/core/constants/app_constants.dart';
import 'package:rebill_flutter/core/middleware/auth_middleware.dart';
import 'package:rebill_flutter/core/middleware/rewards_middleware.dart';
import 'package:rebill_flutter/core/providers/bill_provider.dart';
import 'package:rebill_flutter/core/providers/cart_provider.dart';
import 'package:rebill_flutter/core/providers/product_provider.dart';
import 'package:rebill_flutter/core/providers/products_providers.dart';
import 'package:rebill_flutter/features/login/models/staff_account.dart';
import 'package:rebill_flutter/features/main-bill/constants/bill_constants.dart';
import 'package:rebill_flutter/features/main-bill/providers/main_bill_provider.dart';

class StaffAuthState {
  final String? token;
  final String? identity;
  final bool isLoading;
  final List<StaffAccount> outlets;
  final bool accountsLoading;
  final String? accountsError;
  final Staff? loggedInStaff;

  const StaffAuthState({
    this.token,
    this.identity,
    this.isLoading = false,
    this.outlets = const [],
    this.accountsLoading = false,
    this.accountsError,
    this.loggedInStaff,
  });

  StaffAuthState copyWith({
    String? token,
    String? identity,
    bool? isLoading,
    List<StaffAccount>? outlets,
    bool? accountsLoading,
    String? accountsError,
    Staff? loggedInStaff,
  }) {
    return StaffAuthState(
      token: token ?? this.token,
      identity: identity ?? this.identity,
      isLoading: isLoading ?? this.isLoading,
      outlets: outlets ?? this.outlets,
      accountsLoading: accountsLoading ?? this.accountsLoading,
      accountsError: accountsError ?? this.accountsError,
      loggedInStaff: loggedInStaff ?? this.loggedInStaff,
    );
  }
}

class StaffAuthProvider extends StateNotifier<StaffAuthState> {
  final Ref ref;
  late final AuthMiddleware authMiddleware;
  Timer? _refreshTokenTimer;
  final Duration cacheDuration = const Duration(hours: 1);

  StaffAuthProvider(this.ref) : super(const StaffAuthState()) {
    authMiddleware = AuthMiddleware(ref);
  }

  @override
  void dispose() {
    stopRefreshTokenTimer();
    super.dispose();
  }

  Future<void> loginStaff(
    StaffAccount outlet,
    Staff staff,
    String password,
  ) async {
    try {
      final storage = FlutterSecureStorage();
      await authMiddleware.loginStaff(
        outlet.id.toString(),
        staff.id.toString(),
        password,
      );

      state = state.copyWith(
        token: await storage.read(key: AppConstants.authTokenStaffKey),
        identity: staff.id.toString(),
        loggedInStaff: staff,
      );

      startRefreshTokenTimer();

      // Refresh products after login
      try {
        await ref.read(paginatedProductsProvider.notifier).refresh();
      } catch (_) {}
      ref.invalidate(availableCategoriesProvider);
    } catch (e) {
      rethrow;
    }
  }

  // Load or fecth staff accounts
  Future<void> loadOrFetchStaffAccounts() async {
    final storage = FlutterSecureStorage();

    try {
      final cachedDataJson = await storage.read(
        key: AppConstants.staffAccountsCacheKey,
      );
      final cachedTimeStamp = await storage.read(
        key: AppConstants.staffAccountsCacheTimestampKey,
      );

      if (cachedDataJson != null && cachedTimeStamp != null) {
        final cacheTime = DateTime.parse(cachedTimeStamp);
        final bool isCacheFresh =
            DateTime.now().difference(cacheTime) < cacheDuration;

        if (isCacheFresh) {
          final List<dynamic> outletList = jsonDecode(cachedDataJson);
          final outlets =
              outletList
                  .map((outletJson) => StaffAccount.fromJson(outletJson))
                  .toList();
          state = state.copyWith(outlets: outlets, accountsLoading: false);
          return;
        }
      }
    } catch (e) {
      debugPrint("Could not read from cache: $e");
    }
    debugPrint("Cache is stale or not found. Fecthing from network...");
    await fetchStaffAccountsFromApi();
  }

  Future<void> fetchStaffAccountsFromApi() async {
    state = state.copyWith(accountsLoading: true, accountsError: null);
    final storage = FlutterSecureStorage();

    try {
      final token = await storage.read(key: AppConstants.authTokenKey);
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final dio = ref.read(dioProvider);
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
        await storage.write(
          key: AppConstants.staffAccountsCacheKey,
          value: jsonEncode(outletList),
        );
        await storage.write(
          key: AppConstants.staffAccountsCacheTimestampKey,
          value: DateTime.now().toIso8601String(),
        );
        debugPrint("Staff accounts fecthed from API and saved to cache.");
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

    ref
        .read(mainBillProvider.notifier)
        .setMainBill(MainBillComponent.defaultComponent);
    ref.read(cartProvider.notifier).clearCart();
    ref.read(billProvider.notifier).clearSelectedBill();
    ref.read(customerTypeProvider.notifier).setCustomerType(CustomerType.guest);
    ref.read(knownIndividualProvider.notifier).setKnownIndividual(null);
    ref.invalidate(productMiddlewareProvider);
    await ref.read(paginatedProductsProvider.notifier).refresh();
    ref.invalidate(availableCategoriesProvider);
  }
}

final staffAuthProvider =
    StateNotifierProvider<StaffAuthProvider, StaffAuthState>(
      (ref) => StaffAuthProvider(ref),
    );
