import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rebill_flutter/core/constants/app_constants.dart';
import 'package:rebill_flutter/core/widgets/app_snackbar.dart';
import 'package:rebill_flutter/features/login/providers/staff_auth_provider.dart';

class OwnerLoginSplashPage extends ConsumerStatefulWidget {
  const OwnerLoginSplashPage({super.key});

  @override
  ConsumerState<OwnerLoginSplashPage> createState() =>
      _OwnerLoginSplashPageState();
}

class _OwnerLoginSplashPageState extends ConsumerState<OwnerLoginSplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataAndProceed();
    });
  }

  Future<void> _loadDataAndProceed() async {
    try {
      final fecthDataFuture =
          ref.read(staffAuthProvider.notifier).loadOrFetchStaffAccounts();

      final minDelayFuture = Future.delayed(const Duration(milliseconds: 1500));
      await Future.wait([fecthDataFuture, minDelayFuture]);

      if (mounted) {
        context.go(AppConstants.loginStaffPage);
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(
          context,
          message: 'Failed to load data: ${e.toString()}',
          ttile: 'Connection Error',
        );
        context.go(AppConstants.loginPage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: theme.colorScheme.primary,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/rLogo.png',
                height: 96,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
