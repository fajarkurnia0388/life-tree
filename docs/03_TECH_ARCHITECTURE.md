# 03 — Technical Architecture
## Daoji / LifeTree App Architecture

> **Primary source of truth for technical structure, data layer, runtime assumptions, and testing strategy.**

---

## 1. Stack Overview

### App stack
- **Flutter**
- **Dart**
- **Riverpod** for state management
- **GoRouter** for navigation
- **Drift + SQLite** for local database
- **Material 3** UI foundation

### Product architecture philosophy
- offline-first
- local-first data
- calm tech UI
- interpretive cultivation layer over existing data structures

---

## 2. Repository Structure (High Level)

```text
app/
  lib/
    src/
      core/
      data/
      features/
```

### Major areas
- `core/` → routing, shared services, theme, constants
- `data/` → local DB and persistence
- `features/` → dashboard, journal, reflection, cultivation, onboarding, marketplace, profile, etc.

### Cultivation layer location
Current cultivation implementation lives under:
```text
app/lib/src/features/cultivation/
```

This is the correct direction.
Cultivation is treated as a **feature-layer interpretation system**, not a separate app.

---

## 3. Data Architecture

## 3.1 Principle
Cultivation is primarily an **interpretive layer** built on top of existing tables.
Phase 1 should avoid unnecessary schema migrations.

## 3.2 Core tables in current system
- `UserProfiles`
- `LifeAudits`
- `WeeklyPulses`
- `Habits`
- `HabitLogs`
- `JournalEntries`
- `ThinkingCanvasSessions`
- `ConsentLogs`
- `ReminderPreferences`
- `WellnessPromptLogs`
- `DecisionEntries`
- `MarketplaceTemplates`
- `ValueDilemmaResponses`

## 3.3 Conceptual mapping
| Data table | Cultivation meaning |
|---|---|
| `UserProfiles` | cultivator identity, preferences, dao heart seed |
| `Habits` | practices / techniques |
| `HabitLogs` | practice records |
| `LifeAudits` | palace resonance baseline |
| `WeeklyPulses` | meridian check history |
| `JournalEntries` | qi logs |
| `ThinkingCanvasSessions` | insight / comprehension sessions |
| `DecisionEntries` | forked path records |
| `ValueDilemmaResponses` | dao heart mirror evidence |
| `MarketplaceTemplates` | technique library / sutra pavilion |

---

## 4. Routing Architecture

Current routing uses `GoRouter`.
Important route groups include:
- onboarding
- dashboard/main shell
- journal
- thinking canvas
- safety
- add habit
- marketplace
- weekly pulse
- decision journal
- value mirror/session

### Architecture recommendation
Cultivation should not introduce a separate app shell.
It should:
- reuse the same routing;
- alter labels, strings, and interpretation;
- optionally add cultivation-specific widgets inside existing screens.

---

## 5. State Management

Riverpod is used across app features.

### Current pattern
- providers for dashboard state
- providers for DB access
- feature-specific providers where needed

### Cultivation pattern (recommended)
Cultivation should stay as:
1. **derived state provider**
2. **string resolver layer**
3. **visual helper layer**

### Good example already present
- `cultivation_layer.dart`
- `cultivation_provider.dart`
- `cultivation_strings.dart`

This is the right architectural direction because:
- low coupling
- low migration cost
- easy rollback if needed
- easy A/B of language systems

---

## 6. Cultivation Interpretation Layer

## 6.1 Goal
Convert existing user data into a cultivation-aware reading of:
- realm
- state
- palace health
- path hints
- qi capacity usage

## 6.2 Inputs
Main inputs should come from existing sources such as:
- `DashboardData`
- `UserProfile`
- domain scores
- habit completion patterns
- reflection usage
- support mode / recovery state

## 6.3 Outputs
The interpretation layer should derive:
- current `Realm`
- current `State/Season`
- `Palace` balance map
- current `Qi level` / capacity usage
- optional `Path` hint
- optional `Heart Demon` insight

## 6.4 Important rule
This layer should remain **descriptive, not judgmental**.
It must never be used to punish the user.

---

## 7. Vocabulary Mode System

## 7.1 Required levels
- plain
- hybrid
- full cultivation

## 7.2 Technical requirement
All user-facing cultivation-sensitive strings should resolve through a centralized string layer.

### Recommended pattern
A single resolver like:
- `CultivationStrings`

