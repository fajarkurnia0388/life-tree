import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/theme/theme.dart';
import '../../../core/providers/db_provider.dart';
import '../../../data/local_db/database.dart';
import '../../habit/services/habit_log_service.dart';
import '../dashboard_provider.dart';

/// Bottom sheet for friction intervention — shown when user taps "Tidak Sanggup".
class FrictionInterventionSheet extends ConsumerStatefulWidget {
  final Habit habit;
  const FrictionInterventionSheet({super.key, required this.habit});

  @override
  ConsumerState<FrictionInterventionSheet> createState() =>
      _FrictionInterventionSheetState();
}

class _FrictionInterventionSheetState
    extends ConsumerState<FrictionInterventionSheet> {
  String? _selectedReason; // 'Kurang_Waktu', 'Kelelahan', 'Lupa'
  int _recoveryDays = 3;

  Future<void> _submitIntervention() async {
    if (_selectedReason == null) return;

    final service = ref.read(habitLogServiceProvider);
    final db = ref.read(dbProvider);
    final now = DateTime.now();

    // Safe upsert Missed log via HabitLogService (no duplicate conflict)
    await service.markMissedWithReason(
      habit: widget.habit,
      date: now,
      reason: _selectedReason!,
    );

    // Apply specific intervention logic based on user choice
    if (_selectedReason == 'Kelelahan') {
      final profiles = await db.select(db.userProfiles).get();
      if (profiles.isNotEmpty) {
        await (db.update(db.userProfiles)
              ..where((tbl) => tbl.userId.equals(profiles.first.userId)))
            .write(UserProfilesCompanion(
              supportMode: const drift.Value('Recovery'),
              updatedAt: drift.Value(now),
            ));
      }
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Ada apa hari ini?',
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Jangan merasa bersalah. Menghadapi rintangan adalah bagian dari proses pembentukan kebiasaan.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 24),
          _buildReasonTile(
            value: 'Kurang_Waktu',
            icon: Icons.timer_outlined,
            title: 'Kurang Waktu',
            desc: 'Saya hanya punya sedikit waktu hari ini.',
          ),
          _buildReasonTile(
            value: 'Kelelahan',
            icon: Icons.battery_alert_rounded,
            title: 'Kelelahan / Sakit',
            desc: 'Energi saya benar-benar terkuras hari ini.',
          ),
          _buildReasonTile(
            value: 'Lupa',
            icon: Icons.notifications_off_outlined,
            title: 'Lupa / Kurang Fokus',
            desc: 'Saya terlewat karena tidak ingat jadwalnya.',
          ),
          const SizedBox(height: 16),
          if (_selectedReason == 'Kurang_Waktu')
            Card(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('💡 Tips Ringan',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: CalmTheme.primarySage)),
                    const SizedBox(height: 8),
                    Text(
                      'Bagaimana jika kita kurangi target besok ke versi ringkas (${widget.habit.mvaDurationMin} menit) saja?',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          if (_selectedReason == 'Kelelahan')
            Card(
              color: CalmTheme.secondaryBlue.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('❄️ Masuk Mode Istirahat',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: CalmTheme.secondaryBlue)),
                    const SizedBox(height: 8),
                    const Text(
                      'Pohon Anda akan diselimuti salju dan notifikasi akan dijeda sementara.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [3, 5, 7].map((days) {
                        final isSelected = _recoveryDays == days;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ChoiceChip(
                            label: Text('$days Hari'),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) setState(() => _recoveryDays = days);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          if (_selectedReason == 'Lupa')
            Card(
              color: Colors.amber.withValues(alpha: 0.05),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('🔗 Routine Stacking',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber)),
                    SizedBox(height: 8),
                    Text(
                      'Coba kaitkan kebiasaan ini tepat setelah aktivitas harian yang pasti Anda lakukan (misal: setelah minum kopi pagi).',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _selectedReason != null ? _submitIntervention : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              minimumSize: const Size(88, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Simpan & Refleksikan'),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonTile({
    required String value,
    required IconData icon,
    required String title,
    required String desc,
  }) {
    final isSelected = _selectedReason == value;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RadioListTile<String>(
        value: value,
        groupValue: _selectedReason,
        onChanged: (val) => setState(() => _selectedReason = val),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc, style: const TextStyle(fontSize: 12)),
        secondary: Icon(icon,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.4)),
        selected: isSelected,
        activeColor: theme.colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.08),
            width: isSelected ? 1.5 : 1,
          ),
        ),
      ),
    );
  }
}
