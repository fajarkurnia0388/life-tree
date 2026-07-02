import 'package:flutter/material.dart';

/// Reusable error state widget with retry functionality.
/// 
/// Displays an error icon, message, optional error details, and a retry button.
/// Designed to provide users with clear feedback and recovery options when errors occur.
/// 
/// Usage:
/// ```dart
/// if (snapshot.hasError) {
///   return ErrorStateWidget(
///     message: 'Gagal memuat data',
///     error: snapshot.error.toString(),
///     onRetry: () => setState(() {}),
///   );
/// }
/// ```
class ErrorStateWidget extends StatelessWidget {
  /// User-friendly error message
  final String message;

  /// Optional technical error details (collapsible)
  final String? error;

  /// Callback when retry button is pressed
  final VoidCallback? onRetry;

  /// Optional icon to display (defaults to error_outline)
  final IconData? icon;

  /// Optional custom color for the icon
  final Color? iconColor;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.error,
    this.onRetry,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error Icon
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: iconColor ?? theme.colorScheme.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 24),

            // User-friendly message
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Technical error details (if provided)
            if (error != null && error!.isNotEmpty) ...[
              _ErrorDetailsExpander(error: error!),
              const SizedBox(height: 20),
            ] else ...[
              const SizedBox(height: 20),
            ],

            // Retry button
            if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Collapsible error details expander
class _ErrorDetailsExpander extends StatefulWidget {
  final String error;

  const _ErrorDetailsExpander({required this.error});

  @override
  State<_ErrorDetailsExpander> createState() => _ErrorDetailsExpanderState();
}

class _ErrorDetailsExpanderState extends State<_ErrorDetailsExpander> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Toggle button
        TextButton.icon(
          onPressed: () => setState(() => _isExpanded = !_isExpanded),
          icon: Icon(
            _isExpanded ? Icons.expand_less : Icons.expand_more,
            size: 18,
          ),
          label: Text(
            _isExpanded ? 'Sembunyikan Detail' : 'Lihat Detail Error',
            style: const TextStyle(fontSize: 12),
          ),
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),

        // Error details (when expanded)
        if (_isExpanded)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.error.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              widget.error,
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.left,
            ),
          ),
      ],
    );
  }
}
