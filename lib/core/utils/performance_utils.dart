import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Utility class for performance optimizations throughout the app
class PerformanceUtils {
  /// Enables or disables performance overlay for debugging
  static void togglePerformanceOverlay(bool enabled) {
    if (kDebugMode) {
      debugPrintBeginFrameBanner = enabled;
      debugPrintEndFrameBanner = enabled;
      debugPrintBuildScope = enabled;
      debugPrintScheduleBuildForStacks = enabled;
    }
  }

  /// Use this in parent widgets to prevent unnecessary rebuilds of children
  static bool shouldRebuild<T>(T oldWidget, T newWidget) {
    return oldWidget != newWidget;
  }

  /// Enables or disables repaint rainbow for debugging repaints
  static void toggleRepaintRainbow(bool enabled) {
    if (kDebugMode) {
      debugRepaintRainbowEnabled = enabled;
    }
  }

  /// Cache images for better performance
  static ImageProvider precacheImageProvider(
    ImageProvider provider,
    BuildContext context,
  ) {
    precacheImage(provider, context);
    return provider;
  }

  /// Schedule work for the next frame when UI is idle
  static void scheduleTask(VoidCallback task) {
    SchedulerBinding.instance.scheduleTask(task, Priority.animation);
  }

  /// Run heavy computation in the background using compute
  static Future<R> computeInBackground<Q, R>(
    ComputeCallback<Q, R> callback,
    Q message,
  ) {
    return compute(callback, message);
  }
}
