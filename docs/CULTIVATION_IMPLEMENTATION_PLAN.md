# Daoji Cultivation System — Implementation Plan & Task Tracker

> **Status:** Active Implementation  
> **Tanggal Mulai:** 2 Juli 2026  
> **Sumber Blueprint:** [CULTIVATION_SYSTEM_FINAL.md](CULTIVATION_SYSTEM_FINAL.md)  
> **Prinsip:** Layer kultivasi adalah interpretasi di atas data existing. Hindari migrasi database kecuali benar-benar diperlukan.

---

## 0. Ringkasan Status

| Fase | Nama | Status | Catatan |
|---|---|---:|---|
| Fase 0 | Foundation — Layer Interpretasi | ✅ Selesai | Core layer, provider, strings, widget foundation, dan test sudah dibuat. |
| Fase 1 | Narasi & Bahasa — 3-Level Language | ⬜ Belum mulai | Integrasi copy ke UI existing. |
| Fase 2 | Visual & UI — Kosmetik Cultivation | ⬜ Belum mulai | State visual, badge, progress, panel status. |
| Fase 3 | Depth — Achievement, Path, Heart Demon | ⬜ Belum mulai | Logic mendalam dan anti-guilt detection. |
| Fase 4 | Ekspansi — Advanced Cultivation | ⬜ Belum mulai | Journal mode, resonance, guide, social non-kompetitif. |

---

## 1. Aturan Kerja

Setiap task implementasi wajib mengikuti aturan berikut:

1. **Update dokumen relevan setelah task selesai.**
   - Minimal update file ini.
   - Jika task mengubah status produk, update [05_implementation_status.md](05_implementation_status.md).
   - Jika task mengubah blueprint/roadmap, update [CULTIVATION_SYSTEM_FINAL.md](CULTIVATION_SYSTEM_FINAL.md).
2. **Jalankan test relevan setelah perubahan.**
3. **Plain mode harus tetap aman dan jelas.**
4. **Tidak ada streak punishment, death state, leaderboard realm, atau judgment user.**
5. **Safety/legal copy selalu plain atau dual-label.**
6. **Database migration hanya boleh dibuat jika task eksplisit membutuhkan persistensi baru.**

---

## 2. Fase 0 — Foundation: Layer Interpretasi

**Status:** ✅ Selesai  
**Tujuan:** Membuat cultivation layer yang bisa membaca data existing tanpa migrasi database.

| ID | Task | Status | File Utama | Validasi |
|---|---|---:|---|---|
| 0.1 | Buat `CultivationLayer` class dengan 4 sumbu | ✅ Selesai | `app/lib/src/features/cultivation/cultivation_layer.dart` | `cultivation_layer_test.dart` |
| 0.2 | Kalkulasi realm multi-sinyal | ✅ Selesai | `cultivation_layer.dart` | Realm tests |
| 0.3 | 5 state trigger logic | ✅ Selesai | `cultivation_layer.dart` | Season tests |
| 0.4 | `CultivationStrings` 3-level language resolver | ✅ Selesai | `cultivation_strings.dart` | String coverage awal |
| 0.5 | Provider integration | ✅ Selesai | `cultivation_provider.dart` | Provider tests |
| 0.6 | Unit test + no regression | ✅ Selesai | `app/test/cultivation_layer_test.dart` | `flutter test` → 65 passed |
| 0.7 | Widget foundation | ✅ Selesai | `widgets/` | Analyze + compile |

### Catatan Fase 0

- Tidak ada migrasi database.
- `cultivationProvider` menginterpretasikan `dashboardDataProvider`.
- `CultivationLanguageLevel.hybrid` menjadi default.

---

## 3. Fase 1 — Narasi & Bahasa: 3-Level Language

**Status:** ⬜ Belum mulai  
**Tujuan:** Menghubungkan `CultivationStrings` ke UI existing agar narasi app dapat berpindah antara Plain, Hybrid, dan Full Cultivation.

### 3.1 Task Breakdown

