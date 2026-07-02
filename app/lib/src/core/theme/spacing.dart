/// Application-wide spacing constants for consistent layout.
/// 
/// Use these constants instead of hardcoded values to ensure
/// visual consistency across the app.
/// 
/// Usage:
/// ```dart
/// Padding(
///   padding: EdgeInsets.all(AppSpacing.lg),
///   child: ...
/// )
/// ```
class AppSpacing {
  AppSpacing._(); // Private constructor to prevent instantiation

  // Base spacing units (multiples of 4)
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 48.0;

  // Component-specific spacing
  static const double cardPadding = 20.0;
  static const double cardPaddingVertical = 20.0;
  static const double cardPaddingHorizontal = 20.0;
  
  static const double buttonPaddingVertical = 14.0;
  static const double buttonPaddingHorizontal = 24.0;
  
  static const double screenPadding = 24.0;
  static const double screenPaddingHorizontal = 24.0;
  static const double screenPaddingVertical = 16.0;

  // Border radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusCard = 16.0;
  static const double radiusButton = 12.0;
  static const double radiusSheet = 24.0;

  // Touch targets (minimum 48x48dp for accessibility)
  static const double minTouchTarget = 48.0;
  static const double iconButtonSize = 48.0;

  // List spacing
  static const double listItemSpacing = 12.0;
  static const double listItemPadding = 16.0;

  // Section spacing
  static const double sectionSpacing = 24.0;
  static const double sectionHeaderSpacing = 16.0;
}
