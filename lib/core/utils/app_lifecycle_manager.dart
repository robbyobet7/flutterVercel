import 'package:flutter/material.dart';
import 'memory_optimizer.dart';

/// AppLifecycleManager handles optimizations based on app lifecycle
class AppLifecycleManager extends StatefulWidget {
  final Widget child;

  const AppLifecycleManager({super.key, required this.child});

  @override
  State<AppLifecycleManager> createState() => _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends State<AppLifecycleManager>
    with WidgetsBindingObserver {
  final MemoryOptimizer _memoryOptimizer = MemoryOptimizer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _memoryOptimizer.setImageCacheSize(100);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      _memoryOptimizer.clearMemoryOnBackground();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
