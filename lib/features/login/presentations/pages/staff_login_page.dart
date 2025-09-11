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

class LoginStaffPage extends ConsumerWidget {
  const LoginStaffPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLandscape = ref.watch(orientationProvider);
    final staffState = ref.watch(staffAuthProvider);
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(width: boxWidth, height: boxHeight),
                    if (staffState.accountsLoading)
                      const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      )
                    else if (staffState.accountsError != null)
                      Expanded(
                        child: Center(
                          child: Text(
                            'Error: ${staffState.accountsError}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    else
                      LoginStaffComponent(outlets: staffState.outlets),
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

class LoginStaffComponent extends ConsumerStatefulWidget {
  final List<StaffAccount> outlets;
  const LoginStaffComponent({super.key, required this.outlets});

  @override
  ConsumerState<LoginStaffComponent> createState() =>
      _LoginStaffComponentState();
}

class _LoginStaffComponentState extends ConsumerState<LoginStaffComponent> {
  StaffAccount? _selectedOutlet;
  Staff? _selectedStaff;
  bool _isLoggingIn = false;
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  // Staff Login
  Future<void> _submitLogin() async {
    if (_isLoggingIn) return;
    FocusScope.of(context).unfocus();

    try {
      setState(() => _isLoggingIn = true);

      // Validation
      if (_selectedOutlet == null) {
        AppSnackbar.showError(context, message: 'Please Select an outlet.');
        return;
      }
      if (_selectedStaff == null) {
        AppSnackbar.showError(
          context,
          message: 'Please select a staff member.',
        );
        return;
      }
      if (_pinController.text.length < 6) {
        AppSnackbar.showError(context, message: 'Please enter a 6-digit PIN.');
        return;
      }

      await ref
          .read(staffAuthProvider.notifier)
          .loginStaff(_selectedOutlet!, _selectedStaff!, _pinController.text);

      if (mounted) {
        precacheImage(const AssetImage('assets/images/R-Logo3.png'), context);
      }

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        context.go(AppConstants.staffLoginSplashRoute);
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(
          context,
          message: e.toString(),
          ttile: 'Login Failed',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoggingIn = false);
        _pinController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLandscape = ref.watch(orientationProvider);
    final primaryColor = theme.colorScheme.primary;

    // Default theme for Pinput
    final defaultPinTheme = PinTheme(
      width: 44,
      height: 44,
      textStyle: theme.textTheme.headlineSmall?.copyWith(color: Colors.black87),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
    );

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF1F4FD),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: isLandscape ? Radius.circular(0) : Radius.circular(40),
            bottomLeft: isLandscape ? Radius.circular(35) : Radius.circular(0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/icons/rebill_logo.svg', height: 70),
            const SizedBox(height: 14),
            Text(
              'Login Staff',
              style: theme.textTheme.displayLarge?.copyWith(
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              margin: EdgeInsets.only(top: 12),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 30,
                ),
                child: Column(
                  children: [
                    _AdvancedDropdown<StaffAccount>(
                      label: _selectedOutlet?.name ?? 'Select Outlet',
                      icon: Icons.store_outlined,
                      items: widget.outlets,
                      itemBuilder: (outlet) => outlet.name,
                      onSelected: (selected) {
                        setState(() {
                          _selectedOutlet = selected;
                          _selectedStaff = null;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    _AdvancedDropdown<Staff>(
                      label: _selectedStaff?.name ?? 'Select Staff',
                      icon: Icons.person_outline_rounded,
                      items: _selectedOutlet?.staff ?? [],
                      isEnabled: _selectedOutlet != null,
                      itemBuilder: (staff) => staff.name,
                      onSelected: (selected) {
                        setState(() {
                          _selectedStaff = selected;
                        });
                        _pinFocusNode.requestFocus();
                      },
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Input your pin',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Input PIN with Pinput
                    Pinput(
                      length: 6,
                      focusNode: _pinFocusNode,
                      controller: _pinController,
                      obscureText: true,
                      obscuringCharacter: '●',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onCompleted: (pin) => _submitLogin(),
                      hapticFeedbackType: HapticFeedbackType.lightImpact,
                      defaultPinTheme: defaultPinTheme,
                      focusedPinTheme: defaultPinTheme.copyWith(
                        decoration: defaultPinTheme.decoration!.copyWith(
                          border: Border.all(color: primaryColor, width: 1),
                        ),
                      ),
                      submittedPinTheme: defaultPinTheme.copyWith(
                        decoration: defaultPinTheme.decoration!.copyWith(
                          border: Border.all(color: primaryColor, width: 2),
                        ),
                      ),
                      showCursor: !_isLoggingIn,
                      preFilledWidget:
                          _isLoggingIn
                              ? Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: primaryColor,
                                  ),
                                ),
                              )
                              : null,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdvancedDropdown<T> extends StatefulWidget {
  final String label;
  final IconData icon;
  final List<T> items;
  final void Function(T) onSelected;
  final String Function(T) itemBuilder;
  final bool isEnabled;

  const _AdvancedDropdown({
    super.key,
    required this.label,
    required this.icon,
    required this.items,
    required this.onSelected,
    required this.itemBuilder,
    this.isEnabled = true,
  });

  @override
  State<_AdvancedDropdown<T>> createState() => _AdvancedDropdownState<T>();
}

class _AdvancedDropdownState<T> extends State<_AdvancedDropdown<T>>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isMenuOpen = false;
  final double _menuWidth = 220.0;
  final double _itemHeight = 48.0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _hideMenu();
    _animationController.dispose();
    super.dispose();
  }

  void _showMenu() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isMenuOpen = true);
    _animationController.forward();
  }

  void _hideMenu() {
    if (_isMenuOpen) {
      _animationController.reverse().then((value) {
        if (_overlayEntry != null) {
          _overlayEntry!.remove();
          _overlayEntry = null;
        }
        if (mounted) {
          setState(() => _isMenuOpen = false);
        }
      });
    }
  }

  void _toggleMenu() {
    if (_isMenuOpen) {
      _hideMenu();
    } else {
      _showMenu();
    }
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _hideMenu,
                behavior: HitTestBehavior.translucent,
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomRight,
              followerAnchor: Alignment.topRight,
              offset: const Offset(0, 8),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: _menuWidth,
                    height:
                        widget.items.length > 3.7
                            ? _itemHeight * 3.7
                            : (widget.items.length * _itemHeight) + 12,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: widget.items.length,
                      itemExtent: _itemHeight,
                      cacheExtent: _itemHeight * 5,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final item = widget.items[index];
                        return RepaintBoundary(
                          child: InkWell(
                            onTap: () {
                              widget.onSelected(item);
                              _hideMenu();
                            },
                            child: Container(
                              height: _itemHeight,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                widget.itemBuilder(item),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final disabledColor = Colors.grey.shade400;
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: widget.isEnabled ? _toggleMenu : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  widget.isEnabled
                      ? primaryColor.withAlpha(102)
                      : disabledColor.withAlpha(102),
              width: 1.5,
            ),
            color: widget.isEnabled ? Colors.transparent : Colors.grey.shade100,
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: widget.isEnabled ? primaryColor : disabledColor,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: widget.isEnabled ? Colors.black87 : disabledColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.arrow_drop_down_rounded,
                color: widget.isEnabled ? primaryColor : disabledColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
