# Life-Tree Codebase — Improvement Plan

**Repo:** `fajarkurnia0388/life-tree` · `main` branch  
**Scope:** `app/` (Flutter/Dart), `pubspec.yaml`, `.gitignore`, tanpa `.github/`  
**Format:** Tiap item berisi lokasi file exact, diagnosis singkat, dan instruksi konkret untuk coding agent.

---

## Prioritas P0 — Bug Runtime / Data Korup

### FIX-01 · Ghost class `_FrictionInterventionSheet` di `dashboard_view.dart`

**File:** `app/lib/src/features/dashboard/dashboard_view.dart`  
**Baris:** 1557–2105 (habis di akhir file)

**Diagnosis:**  
`_showFrictionIntervention()` mengimport dan menginstansiasi `FrictionInterventionSheet` dari
`sheets/friction_intervention_sheet.dart`. Namun, di bawah `dashboard_view.dart` terdapat
kelas private `_FrictionInterventionSheet` (~548 baris) yang **tidak pernah dipanggil** — dead
code murni, hasil refactor yang tidak tuntas. Ini menggandakan ~548 baris yang membingungkan
dan berisiko di-maintain secara keliru di masa depan.

**Fix:**  
Hapus seluruh blok mulai dari `// ---------------------------------------------------------`
(komentar "Friction Intervention Sheet Component") di baris ~1550 sampai akhir file.
Pastikan `import 'sheets/friction_intervention_sheet.dart';` tetap ada di bagian atas file.

---

### FIX-02 · `_recoveryDays` dipilih user tapi tidak pernah disimpan ke DB

**File:** `app/lib/src/features/dashboard/sheets/friction_intervention_sheet.dart`  
**Baris:** sekitar `_recoveryDays = 3;` dan chip-chip `[3, 5, 7]`

**Diagnosis:**  
User dapat memilih durasi Recovery (3/5/7 hari) lewat `ChoiceChip`, nilai tersimpan di
`_recoveryDays`, tapi `_submitIntervention()` hanya menulis `supportMode: 'Recovery'` ke DB
tanpa menyertakan durasi apapun. UX menjanjikan sesuatu yang tidak terjadi.

**Fix — dua opsi (pilih salah satu):**

*Opsi A (lebih kompleks, UX benar):*  
1. Tambah kolom `DateTimeColumn get recoveryEndDate => dateTime().nullable()();` ke
   tabel `UserProfiles` di `database.dart`.
2. Increment `schemaVersion` ke `6`.
3. Tambah `if (from < 6) { await m.addColumn(userProfiles, userProfiles.recoveryEndDate); }`
   di blok `onUpgrade`.
4. Di `_submitIntervention()`, saat `_selectedReason == 'Kelelahan'`, tulis juga:
   ```dart
   recoveryEndDate: drift.Value(now.add(Duration(days: _recoveryDays))),
   ```

*Opsi B (minimal, hapus kebohongan UX):*  
Hapus state `_recoveryDays`, chip-chip pemilihan durasi, dan keterangan "X Hari" dari UI.
Cukup tampilkan info bahwa mode Recovery aktif tanpa menjanjikan durasi spesifik.

---

### FIX-03 · `_completeOnboarding()` melakukan 3 insert terpisah tanpa transaksi

**File:** `app/lib/src/features/onboarding/onboarding_view.dart`  
**Baris:** sekitar `await db.into(db.userProfiles).insert(profile);`

**Diagnosis:**  
Tiga insert (`userProfiles`, `lifeAudits`, `consentLogs`) dipanggil berurutan tanpa
`db.transaction()`. Jika insert kedua atau ketiga gagal (misal, disk penuh), profil
terbuat setengah-setengah dan state aplikasi menjadi korup.

**Fix:**  
Ganti tiga insert terpisah dengan satu transaksi:

```dart
await db.transaction(() async {
  await db.into(db.userProfiles).insert(profile);
  await db.into(db.lifeAudits).insert(audit);
  await db.into(db.consentLogs).insert(consent);
});
```

---

### FIX-04 · `WellnessPromptTrigger` constants tidak cocok dengan nilai DB yang terdokumentasi

**File A:** `app/lib/src/core/domain/app_constants.dart`  
**File B:** `app/lib/src/data/local_db/database.dart` (kolom `triggerType`)