| ID | Task | Status | File Target | Dokumen yang Diupdate | Test/Validasi |
|---|---|---:|---|---|---|
| 1.1 | Audit semua hardcoded UI copy yang terkait tree/domain/habit/journal/reflection | ⬜ Todo | `app/lib/src/features/**` | File ini | Search report |
| 1.2 | Tambah 3-Level Language picker di settings | ⬜ Todo | `dashboard/widgets/settings_bottom_sheet.dart`, `cultivation_provider.dart` | File ini, `05_implementation_status.md` | Widget/settings test |
| 1.3 | Integrasi copy Dashboard: Dao Tree, realm, qi, state | ⬜ Todo | `dashboard_view.dart`, `tree_display_widget.dart`, `season_badge_widget.dart` | File ini | Dashboard/widget test |
| 1.4 | Integrasi `Action of the Day` → `Breakthrough Hari Ini` | ⬜ Todo | `action_of_the_day_card.dart` | File ini | Dashboard provider/widget test |
| 1.5 | Integrasi Habit list → Practice language | ⬜ Todo | `habit_list_section.dart`, `add_habit_view.dart` | File ini | Habit widget test |
| 1.6 | Integrasi Growth Map labels + semantics | ⬜ Todo | `growth_map_widget.dart`, `growth_map_semantics.dart`, `growth_map_node.dart` | File ini | Accessibility test |
| 1.7 | Integrasi Friction Intervention → Bottleneck/Heart Demon copy | ⬜ Todo | `friction_intervention_sheet.dart` | File ini | Friction flow test |
| 1.8 | Integrasi Journal + Thinking Canvas language | ⬜ Todo | `journal_lite_view.dart`, `journal_dashboard_tab.dart`, `thinking_canvas_lite_view.dart` | File ini | Journal tests |
| 1.9 | Integrasi Reflection/Profile: Dao Heart, Meridian Check, Forked Path | ⬜ Todo | `reflection_dashboard_tab.dart`, `profile_dashboard_tab.dart`, `life_compass_section.dart` | File ini | Profile/reflection tests |
| 1.10 | Pastikan Safety Card tetap plain/dual-label | ⬜ Todo | `safety_card_view.dart` | File ini | Safety test |
| 1.11 | Test 3 language level consistency | ⬜ Todo | `app/test/cultivation_strings_test.dart` | File ini | New test |
| 1.12 | Update status docs Fase 1 | ⬜ Todo | Docs | File ini, `05_implementation_status.md` | Doc review |

### 3.2 Kriteria Selesai Fase 1

- Semua label utama yang masuk scope menggunakan `CultivationStrings` atau wrapper setara.
- Plain mode tidak menampilkan istilah cultivation berat.
- Hybrid menjadi default.
- Safety/legal copy tetap jelas.
- Test lama tetap lulus.

---

## 4. Fase 2 — Visual & UI: Kosmetik Cultivation

**Status:** ⬜ Belum mulai  
**Tujuan:** Mengubah tampilan cultivation dari sekadar teks menjadi pengalaman visual yang tenang, jelas, dan accessible.

### 4.1 Task Breakdown

