import 'package:flutter/material.dart';

/// Helper class untuk standardisasi button hierarchy di aplikasi
///
/// Hierarchy:
/// - Primary Action: ElevatedButton dengan brand color (sage green)
/// - Secondary Action: OutlinedButton atau TextButton
/// - Destructive Action: Red color dengan confirmation
class AppButtonStyles {
  AppButtonStyles._();

  /// Primary action button - untuk aksi utama/positif
  /// Contoh: Simpan, Lanjut, Selesai, Tambah
  static ButtonStyle primary(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton.styleFrom(
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      minimumSize: const Size(120, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
    );
  }

  /// Secondary action button - untuk aksi sekunder/opsional
  /// Contoh: Batal, Lewati, Kembali
  static ButtonStyle secondary(BuildContext context) {
    final theme = Theme.of(context);
    return OutlinedButton.styleFrom(
      foregroundColor: theme.colorScheme.onSurface,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      minimumSize: const Size(100, 48),
      side: BorderSide(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  /// Destructive action button - untuk aksi yang menghapus data
  /// Contoh: Hapus, Reset
  static ButtonStyle destructive(BuildContext context) {
    return OutlinedButton.styleFrom(
      foregroundColor: Colors.red,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      minimumSize: const Size(100, 48),
      side: const BorderSide(color: Colors.red, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  /// Text button - untuk aksi tersier/subtle
  /// Contoh: Lihat Detail, Pelajari Lebih Lanjut
  static ButtonStyle text(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton.styleFrom(
      foregroundColor: theme.colorScheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      minimumSize: const Size(80, 44),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  /// Primary button dengan icon - untuk quick actions
  static ButtonStyle primaryWithIcon(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton.styleFrom(
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      minimumSize: const Size(100, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
    );
  }

  /// Secondary button untuk "Tidak Sanggup" pada habit
  static ButtonStyle habitSecondary(BuildContext context) {
    final theme = Theme.of(context);
    return OutlinedButton.styleFrom(
      foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      minimumSize: const Size(64, 44),
      side: BorderSide(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        width: 1,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  /// Floating action button style
  static Widget primaryFab({
    required VoidCallback onPressed,
    required IconData icon,
    String? tooltip,
    String? heroTag,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return FloatingActionButton(
          onPressed: onPressed,
          tooltip: tooltip,
          heroTag: heroTag,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          child: Icon(icon),
        );
      },
    );
  }
}

/// Extension untuk kemudahan penggunaan
extension ButtonStyleExtension on Widget {
  /// Wrap button dengan semantic label untuk accessibility
  Widget withSemantics({
    required String label,
    String? hint,
    bool isButton = true,
  }) {
    return Semantics(label: label, hint: hint, button: isButton, child: this);
  }
}

/// Helper untuk dialog actions dengan hierarchy yang jelas
class DialogActions {
  DialogActions._();

  /// Positive action (kiri) + Negative action (kanan)
  /// Digunakan untuk konfirmasi umum
  static List<Widget> confirmCancel({
    required BuildContext context,
    required String confirmText,
    required VoidCallback onConfirm,
    String cancelText = 'Batal',
    VoidCallback? onCancel,
  }) {
    return [
      TextButton(
        onPressed: onCancel ?? () => Navigator.of(context).pop(false),
        child: Text(cancelText),
      ),
      ElevatedButton(
        onPressed: () {
          onConfirm();
          Navigator.of(context).pop(true);
        },
        style: AppButtonStyles.primary(context),
        child: Text(confirmText),
      ),
    ];
  }

  /// Destructive action (kiri) + Safe action (kanan)
  /// Digunakan untuk konfirmasi penghapusan
  static List<Widget> destructiveCancel({
    required BuildContext context,
    required String destructiveText,
    required VoidCallback onDestructive,
    String cancelText = 'Batal',
    VoidCallback? onCancel,
  }) {
    return [
      TextButton(
        onPressed: onCancel ?? () => Navigator.of(context).pop(false),
        child: Text(cancelText),
      ),
      OutlinedButton(
        onPressed: () {
          onDestructive();
          Navigator.of(context).pop(true);
        },
        style: AppButtonStyles.destructive(context),
        child: Text(destructiveText),
      ),
    ];
  }
}
