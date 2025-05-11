import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rebill_flutter/core/models/navbar.dart';
import 'package:rebill_flutter/core/theme/app_theme.dart';
import 'package:rebill_flutter/core/theme/theme_provider.dart';
import 'package:rebill_flutter/core/widgets/app_dialog.dart';
import 'package:rebill_flutter/core/widgets/profile_avatar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/widgets/table_dialog.dart';

class Navbar extends ConsumerWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: AppTheme.kBoxShadow,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      // Using Center to ensure the Row is vertically centered in the container
      child: Center(
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
                        ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                        : null,
              ),
            ),

            NavFeatures(),
            Row(
              children: [
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
                      case 'logout':
                        // Handle logout action
                        break;
                    }
                  },
                  itemBuilder:
                      (BuildContext context) => <PopupMenuEntry<String>>[
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
                                style: theme.textTheme.bodyMedium?.copyWith(
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
                                Theme.of(context).brightness == Brightness.dark
                                    ? Icons.light_mode_rounded
                                    : Icons.dark_mode_rounded,
                                color: theme.colorScheme.onSurface,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                Theme.of(context).brightness == Brightness.dark
                                    ? 'Light Mode'
                                    : 'Dark Mode',
                                style: theme.textTheme.bodyMedium?.copyWith(
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
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.error,
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
    );
  }
}

class NavFeatures extends StatefulWidget {
  const NavFeatures({super.key});

  @override
  State<NavFeatures> createState() => _NavFeaturesState();
}

class _NavFeaturesState extends State<NavFeatures> {
  final ScrollController _scrollController = ScrollController();

  void handleTableTap() {
    AppDialog.showCustom(
      context,
      title: 'Tables',
      height: MediaQuery.of(context).size.height * 0.8,
      width: MediaQuery.of(context).size.width * 0.8,
      content: const TableDialog(),
    );
  }

  late final List<NavMenu> _features;

  @override
  void initState() {
    super.initState();
    _features = [
      NavMenu(icon: Icons.table_bar, label: 'Tables', onTap: handleTableTap),
      NavMenu(icon: Icons.book_online, label: 'Reservations', onTap: () {}),
      NavMenu(icon: Icons.restaurant, label: 'Kitchen Orders', onTap: () {}),
      NavMenu(icon: Icons.lock, label: 'Lock / Switch', onTap: () {}),
      NavMenu(icon: Icons.assessment, label: 'Daily Report', onTap: () {}),
      NavMenu(icon: Icons.inventory_2, label: 'Stock Taking', onTap: () {}),
    ];
  }

  void _scrollLeft() {
    if (_scrollController.hasClients) {
      final position = _scrollController.position.pixels;
      _scrollController.animateTo(
        position - 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollRight() {
    if (_scrollController.hasClients) {
      final position = _scrollController.position.pixels;
      _scrollController.animateTo(
        position + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate if scrolling is needed
          final double totalWidth =
              _features.length * 120.0; // 60 width + 8 margin
          final bool needsScrolling = totalWidth > constraints.maxWidth;

          if (needsScrolling) {
            // Original scrollable implementation with arrows
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios, size: 10),
                  onPressed: _scrollLeft,
                  tooltip: 'Scroll left',
                  iconSize: 16,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    height: 60,
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            theme.colorScheme.surface,
                            theme.colorScheme.surface.withOpacity(0.0),
                            theme.colorScheme.surface.withOpacity(0.0),
                            theme.colorScheme.surface,
                          ],
                          stops: const [0.0, 0.1, 0.9, 1.0],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.dstOut,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: theme.colorScheme.outline.withOpacity(0.1),
                              width: 1,
                            ),
                            right: BorderSide(
                              color: theme.colorScheme.outline.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                        ),
                        child: ListView.builder(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _features.length,
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          itemBuilder: (context, index) {
                            final feature = _features[index];
                            return Row(
                              children: [
                                const SizedBox(width: 4),
                                _buildFeatureBox(
                                  context,
                                  feature.icon,
                                  feature.label,
                                  onTap: feature.onTap,
                                ),
                                const SizedBox(width: 4),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios, size: 10),
                  onPressed: _scrollRight,
                  tooltip: 'Scroll right',
                  iconSize: 16,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            );
          } else {
            // Simplified layout without arrows when scrolling isn't needed
            return Container(
              height: 60,
              child: Row(
                spacing: 8,
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    _features.map((feature) {
                      return _buildFeatureBox(
                        context,
                        feature.icon,
                        feature.label,
                        onTap: feature.onTap,
                      );
                    }).toList(),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildFeatureBox(
    BuildContext context,
    IconData icon,
    String label, {
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return SizedBox(
      height: double.infinity,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          minimumSize: Size(100, 60),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: theme.colorScheme.surfaceContainer,
        ),
        child: Tooltip(
          message: label,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 8,
                  color: theme.colorScheme.onSurfaceVariant,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
