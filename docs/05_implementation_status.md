# Status Implementasi Aplikasi LifeTree

Laporan ini menyajikan status pencapaian pengembangan aplikasi **LifeTree** (Personal Life OS) hingga saat ini, membandingkan realisasi fitur dengan rancangan master blueprint, serta memetakan sisa backlog pekerjaan.

---

## 1. Ringkasan Status Proyek
*   **Tanggal Pembaruan:** 27 Juni 2026
*   **Target Platform:** Windows Desktop, Android, iOS (Cross-Platform)
*   **Penyimpanan Data:** Offline-First (SQLite Local Database via Drift Generator)
*   **Versi Skema Database Saat Ini:** `5` (Mendukung target goals, kustomisasi review period, dan kompas hidup)
*   **Status Analisis & Tes:** 
*   `flutter analyze` $\to$ **Lolos 100%** (Bersih dari error visual/pemrograman)
*   `flutter test` $\to$ **Lolos 100%** (Widget smoke test & Unit tests passed)

---

## 2. Matriks Kelayakan Fitur (Feature Coverage Matrix)

Berikut adalah status detil pemenuhan fitur berdasarkan pembagian lapis arsitektur LifeTree:

### 🌱 Lapis 0: Akar (Refleksi Adaptif & Diagnosis)
*   **Onboarding & Life Audit:** **[SELESAI]** Kuesioner pemetaan domain awal pengguna, persetujuan T&C/Disclaimer, dan pencatatan Consent Log lokal.
*   **Journal Lite:** **[SELESAI]** Pencatatan suasana hati harian (1-5 emoji) beserta 1 kata kunci pencarian. Memiliki detektor mood rendah berturut-turut (3 hari) yang memicu dialog bantuan. **Mendukung pre-filling data hari ini secara otomatis** jika form dibuka kembali.
*   **Deep Reflection (Refleksi Mendalam):** **[SELESAI]** Sakelar ekspansi formulir di dalam halaman jurnal berisi 3 pertanyaan kualitatif dan **Gratitude Suggestion Chips** (Keluarga, Makanan Enak, Kesehatan, dll.) untuk pengisian instan.
*   **Thinking Canvas Lite:** **[SELESAI]** Manajemen sesi corat-coret kertas (PMI, Mind Dump, Reverse Brainstorming) terintegrasi dengan **Pemandu Tur Interaktif 4 Langkah** dan AppBar Help Button. **Mendukung pemilihan domain tag** saat menyimpan aksi kecil ke daftar kebiasaan.
*   **Weekly Pulse (WHO-5 Check-In):** **[SELESAI]** Survei indeks kesejahteraan mental 5 pertanyaan WHO-5 yang otomatis aktif setiap hari Minggu (atau via tombol uji coba pengembang). **Mencegah duplikasi data** dengan mengupdate entri jika sudah diisi di minggu yang sama.
*   **Safety Card (Papan Darurat):** **[SELESAI]** Hotline darurat kesehatan mental terintegrasi panggilan instan via **panggilan dialer asli telepon (url_launcher)** ke nomor 119 dengan **rotasi dinamis warna border aksen (harian/day-based)** untuk mencegah visual habituasi (*banner blindness*).

### 🪵 Lapis 1: Batang (Beban & Goal Hierarchy)
*   **Canopy Load System:** **[SELESAI]** Kapasitas pembatasan beban harian (10 poin) dengan sistem peringatan halus (*soft warning*) jika kebiasaan yang dibuat berlebih.
*   **Goal Hierarchy Tagging:** **[SELESAI]** Menghubungkan kebiasaan harian dengan target/goals jangka panjang secara visual pada dasbor (kolom `goalTag` di SQLite).
*   **Friction Intervention & MVA:** **[SELESAI]** Intervensi pop-up empatik saat kebiasaan terlewat. Menyediakan opsi pengurangan waktu instan (*MVA duration override*) dan perpindahan musim ke *Recovery Mode* (musim bersalju).
*   **Automaticity Decay:** **[BACKLOG]** Algoritma peluruhan bobot otomatis kebiasaan berdasarkan aktivitas 90 hari terakhir (Formula UCL Lally-based).

### 🌿 Lapis 2: Cabang (6 Domain Kehidupan)
*   **6 Domain Kehidupan Aktif:** **[SELESAI]** Form pembuatan kebiasaan mendukung pemilihan 6 bidang kehidupan (Tubuh, Keuangan, Hubungan, Emosi, Karir, Rekreasi).
*   **Radar Chart Keseimbangan:** **[SELESAI]** Diagram radar kustom hexagon di dasbor utama yang merender keseimbangan secara dinamis berdasarkan formula **blended score (70% audit baseline + 30% rasio harian)** untuk menghindari fluktuasi visual yang terlalu ekstrem.

### 🍎 Lapis 3: Buah & Kompas (Advanced OS)
*   **Life Compass (Nilai Inti):** **[SELESAI]** Manajemen 3 nilai inti pembimbing hidup (Core Values) terintegrasi dengan **Preset Chips Nilai Populer** (Kesehatan, Kebebasan, Disiplin, dll.) dan visualisasi kartu lencana di atas dasbor utama.
*   **Decision Journal (Jurnal Keputusan):** **[SELESAI]** Pencatatan pilihan sulit (A vs B), data keyakinan awal (asumsi kognitif), ekspektasi hasil, **Kustomisasi Jangka Waktu Review (7 Hari, 30 Hari, atau 90 Hari)**, serta lembar peninjauan refleksi bias keputusan.
*   **Overdue Decision Alert:** **[SELESAI]** Papan peringatan kartu darurat di dasbor jika ada jurnal keputusan yang sudah jatuh tempo untuk dievaluasi.

