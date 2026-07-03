# Daoji Cultivation System — Implementation Plan & Task Tracker

> **Status:** Active Implementation  
> **Tanggal Mulai:** 2 Juli 2026  
> **Sumber Blueprint:** [CULTIVATION_SYSTEM_FINAL.md](CULTIVATION_SYSTEM_FINAL.md)  
> **Prinsip:** Layer kultivasi adalah interpretasi di atas data existing. Hindari migrasi database kecuali benar-benar diperlukan.

---

## 0. Ringkasan Status

| Fase    | Nama                                   |         Status | Catatan                                                                          |
| ------- | -------------------------------------- | -------------: | -------------------------------------------------------------------------------- |
| Fase 0  | Foundation — Layer Interpretasi        |     ✅ Selesai | Core layer, provider, strings, widget foundation, dan test sudah dibuat.         |
| Fase 1  | Narasi & Bahasa — 3-Level Language     |     ✅ Selesai | Language resolver aktif; plain/hybrid/full copy terhubung ke UI utama.           |
| Fase 2  | Visual & UI — Kosmetik Cultivation     |     ✅ Selesai | Badge, progress, panel status, visual states, palace aura, skins.                |
| UX Pref | Onboarding & Settings Theme Choice     |     ✅ Selesai | User bisa memilih bahasa sederhana atau tema kultivasi saat onboarding/settings. |
| Fase 3  | Depth — Achievement, Path, Heart Demon | ⬜ Belum mulai | Logic mendalam dan anti-guilt detection.                                         |
| Fase 4  | Ekspansi — Advanced Cultivation        | ⬜ Belum mulai | Journal mode, resonance, guide, social non-kompetitif.                           |

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

| ID  | Task                                           |     Status | File Utama                                                | Validasi                      |
| --- | ---------------------------------------------- | ---------: | --------------------------------------------------------- | ----------------------------- |
| 0.1 | Buat `CultivationLayer` class dengan 4 sumbu   | ✅ Selesai | `app/lib/src/features/cultivation/cultivation_layer.dart` | `cultivation_layer_test.dart` |
| 0.2 | Kalkulasi realm multi-sinyal                   | ✅ Selesai | `cultivation_layer.dart`                                  | Realm tests                   |
| 0.3 | 5 state trigger logic                          | ✅ Selesai | `cultivation_layer.dart`                                  | Season tests                  |
| 0.4 | `CultivationStrings` 3-level language resolver | ✅ Selesai | `cultivation_strings.dart`                                | String coverage awal          |
| 0.5 | Provider integration                           | ✅ Selesai | `cultivation_provider.dart`                               | Provider tests                |
| 0.6 | Unit test + no regression                      | ✅ Selesai | `app/test/cultivation_layer_test.dart`                    | `flutter test` → 65 passed    |
| 0.7 | Widget foundation                              | ✅ Selesai | `widgets/`                                                | Analyze + compile             |

### Catatan Fase 0

- Tidak ada migrasi database.
- `cultivationProvider` menginterpretasikan `dashboardDataProvider`.
- `CultivationLanguageLevel.hybrid` menjadi default.

---

## 3. Fase 1 — Narasi & Bahasa: 3-Level Language

**Status:** 🟡 Berjalan  
**Tujuan:** Menghubungkan `CultivationStrings` ke UI existing agar narasi app dapat berpindah antara Plain, Hybrid, dan Full Cultivation.

### 3.1 Task Breakdown

| ID   | Task                                                                            |     Status | File Target                                                                                | Dokumen yang Diupdate                   | Test/Validasi                  |
| ---- | ------------------------------------------------------------------------------- | ---------: | ------------------------------------------------------------------------------------------ | --------------------------------------- | ------------------------------ |
| 1.1  | Audit semua hardcoded UI copy yang terkait tree/domain/habit/journal/reflection | ✅ Selesai | `app/lib/src/features/**`                                                                  | File ini                                | Search report                  |
| 1.2  | Tambah 3-Level Language picker di settings                                      | ✅ Selesai | `dashboard/widgets/settings_bottom_sheet.dart`, `cultivation_provider.dart`                | File ini, `05_implementation_status.md` | `flutter test` → 65 passed     |
| 1.3  | Integrasi copy Dashboard: Dao Tree, realm, qi, state                            | ✅ Selesai | `dashboard_view.dart`, `tree_display_widget.dart`, `season_badge_widget.dart`              | File ini                                | Dashboard/widget test          |
| 1.4  | Integrasi `Action of the Day` → `Breakthrough Hari Ini`                         | ✅ Selesai | `action_of_the_day_card.dart`                                                              | File ini                                | Dashboard provider/widget test |
| 1.5  | Integrasi Habit list → Practice language                                        | ✅ Selesai | `habit_list_section.dart`, `add_habit_view.dart`                                           | File ini                                | Habit widget test              |
| 1.6  | Integrasi Growth Map labels + semantics                                         | ✅ Selesai | `growth_map_widget.dart`, `growth_map_semantics.dart`, `growth_map_node.dart`              | File ini                                | Accessibility test             |
| 1.7  | Integrasi Friction Intervention → Bottleneck/Heart Demon copy                   | ✅ Selesai | `friction_intervention_sheet.dart`                                                         | File ini                                | Friction flow test             |
| 1.8  | Integrasi Journal + Thinking Canvas language                                    | ✅ Selesai | `journal_lite_view.dart`, `journal_dashboard_tab.dart`, `thinking_canvas_lite_view.dart`   | File ini                                | Journal tests                  |
| 1.9  | Integrasi Reflection/Profile: Dao Heart, Meridian Check, Forked Path            | ✅ Selesai | `reflection_dashboard_tab.dart`, `profile_dashboard_tab.dart`, `life_compass_section.dart` | File ini                                | Profile/reflection tests       |
| 1.10 | Pastikan Safety Card tetap plain/dual-label                                     |    ⬜ Todo | `safety_card_view.dart`                                                                    | File ini                                | Safety test                    |
| 1.11 | Test 3 language level consistency                                               |    ⬜ Todo | `app/test/cultivation_strings_test.dart`                                                   | File ini                                | New test                       |
| 1.12 | Update status docs Fase 1                                                       |    ⬜ Todo | Docs                                                                                       | File ini, `05_implementation_status.md` | Doc review                     |

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

