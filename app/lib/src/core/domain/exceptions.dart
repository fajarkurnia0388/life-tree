/// Custom exception types for Daoji application.
///
/// These exceptions provide more semantic meaning than generic exceptions,
/// making it easier to handle different error scenarios appropriately.
library;

/// Base class for all Daoji application exceptions.
abstract class DaojiException implements Exception {
  final String message;
  final dynamic originalError;

  const DaojiException(this.message, [this.originalError]);

  @override
  String toString() => 'DaojiException: $message';
}

/// Thrown when a database operation fails.
///
/// Examples: insert/update/delete failures, constraint violations, etc.
class DatabaseException extends DaojiException {
  const DatabaseException(super.message, [super.originalError]);

  @override
  String toString() => 'DatabaseException: $message';
}

/// Thrown when user input validation fails.
///
/// Examples: empty required fields, invalid formats, out of range values.
class ValidationException extends DaojiException {
  final String? fieldName;

  const ValidationException(
    String message, {
    this.fieldName,
    dynamic originalError,
  }) : super(message, originalError);

  @override
  String toString() =>
      'ValidationException${fieldName != null ? ' [$fieldName]' : ''}: $message';
}

/// Thrown when a network operation fails (for future cloud sync).
///
/// Currently unused in MVP, but prepared for future cloud sync features.
class NetworkException extends DaojiException {
  const NetworkException(super.message, [super.originalError]);

  @override
  String toString() => 'NetworkException: $message';
}

/// Thrown when data parsing/serialization fails.
///
/// Examples: JSON decode errors, invalid data format from database.
class DataFormatException extends DaojiException {
  const DataFormatException(super.message, [super.originalError]);

  @override
  String toString() => 'DataFormatException: $message';
}
