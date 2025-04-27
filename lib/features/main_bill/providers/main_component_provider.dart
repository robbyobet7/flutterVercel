import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainComponentNotifier extends StateNotifier<String> {
  MainComponentNotifier() : super("");

  void setMainComponent(String component) {
    state = component;
  }
}

final mainComponentProvider =
    StateNotifierProvider<MainComponentNotifier, String>((ref) {
      return MainComponentNotifier();
    });
