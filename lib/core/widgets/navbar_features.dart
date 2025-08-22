import 'package:flutter/material.dart';
import 'package:rebill_flutter/core/models/navbar.dart';
import 'package:rebill_flutter/core/widgets/app_dialog.dart';
import 'package:rebill_flutter/core/widgets/app_material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/features/home/providers/home_component_provider.dart';
import 'package:rebill_flutter/features/stock-taking/presentations/widgets/stock_taking_dialog.dart';

class NavFeatures extends ConsumerStatefulWidget {
  const NavFeatures({super.key});

  @override
  ConsumerState<NavFeatures> createState() => _NavFeaturesState();
}

class _NavFeaturesState extends ConsumerState<NavFeatures> {
  final ScrollController _scrollController = ScrollController();

  void toggleMode(HomeComponent mode) {
    if (ref.read(homeComponentProvider) == mode) {
      ref.read(homeComponentProvider.notifier).state = HomeComponent.home;
    } else {
      ref.read(homeComponentProvider.notifier).state = mode;
    }
  }

  void handleTableTap() {
    toggleMode(HomeComponent.tables);
  }

  void handleReservationTap() {
    toggleMode(HomeComponent.reservations);
  }

  void handleStockTakingTap() {
    AppDialog.showCustom(
      context,
      dialogType: DialogType.large,
      title: 'Stock Taking',
      content: const StockTakingDialog(),
    );
  }

  void handleKitchenOrderTap() {
    toggleMode(HomeComponent.kitchenOrders);
  }

  late final List<NavMenu> _features;

  @override
  void initState() {
    super.initState();
    _features = [
      NavMenu(icon: Icons.table_bar, label: 'Tables', onTap: handleTableTap),
      NavMenu(
        icon: Icons.book_online,
        label: 'Reservations',
        onTap: handleReservationTap,
      ),
      NavMenu(
        icon: Icons.restaurant,
        label: 'Kitchen Orders',
        onTap: handleKitchenOrderTap,
      ),
      NavMenu(icon: Icons.lock, label: 'Lock / Switch', onTap: () {}),
      NavMenu(icon: Icons.assessment, label: 'Daily Report', onTap: () {}),
      NavMenu(
        icon: Icons.inventory_2,
        label: 'Stock Taking',
        onTap: handleStockTakingTap,
      ),
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

          // Responsive font size for labels
          final double labelFontSize =
              constraints.maxWidth >= 1200
                  ? 10
                  : constraints.maxWidth >= 900
                  ? 9
                  : 8;

          if (needsScrolling) {
            // Original scrollable implementation with arrows
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios, size: 10),
                  onPressed: _scrollLeft,
                  tooltip: 'Scroll left',
                  iconSize: 24,
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
                            theme.colorScheme.surface.withValues(alpha: 0.0),
                            theme.colorScheme.surface.withValues(alpha: 0.0),
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
                              color: theme.colorScheme.outline.withValues(
                                alpha: 0.1,
                              ),
                              width: 1,
                            ),
                            right: BorderSide(
                              color: theme.colorScheme.outline.withValues(
                                alpha: 0.1,
                              ),
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
                                  labelFontSize: labelFontSize,
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
            return SizedBox(
              height: 60,
              child: Align(
                alignment: const Alignment(0.16, 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      _features.map((feature) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: _buildFeatureBox(
                            context,
                            feature.icon,
                            feature.label,
                            labelFontSize: labelFontSize,
                            onTap: feature.onTap,
                          ),
                        );
                      }).toList(),
                ),
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
    double labelFontSize = 8,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final active = ref.watch(homeComponentProvider).name == label;

    return SizedBox(
      height: double.infinity,
      child: AppMaterial(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          constraints: BoxConstraints(minWidth: 100, minHeight: 60),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border:
                active
                    ? Border.all(color: theme.colorScheme.primary, width: 1)
                    : null,
            color:
                active
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainer,
          ),
          child: Tooltip(
            message: label,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color:
                      active
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: labelFontSize,
                    color:
                        active
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
