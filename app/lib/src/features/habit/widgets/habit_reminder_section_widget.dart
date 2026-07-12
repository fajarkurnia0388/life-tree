import 'package:flutter/material.dart';

class HabitReminderSectionWidget extends StatelessWidget {
  final bool reminderEnabled;
  final ValueChanged<bool> onReminderEnabledChanged;
  final String reminderTime;
  final ValueChanged<String> onReminderTimeChanged;
  final String quietHoursStart;
  final ValueChanged<String> onQuietHoursStartChanged;
  final String quietHoursEnd;
  final ValueChanged<String> onQuietHoursEndChanged;

  const HabitReminderSectionWidget({
    super.key,
    required this.reminderEnabled,
    required this.onReminderEnabledChanged,
    required this.reminderTime,
    required this.onReminderTimeChanged,
    required this.quietHoursStart,
    required this.onQuietHoursStartChanged,
    required this.quietHoursEnd,
    required this.onQuietHoursEndChanged,
  });

  Future<void> _selectTime(
    BuildContext context,
    String currentTime,
    ValueChanged<String> onChanged,
  ) async {
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 8,
      minute: int.tryParse(parts[1]) ?? 0,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      final hourStr = picked.hour.toString().padLeft(2, '0');
      final minuteStr = picked.minute.toString().padLeft(2, '0');
      onChanged('$hourStr:$minuteStr');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.notifications_active_outlined,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Pengingat Kebiasaan',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Switch(
                  value: reminderEnabled,
                  onChanged: onReminderEnabledChanged,
                ),
              ],
            ),
            if (reminderEnabled) ...[
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Waktu Pengingat',
                  style: TextStyle(fontSize: 14),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    reminderTime,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                onTap: () => _selectTime(context, reminderTime, onReminderTimeChanged),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Jam Sunyi Mulai (Quiet Start)',
                  style: TextStyle(fontSize: 14),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    quietHoursStart,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                onTap: () => _selectTime(context, quietHoursStart, onQuietHoursStartChanged),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Jam Sunyi Selesai (Quiet End)',
                  style: TextStyle(fontSize: 14),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    quietHoursEnd,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                onTap: () => _selectTime(context, quietHoursEnd, onQuietHoursEndChanged),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
