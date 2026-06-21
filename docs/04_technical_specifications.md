# Engineering & Technical Specifications: LifeTree

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