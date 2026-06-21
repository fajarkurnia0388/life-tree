# Research Paper & Compliance Guideline: LifeTree Personal OS

**Abstrak**
Dokumen ini merupakan landasan empiris, psikologis, dan hukum dari pengembangan LifeTree. Berbeda dengan aplikasi produktivitas konvensional yang mengandalkan *loss aversion* (penghindaran kerugian) melalui sistem *streak*, LifeTree dirancang berbasis filosofi *Anti-Guilt* (Anti Rasa Bersalah). Makalah ini membedah integrasi *Habit Formation Theory*, *Cognitive Load Theory*, serta batas-batas hukum terkait privasi dan keselamatan pengguna di bawah payung yurisdiksi Indonesia (PP TUNAS) dan standar internasional (COPPA).

---

## Bagian 1: Landasan Ilmu Perilaku (Behavioral Science)

### 1.1 Dekonstruksi Mitos 21 Hari & Validasi 66 Hari
Industri pengembangan diri sering berpatokan pada mitos bahwa kebiasaan terbentuk dalam 21 hari. LifeTree menolak kerangka ini dan menggunakan temuan **Lally et al. (2010)** dari University College London (UCL).
- **Temuan Kunci:** Waktu median menuju otomatisasi perilaku adalah 66 hari, dengan rentang variasi yang sangat ekstrem (18 hingga 254 hari). 
- **Landasan *Anti-Guilt*:** Studi yang sama membuktikan bahwa hilangnya kesempatan satu atau dua hari berturut-turut (*missed opportunity*) tidak merusak proses otomatisasi secara material. Oleh karena itu, arsitektur LifeTree mengizinkan *Recovery Mode* (Mode Istirahat) tanpa menghukum (*punish*) pengguna dengan me-reset visual pohon mereka.

### 1.2 Manajemen Beban Kognitif (*Cognitive Load Theory*)
LifeTree menggunakan konsep *Canopy Load* yang diilhami dari *Cognitive Load Theory* (Sweller, 1988). Otak manusia (terutama *Working Memory*) memiliki kapasitas terbatas.
- **Rasionalisasi:** Kegagalan dalam mempertahankan kebiasaan seringkali bukan masalah motivasi, melainkan *overload* (kelebihan beban). 
- **Implementasi Produk:** Sistem mengkalibrasi beban kebiasaan melalui dua matriks: *Initiation Friction* (Kesulitan Memulai) dan *Energy Cost* (Biaya Tenaga). Beban ini otomatis turun seiring berjalannya waktu (*Automaticity Decay*) untuk membebaskan ruang memori kognitif.

### 1.3 Model Intervensi Perilaku (Fogg Behavior Model)
Berdasarkan rumusan B=MAP (*Behavior = Motivation + Ability + Prompt*) dari Dr. BJ Fogg, LifeTree tidak menangani kegagalan dengan "Peringatan Hukuman".
- Jika *Ability* (Kemampuan) bermasalah ("Kurang Waktu/Energi"), sistem menurunkan durasi aksi (membuatnya menjadi *Minimum Viable Action*).
- Jika *Prompt* (Pemicu) bermasalah ("Lupa"), sistem menyarankan *Routine Stacking* (Menumpuk kebiasaan baru ke kebiasaan lama yang sudah ada).

---

## Bagian 2: Kepatuhan Hukum & Etika Digital (Compliance)