**Diagnosis:**  
`database.dart` mendokumentasikan nilai `triggerType` sebagai `'Mood_3day'`, `'Mood_Drop'`,
`'Escalation_14day'`. Namun `app_constants.dart` mendefinisikan:
```dart
static const String lowMood = 'Low_Mood_3Days';
static const String safetyCard = 'Safety_Card';
static const String weeklyPulse = 'Weekly_Pulse';
```
Nilai-nilai ini berbeda. Jika kedua sumber digunakan di tempat berbeda, query filter pada
kolom `triggerType` akan gagal secara senyap.

**Fix:**  
Putuskan satu set nilai canonical, lalu sinkronkan keduanya. Rekomendasi: gunakan nilai di
`app_constants.dart` sebagai source-of-truth, update komentar di `database.dart`:
```dart
TextColumn get triggerType => text()();
// Valid values: WellnessPromptTrigger.lowMood, .safetyCard, .weeklyPulse
```

---

## Prioritas P1 — Kualitas & Correctness Tinggi

### FIX-05 · `ColorScheme.background` dan `ColorScheme.onBackground` deprecated (119 tempat)

**File:** Semua file di `app/lib/src/` (terutama `dashboard_view.dart` — 18 tempat)

**Diagnosis:**  
Flutter 3.18+ mendeprekasi `ColorScheme.background` dan `ColorScheme.onBackground`. Di
Material 3, penggantinya adalah `ColorScheme.surface` dan `ColorScheme.onSurface`.

**Fix:**  
Jalankan find-and-replace di seluruh direktori `app/lib/src/`:
- `colorScheme.background` → `colorScheme.surface`
- `colorScheme.onBackground` → `colorScheme.onSurface`
- `theme.colorScheme.onBackground` → `theme.colorScheme.onSurface`

Juga update `ColorScheme.light()` dan `ColorScheme.dark()` di `theme.dart`:
- Hapus argumen `background:` dan `onBackground:` (sudah deprecated).
- Pastikan nilai yang sama diberikan ke argumen `surface:` dan `onSurface:`.

---

### FIX-06 · Font `Inter` dideklarasikan di theme tapi tidak didaftarkan di `pubspec.yaml`

**File A:** `app/lib/src/core/theme/theme.dart` (setiap `fontFamily: 'Inter'`)  
**File B:** `app/pubspec.yaml`

**Diagnosis:**  
`CalmTheme.lightTheme` dan `darkTheme` menggunakan `fontFamily: 'Inter'` di seluruh
`TextTheme`, namun `pubspec.yaml` tidak memiliki deklarasi font sama sekali. Flutter akan
silently fallback ke font sistem, membuat tema tidak konsisten di semua device.

**Fix — dua opsi:**

*Opsi A (tambah font):*  
Download Inter dari Google Fonts atau `google_fonts` package.  
Tambahkan di `pubspec.yaml`:
```yaml
flutter:
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
```

*Opsi B (pakai google_fonts package):*  
Tambah `google_fonts: ^6.2.1` ke dependencies, lalu di `theme.dart`:
```dart
import 'package:google_fonts/google_fonts.dart';
// Di lightTheme:
textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(...)
```
Hapus semua `fontFamily: 'Inter'` manual dari `TextStyle`.

---

### FIX-07 · Formula priority score diduplikasi di 4 tempat

**File A:** `app/lib/src/features/dashboard/dashboard_provider.dart` (2 tempat)  
**File B:** `app/lib/src/features/dashboard/dashboard_view.dart` (2 tempat)

**Diagnosis:**  
Formula `(domainDeficit * impactScore) / (initiationFriction + energyCost)` ditulis ulang
4 kali. Jika formula berubah (misal, menambah faktor `weightedDoneScore`), harus update
4 tempat sekaligus — mudah miss satu.

**Fix:**  
Buat helper function di `app/lib/src/core/domain/app_constants.dart` (atau file baru
`app/lib/src/core/domain/priority_score.dart`):

```dart
/// Computes the Action of the Day priority score for a single habit.
/// Higher score = higher priority.
/// Formula: (domain_deficit × impact_score) / (initiation_friction + energy_cost)
double computeHabitPriorityScore({
  required Habit habit,
  required Map<String, dynamic> domainScores,
}) {
  final domain = habit.domainTag ?? 'Tubuh';
  final rawScore = domainScores[domain] ?? 5;
  final domainScore = (rawScore is num) ? rawScore.toDouble() : 5.0;
  final domainDeficit = 10.0 - domainScore;
  final totalLoad = habit.initiationFriction + habit.energyCost;
  return (domainDeficit * habit.impactScore) / (totalLoad > 0 ? totalLoad : 1);
}
```

