import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';

/// Quick actions grid panel — shortcuts to Journal, Thinking Canvas, Add Habit, etc.
class QuickActionsPanel extends StatelessWidget {
  const QuickActionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Refleksi & Bantuan', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.mood_rounded,
                label: 'Mood & Jurnal',
                color: CalmTheme.primarySage,
                onTap: () => context.push('/journal'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.edit_note_rounded,
                label: 'Thinking Canvas',
                color: CalmTheme.secondaryBlue,
                onTap: () => context.push('/thinking-canvas'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => context.push('/add-habit'),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Buat Kebiasaan Baru'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            foregroundColor: theme.colorScheme.primary,
            elevation: 0,
            minimumSize: const Size(88, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: color.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.2), width: 1.5),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(fontWeight: FontWeight.w600, color: color, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
