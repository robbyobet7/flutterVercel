import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A simple provider that exposes whether the app is running on the web or not.
///
/// This provider can be used throughout the app to conditionally render different
/// UI components or behaviors based on the platform.
///
/// Usage:
/// ```dart
/// final isWeb = ref.watch(deviceProvider.isWeb);
/// ```
class DeviceNotifier extends StateNotifier<DeviceState> {
  DeviceNotifier() : super(DeviceState(isWeb: kIsWeb));
}

/// The state class for the device provider
class DeviceState {
  /// Whether the app is running on the web platform
  final bool isWeb;

  const DeviceState({required this.isWeb});
}

/// Provider that gives access to device platform information
final deviceProvider = StateNotifierProvider<DeviceNotifier, DeviceState>((
  ref,
) {
  return DeviceNotifier();
});

/// Convenience provider that directly exposes whether the app is running on web
final isWebProvider = Provider<bool>((ref) {
  return ref.watch(deviceProvider).isWeb;
});
