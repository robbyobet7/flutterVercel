import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/utils/router.dart';
import 'core/providers/orientation_provider.dart';
import 'core/utils/app_lifecycle_manager.dart';
import 'core/widgets/unfocus_on_tap.dart';
import 'features/login/providers/owner_auth_provider.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Set preferred orientations for better performance
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Optimize system UI for better performance
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      // Check if user is already logged in
      final isLoggedIn = await ref.read(authProvider.notifier).isLoggedIn();

      if (isLoggedIn) {
        // User is logged in, initiate refresh while splash is visible
        await ref.read(authProvider.notifier).refreshTokenOwner();
      }
    } catch (e) {
      // Error handling handled in AuthProvider
    } finally {
      // Remove native splash after initialization finished
      FlutterNativeSplash.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);

    // Use a safer approach for orientation detection
    if (context.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          initOrientationDetection(context, ref);
        }
      });
    }

    return AppLifecycleManager(
      child: UnfocusOnTap(
        child: MaterialApp.router(
          title: AppConstants.appName,
          themeMode: themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          routerDelegate: router.routerDelegate,
          routeInformationParser: router.routeInformationParser,
          routeInformationProvider: router.routeInformationProvider,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
