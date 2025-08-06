import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rebill_flutter/core/constants/app_constants.dart';
import 'package:rebill_flutter/features/login/models/staff_account.dart';

class StaffAccountState {
  final List<StaffAccount> outlets;
  final bool isLoading;
  final String? errorMessage;

  StaffAccountState({
    this.outlets = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  StaffAccountState copyWith({
    List<StaffAccount>? outlets,
    bool? isLoading,
    String? errorMessage,
  }) {
    return StaffAccountState(
      outlets: outlets ?? this.outlets,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class StaffAccountNotifier extends StateNotifier<StaffAccountState> {
  final Dio dio = Dio();
  final FlutterSecureStorage storage = FlutterSecureStorage();

  StaffAccountNotifier() : super(StaffAccountState());

  Future<void> fetchStaffAccounts() async {
    try {
      // Set loading state
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Get token from secure storage
      final token = await storage.read(key: AppConstants.authTokenKey);

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Configure request with token
      dio.options.headers['Authorization'] = token;

      // Fetch staff accounts
      final response = await dio.get(
        '${AppConstants.baseUrl}${AppConstants.service}${AppConstants.apiVersion}masterdata/staff-accounts',
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      // Check response
      if (response.statusCode == 200) {
        final List<dynamic> outletList = response.data['data'] ?? [];
        final outlets =
            outletList
                .map((outletJson) => StaffAccount.fromJson(outletJson))
                .toList();

        // Update state with fetched outlets
        state = state.copyWith(outlets: outlets, isLoading: false);
      } else {
        // Handle error response
        final errorMessage =
            response.data['message'] ?? 'Failed to fetch staff accounts';
        state = state.copyWith(isLoading: false, errorMessage: errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Handle any exceptions
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  // Get staff for a specific outlet
  List<Staff> getStaffForOutlet(int outletId) {
    final outlet = state.outlets.firstWhere(
      (outlet) => outlet.id == outletId,
      orElse: () => StaffAccount(id: -1, name: '', staff: []),
    );
    return outlet.staff;
  }
}

// Provider for staff accounts
final staffAccountProvider =
    StateNotifierProvider<StaffAccountNotifier, StaffAccountState>((ref) {
      return StaffAccountNotifier();
    });
