"""Finalize VITALITY_RADAR_SPECIFICATION.md accuracy fixes."""

import pathlib

spec = pathlib.Path("docs/VITALITY_RADAR_SPECIFICATION.md")
content = spec.read_text(encoding="utf-8")

# Fix domain names in Example section
content = content.replace(
    "A badge or summary line indicates `Low Body · Growth Opportunity in Career`.",
    "A badge or summary line indicates `Low Tubuh · Growth opportunity in Karir`.",
)
content = content.replace(
    "   - `Low Body score` → `Try adding a gentle self-care habit`",
    "   - `Low Tubuh score` → `Try adding a gentle self-care habit`",
)
content = content.replace(
    "   - `Growth Opportunity in Career` → `Consider a new learning habit`",
    "   - `Growth opportunity in Karir` → `Consider a new learning habit`",
)

# Move Testing Strategy out of Technical Considerations
old_testing = (
    "### Testing Strategy\n\n"
    "Unit tests:\n"
    "- verify each detection rule with synthetic domain score sets\n"
    "- confirm severity assignment for edge cases\n"
    "- ensure signal descriptions and recommendations are correct\n\n"
    "Widget tests:\n"
    "- verify `RadarChartWidget` renders the header and badge\n"
    "- tap the card and open the signal bottom sheet\n"
    "- verify signal list content appears correctly\n\n"
    "Integration tests:\n"
    "- simulate score updates and confirm new signals appear\n"
    "- verify recovery mode or season state changes affect signal generation"
)
new_testing_placeholder = (
    "### Testing Strategy\n\nSee dedicated **Testing Strategy** section below."
)
content = content.replace(old_testing, new_testing_placeholder)

# Add proper Testing Strategy section before Open Questions
old_open = "## Open Questions"
new_testing_section = (
    "## Testing Strategy\n\n"
    "### Unit Tests\n\n"
    "File: `app/test/vitality_radar_service_test.dart`\n\n"
    "| Test case | Expected result |\n"
    "|-----------|----------------|\n"
    "| score = 3.5 for Tubuh | returns `lowDomain` signal, severity `medium` |\n"
    "| score = 2.5 for Emosi | returns `lowDomain` signal, severity `high` |\n"
    "| max-min gap = 5.5 | returns `imbalance` signal |\n"
    "| load ratio = 0.9, season = Growth | returns `burnoutWarning`, severity `high` |\n"
    "| load ratio = 0.9, season = Recovery | no `burnoutWarning` signal |\n"
    "| stable score 7.5, no habit in 30d | returns `growthOpportunity` |\n"
    "| stable score 7.5, season = Dormant | no `growthOpportunity` signal |\n"
    "| all scores 5.0, load ratio 0.5 | returns empty signal list |\n\n"
    "### Widget Tests\n\n"
    "File: `app/test/radar_chart_widget_test.dart`\n\n"
    "- badge renders with correct count when signals are present\n"
    "- badge is hidden when signal list is empty\n"
    "- tapping badge opens `RadarSignalSheet`\n"
    "- `RadarSignalSheet` displays signal titles and recommendations\n\n"
    "### Integration Tests\n\n"
    "- simulate domain score update → confirm new signals appear\n"
    "- switch season to Recovery → confirm burnout signal disappears\n"
    "- switch season to Dormant → confirm growth signal disappears\n\n"
    "## Open Questions"
)
content = content.replace(old_open, new_testing_section)

spec.write_text(content, encoding="utf-8")
print("SUCCESS")
