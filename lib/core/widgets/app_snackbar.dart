import 'package:flutter/material.dart';
import 'package:rebill_flutter/core/theme/app_theme.dart';

enum AppSnackbarType { info, error, success, warning }

class AppSnackbar {
  AppSnackbar._();

  static void show(
    BuildContext context, {
    required message,
    AppSnackbarType type = AppSnackbarType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
    bool isDismissible = true,
    String? ttile,
  }) {
    final snackbar = _buildSnackBar(
      message: message,
      type: type,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
      isDismissible: isDismissible,
      ttile: ttile,
      context: context,
    );
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  static void showSuccess(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
    bool isDismissible = true,
    String? ttile,
  }) {
    show(
      context,
      message: message,
      type: AppSnackbarType.success,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
      isDismissible: isDismissible,
      ttile: ttile,
    );
  }

  static void showError(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
    bool isDismissible = true,
    String? ttile,
  }) {
    show(
      context,
      message: message,
      type: AppSnackbarType.error,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
      isDismissible: isDismissible,
      ttile: ttile,
    );
  }

  static void showWarning(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
    bool isDismissible = true,
    String? ttile,
  }) {
    show(
      context,
      message: message,
      type: AppSnackbarType.warning,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
      isDismissible: isDismissible,
      ttile: ttile,
    );
  }

  static void showInfo(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
    bool isDismissible = true,
    String? ttile,
  }) {
    show(
      context,
      message: message,
      type: AppSnackbarType.info,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
      isDismissible: isDismissible,
      ttile: ttile,
    );
  }

  static SnackBar _buildSnackBar({
    required String message,
    required AppSnackbarType type,
    required BuildContext context,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
    bool isDismissible = true,
    String? ttile,
  }) {
    final colorData = _getColorData(type);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SnackBar(
      duration: duration,
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(16),
      dismissDirection:
          isDismissible ? DismissDirection.horizontal : DismissDirection.none,
      content: AppSnackbarContent(
        message: message,
        title: ttile,
        type: type,
        colorData: colorData,
        isDark: isDarkMode,
        actionLabel: actionLabel,
        onAction: onAction,
        dismissible: isDismissible,
      ),
    );
  }

  static _SnackbarColorData _getColorData(AppSnackbarType type) {
    switch (type) {
      case AppSnackbarType.success:
        return const _SnackbarColorData(
          backgroundColor: AppTheme.success,
          iconColor: Colors.white,
          textColor: Colors.white,
          icon: Icons.check_circle,
        );
      case AppSnackbarType.error:
        return _SnackbarColorData(
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
          iconColor: Colors.white,
          textColor: Colors.white,
          icon: Icons.error,
        );
      case AppSnackbarType.warning:
        return _SnackbarColorData(
          backgroundColor: AppTheme.warning,
          iconColor: Colors.white,
          textColor: Colors.white,
          icon: Icons.warning,
        );
      case AppSnackbarType.info:
        return const _SnackbarColorData(
          backgroundColor: AppTheme.warning, // Info blue color
          iconColor: Colors.white,
          textColor: Colors.white,
          icon: Icons.info,
        );
    }
  }
}

class AppSnackbarContent extends StatelessWidget {
  const AppSnackbarContent({
    super.key,
    required this.message,
    required this.type,
    required this.colorData,
    required this.isDark,
    this.title,
    this.actionLabel,
    this.onAction,
    this.dismissible = true,
  });

  final String message;
  final String? title;
  final AppSnackbarType type;
  final _SnackbarColorData colorData;
  final bool isDark;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool dismissible;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorData.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(colorData.icon, color: colorData.iconColor, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  Text(title!, style: TextStyle(color: colorData.textColor)),
                  SizedBox(height: 2),
                ],
                Text(
                  message,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(color: colorData.textColor),
                ),
              ],
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            SizedBox(width: 8),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: colorData.textColor,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              child: Text(
                actionLabel!,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorData.textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (dismissible) ...[
            SizedBox(width: 4),
            IconButton(
              onPressed:
                  () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
              icon: Icon(Icons.close, color: colorData.iconColor, size: 20),
              constraints: BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
    );
  }
}

class _SnackbarColorData {
  const _SnackbarColorData({
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
    required this.icon,
  });

  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final IconData icon;
}
