import 'package:flutter/material.dart';

/// Reusable loading state widget with contextual messages.
/// 
/// Displays a loading indicator with an optional message to inform users
/// what is being loaded, improving perceived performance.
/// 
/// Usage:
/// ```dart
/// loading: () => LoadingStateWidget(
///   message: 'Memuat data dashboard...',
/// ),
/// ```
class LoadingStateWidget extends StatelessWidget {
  /// Contextual message explaining what is loading
  final String? message;

  /// Whether to show a progress indicator (circular spinner)
  final bool showProgress;

  /// Optional progress value (0.0 to 1.0) for determinate progress
  final double? progressValue;

  const LoadingStateWidget({
    super.key,
    this.message,
    this.showProgress = true,
    this.progressValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Progress Indicator
          if (showProgress)
            if (progressValue != null)
              // Determinate progress (shows actual progress)
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  value: progressValue,
                  strokeWidth: 3,
                ),
              )
            else
              // Indeterminate progress (spinner)
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                ),
              ),

          // Message
          if (message != null && message!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Skeleton loading widget for lists
/// 
/// Shows a placeholder skeleton while content is loading,
/// improving perceived performance.
class SkeletonLoadingWidget extends StatelessWidget {
  /// Number of skeleton items to show
  final int itemCount;

  /// Height of each skeleton item
  final double itemHeight;

  const SkeletonLoadingWidget({
    super.key,
    this.itemCount = 3,
    this.itemHeight = 80,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Container(
          height: itemHeight,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title skeleton
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle skeleton
                Container(
                  height: 12,
                  width: 200,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.07)
                        : Colors.black.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
