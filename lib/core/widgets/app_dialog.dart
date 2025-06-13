import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A reusable dialog component that can be customized for various use cases.
///
/// This dialog supports different configurations like confirmation dialogs,
/// information dialogs, or custom content dialogs.
class AppDialog extends StatelessWidget {
  /// The title of the dialog.
  final String? title;

  /// The content of the dialog.
  final Widget? content;

  final double? width;

  final double? height;

  /// Text content of the dialog. Either [content] or [contentText] can be provided.
  final String? contentText;

  /// Primary action button text.
  final String? primaryButtonText;

  /// Secondary action button text.
  final String? secondaryButtonText;

  /// Callback for primary button.
  final VoidCallback? onPrimaryButtonPressed;

  /// Callback for secondary button.
  final VoidCallback? onSecondaryButtonPressed;

  /// Callback when dialog is closed through any method.
  final VoidCallback? onClose;

  /// Whether dialog can be dismissed by tapping outside or pressing back.
  final bool barrierDismissible;

  /// Dialog icon to display at the top.
  final IconData? icon;

  /// Color for the icon.
  final Color? iconColor;

  /// Whether the dialog is custom.
  final bool? isCustom;

  final EdgeInsets? padding;

  const AppDialog({
    super.key,
    this.title,
    this.content,
    this.contentText,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryButtonPressed,
    this.onSecondaryButtonPressed,
    this.onClose,
    this.barrierDismissible = true,
    this.icon,
    this.iconColor,
    this.isCustom = false,
    this.width,
    this.height,
    this.padding,
  }) : assert(
         content == null || contentText == null,
         'Either provide content or contentText, not both',
       );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        SystemChannels.textInput.invokeMethod('TextInput.hide');

