# Vitality Radar Specification

> **Status:** Design — ready for Phase 1 implementation
> **Last updated:** 2026-07-02
> **Codebase verified:** yes — all types, field names, and formulas match actual source

---

## Purpose

The Vitality Radar is a dashboard feature that converts domain balance data into actionable detection signals and habit recommendations. It should feel like a radar system: continuously scanning the user's life domains, detecting imbalances, areas of stress, and growth opportunities, then presenting concise signals on the dashboard.

## Goals

- Provide a clear, English header for the dashboard component: `Vitality Radar`
- Turn the radar visual into a functional detection system
- Detect domain anomalies, low energy signals, burnout risk, and growth opportunities
- Provide recommendations for habits or actions in response to detected signals
- Keep the system lightweight, explainable, and suitable for initial MVP implementation

## Scope

The feature includes:

- signal detection service (`VitalityRadarService`)
- Riverpod provider (`vitalityRadarProvider`)
- UI badge and signal summary on the dashboard (`RadarChartWidget`)
- detail bottom sheet for signal recommendations
- integration with existing domain score, habits, journal, and canopy load data

---

## Codebase Context

### Domain Keys

The app uses exactly 6 domains, defined in `DomainDefaults.scores` in `app_constants.dart`:

```dart
const Map<String, double> scores = {
  'Tubuh':     5.0,  // Body / Physical
  'Keuangan':  5.0,  // Finance
  'Hubungan':  5.0,  // Relationships
  'Emosi':     5.0,  // Emotion / Mental
  'Karir':     5.0,  // Career
  'Rekreasi':  5.0,  // Recreation / Rest
};
```

All detection algorithms must use these exact string keys.

### Season Constants

`Season` is a class with string constants (not a Dart enum):

```dart
class Season {
  static const String growth   = 'Growth';
  static const String recovery = 'Recovery';
  static const String dormant  = 'Dormant';
}
```

Detection behavior should adapt based on the current season string.

### Domain Score Source

Domain scores are stored as JSON in `UserProfile.latestDomainScores` (a `String?` field). The dashboard blends baseline scores with daily habit completion:

```
blendedScore[domain] = (baselineScore × 0.7 + dailyScore × 0.3).clamp(1.0, 10.0)
```

The `RadarChartWidget` receives a `Map<String, double> scores` parameter with these blended values.

### Canopy Load Formula

There is no separate canopy model. Load is computed on-the-fly:

```
canopyLoad = Σ(habit.initiationFriction + habit.energyCost) for all active habits
canopyCapacity = UserProfile.canopyLoadCapacity  // int, default = 10
loadRatio = canopyLoad / canopyCapacity
```

Both `initiationFriction` and `energyCost` are `int` fields on the `Habit` data class (scale 1–5).

### Habit Model (relevant fields)

```dart
class Habit {
  final String habitId;
  final String? domainTag;       // one of the 6 domain keys, or null
  final String status;           // 'Active', 'Archived', etc.
  final int initiationFriction;  // 1–5
  final int energyCost;          // 1–5
  final int impactScore;         // 1–5
  final double? completionRate90d;
  final DateTime createdAt;
  final DateTime? deletedAt;
}
```

### JournalEntry Model (relevant fields)

```dart
class JournalEntry {
  final String entryId;
  final DateTime date;
  final int moodScore;           // numeric mood rating
  final String? keyword;
  final String? textContent;
  final String entryType;        // 'Lite' or 'Deep'
  final DateTime? deletedAt;
}
```

### DashboardData (existing provider output)

```dart
class DashboardData {
  final UserProfile profile;          // includes latestDomainScores, canopyLoadCapacity, supportMode
  final int cumulativeDays;
  final String season;                // Season.growth / recovery / dormant
  final Habit? actionOfTheDay;
  final List<HabitWithLog> habitsToday;
  final bool allDone;
  final bool hasOverdueDecisions;
}
```

---

## Key Concepts

### Radar Signals

Each signal represents a condition detected in the user's life data.

Signal types:

- `lowDomain` — one or more domains are trending too low
- `imbalance` — domain scores are too uneven across the radar
- `burnoutWarning` — canopy load is too high relative to capacity
- `growthOpportunity` — stable domains are ready for new habits

Each signal includes:

- `title`
- `description`
- `severity` (low, medium, high)
- `domains` involved (list of domain key strings)
- `recommendations`
- `createdAt`
- optional `score` (numeric value that triggered the signal)

### Data Inputs

Data sources for detection:

- `Map<String, double> domainScores` — blended domain scores from `RadarChartWidget`
- `List<Habit> activeHabits` — habits with `status == 'Active'` and `deletedAt == null`
- `int canopyCapacity` — from `UserProfile.canopyLoadCapacity`
- `String season` — from `DashboardData.season`
- `List<JournalEntry> recentJournals` — last 7–14 days, for mood trend (Phase 2+)

---

## Data Structures

### RadarSignal

```dart
enum RadarSignalType { lowDomain, imbalance, burnoutWarning, growthOpportunity }

enum RadarSignalSeverity { low, medium, high }

class RadarSignal {
  final RadarSignalType type;
  final RadarSignalSeverity severity;
  final String title;
  final String description;
  final List<String> domains;       // domain keys e.g. ['Tubuh', 'Emosi']
  final List<String> recommendations;
  final DateTime createdAt;
  final double? score;              // numeric trigger value for transparency

  const RadarSignal({
    required this.type,
    required this.severity,
    required this.title,
    required this.description,
    required this.domains,
    required this.recommendations,
    required this.createdAt,
    this.score,
  });
}
```

### VitalityRadarState

````dart
class VitalityRadarState {
  final List<RadarSignal> signals;
  final double balanceIndex;        // 0.0–1.0, average of all domain scores / 10
  final bool isRecoveryMode;        // season == Season.recovery

  const VitalityRadarState({
    required this.signals,
    required this.balanceIndex,
    required this.isRecoveryMode,
  });

  int get highCount => signals.where((s) => s.severity == RadarSignalSeverity.high).length;
  int get totalCount => signals.length;
}

## Detection Algorithms

All algorithms receive the same inputs from `VitalityRadarService.detectSignals()`. They operate on current snapshot data (no historical trend table needed for MVP).

### 1. Low Domain Detection

**Purpose:** detect domains with a score below a healthy threshold.

**Inputs:** `Map<String, double> domainScores`

**Logic:**
- iterate over all 6 domain keys
- if `score < 4.0`, create a `lowDomain` signal for that domain
- severity: `high` if `score < 3.0`, otherwise `medium`
- skip domains not in `activeDomains` (not yet unlocked by user)

**Pseudocode:**

```dart
List<RadarSignal> _detectLowDomains(Map<String, double> scores) {
  final signals = <RadarSignal>[];
  for (final entry in scores.entries) {
    final domain = entry.key;   // e.g. 'Tubuh', 'Emosi'
    final score  = entry.value; // blended 1.0–10.0
    if (score < 4.0) {
      signals.add(RadarSignal(
        type: RadarSignalType.lowDomain,
        severity: score < 3.0 ? RadarSignalSeverity.high : RadarSignalSeverity.medium,
        title: 'Low $domain score',
        description: 'Your $domain score is at ${score.toStringAsFixed(1)} — below the healthy range.',
        domains: [domain],
        recommendations: _lowDomainRecommendations(domain),
        createdAt: DateTime.now(),
        score: score,
      ));
    }
  }
  return signals;
}
````

**Per-domain recommendations (hard-coded for MVP):**

| Domain   | Recommendation examples                                  |
| -------- | -------------------------------------------------------- |
| Tubuh    | Add a 5-min movement habit · Prioritize sleep tonight    |
| Keuangan | Review one expense this week · Set a small savings goal  |
| Hubungan | Reach out to one person today · Schedule a catch-up      |
| Emosi    | Write 3 lines in your journal · Try a breathing exercise |
| Karir    | Block 30 min for focused work · Review your weekly goal  |
| Rekreasi | Take a proper break today · Do one thing just for fun    |

---

### 2. Balance Anomaly Detection

**Purpose:** identify a large gap between the strongest and weakest domain.

**Inputs:** `Map<String, double> domainScores`

**Logic:**

- find `maxScore` and `minScore` across all domains
- if `maxScore - minScore >= 5.0`, signal imbalance
- severity: `high` if gap >= 6.0, `medium` if gap >= 5.0
- include both the strongest and weakest domain in `domains`

**Pseudocode:**

```dart
List<RadarSignal> _detectImbalance(Map<String, double> scores) {
  final sorted = scores.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final strongest = sorted.first;
  final weakest   = sorted.last;
  final gap = strongest.value - weakest.value;

  if (gap >= 5.0) {
    return [RadarSignal(
      type: RadarSignalType.imbalance,
      severity: gap >= 6.0 ? RadarSignalSeverity.high : RadarSignalSeverity.medium,
      title: 'Life balance anomaly',
      description:
        '${strongest.key} (${strongest.value.toStringAsFixed(1)}) is much stronger '
        'than ${weakest.key} (${weakest.value.toStringAsFixed(1)}). '
        'A gap of ${gap.toStringAsFixed(1)} points may cause strain.',
      domains: [strongest.key, weakest.key],
      recommendations: [
        'Bring gentle attention to ${weakest.key}',
        'Maintain your strength in ${strongest.key} without over-investing',
      ],
      createdAt: DateTime.now(),
      score: gap,
    )];
  }
  return [];
}
```

---

### 3. Burnout Early Warning

**Purpose:** detect when canopy load is too high relative to capacity.

**Inputs:** `List<Habit> activeHabits`, `int canopyCapacity`

**Canopy load formula** (matches existing `add_habit_view.dart` logic):

```
canopyLoad = Σ(habit.initiationFriction + habit.energyCost)
             for all habits where status == 'Active' && deletedAt == null