Ganti semua 4 implementasi inline dengan pemanggilan fungsi ini.

---

### FIX-08 · `dashboardDataProvider` memuat SEMUA HabitLog ke memory untuk hitung hari kumulatif

**File:** `app/lib/src/features/dashboard/dashboard_provider.dart`  
**Baris:** `final logs = await db.select(db.habitLogs).get();`

**Diagnosis:**  
`db.select(db.habitLogs).get()` mengambil **seluruh** tabel habit_logs ke dalam memori hanya
untuk menghitung jumlah tanggal unik yang statusnya `'Done'`. Untuk pengguna dengan ratusan
habit selama bertahun-tahun, ini O(n) dalam memori dan berpotensi lambat.

**Fix:**  
Ganti dengan query SQL `customSelect`:

```dart
// Di AppDatabase class di database.dart, tambahkan method:
Future<int> countUniqueDoneDates() async {
  final result = await customSelect(
    "SELECT COUNT(DISTINCT date(date / 1000, 'unixepoch')) AS cnt "
    "FROM habit_logs WHERE status = 'Done' AND deleted_at IS NULL",
    readsFrom: {habitLogs},
  ).getSingle();
  return result.read<int>('cnt');
}
```

Lalu di `dashboard_provider.dart`, ganti blok logs/cumulativeDays menjadi:
```dart
final cumulativeDays = overrideDays ?? await db.countUniqueDoneDates();
```

> **Catatan:** Drift menyimpan DateTime sebagai milliseconds sejak epoch. Sesuaikan ekspresi
> `date(date / 1000, 'unixepoch')` jika skema memakai format lain.

---

### FIX-09 · `isDevMode` dideteksi via konten `unlockedSkins` — rawan salah trigger

**File:** `app/lib/src/features/dashboard/dashboard_view.dart` (dan beberapa tempat lain)

**Diagnosis:**  
Dev mode diidentifikasi dengan:
```dart
final isDevMode = profile.unlockedSkins.contains('Sakura') &&
    profile.unlockedSkins.contains('Maple') &&
    profile.unlockedSkins.contains('Bonsai');
```
Pengguna yang membeli semua skin premium secara sah akan secara tidak sengaja mengaktifkan
dev mode. Ini juga hardcode nama skin sebagai sinyal keamanan — sangat rapuh.

**Fix:**  
1. Tambah kolom ke tabel `UserProfiles` di `database.dart`:
   ```dart
   BoolColumn get isDeveloperMode => boolean().withDefault(const Constant(false))();
   ```
2. Increment `schemaVersion` ke `6` (atau sesuaikan jika FIX-02 juga diimplementasi → `7`).
3. Tambah migrasi: `if (from < 6) { await m.addColumn(userProfiles, userProfiles.isDeveloperMode); }`
4. Ganti semua 4-5 lokasi pengecekan `isDevMode` via skin dengan:
   ```dart
   final isDevMode = profile.isDeveloperMode;
   ```
5. Update `_toggleDeveloperMode()` di `dashboard_view.dart` agar hanya menulis kolom baru
   ini (tidak perlu lagi memanipulasi `unlockedSkins` untuk sinyal dev mode).

---

### FIX-10 · Ekspor data tidak menggunakan `share_plus` meski sudah jadi dependency

**File:** `app/lib/src/features/dashboard/dashboard_view.dart`  
**Method:** `_exportDataAsJson()`

**Diagnosis:**  
`share_plus: ^13.2.0` ada di `pubspec.yaml`, namun fungsi ekspor hanya menampilkan JSON
dalam `AlertDialog` dengan `SelectableText`. Pengguna tidak dapat menyimpan file ini. Ini
UX yang frustrating dan fitur yang tidak selesai.

**Fix:**

```dart
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<void> _exportDataAsJson(BuildContext context, WidgetRef ref) async {
  // ... (build jsonString sama seperti sekarang) ...
  
  // Tulis ke file sementara lalu share
  final tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}/lifetree_export_${DateTime.now().millisecondsSinceEpoch}.json');
  await file.writeAsString(jsonString);
  
  await Share.shareXFiles(
    [XFile(file.path, mimeType: 'application/json')],
    subject: 'LifeTree Data Export',
  );
}
```

---

### FIX-11 · Raw string literals digunakan alih-alih konstanta `app_constants.dart`

**File:** `app/lib/src/features/dashboard/dashboard_provider.dart`,  
         `app/lib/src/features/habit/services/habit_log_service.dart`

