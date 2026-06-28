import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dashboard_provider.dart';

/// Dev Tools widget untuk debugging
class DevToolbarWidget extends StatelessWidget {
  const DevToolbarWidget({
    super.key,
    required this.data,
  });

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final ageOverride = ref.watch(devCumulativeDaysOverrideProvider);
        final timeOverride = ref.watch(devTimeOfDayOverrideProvider);
        final isAgePlaying = ref.watch(devAgePlayProvider);
        final isTimePlaying = ref.watch(devTimePlayProvider);
        final currentAge = ageOverride ?? data.cumulativeDays;

        return Card(
          color: Colors.blueGrey.withValues(alpha: 0.06),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.blueGrey.withValues(alpha: 0.2), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tune_rounded, size: 15, color: Colors.blueGrey),
                    const SizedBox(width: 6),
                    const Text(
                      'DEV TOOLS 🛠️',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                        letterSpacing: 1,
                      ),
                    ),
                    const Spacer(),
                    if (ageOverride != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$ageOverride Hari Virtual',
                          style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.nature_people_rounded, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    const Text('Usia Pohon', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => ref.read(devAgePlayProvider.notifier).toggle(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isAgePlaying ? Colors.green.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isAgePlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              size: 14,
                              color: isAgePlaying ? Colors.green : Colors.grey,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              isAgePlaying ? 'Jeda' : 'Putar',
                              style: TextStyle(
                                fontSize: 10,
                                color: isAgePlaying ? Colors.green : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (ageOverride != null)
                      GestureDetector(
                        onTap: () {
                          ref.read(devAgePlayProvider.notifier).stop();
                          ref.read(devCumulativeDaysOverrideProvider.notifier).state = null;
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Reset',
                            style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                    activeTrackColor: Colors.green,
                    thumbColor: Colors.green,
                    inactiveTrackColor: Colors.green.withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: currentAge.toDouble().clamp(0.0, 100.0),
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: '$currentAge Hari',
                    onChanged: (val) {
                      ref.read(devAgePlayProvider.notifier).stop();
                      ref.read(devCumulativeDaysOverrideProvider.notifier).state = val.toInt();
                    },
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.nights_stay_rounded, size: 14, color: Colors.purple),
                    const SizedBox(width: 4),
                    const Text('Waktu Langit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => ref.read(devTimePlayProvider.notifier).toggle(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isTimePlaying ? Colors.purple.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isTimePlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              size: 14,
                              color: isTimePlaying ? Colors.purple : Colors.grey,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              isTimePlaying ? 'Jeda' : 'Siklus Auto',
                              style: TextStyle(
                                fontSize: 10,
                                color: isTimePlaying ? Colors.purple : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: [
                    _timeChip(ref, 'Auto', null, timeOverride),
                    _timeChip(ref, '🌅 Pagi', CelestialTime.morning, timeOverride),
                    _timeChip(ref, '☀️ Siang', CelestialTime.noon, timeOverride),
                    _timeChip(ref, '🌇 Sore', CelestialTime.sunset, timeOverride),
                    _timeChip(ref, '🌙 Malam', CelestialTime.night, timeOverride),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _timeChip(WidgetRef ref, String label, CelestialTime? time, CelestialTime currentOverride) {
    final resolvedTime = time ?? CelestialTime.auto;
    final isSelected = currentOverride == resolvedTime;
    return Semantics(
      button: true,
      label: 'Waktu langit $label',
      selected: isSelected,
      child: FilterChip(
        label: Text(label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        selected: isSelected,
        onSelected: (_) {
          ref.read(devTimePlayProvider.notifier).stop();
          ref.read(devTimeOfDayOverrideProvider.notifier).state = resolvedTime;
        },
        selectedColor: Colors.purple.withValues(alpha: 0.2),
        checkmarkColor: Colors.purple,
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
    );
  }
}