| ID | Task | Status | File Target | Dokumen yang Diupdate | Test/Validasi |
|---|---|---:|---|---|---|
| 2.1 | Pasang `CultivationBadge` di Dashboard | ⬜ Todo | `dashboard_view.dart` | File ini | Widget test |
| 2.2 | Pasang `CultivationProgressBar` tanpa rank agresif | ⬜ Todo | `dashboard_view.dart` atau `tree_display_widget.dart` | File ini | Widget test |
| 2.3 | Pasang `CultivationStatusPanel` sebagai panel ringkasan opsional | ⬜ Todo | `dashboard_view.dart` / settings/dev area | File ini | UI smoke test |
| 2.4 | Implement state-based visual modifiers untuk Dao Tree | ⬜ Todo | `tree_display_widget.dart`, `growth_map_painter.dart` | File ini, `CULTIVATION_SYSTEM_FINAL.md` jika ada perubahan visual | Visual/accessibility test |
| 2.5 | Growth state: normal/kanopi penuh | ⬜ Todo | `tree_display_widget.dart` | File ini | Manual visual check |
| 2.6 | Recovery state: snow/soft visual, no death language | ⬜ Todo | `tree_display_widget.dart` | File ini | Recovery test |
| 2.7 | Dormant state: redup/tenang, bukan mati | ⬜ Todo | `tree_display_widget.dart` | File ini | Dormant test |
| 2.8 | Tribulation state: aura biru/getaran halus | ⬜ Todo | `tree_display_widget.dart` | File ini | Motion accessibility check |
| 2.9 | Quiet Integration state: night/stars visual | ⬜ Todo | `tree_display_widget.dart` | File ini | Manual visual check |
| 2.10 | Palace aura di Growth Map | ⬜ Todo | `growth_map_painter.dart`, `growth_map_widget.dart` | File ini | Visual/accessibility test |
| 2.11 | Tambah skin cultivation: Bamboo Immortal | ⬜ Todo | `tree_skin_config.dart`, assets jika perlu | File ini, `05_implementation_status.md` | Skin test |
| 2.12 | Tambah skin cultivation: Peach Blossom | ⬜ Todo | `tree_skin_config.dart`, assets jika perlu | File ini | Skin test |
| 2.13 | Tambah skin cultivation: Ancient Pine | ⬜ Todo | `tree_skin_config.dart`, assets jika perlu | File ini | Skin test |
| 2.14 | Pastikan visual tidak bergantung warna saja | ⬜ Todo | Painter/widgets | File ini | Accessibility test |
| 2.15 | Update status docs Fase 2 | ⬜ Todo | Docs | File ini, `05_implementation_status.md` | Doc review |

### 4.2 Kriteria Selesai Fase 2

- 5 state punya representasi visual non-punitive.
- Realm indicator informatif, bukan kompetitif.
- Palace visual tetap accessible.
- Tidak ada istilah mati/gagal/hancur untuk kondisi user.

---

## 5. Fase 3 — Depth: Achievement, Path, Heart Demon

**Status:** ⬜ Belum mulai  
**Tujuan:** Menambahkan kedalaman sistem tanpa membuat user merasa dihukum atau dinilai.

### 5.1 Task Breakdown

| ID | Task | Status | File Target | Dokumen yang Diupdate | Test/Validasi |
|---|---|---:|---|---|---|
| 3.1 | Implement achievement detection service | ⬜ Todo | `cultivation_achievement.dart`, service baru | File ini | Achievement tests |
| 3.2 | Realm Breakthrough milestone | ⬜ Todo | Achievement service, dialog | File ini | Test no spam |
| 3.3 | Qi Milestone 100 practice | ⬜ Todo | Achievement service | File ini | Test trigger |
| 3.4 | Tribulation Survivor | ⬜ Todo | Achievement service | File ini | Recovery test |
| 3.5 | Dao Comprehension 1 tahun | ⬜ Todo | Achievement service | File ini | Date test |
| 3.6 | Legacy Builder marketplace trigger | ⬜ Todo | Marketplace service / achievement service | File ini | Marketplace test |
| 3.7 | 6 Paths detection algorithm | ⬜ Todo | `cultivation_layer.dart` atau service baru | File ini, `CULTIVATION_SYSTEM_FINAL.md` jika scoring berubah | Path tests |
| 3.8 | Path profile UI | ⬜ Todo | `profile_dashboard_tab.dart`, widget baru | File ini | Widget test |
| 3.9 | Heart Demon detection service | ⬜ Todo | service baru | File ini | Pattern tests |
| 3.10 | Perfection Demon pattern | ⬜ Todo | Heart Demon service | File ini | Test |
| 3.11 | Impatience Demon pattern | ⬜ Todo | Heart Demon service | File ini | Test |
| 3.12 | Attachment Demon pattern | ⬜ Todo | Heart Demon service | File ini | Test |
| 3.13 | Heart Demon Severing flow | ⬜ Todo | Journal/reflection/habit archive UI | File ini | Flow test |
| 3.14 | Demonic Cultivation warning sebagai pola, bukan label user | ⬜ Todo | Warning widget/service | File ini | Anti-guilt test |
| 3.15 | Test: tidak ada streak requirement | ⬜ Todo | Test suite | File ini | Anti-guilt test |
| 3.16 | Update status docs Fase 3 | ⬜ Todo | Docs | File ini, `05_implementation_status.md` | Doc review |

