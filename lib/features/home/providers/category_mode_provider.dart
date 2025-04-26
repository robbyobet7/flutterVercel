import 'package:flutter_riverpod/flutter_riverpod.dart';

final categoryModeProvider = StateNotifierProvider<CategoryModeNotifier, bool>((
  ref,
) {
  return CategoryModeNotifier();
});

class CategoryModeNotifier extends StateNotifier<bool> {
  CategoryModeNotifier() : super(false);

  void toggleCategoryMode() {
    state = !state;
  }
}
