import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/middleware/auth_middleware.dart';

class AuthProvider extends StateNotifier<AuthState> {
  AuthProvider() : super(AuthState());
  AuthMiddleware authMiddleware = AuthMiddleware();

  Future<void> login(String identity, String password) async {
    await authMiddleware.login(identity, password);
  }
}

class AuthState {
  final String? token;
  final String? identity;

  AuthState({this.token, this.identity});
}

final authProvider = StateNotifierProvider<AuthProvider, AuthState>((ref) {
  return AuthProvider();
});
