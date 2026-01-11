import 'package:flutter/material.dart';

class AppToast {
  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 2),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    // 移除当前的 SnackBar
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bg = isError
        ? colorScheme.errorContainer
        : colorScheme.secondaryContainer;

    final fg = isError
        ? colorScheme.onErrorContainer
        : colorScheme.onSecondaryContainer;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: fg,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: bg,
        elevation: 0,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: duration,
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: fg,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  static void error(BuildContext context, String message) {
    show(context, message, isError: true);
  }

  static void success(BuildContext context, String message) {
    show(context, message, isError: false);
  }
}
