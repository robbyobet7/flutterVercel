import 'package:flutter_riverpod/flutter_riverpod.dart';

final isLoggedInProvider = StateProvider<bool>((ref) {
  return false;
});

final usernameProvider = StateProvider<String>((ref) {
  return '';
});