**Diagnosis:**  
`app_constants.dart` mendefinisikan `HabitStatus.done = 'Done'`, `HabitStatus.active = 'Active'`,
`Season.recovery = 'Recovery'`, dll. Namun file-file kunci masih menggunakan raw string literal:
`'Done'`, `'Missed'`, `'Active'`, `'Recovery'`, `'Growth'`, `'Dormant'`, `'Daily'`.

**Fix:**  
Di `dashboard_provider.dart` dan `habit_log_service.dart`, tambahkan import:
```dart
import '../../core/domain/app_constants.dart';
```
Kemudian ganti setiap raw string dengan konstanta:
- `'Done'` → `HabitStatus.done`
- `'Missed'` → `HabitStatus.missed`
- `'Active'` → `HabitStatus.active`
- `'Recovery'` (season) → `Season.recovery`
- `'Growth'` → `Season.growth`
- `'Dormant'` → `Season.dormant`
- `'Daily'` → `HabitFrequency.daily`

---

### FIX-12 · `pubspec.yaml` masih menggunakan deskripsi template Flutter

**File:** `app/pubspec.yaml`

**Diagnosis:**  
`description: "A new Flutter project."` adalah teks boilerplate yang tidak mendeskripsikan
aplikasi sama sekali.

**Fix:**  
```yaml
description: "LifeTree — Personal OS untuk orientasi diri berbasis kebiasaan (habit tracker) dengan pohon kehidupan sebagai metafora pertumbuhan."
```

---

## Prioritas P2 — Arsitektur & Technical Debt

### FIX-13 · Tidak ada CI Pipeline (GitHub Actions)

**File yang harus dibuat:** `.github/workflows/ci.yml` (di root repo, bukan di `app/`)

**Diagnosis:**  
Tidak ada direktori `.github/` sama sekali. Tanpa CI, PR bisa masuk dengan kode yang gagal
`flutter analyze` atau `flutter test` tanpa terdeteksi.

**Fix:**  
Buat file `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: app

    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.32.x'
          channel: 'stable'
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Run code generation (drift)
        run: dart run build_runner build --delete-conflicting-outputs

      - name: Analyze
        run: flutter analyze --fatal-infos

      - name: Test
        run: flutter test
```

---

### FIX-14 · `onUpgrade` tidak menambahkan performance indexes untuk pengguna lama

**File:** `app/lib/src/data/local_db/database.dart`  
**Method:** `MigrationStrategy.onUpgrade`

**Diagnosis:**  
Semua `CREATE INDEX` hanya ada di `onCreate`. Pengguna yang mengupgrade dari v1 ke v5 mendapat
tabel dan kolom baru, tapi **tidak mendapat** index `idx_habit_log_perf`, `idx_journal_entry_wellness`,
dll. Ini menyebabkan query lambat tanpa ada pesan error.

**Fix:**  
Tambahkan block baru di `onUpgrade`:
```dart
if (from < 6) { // atau versi berikutnya setelah FIX-09
  // Tambahkan indexes jika belum ada (idempotent karena IF NOT EXISTS)
  await customStatement('CREATE INDEX IF NOT EXISTS idx_habit_log_perf ON habit_logs (habit_id, date, status);');
  await customStatement('CREATE INDEX IF NOT EXISTS idx_habit_log_desc ON habit_logs (habit_id, date DESC);');
  await customStatement('CREATE INDEX IF NOT EXISTS idx_journal_entry_wellness ON journal_entries (user_id, date, mood_score);');
  await customStatement('CREATE INDEX IF NOT EXISTS idx_habit_active ON habits (user_id, status, domain_tag);');
  await customStatement('CREATE INDEX IF NOT EXISTS idx_weekly_pulse_ttl ON weekly_pulses (user_id, domain_tag, week_start_date DESC);');
  await customStatement('CREATE INDEX IF NOT EXISTS idx_decision_review ON decision_entries (user_id, review_date, is_reviewed);');
}
```

---

### FIX-15 · `HabitLogService.markUnchecked()` melakukan hard delete, tidak konsisten dengan soft-delete pattern

**File:** `app/lib/src/features/habit/services/habit_log_service.dart`  
**Method:** `markUnchecked()`

**Diagnosis:**  
Tabel `HabitLogs` memiliki kolom `deletedAt` untuk soft-delete. Namun `markUnchecked()`
melakukan:
```dart
await (_db.delete(_db.habitLogs)..where((tbl) => tbl.logId.equals(log.logId))).go();
```
Ini menghancurkan data audit secara permanen. Tidak konsisten dengan habit records lain yang
menggunakan soft-delete.

