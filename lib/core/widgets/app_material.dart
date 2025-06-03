import 'package:flutter/material.dart';

class AppMaterial extends StatelessWidget {
  const AppMaterial({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
  });

  final Widget child;
  final void Function()? onTap;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(onTap: onTap ?? () {}, child: child),
      ),
    );
  }
}
