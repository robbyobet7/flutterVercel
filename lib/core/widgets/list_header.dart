import 'package:flutter/material.dart';
import 'package:rebill_flutter/core/widgets/header_column.dart';

class ListHeader extends StatelessWidget {
  const ListHeader({super.key, required this.headers, this.padding});

  final List<Header> headers;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding:
          padding ?? EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          ...headers.map(
            (header) => HeaderColumn(
              flex: header.flex,
              text: header.text,
              textAlign: header.textAlign,
            ),
          ),
        ],
      ),
    );
  }
}

class Header {
  final int flex;
  final String text;
  final TextAlign? textAlign;

  Header({required this.flex, required this.text, this.textAlign});
}
