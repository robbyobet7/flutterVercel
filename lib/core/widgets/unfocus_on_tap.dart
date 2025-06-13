import 'package:flutter/material.dart';

/// A widget that unfocuses (dismisses the keyboard) when tapped.
///
/// This widget is intended to be used at a high level in the widget tree to provide
/// global behavior for dismissing the keyboard when tapping outside of text fields.
class UnfocusOnTap extends StatelessWidget {
  /// Creates a container that unfocuses when tapped.
  ///
  /// The [child] parameter is required.
  const UnfocusOnTap({super.key, required this.child});

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // When tapped, dismiss any active focus and hide keyboard
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      // HitTestBehavior.translucent ensures taps are caught even if they would
      // normally be absorbed by the widget tree
      behavior: HitTestBehavior.translucent,
      // Pass the child through
      child: child,
    );
  }
}