loadRatio  = canopyLoad / canopyCapacity
```

**Logic:**

- compute `loadRatio`
- if `loadRatio >= 0.85`, severity `high`
- if `loadRatio >= 0.75`, severity `medium`
- skip this signal if `season == Season.recovery` (user is already resting)

**Pseudocode:**

```dart
List<RadarSignal> _detectBurnout(
  List<Habit> activeHabits,
  int canopyCapacity,
  String season,
) {
  if (season == Season.recovery) return [];  // already in rest mode

  final load = activeHabits.fold<int>(
    0, (sum, h) => sum + h.initiationFriction + h.energyCost,
  );
  final ratio = load / canopyCapacity;

  if (ratio >= 0.75) {
    return [RadarSignal(
      type: RadarSignalType.burnoutWarning,
      severity: ratio >= 0.85 ? RadarSignalSeverity.high : RadarSignalSeverity.medium,
      title: 'High life load detected',
      description:
        'Your canopy is at ${(ratio * 100).toStringAsFixed(0)}% capacity ($load/$canopyCapacity). '
        'Sustained overload may lead to burnout.',
      domains: [],  // not domain-specific
      recommendations: [
        'Consider pausing one low-impact habit temporarily',
        'Take a recovery day if possible',
        'Review which habits are truly essential this week',
      ],
      createdAt: DateTime.now(),
      score: ratio,
    )];
  }
  return [];
}
```

---

### 4. Growth Opportunity Detection

**Purpose:** recommend new habits when a domain is stable and has no recent habit additions.

**Inputs:** `Map<String, double> domainScores`, `List<Habit> activeHabits`

**Logic:**

- for each domain, check if score is in the stable range `7.0 <= score <= 8.5`
- check if no active habit with that `domainTag` was created in the last 30 days
- if both conditions met, create a `growthOpportunity` signal
- severity is always `low` (positive signal, not a warning)
- skip if `season == Season.dormant` (user is inactive)

**Pseudocode:**

````dart
List<RadarSignal> _detectGrowthOpportunity(
  Map<String, double> scores,
  List<Habit> activeHabits,
  String season,
) {
  if (season == Season.dormant) return [];

  final signals = <RadarSignal>[];
  final cutoff = DateTime.now().subtract(const Duration(days: 30));

  for (final entry in scores.entries) {
    final domain = entry.key;
    final score  = entry.value;

    if (score < 7.0 || score > 8.5) continue;

    final hasRecentHabit = activeHabits.any((h) =>
      h.domainTag == domain && h.createdAt.isAfter(cutoff),
    );
    if (hasRecentHabit) continue;

    signals.add(RadarSignal(
      type: RadarSignalType.growthOpportunity,
      severity: RadarSignalSeverity.low,
      title: 'Growth opportunity: $domain',
      description:
        'Your $domain score is stable at ${score.toStringAsFixed(1)}. '
        'This is a good time to add a new habit here.',
      domains: [domain],
      recommendations: [
        'Add one new supportive habit for $domain',
        'Try a small challenge to deepen your progress',
      ],
      createdAt: DateTime.now(),
      score: score,
    ));
  }
  return signals;
}

## Service Architecture

### VitalityRadarService

File: `app/lib/src/features/dashboard/services/vitality_radar_service.dart`

Responsibility:
- compute radar signals from available user data
- expose a single `detectSignals()` method
- support future extension with new signal types

```dart
class VitalityRadarService {
  List<RadarSignal> detectSignals({
    required Map<String, double> domainScores,
    required List<Habit> activeHabits,
    required int canopyCapacity,
    required String season,
  }) {
    return [
      ..._detectLowDomains(domainScores),
      ..._detectImbalance(domainScores),
      ..._detectBurnout(activeHabits, canopyCapacity, season),
      ..._detectGrowthOpportunity(domainScores, activeHabits, season),
    ];
  }

