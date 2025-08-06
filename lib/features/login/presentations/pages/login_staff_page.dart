import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rebill_flutter/core/providers/orientation_provider.dart';
import 'package:rebill_flutter/core/theme/app_theme.dart';
import 'package:rebill_flutter/core/widgets/app_snackbar.dart';
import 'package:rebill_flutter/core/widgets/app_text_field.dart';
import 'package:rebill_flutter/features/login/providers/auth_provider.dart';
import 'package:rebill_flutter/features/login/providers/staff_account_provider.dart';
import 'package:rebill_flutter/features/login/models/staff_account.dart';
import 'package:go_router/go_router.dart';
import 'package:rebill_flutter/core/constants/app_constants.dart';

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
      ref.read(staffAccountProvider.notifier).fetchStaffAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLandscape = ref.watch(orientationProvider);
    final isLoading = ref.watch(authProvider).isLoading;
    final staffAccountState = ref.watch(staffAccountProvider);

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
                    LoginStaffComponent(outlets: staffAccountState.outlets),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading || staffAccountState.isLoading)
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
    // Listen to PIN changes for auto-login
    pinController.addListener(onPinChanged);
  }

  @override
  void dispose() {
    pinController.removeListener(onPinChanged);
    pinController.dispose();
    super.dispose();
  }

  void onPinChanged() {
    final pin = pinController.text;

    // Check if PIN is exactly 6 digits
    if (pin.length == 6) {
      // Validate PIN format (only numbers)
      if (RegExp(r'^[0-9]{6}$').hasMatch(pin)) {
        // Auto-login after a short delay to show the last digit
        Future.delayed(const Duration(milliseconds: 0), () {
          if (mounted) {
            _validateAndLogin();
          }
        });
      } else {
        // Clear PIN if it contains non-numeric characters
        pinController.clear();
      }
    }
  }

  Future<void> _validateAndLogin() async {
    try {
      // Validasi input
      if (selectedOutlet == null) {
        FocusScope.of(context).unfocus();
        AppSnackbar.showError(
          context,
          ttile: 'Outlet Belum Dipilih',
          message: 'Pilih outlet terlebih dahulu',
        );
        pinController.clear();
        return;
      }

      if (selectedStaff == null) {
        // Tutup keyboard dan tampilkan error
        FocusScope.of(context).unfocus();

        AppSnackbar.showError(
          context,
          message: 'Pilih staff terlebih dahulu',
          ttile: 'Staff Belum Dipilih',
        );
        pinController.clear();
        return;
      }

      // Proses login staff
      await ref
          .read(authProvider.notifier)
          .loginStaff(
            selectedOutlet!.id.toString(),
            selectedStaff!.id.toString(),
            pinController.text,
          );

      // Close Keyboard
      FocusScope.of(context).unfocus();

      ref.read(authProvider.notifier).setIsLoading(true);
      await Future.delayed(const Duration(milliseconds: 3000));

      if (!context.mounted) return;
      context.go(AppConstants.homeRoute);
    } catch (e) {
      if (!context.mounted) return;

      // Tutup keyboard dan clear PIN on error
      FocusScope.of(context).unfocus();
      pinController.clear();

      AppSnackbar.showError(context, message: 'Wrong pin, try again');
    }
  }

  Future<void> loginStaff() async {
    try {
      // Close Keyboard
      FocusScope.of(context).unfocus();

      // Validate Input
      if (selectedOutlet == null) {
        // Close Keyboard
        FocusScope.of(context).unfocus();

        AppSnackbar.showError(
          context,
          message: 'Pilih outlet terlebih dahulu',
          ttile: 'Outlet Belum Dipilih',
        );
        return;
      }

      if (selectedStaff == null) {
        // Close keyboard and show error
        FocusScope.of(context).unfocus();

        AppSnackbar.showError(
          context,
          message: 'Pilih staff terlebih dahulu',
          ttile: 'Staff Belum Dipilih',
        );
        return;
      }

      // Staff Login Process
      await ref
          .read(authProvider.notifier)
          .loginStaff(
            selectedOutlet!.id.toString(),
            selectedStaff!.id.toString(),
            pinController.text,
          );

      ref.read(authProvider.notifier).setIsLoading(true);
      await Future.delayed(const Duration(milliseconds: 1000));

      if (!context.mounted) return;
      context.go(AppConstants.homeRoute);
    } catch (e) {
      if (!context.mounted) return;

      // Tutup keyboard dan tampilkan error
      FocusScope.of(context).unfocus();
      await Future.delayed(const Duration(seconds: 3));
      AppSnackbar.showError(
        context,
        message: e.toString(),
        ttile: 'Login Gagal',
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
                  // Dropdown Outlet dengan PopupMenuButton
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
                        maxHeight:
                            3.5 * 50, // 3 item penuh + setengah item ke-4
                      ),
                      color: Colors.white, // background putih
                      itemBuilder: (BuildContext context) {
                        return widget.outlets.map<PopupMenuEntry<StaffAccount>>(
                          (outlet) {
                            return PopupMenuItem<StaffAccount>(
                              value: outlet,
                              height: 48, // tinggi item
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
                              color: theme.colorScheme.primary,
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

                  // Dropdown Staff dengan PopupMenuButton
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: PopupMenuButton<Staff>(
                      offset: const Offset(0, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabled: selectedOutlet != null,
                      constraints: const BoxConstraints(
                        minWidth: 200,
                        maxWidth: 300,
                        maxHeight:
                            3.5 * 48, // 3 item penuh + setengah item ke-4
                      ),
                      color: Colors.white, // background putih
                      itemBuilder: (BuildContext context) {
                        final staffList =
                            selectedOutlet == null ? [] : selectedOutlet!.staff;
                        return staffList.map<PopupMenuEntry<Staff>>((staff) {
                          return PopupMenuItem<Staff>(
                            value: staff,
                            height: 48, // tinggi item
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
                                  selectedOutlet != null
                                      ? theme.colorScheme.primary
                                      : Colors.grey[400],
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                selectedStaff?.name ?? 'Pilih Staff',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color:
                                      selectedStaff != null
                                          ? Colors.black87
                                          : Colors.grey[600],
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down_rounded,
                              color:
                                  selectedOutlet != null
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

                  // Input PIN
                  AppTextField(
                    obscureText: true,
                    controller: pinController,
                    showLabel: false,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    prefix: Icon(Icons.pin, color: theme.colorScheme.primary),
                    hintText: 'Masukkan PIN (6 digit)',
                    constraints: const BoxConstraints(maxHeight: 60),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    onChanged: (value) {
                      // Additional validation to ensure only numbers
                      if (value.isNotEmpty &&
                          !RegExp(r'^[0-9]*$').hasMatch(value)) {
                        // Remove non-numeric characters
                        final numericOnly = value.replaceAll(
                          RegExp(r'[^0-9]'),
                          '',
                        );
                        pinController.value = TextEditingValue(
                          text: numericOnly,
                          selection: TextSelection.collapsed(
                            offset: numericOnly.length,
                          ),
                        );
                      }
                    },
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