        if (onClose != null) onClose!();
        return true;
      },
      child: Dialog(
        insetPadding: EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: width,
          height: height,
          constraints: BoxConstraints(minWidth: 600),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (icon != null) ...[
                  Center(
                    child: Icon(
                      icon,
                      size: 48,
                      color: iconColor ?? theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (title != null) ...[
                  Center(
                    child: Text(
                      title!,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (content != null)
                  content!
                else if (contentText != null)
                  Text(
                    contentText!,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                isCustom!
                    ? const SizedBox(height: 0)
                    : const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (secondaryButtonText != null) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            if (onSecondaryButtonPressed != null) {
                              onSecondaryButtonPressed!();
                            }
                            if (onClose != null) onClose!();
                            Navigator.of(context).pop(false);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(secondaryButtonText!),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (!isCustom!) ...[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (onPrimaryButtonPressed != null) {
                              onPrimaryButtonPressed!();
                            }
                            if (onClose != null) onClose!();
                            Navigator.of(context).pop(true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(primaryButtonText ?? 'OK'),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Shows a confirmation dialog with Yes/No buttons.
  static Future<bool?> showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Yes',
    String cancelText = 'No',
    IconData? icon,
    VoidCallback? onClose,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AppDialog(
            title: title,
            contentText: message,
            primaryButtonText: confirmText,
            secondaryButtonText: cancelText,
            icon: icon ?? Icons.help_outline_rounded,
            iconColor: Theme.of(context).colorScheme.primary,
            onClose: onClose,
          ),
    );
  }

  /// Shows an info dialog with a single OK button.
  static Future<void> showInfo(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
    IconData? icon,
    VoidCallback? onClose,
  }) {
    return showDialog<void>(
      context: context,
      builder:
          (context) => AppDialog(
            title: title,
            contentText: message,
            primaryButtonText: buttonText,
            icon: icon ?? Icons.info_outline_rounded,
            iconColor: Theme.of(context).colorScheme.primary,
            onClose: onClose,
          ),
    );
  }

  /// Shows an error dialog with a single OK button.
  static Future<void> showError(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onClose,
  }) {
    return showDialog<void>(
      context: context,
      builder:
          (context) => AppDialog(
            title: title,
            contentText: message,
            primaryButtonText: buttonText,
            icon: Icons.error_outline_rounded,
            iconColor: Theme.of(context).colorScheme.error,
            onClose: onClose,
          ),
    );
  }

  // /// Shows a custom dialog with provided content.
  // static Future<T?> showCustomNoAnimation<T>(
  //   BuildContext context, {
  //   String? title,
  //   required Widget content,
  //   String? primaryButtonText,
  //   String? secondaryButtonText,
  //   VoidCallback? onPrimaryButtonPressed,
  //   VoidCallback? onSecondaryButtonPressed,
  //   IconData? icon,
  //   Color? iconColor,
  //   VoidCallback? onClose,
  //   required DialogType dialogType,
  //   EdgeInsets? padding,
  // }) {
  //   return showDialog<T>(
  //     context: context,
  //     builder:
  //         (context) => AppDialog(
  //           title: title,
  //           content: content,
  //           primaryButtonText: primaryButtonText,
  //           secondaryButtonText: secondaryButtonText,
  //           onPrimaryButtonPressed: onPrimaryButtonPressed,
  //           onSecondaryButtonPressed: onSecondaryButtonPressed,
  //           icon: icon,
  //           iconColor: iconColor,
  //           isCustom: true,
  //           onClose: onClose,
  //           width: _getDialogWidth(context, dialogType),
  //           height: _getDialogHeight(context, dialogType),
  //           padding: padding,
  //         ),
  //   );
  // }

  static Future<T?> showCustom<T>(
    BuildContext context, {
    String? title,
    required Widget content,
    String? primaryButtonText,
    String? secondaryButtonText,
    VoidCallback? onPrimaryButtonPressed,
    VoidCallback? onSecondaryButtonPressed,
    IconData? icon,
    Color? iconColor,
    VoidCallback? onClose,
    required DialogType dialogType,
    EdgeInsets? padding,
    Color barrierColor = Colors.black54,
    Duration transitionDuration = const Duration(milliseconds: 400),
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      barrierColor: barrierColor,
      transitionBuilder: (context, a1, a2, widget) {
        final curvedValue = Curves.easeOutCubic.transform(a1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
          child: Opacity(
            opacity: a1.value,
            child: AppDialog(
              title: title,
              content: content,
              primaryButtonText: primaryButtonText,
              secondaryButtonText: secondaryButtonText,
              onPrimaryButtonPressed: onPrimaryButtonPressed,
              onSecondaryButtonPressed: onSecondaryButtonPressed,
              icon: icon,
              iconColor: iconColor,
              isCustom: true,
              onClose: onClose,
              width: _getDialogWidth(context, dialogType),
              height: _getDialogHeight(context, dialogType),
              padding: padding,
            ),
          ),
        );
      },
      transitionDuration: transitionDuration,
      barrierDismissible: barrierDismissible,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {
        return const SizedBox.shrink();
      },
    );
  }

  /// Helper methods to calculate dialog width based on orientation
  static double _getDialogWidth(BuildContext context, DialogType dialogType) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    if (isLandscape) {
      return dialogType == DialogType.small
          ? mediaQuery.size.width * 0.5
          : dialogType == DialogType.medium
          ? mediaQuery.size.width * 0.5
          : mediaQuery.size.width * 0.8;
    } else {
      // Portrait mode - use more width
      return dialogType == DialogType.small
          ? mediaQuery.size.width * 0.85
          : dialogType == DialogType.medium
          ? mediaQuery.size.width * 0.9
          : mediaQuery.size.width * 0.95;
    }
  }

  /// Helper methods to calculate dialog height based on orientation
  static double _getDialogHeight(BuildContext context, DialogType dialogType) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    if (isLandscape) {
      return dialogType == DialogType.small
          ? mediaQuery.size.height * 0.5
          : dialogType == DialogType.medium
          ? mediaQuery.size.height * 0.8
          : mediaQuery.size.height * 0.8;
    } else {
      // Portrait mode - use less height to avoid keyboard issues
      return dialogType == DialogType.small
          ? mediaQuery.size.height * 0.3
          : dialogType == DialogType.medium
          ? mediaQuery.size.height * 0.5
          : mediaQuery.size.height * 0.6;
    }
  }
}

/// Shows a dialog with custom transition animation.

enum DialogType { small, medium, large }