  // private detection methods (see algorithms above)
}
````

### Riverpod Provider

File: `app/lib/src/features/dashboard/providers/vitality_radar_provider.dart`

```dart
final vitalityRadarServiceProvider = Provider<VitalityRadarService>(
  (ref) => VitalityRadarService(),
);

final vitalityRadarProvider = FutureProvider<VitalityRadarState>((ref) async {
  final dashboardData = await ref.watch(dashboardDataProvider.future);
  final service = ref.read(vitalityRadarServiceProvider);

  // Parse domain scores from UserProfile JSON
  final rawScores = dashboardData.profile.latestDomainScores;
  final domainScores = rawScores != null
    ? Map<String, double>.from(jsonDecode(rawScores))
    : DomainDefaults.scores;

  // Get active habits from habitsToday or a separate query
  final activeHabits = dashboardData.habitsToday
    .map((h) => h.habit)
    .where((h) => h.status == 'Active' && h.deletedAt == null)
    .toList();

  final signals = service.detectSignals(
    domainScores: domainScores,
    activeHabits: activeHabits,
    canopyCapacity: dashboardData.profile.canopyLoadCapacity,
    season: dashboardData.season,
  );

  final balanceIndex = domainScores.values.fold(0.0, (a, b) => a + b)
    / (domainScores.length * 10.0);

  return VitalityRadarState(
    signals: signals,
    balanceIndex: balanceIndex,
    isRecoveryMode: dashboardData.season == Season.recovery,
  );
});
```

### Integration Points

| Component                    | Change needed                                          |
| ---------------------------- | ------------------------------------------------------ |
| `RadarChartWidget`           | Accept `VitalityRadarState?` and show badge            |
| `dashboard_view.dart`        | Watch `vitalityRadarProvider` and pass state to widget |
| `DashboardData`              | No change needed — provider reads from it              |
| `UserProfile`                | No change needed — `canopyLoadCapacity` already exists |
| New: `VitalityRadarService`  | New file in `dashboard/services/`                      |
| New: `vitalityRadarProvider` | New file in `dashboard/providers/`                     |
| New: `RadarSignalSheet`      | New bottom sheet widget                                |

## UI Design

### RadarChartWidget — Updated Layout

Current structure (existing):

```
Card
  └─ Column
       ├─ Header row: "Vitality Radar" + ? button
       ├─ SizedBox(330×330) → Stack
       │    ├─ CustomPaint (240×240) — _RadarChartPainter
       │    └─ 6 Positioned clickable label chips
       └─ _buildDataTable() — accessible fallback table
```

Updated structure (with signals):

```
Card
  └─ Column
       ├─ Header row
       │    ├─ Text "Vitality Radar"
       │    ├─ SignalBadge (count chip, color-coded)
       │    └─ ? info button
       ├─ SizedBox(330×330) → Stack (unchanged)
       └─ Signal summary strip (1 line, optional)
            e.g. "Low Emosi · Growth opportunity in Karir"
```

### Signal Badge

- Shown in the header row, right of the title
- Color rules:
  - red chip → at least 1 `high` severity signal
  - amber chip → only `medium` signals
  - green chip → only `low` (growth) signals
  - hidden → no signals
- Label: `"2 alerts"` or `"1 growth tip"`

### Signal Detail Bottom Sheet (`RadarSignalSheet`)

Triggered by tapping the badge or a dedicated button.

```
Bottom Sheet
  ├─ Handle bar
  ├─ Title: "Radar Signals"
  ├─ Subtitle: "Detected today · tap a signal to act"
  └─ ListView of RadarSignalCard widgets
       Each card:
         ├─ Icon (domain color or signal type icon)
         ├─ Title (signal.title)
         ├─ Description (signal.description)
         ├─ Severity chip (High / Medium / Growth)
         ├─ Domains involved (small chips)
         └─ Recommendations (bulleted list, 1–3 items)
```

### Severity Color Mapping

| Severity     | Color               | Icon                          |
| ------------ | ------------------- | ----------------------------- |
| high         | `Colors.red[400]`   | `Icons.warning_amber_rounded` |
| medium       | `Colors.amber[600]` | `Icons.info_outline`          |
| low (growth) | `Colors.green[500]` | `Icons.trending_up`           |

## Implementation Plan

### Phase 1: MVP

**New files to create:**

