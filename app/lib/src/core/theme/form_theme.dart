import 'package:flutter/material.dart';

/// Form-specific theme configurations and input decoration styles.
/// 
/// Provides consistent styling for form inputs, validation messages,
/// and error states across the application.
/// 
/// Usage:
/// ```dart
/// TextFormField(
///   decoration: AppFormTheme.inputDecoration(
///     labelText: 'Email',
///     hintText: 'nama@example.com',
///   ),
/// )
/// ```
class AppFormTheme {
  AppFormTheme._(); // Private constructor

  /// Standard input decoration for text fields
  static InputDecoration inputDecoration({
    required String labelText,
    String? hintText,
    String? helperText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    int? maxLength,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      counterText: maxLength != null ? '' : null, // Hide counter by default
      filled: true,
      fillColor: Colors.transparent,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    );
  }

  /// Validation messages in Indonesian with empathetic tone
  static String? requiredFieldValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  static String? minLengthValidator(
    String? value,
    String fieldName,
    int minLength,
  ) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    if (value.trim().length < minLength) {
      return '$fieldName minimal $minLength karakter';
    }
    return null;
  }

  static String? maxLengthValidator(
    String? value,
    String fieldName,
    int maxLength,
  ) {
    if (value != null && value.trim().length > maxLength) {
      return '$fieldName maksimal $maxLength karakter';
    }
    return null;
  }

  static String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  /// Combined validator for common patterns
  static String? habitTitleValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Judul kebiasaan tidak boleh kosong';
    }
    if (value.trim().length < 3) {
      return 'Judul minimal 3 karakter';
    }
    if (value.trim().length > 50) {
      return 'Judul maksimal 50 karakter';
    }
    return null;
  }

  static String? optionalTextValidator(String? value, {int? maxLength}) {
    if (value != null && value.trim().isNotEmpty) {
      if (maxLength != null && value.trim().length > maxLength) {
        return 'Maksimal $maxLength karakter';
      }
    }
    return null;
  }
}
