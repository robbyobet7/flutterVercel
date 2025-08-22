import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rebill_flutter/core/providers/orientation_provider.dart';
import 'package:rebill_flutter/core/theme/app_theme.dart';
import 'package:rebill_flutter/core/widgets/app_snackbar.dart';
import 'package:rebill_flutter/features/login/providers/staff_auth_provider.dart';
import 'package:rebill_flutter/features/login/models/staff_account.dart';
import 'package:go_router/go_router.dart';
import 'package:rebill_flutter/core/constants/app_constants.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter/services.dart';

class LoginStaffPage extends ConsumerStatefulWidget {
  const LoginStaffPage({super.key});

  @override
  ConsumerState<LoginStaffPage> createState() => _LoginStaffPageState();
}

class _LoginStaffPageState extends ConsumerState<LoginStaffPage> {
  @override
  void initState() {
    super.initState();
    // Fetch staff accounts when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(staffAuthProvider.notifier).fetchStaffAccounts();
      debugPrint('');
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLandscape = ref.watch(orientationProvider);
    final isLoading = ref.watch(staffAuthProvider).isLoading;
    final staffState = ref.watch(staffAuthProvider);

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
                    LoginStaffComponent(outlets: staffState.outlets),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading || staffState.accountsLoading)
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

class LoginStaffComponent extends ConsumerStatefulWidget {
  final List<StaffAccount> outlets;

  const LoginStaffComponent({super.key, required this.outlets});

