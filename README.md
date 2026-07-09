# 道基 Daoji — Personal OS untuk Orientasi Diri

> **Versi 14.0 (Master Product & System Spec)** — Daily Orientation Loop, Privacy Roadmap, Arsitektur Sistem, Kepatuhan, Strategi Bisnis & Setup Flutter

Daoji adalah **Personal OS (Sistem Orientasi Diri)** offline-first yang menjembatani kesejajaran antara aplikasi produktivitas konvensional (yang seringkali memicu rasa bersalah lewat hukuman _streak_) dengan aplikasi kesehatan mental yang terlalu medis/klinis. Dibangun di atas filosofi **Anti-Guilt**, kegagalan di dalam Daoji dikonversi menjadi data refleksi adaptif untuk memulihkan ritme harian pengguna secara tenang.

---

## 🗺️ Peta Induk Dokumentasi (Documentation Hub)

Untuk menjaga kebersihan repositori dan menghindari redundansi data, seluruh detail normatif per domain ditempatkan pada dokumen khusus di folder `docs/`. README ini berfungsi sebagai peta induk:

- **[01_PRODUCT_BLUEPRINT.md](docs/01_PRODUCT_BLUEPRINT.md)**: Rencana induk produk, arsitektur visual pohon (vitality states), detail season (Dormant, Winter/Rest, Spring), dan matrix scope MVP.
- **[02_PRODUCT_REQUIREMENTS.md](docs/02_PRODUCT_REQUIREMENTS.md)**: Landasan empiris behavioral science (Lally et al. 66 hari, Fogg Behavior Model), analisis legal perlindungan anak (PP TUNAS/PP 17/2025, Permenkomdigi 9/2026, COPPA), disclaimer kesehatan mental, dan Passive Wellness protocol.
- **[03_TECH_ARCHITECTURE.md](docs/03_TECH_ARCHITECTURE.md)**: Arsitektur teknologi, spesifikasi teknis backend lokal, schema database Drift SQLite (UserProfiles, Habits, HabitLogs, dll), spesifikasi index database, format sinkronisasi zero-knowledge, dan protokol kriptografi E2EE (X25519, AES-GCM).
- **[04_ROADMAP_AND_STATUS.md](docs/04_ROADMAP_AND_STATUS.md)**: Laporan status fungsionalitas, roadmap rilis, dan checklist audit dari pengerjaan codebase aplikasi Flutter.
- **[05_RESEARCH_GOVERNANCE.md](docs/05_RESEARCH_GOVERNANCE.md)**: Tata kelola riset, metodologi, dan regulasi terkait.
- **[06_LANGUAGE_LEVEL_COPY_PLAN.md](docs/06_LANGUAGE_LEVEL_COPY_PLAN.md)**: Rencana penulisan salinan (copywriting plan) tingkat bahasa UI.
- **[07_UI_CODE_LANGUAGE_AUDIT.md](docs/07_UI_CODE_LANGUAGE_AUDIT.md)**: Laporan audit bahasa kode antarmuka pengguna (UI).

*Catatan: Dokumen spesifikasi lama telah diarsipkan ke folder [docs/arsip/](docs/arsip/) sebagai bagian dari riwayat revisi proyek.*

---

## 🚀 Setup Project Flutter

Aplikasi mobile/desktop Daoji dibangun menggunakan Flutter (SDK 3.27+ kompatibel).

### Prasyarat (Prerequisites)

1. **Flutter SDK:** Hubungkan ke flutter channel stable terbaru (`flutter --version`).
2. **Dart SDK:** Kompatibel dengan null safety.
3. **SQLite3 Library:** Lokal pada target OS.

### Instalasi & Menjalankan Aplikasi

Buka folder `app/` di terminal, lalu jalankan perintah berikut:

```bash
# Mengunduh dependensi package pub
flutter pub get

# Menjalankan Drift code generator (build_runner)
dart run build_runner build --delete-conflicting-outputs

# Menjalankan aplikasi pada emulator atau perangkat fisik
flutter run
```

### Pengujian & Analisis Kode

Untuk memverifikasi kebersihan kode dan keandalan fungsionalitas:

```bash
# Analisis linter statis (0 issues / warnings)
flutter analyze

# Menjalankan seluruh unit & widget test suite
flutter test
```

---

**© 2025 Fajar Kurnia — Daoji Personal OS**
