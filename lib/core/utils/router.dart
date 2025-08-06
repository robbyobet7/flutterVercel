import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rebill_flutter/features/login/presentations/pages/login_page.dart';
import 'package:rebill_flutter/features/login/presentations/pages/login_staff_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../constants/app_constants.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppConstants.loginPage,
    routes: [
      GoRoute(
        path: AppConstants.homeRoute,
        builder: (context, state) => const HomePage(),
      ),

      GoRoute(
        path: AppConstants.loginPage,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppConstants.loginStaffPage,
        builder: (context, state) => const LoginStaffPage(),
      ),
    ],

    errorBuilder:
        (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: Center(
            child: Text('Route not found: ${state.matchedLocation}'),
          ),
        ),
  );
});
