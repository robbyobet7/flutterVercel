import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for bill search state management
final billSearchProvider = StateNotifierProvider<BillSearchNotifier, String>((
  ref,
) {
  return BillSearchNotifier();
});

/// Notifier class to handle bill search query state
class BillSearchNotifier extends StateNotifier<String> {
  BillSearchNotifier() : super('');

  /// Update bill search query
  void updateSearchQuery(String query) {
    state = query;
  }

  /// Clear bill search query
  void clearSearch() {
    state = '';
  }
}