| ID   | Task                                                             |     Status | File Target                                           | Dokumen yang Diupdate                                             | Test/Validasi              |
| ---- | ---------------------------------------------------------------- | ---------: | ----------------------------------------------------- | ----------------------------------------------------------------- | -------------------------- |
| 2.1  | Pasang `CultivationBadge` di Dashboard                           | ✅ Selesai | `dashboard_view.dart`                                 | File ini                                                          | Widget test                |
| 2.2  | Pasang `CultivationProgressBar` tanpa rank agresif               | ✅ Selesai | `dashboard_view.dart` atau `tree_display_widget.dart` | File ini                                                          | Widget test                |
| 2.3  | Pasang `CultivationStatusPanel` sebagai panel ringkasan opsional | ✅ Selesai | `dashboard_view.dart` / settings/dev area             | File ini                                                          | UI smoke test              |
| 2.4  | Implement state-based visual modifiers untuk Dao Tree            | ✅ Selesai | `tree_display_widget.dart`, `growth_map_painter.dart` | File ini, `CULTIVATION_SYSTEM_FINAL.md` jika ada perubahan visual | Visual/accessibility test  |
| 2.5  | Growth state: normal/kanopi penuh                                | ✅ Selesai | `tree_display_widget.dart`                            | File ini                                                          | Manual visual check        |
| 2.6  | Recovery state: snow/soft visual, no death language              | ✅ Selesai | `tree_display_widget.dart`                            | File ini                                                          | Recovery test              |
| 2.7  | Dormant state: redup/tenang, bukan mati                          | ✅ Selesai | `tree_display_widget.dart`                            | File ini                                                          | Dormant test               |
| 2.8  | Tribulation state: aura biru/getaran halus                       | ✅ Selesai | `tree_display_widget.dart`                            | File ini                                                          | Motion accessibility check |
| 2.9  | Quiet Integration state: night/stars visual                      | ✅ Selesai | `tree_display_widget.dart`                            | File ini                                                          | Manual visual check        |
| 2.10 | Palace aura di Growth Map                                        | ✅ Selesai | `growth_map_painter.dart`, `growth_map_widget.dart`   | File ini                                                          | Visual/accessibility test  |
| 2.11 | Tambah skin cultivation: Bamboo Immortal                         | ✅ Selesai | `tree_skin_config.dart`, assets jika perlu            | File ini, `05_implementation_status.md`                           | Skin test                  |
| 2.12 | Tambah skin cultivation: Peach Blossom                           | ✅ Selesai | `tree_skin_config.dart`, assets jika perlu            | File ini                                                          | Skin test                  |
| 2.13 | Tambah skin cultivation: Ancient Pine                            | ✅ Selesai | `tree_skin_config.dart`, assets jika perlu            | File ini                                                          | Skin test                  |
| 2.14 | Pastikan visual tidak bergantung warna saja                      | ✅ Selesai | Painter/widgets                                       | File ini                                                          | Accessibility test         |
| 2.15 | Update status docs Fase 2                                        | ✅ Selesai | Docs                                                  | File ini, `05_implementation_status.md`                           | Doc review                 |

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

| ID   | Task                                                       |  Status | File Target                                  | Dokumen yang Diupdate                                        | Test/Validasi     |
| ---- | ---------------------------------------------------------- | ------: | -------------------------------------------- | ------------------------------------------------------------ | ----------------- |
| 3.1  | Implement achievement detection service                    | ⬜ Todo | `cultivation_achievement.dart`, service baru | File ini                                                     | Achievement tests |
| 3.2  | Realm Breakthrough milestone                               | ⬜ Todo | Achievement service, dialog                  | File ini                                                     | Test no spam      |
| 3.3  | Qi Milestone 100 practice                                  | ⬜ Todo | Achievement service                          | File ini                                                     | Test trigger      |
| 3.4  | Tribulation Survivor                                       | ⬜ Todo | Achievement service                          | File ini                                                     | Recovery test     |
| 3.5  | Dao Comprehension 1 tahun                                  | ⬜ Todo | Achievement service                          | File ini                                                     | Date test         |
| 3.6  | Legacy Builder marketplace trigger                         | ⬜ Todo | Marketplace service / achievement service    | File ini                                                     | Marketplace test  |
| 3.7  | 6 Paths detection algorithm                                | ⬜ Todo | `cultivation_layer.dart` atau service baru   | File ini, `CULTIVATION_SYSTEM_FINAL.md` jika scoring berubah | Path tests        |
| 3.8  | Path profile UI                                            | ⬜ Todo | `profile_dashboard_tab.dart`, widget baru    | File ini                                                     | Widget test       |
| 3.9  | Heart Demon detection service                              | ⬜ Todo | service baru                                 | File ini                                                     | Pattern tests     |
| 3.10 | Perfection Demon pattern                                   | ⬜ Todo | Heart Demon service                          | File ini                                                     | Test              |
| 3.11 | Impatience Demon pattern                                   | ⬜ Todo | Heart Demon service                          | File ini                                                     | Test              |
| 3.12 | Attachment Demon pattern                                   | ⬜ Todo | Heart Demon service                          | File ini                                                     | Test              |
| 3.13 | Heart Demon Severing flow                                  | ⬜ Todo | Journal/reflection/habit archive UI          | File ini                                                     | Flow test         |
| 3.14 | Demonic Cultivation warning sebagai pola, bukan label user | ⬜ Todo | Warning widget/service                       | File ini                                                     | Anti-guilt test   |
| 3.15 | Test: tidak ada streak requirement                         | ⬜ Todo | Test suite                                   | File ini                                                     | Anti-guilt test   |
| 3.16 | Update status docs Fase 3                                  | ⬜ Todo | Docs                                         | File ini, `05_implementation_status.md`                      | Doc review        |

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