| File                                                                    | Purpose           |
| ----------------------------------------------------------------------- | ----------------- |
| `app/lib/src/features/dashboard/services/vitality_radar_service.dart`   | Detection logic   |
| `app/lib/src/features/dashboard/providers/vitality_radar_provider.dart` | Riverpod provider |
| `app/lib/src/features/dashboard/widgets/radar_signal_sheet.dart`        | Bottom sheet UI   |

**Files to modify:**

| File                                                             | Change                                     |
| ---------------------------------------------------------------- | ------------------------------------------ |
| `app/lib/src/features/dashboard/widgets/radar_chart_widget.dart` | Add `radarState` param, badge, tap handler |
| `app/lib/src/features/dashboard/dashboard_view.dart`             | Watch `vitalityRadarProvider`, pass state  |

**Detection rules in MVP:**

1. Low Domain Detection
2. Balance Anomaly Detection

**Success criteria:**

- dashboard shows signal count badge on Vitality Radar card
- tapping badge opens `RadarSignalSheet`
- signals update when domain scores change
- `flutter analyze` passes cleanly

---

### Phase 2: Strengthen Analytics

**Additional detection rules:** 3. Burnout Early Warning (canopy load ratio) 4. Growth Opportunity Detection (stable domain + no recent habit)

**Additional improvements:**

- use `JournalEntry.moodScore` trend for mood-aware signals
- add habit coverage check (domains with no active habit)
- rate-limit growth signals (max 1 per domain per 7 days)

---

### Phase 3: Personalization

**Future additions:**

- user feedback on signals (helpful / not helpful)
- adaptive thresholds based on user history
- signal history table in Drift database
- "recommended next action" surfaced on dashboard home

## UX Rules

- Keep headers concise and English: `Vitality Radar`.
- Avoid overly verbose labels in the dashboard card.
- Show only the most important signals on first glance.
- Display signal severity visually with color and icon.
- Use friendly language for recommendations.
- Do not overload the user with every possible alert.

## Example Dashboard Flow

1. User opens the dashboard.
2. `Vitality Radar` card shows 2 active signals.
3. The radar chart displays domain scores.
4. A badge or summary line indicates `Low Tubuh · Growth opportunity in Karir`.
5. User taps the card.
6. Bottom sheet displays:
   - `Low Tubuh score` → `Try adding a gentle self-care habit`
   - `Growth opportunity in Karir` → `Consider a new learning habit`
7. User accepts one recommendation or circulates back to habits.

## Technical Considerations

### Performance

- Compute radar signals on demand or when input data changes.
- Keep signal list small and cached for dashboard refresh.
- Avoid heavy cross-feature queries on every frame.

### Privacy

- Use only local data currently available in the app.
- Do not send journal content or sensitive details externally.
- Make detection conditions transparent in the UI.

### Extensibility

- Implement detection rules as separate methods.
- Allow future addition of new `RadarSignalType` values.
- Keep UI components modular so the radar card can be reused.

### Testing Strategy

See dedicated **Testing Strategy** section below.

## Testing Strategy

### Unit Tests

File: `app/test/vitality_radar_service_test.dart`

| Test case                           | Expected result                               |
| ----------------------------------- | --------------------------------------------- |
| score = 3.5 for Tubuh               | returns `lowDomain` signal, severity `medium` |
| score = 2.5 for Emosi               | returns `lowDomain` signal, severity `high`   |
| max-min gap = 5.5                   | returns `imbalance` signal                    |
| load ratio = 0.9, season = Growth   | returns `burnoutWarning`, severity `high`     |
| load ratio = 0.9, season = Recovery | no `burnoutWarning` signal                    |
| stable score 7.5, no habit in 30d   | returns `growthOpportunity`                   |
| stable score 7.5, season = Dormant  | no `growthOpportunity` signal                 |
| all scores 5.0, load ratio 0.5      | returns empty signal list                     |

### Widget Tests

File: `app/test/radar_chart_widget_test.dart`

- badge renders with correct count when signals are present
- badge is hidden when signal list is empty
- tapping badge opens `RadarSignalSheet`
- `RadarSignalSheet` displays signal titles and recommendations

### Integration Tests

- simulate domain score update → confirm new signals appear
- switch season to Recovery → confirm burnout signal disappears
- switch season to Dormant → confirm growth signal disappears

## Open Questions

- Should `Vitality Radar` use a dedicated history table for signals?
- Should growth opportunity suggestions be rate-limited to avoid repeated prompts?
- How should habit recommendations be prioritized when multiple signals involve the same domain?
- Should the radar UI include animated scanning lines or only static radar shape?

## Recommendation

Start with a compact MVP in the dashboard card, then expand into signal detail and habit recommendation flows. Keep the first release focused on clarity, actionability, and simple English labels.
