# 🌳 LifeTree — Personal OS untuk Orientasi Diri

> **Versi 14.0 (Master Product & System Spec)** — Daily Orientation Loop, Privacy Roadmap, Arsitektur Sistem, Kepatuhan, Strategi Bisnis & Setup Flutter

LifeTree adalah **Personal OS (Sistem Orientasi Diri)** offline-first yang menjembatani kesejajaran antara aplikasi produktivitas konvensional (yang seringkali memicu rasa bersalah lewat hukuman *streak*) dengan aplikasi kesehatan mental yang terlalu medis/klinis. Dibangun di atas filosofi **Anti-Guilt**, kegagalan di dalam LifeTree dikonversi menjadi data refleksi adaptif untuk memulihkan ritme harian pengguna secara tenang.

---

## 🗺️ Peta Induk Dokumentasi (Documentation Hub)

Untuk menjaga kebersihan repositori dan menghindari redundansi data, seluruh detail normatif per domain ditempatkan pada dokumen khusus di folder `docs/`. README ini berfungsi sebagai peta induk:

*   **[00_master_blueprint.md](docs/00_master_blueprint.md)**: Rencana induk produk, arsitektur visual pohon (vitality states), detail season (Dormant, Winter/Rest, Spring), dan matrix scope MVP.
*   **[01_research_and_compliance.md](docs/01_research_and_compliance.md)**: Landasan empiris behavioral science (Lally et al. 66 hari, Fogg Behavior Model), analisis legal perlindungan anak (PP TUNAS/PP 17/2025, Permenkomdigi 9/2026, COPPA), disclaimer kesehatan mental, dan Passive Wellness protocol.
*   **[02_business_strategy.md](docs/02_business_strategy.md)**: Analisis pasar, strategi monetisasi (tier subscription gratis vs premium), kalkulasi LTV/CAC, cohort analysis, dan strategi Community-Led Growth (CLG).
*   **[03_product_requirements_prd.md](docs/03_product_requirements_prd.md)**: Product Requirements Document (PRD) yang merinci alur Onboarding (legal disclaimer check), modul Thinking Canvas (21+ metode berpikir kognitif), Habit Scheduling (Daily/Custom), dan Friction Journal.
*   **[04_technical_specifications.md](docs/04_technical_specifications.md)**: Spesifikasi teknis backend lokal, schema database Drift SQLite (UserProfiles, Habits, HabitLogs, dll), spesifikasi index database, format sinkronisasi zero-knowledge, dan protokol kriptografi E2EE (X25519, AES-GCM).
*   **[05_implementation_status.md](docs/05_implementation_status.md)**: Laporan status fungsionalitas dan checklist audit dari pengerjaan codebase aplikasi Flutter.
*   **[metode-berpikir-diatas-kertas.md](docs/metode-berpikir-diatas-kertas.md)**: Panduan praktis, ilustrasi layout visual coretan kertas, dan rationale kognitif untuk masing-masing 21+ metode berpikir yang didukung oleh Thinking Canvas.

---

## 🚀 Setup Project Flutter

Aplikasi mobile/desktop LifeTree dibangun menggunakan Flutter (SDK 3.27+ kompatibel).

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

**© 2025 Fajar Kurnia — LifeTree Personal OS**
