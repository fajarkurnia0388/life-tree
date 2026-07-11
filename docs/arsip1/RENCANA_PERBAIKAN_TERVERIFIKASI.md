# Rencana Perbaikan Terverifikasi — Daoji / Life Tree

**Baseline:** `e0612ca86c9440012101d13aeeaa274fa4b855ea`  
**Toolchain:** Flutter 3.44.6, Dart 3.12.2, Drift 2.34.x  
**Prinsip:** dahulukan integritas data, privacy, dan release correctness sebelum refactor visual.

## Sasaran paket perbaikan

Paket ini menerapkan perbaikan yang dapat diverifikasi dengan analyzer/test dan aman dipindahkan melalui copy-replace. File ZIP akhir hanya memuat file baru/berubah dengan path project aslinya.

## Tahap A — integritas data dan release blocker

- [x] Membuat migrasi database idempotent untuk jalur upgrade lintas versi.
- [x] Menambah regression test migrasi v3 → schema terkini.
- [x] Memperbaiki `countUniqueDoneDates` agar memakai Unix seconds Drift dengan benar.
- [x] Membuat reset seluruh data lengkap dan transactional.
- [x] Membuat ekspor data benar-benar mencakup seluruh data milik pengguna.
- [x] Membersihkan file ekspor sementara setelah share selesai.
- [x] Memperbarui CI ke Flutter/Dart yang kompatibel dan mengaktifkan analyze/test/coverage gate.
- [ ] Mengaktifkan project-wide format gate setelah baseline 112 file lama diformat dalam PR terpisah.
- [x] Menghapus debug signing dari Android release.

## Tahap B — notification, transaksi, dan query correctness

- [x] Menginisialisasi timezone notification secara eksplisit.
- [x] Menjadwalkan reminder berdasarkan hari habit, bukan selalu harian.
- [x] Menerapkan quiet hours.
- [x] Mengganti ID notification berbasis `hashCode` dengan ID deterministik.
- [x] Membungkus multi-write Habit, Weekly Pulse, Value Compass, dan Thinking Canvas dalam transaction.
- [x] Menyeragamkan filter `userId` dan `deletedAt` pada query history/dashboard/journal.
- [x] Memperbaiki query Weekly Pulse agar selalu scoped ke `WHO-5`.

## Tahap C — privacy dan product truth

- [x] Mencegah database sensitif masuk Android cloud/device backup.
- [x] Mengubah copy marketplace agar jujur sebagai koleksi lokal/demo.
- [x] Memastikan akses hotline tidak bergantung pada keberhasilan telemetry DB.
- [x] Menyimpan identitas kanal hotline pada log lokal tanpa menyimpan isi percakapan.
- [x] Menghapus dependency SQLite Flutter yang sudah EOL bila native assets `sqlite3` mencukupi.

## Tahap D — kualitas dan maintainability

- [x] Membersihkan seluruh issue analyzer pada baseline.
- [x] Memformat hanya file yang benar-benar disentuh.
- [x] Memperbaiki adapter `_DualPalaceMap` agar read-only contract aman.
- [x] Memisahkan registry workspace Thinking Canvas dari view utama.
- [x] Menambah regression test untuk bug yang diperbaiki.
- [x] Menaikkan kualitas smoke test tanpa mengandalkan generated code sebagai coverage aplikasi.

## Tahap E — landing/deployment

- [x] Memperbaiki canonical/Open Graph URL untuk GitHub Pages project path.
- [x] Menambahkan favicon, touch icon, manifest, dan Open Graph image yang hilang.
- [x] Menghapus script Cloudflare challenge yang tidak berlaku dan 404.
- [x] Memisahkan CSS/JavaScript dari HTML monolitik.
- [x] Menambahkan service worker sederhana dan memperbaiki ARIA misuse.

## Verifikasi wajib

1. `dart run build_runner build`
2. `dart format --output=none --set-exit-if-changed` pada file Dart yang disentuh
3. `flutter analyze --fatal-infos`
4. `flutter test`
5. regression test migrasi, cumulative-day, reset/export, notification schedule
6. `node --check` untuk JavaScript landing
7. validasi seluruh file lokal yang direferensikan landing
8. memastikan ZIP hanya berisi file baru/berubah dengan struktur path yang benar

## Kriteria selesai

- Tidak ada compile/analyzer issue.
- Seluruh test lama dan test baru lulus.
- Tidak ada data user tersisa setelah reset.
- Dua tanggal completion berbeda dihitung sebagai dua hari.
- Upgrade database historis yang diuji tidak gagal akibat duplicate column.
- Reminder menghormati timezone, weekday, dan quiet hours.
- CI menggunakan SDK yang memenuhi `pubspec.yaml`.
- Android release tidak menggunakan debug key.
- Landing tidak mereferensikan asset lokal yang hilang.
- Arsip patch dapat diekstrak di root repository untuk melakukan copy-replace.


## Status implementasi

Paket perbaikan ini telah diverifikasi terhadap baseline commit yang tercantum di atas:

- `flutter analyze --fatal-infos`: **0 issue**
- `flutter test --coverage`: **131/131 test lulus**
- raw coverage: **22,69%**
- app-owned coverage tanpa generated `*.g.dart`: **20,17%**
- JavaScript landing dan service worker: syntax check lulus
- manifest JSON dan XML Android: parse check lulus
- seluruh asset lokal yang direferensikan landing: tersedia

## Pekerjaan yang sengaja ditunda

Item berikut tidak dipaksakan ke patch ini karena memerlukan keputusan produk,
credential, atau pengujian device native yang tidak tersedia di environment audit:

1. **SQLCipher/encryption at rest.** Patch sudah mematikan backup database sensitif,
   tetapi migrasi database plaintext ke encrypted database memerlukan desain key
   lifecycle, Android Keystore/iOS Keychain, recovery policy, dan device test.
2. **Schema v16 untuk memisahkan metadata WHO-5.** Existing migration v1–v15 telah
   dibuat idempotent dan dites; perubahan schema baru sebaiknya menjadi release
   terpisah dengan snapshot Drift lengkap.
3. **Refactor visual besar `tree_display_widget.dart` dan `growth_map_widget.dart`.**
   Perubahan ini tidak diperlukan untuk memperbaiki bug data dan berisiko visual
   regression tanpa golden/device test.
4. **Migrasi seluruh copy ke ARB/gen-l10n.** Locale Indonesia dan Flutter
   localization delegates sudah dipasang, tetapi vocabulary registry belum
   dipindahkan seluruhnya ke ARB.
5. **Native Android/iOS release build.** Android SDK, emulator, dan Xcode tidak
   tersedia di environment ini; CI telah diperbarui agar validasi dapat dilanjutkan.
6. **Project-wide formatting.** Hanya file yang benar-benar diubah yang diformat,
   agar patch copy-replace tidak berisi 112 file kosmetik yang tidak relevan.

Tool lama `dart run tool/check_daoji_keys.dart` masih terkena crash compiler/native
hook Dart 3.12 pada package graph SQLite. Pemeriksaan ekuivalennya tetap dijalankan
oleh `test/daoji_text_key_completeness_test.dart` dan lulus dalam suite 131 test.