### 5.2 Kriteria Selesai Fase 3

- Achievement tidak menjadi streak punishment.
- Heart Demon selalu dipresentasikan sebagai pola, bukan identitas user.
- Demonic Cultivation tidak judgmental.
- Path bersifat personalisasi, bukan kasta/ranking.

---

## 6. Fase 4 — Ekspansi: Advanced Cultivation

**Status:** ⬜ Belum mulai  
**Tujuan:** Menambah fitur lanjutan setelah foundation, language, visual, dan depth stabil.

### 6.1 Task Breakdown

| ID | Task | Status | File Target | Dokumen yang Diupdate | Test/Validasi |
|---|---|---:|---|---|---|
| 4.1 | Cultivation Journal Mode | ⬜ Todo | `journal_lite_view.dart`, widget/service baru | File ini, `05_implementation_status.md` | Journal test |
| 4.2 | Palace Resonance Visualization refinement | ⬜ Todo | `radar_chart_widget.dart`, `domain_scores_card.dart` | File ini | Visual test |
| 4.3 | Mind Demon Diary | ⬜ Todo | Journal/reflection feature | File ini, blueprint jika scope berubah | Privacy/safety review |
| 4.4 | Dao Alignment Score — reflective, not judgmental | ⬜ Todo | Service/widget baru | File ini | Anti-guilt test |
| 4.5 | Sekte/Social Mode tanpa kompetisi | ⬜ Todo | Marketplace/social area | File ini, blueprint | Product review |
| 4.6 | User Guide — Cultivation Mode | ⬜ Todo | Docs/app guide | File ini, user guide doc baru | Doc review |
| 4.7 | Update status docs Fase 4 | ⬜ Todo | Docs | File ini, `05_implementation_status.md` | Doc review |

### 6.2 Kriteria Selesai Fase 4

- Semua ekspansi tetap offline-first atau jelas batas sinkronisasinya.
- Social mode tidak menjadi leaderboard.
- Dao Alignment Score tidak menjadi skor rasa bersalah.

---

## 7. Test Matrix Wajib

| Area | Test | Status |
|---|---|---:|
| CultivationLayer from existing data | Semua 4 sumbu bisa dihitung tanpa data baru | ✅ Ada |
| No DB migration needed | Fase 0 tidak mengubah schema | ✅ Ada |
| 3-Level Language consistency | Semua komponen punya string di 3 level | ⬜ Belum lengkap |
| Screen reader compatibility | Semantic label tidak hilang | ⬜ Belum lengkap |
| Anti-Guilt compliance | Tidak ada punishment/judgment | ⬜ Belum lengkap |
| State transition logic | State sesuai trigger | ✅ Ada awal |
| Multi-sinyal realm calculation | Realm bukan hanya hari | ✅ Ada awal |
| Visual accessibility | Visual tidak bergantung warna saja | ⬜ Belum lengkap |
| Performance impact | Animasi tidak jank | ⬜ Manual/perf test |

---

## 8. Log Implementasi

### 2026-07-02 — Fase 0 selesai

- Menambahkan folder `app/lib/src/features/cultivation/`.
- Menambahkan cultivation constants, layer, strings, provider, achievements, dan widget foundation.
- Menambahkan `app/test/cultivation_layer_test.dart`.
- Validasi: `flutter test` → 65 tests passed.

---

## 9. Next Immediate Task

**Mulai Fase 1.1 — audit UI copy cultivation-related.**

Target awal:

1. Cari hardcoded copy terkait tree, habit, domain, journal, reflection, compass, recovery.
2. Kelompokkan copy menjadi Plain/Hybrid/Full.
3. Tentukan file mana yang paling aman diubah dulu.
4. Update dokumen ini setelah audit selesai.