This ensures:
- consistency
- easier translation later
- easier experimentation
- lower copy drift across screens

## 7.3 Rule
Do not hardcode cultivation-heavy text inside individual widgets unless it is intentionally static and local.

---

## 8. Dashboard Architecture

Dashboard remains the primary orchestrator.

### It should integrate:
- `DashboardDataProvider`
- cultivation interpretation provider
- language resolver
- tree/growth map visual layer
- state badge
- practice list

### Recommended separation
- business logic: provider
- cultivation interpretation: derived provider
- strings: string resolver
- visual representation: widgets

---

## 9. Growth Map / Dao Tree Architecture

## 9.1 Principle
Growth Map should remain anti-regression.
No visual death states.

## 9.2 Required signals
- cumulative progress
- current state
- selected/active domain
- palace resonance
- recovery state
- optional cultivation flavor

## 9.3 Accessibility requirement
Every visual node/state must produce semantic labels.
Do not rely on color only.

---

## 10. Security & Privacy

## 10.1 Current principle
- local-first
- no mandatory server account
- offline-friendly

## 10.2 Current/future notes
- SQLCipher/encryption may be roadmap work
- exports must remain user-controlled
- cloud sync, if added, should be carefully separated from core offline experience

## 10.3 Product law
Privacy is part of trust architecture, not a premium gimmick.

---

## 11. Error Handling & Empty States

The repo already contains improved loading/error/empty handling.
This should remain consistent with cultivation language strategy.

### Rule
Error and critical-state messaging should stay closer to plain/hybrid language.
Do not make failures sound mystical when the user needs clarity.

---

## 12. Testing Strategy

## 12.1 Required categories
1. unit tests
2. widget tests
3. DB/service tests
4. cultivation interpretation tests
5. accessibility/semantics tests

## 12.2 Cultivation-specific tests
- realm derivation does not regress to shame logic
- state derivation handles recovery/dormant correctly
- vocabulary resolver returns correct strings by mode
- growth map labels remain accessible
- palace mapping stays consistent

## 12.3 Existing evidence
Repo already includes:
- cultivation tests
- dashboard tests
- onboarding tests
- marketplace tests
- growth map tests
- profile and safety tests

This is good and should be preserved.

---

## 13. Running Flutter in Constrained Environments

Based on the Flutter testing bridge plan, realistic support in limited environments is:

### Usually possible with portable Flutter SDK
- `flutter --version`
- `dart --version`
- `flutter pub get`
- `flutter analyze`
- `flutter test`

### Usually not reliable in constrained environments
- emulator/device runs
- Android/iOS builds
- integration tests needing real platform services
- desktop/web builds without toolchain/browser

### Recommendation
For agent/sandbox workflows:
1. bootstrap portable Flutter SDK
2. run `flutter analyze`
3. run `flutter test`
4. rely on local/CI for native builds and integration testing

---

## 14. CI Recommendation

A minimal CI lane should always validate:
- dependency resolution
- static analysis
- test suite

### Minimum recommended flow
- checkout
- install Flutter stable
- `flutter pub get`
- `flutter analyze`
- `flutter test`

This must remain independent of cultivation theming.

---

## 15. Migration Strategy

## 15.1 Phase 1
No schema migration required.
Use interpretation + string + visual layers only.

## 15.2 Phase 2 (optional)
Add user preferences such as:
- cultivation theme enabled
- vocabulary mode
- path preference
- root/archetype

## 15.3 Rule
Do not add schema complexity until the UX proves useful.

---

## 16. Performance & Complexity Boundaries

1. cultivation layer must remain light
2. interpretation must not require expensive DB scans every frame
3. heavy calculations should be cached or derived once per relevant refresh
4. visuals should remain calm and not GPU-heavy

---

## 17. Technical Priorities Going Forward

### High priority
- unify string usage
- audit cultivation provider outputs
- ensure dashboard integration consistency
- ensure settings/profile control vocabulary mode cleanly

### Medium priority
- path hints
- palace-specific visuals
- advanced derived insights

### Lower priority
- deeper lore objects
- cosmetic-only complexity with little user value

---

## 18. Final Architecture Principle

**Cultivation is not a parallel technical system. It is a disciplined interpretation layer over an existing personal operating system.**

That means:
- data stays mostly the same,
- flows stay mostly the same,
- but meaning, language, and motivation become richer and more coherent.