| ID  | Task                                             |  Status | File Target                                          | Dokumen yang Diupdate                   | Test/Validasi         |
| --- | ------------------------------------------------ | ------: | ---------------------------------------------------- | --------------------------------------- | --------------------- |
| 4.1 | Cultivation Journal Mode                         | ⬜ Todo | `journal_lite_view.dart`, widget/service baru        | File ini, `05_implementation_status.md` | Journal test          |
| 4.2 | Palace Resonance Visualization refinement        | ⬜ Todo | `radar_chart_widget.dart`, `domain_scores_card.dart` | File ini                                | Visual test           |
| 4.3 | Mind Demon Diary                                 | ⬜ Todo | Journal/reflection feature                           | File ini, blueprint jika scope berubah  | Privacy/safety review |
| 4.4 | Dao Alignment Score — reflective, not judgmental | ⬜ Todo | Service/widget baru                                  | File ini                                | Anti-guilt test       |
| 4.5 | Sekte/Social Mode tanpa kompetisi                | ⬜ Todo | Marketplace/social area                              | File ini, blueprint                     | Product review        |
| 4.6 | User Guide — Cultivation Mode                    | ⬜ Todo | Docs/app guide                                       | File ini, user guide doc baru           | Doc review            |
| 4.7 | Update status docs Fase 4                        | ⬜ Todo | Docs                                                 | File ini, `05_implementation_status.md` | Doc review            |

### 6.2 Kriteria Selesai Fase 4

- Semua ekspansi tetap offline-first atau jelas batas sinkronisasinya.
- Social mode tidak menjadi leaderboard.
- Dao Alignment Score tidak menjadi skor rasa bersalah.

---

## 7. Test Matrix Wajib

| Area                                | Test                                        |              Status |
| ----------------------------------- | ------------------------------------------- | ------------------: |
| CultivationLayer from existing data | Semua 4 sumbu bisa dihitung tanpa data baru |              ✅ Ada |
| No DB migration needed              | Fase 0 tidak mengubah schema                |              ✅ Ada |
| 3-Level Language consistency        | Semua komponen punya string di 3 level      |    ⬜ Belum lengkap |
| Screen reader compatibility         | Semantic label tidak hilang                 |    ⬜ Belum lengkap |
| Anti-Guilt compliance               | Tidak ada punishment/judgment               |    ⬜ Belum lengkap |
| State transition logic              | State sesuai trigger                        |         ✅ Ada awal |
| Multi-sinyal realm calculation      | Realm bukan hanya hari                      |         ✅ Ada awal |
| Visual accessibility                | Visual tidak bergantung warna saja          |    ⬜ Belum lengkap |
| Performance impact                  | Animasi tidak jank                          | ⬜ Manual/perf test |

---

## 8. Log Implementasi

### 2026-07-02 — Fase 0 selesai

- Menambahkan folder `app/lib/src/features/cultivation/`.
- Menambahkan cultivation constants, layer, strings, provider, achievements, dan widget foundation.
- Menambahkan `app/test/cultivation_layer_test.dart`.
- Validasi: `flutter test` → 65 tests passed.

### 2026-07-02 — Task 1.1 Audit selesai

**Hasil Audit UI Copy:**

1. **Tree/Pohon (5 lokasi utama):**
   - `celebration_card.dart` → "Pohonmu sedang tumbuh"
   - `friction_intervention_sheet.dart` → "Pohon Anda akan diselimuti salju"
   - `tree_display_widget.dart` → Banyak referensi visual tree
   - `growth_map_semantics.dart` → "Akar Diri", "Daun Kebiasaan", "Bunga", "Buah"
   - `skin_shop_bottom_sheet.dart` → "Toko Skin Pohon"

2. **Domain/Palace (310+ matches, 28 files):**
   - `dashboard_view.dart` → Domain filter, radar chart
   - `domain_scores_card.dart` → Domain scores display
   - `domain_insight_dialog.dart` → Domain-specific insights
   - `radar_chart_widget.dart` → 6 domain labels
   - `habit/add_habit_view.dart` → Domain tag selection
   - `marketplace_view.dart` → Domain filter
   - `onboarding/widgets/audit_step.dart` → Domain audit

3. **Habit/Practice (23 matches, 6 files):**
   - `habit_list_section.dart` → "Kebiasaan Hari Ini" (header comment)
   - `action_of_the_day_card.dart` → "ACTION OF THE DAY"
   - `add_habit_view.dart` → "Tambah Kebiasaan" title
   - `thinking_canvas_lite_view.dart` → "daftar kebiasaan hari ini"

