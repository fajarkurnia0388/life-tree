import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/theme.dart';

class ValueMirrorIntroView extends StatelessWidget {
  const ValueMirrorIntroView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cermin Nilai 🪞'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  decoration: BoxDecoration(
                    color: CalmTheme.secondaryBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.balance_rounded,
                    size: 64,
                    color: CalmTheme.secondaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Cermin Nilai Hidupmu',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Bagaimana pilihan-pilihan kecilmu mencerminkan apa yang sebenarnya berharga bagi dirimu?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Panduan Anti-Guilt
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    _buildGuidelineRow(context, Icons.done_all_rounded, 'Tidak ada jawaban benar atau salah'),
                    const SizedBox(height: 12),
                    _buildGuidelineRow(context, Icons.visibility_off_rounded, 'Ini bukan tes kepribadian — ini adalah cermin pilihanmu'),
                    const SizedBox(height: 12),
                    _buildGuidelineRow(context, Icons.timer_outlined, 'Hanya memerlukan ~2 menit untuk 7 pertanyaan refleksi'),
                  ],
                ),
              ),
              const Spacer(),
              Semantics(
                label: 'Mulai sesi refleksi nilai',
                hint: 'Memulai sesi Value Mirror untuk refleksi nilai hidup Anda',
                button: true,
                child: ElevatedButton(
                  onPressed: () => context.push('/value-mirror/session'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CalmTheme.secondaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'Mulai Sesi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Semantics(
                label: 'Kembali',
                hint: 'Kembali ke halaman sebelumnya',
                button: true,
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    'Kembali',
                    style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuidelineRow(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: CalmTheme.secondaryBlue),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }
}
