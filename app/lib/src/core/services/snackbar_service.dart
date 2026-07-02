import 'package:flutter/material.dart';

/// Standardized SnackBar service for consistent error, success, and info messages.
///
/// Provides appropriate durations and styling for different message types:
/// - Error messages: 6-8 seconds (users need time to read and understand)
/// - Success messages: 3-4 seconds (quick confirmation)
/// - Info messages: 4-5 seconds (moderate attention)
///
/// Usage:
/// ```dart
/// SnackBarService.showError(
///   context,
///   'Gagal menyimpan data',
/// );
/// ```
class SnackBarService {
  SnackBarService._(); // Private constructor to prevent instantiation

  /// Show error message with appropriate duration (6 seconds)
  static void showError(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: Theme.of(context).colorScheme.error,
      duration: const Duration(seconds: 6),
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  /// Show success message with shorter duration (3 seconds)
  static void showSuccess(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.green.shade700,
      duration: const Duration(seconds: 3),
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  /// Show info message with moderate duration (4 seconds)
  static void showInfo(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.blue.shade700,
      duration: const Duration(seconds: 4),
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  /// Show warning message with moderate duration (5 seconds)
  static void showWarning(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.orange.shade700,
      duration: const Duration(seconds: 5),
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  /// Internal method to show SnackBar with consistent styling
  static void _showSnackBar(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required Duration duration,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    // Clear any existing SnackBars
    ScaffoldMessenger.of(context).clearSnackBars();

    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      action: actionLabel != null && onActionPressed != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: Colors.white,
              onPressed: onActionPressed,
            )
          : null,
      // Accessibility: ensure SnackBar is announced by screen readers
      dismissDirection: DismissDirection.horizontal,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