4. **Recovery/Seclusion (18 matches, 7 files):**
   - `friction_intervention_sheet.dart` → "Masuk Mode Istirahat"
   - `season_badge_widget.dart` → "Mode Istirahat Aktif"
   - `weekly_pulse_view.dart` → Recovery mode suggestion
   - `habit_list_section.dart` → "dijeda untuk mode istirahat"

5. **Journal (68 matches, 11 files):**
   - `journal_lite_view.dart` → "Refleksi Mendalam"
   - `journal_dashboard_tab.dart` → "Riwayat Mood & Refleksi Harian"
   - `decision_journal_view.dart` → Decision journal UI

6. **Reflection/Weekly Pulse (85 matches, 21 files):**
   - `reflection_dashboard_tab.dart` → "Refleksi Diri" title
   - `weekly_pulse_view.dart` → "Weekly Pulse Check", "Meridian Check"
   - `thinking_canvas_lite_view.dart` → "Thinking Canvas"

7. **Compass/Dao Heart (54 matches, 14 files):**
   - `profile_dashboard_tab.dart` → "Kompas Hidup"
   - `life_compass_section.dart` → "Kompas Hidup 🧭"
   - `value_mirror_intro_view.dart` → "Cermin Nilai"
   - `compass_comparison_dialog.dart` → Comparison logic

**Prioritas Integrasi:**

- **High:** Dashboard tree title, Action of Day, Habit list header, Recovery mode labels
- **Medium:** Domain labels di radar/growth map, Journal titles, Reflection tab
- **Low:** Internal comments, dev strings, template descriptions

### 2026-07-02 — Task 1.2 Language Picker selesai

**Implementasi:**

- Menambahkan dropdown picker di `settings_bottom_sheet.dart`
- Mengintegrasikan dengan `cultivationLanguageLevelProvider`
- 3 opsi: Plain (Sehari-hari), Hybrid (Paduan Tenang - default), Full (Nuansa Kultivasi)
- Deskripsi level ditampilkan di subtitle
- Validasi: `flutter test` → 65 tests passed

**File yang diubah:**

- `app/lib/src/features/dashboard/widgets/settings_bottom_sheet.dart`

### 2026-07-02 — Task 1.3 Dashboard Copy Integration selesai

**Implementasi:**

- Mengintegrasikan CultivationStrings ke widget dashboard utama
- `season_badge_widget.dart`: Season labels (Recovery/Dormant/Growth) kini menggunakan `CultivationStrings.seasonRecovery/Dormant/Growth()` dan `recoveryModeDescription()`
- `tree_display_widget.dart`:
  - Convert `TreeVitalityCard` dari StatefulWidget → ConsumerStatefulWidget
  - Dashboard title menggunakan `CultivationStrings.dashboardTitle()`
  - Journey label menggunakan `CultivationStrings.realmDisplay()` dengan realm dinamis dari `cultivationProvider`
  - Stage badge menggunakan `CultivationStrings.seasonRecovery/Growth()`
- Semua widget kini watch `cultivationLanguageLevelProvider` dan merespons perubahan bahasa secara real-time
- Validasi: `flutter test` → 65/65 tests passed, no compilation errors

**File yang diubah:**

- `app/lib/src/features/dashboard/widgets/season_badge_widget.dart`
- `app/lib/src/features/dashboard/widgets/tree_display_widget.dart`

### 2026-07-02 — Task 1.4 Action of the Day Copy Integration selesai

**Implementasi:**

- Convert `ActionOfTheDayCard` dari StatelessWidget → ConsumerWidget
- Menambahkan watch ke `cultivationLanguageLevelProvider`
- Header "ACTION OF THE DAY" diganti menjadi `CultivationStrings.actionOfTheDayTitle()`
- Subtitle pendek ditambahkan melalui `CultivationStrings.actionOfTheDaySubtitle()`
- Perubahan bahasa Plain/Hybrid/Full kini langsung memengaruhi copy kartu prioritas harian
- Validasi: `flutter test` → 65/65 tests passed, no compilation errors

**File yang diubah:**

- `app/lib/src/features/dashboard/widgets/action_of_the_day_card.dart`

### 2026-07-02 — Task 1.5 Habit List Language Integration selesai

**Implementasi:**

- `habit_list_section.dart`: Mengganti "Jadwal Kebiasaan Hari Ini" dengan `CultivationStrings.habitListTitle()`
- `add_habit_view.dart`:
  - AppBar title kini dinamis menggunakan `CultivationStrings.addHabit()` dan `habitLabel()`
  - Heading menggunakan cultivation strings
  - Dialog hapus menggunakan `habitLabel()` untuk terminology yang konsisten
  - Template section menggunakan `habitLabel()`
- Semua label "Kebiasaan" kini beradaptasi menjadi "Practice" (Hybrid) atau "Cultivation Technique" (Full)
- Validasi: `flutter test` → 65/65 tests passed, no compilation errors

**File yang diubah:**

- `app/lib/src/features/dashboard/widgets/habit_list_section.dart`
- `app/lib/src/features/habit/add_habit_view.dart`

### 2026-07-02 — Task 1.6 Growth Map Labels + Semantics selesai

**Implementasi:**

- `growth_map_semantics.dart`: `buildLabel()` kini menerima `CultivationLanguageLevel`
- Semantics root/branch/leaf/flower/fruit menggunakan `CultivationStrings.growthMapRoot/Branch/Leaf/Flower/Fruit()`
- `growth_map_widget.dart`: watch `cultivationLanguageLevelProvider` dan meneruskan level ke semantics builder
- Dialog root Growth Map menggunakan `CultivationStrings.growthMapRoot()` untuk judul
- `growth_map_accessibility_test.dart`: diperbarui agar memvalidasi label semantics berbasis level Plain
- Validasi: `flutter test` → 65/65 tests passed, no compilation errors

