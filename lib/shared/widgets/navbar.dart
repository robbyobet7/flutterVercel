import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rebill_flutter/core/theme/app_theme.dart';
import 'package:rebill_flutter/shared/widgets/profile_avatar.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
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
                IconButton(
                  icon: const Icon(Icons.expand_more),
                  onPressed: () {
                    // Handle expand action
                  },
                  tooltip: 'Expand',
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

  final List<Map<String, dynamic>> _features = [
    {'icon': Icons.table_bar, 'label': 'Tables'},
    {'icon': Icons.book_online, 'label': 'Reservations'},
    {'icon': Icons.restaurant, 'label': 'Kitchen Orders'},
    {'icon': Icons.lock, 'label': 'Lock / Switch'},
    {'icon': Icons.assessment, 'label': 'Daily Report'},
    {'icon': Icons.inventory_2, 'label': 'Stock Taking'},
  ];

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
              _features.length * 68.0; // 60 width + 8 margin
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
                                  feature['icon'],
                                  feature['label'],
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
                        feature['icon'],
                        feature['label'],
                      );
                    }).toList(),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildFeatureBox(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);

    return SizedBox(
      height: double.infinity,
      child: TextButton(
        onPressed: () {
          // Handle feature button press
        },
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
