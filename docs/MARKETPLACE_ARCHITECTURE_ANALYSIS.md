# Marketplace Architecture Analysis

**Date:** 2026-07-03  
**Purpose:** Understand current marketplace implementation for refactoring into a generic system

---

## 1. Current Marketplace Structure

### 1.1 Database Schema

**Location:** [app/lib/src/data/local_db/database.dart](app/lib/src/data/local_db/database.dart#L241-L260)

```dart
@DataClassName('MarketplaceTemplate')
class MarketplaceTemplates extends Table {
  TextColumn get templateId => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get domainTag => text()();          // Domain categorization
  IntColumn get friction => integer()();          // Habit-specific: initiation friction
  IntColumn get energy => integer()();            // Habit-specific: energy cost
  IntColumn get impact => integer()();            // Habit-specific: impact score
  IntColumn get mvaDuration => integer()();       // Habit-specific: MVA duration
  TextColumn get creatorPenName => text()();     // Creator attribution
  IntColumn get ratingsSum => integer()();        // Rating system
  IntColumn get ratingsCount => integer()();      // Rating count
  IntColumn get downloadsCount => integer()();    // Download tracking
  DateTimeColumn get createdAt => dateTime()();   // Timestamp

  @override
  Set<Column> get primaryKey => {templateId};
}
```

**Key Observations:**

- ✅ Generic fields: `templateId`, `title`, `description`, `domainTag`, `creatorPenName`, `ratingsSum`, `ratingsCount`, `downloadsCount`, `createdAt`
- ❌ Habit-specific fields: `friction`, `energy`, `impact`, `mvaDuration`
- **Refactoring Need:** Extract habit-specific fields into a flexible JSON metadata column

---

## 2. Service Layer Architecture

### 2.1 PublicTemplate Model

**Location:** [app/lib/src/features/marketplace/marketplace_service.dart](app/lib/src/features/marketplace/marketplace_service.dart#L1-L70)

```dart
class PublicTemplate {
  final String templateId;
  final String title;
  final String description;
  final String domainTag;
  final int friction;        // Habit-specific
  final int energy;          // Habit-specific
  final int impact;          // Habit-specific
  final int mvaDuration;     // Habit-specific
  final String creatorPenName;
  final int ratingsSum;
  final int ratingsCount;
  final int downloadsCount;
  final DateTime createdAt;

  double get averageRating => ratingsCount == 0 ? 0.0 : ratingsSum / ratingsCount;
}
```

**Refactoring Strategy:**

- Create generic `PublicTemplate<T>` with type parameter for metadata
- Or use `Map<String, dynamic> metadata` field

### 2.2 MarketplaceService Interface

**Location:** [app/lib/src/features/marketplace/marketplace_service.dart](app/lib/src/features/marketplace/marketplace_service.dart#L71-L87)

```dart
abstract class MarketplaceService {
  Future<List<PublicTemplate>> fetchTemplates({
    String? domain,
    String? query,
    String? sortBy
  });

  Future<void> uploadTemplate({
    required String title,
    required String description,
    required String domainTag,
    required int friction,     // Habit-specific
    required int energy,       // Habit-specific
    required int impact,       // Habit-specific
    required int mvaDuration,  // Habit-specific
    required String creatorPenName,
  });

  Future<void> rateTemplate(String templateId, int rating);
  Future<void> incrementDownloads(String templateId);
}
```

**Analysis:**

- ✅ `fetchTemplates`, `rateTemplate`, `incrementDownloads` are generic
- ❌ `uploadTemplate` is tightly coupled to habit fields
- **Refactoring Need:** Add `templateType` parameter and generic metadata

### 2.3 LocalMarketplaceService Implementation

**Location:** [app/lib/src/features/marketplace/marketplace_service.dart](app/lib/src/features/marketplace/marketplace_service.dart#L89-L350)

**Key Methods:**

1. **`_seedIfEmpty()`** - Seeds 10 habit templates on first run
2. **`fetchTemplates()`** - Filters by domain, search query, and sorts
3. **`uploadTemplate()`** - Inserts new template to database
4. **`rateTemplate()`** - Updates rating aggregates
5. **`incrementDownloads()`** - Increments download counter

**Seeded Template Domains:**

- Tubuh (Body): 4 templates
- Emosi (Emotion): 2 templates
- Keuangan (Finance): 1 template
- Hubungan (Relationships): 1 template
- Karir (Career): 1 template
- Rekreasi (Recreation): 1 template

**Provider:**

```dart
final marketplaceServiceProvider = Provider<MarketplaceService>((ref) {
  final db = ref.watch(dbProvider);
  return LocalMarketplaceService(db);
});
```

---

## 3. UI Layer

### 3.1 MarketplaceView Widget

**Location:** [app/lib/src/features/marketplace/marketplace_view.dart](app/lib/src/features/marketplace/marketplace_view.dart)

**Structure:**

```
MarketplaceView (ConsumerStatefulWidget)
├── AppBar
│   ├── Title: "Marketplace Kebiasaan"
│   └── Share button (opens ShareTemplateBottomSheet)
├── Search TextField
├── Domain Filter (Horizontal ChoiceChips)
│   └── ['Semua', 'Tubuh', 'Keuangan', 'Hubungan', 'Emosi', 'Karir', 'Rekreasi']
├── Sort Options (Horizontal ChoiceChips)
│   └── ['Terpopuler', 'Terbaik', 'Terbaru']
└── Template List (FutureBuilder)
    ├── Loading: LoadingStateWidget
    ├── Empty: EmptyStateWidget
    └── List: MarketplaceTemplateCard (multiple)
```

**State Management:**

- `_searchController` - Search input
- `_selectedDomain` - Currently selected domain filter
- `_sortBy` - Current sort mode
- `_templatesFuture` - Async template data

**Key Methods:**

1. **`_refreshTemplates()`** - Fetches templates with current filters
2. **`_downloadTemplate()`** - Converts template to Habit and inserts to DB
3. **`_rateTemplate()`** - Shows rating dialog and submits rating
4. **`_showShareDialog()`** - Opens share bottom sheet

**Download Logic (Habit-Specific):**

```dart
// Creates a new Habit from PublicTemplate
final newHabit = HabitsCompanion.insert(
  habitId: habitId,
  userId: userId,
  domainTag: drift.Value(t.domainTag),
  title: t.title,
  status: const drift.Value(HabitStatus.active),
  frequency: const drift.Value('Daily'),
  initiationFriction: drift.Value(t.friction),
  originalFriction: drift.Value(t.friction),
  energyCost: drift.Value(t.energy),
  impactScore: drift.Value(t.impact),
  mvaDurationMin: drift.Value(t.mvaDuration),
  createdAt: now,
);
```

### 3.2 MarketplaceTemplateCard Widget

**Location:** [app/lib/src/features/marketplace/widgets/marketplace_template_card.dart](app/lib/src/features/marketplace/widgets/marketplace_template_card.dart)

**Visual Structure:**

```
Card
├── Domain Tag Badge (e.g., "Tubuh")
├── Star Rating Display (e.g., "4.8 (10)")
├── Title (Bold, Medium)
├── Creator ("Oleh: dr. Budi")
├── Description
├── Metrics Row
│   ├── MVA Duration (Timer icon)
│   ├── Beban/Load (Fitness icon)
│   └── Downloads (Download icon)
├── Divider
└── Action Buttons
    ├── "Beri Rating" (OutlinedButton)
    └── "Gunakan" (ElevatedButton)
```

**Props:**

- `template: PublicTemplate` - Template data
- `onRate: VoidCallback` - Rating action
- `onDownload: VoidCallback` - Download action

### 3.3 ShareTemplateBottomSheet Widget

**Location:** [app/lib/src/features/marketplace/widgets/share_template_bottom_sheet.dart](app/lib/src/features/marketplace/widgets/share_template_bottom_sheet.dart)

**Structure:**

```
BottomSheet
├── Header: "Bagikan Kebiasaan Saya 👥"
├── Form
│   ├── Dropdown: Select Active Habit
│   ├── TextFormField: Description/Tips (min 10 chars)
│   ├── TextFormField: Pen Name (optional, max 30 chars)
│   └── Submit Button: "Bagikan Sekarang"
└── Loading/Empty States
```

**Logic:**

1. Loads user's active habits from database
2. User selects a habit to share
3. User provides description/tips
4. Optionally provides pen name
5. Calls `service.uploadTemplate()` with habit data

---

## 4. Navigation & Routing

### 4.1 Route Registration

**Location:** [app/lib/src/core/routing/router.dart](app/lib/src/core/routing/router.dart#L78-L82)

```dart
GoRoute(
  path: '/marketplace',
  builder: (context, state) => const MarketplaceView(),
),
```

### 4.2 Navigation Entry Points

**1. Bottom Navigation Bar**  
**Location:** [app/lib/src/features/navigation/main_navigation_shell.dart](app/lib/src/features/navigation/main_navigation_shell.dart#L25-L70)

- Tab 4: "Marketplace" with storefront icon
- Displays MarketplaceView in IndexedStack

**2. Add Habit View AppBar**  
**Location:** [app/lib/src/features/habit/add_habit_view.dart](app/lib/src/features/habit/add_habit_view.dart#L295-L301)

```dart
IconButton(
  icon: const Icon(Icons.storefront_outlined),
  tooltip: 'Marketplace ${CultivationStrings.habitLabel(languageLevel)}',
  onPressed: () => context.push('/marketplace'),
),
```

**3. Reflection Dashboard**  
**Location:** Referenced in grep search (reflection_dashboard_tab.dart)

- "Habit Marketplace 🛒" tile

**4. Thinking Canvas Workspaces**  
**Location:** Referenced in grep search (brainstorm_workspaces.dart, morphological_workspace.dart)

- Brainstorm: `_openMarketplace()` method
- Morphological: `_showTemplateMarketplace()` method

---

## 5. Refactoring Requirements for Generic System

### 5.1 Database Schema Changes

**Proposed New Schema:**

```dart
@DataClassName('MarketplaceTemplate')
class MarketplaceTemplates extends Table {
  // Generic fields (keep as-is)
  TextColumn get templateId => text()();
  TextColumn get templateType => text()();        // NEW: 'habit' | 'core_value'
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get domainTag => text()();
  TextColumn get creatorPenName => text()();
  IntColumn get ratingsSum => integer()();
  IntColumn get ratingsCount => integer()();
  IntColumn get downloadsCount => integer()();
  DateTimeColumn get createdAt => dateTime()();

  // Type-specific metadata (NEW)
  TextColumn get metadata => text().map(const JsonConverter())();

  @override
  Set<Column> get primaryKey => {templateId};
}
```

**Metadata Examples:**

```dart
// For habit templates
{
  "friction": 1,
  "energy": 2,
  "impact": 4,
  "mvaDuration": 5
}

// For core value templates
{
  "category": "intrinsic",
  "conflicts": ["power", "achievement"],
  "culturalOrigin": "eastern",
  "reflectionPrompts": ["...", "..."]
}
```

### 5.2 Service Layer Changes

**Generic PublicTemplate:**

```dart
class PublicTemplate<T> {
  final String templateId;
  final String templateType;      // NEW
  final String title;
  final String description;
  final String domainTag;
  final String creatorPenName;
  final int ratingsSum;
  final int ratingsCount;
  final int downloadsCount;
  final DateTime createdAt;
  final T metadata;               // NEW: Type-safe metadata

  double get averageRating => ratingsCount == 0 ? 0.0 : ratingsSum / ratingsCount;
}

// Specific implementations
class HabitMetadata {
  final int friction;
  final int energy;
  final int impact;
  final int mvaDuration;
}

class CoreValueMetadata {
  final String category;
  final List<String> conflicts;
  final String culturalOrigin;
  final List<String> reflectionPrompts;
}
```

**Updated Service Interface:**

```dart
abstract class MarketplaceService {
  Future<List<PublicTemplate>> fetchTemplates({
    String? templateType,      // NEW: filter by type
    String? domain,
    String? query,
    String? sortBy
  });

  Future<void> uploadTemplate({
    required String templateType,           // NEW
    required String title,
    required String description,
    required String domainTag,
    required String creatorPenName,
    required Map<String, dynamic> metadata, // NEW: flexible metadata
  });

  Future<void> rateTemplate(String templateId, int rating);
  Future<void> incrementDownloads(String templateId);
}
```

### 5.3 UI Layer Changes

**Generic MarketplaceView:**

```dart
class MarketplaceView extends ConsumerStatefulWidget {
  final String templateType;  // NEW: 'habit' | 'core_value'

  const MarketplaceView({
    super.key,
    required this.templateType,
  });
}
```

**Abstract Template Card:**

```dart
abstract class BaseTemplateCard extends StatelessWidget {
  final PublicTemplate template;
  final VoidCallback onRate;
  final VoidCallback onDownload;

  @protected
  Widget buildMetadata(BuildContext context);  // Override for each type
}

class HabitTemplateCard extends BaseTemplateCard {
  @override
  Widget buildMetadata(BuildContext context) {
    final metadata = template.metadata as HabitMetadata;
    return Row(
      children: [
        _buildMetric(Icons.timer_outlined, 'MVA: ${metadata.mvaDuration}m'),
        _buildMetric(Icons.fitness_center_rounded, 'Beban: ${metadata.friction + metadata.energy}'),
      ],
    );
  }
}

class CoreValueTemplateCard extends BaseTemplateCard {
  @override
  Widget buildMetadata(BuildContext context) {
    final metadata = template.metadata as CoreValueMetadata;
    return Column(
      children: [
        _buildTag(metadata.category),
        _buildTag('Origin: ${metadata.culturalOrigin}'),
      ],
    );
  }
}
```

### 5.4 Navigation Changes

**Type-specific routes:**

```dart
GoRoute(
  path: '/marketplace/habits',
  builder: (context, state) => const MarketplaceView(templateType: 'habit'),
),
GoRoute(
  path: '/marketplace/core-values',
  builder: (context, state) => const MarketplaceView(templateType: 'core_value'),
),
```

---

## 6. Migration Strategy

### Phase 1: Database Migration

1. Add `templateType` column (default: 'habit')
2. Add `metadata` JSON column
3. Migrate existing rows:
   ```sql
   UPDATE marketplace_templates
   SET
     templateType = 'habit',
     metadata = json_object(
       'friction', friction,
       'energy', energy,
       'impact', impact,
       'mvaDuration', mvaDuration
     );
   ```
4. Mark old columns as deprecated (don't drop yet for rollback safety)

### Phase 2: Service Layer Refactoring

1. Create generic `PublicTemplate` with metadata field
2. Create `HabitMetadata` and `CoreValueMetadata` classes
3. Update `MarketplaceService` interface
4. Refactor `LocalMarketplaceService` implementation
5. Add metadata serialization/deserialization logic

### Phase 3: UI Refactoring

1. Create `BaseTemplateCard` abstract class
2. Refactor `MarketplaceTemplateCard` → `HabitTemplateCard`
3. Create `CoreValueTemplateCard`
4. Update `MarketplaceView` to accept `templateType` parameter
5. Create type-specific card factory

### Phase 4: Integration

1. Add core value seeding logic
2. Create `ShareCoreValueBottomSheet`
3. Update navigation routes
4. Add core value download logic to `MarketplaceView`

### Phase 5: Cleanup

1. Drop deprecated columns from schema
2. Remove old code
3. Update tests

---

## 7. Core Value Template Requirements

Based on the existing habit marketplace, core value templates should include:

### 7.1 Generic Fields (Same as Habits)

- Template ID
- Title (e.g., "Kebebasan Berekspresi")
- Description (e.g., "Nilai yang menekankan pentingnya otonomi dalam mengekspresikan diri...")
- Domain Tag (e.g., "Intrinsik", "Ekstrinsik", "Spiritual")
- Creator Pen Name
- Ratings (sum + count)
- Downloads Count
- Created At

### 7.2 Core Value Specific Metadata

```dart
class CoreValueMetadata {
  final String category;              // 'intrinsic', 'extrinsic', 'transcendence'
  final List<String> conflictsWith;   // Value conflicts (e.g., ['tradition', 'conformity'])
  final String culturalOrigin;        // 'universal', 'eastern', 'western', etc.
  final int schwartz_quadrant;        // 1-4 for Schwartz value model
  final List<String> reflectionPrompts; // Questions for self-reflection
  final List<String> behaviorIndicators; // How this value shows up in daily life
  final String iconEmoji;             // Visual representation
}
```

### 7.3 Example Core Value Template

```json
{
  "templateId": "cv-001",
  "templateType": "core_value",
  "title": "Kemandirian Berpikir",
  "description": "Kemampuan untuk membentuk opini dan membuat keputusan berdasarkan pemikiran kritis sendiri, bukan hanya mengikuti arus atau otoritas.",
  "domainTag": "Intrinsik",
  "creatorPenName": "PhilosophyMind",
  "ratingsSum": 85,
  "ratingsCount": 18,
  "downloadsCount": 234,
  "metadata": {
    "category": "intrinsic",
    "conflictsWith": ["conformity", "tradition"],
    "culturalOrigin": "western",
    "schwartz_quadrant": 1,
    "reflectionPrompts": [
      "Kapan terakhir saya mengambil keputusan yang berbeda dari mayoritas?",
      "Apa yang saya yakini tanpa bukti eksternal?",
      "Seberapa nyaman saya dengan ketidakpastian?"
    ],
    "behaviorIndicators": [
      "Menantang asumsi yang diterima begitu saja",
      "Mencari informasi dari berbagai sumber",
      "Berani berbeda pendapat dalam diskusi"
    ],
    "iconEmoji": "🧠"
  }
}
```

---

## 8. Key Files Summary

| File                               | Purpose           | Refactoring Priority                     |
| ---------------------------------- | ----------------- | ---------------------------------------- |
| `database.dart`                    | Schema definition | 🔴 HIGH - Foundation                     |
| `marketplace_service.dart`         | Business logic    | 🔴 HIGH - Core abstraction               |
| `marketplace_view.dart`            | Main UI           | 🟡 MEDIUM - Depends on service           |
| `marketplace_template_card.dart`   | Template display  | 🟡 MEDIUM - Make generic                 |
| `share_template_bottom_sheet.dart` | Upload UI         | 🟢 LOW - Create separate for core values |
| `router.dart`                      | Navigation        | 🟢 LOW - Add new routes                  |
| `main_navigation_shell.dart`       | Bottom nav        | 🟢 LOW - Keep as-is initially            |

---

## 9. Testing Considerations

### 9.1 Existing Test

**Location:** `app/test/marketplace_service_test.dart`

- Verify this test exists and covers current behavior
- Will need updates for generic implementation

### 9.2 New Tests Needed

1. **Generic template CRUD**
   - Upload habit template
   - Upload core value template
   - Fetch by type
   - Metadata serialization

2. **UI tests**
   - Habit card rendering
   - Core value card rendering
   - Type-specific filtering

3. **Migration tests**
   - Schema migration from v1 to v2
   - Data integrity after migration

---

## 10. Questions for Refinement

1. **Should core values have a "download/use" action?**
   - For habits: Creates a new Habit entry
   - For core values: What happens on download?
     - Add to user's personal value compass?
     - Add to reflection journal prompts?
     - Just bookmark/favorite?

2. **Domain tags for core values:**
   - Use Schwartz's value dimensions? (Self-Enhancement, Self-Transcendence, Conservation, Openness)
   - Use simpler categories? (Intrinsik, Ekstrinsik, Spiritual)
   - Allow custom tags?

3. **Should we support multi-type marketplace views?**
   - Option A: Separate tabs for habits vs core values
   - Option B: Unified view with type filter
   - Option C: Completely separate marketplace screens

4. **Rating system:**
   - Keep the same 5-star rating for both types?
   - Or add type-specific rating dimensions?

5. **Search and discovery:**
   - Should search work across both types or per-type?
   - Need different sort options for core values?

---

## 11. Next Steps

1. ✅ **Complete this analysis document**
2. ⏳ **Get stakeholder approval on:**
   - Generic schema design
   - Core value metadata structure
   - UI/UX approach for multi-type marketplace
3. ⏳ **Create detailed implementation tickets:**
   - Database migration script
   - Service layer refactoring
   - UI component updates
   - Test coverage
4. ⏳ **Prototype core value template card**
5. ⏳ **Begin Phase 1: Database migration**

---

**Analysis Complete** ✅  
This document provides a comprehensive foundation for refactoring the marketplace into a generic system supporting both habit and core value templates.