### 2.1 Perlindungan Data Pribadi (UU PDP & PP 17/2025 - PP TUNAS)
Jurnal emosi, kebiasaan, dan kondisi finansial adalah **Data Bersifat Spesifik/Sensitif**. LifeTree mematuhi peraturan hukum perlindungan data Indonesia:
- **Hak Atas Privasi Anak (Usia 13-17):** Sesuai PP 17/2025, remaja adalah anak di bawah 18 tahun. Namun, secara psikologis, remaja membutuhkan ruang aman. LifeTree memberikan *Parental Dashboard* (Dasbor Orang Tua) yang **hanya** menampilkan tren agregat (grafik sentimen), dan secara sistem **membatasi orang tua untuk membaca teks asli isi jurnal anak**. Ini adalah jembatan antara perlindungan wali dan *Trust* (Kepercayaan) remaja.
- **Usia < 13 Tahun (COPPA & PP TUNAS):** Anak usia 3-12 tahun diwajibkan menggunakan mode *Offline-First* mutlak tanpa sinkronisasi *cloud*. Data tidak pernah keluar dari perangkat. Selain itu, **Autentikasi Biometrik (FaceID) dilarang mutlak** untuk menghindari pengumpulan data wajah anak.
- **Age Graduation (Kelulusan Usia):** Tepat pada hari ulang tahun ke-18, sistem mencabut (*revoke*) akses orang tua dari akun secara otomatis.

### 2.2 Passive Crisis Safety Protocol (Protokol Keselamatan)
Memproses deteksi bunuh diri atau depresi menggunakan AI (*Machine Learning Keyword Matching*) membawa risiko hukum (*Liability*) yang sangat masif, termasuk potensi tuntutan atas kelalaian jika terjadi *False Negative* (sistem gagal mendeteksi sandi kiasan dari pengguna yang sedang depresi).
- **Rasionalisasi Etis:** LifeTree BUKAN *Medical Device* (Alat Medis) atau layanan terapi. 
- **Implementasi Kepatuhan:** Sistem menggunakan **Passive Safety Protocol**. Menyediakan "Safety Card" (Kartu Keselamatan) yang selalu tampil (*Always-On*) di antarmuka Lapis 0. Tombol ini terhubung ke *Hotline* Darurat (misal: 119 di Indonesia) tanpa melibatkan algoritma deteksi membaca isi jurnal.

### 2.3 Hak Atas Data & Enkripsi (*Right to Erasure*)
- **E2EE (End-to-End Encryption):** Semua data awan (*cloud sync*) dienkripsi.
- **Batasan Akses Perusahaan:** Pihak LifeTree *zero-knowledge* (tidak memiliki kunci untuk melihat data pengguna).
- Jika pengguna kehilangan/lupa kunci sandi, mereka **kehilangan data selamanya**. Kebijakan ini dijabarkan secara tegas di *Term of Service* (ToS) saat pendaftaran. Sistem menyediakan Ekspor Lokal (JSON/CSV) agar pengguna dapat melakukan pencadangan mandiri yang bisa dibaca oleh manusia.

---

## Kesimpulan Akademis
LifeTree menjembatani kesejangan antara aplikasi produktivitas yang menghukum, dengan aplikasi kesehatan mental yang terlalu klinis. Dengan berlandaskan sains perilaku dan kepatuhan hukum yang ekstrem (terutama pelindungan anak), LifeTree berdiri sebagai paradigma baru dalam *Ethical Technology Design* (Desain Teknologi Beretika).# Business & Strategy Whitepaper: LifeTree

**Dokumen Konfidensial - Untuk Investor, Stakeholders, & Tim Marketing**

## 1. Ringkasan Eksekutif (The Problem & The Solution)
**Masalah:** Pasar aplikasi produktivitas dan *habit tracker* saat ini (senilai miliaran dolar) memiliki masalah fundamental: *Churn rate* (pengguna berhenti) yang sangat tinggi. Hal ini disebabkan oleh "Toxic Productivity" di mana aplikasi mengandalkan fitur *streak* (hari beruntun) yang memicu rasa bersalah (*guilt*) dan kelelahan mental (*burnout*) saat pengguna melewatkan 1 hari saja. 

**Solusi:** LifeTree adalah **Personal OS (Sistem Orientasi Diri)** pertama yang berlandaskan filosofi **Anti-Guilt**. LifeTree mengonversi "kegagalan" menjadi data refleksi (*Friction Journaling*) dan membantu pengguna memetakan kembali arah hidup mereka secara holistik, bukan sekadar mencentang daftar tugas.

