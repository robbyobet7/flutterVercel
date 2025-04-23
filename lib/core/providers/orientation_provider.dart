import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to track orientation state (landscape/portrait)
final orientationProvider = StateNotifierProvider<OrientationNotifier, bool>((
  ref,
) {
  return OrientationNotifier();
});

/// Notifier class to handle orientation state
class OrientationNotifier extends StateNotifier<bool> {
  // Initialize with default (portrait) orientation
  OrientationNotifier() : super(false);

  /// Update orientation state
  void setOrientation(Orientation orientation) {
    state = orientation == Orientation.landscape;
  }

  /// Helper method to check if current orientation is landscape
  bool get isLandscape => state;

  /// Helper method to check if current orientation is portrait
  bool get isPortrait => !state;
}

/// Call this method in the app initialization to set up orientation detection
void initOrientationDetection(BuildContext context, WidgetRef ref) {
  // Initial setup based on current orientation
  _updateOrientation(context, ref);

  // Add a listener to update when orientation changes
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _setupOrientationListener(ref);
  });
}

void _updateOrientation(BuildContext context, WidgetRef ref) {
  final mediaQuery = MediaQuery.of(context);
  final orientation = mediaQuery.orientation;
  ref.read(orientationProvider.notifier).setOrientation(orientation);
}

void _setupOrientationListener(WidgetRef ref) {
  WidgetsBinding.instance.addObserver(
    _OrientationChangeObserver(
      onOrientationChanged: (orientation) {
        ref.read(orientationProvider.notifier).setOrientation(orientation);
      },
    ),
  );
}

class _OrientationChangeObserver extends WidgetsBindingObserver {
  final Function(Orientation) onOrientationChanged;

  _OrientationChangeObserver({required this.onOrientationChanged});

  @override
  void didChangeMetrics() {
    final window = WidgetsBinding.instance.window;
    final orientation =
        window.physicalSize.width > window.physicalSize.height
            ? Orientation.landscape
            : Orientation.portrait;
    onOrientationChanged(orientation);
  }
}
