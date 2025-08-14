import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rebill_flutter/core/constants/app_constants.dart';

class OwnerLoginSplashPage extends ConsumerStatefulWidget {
  const OwnerLoginSplashPage({super.key});

  @override
  ConsumerState<OwnerLoginSplashPage> createState() =>
      _OwnerLoginSplashPageState();
}

class _OwnerLoginSplashPageState extends ConsumerState<OwnerLoginSplashPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _proceed();
  }

  Future<void> _proceed() async {
    // Simulasikan proses setelah login owner: load data ringan, dsb.
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    context.go(AppConstants.loginStaffPage);
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
