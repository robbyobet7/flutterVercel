import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:rebill_flutter/core/middleware/auth_middleware.dart';

class AuthProvider extends StateNotifier<AuthState> {
  AuthProvider() : super(AuthState());
  AuthMiddleware authMiddleware = AuthMiddleware();

  Future<bool> login(String identity, String password) async {
    state = state.copyWith(isLoading: true);
    final token = await authMiddleware.login(identity, password);
    state = state.copyWith(isLoading: false);
    return token != null;
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
