import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Centralized error handling service for Daoji application.
///
/// Provides consistent error logging and user feedback. Production logs must
/// never include journal body, mood scores, or free-text reflection content.
class ErrorHandlerService {
  /// Logs a framework [FlutterErrorDetails] via the shared pipeline.
  static void logFlutterError(FlutterErrorDetails details) {
    final service = ErrorHandlerService();
    service.logError(
      details.exceptionAsString(),
      details.stack,
      context: details.context?.toString(),
    );
  }

  /// Static entry point for [PlatformDispatcher.instance.onError].
  static bool logZoneError(Object error, StackTrace stack) {
    ErrorHandlerService().logError(error, stack, context: 'PlatformDispatcher');
    return true;
  }

  /// Logs an error with optional context information.
  ///
  /// In debug mode, prints to console with full stack trace.
  /// In production, logs a truncated, redacted summary only.
  void logError(Object error, StackTrace? stackTrace, {String? context}) {
    final sanitizedContext = _redactSensitiveData(context);
    final errorText = _truncate(_redactSensitiveData(error.toString()), 500);
    final stackText = stackTrace == null
        ? null
        : _truncate(stackTrace.toString(), 2000);

    if (kDebugMode) {
      debugPrint('═══════════════════════════════════════');
      debugPrint(
        'ERROR${sanitizedContext.isNotEmpty ? ' [$sanitizedContext]' : ''}',
      );
      debugPrint('Error: $errorText');
      if (stackText != null) {
        debugPrint('Stack trace:\n$stackText');
      }
      debugPrint('═══════════════════════════════════════');
      return;
    }

    // Production path: structured, non-PII summary only (no crash reporter yet).
    debugPrint(
      'DaojiError'
      '${sanitizedContext.isNotEmpty ? ' context=$sanitizedContext' : ''}'
      ' error=$errorText',
    );
  }

  /// Shows a user-friendly error message via SnackBar.
  void showErrorSnackbar(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    if (!context.mounted) return;

    final scheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: scheme.onError)),
        backgroundColor: scheme.error,
        behavior: SnackBarBehavior.floating,
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: scheme.onError,
                onPressed: onAction,
              )
            : null,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Shows a generic "something went wrong" message.
  void showGenericError(BuildContext context) {
    showErrorSnackbar(context, 'Terjadi kesalahan. Silakan coba lagi.');
  }

  /// Shows a retry-able error message.
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

  /// Redacts likely sensitive free-text from log context strings.
  ///
  /// Prefer not logging journal/mood/reflection payloads at all; this is a
  /// last-line defense for accidental context strings.
  static String _redactSensitiveData(String? input) {
    if (input == null || input.isEmpty) return '';
    var out = input;
    // Drop free-text blobs after known sensitive labels.
    out = out.replaceAll(
      RegExp(
        r'(journal|mood|reflection|openText|responseReason|noteText)\s*[:=]\s*[^,;\n]+',
        caseSensitive: false,
      ),
      r'$1=[REDACTED]',
    );
    return out;
  }

  static String _truncate(String value, int max) {
    if (value.length <= max) return value;
    return '${value.substring(0, max)}…';
  }
}