## 2. Target Pasar & Strategi Peluncuran (Go-to-Market)
Untuk menghindari *over-engineering* dan memotong biaya produksi, peluncuran LifeTree dibagi dalam beberapa fase:
- **Fase 1 (MVP - Minimum Viable Product):** 
  - **Target Audiens:** Dewasa muda usia 18 - 35 Tahun (Mahasiswa tingkat akhir, *First-Jobber*, Profesional). 
  - **Karakteristik:** Digital-native, memiliki kepedulian tinggi pada *mental health*, rentan terhadap *overwhelm/burnout*.
- **Fase 2 (Ekspansi Masa Depan):** Menguasai pasar Gen-Alpha dan Keluarga melalui perilisan *Teen Mode*, *Seedling Mode* (Anak), dan *Parental Dashboard*.

## 3. Strategi Monetisasi (Value-Based Freemium)
LifeTree **TIDAK** menjual data pengguna dan **TIDAK** menampilkan iklan (*Zero Targeted Ads*). Pendapatan dihasilkan dari model berlangganan yang berfokus pada "kenyamanan dan analitik":

1. **Tier Dasar (Gratis):**
   - Akses penuh ke seluruh orientasi dasar (Jurnal, Habit, Radar Kehidupan).
   - *Local Encrypted Backup* (Gratis untuk 1 perangkat, mencegah pengguna trauma kehilangan jurnal jika HP rusak/hilang).
2. **LifeTree Plus (Langganan B2C - Estimasi Rp 39.000/bln):**
   - **E2EE Cloud Sync:** Sinkronisasi *real-time* otomatis antar perangkat (HP, Tablet, PC).
   - **On-Device Insights:** Analisis pola hidup ("Kurang tidur memicu pengeluaran boros").
   - **PDF Export:** Fitur mengubah jurnal tahunan menjadi *e-book* estetik siap cetak.
3. **Micro-Transactions (Kosmetik):** Penjualan tema warna aplikasi dan skin spesies pohon (*Dark Mode OLED*, Pohon Sakura, dll).

## 4. Key Performance Indicators (KPIs) & Target Sukses
Berbeda dengan aplikasi lain yang memuja *Daily Active Users* (DAU) berbasis kecanduan, LifeTree mengukur kesuksesan melalui retensi yang bermakna:
- **Metrik Retensi:** *Day-7 Retention* ≥ 20%, dan *Day-30 Retention* sebesar **10% - 15%** (Menjadi *Top-Quartile* di industri *wellness app*).
- **North Star Metric (Shame-Free Return Rate):** ≥ 30% pengguna yang tidak membuka aplikasi selama > 3 hari, berhasil kembali aktif setelah dipicu dialog *Friction Journaling* yang empatik.
- **Weekly Clarity Rate:** ≥ 40% pengguna menyatakan *"Saya tahu apa yang menjadi fokus saya minggu depan"* setelah *Weekly Pulse Check*.# Product Requirements Document (PRD): LifeTree

**Dokumen Spesifikasi Desain - Untuk Product Manager & Desainer UI/UX**

## 1. Visi Produk & Scope MVP
LifeTree adalah aplikasi yang memadukan jurnal, *habit tracker*, dan peta tujuan hidup. MVP HANYA ditujukan untuk pengguna Dewasa (18-35 tahun). Semua desain layar untuk mode anak, remaja, dan *parental control* TIDAK dimasukkan di MVP.

