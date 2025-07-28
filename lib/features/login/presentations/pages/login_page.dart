import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rebill_flutter/core/providers/orientation_provider.dart';
import 'package:rebill_flutter/core/theme/app_theme.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_text_field.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLandscape = ref.watch(orientationProvider);

    double boxWidth = isLandscape ? screenWidth * 0.3 : double.infinity;
    double boxHeight = isLandscape ? double.infinity : screenWidth * 0.5;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: screenWidth,
          height: screenHeight,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/login_background.webp'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
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
    );
  }
}

class LoginComponent extends ConsumerWidget {
  const LoginComponent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isLandscape = ref.watch(orientationProvider);

    double? boxWidth = isLandscape ? null : double.infinity;
    double? boxHeight = isLandscape ? double.infinity : null;

    return Expanded(
      child: Container(
        width: boxWidth,
        height: boxHeight,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(50),
            topRight: isLandscape ? Radius.circular(0) : Radius.circular(50),
            bottomLeft: isLandscape ? Radius.circular(50) : Radius.circular(0),
          ),
        ),
        child: Column(
          spacing: 24,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/icons/rebill_logo.svg', height: 70),
            Text('Login to your account', style: theme.textTheme.displayLarge),
            Container(
              decoration: BoxDecoration(
                boxShadow: AppTheme.kBoxShadow,
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              constraints: BoxConstraints(maxWidth: 370),
              padding: EdgeInsets.all(16),
              child: Column(
                spacing: 12,
                children: [
                  AppTextField(
                    controller: TextEditingController(),
                    showLabel: false,
                    prefix: Icon(
                      Icons.person,
                      color: theme.colorScheme.primary,
                    ),
                    hintText: 'Email Address or Username',
                  ),
                  AppTextField(
                    controller: TextEditingController(),
                    showLabel: false,
                    prefix: Icon(Icons.lock, color: theme.colorScheme.primary),
                    suffix: Icon(
                      Icons.visibility,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    hintText: 'Password',
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: 8,
                    children: [
                      AppButton(
                        onPressed: () {},
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
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                      AppButton(
                        onPressed: () {},
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
