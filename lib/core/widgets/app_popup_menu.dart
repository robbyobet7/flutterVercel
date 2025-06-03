import 'package:flutter/material.dart';

class AppPopupMenuItem<T> {
  final T? value;
  final String text;
  final IconData? icon;
  final Color? iconColor;
  final Color? textColor;
  final bool isDivider;
  final Widget? trailing;
  final double? height;

  const AppPopupMenuItem({
    required this.value,
    required this.text,
    this.icon,
    this.iconColor,
    this.textColor,
    this.isDivider = false,
    this.trailing,
    this.height,
  });

  factory AppPopupMenuItem.divider() {
    return const AppPopupMenuItem(
      value: null,
      text: '',
      icon: Icons.circle,
      isDivider: true,
    );
  }
}

class AppPopupMenu<T> extends StatefulWidget {
  final List<AppPopupMenuItem<T>> items;
  final Function(T) onSelected;
  final Widget? child;
  final String? tooltip;
  final Widget? icon;
  final PopupMenuPosition position;
  final Offset offset;
  final double elevation;

  const AppPopupMenu({
    super.key,
    required this.items,
    required this.onSelected,
    this.child,
    this.tooltip,
    this.icon,
    this.position = PopupMenuPosition.under,
    this.offset = const Offset(0, 8),
    this.elevation = 2,
  });

  @override
  State<AppPopupMenu<T>> createState() => _AppPopupMenuState<T>();
}

class _AppPopupMenuState<T> extends State<AppPopupMenu<T>> {
  late final FocusNode _menuFocusNode;

  @override
  void initState() {
    super.initState();
    _menuFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _menuFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Focus(
      focusNode: _menuFocusNode,
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          // When menu gets focus, ensure keyboard is hidden
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: PopupMenuButton<T>(
        tooltip: widget.tooltip,
        icon: widget.icon,
        position: widget.position,
        offset: widget.offset,
        elevation: widget.elevation,
        clipBehavior: Clip.hardEdge,
        borderRadius: BorderRadius.circular(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: theme.colorScheme.surface,
        // When popup menu is opened, ensure keyboard is dismissed
        onOpened: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        onSelected: (value) {
          // Ensure keyboard stays hidden after selection
          FocusManager.instance.primaryFocus?.unfocus();
          // Give focus back to menu area to prevent other widgets from getting focus
          _menuFocusNode.requestFocus();
          // Call the original onSelected callback
          widget.onSelected(value);
        },
        itemBuilder:
            (BuildContext context) =>
                widget.items.map((item) {
                  if (item.isDivider) {
                    return PopupMenuItem<T>(
                      height: 0.5,
                      enabled: false,
                      padding: EdgeInsets.zero,
                      child: Divider(
                        color: theme.colorScheme.outlineVariant,
                        height: 0.5,
                      ),
                    );
                  }

                  return PopupMenuItem<T>(
                    value: item.value,
                    height: item.height ?? kMinInteractiveDimension,
                    child: Row(
                      children: [
                        if (item.icon != null) ...[
                          Icon(
                            item.icon,
                            color:
                                item.iconColor ?? theme.colorScheme.onSurface,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                        ],
                        Flexible(
                          child: Text(
                            item.text,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: item.textColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item.trailing != null) ...[item.trailing!],
                      ],
                    ),
                  );
                }).toList(),
        child: widget.child,
      ),
    );
  }
}
