import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dashboard_provider.dart';

/// Dev tools for inspecting and simulating tree growth state during development.
class DevToolbarWidget extends StatelessWidget {
  const DevToolbarWidget({super.key, required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final ageOverride = ref.watch(devCumulativeDaysOverrideProvider);
        final isAgePlaying = ref.watch(devAgePlayProvider);
        final currentAge = ageOverride ?? data.cumulativeDays;

        return Card(
          color: Colors.blueGrey.withValues(alpha: 0.06),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.blueGrey.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.tune_rounded,
                      size: 15,
                      color: Colors.blueGrey,
                    ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$ageOverride Hari Virtual',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.nature_people_rounded,
                      size: 14,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Fase Pohon',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () =>
                          ref.read(devAgePlayProvider.notifier).toggle(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isAgePlaying
                              ? Colors.green.withValues(alpha: 0.15)
                              : Colors.grey.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isAgePlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              size: 14,
                              color: isAgePlaying ? Colors.green : Colors.grey,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              isAgePlaying ? 'Jeda' : 'Putar',
                              style: TextStyle(
                                fontSize: 10,
                                color: isAgePlaying
                                    ? Colors.green
                                    : Colors.grey,
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
                          ref
                                  .read(
                                    devCumulativeDaysOverrideProvider.notifier,
                                  )
                                  .state =
                              null;
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Reset',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 16,
                    ),
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
                      ref
                          .read(devCumulativeDaysOverrideProvider.notifier)
                          .state = val
                          .toInt();
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}