**Fix:**  
Ganti hard delete dengan soft delete:
```dart
Future<void> markUnchecked({required Habit habit, required HabitLog log}) async {
  final now = DateTime.now();
  await (_db.update(_db.habitLogs)..where((tbl) => tbl.logId.equals(log.logId)))
      .write(HabitLogsCompanion(deletedAt: drift.Value(now)));

  final newCount = (habit.lifetimeDoneCount - 1).clamp(0, 99999);
  await (_db.update(_db.habits)..where((tbl) => tbl.habitId.equals(habit.habitId)))
      .write(HabitsCompanion(lifetimeDoneCount: drift.Value(newCount)));
}
```

Juga pastikan semua query yang membaca `HabitLogs` sudah menyaring `deletedAt.isNull()`.

---

### FIX-16 · `MockMarketplaceService` — uploads hilang saat app restart

**File:** `app/lib/src/features/marketplace/marketplace_service.dart`

**Diagnosis:**  
`MockMarketplaceService._templates` adalah list dalam memori. Upload baru via `uploadTemplate()`
ditambahkan ke list ini, tapi karena `marketplaceServiceProvider` membuat instance baru setiap
kali (Provider bukan Singleton), data hilang saat app restart atau provider didispose.
Ini membuat fitur upload sama sekali tidak berfungsi secara persisten.

**Fix (jangka pendek):**  
Tambahkan komentar eksplisit di dekat provider:
```dart
// TODO: MockMarketplaceService hanya menyimpan data di memori (volatile).
// Implementasikan RemoteMarketplaceService menggunakan Supabase/Firebase
// atau LocalMarketplaceService menggunakan drift untuk persisten data.
final marketplaceServiceProvider = Provider<MarketplaceService>((ref) {
  return MockMarketplaceService(); // MOCK ONLY — not production-ready
});
```

**Fix (jangka panjang):**  
Buat `LocalMarketplaceService implements MarketplaceService` yang menyimpan template
ke tabel Drift baru `PublicTemplates`, atau integrasikan API backend sesungguhnya.

---

### FIX-17 · `DashboardView` adalah god widget — 2105 baris dalam satu file

**File:** `app/lib/src/features/dashboard/dashboard_view.dart`

**Diagnosis:**  
File ini menggabungkan: settings management, theme management, dev tools, skin shop,
export/reset, radar chart business logic, habit list rendering, core values dialog, dan
life compass widget — semuanya dalam satu `ConsumerStatefulWidget`.

**Fix (bisa dilakukan bertahap):**

Ekstrak ke file/widget terpisah:

| Blok yang akan diekstrak | File tujuan |
|---|---|
| `_showExportMenu`, `_exportDataAsJson`, `_resetApplication` | `features/settings/settings_bottom_sheet.dart` |
| `_toggleDeveloperMode`, `_updateThemeMode`, dev sliders | Masuk ke `settings_bottom_sheet.dart` |
| `_showCoreValuesDialog`, `_buildLifeCompassWidget` | `features/profile/core_values_dialog.dart` |
| `_buildDomainScoresCard` | `features/dashboard/widgets/domain_scores_card.dart` |
| `_buildRadarChartCard` (termasuk score blending logic) | Pindahkan score blending ke `dashboard_provider.dart` atau service terpisah |
| `_TreeSkinShopBottomSheet` | `features/marketplace/skin_shop_bottom_sheet.dart` |

Setiap ekstraksi tidak mengubah behaviour, hanya memindahkan kode ke unit yang lebih kecil
dan bisa di-test secara independen.

---

### FIX-18 · `database.g.dart` tidak ada di `.gitignore`

**File:** `app/.gitignore`

**Diagnosis:**  
File generated `database.g.dart` tidak masuk `.gitignore`. Secara konvensi, generated files
tidak di-commit karena bisa di-regenerasi via `dart run build_runner build`. Jika ada
perubahan di `database.dart`, `database.g.dart` versi lama di repo bisa menyebabkan konflik
merge.

**Fix:**  
Tambahkan ke `app/.gitignore`:
```
# Drift generated files
**/*.g.dart
```

> **Catatan:** Jika memutuskan untuk commit `*.g.dart` (agar fresh clone tidak perlu
> menjalankan build_runner), tambahkan dokumentasi di `app/README.md` menjelaskan keputusan
> ini, dan update CI (FIX-13) untuk tidak menjalankan `build_runner` sebelum test.

