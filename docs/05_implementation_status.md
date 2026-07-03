# Status Implementasi Aplikasi Daoji

Laporan ini menyajikan status pencapaian pengembangan aplikasi **Daoji** (Personal Life OS) hingga saat ini, membandingkan realisasi fitur dengan rancangan master blueprint, serta memetakan sisa backlog pekerjaan.

> **Keterangan Maturity Level:**
>
> - 🟢 **Production-Ready** — Stabil, tervalidasi unit test, aman untuk beta
> - 🟡 **Implemented** — Berfungsi, belum ada test coverage penuh
> - 🟠 **Prototype** — Berfungsi secara UI, logika backend masih simulasi/mock
> - ⚪ **Backlog** — Belum diimplementasi

---

## 1. Ringkasan Status Proyek

- **Tanggal Pembaruan:** 2 Juli 2026
- **Target Platform:** Windows Desktop, Android, iOS (Cross-Platform)
- **Penyimpanan Data:** Offline-First (SQLite Local Database via Drift Generator)
- **Versi Skema Database Saat Ini:** `9` (Mendukung target goals, kustomisasi review period, kompas hidup, marketplace template, respons dilema nilai tersirat, dan preferensi tema kultivasi)
- **Status Analisis & Tes:**
  - `flutter analyze` → **Lolos 100%** (Bersih dari error, warning, lints)
  - `flutter test` → **65/65 Tests Passed** (Unit/widget test: Onboarding, Decision, Weekly Pulse, Safety, Profile, HabitLog, Scheduling, Value Compass, Cultivation Layer)

---

## 2. Matriks Kelayakan Fitur (Feature Coverage Matrix)

### 🌱 Lapis 0: Akar (Refleksi Adaptif & Diagnosis)

| Fitur                   | Status     | Maturity            | Catatan                                                                                                  |
| ----------------------- | ---------- | ------------------- | -------------------------------------------------------------------------------------------------------- |
| Onboarding & Life Audit | ✅ SELESAI | � Production-Ready  | Berfungsi, tervalidasi test onboarding flow; kini menyertakan pilihan bahasa sederhana vs tema kultivasi |
| Journal Lite            | ✅ SELESAI | 🟢 Production-Ready | Pre-fill hari ini, low mood 3 hari berturut-turut (tervalidasi test)                                     |
| Deep Reflection         | ✅ SELESAI | 🟡 Implemented      | Sakelar ekspansi + Gratitude chips                                                                       |
| Thinking Canvas Lite    | ✅ SELESAI | 🟡 Implemented      | PMI/Mind Dump/Reverse Brainstorming, domain tag                                                          |
| Weekly Pulse (WHO-5)    | ✅ SELESAI | 🟡 Implemented      | Update-safe (tidak duplikat entry minggu sama)                                                           |
| Safety Card             | ✅ SELESAI | 🟢 Production-Ready | Dialer telepon asli via url_launcher, rotasi warna harian                                                |

### 🪵 Lapis 1: Batang (Beban & Goal Hierarchy)

| Fitur                       | Status     | Maturity            | Catatan                                               |
| --------------------------- | ---------- | ------------------- | ----------------------------------------------------- |
| Canopy Load System          | ✅ SELESAI | 🟡 Implemented      | Peringatan halus 10 poin, belum ada test              |
| Goal Hierarchy Tagging      | ✅ SELESAI | 🟡 Implemented      | Kolom `goalTag` di SQLite                             |
| Habit Log (Done/Missed)     | ✅ SELESAI | 🟢 Production-Ready | Upsert-safe via HabitLogService (tervalidasi test)    |
| Friction Intervention & MVA | ✅ SELESAI | 🟡 Implemented      | Upsert-safe, Recovery Mode aktif, MVA duration UI ada |
| Automaticity Decay          | ⬜ BACKLOG | ⚪ Backlog          | Algoritma UCL Lally-based belum diimplementasi        |

### 🌿 Lapis 2: Cabang (6 Domain Kehidupan)

| Fitur                    | Status     | Maturity       | Catatan                                                  |
| ------------------------ | ---------- | -------------- | -------------------------------------------------------- |
| 6 Domain Kehidupan       | ✅ SELESAI | 🟡 Implemented | Pemilihan domain di form habit & thinking canvas         |
| Radar Chart Keseimbangan | ✅ SELESAI | 🟡 Implemented | Blended score 70%+30%, visualisasi hexagon               |
| Action of the Day        | ✅ SELESAI | 🟡 Implemented | Priority score berdasarkan domain deficit, dynamic emoji |
| Scheduling Non-Daily     | ✅ SELESAI | 🟠 Prototype   | Logika ada, belum divalidasi unit test                   |

