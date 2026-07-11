# Catatan Penerapan Patch Life Tree

**Baseline:** `e0612ca86c9440012101d13aeeaa274fa4b855ea`  
**Arsip:** dibuat hanya dari file baru/berubah, bukan seluruh repository.

## Cara menerapkan

1. Backup project lokal Anda.
2. Extract ZIP di **root repository `life-tree/`**, yaitu folder yang berisi
   `index.html`, folder `app/`, dan folder `.github/`.
3. Izinkan overwrite/replace file yang sudah ada.
4. Masuk ke Flutter project dan regenerate source Drift:

```bash
cd app
flutter clean
flutter pub get
dart run build_runner build
flutter analyze --fatal-infos
flutter test
```

Struktur di dalam ZIP dipertahankan persis, misalnya:

```text
app/lib/src/features/thinking_canvas/thinking_canvas_lite_view.dart
app/lib/src/features/thinking_canvas/workspace_registry.dart
app/test/database_migration_test.dart
.github/workflows/ci.yml
```

Jadi file `thinking_canvas_lite_view.dart` akan jatuh langsung ke folder yang
benar ketika ZIP diekstrak dari root repository.

## File yang perlu dihapus

**Tidak ada file source yang wajib dihapus secara manual.**

`sqlite3_flutter_libs` dihapus dari dependency melalui `pubspec.yaml` dan
`pubspec.lock`; package cache lama boleh dibersihkan oleh `flutter clean`.

`database.g.dart` tidak dimasukkan ke ZIP karena project memang mengabaikan
`*.g.dart`. File tersebut wajib dibuat ulang dengan build runner setelah patch
diterapkan.

## Android release signing

Release tidak lagi memakai debug key. Salin template berikut:

```bash
cp app/android/key.properties.example app/android/key.properties
```

Kemudian isi path dan credential upload keystore yang sebenarnya. File
`key.properties` dan keystore tetap diabaikan Git dan tidak boleh dimasukkan ke
repository. Tanpa file tersebut, release build dibiarkan unsigned—lebih aman
daripada diam-diam memakai debug key.

## Perubahan dependency

- `sqlite3_flutter_libs` EOL dihapus.
- `flutter_localizations` dari Flutter SDK ditambahkan.
- `intl` diselaraskan ke versi yang dipin Flutter SDK.
- `sqlite3` dicantumkan sebagai dev dependency untuk migration fixture tests.

## Hasil verifikasi

- Flutter 3.44.6 / Dart 3.12.2
- `flutter analyze --fatal-infos`: **0 issue**
- `flutter test --coverage`: **131/131 lulus**
- Raw coverage: **22,69%**
- App-owned coverage tanpa generated code: **20,17%**
- Migrasi fixture v3→v15: lulus
- Migrasi marketplace legacy v10→v15: lulus
- Cumulative-day regression: lulus
- Reset/export completeness regression: lulus
- Notification timezone/weekday/quiet-hours tests: lulus
- Landing JS/service worker syntax: lulus
- Manifest JSON/XML dan referensi asset landing: lulus

## Batas verifikasi

Environment audit tidak memiliki Android SDK/emulator dan Xcode, sehingga native
release build serta migrasi ke database terenkripsi harus diuji di CI/device.
Detail pekerjaan yang sengaja ditunda tercantum dalam
`RENCANA_PERBAIKAN_TERVERIFIKASI.md`.

Tool standalone lama `dart run tool/check_daoji_keys.dart` masih terkena crash
compiler/native-hook Dart pada package graph SQLite. Pemeriksaan key ekuivalen
sudah tercakup oleh `test/daoji_text_key_completeness_test.dart` dan lulus.