## 2. Struktur Layar Utama (Central Command Dashboard)
Saat pengguna membuka aplikasi, layar "Home" wajib menampilkan 4 elemen secara hierarkis (dari atas ke bawah):
1. **Visual Pohon (Tree Vitality):** Estetika utama aplikasi. Pohon tumbuh seiring konsistensi, bisa berubah sesuai *Current Season* (misal: bersalju saat *Recovery Mode*).
2. **Action of the Day (Aksi Prioritas):** 1 Kartu besar di tengah layar yang merekomendasikan **1 Habit** paling penting untuk dikerjakan hari ini.
3. **Radar Keseimbangan (Wheel of Life):** Diagram jaring laba-laba (*spider chart*) mini yang menampilkan 6 titik domain kehidupan.
4. **Quick Journaling (Akar):** Tombol akses cepat ke *Journal Lite* (1 ketuk emoji).

## 3. User Journey & Alur Layar (User Flows)

### A. Onboarding (Progressive Profiling)
Untuk mencegah pengguna menghapus aplikasi karena kelelahan (*drop-off*), proses *onboarding* dilakukan secara bertahap:
1. **Welcome Screen (Hari 1):** Menjelaskan filosofi *Anti-Guilt*. Pengguna hanya ditanya 2 dari 6 pertanyaan *Life Audit* sebagai *Quick Start*.
2. **Setup Keamanan (Hari 3):** Setelah pengguna merasa betah, sistem baru akan meminta pengguna mengamankan jurnal dengan mengunduh *12-Word Recovery Key* (Terdapat opsi cepat: *Save to iCloud/Google Passwords*).
3. **Full Audit (Akhir Minggu 1):** Sisa 4 pertanyaan audit diselesaikan saat pengguna melakukan *Weekly Pulse* pertama.

### B. Friction Intervention (Flow Saat Gagal Habit)
Jika sebuah habit berstatus *Missed* 3x dalam 7 hari:
1. Muncul Pop-up ramah (Bukan warna merah/peringatan keras).
2. Teks: *"Hari ini sepertinya berat. Apa hambatan terbesarmu kemarin?"*
3. Pilihan (A) Kurang Waktu, (B) Kelelahan, (C) Lupa.
4. Jika pilih (A), UI memunculkan tombol: *"Mau potong durasi habit ini jadi 5 menit saja untuk besok?"*

### C. Weekly Pulse Check (Akhir Minggu)
- Setiap hari Minggu, muncul notifikasi untuk *Weekly Pulse*.
- Pengguna menjawab 1 pertanyaan refleksi pendek per domain hidup agar skor Radar Keseimbangan di layar Home terus ter-*update*.

