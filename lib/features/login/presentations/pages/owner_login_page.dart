import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rebill_flutter/core/providers/orientation_provider.dart';
import 'package:rebill_flutter/core/theme/app_theme.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_snackbar.dart';
import 'package:rebill_flutter/core/widgets/app_text_field.dart';
import 'package:rebill_flutter/features/login/providers/owner_auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:rebill_flutter/core/constants/app_constants.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _didPrecache = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didPrecache) {
      precacheImage(
        const AssetImage('assets/images/login_background.webp'),
        context,
      );
      _didPrecache = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLandscape = ref.watch(orientationProvider);
    final Alignment backgroundImageAlignment;

    double boxWidth = isLandscape ? screenWidth * 0.3 : double.infinity;
    double boxHeight = isLandscape ? double.infinity : screenWidth * 0.5;

    if (isLandscape) {
      backgroundImageAlignment =
          screenWidth >= 1200
              ? Alignment(-3, 0)
              : screenWidth >= 800
              ? Alignment(-7, 0)
              : Alignment(-2, 0);
    } else {
      backgroundImageAlignment = Alignment(0, -1.2);
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        alignment: Alignment.centerRight,
        children: [
          SingleChildScrollView(
            child: Container(
              width: screenWidth,
              height: screenHeight,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/login_background.webp'),
                  alignment: backgroundImageAlignment,
                ),
              ),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(204),
                ),
                child: Flex(
                  direction: isLandscape ? Axis.horizontal : Axis.vertical,
                  children: [
                    SizedBox(width: boxWidth, height: boxHeight),
                    const LoginComponent(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum LoginType { dashboard, pos }

class LoginComponent extends ConsumerStatefulWidget {
  const LoginComponent({super.key});

  @override
  ConsumerState<LoginComponent> createState() => _LoginComponentState();
}

class _LoginComponentState extends ConsumerState<LoginComponent> {
  // State lokal untuk melacak tombol yang sedang loading
  LoginType? _loadingButton;

  // Fungsi generik untuk menangani proses login
  Future<void> _performLogin(LoginType type) async {
    if (_loadingButton != null) return; // Mencegah klik ganda

    FocusScope.of(context).unfocus();

    try {
      // Set state untuk menunjukkan tombol mana yang loading
      setState(() {
        _loadingButton = type;
      });

      // Panggil provider untuk melakukan login
      await ref
          .read(authProvider.notifier)
          .login(
            ref.read(identityControllerProvider).text,
            ref.read(passwordControllerProvider).text,
          );

      // Jeda singkat untuk UX
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;
      context.go(AppConstants.ownerLoginSplashRoute);
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.showError(context, message: e.toString());
    } finally {
      // Selalu reset state loading setelah selesai
      if (mounted) {
        setState(() {
          _loadingButton = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLandscape = ref.watch(orientationProvider);
    final isObscure = ref.watch(obscureProvider);
    final identityController = ref.watch(identityControllerProvider);
    final passwordController = ref.watch(passwordControllerProvider);
    final isPosLoading = _loadingButton == LoginType.pos;
    final primaryColor = theme.colorScheme.primary;

    double? boxWidth = isLandscape ? null : double.infinity;
    double? boxHeight = isLandscape ? double.infinity : null;

    return Expanded(
      child: Container(
        width: boxWidth,
        height: boxHeight,
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: isLandscape ? Radius.circular(0) : Radius.circular(40),
            bottomLeft: isLandscape ? Radius.circular(35) : Radius.circular(0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/icons/rebill_logo.svg', height: 70),
            const SizedBox(height: 24),
            Text(
              'Login to your account',
              style: theme.textTheme.displayLarge?.copyWith(
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                boxShadow: AppTheme.kBoxShadow,
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              constraints: BoxConstraints(
                maxWidth:
                    isLandscape
                        ? MediaQuery.of(context).size.width * 0.4
                        : MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 35),
              child: Column(
                children: [
                  AppTextField(
                    controller: identityController,
                    showLabel: false,
                    prefix: Icon(
                      Icons.person,
                      color: theme.colorScheme.primary,
                    ),
                    hintText: 'Email Address or Username',
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    obscureText: isObscure,
                    controller: passwordController,
                    showLabel: false,
                    prefix: Icon(Icons.lock, color: theme.colorScheme.primary),
                    suffix: IconButton(
                      onPressed: () {
                        ref.read(obscureProvider.notifier).state =
                            !isObscure; // Toggle password visibility
                      },
                      icon: Icon(
                        isObscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.blueGrey,
                      ),
                    ),
                    hintText: 'Password',
                  ),
                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width:
                          isLandscape
                              ? MediaQuery.of(context).size.width * 0.15
                              : MediaQuery.of(context).size.width * 0.25,
                      child:
                          isPosLoading
                              ? AppButton(
                                onPressed: null,
                                backgroundColor: Colors.white,
                                text: '',
                                child: SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: primaryColor,
                                  ),
                                ),
                              )
                              : AppButton(
                                onPressed: () => _performLogin(LoginType.pos),
                                backgroundColor: primaryColor,
                                text: 'Login POS',
                                textStyle: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