**File yang diubah:**

- `app/lib/src/features/dashboard/widgets/growth_map/growth_map_widget.dart`
- `app/lib/src/features/dashboard/widgets/growth_map/growth_map_semantics.dart`
- `app/test/growth_map_accessibility_test.dart`

### 2026-07-02 — Task 1.7 Friction Intervention Language selesai

**Implementasi:**

- `friction_intervention_sheet.dart`: watch `cultivationLanguageLevelProvider`
- Title "Ada apa hari ini?" → `CultivationStrings.frictionInterventionTitle()` (Hambatan apa? / Bottleneck apa? / Heart Demon macam apa?)
- Option "Kurang Waktu" → `CultivationStrings.frictionOptionTime()` (Kurang Waktu / Qi belum terkumpul / Qi-mu bocor)
- Option "Kelelahan / Sakit" → `CultivationStrings.frictionOptionEnergy()` (Kelelahan / Energi habis / Shen-mu lelah)
- Option "Lupa / Kurang Fokus" → `CultivationStrings.frictionOptionForgot()` (Lupa / Fokus buyar / Pikiranmu tercerai)
- Validasi: `flutter test` → 65/65 tests passed, no compilation errors

**File yang diubah:**

- `app/lib/src/features/dashboard/sheets/friction_intervention_sheet.dart`

### 2026-07-02 — Task 1.8 Journal + Thinking Canvas Language selesai

**Implementasi:**

- `journal_lite_view.dart`:
  - Added cultivation imports
  - Watch `cultivationLanguageLevelProvider`
  - AppBar title "Jurnal Lite" → `CultivationStrings.journalLite()` (Cepat / Journal Ringan / Meditasi Cepat)
  - Prompt "Bagaimana perasaan Anda hari ini?" → `CultivationStrings.journalMoodPrompt()` (Bagaimana perasaanmu / aliran energimu / keselarasan Qi-mu)
- `journal_dashboard_tab.dart`:
  - Added cultivation imports
  - Watch `cultivationLanguageLevelProvider`
  - AppBar title "Jurnal & Mood 📝" → `CultivationStrings.journalTitle()` (📝 Catatan Harian / 📝 Qi Log / 📜 Heart Scripture)
  - Button "Tulis Jurnal Lengkap / Refleksi Mendalam" → `CultivationStrings.journalDeep()` (Refleksi / Deep Reflection / Pemurnian Shen)
  - Title "Jurnal Keputusan (Decision Journal) ⚖️" → `CultivationStrings.decisionJournalTitle()` (Catatan Keputusan / Forked Path Journal / Dao Crossroads Record)
- `thinking_canvas_lite_view.dart`: Tidak ada cultivation strings khusus untuk Thinking Canvas, tetap menggunakan naming asli metode berpikir
- Validasi: `flutter test` → 65/65 tests passed, no compilation errors

**Catatan:** Beberapa istilah pohon (akar, cabang, buah) masih muncul di Thinking Canvas methods (Mind Map, Lotus Blossom, 5 Whys) karena mereka adalah nama metode berpikir standar, bukan bagian dari UI cultivation system.

**File yang diubah:**

- `app/lib/src/features/journal/journal_lite_view.dart`
- `app/lib/src/features/journal/journal_dashboard_tab.dart`

### 2026-07-02 — Task 1.9 Reflection/Profile Language Integration selesai

**Implementasi:**

- `reflection_dashboard_tab.dart`:
  - Converted `StatelessWidget` → `ConsumerWidget`
  - Added cultivation imports and watch `cultivationLanguageLevelProvider`
  - "Cermin Nilai 🪞" → `CultivationStrings.valueMirrorTitle()` (Cermin Nilai / Dao Heart Mirror / Heart Demon Mirror)
  - "Weekly Pulse 📈" → `CultivationStrings.weeklyPulseTitle()` (Review Mingguan / Meridian Check / Resonance Check)
- `profile_dashboard_tab.dart`:
  - Added cultivation imports
  - Dialog title "Tentukan Kompas Hidup 🧭" → `CultivationStrings.lifeCompassTitle()` (Kompas Hidup / Dao Heart / Dao Heart (道心))
  - Success message "Kompas hidup berhasil disimpan!" → uses `lifeCompassTitle()` dynamically
- `life_compass_section.dart`:
  - Converted `StatelessWidget` → `ConsumerWidget`
  - Added cultivation imports and watch `cultivationLanguageLevelProvider`
  - Section title "Kompas Hidup 🧭" → `CultivationStrings.lifeCompassTitle()`
  - Button "Mulai Cermin Nilai 🪞" → `CultivationStrings.valueMirrorTitle()`
- Validasi: `flutter test` → 65/65 tests passed, no compilation errors

**File yang diubah:**

- `app/lib/src/features/reflection/reflection_dashboard_tab.dart`
- `app/lib/src/features/profile/profile_dashboard_tab.dart`
- `app/lib/src/features/profile/widgets/life_compass_section.dart`

**Catatan:** Phase 1 (Narasi & Bahasa) sekarang selesai sepenuhnya. Semua UI copy utama kini responsif terhadap 3 level bahasa kultivasi.

### 2026-07-02 — Task 2.1 CultivationBadge di Dashboard selesai

**Implementasi:**

- `dashboard_view.dart`:
  - Added import for `cultivation_badge.dart`
  - Placed `CultivationBadge` widget in AppBar actions (top right corner)
  - Badge displays current realm level and name (e.g., "1 Memulai" / "1 Foundation" / "1 Foundation (筑基)")
  - Badge styling adapts to theme with primary container background
  - Badge language adapts to user's selected cultivation language level