## 4. Panduan Copywriting (UX Writing Guidelines)
**Nada Suara (Tone of Voice):** Empatik, Tenang, Netral, Mendukung.
**Aturan Wajib (Do & Don'ts):**
- ❌ **JANGAN:** *"Kamu merusak streak-mu! Kembali ke Nol."* 
- ✅ **GUNAKAN:** *"Pohonmu sedang beristirahat. Kapanpun kamu siap, mari menanam lagi."*
- ❌ **JANGAN:** *"Hapus Habit."*
- ✅ **GUNAKAN:** *"Arsipkan Habit (Beri ruang untuk hal lain)."*
- ❌ **JANGAN:** *"Gagal / Failed."*
- ✅ **GUNAKAN:** *"Missed (Terlewat) / Paused (Jeda)."*

## 5. Aksesibilitas Visual (Accessibility)
- Radar Chart wajib memiliki versi alternatif berupa **List View / Tabel** bagi pengguna tuna netra (agar terbaca *Screen Reader*).
- Hindari penggunaan indikator yang HANYA mengandalkan warna (Misal: merah = bahaya). Gunakan kombinasi warna + Ikon.# Engineering & Technical Specifications: LifeTree

**Dokumen Spesifikasi Teknis - Untuk Software Engineers & Developers**

## 1. System Architecture & Tech Stack (Final Decision)
- **Frontend (Mobile):** Flutter (Dipilih untuk satu *codebase* iOS & Android guna mempercepat *time-to-market* MVP).
- **Local Database (Offline-First):** SQLite.
- **Security & Encryption:** SQLCipher (Untuk enkripsi database *at-rest* di perangkat lokal).
- **Key Management:** *12-Word Seed Phrase* (BIP-39 standard) yang di-*derive* menjadi Encryption Key. Fitur auto-save menggunakan OS Native Keychain (iCloud Keychain / Android Keystore).
- **Backend (Cloud Sync - Khusus Tier Plus):** Node.js dengan database PostgreSQL, menyimpan *Encrypted Ciphertext BLOB* (Server *Zero-Knowledge* terhadap *plaintext*).

## 2. Core Data Models (Entity Schema Dasar)
- `UserProfile`: { user_id, age_band, current_season, canopy_load_capacity (default: 10) }
- `LifeAudit`: { audit_id, user_id, domain_scores[6], timestamp }
- `Habit`: { habit_id, domain_tag, status (Active/Archived), initiation_friction (1-5), energy_cost (1-5), total_load_score }
- `HabitLog`: { log_id, habit_id, date, status (Done, Missed, Skipped_Intentionally, Paused), friction_reason_selected }
- `JournalEntry`: { entry_id, mood_score (1-5), text_content, gratitude_text, encrypted (boolean) }

## 3. Algoritma Mesin & Logic Flow

### A. Algoritma "Action of the Day"
Sistem memprioritaskan 1 habit untuk ditampilkan di *Central Dashboard* menggunakan formula sederhana (Rule-Based, NO AI/ML):
1. Cari domain dengan skor terendah di tabel `LifeAudit` / `WeeklyPulse`. (Misal: Tubuh).
2. Query semua habit aktif yang memiliki `domain_tag == Tubuh`.
3. Urutkan berdasarkan `total_load_score` TERENDAH.
4. Tampilkan habit urutan pertama sebagai *Action of the Day*. (Prinsip *Low-Hanging Fruit*).

### B. Algoritma "Automaticity Decay" (Penurunan Beban)
Sistem memisahkan variabel `initiation_friction` (sulit mulai) dan `energy_cost` (kuras tenaga). Total Poin Beban sebuah habit = Friksi + Energi.
- **Trigger:** Jika `HabitLog` untuk habit "X" berstatus `Done` selama 60 hari (Sesuai dengan median ilmiah pembentukan kebiasaan Lally et al.).
- **Action:** Turunkan nilai `initiation_friction` menjadi 1 (karena kebiasaan sudah masuk tahap otomasi bawah sadar).
- **Note:** `energy_cost` TETAP tidak berubah (olahraga 1 jam tetap menguras energi fisik). Total poin beban di-kalkulasi ulang.

### C. Algoritma "Passive Crisis Intervention"
Sistem memantau tabel `JournalEntry` secara pasif dengan batasan frekuensi agar tidak memicu kelelahan notifikasi (*Spam Fatigue*):
- **Trigger:** Jika `mood_score <= 2` selama 3 hari berturut-turut ATAU turun > 2 poin dalam rentang 5 hari.
- **Frequency Cap:** Maksimal hanya dipicu **1 kali dalam 7 hari** per pengguna.
- **Action:** Memicu *Pop-up Modal* berisi ajakan empati dan memunculkan *Safety Card* (Nomor darurat).
- **Action 2:** Menawarkan pengguna untuk merubah `current_season` di `UserProfile` menjadi `Recovery Mode` (Sistem akan mem-*pause* notifikasi habit dan mengubah status habit harian menjadi `Paused` agar statistik tidak rusak).

## 4. State Machine (Status Habit)
Perhatikan transisi status dalam tabel `HabitLog` harian:
- `Done`: Pengguna berhasil.
- `Missed`: Pengguna tidak melakukan habit (Bisa memicu *Friction Journaling* jika 3x dalam 7 hari).
- `Skipped_Intentionally`: Pengguna dengan sadar meliburkan diri (Misal hari Minggu). TIDAK masuk hitungan *Missed*.
- `Paused`: Sistem yang menghentikan sementara karena pengguna masuk *Recovery Mode*.