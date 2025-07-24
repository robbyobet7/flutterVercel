import 'package:flutter_riverpod/flutter_riverpod.dart';

final isLoggedInProvider = StateProvider<bool>((ref) {
  return false;
});

final identityProvider = StateProvider<String>((ref) {
  return '';
});
final passwordProvider = StateProvider<String>((ref) {
  return '';
});