- Badge widget already existed from Phase 0, task was integration into dashboard UI
- Validasi: `flutter test` → 65/65 tests passed, no compilation errors

**File yang diubah:**

- `app/lib/src/features/dashboard/dashboard_view.dart`

### 2026-07-02 — Task 2.2 CultivationProgressBar tanpa rank agresif selesai

**Implementasi:**

- `dashboard_view.dart`:
  - Added `CultivationProgressBar` below season status and above Tree Vitality card
  - Progress is now visible in the primary dashboard flow without adding competitive/ranking UI
- `cultivation_progress_bar.dart`:
  - Replaced numeric "Realm X" label with current realm name
  - Label adapts to 3 language levels:
    - Plain: Indonesian realm name
    - Hybrid: English cultivation realm name
    - Full: English realm name + Chinese name
  - Kept percentage as personal progress within the current realm only
  - Added overflow handling for long full-cultivation labels
- Validasi: `flutter test` → 65/65 tests passed, no compilation errors

**File yang diubah:**

- `app/lib/src/features/dashboard/dashboard_view.dart`
- `app/lib/src/features/cultivation/widgets/cultivation_progress_bar.dart`

### 2026-07-02 — Task 2.3 CultivationStatusPanel opsional selesai

**Implementasi:**

- `dashboard_view.dart`:
  - Added `CultivationStatusPanel` import
  - Added `_showCultivationDetails` state flag
  - Added `TextButton.icon` toggle below cultivation progress bar
  - Panel is hidden by default and can be expanded with "Lihat status kultivasi"
  - Expanded panel shows current cultivation summary without making the dashboard too dense
- Validasi: `flutter test` → 65/65 tests passed, no compilation errors

**File yang diubah:**

- `app/lib/src/features/dashboard/dashboard_view.dart`

### 2026-07-02 — Task 2.4 State-based visual modifiers untuk Dao Tree selesai

**Implementasi:**

- `growth_map_painter.dart`:
  - Added `_SeasonModifier` class with alpha, saturation, and glow multipliers
  - Implemented `_applySeasonMod()` method to apply HSV saturation and alpha adjustments
  - Added season-based visual states:
    - **Growth** (default): Normal vibrant colors (1.0x multipliers)
    - **Recovery**: Muted 0.7x alpha, 0.5x saturation, 0.6x glow (calm, resting state)
    - **Dormant**: Very muted 0.5x alpha, 0.3x saturation, 0.4x glow (minimal energy)
    - **Tribulation**: Intense 1.2x alpha, 1.3x saturation, 1.4x glow (heightened state)
    - **QuietIntegration**: Subtle 0.85x alpha, 0.7x saturation, 0.9x glow (calm focus)
  - Applied modifiers to all tree elements: roots, branches, leaves, flowers, fruits, and glow effects
  - Visual state now dynamically reflects cultivation season without aggressive UI
- Validasi: `flutter test` → 65/65 tests passed, no compilation errors

**File yang diubah:**

- `app/lib/src/features/dashboard/widgets/growth_map/growth_map_painter.dart`

### 2026-07-02 — Task 2.5 Growth state normal/kanopi penuh selesai

**Implementasi:**

- `tree_display_widget.dart`:
  - Added full-canopy visual state when `balanceIndex >= 0.8` and not in recovery
  - Added animated glow around the tree scene for healthy/full-canopy state
  - Added `_FullCanopyBadge` with language-level-aware labels:
    - Plain: "Kanopi Penuh"
    - Hybrid: "Full Canopy"
    - Full: "Full Canopy (满载)"
  - Kept normal growth state unchanged below threshold, so users see enhancement only when balance is strong
- Validasi: `flutter test` → 65/65 tests passed, no compilation errors

**File yang diubah:**

- `app/lib/src/features/dashboard/widgets/tree_display_widget.dart`

### 2026-07-02 — Task 2.6 Recovery state: snow/soft visual, no death language selesai

**Implementasi:**

- `tree_display_widget.dart`:
  - Added soft blue gradient veil overlay during recovery mode
  - Gradient uses CalmTheme.secondaryBlue with gentle alpha transitions
  - Layered over existing snow animation for a calm, restful visual (not harsh/dead)
  - Comment explicitly states "never death/decay language" to reinforce supportive design
  - Existing cultivation strings already use supportive language: "Mode Istirahat", "Seclusion", "Focus on recovery"
- Validasi: `flutter test` → 65/65 tests passed, no compilation errors

**File yang diubah:**

- `app/lib/src/features/dashboard/widgets/tree_display_widget.dart`

### 2026-07-02 — Task 2.7 Dormant state: redup/tenang, bukan mati selesai

**Implementasi:**

- `tree_display_widget.dart`:
  - Added `isDormant` flag to detect dormant season state
  - Added dim radial gradient overlay for dormant state (darker than recovery, softer than harsh)
  - Gradient uses black with low alpha (0.08–0.22) for restful, quiet visual
  - Comment explicitly states "never death/decay language" to maintain supportive design
  - Existing cultivation strings already use supportive language: "Mode Istirahat Panjang", "Dormant Phase", "Winter Hibernation"
- Validasi: `flutter test` → 65/65 tests passed, no compilation errors

**File yang diubah:**

- `app/lib/src/features/dashboard/widgets/tree_display_widget.dart`

### 2026-07-02 — Task 2.8 Tribulation state: aura biru/getaran halus selesai

