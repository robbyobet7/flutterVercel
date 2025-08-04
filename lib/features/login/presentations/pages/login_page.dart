import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rebill_flutter/core/providers/orientation_provider.dart';
import 'package:rebill_flutter/core/theme/app_theme.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_snackbar.dart';
import 'package:rebill_flutter/core/widgets/app_text_field.dart';
import 'package:rebill_flutter/features/login/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:rebill_flutter/core/constants/app_constants.dart';

final obscureProvider = StateProvider<bool>((ref) => true);

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLandscape = ref.watch(orientationProvider);
    double boxWidth = isLandscape ? screenWidth * 0.3 : double.infinity;
    double boxHeight = isLandscape ? double.infinity : screenWidth * 0.5;

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
                  alignment:
                      isLandscape ? Alignment(-7, 0) : Alignment(0.0, -1.2),
                ),
              ),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.8),
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
          if (ref.watch(authProvider).isLoading)
            Container(
              width: screenWidth,
              height: screenHeight,
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class LoginComponent extends ConsumerWidget {
  const LoginComponent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final isLandscape = ref.watch(orientationProvider);
    final isObscure = ref.watch(obscureProvider);
    final identityController = ref.watch(identityControllerProvider);
    final passwordController = ref.watch(passwordControllerProvider);
    double? boxWidth = isLandscape ? null : double.infinity;
    double? boxHeight = isLandscape ? double.infinity : null;

    return Expanded(
      child: Container(
        width: boxWidth,
        height: boxHeight,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F4FD),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: isLandscape ? Radius.circular(0) : Radius.circular(40),
            bottomLeft: isLandscape ? Radius.circular(35) : Radius.circular(0),
          ),
        ),
        child: Column(
          spacing: 24,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/icons/rebill_logo.svg', height: 70),
            Text(
              'Login to your account',
              style: theme.textTheme.displayLarge?.copyWith(
                color: Colors.black,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                boxShadow: AppTheme.kBoxShadow,
                color: theme.colorScheme.onPrimaryContainer,
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
                spacing: 15,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: 8,
                    children: [
                      AppButton(
                        onPressed:
                            authState.isLoading
                                ? null
                                : () async {
                                  try {
                                    final success = await ref
                                        .read(authProvider.notifier)
                                        .login(
                                          identityController.text,
                                          passwordController.text,
                                        );
                                    if (!context.mounted) return;
                                    if (success) {
                                      context.go(AppConstants.homeRoute);
                                    } else {
                                      AppSnackbar.showError(
                                        context,
                                        message:
                                            'Login gagal. Periksa username dan password Anda.',
                                      );
                                    }
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    AppSnackbar.showError(
                                      context,
                                      message: 'Error: ${e.toString()}',
                                    );
                                  }
                                },
                        text: 'Login Dashboard',
                        backgroundColor: theme.colorScheme.primary,
                        textStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'or',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.surfaceContainer.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                      AppButton(
                        onPressed:
                            authState.isLoading
                                ? null
                                : () async {
                                  try {
                                    final success = await ref
                                        .read(authProvider.notifier)
                                        .login(
                                          identityController.text,
                                          passwordController.text,
                                        );
                                    if (!context.mounted) return;
                                    if (success) {
                                      context.go(AppConstants.homeRoute);
                                    } else {
                                      AppSnackbar.showError(
                                        context,
                                        message:
                                            'Login gagal. Periksa username dan password Anda.',
                                      );
                                    }
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    AppSnackbar.showError(
                                      context,
                                      message: 'Error: ${e.toString()}',
                                    );
                                  }
                                },
                        text: 'Login POS',
                        backgroundColor: theme.colorScheme.primary,
                        textStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
