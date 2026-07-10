import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Centralized error handling service for Daoji application.
///
/// This service provides consistent error logging and user feedback
/// across the entire application. It serves as the single source of
/// truth for how errors should be handled and reported.
class ErrorHandlerService {
  /// Logs an error with optional context information.
  ///
  /// In debug mode, prints to console with full stack trace.
  /// In production, this will integrate with crash reporting services.
  ///
  /// Parameters:
  /// - [error]: The error object that was thrown
  /// - [stackTrace]: The stack trace at the point of error
  /// - [context]: Optional context string describing where/why the error occurred
  void logError(Object error, StackTrace? stackTrace, {String? context}) {
    if (kDebugMode) {
      debugPrint('═══════════════════════════════════════');
      debugPrint('ERROR${context != null ? ' [$context]' : ''}');
      debugPrint('Error: $error');
      if (stackTrace != null) {
        debugPrint('Stack trace:\n$stackTrace');
      }
      debugPrint('═══════════════════════════════════════');
    }

    // Translate to a user-friendly log format or store state if needed in production
  }

  /// Shows a user-friendly error message via SnackBar.
  ///
  /// Displays a dismissible error message with optional retry action.
  /// Use this when an operation fails and the user needs to be notified.
  ///
  /// Parameters:
  /// - [context]: BuildContext to show the SnackBar
  /// - [message]: User-friendly error message
  /// - [actionLabel]: Optional label for action button (e.g., "Retry")
  /// - [onAction]: Optional callback when action button is pressed
  void showErrorSnackbar(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Shows a generic "something went wrong" message.
  ///
  /// Use this when the specific error is not important to show to the user,
  /// but they should know the operation failed.
  void showGenericError(BuildContext context) {
    showErrorSnackbar(context, 'Terjadi kesalahan. Silakan coba lagi.');
  }

  /// Shows a retry-able error message.
  ///
  /// Displays an error with a "Coba Lagi" button that executes the retry callback.
  void showRetryableError(
    BuildContext context,
    String message,
    VoidCallback onRetry,
  ) {
    showErrorSnackbar(
      context,
      message,
      actionLabel: 'Coba Lagi',
      onAction: onRetry,
    );
  }
}
