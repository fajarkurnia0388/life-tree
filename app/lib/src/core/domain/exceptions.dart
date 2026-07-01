/// Custom exception types for LifeTree application.
///
/// These exceptions provide more semantic meaning than generic exceptions,
/// making it easier to handle different error scenarios appropriately.
library;

/// Base class for all LifeTree application exceptions.
abstract class LifeTreeException implements Exception {
  final String message;
  final dynamic originalError;

  const LifeTreeException(this.message, [this.originalError]);

  @override
  String toString() => 'LifeTreeException: $message';
}

/// Thrown when a database operation fails.
///
/// Examples: insert/update/delete failures, constraint violations, etc.
class DatabaseException extends LifeTreeException {
  const DatabaseException(super.message, [super.originalError]);

  @override
  String toString() => 'DatabaseException: $message';
}

/// Thrown when user input validation fails.
///
/// Examples: empty required fields, invalid formats, out of range values.
class ValidationException extends LifeTreeException {
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
class NetworkException extends LifeTreeException {
  const NetworkException(super.message, [super.originalError]);

  @override
  String toString() => 'NetworkException: $message';
}

/// Thrown when data parsing/serialization fails.
///
/// Examples: JSON decode errors, invalid data format from database.
class DataFormatException extends LifeTreeException {
  const DataFormatException(super.message, [super.originalError]);

  @override
  String toString() => 'DataFormatException: $message';
}
