import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'error_handler_service.dart';

/// Provider for ErrorHandlerService singleton.
///
/// Use this provider to access error handling functionality throughout
/// the application. The service is created once and reused.
///
/// Example usage:
/// ```dart
/// try {
///   await someOperation();
/// } catch (e, stackTrace) {
///   ref.read(errorLoggerProvider).logError(
///     e,
///     stackTrace,
///     context: 'DashboardProvider.loadData',
///   );
///   if (context.mounted) {
///     ref.read(errorLoggerProvider).showGenericError(context);
///   }
/// }
/// ```
final errorLoggerProvider = Provider<ErrorHandlerService>((ref) {
  return ErrorHandlerService();
});
