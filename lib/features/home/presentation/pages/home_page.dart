import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/theme/theme_provider.dart';
import 'package:rebill_flutter/features/home/widgets/home_features.dart';
import 'package:rebill_flutter/shared/widgets/navbar.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final themeNotifier = ref.read(themeProvider.notifier);
          themeNotifier.toggleTheme();
        },
        child: Icon(
          Theme.of(context).brightness == Brightness.light
              ? Icons.dark_mode
              : Icons.light_mode,
        ),
      ),
      body: Column(spacing: 24, children: const [Navbar(), HomeFeatures()]),
    );
  }
}
