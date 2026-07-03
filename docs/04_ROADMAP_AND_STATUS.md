# 04 — Roadmap and Status
## Daoji / LifeTree Delivery Status

> **Primary source of truth for progress, roadmap, backlog, and release readiness.**

---

## 1. Current Snapshot

### Repo state (high level)
The project is in an active transition from **LifeTree** toward a more cultivation-aware identity (**Daoji / LifeTree**).

### What is already true
- core app architecture exists
- offline-first local DB exists
- dashboard/habit/journal/reflection loops exist
- cultivation feature layer has already started implementation upstream
- tests exist across multiple features

### What is not yet complete
- full documentation consolidation
- source-of-truth cleanup
- cultivation language consistency across all screens
- final product-wide audit against Anti-Guilt rules

---

## 2. Implementation Status by Area

## 2.1 Foundation product
| Area | Status | Notes |
|---|---|---|
| Offline-first architecture | Strong | existing SQLite/Drift basis |
| Dashboard loop | Strong | core product exists |
| Habit/practice engine | Strong | add, schedule, log, friction |
| Reflection tools | Strong | journal, weekly pulse, thinking canvas |
| Safety / wellness base | Strong | safety card and low-mood pathways |

## 2.2 Cultivation integration
| Area | Status | Notes |
|---|---|---|
| Cultivation constants/layer/provider | In progress / strong start | already added upstream |
| Cultivation strings | In progress / strong start | 3-level language exists |
| Dashboard integration | Partial | present, needs consistency audit |
| Onboarding cultivation step | Partial | exists upstream |
| Marketplace cultivation framing | Partial | in transition |
| Full doc consolidation | Not complete | this docs restructure addresses it |

---

## 3. Phase Model

## Phase A — Core Product Foundation
### Goal
Establish a usable Anti-Guilt Personal OS.

### Includes
- onboarding
- dashboard
- habits
- friction intervention
- journaling
- weekly pulse
- safety card
- values and decision tools

### Status
Largely achieved.

---

## Phase B — Cultivation Language & Visual Layer
### Goal
Apply cultivation framing without changing core behavior.

### Includes
- Dao Tree naming
- Qi Log naming
- Breakthrough Hari Ini naming
- Seclusion naming
- Dao Heart terminology
- state badge consistency

### Status
Partially implemented; needs consolidation and QA.

---

## Phase C — Cultivation Interpretation Layer
### Goal
Make cultivation concepts structurally meaningful.

### Includes
- realm derivation
- state derivation
- palace framing
- path hints
- qi/capacity interpretation

### Status
In progress.
Core files exist but need audit and alignment.

---

## Phase D — Personalization & Depth
### Goal
Add optional richness without sacrificing usability.

### Includes
- vocabulary mode toggle
- path preference
- archetype/root hints
- cultivation skins
- advanced insights

### Status
Early / partial.

---

## Phase E — Community / Ecosystem Expansion
### Goal
Turn template/library features into a healthy exchange system.

### Includes
- marketplace hardening
- technique library framing
- optional community contributions
- safe social mechanics without competition

### Status
Early / evolving.

---

## 4. Immediate Priorities

## P0 — Documentation cleanup
- finalize new 5-doc structure
- treat these files as root source of truth
- archive or remove old overlapping docs after migration

## P1 — Cultivation consistency audit
- dashboard labels
- journal labels
- reflection labels
- profile/settings labels
- marketplace labels
- safety wording boundaries

## P2 — Technical verification
- run Flutter analyze/test on current repo state
- audit cultivation provider output
- validate no regressions in semantics/accessibility

## P3 — Preference control
- ensure cultivation mode / vocabulary mode is coherent
- ensure plain mode remains high quality

---

## 5. Active Backlog

### Product backlog
- unify all cultivation-facing strings
- standardize “plain / hybrid / full” usage rules
- reconcile LifeTree vs Daoji naming in repo and UI
- clarify marketplace product role

### UX backlog
- reduce mixed terminology across screens
- ensure no screen becomes overly roleplay-heavy by default
- audit dashboards for calm tech consistency

### Technical backlog
- complete integration tests where possible
- maintain/update widget tests after wording changes
- add more cultivation-layer tests if needed
- review DB schema for optional future preferences

### Documentation backlog
- archive legacy docs
- update README to point only to new docs
- mark deprecated docs as superseded if retained temporarily

---

## 6. Release Readiness Criteria

A cultivation-aware release should only be considered ready when:

### Product
- dashboard language is coherent
- no major screen breaks Anti-Guilt philosophy
- users can still understand app with zero xianxia background

### UX
- hybrid mode is smooth and not cringe-heavy
- plain mode remains complete and polished
- recovery remains clearly compassionate

### Technical
- `flutter analyze` passes
- `flutter test` passes
- no major routing or provider regressions
- semantics remain intact

### Documentation
- these 5 docs exist and are authoritative
- README points to them
- old doc sprawl is removed or archived

---

## 7. Recommended Roadmap Sequence

## Sprint 1 — Docs & naming stabilization
- adopt 5-file docs system
- unify product naming in docs
- decide public naming strategy: Daoji / LifeTree

## Sprint 2 — Dashboard-first cultivation polish
- Dao Tree card consistency
- Breakthrough Hari Ini consistency
- Six Palace wording consistency
- state/seclusion consistency

## Sprint 3 — Reflection suite consistency
- Qi Log
- Dao Heart / Value Mirror
- Meridian Check
- Forked Path Journal language review

## Sprint 4 — Technical verification & cleanup
- analyze/test
- remove dead wording
- fix edge-case copy mismatches
- improve preference handling

## Sprint 5 — Optional depth
- path hints
- root/archetype framing
- further marketplace flavor

---

## 8. Risks

### Risk 1 — Theme drift
Cultivation layer becomes inconsistent across screens.

### Risk 2 — Over-roleplay
Default UX becomes too niche for normal users.

### Risk 3 — Documentation divergence
Multiple docs continue acting like competing truths.

### Risk 4 — Product anxiety
Realm/level language accidentally creates pressure or shame.

### Risk 5 — Safety ambiguity
Wellness-critical flows become too wrapped in lore.

---

## 9. Mitigations

- maintain Hybrid as default
- keep safety language explicit
- keep recovery as state, not failure
- centralize strings
- centralize docs
- test semantics and flows after wording changes

---

## 10. Operational Status Format (Recommended)

Going forward, update this file using a compact status format:

### Example
- **Done:** dashboard cultivation badge integrated
- **In progress:** profile/settings vocabulary mode
- **Blocked:** Flutter toolchain not available in current environment
- **Next:** audit reflection tab terminology

This avoids spawning many micro-report files.

---

## 11. What to Archive from Old Docs

Once the new docs are accepted, the following kinds of files should move to `docs/archive/` or be removed after extraction:
- phase completion reports
- dated implementation reports
- one-off session notes
- old blueprint variants
- duplicate cultivation drafts

---

## 12. Final Delivery Principle

Roadmap success is not measured by how “epic” the cultivation theme sounds.
It is measured by whether the product becomes:
- clearer,
- calmer,
- more meaningful,
- and more coherent,
without losing the practical usefulness of the original LifeTree system.
