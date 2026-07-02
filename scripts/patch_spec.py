"""Patch the VITALITY_RADAR_SPECIFICATION.md implementation plan section."""
import pathlib

spec = pathlib.Path("docs/VITALITY_RADAR_SPECIFICATION.md")
content = spec.read_text(encoding="utf-8")

# Locate the section by line numbers (lines 583-624 based on inspection)
lines = content.split("\n")

# Find start and end indices
start = next(i for i, l in enumerate(lines) if l.strip() == "### Phase 1: MVP")
end = next(i for i, l in enumerate(lines) if "system can surface" in l and "recommended next action" in l)

new_section = [
    "### Phase 1: MVP",
    "",
    "**New files to create:**",
    "",
    "| File | Purpose |",
    "|------|---------|",
    "| `app/lib/src/features/dashboard/services/vitality_radar_service.dart` | Detection logic |",
    "| `app/lib/src/features/dashboard/providers/vitality_radar_provider.dart` | Riverpod provider |",
    "| `app/lib/src/features/dashboard/widgets/radar_signal_sheet.dart` | Bottom sheet UI |",
    "",
    "**Files to modify:**",
    "",
    "| File | Change |",
    "|------|--------|",
    "| `app/lib/src/features/dashboard/widgets/radar_chart_widget.dart` | Add `radarState` param, badge, tap handler |",
    "| `app/lib/src/features/dashboard/dashboard_view.dart` | Watch `vitalityRadarProvider`, pass state |",
    "",
    "**Detection rules in MVP:**",
    "1. Low Domain Detection",
    "2. Balance Anomaly Detection",
    "",
    "**Success criteria:**",
    "- dashboard shows signal count badge on Vitality Radar card",
    "- tapping badge opens `RadarSignalSheet`",
    "- signals update when domain scores change",
    "- `flutter analyze` passes cleanly",
    "",
    "---",
    "",
    "### Phase 2: Strengthen Analytics",
    "",
    "**Additional detection rules:**",
    "3. Burnout Early Warning (canopy load ratio)",
    "4. Growth Opportunity Detection (stable domain + no recent habit)",
    "",
    "**Additional improvements:**",
    "- use `JournalEntry.moodScore` trend for mood-aware signals",
    "- add habit coverage check (domains with no active habit)",
    "- rate-limit growth signals (max 1 per domain per 7 days)",
    "",
    "---",
    "",
    "### Phase 3: Personalization",
    "",
    "**Future additions:**",
    "- user feedback on signals (helpful / not helpful)",
    "- adaptive thresholds based on user history",
    "- signal history table in Drift database",
    '- "recommended next action" surfaced on dashboard home',
]

updated_lines = lines[:start] + new_section + lines[end + 1:]
spec.write_text("\n".join(updated_lines), encoding="utf-8")
print(f"SUCCESS: replaced lines {start}–{end}")