  @override
  ConsumerState<LoginStaffComponent> createState() =>
      _LoginStaffComponentState();
}

class _LoginStaffComponentState extends ConsumerState<LoginStaffComponent> {
  StaffAccount? selectedOutlet;
  Staff? selectedStaff;
  final TextEditingController pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Ensure no field is focused when entering this page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
    });
  }

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  Future<void> validateAndLogin() async {
    try {
      // Validasi input
      if (selectedOutlet == null) {
        FocusScope.of(context).unfocus();
        AppSnackbar.showError(
          context,
          ttile: 'Outlet not selected',
          message: 'Select the outlet first',
        );
        pinController.clear();
        return;
      }

      if (selectedStaff == null) {
        FocusScope.of(context).unfocus();

        AppSnackbar.showError(
          context,
          ttile: 'Staff not yet selected',
          message: 'Select staff first',
        );
        pinController.clear();
        return;
      }

      // Proses login staff
      await ref
          .read(staffAuthProvider.notifier)
          .loginStaff(
            selectedOutlet!.id.toString(),
            selectedStaff!.id.toString(),
            pinController.text,
          );

      if (!mounted) return;

      FocusScope.of(context).unfocus();

      ref.read(staffAuthProvider.notifier).setIsLoading(true);
      await Future.delayed(const Duration(milliseconds: 3000));

      if (!mounted) return;
      context.go(AppConstants.ownerLoginSplashRoute);
    } catch (e) {
      if (!mounted) return;

      // Close Keyboard and pin error
      FocusScope.of(context).unfocus();
      pinController.clear();

      AppSnackbar.showError(context, message: 'Wrong pin, try again');
    }
  }

  Future<void> loginStaff() async {
    try {
      FocusScope.of(context).unfocus();

      // Validate Input
      if (selectedOutlet == null) {
        FocusScope.of(context).unfocus();

        AppSnackbar.showError(
          context,
          message: 'Select the outlet first',
          ttile: 'Outlet not selected',
        );
        return;
      }

      if (selectedStaff == null) {
        FocusScope.of(context).unfocus();

        AppSnackbar.showError(
          context,
          message: 'Select staff first',
          ttile: 'Staff not yet selected',
        );
        return;
      }

      // Staff Login Process
      await ref
          .read(staffAuthProvider.notifier)
          .loginStaff(
            selectedOutlet!.id.toString(),
            selectedStaff!.id.toString(),
            pinController.text,
          );

      if (!mounted) return;

      ref.read(staffAuthProvider.notifier).setIsLoading(true);
      await Future.delayed(const Duration(milliseconds: 1000));

      if (!mounted) return;
      context.go(AppConstants.homeRoute);
    } catch (e) {
      if (!mounted) return;

      FocusScope.of(context).unfocus();
      await Future.delayed(const Duration(seconds: 3));
      AppSnackbar.showError(
        context,
        message: e.toString(),
        ttile: 'Login Failed',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLandscape = ref.watch(orientationProvider);

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
              'Login Staff',
              style: theme.textTheme.displayLarge?.copyWith(
                color: Colors.black,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 12),
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
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              child: Column(
                spacing: 15,
                children: [
                  // Outlet Dropdown
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: PopupMenuButton<StaffAccount>(
                      offset: const Offset(0, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 200,
                        maxWidth: 300,
                        maxHeight: 3.5 * 50,
                      ),
                      color: Colors.white,
                      itemBuilder: (BuildContext context) {
                        return widget.outlets.map<PopupMenuEntry<StaffAccount>>(
                          (outlet) {
                            return PopupMenuItem<StaffAccount>(
                              value: outlet,
                              height: 48,
                              child: Text(
                                outlet.name,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.black,
                                ),
                              ),
                            );
                          },
                        ).toList();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.store_outlined,
                              color:
                                  selectedOutlet != null
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.scrim.withOpacity(
                                        0.2,
                                      ),
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                selectedOutlet?.name ?? 'Select Outlet',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color:
                                      selectedOutlet != null
                                          ? Colors.black87
                                          : Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down_rounded,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                      onSelected: (StaffAccount outlet) {
                        setState(() {
                          selectedOutlet = outlet;
                          // Reset staff selection when outlet changes
                          selectedStaff = null;
                        });
                      },
                    ),
                  ),

                  // Staff Dropdown
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: PopupMenuButton<Staff>(
                      offset: const Offset(0, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabled: selectedOutlet != null,
                      constraints: const BoxConstraints(
                        minWidth: 200,
                        maxWidth: 300,
                        maxHeight: 3.5 * 50,
                      ),
                      color: Colors.white,
                      itemBuilder: (BuildContext context) {
                        final staffList =
                            selectedOutlet == null ? [] : selectedOutlet!.staff;
                        return staffList.map<PopupMenuEntry<Staff>>((staff) {
                          return PopupMenuItem<Staff>(
                            value: staff,
                            height: 48,
                            child: Text(
                              staff.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.black,
                              ),
                            ),
                          );
                        }).toList();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              color:
                                  selectedStaff != null
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.scrim.withOpacity(
                                        0.2,
                                      ),
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                selectedStaff?.name ?? 'Select Staff',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color:
                                      selectedStaff != null
                                          ? Colors.black87
                                          : Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down_rounded,
                              color:
                                  selectedStaff != null
                                      ? theme.colorScheme.primary
                                      : Colors.grey[400],
                            ),
                          ],
                        ),
                      ),
                      onSelected: (Staff staff) {
                        setState(() {
                          selectedStaff = staff;
                        });
                      },
                    ),
                  ),
                  Text(
                    'Input your pin',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.scrim.withOpacity(0.5),
                    ),
                  ),

                  // Input PIN with Pinput
                  Pinput(
                    length: 6,
                    controller: pinController,
                    obscureText: true,
                    obscuringCharacter: '●',
                    autofocus: false,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onCompleted: (pin) {
                      validateAndLogin();
                    },
                    defaultPinTheme: PinTheme(
                      width: 44,
                      height: 44,
                      textStyle:
                          theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.surfaceContainer,
                          ) ??
                          const TextStyle(color: Colors.grey),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: theme.colorScheme.scrim.withOpacity(0.2),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    focusedPinTheme: PinTheme(
                      width: 44,
                      height: 44,
                      textStyle:
                          theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.surfaceContainer,
                          ) ??
                          const TextStyle(color: Colors.grey),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onPrimary,
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    submittedPinTheme: PinTheme(
                      width: 44,
                      height: 44,
                      textStyle:
                          theme.textTheme.headlineSmall?.copyWith(
                            fontSize: 18,
                            color: theme.colorScheme.surface,
                          ) ??
                          const TextStyle(color: Colors.grey, fontSize: 18),

                      decoration: BoxDecoration(
                        color: theme.colorScheme.onPrimary,
                        border: Border.all(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
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
