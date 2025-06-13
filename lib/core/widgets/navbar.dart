import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rebill_flutter/core/providers/orientation_provider.dart';
import 'package:rebill_flutter/core/theme/app_theme.dart';
import 'package:rebill_flutter/core/theme/theme_provider.dart';
import 'package:rebill_flutter/core/widgets/app_dialog.dart';
import 'package:rebill_flutter/core/widgets/app_material.dart';
import 'package:rebill_flutter/core/widgets/navbar_features.dart';
import 'package:rebill_flutter/core/widgets/profile_avatar.dart';
import 'package:rebill_flutter/features/printer-settings/presentations/widgets/printer_dialog.dart';

final hideNavbarProvider = StateProvider<bool>((ref) => false);

class Navbar extends ConsumerWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLandscape = ref.watch(orientationProvider);

    void handlePrinterTap() {
      AppDialog.showCustom(
        context,
        dialogType: DialogType.medium,
        title: 'Printer Settings',
        content: const PrinterDialog(),
      );
    }

    final theme = Theme.of(context);
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: AppTheme.kBoxShadow,
        ),
        // Using Center to ensure the Row is vertically centered in the container
        child: Center(
          child:
              ref.watch(hideNavbarProvider)
                  ? AppMaterial(
                    borderRadius: BorderRadius.circular(0),
                    onTap: () {
                      ref.read(hideNavbarProvider.notifier).state =
                          !ref.read(hideNavbarProvider.notifier).state;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      width: double.infinity,
                      child: Icon(Icons.unfold_more),
                    ),
                  )
                  : Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 32,
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: SvgPicture.asset(
                            'assets/icons/logo.svg',
                            fit: BoxFit.contain,
                            colorFilter:
                                Theme.of(context).brightness == Brightness.dark
                                    ? const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    )
                                    : null,
                          ),
                        ),

                        NavFeatures(),
                        Row(
                          children: [
                            if (isLandscape)
                              IconButton(
                                onPressed: () {
                                  ref.read(hideNavbarProvider.notifier).state =
                                      !ref
                                          .read(hideNavbarProvider.notifier)
                                          .state;
                                },
                                icon: Icon(
                                  Icons.unfold_less,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            if (isLandscape)
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.fullscreen,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.expand_more),
                              tooltip: 'Options',
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              position: PopupMenuPosition.under,
                              offset: const Offset(0, 8),
                              color: theme.colorScheme.surface,
                              onSelected: (value) {
                                // Handle selection based on value
                                switch (value) {
                                  case 'printer':
                                    // Handle printer action
                                    handlePrinterTap();
                                    break;
                                  case 'darkmode':
                                    // Handle dark mode toggle safely
                                    Future.microtask(() {
                                      final themeNotifier = ref.read(
                                        themeProvider.notifier,
                                      );
                                      themeNotifier.toggleTheme();
                                    });
                                    break;
                                  case 'collapse':
                                    ref
                                        .read(hideNavbarProvider.notifier)
                                        .state = !ref
                                            .read(hideNavbarProvider.notifier)
                                            .state;
                                    break;
                                  case 'fullscreen':
                                    // Handle fullscreen action
                                    break;
                                  case 'logout':
                                    // Handle logout action
                                    break;
                                }
                              },
                              itemBuilder:
                                  (
                                    BuildContext context,
                                  ) => <PopupMenuEntry<String>>[
                                    PopupMenuItem<String>(
                                      value: 'printer',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.print_rounded,
                                            color: theme.colorScheme.onSurface,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Printer Settings',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'darkmode',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Icons.light_mode_rounded
                                                : Icons.dark_mode_rounded,
                                            color: theme.colorScheme.onSurface,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? 'Light Mode'
                                                : 'Dark Mode',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!isLandscape)
                                      PopupMenuItem<String>(
                                        value: 'collapse',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.unfold_more,
                                              color:
                                                  theme.colorScheme.onSurface,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Collapse',
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (!isLandscape)
                                      PopupMenuItem<String>(
                                        value: 'fullscreen',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.fullscreen,
                                              color:
                                                  theme.colorScheme.onSurface,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Fullscreen',
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    PopupMenuItem<String>(
                                      height: .5, // Minimal height
                                      enabled: false,
                                      child: Divider(
                                        color: theme.colorScheme.outlineVariant,
                                        height: .5,
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'logout',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.logout_rounded,
                                            color: theme.colorScheme.error,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Logout',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      theme.colorScheme.error,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                            ),
                            ProfileAvatar(),
                          ],
                        ),
                      ],
                    ),
                  ),
        ),
      ),
    );
  }
}