**Implementasi:**

- `tree_display_widget.dart`:
  - Added `cultivationSeason` optional parameter to TreeDisplayWidget to support cultivation-specific seasons (tribulation, quietIntegration)
  - Added `isTribulation` flag using `CultivationSeason.tribulation`
  - Created `TribulationAuraWidget`: pulsing blue radial gradient aura (3s cycle, 0.08–0.18 alpha)
  - Uses `Colors.blue.shade700` and `Colors.blue.shade300` for gentle, supportive visual (not harsh/violent)
  - Animation uses `Curves.easeInOut` for smooth, calming pulse
  - Passed `cultivation?.season` from TreeVitalityCard to TreeDisplayWidget
- Validasi: `flutter test` → 65/65 tests passed, no compilation errors

**File yang diubah:**

- `app/lib/src/features/dashboard/widgets/tree_display_widget.dart`

### 2026-07-02 — Task 2.9 Quiet Integration state: night/stars visual selesai

**Implementasi:**

- `tree_display_widget.dart`:
  - Added `isQuietIntegration` flag using `CultivationSeason.quietIntegration`
  - Created `QuietIntegrationOverlay`: stable night-sky visual with soft gradient and static stars
  - `_QuietIntegrationGradient`: uses `CalmTheme.secondaryBlue` with gentle alpha (0.12 → 0.05 → transparent)
  - `_SoftStar`: four positioned stars with varied sizes (2.5–3.5) and alpha (0.32–0.42) for peaceful, stable visual
  - Stars have soft glow via boxShadow (no animation/motion for accessibility)
  - Represents post-recovery integration period (7 days after recovery ends)
- Validasi: `flutter test` → 65/65 tests passed, no compilation errors

**File yang diubah:**

- `app/lib/src/features/dashboard/widgets/tree_display_widget.dart`

### 2026-07-02 — Task 2.10 Palace aura di Growth Map selesai

**Implementasi:**

- `growth_map_painter.dart`:
  - Added `_drawPalaceAura` helper for each domain branch/palace node
  - Aura radius scales with branch score (14–30 px)
  - Aura alpha scales with branch score and season glow multiplier
  - Draws radial gradient using existing branch color while preserving season modifiers
  - Accessibility: aura is not color-only; stronger palace resonance also changes radius, stroke width, and ring count
  - Score ≥ 6 shows outer ring; score ≥ 8 shows additional inner ring
  - Palace aura is drawn behind branch paths before connectors for soft, non-intrusive visual hierarchy
- Validasi: `flutter test` → 65/65 tests passed, no compilation errors

**File yang diubah:**

- `app/lib/src/features/dashboard/widgets/growth_map/growth_map_painter.dart`

### 2026-07-02 — Task 2.11 Tambah skin cultivation: Bamboo Immortal selesai

**Implementasi:**

- `app_constants.dart`: Added `TreeSkin.bambooImmortal = 'Bamboo_Immortal'` constant
- `tree_skin_config.dart`: Added `TreeSkin.bambooImmortal` to `supportedSkins` set
- `skin_shop_bottom_sheet.dart`: Added Bamboo Immortal to shop list with cultivation-themed description
  - Name: "Bamboo Immortal 🎋"
  - Description: "Bambu abadi dengan aura kultivasi. Melambangkan ketahanan dan fleksibilitas jiwa."
  - Price: Rp 30.000 (premium cultivation skin)
  - Preview: '🎋🌱 🎋🌿 🎋🌳 🎋🌲'
- No assets added yet (can be added later if needed)
- Validasi: `flutter test` → 65/65 tests passed, no compilation errors

**File yang diubah:**

- `app/lib/src/core/domain/app_constants.dart`
- `app/lib/src/core/domain/tree_skin_config.dart`
- `app/lib/src/features/dashboard/widgets/skin_shop_bottom_sheet.dart`

### 2026-07-02 — Task 2.12 Tambah skin cultivation: Peach Blossom selesai

**Implementasi:**

- `app_constants.dart`: Added `TreeSkin.peachBlossom = 'Peach_Blossom'` constant
- `tree_skin_config.dart`: Added `TreeSkin.peachBlossom` to `supportedSkins` set
- `skin_shop_bottom_sheet.dart`: Added Peach Blossom Paradise to shop list with cultivation-themed description
  - Name: "Peach Blossom Paradise 🌺"
  - Description: "Pohon persik abadi dari surga kultivator. Melambangkan umur panjang dan ketenangan jiwa."
  - Price: Rp 30.000 (premium cultivation skin)
  - Preview: '🌺🌱 🌺🌿 🌺🌳 🌺🌲'
- No assets added yet (can be added later if needed)
- Validasi: `flutter test` → 65/65 tests passed, no compilation errors

**File yang diubah:**

- `app/lib/src/core/domain/app_constants.dart`
- `app/lib/src/core/domain/tree_skin_config.dart`
- `app/lib/src/features/dashboard/widgets/skin_shop_bottom_sheet.dart`

### 2026-07-02 — Task 2.13 Tambah skin cultivation: Ancient Pine selesai

**Implementasi:**

- `app_constants.dart`: Added `TreeSkin.ancientPine = 'Ancient_Pine'` constant
- `tree_skin_config.dart`: Added `TreeSkin.ancientPine` to `supportedSkins` set
- `skin_shop_bottom_sheet.dart`: Added Ancient Pine to shop list with cultivation-themed description
  - Name: "Ancient Pine 🌲"
  - Description: "Pinus kuno yang berdiri ribuan tahun. Melambangkan ketekunan, stabilitas, dan kebijaksanaan."
  - Price: Rp 35.000 (premium cultivation skin, highest tier)
  - Preview: '🌲🌱 🌲🌿 🌲🌳 🌲'