### 🍎 Lapis 3: Buah & Kompas (Advanced OS)

| Fitur                                 | Status     | Maturity            | Catatan                                                                   |
| ------------------------------------- | ---------- | ------------------- | ------------------------------------------------------------------------- |
| Life Compass (Core Values)            | ✅ SELESAI | 🟡 Implemented      | Preset chips + visualisasi lencana dashboard                              |
| Revealed Value Compass (Cermin Nilai) | ✅ SELESAI | 🟢 Production-Ready | Dilema biner + Tally scores + Perbandingan netral (tervalidasi unit test) |
| Decision Journal                      | ✅ SELESAI | 🟡 Implemented      | Kustomisasi review period, refleksi bias keputusan                        |
| Overdue Decision Alert                | ✅ SELESAI | 🟡 Implemented      | Alert otomatis di dashboard jika jatuh tempo                              |

### 🛒 Ekosistem, Monetisasi & Developer Mode

| Fitur                      | Status       | Maturity            | Catatan                                                                      |
| -------------------------- | ------------ | ------------------- | ---------------------------------------------------------------------------- |
| Habit Template Marketplace | ✅ SELESAI   | 🟢 Production-Ready | Persistensi SQLite lokal via LocalMarketplaceService (tervalidasi unit test) |
| Tree Skin Shop             | 🔶 PROTOTYPE | 🟠 Prototype        | Simulasi payment (GPay/VA/QRIS), bukan integrasi payment nyata               |
| Developer Mode Toggle      | ✅ SELESAI   | 🟡 Implemented      | Debug-only — untuk bypass skin payment saat testing                          |

### ☯️ Cultivation System — Migrasi Konsep Daoji

| Fitur                          | Status     | Maturity            | Catatan                                                                                                                                                                                                                                                                                                                                                 |
| ------------------------------ | ---------- | ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Cultivation Interpretive Layer | ✅ SELESAI | 🟢 Production-Ready | `CultivationLayer` membaca data existing tanpa migrasi database                                                                                                                                                                                                                                                                                         |
| Realm Multi-Signal Calculation | ✅ SELESAI | 🟢 Production-Ready | Realm dihitung dari hari, konsistensi, refleksi, keseimbangan domain, dan compass                                                                                                                                                                                                                                                                       |
| Season/State Detection         | ✅ SELESAI | 🟢 Production-Ready | Growth, Recovery, Dormant, Tribulation, Quiet Integration                                                                                                                                                                                                                                                                                               |
| Palace Mapping                 | ✅ SELESAI | 🟢 Production-Ready | 6 domain dipetakan ke 6 Palace                                                                                                                                                                                                                                                                                                                          |
| Cultivation Providers          | ✅ SELESAI | 🟢 Production-Ready | Riverpod provider untuk layer, realm, season, dan qi                                                                                                                                                                                                                                                                                                    |
| 3-Level Language Foundation    | ✅ SELESAI | 🟡 Implemented      | Plain, Hybrid, Full Cultivation tersedia via `CultivationStrings`                                                                                                                                                                                                                                                                                       |
| Language Picker Settings       | ✅ SELESAI | � Production-Ready  | Toggle Tema Kultivasi tersimpan di SQLite; jika disabled UI dipaksa Plain, jika enabled tersedia Plain/Hybrid/Full                                                                                                                                                                                                                                      |
| UI Copy Integration            | ✅ SELESAI | ✅ Complete         | Dashboard, Action of Day, Habit list, Growth Map, Friction, Journal, Reflection, Profile — semua UI utama responsif terhadap 3 level bahasa                                                                                                                                                                                                             |
| Cultivation Visual UI          | ✅ SELESAI | 🟢 Production-Ready | **Fase 2 Selesai**: Badge, progress bar, status panel terpasang; 5 cultivation states (growth/full-canopy, recovery, dormant, tribulation, quiet integration) punya visual non-punitive; palace aura di Growth Map; 3 cultivation skins (Bamboo Immortal, Peach Blossom, Ancient Pine); accessibility audit passed (multi-cue visuals, semantic labels) |
| Achievement/Path/Heart Demon   | ⬜ BACKLOG | ⚪ Backlog          | Model awal ada, detection logic belum diimplementasikan                                                                                                                                                                                                                                                                                                 |

