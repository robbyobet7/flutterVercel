import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for search state management
final searchProvider = StateNotifierProvider<SearchNotifier, String>((ref) {
  return SearchNotifier();
});

final productSearchQueryProvider =
    StateNotifierProvider<SearchNotifier, String>((ref) {
      return SearchNotifier();
    });

final customerSearchQueryProvider =
    StateNotifierProvider<SearchNotifier, String>((ref) {
      return SearchNotifier();
    });

/// Notifier class to handle search query state
class SearchNotifier extends StateNotifier<String> {
  SearchNotifier() : super('');

  /// Update search query
  void updateSearchQuery(String query) {
    state = query;
  }

  /// Clear search query
  void clearSearch() {
    state = '';
  }
}