### 🛒 Ekosistem, Monetisasi & Developer Mode
*   **Habit Template Marketplace:** **[SELESAI]** Jelajah template kebiasaan publik (pencarian teks, filter per domain, sortir terpopuler/rating/terbaru), kloning instan ke SQLite lokal, sistem rating bintang 1-5, dan pengunggahan template pribadi menggunakan Nama Pena (*Pen Name*).
*   **Tree Skin Shop (Paid Cosmetics):** **[SELESAI]** Pembelian skin premium (Sakura Jepang 🌸, Golden Maple 🍁, Bonsai Zen 🪴) dengan integrasi gerbang pembayaran simulasi (GPay, Virtual Account, QRIS) yang merubah seluruh emoji visual pertumbuhan pohon di dasbor secara dinamis.
*   **Developer Mode Toggle:** **[SELESAI]** Sakelar di sheet Pengaturan untuk secara instan mengunci/membuka kunci kosmetik skin premium guna pengujian alur beli.

### ⚙️ Utilitas & Keamanan
*   **Mode Tema (Light & Dark Theme Switcher):** **[SELESAI]** Dukungan tema terang Krem Hangat-Sage Green dan tema gelap Charcoal terintegrasi preferensi SQLite.
*   **JSON Exporter & App Reset:** **[SELESAI]** Pencadangan data lokal ke format `.json` dan penghapusan database aman (*Purge Database*) untuk mengulang pengujian onboarding.
*   **AXTree Debug Shielding:** **[SELESAI]** Pembungkus kondisional `ExcludeSemantics` di mode debug untuk menyembunyikan log warning sinkronisasi aksesibilitas Windows UIA di terminal.
*   **SQLCipher Encryption:** **[BACKLOG]** Implementasi proteksi enkripsi kata sandi fisik pada berkas lokal `.db` SQLite.

---

## 3. Peta Folder & Berkas Utama Aplikasi

Berikut adalah lokasi berkas penting hasil implementasi pada direktori [app/lib/src/](file:///d:/LAB/git/life-tree/app/lib/src/):

*   **Database & Skema:**
    *   [database.dart](file:///d:/LAB/git/life-tree/app/lib/src/data/local_db/database.dart) $\to$ Definisi tabel SQLite Drift, migrasi skema `onUpgrade` (Versi 1-5), dan indeks optimasi kueri.
*   **Navigasi & Tema:**
    *   [app.dart](file:///d:/LAB/git/life-tree/app/lib/src/app.dart) $\to$ Inisialisasi aplikasi, tema, dan debug-shield `ExcludeSemantics`.
    *   [router.dart](file:///d:/LAB/git/life-tree/app/lib/src/core/routing/router.dart) $\to$ Rute GoRouter dan pengecekan onboarding.
    *   [theme.dart](file:///d:/LAB/git/life-tree/app/lib/src/core/theme/theme.dart) $\to$ Desain sistem Calm Tech (Light & Dark Theme).
*   **Fitur Views & Providers:**
    *   [dashboard_view.dart](file:///d:/LAB/git/life-tree/app/lib/src/features/dashboard/dashboard_view.dart) $\to$ Visual dasbor utama, menu pengaturan data, dan widget Life Compass.
    *   [dashboard_provider.dart](file:///d:/LAB/git/life-tree/app/lib/src/features/dashboard/dashboard_provider.dart) $\to$ Kalkulator "Action of the Day", data musim, dan status jatuh tempo keputusan.
    *   [add_habit_view.dart](file:///d:/LAB/git/life-tree/app/lib/src/features/habit/add_habit_view.dart) $\to$ Dropdown domain kebiasaan, MVA slider, template micro-habits, dan Goal tag input.
    *   [journal_lite_view.dart](file:///d:/LAB/git/life-tree/app/lib/src/features/journal/journal_lite_view.dart) $\to$ Jurnal harian, low-mood check, dan form ekspansi Refleksi Mendalam + Gratitude chips.
    *   [decision_journal_view.dart](file:///d:/LAB/git/life-tree/app/lib/src/features/decision_journal/decision_journal_view.dart) $\to$ Riwayat keputusan, kustomisasi review period, mock templates, dan refleksi 90 hari.
    *   [marketplace_view.dart](file:///d:/LAB/git/life-tree/app/lib/src/features/marketplace/marketplace_view.dart) $\to$ Halaman utama pencarian, pengunduhan, pengunggahan, dan rating template kebiasaan.
    *   [weekly_pulse_view.dart](file:///d:/LAB/git/life-tree/app/lib/src/features/weekly_pulse/weekly_pulse_view.dart) $\to$ Lembar evaluasi mingguan WHO-5 index.
    *   [safety_card_view.dart](file:///d:/LAB/git/life-tree/app/lib/src/features/safety/safety_card_view.dart) $\to$ Papan kontak darurat kesehatan mental terotasi warna.
