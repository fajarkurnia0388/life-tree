# Privacy & data handling (Daoji)

Short threat model for the Flutter mobile app and marketing PWA landing.
**No SQLCipher / biometric app lock is implemented in this plan revision** unless product re-approves cost.

## Assets & trust boundaries

| Surface | Data | Trust |
|---------|------|--------|
| Flutter app (local SQLite via Drift) | Habits, journals, mood, WHO-5, decisions, value mirror answers, reminders | Device storage only; not synced to Daoji servers |
| Android Auto Backup | Disabled (`android:allowBackup="false"`) | Cloud backup of app data is intentionally off |
| Android device transfer / cloud extract | Excluded for DB + files via `data_extraction_rules.xml` | Same privacy stance on OS-level transfer |
| Marketing PWA (`index.html` / GitHub Pages) | No user journals; interactive prototype state is browser-local only | Public static site; not the Flutter app |
| Residual `isPremium` fields | Legacy metadata only | **No paywall / IAP / entitlement** ([AGENTS.md](../.agents/AGENTS.md)) |

## Threats considered

1. **Device loss / shared device** — DB is plaintext SQLite on disk. Mitigation today: OS screen lock; future option SQLCipher + Keystore.
2. **Cloud backup leakage** — Mitigated by `allowBackup=false` and exclude rules for databases/files.
3. **Export / share of personal content** — Any future JSON export must warn that content is **plaintext** and user-controlled destination.
4. **PWA cache** — Service worker caches marketing shell only; bump `CACHE_NAME` on release so HTML updates are network-first.

## Non-goals (current)

- Multi-user cloud auth
- Encrypted-at-rest DB (optional backlog)
- Flutter web port of the full app

## Policy summary for implementers

- Prefer **local-first** and **honest** product copy (landing = preview/marketing, not store install of a web app).
- Do not re-enable Android backup without revisiting journal/wellness sensitivity.
- Do not gate features on `isPremium`.
