import 'package:flutter/material.dart';

class HeaderColumn extends StatelessWidget {
  const HeaderColumn({
    super.key,
    required this.flex,
    required this.text,
    this.textAlign,
  });

  final int flex;
  final String text;
  final TextAlign? textAlign;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: textAlign ?? TextAlign.left,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }
}

class CellColumn extends StatelessWidget {
  const CellColumn({
    super.key,
    required this.flex,
    required this.text,
    this.textAlign,
    this.child,
  });

  final int flex;
  final String text;
  final TextAlign? textAlign;
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child:
          child ??
          Text(
            text,
            textAlign: textAlign ?? TextAlign.left,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
          ),
    );
  }
}
