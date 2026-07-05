# 07 - UI and Code Language Audit

Date: 2026-07-05
Scope: audit language consistency in UI copy and code terminology residue.

## Executive Summary

Short answer: yes, there are still misses.

Main findings:
- UI copy still has high hardcoded footprint compared to registry-based copy.
- Level-language consistency cannot be guaranteed yet across all screens.
- Code terminology still mixes habit/discipline/practice/technique in a way that can confuse maintenance.
- Legacy vocabulary level names are still referenced in tests and defaults/comments, causing residue and mismatch.

## 1) Quantitative Audit Snapshot

Source scope:
- app/lib/src (excluding generated .g.dart and i18n registry for hardcoded metric)

Metrics:
- UI_HARDCODED_COUNT: 904
- DAOJI_RESOLVE_COUNT: 76

Interpretation:
- Registry adoption is still low relative to raw user-facing strings.
- Language-level behavior can still diverge per screen even if level mapping is correct in core i18n.

## 2) UI Audit - Missed or High-Risk Surfaces

Top files by hardcoded user-facing text count:
- 43: lib/src/features/thinking_canvas/widgets/workspaces/brainstorm_workspaces.dart
- 40: lib/src/features/marketplace/marketplace_view.dart
- 40: lib/src/features/habit/add_habit_view.dart
- 39: lib/src/features/thinking_canvas/widgets/workspaces/synthesis_workspaces.dart
- 32: lib/src/features/profile/profile_dashboard_tab.dart
- 31: lib/src/features/dashboard/widgets/skin_shop_bottom_sheet.dart
- 30: lib/src/features/journal/journal_lite_view.dart
- 30: lib/src/features/decision_journal/widgets/create_decision_sheet.dart

Risk notes:
- Many dialogs/snackbars/tooltips/form labels are still local text.
- These surfaces are exactly where mixed tone appears during daily use.
- Screenshot-validated issue (theme mismatch between adjacent widgets) can recur in these hardcoded areas.

## 3) Code Language Residue Audit

### 3.1 Legacy vocabulary level residue

Found in:
- lib/src/core/i18n/daoji_vocabulary_level.dart
- test/daoji_vocabulary_test.dart
- lib/src/data/local_db/database.dart
- lib/src/features/onboarding/widgets/cultivation_theme_step.dart (comment)

Details:
- Parser still maps legacy strings: practical, gentleCultivation, daoStream, immortalCultivation.
- This mapping is useful for backward compatibility, but test suite still references old enum constants that no longer exist.
- Result: conceptual confusion and test breakage risk.

### 3.2 Mixed conceptual entity terms in codebase

Counts in app/lib/src:
- habit: 352 matches
- discipline: 17 matches
- practice: 32 matches
- technique: 22 matches

Interpretation:
- Mixed naming is expected for user-facing vocabulary levels, but currently it also leaks into internal code structure and route semantics.
- Internal domain model should stay stable, while UI wording should vary by level.

### 3.3 Route and provider semantics

Examples:
- /add-habit and /edit-habit remain core routes.
- navigation/index/theme/onboarding providers use stable technical names.

Risk:
- Not a bug by itself, but if product language shifts heavily to practice/technique, mismatched route naming can confuse dev onboarding.

## 4) What Was Missed in Previous Audit

Missed previously:
- Full hardcoded text inventory by feature.
- Code-residue scan across tests/comments/default literals.
- Explicit distinction between UI-varying vocabulary and internal stable domain naming.

Now covered by this audit:
- UI volume snapshot.
- Hotspot files list.
- Legacy term residue list.
- Conceptual naming conflict map.

## 5) Recommended Fix Plan

P0 (immediate)
- Fix legacy test references in test/daoji_vocabulary_test.dart to current enum names.
- Create hardcoded text inventory issue list per feature.
- Migrate dialogs/snackbars/settings/form labels in top 8 hotspot files to DaojiText keys.

P1 (short-term)
- Define a strict policy:
  - Internal code terms: one canonical term set (recommend: habit for model/routes/db).
  - UI text terms: level-based via registry only.
- Add missing DaojiText keys for repeated hardcoded messages.

P2 (stabilization)
- Add lint/check script for user-facing hardcoded strings in feature folders.
- Add release checklist: language-level smoke test across 4 levels and key screens.

## 6) Decision Needed From Product/Owner

Please confirm:
- Canonical internal code term to keep (recommended: habit).
- Whether practice/discipline/technique should be strictly UI-only.
- Priority order of feature migration after dashboard/profile/navigation.

## 7) Acceptance Criteria For "No Missed Audit"

Audit is considered complete when:
- Hardcoded user-facing strings reduced significantly in P0 surfaces.
- No legacy enum constant usage in tests.
- All critical screens pass manual language-level review (mortal/human/earth/heaven).
- No conflicting terminology in neighboring widgets on the same screen.
