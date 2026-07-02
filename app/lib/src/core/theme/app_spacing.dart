/// AppSpacing - Konstanta spacing yang konsisten untuk seluruh aplikasi
/// Mengikuti prinsip Design System untuk memastikan visual consistency
///
/// Usage:
/// ```dart
/// Padding(
///   padding: const EdgeInsets.all(AppSpacing.lg),
///   child: ...
/// )
/// ```
abstract class AppSpacing {
  /// Extra small spacing - 4.0
  static const double xs = 4.0;

  /// Small spacing - 8.0
  static const double sm = 8.0;

  /// Medium spacing - 12.0
  static const double md = 12.0;

  /// Large spacing - 16.0
  static const double lg = 16.0;

  /// Extra large spacing - 20.0
  static const double xl = 20.0;

  /// 2x Extra large spacing - 24.0
  static const double xxl = 24.0;

  /// 3x Extra large spacing - 32.0
  static const double xxxl = 32.0;

  /// 4x Extra large spacing - 40.0
  static const double xxxxl = 40.0;

  /// Section spacing - 48.0
  static const double section = 48.0;
}
