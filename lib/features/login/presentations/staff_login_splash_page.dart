import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rebill_flutter/core/constants/app_constants.dart';
import 'package:rebill_flutter/core/providers/initial_data_provider.dart';

class StaffLoginSplashPage extends ConsumerWidget {
  const StaffLoginSplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preloaderState = ref.watch(initialDataPreloaderProvider);

    return Scaffold(
      body: preloaderState.when(
        loading:
            () => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/R-Logo3.png', height: 120),
                  const SizedBox(height: 28),
                  const CircularProgressIndicator(),
                ],
              ),
            ),
        error:
            (error, stackTrace) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Failed to load data $error'),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(initialDataPreloaderProvider);
                    },
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),

        data: (_) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(AppConstants.homeRoute);
          });

          return Center(
            child: Image.asset('assets/images/R-Logo3.png', height: 120),
          );
        },
      ),
    );
  }
}