---

### FIX-19 · Dev tools selalu dikompilasi ke build release

**File:** `app/lib/src/features/dashboard/dashboard_provider.dart`  
**File:** `app/lib/src/features/dashboard/dashboard_view.dart` (dev panels)

**Diagnosis:**  
`devTimeOfDayOverrideProvider`, `devCumulativeDaysOverrideProvider`, `DevAgePlayNotifier`,
`DevTimePlayNotifier` selalu ada di production build. Ini menambah binary size dan
merupakan risiko jika ada celah yang memungkinkan user mengaktifkannya.

**Fix:**  
Wrap semua provider dan widget dev dengan guard `kDebugMode`:

```dart
import 'package:flutter/foundation.dart' show kDebugMode;

// Di provider:
final devTimeOfDayOverrideProvider = kDebugMode
    ? StateProvider<CelestialTime>((ref) => CelestialTime.auto)
    : null; // atau gunakan conditional import
```

Alternatif yang lebih bersih: gunakan [conditional imports](https://dart.dev/guides/libraries/create-library-packages#conditionally-importing-and-exporting-library-files)
dengan file stub untuk production.

---

### FIX-20 · `app/README.md` masih template Flutter bawaan

**File:** `app/README.md`

**Diagnosis:**  
Isinya adalah README template default Flutter ("A few resources to get you started...").
Developer yang pertama kali clone repo tidak mendapat informasi tentang cara setup, run,
atau test aplikasi.

**Fix:**  
Tulis ulang `app/README.md` dengan konten minimal:

```markdown
# LifeTree — Flutter App

## Setup
1. Install Flutter SDK (versi sesuai `pubspec.yaml` → `sdk: ^3.12.2`)
2. `flutter pub get`
3. `dart run build_runner build --delete-conflicting-outputs` (generate Drift DAO)
4. `flutter run`

## Menjalankan Tests
flutter test

## Struktur
app/lib/src/
├── core/          # Routing, theme, providers, constants
├── data/          # Drift database schema & generated code
└── features/      # Fitur per domain (dashboard, habit, journal, dll)

## Platform yang Didukung
Android, iOS, Windows (lihat `pubspec.yaml` untuk dependencies)
```

---

## Ringkasan — Urutan Eksekusi yang Direkomendasikan

| Order | Fix ID | Tingkat Risiko | Catatan |
|-------|--------|---------------|---------|
| 1 | FIX-01 | Rendah | Hapus dead code, tidak ada perubahan behavior |
| 2 | FIX-03 | Rendah | Wrap onboarding dalam transaksi |
| 3 | FIX-04 | Rendah | Sinkronkan konstanta WellnessPromptTrigger |
| 4 | FIX-11 | Rendah | Ganti raw strings dengan konstanta |
| 5 | FIX-12 | Rendah | Update deskripsi pubspec |
| 6 | FIX-20 | Rendah | Tulis README app |
| 7 | FIX-05 | Sedang | Ganti deprecated colorScheme (119 tempat, gunakan find-replace) |
| 8 | FIX-07 | Sedang | Ekstrak formula priority score |
| 9 | FIX-10 | Sedang | Implementasi share_plus di export |
| 10 | FIX-15 | Sedang | Ubah markUnchecked ke soft delete |
| 11 | FIX-13 | Sedang | Tambah GitHub Actions CI |
| 12 | FIX-06 | Sedang | Daftarkan font Inter atau switch ke google_fonts |
| 13 | FIX-02 | Tinggi | Fix recoveryDays (butuh schema migration) |
| 14 | FIX-09 | Tinggi | Fix isDevMode detection (butuh schema migration) |
| 15 | FIX-14 | Sedang | Tambah index di onUpgrade (digabung dengan migrasi di atas) |
| 16 | FIX-08 | Sedang | Optimasi query cumulativeDays |
| 17 | FIX-18 | Rendah | Update .gitignore untuk *.g.dart |
| 18 | FIX-17 | Tinggi | Refactor DashboardView (bisa bertahap) |
| 19 | FIX-16 | Tinggi | Implementasi marketplace yang persisten |
| 20 | FIX-19 | Sedang | Guard dev tools dengan kDebugMode |

---

*Generated via full codebase review — `app/lib/src/` (Flutter/Dart), `app/pubspec.yaml`,  
`app/.gitignore`, `app/test/`, `app/lib/src/data/local_db/database.dart`.*
