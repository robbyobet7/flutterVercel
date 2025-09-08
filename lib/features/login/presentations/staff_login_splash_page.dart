// file: features/login/pages/staff_login_splash_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rebill_flutter/core/constants/app_constants.dart';
// IMPORT PROVIDER PRELOADER ANDA
import 'package:rebill_flutter/core/providers/initial_data_provider.dart';

class StaffLoginSplashPage extends ConsumerWidget {
  const StaffLoginSplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. "Tonton" state dari preloader provider.
    //    Saat halaman ini dibangun, Riverpod akan otomatis menjalankan FutureProvider.
    final preloaderState = ref.watch(initialDataPreloaderProvider);

    // 2. Gunakan .when untuk secara reaktif menampilkan UI yang sesuai.
    return Scaffold(
      body: preloaderState.when(
        // === STATE LOADING ===
        // Selama data masih dimuat, tampilkan splash screen Anda.
        loading:
            () => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/ReBillPro.png', height: 300),
                  const CircularProgressIndicator(),
                ],
              ),
            ),
        error:
            (error, stackTrace) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Gagal memuat data: $error'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(initialDataPreloaderProvider);
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),

        data: (_) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(AppConstants.homeRoute);
          });

          return Center(
            child: Image.asset('assets/images/ReBillPro.png', height: 300),
          );
        },
      ),
    );
  }
}