### ⚙️ Utilitas & Keamanan

| Fitur                    | Status     | Maturity            | Catatan                                             |
| ------------------------ | ---------- | ------------------- | --------------------------------------------------- |
| Light & Dark Theme       | ✅ SELESAI | 🟡 Implemented      | Preferensi tersimpan di SQLite                      |
| JSON Exporter            | ✅ SELESAI | 🟠 Prototype        | Tampil di dialog, belum share_plus ke file nyata    |
| App Reset (Purge DB)     | ✅ SELESAI | 🟡 Implemented      | Semua tabel termasuk DecisionEntries dihapus        |
| AXTree Debug Shielding   | ✅ SELESAI | 🟡 Implemented      | `ExcludeSemantics` kondisional di debug mode        |
| SQLCipher Encryption     | ⬜ BACKLOG | ⚪ Backlog          | Database saat ini SQLite biasa, belum terenkripsi   |
| userId Query Consistency | ✅ SELESAI | 🟢 Production-Ready | Semua kueri Drift difilter berdasarkan userId aktif |

---

## 3. Backlog Teknis Aktif

| Prioritas | Item                                                            | Area                 |
| --------- | --------------------------------------------------------------- | -------------------- |
| 🟡 P2     | `ExportService` menggunakan `share_plus` ke file nyata          | `features/export/`   |
| 🟢 P3     | Tambah `TimeService` / `clockProvider` untuk test deterministik | `core/time/`         |
| 🟢 P3     | SQLCipher encryption database                                   | `data/local_db/`     |
| 🟢 P3     | Frequency cap wellness prompt (maks 1x per 7 hari)              | `features/wellness/` |

---

## 4. Peta Folder & Berkas Utama Aplikasi

Berikut adalah lokasi berkas penting hasil implementasi pada direktori [app/lib/src/](../app/lib/src/):

- **Database & Skema:**
  - [database.dart](../app/lib/src/data/local_db/database.dart) → Definisi tabel SQLite Drift, migrasi skema `onUpgrade` (Versi 1-5), dan indeks optimasi kueri.
- **Navigasi & Tema:**
  - [app.dart](../app/lib/src/app.dart) → Inisialisasi aplikasi, tema, dan debug-shield `ExcludeSemantics`.
  - [router.dart](../app/lib/src/core/routing/router.dart) → Rute GoRouter dan pengecekan onboarding.
  - [theme.dart](../app/lib/src/core/theme/theme.dart) → Desain sistem Calm Tech (Light & Dark Theme).
- **Services (Baru):**
  - [habit_log_service.dart](../app/lib/src/features/habit/services/habit_log_service.dart) → Service upsert-safe untuk toggle done/missed habit log.
- **Fitur Views & Providers:**
  - [dashboard_view.dart](../app/lib/src/features/dashboard/dashboard_view.dart) → Visual dasbor utama, menu pengaturan data, dan widget Life Compass.
  - [dashboard_provider.dart](../app/lib/src/features/dashboard/dashboard_provider.dart) → Kalkulator "Action of the Day", data musim, scheduling, dan status jatuh tempo keputusan.
  - [add_habit_view.dart](../app/lib/src/features/habit/add_habit_view.dart) → Dropdown domain kebiasaan, MVA slider, template micro-habits, dan Goal tag input.
  - [journal_lite_view.dart](../app/lib/src/features/journal/journal_lite_view.dart) → Jurnal harian, low-mood check 3 hari berturut-turut, dan form ekspansi Refleksi Mendalam.
  - [decision_journal_view.dart](../app/lib/src/features/decision_journal/decision_journal_view.dart) → Riwayat keputusan, kustomisasi review period, dan refleksi bias.
  - [marketplace_view.dart](../app/lib/src/features/marketplace/marketplace_view.dart) → Halaman pencarian, pengunduhan, pengunggahan, dan rating template kebiasaan **(Prototype)**.
  - [weekly_pulse_view.dart](../app/lib/src/features/weekly_pulse/weekly_pulse_view.dart) → Lembar evaluasi mingguan WHO-5 index.
  - [safety_card_view.dart](../app/lib/src/features/safety/safety_card_view.dart) → Papan kontak darurat kesehatan mental terotasi warna dengan dialer asli.