- No assets added yet (can be added later if needed)
- Validasi: `flutter test` → 65/65 tests passed, no compilation errors

**File yang diubah:**

- `app/lib/src/core/domain/app_constants.dart`
- `app/lib/src/core/domain/tree_skin_config.dart`
- `app/lib/src/features/dashboard/widgets/skin_shop_bottom_sheet.dart`

### 2026-07-02 — Task 2.14 Pastikan visual tidak bergantung warna saja selesai

**Audit Accessibility:**

- Reviewed all cultivation visual components for color-independence
- **Palace aura** (Task 2.10): ✅ Uses radius scaling (14–30px), stroke width variation (1.4–2.2), and ring patterns (outer ring ≥6 score, inner ring ≥8 score) — not color-only
- **Season visual modifiers**: ✅ Use alpha, saturation, and glow multipliers; overlays include gradients, animations, and patterns — not color-only
- **Tree state overlays**:
  - Recovery: ✅ Snow animation + soft blue gradient
  - Dormant: ✅ Dim radial gradient (black low-alpha)
  - Tribulation: ✅ Pulsing blue aura (animation cue)
  - Quiet Integration: ✅ Night gradient + static stars (position + glow pattern)
- **Growth Map semantics**: ✅ Semantic labels present for all node types (root, branch, leaf, flower, fruit)
- **Accessibility tests**: ✅ 3/3 tests passed in `growth_map_accessibility_test.dart`
- All key visual states use multiple cues: size, stroke, pattern, animation, position, and semantic labels

**Validasi:**

- Accessibility test suite: 3/3 passed
- Visual implementations confirmed to use non-color cues

### 2026-07-02 — Task 2.15 Update status docs Fase 2 selesai

**Documentation Update:**

- Updated `05_implementation_status.md`:
  - Changed Cultivation Visual UI status: 🔶 BERJALAN → ✅ SELESAI
  - Changed readiness: 🟡 Implemented → 🟢 Production-Ready
  - Added **Fase 2 Selesai** marker
  - Listed all completed Phase 2 deliverables
- **Phase 2 Summary:**
  - ✅ Tasks 2.1–2.15 complete (15/15)
  - ✅ Badge, progress bar, status panel integrated into Dashboard
  - ✅ 5 cultivation state visuals: growth/full-canopy, recovery, dormant, tribulation, quiet integration — all non-punitive
  - ✅ Palace aura visualization in Growth Map with multi-cue accessibility
  - ✅ 3 cultivation-themed tree skins: Bamboo Immortal, Peach Blossom, Ancient Pine
  - ✅ Accessibility audit passed: all visuals use multiple cues beyond color
  - ✅ All tests passing: 65/65

**File yang diubah:**

- `docs/CULTIVATION_IMPLEMENTATION_PLAN.md`
- `docs/05_implementation_status.md`

---

## 🎉 Phase 2: Cultivation Visual UI — SELESAI

**Tanggal Selesai:** 2026-07-02

**Kriteria Selesai (Terpenuhi Semua):**

- ✅ 5 cultivation states memiliki representasi visual non-punitive dan supportive
- ✅ Badge, progress bar, dan status panel terintegrasi ke Dashboard
- ✅ Visual cultivation menggunakan multi-cue (tidak bergantung warna saja)
- ✅ 3 cultivation skins premium tersedia di skin shop
- ✅ Palace aura visualization di Growth Map dengan accessibility support
- ✅ Semantic labels untuk screen readers
- ✅ All tests passing (65/65)

**Next Steps:** Lihat Phase 3 di bawah untuk fitur cultivation interaction & progression.

---

## ✅ UX Preference: Onboarding & Settings Cultivation Theme Choice — SELESAI

**Tanggal Selesai:** 2026-07-02

**Latar Belakang:** Tidak semua user familiar dengan istilah cerita immortal/cultivation seperti Qi, Realm, Dao, atau Seclusion. Karena itu tema kultivasi kini bisa dipilih secara eksplisit dan tidak dipaksakan.

**Implementasi:**

- ✅ Tambah field persistensi `cultivationThemeEnabled` di `UserProfiles` dengan migration schema v9.
- ✅ Tambah step onboarding “Pilih gaya bahasa aplikasi” sebelum age/audit/disclaimer.
- ✅ Onboarding menyimpan pilihan bahasa sederhana vs tema kultivasi.
- ✅ Settings memiliki toggle “Tema Kultivasi” untuk mengubah preferensi kapan saja.
- ✅ `cultivationLanguageLevelProvider` membaca preferensi profile: jika disabled, UI dipaksa ke `plain`; jika enabled, default `hybrid` dan tetap mendukung pilihan level.
- ✅ Copy memakai framing supportive dan non-punitive.
- ✅ Drift generated code diperbarui.
- ✅ Validasi: `flutter test` → 65/65 passed.

**File utama:**

- `app/lib/src/data/local_db/database.dart`
- `app/lib/src/data/local_db/database.g.dart`
- `app/lib/src/features/onboarding/onboarding_view.dart`
- `app/lib/src/features/onboarding/widgets/cultivation_theme_step.dart`
- `app/lib/src/features/cultivation/cultivation_provider.dart`
- `app/lib/src/features/dashboard/widgets/settings_bottom_sheet.dart`
- `app/test/onboarding_test.dart`

---

## 9. Next Immediate Task

**Phase 2 dan UX Preference selesai. Lihat Phase 3 untuk kelanjutan implementasi.**
