import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rebill_flutter/features/login/presentations/pages/owner_login_page.dart';
import 'package:rebill_flutter/features/login/presentations/pages/staff_login_page.dart';
import 'package:rebill_flutter/features/login/presentations/staff_login_splash_page.dart';
import 'package:rebill_flutter/features/login/providers/owner_auth_provider.dart';
import 'package:rebill_flutter/features/login/providers/staff_auth_provider.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../constants/app_constants.dart';
import '../widgets/login_splash_page.dart';

CustomTransitionPage<T> buildPageWithFadeTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Fade Transition
      return FadeTransition(opacity: animation, child: child);
    },
    // Duration
    transitionDuration: const Duration(milliseconds: 300),
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  // Only listen to token changes to avoid unnecessary router rebuilds
  // Consider either owner or staff authenticated
  final isStaffAuthenticated = ref.watch(
    staffAuthProvider.select(
      (state) => state.token != null && state.token!.isNotEmpty,
    ),
  );

  final isAuthenticated = isStaffAuthenticated;

  return GoRouter(
    initialLocation: AppConstants.loginPage,

    routes: [
      GoRoute(
        path: AppConstants.homeRoute,
        pageBuilder:
            (context, state) => buildPageWithFadeTransition(
              context: context,
              state: state,
              child: const HomePage(),
            ),
      ),
      GoRoute(
        path: AppConstants.loginPage,
        pageBuilder:
            (context, state) => buildPageWithFadeTransition(
              context: context,
              state: state,
              child: const LoginPage(),
            ),
      ),
      GoRoute(
        path: AppConstants.loginStaffPage,
        pageBuilder:
            (context, state) => buildPageWithFadeTransition(
              context: context,
              state: state,
              child: const LoginStaffPage(),
            ),
      ),
      GoRoute(
        path: AppConstants.ownerLoginSplashRoute,
        pageBuilder:
            (context, state) => buildPageWithFadeTransition(
              context: context,
              state: state,
              child: const OwnerLoginSplashPage(),
            ),
      ),
      GoRoute(
        path: AppConstants.staffLoginSplashRoute,
        pageBuilder:
            (context, state) => buildPageWithFadeTransition(
              context: context,
              state: state,
              child: const StaffLoginSplashPage(),
            ),
      ),
    ],

    redirect: (context, state) {
      final destination = state.matchedLocation;

      final unprotectedRoutes = [
        AppConstants.loginPage,
        AppConstants.loginStaffPage,
        AppConstants.ownerLoginSplashRoute,
        AppConstants.staffLoginSplashRoute,
      ];

      final isGoingToUnprotectedRoute = unprotectedRoutes.contains(destination);

      // Allow access to owner splash while transitioning from login to staff selection
      if (!isAuthenticated && !isGoingToUnprotectedRoute) {
        return AppConstants.loginPage;
      }
      if (isAuthenticated &&
          (destination == AppConstants.loginPage ||
              destination == AppConstants.loginStaffPage)) {
        return AppConstants.staffLoginSplashRoute;
      }
      return null;
    },

    refreshListenable: GoRouterRefreshStream(ref),

    errorBuilder:
        (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: Center(
            child: Text('Route not found: ${state.matchedLocation}'),
          ),
        ),
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
    ref.listen(staffAuthProvider, (_, __) => notifyListeners());
  }
}
