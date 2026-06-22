# Engineering & Technical Specifications: LifeTree

**Dokumen Spesifikasi Teknis - Untuk Software Engineers & Developers**

## 1. System Architecture & Tech Stack (Final Decision)

| Komponen | Teknologi | Alasan |
|----------|-----------|--------|
| **Frontend (Mobile)** | Flutter | Satu *codebase* iOS & Android, percepat *time-to-market* MVP |
| **Local Database** | SQLite + SQLCipher | *Offline-first*, enkripsi *at-rest* di perangkat lokal. **Bundling:** Gunakan `sqlite3_flutter_libs` untuk bundling versi SQLite ≥ 3.31.0 (diperlukan untuk GENERATED columns). Device Android lama mungkin menggunakan versi SQLite yang lebih tua di system library. |
| **Key Management** | BIP-39 (12-Word Seed Phrase) | Standar industri — **opsional, hanya untuk Advanced Security / Cloud Sync** |
| **Auto-Save Key (DEFAULT)** | OS Native Keychain | iCloud Keychain / Android Keystore — 1-ketuk setup, minim friksi |
| **Backend (Cloud Sync)** | Node.js + PostgreSQL | Menyimpan *Encrypted Ciphertext BLOB*, server *Zero-Knowledge* |
| **Remote Config** | Firebase Remote Config | Update nomor darurat tambahan tanpa *app update* |
| **Push Notification** | Firebase Cloud Messaging | Out-of-app wellness check |

> **Prinsip Arsitektur:** Seluruh logika komputasi berjalan di perangkat pengguna (*client-side*). Server hanya menerima, menyimpan, dan mengembalikan ciphertext. **Battery/CPU optimization:** cumulative_done_count counter (bukan COUNT query), incremental query 90 hari terakhir, background computation (midnight/app idle), caching Action of the Day sampai end-of-day.

> **Catatan Schema:** Skema database bersifat **konseptual**. `JSONB` (spesifik PostgreSQL) digunakan untuk deskripsi; implementasi lokal di SQLite menggunakan `TEXT` dengan JSON serialization. Terdapat *mapping layer* di aplikasi.

> **Autentikasi Akun:** Email + password hash (bcrypt) di server — terpisah dari enkripsi konten. Server mengautentikasi identitas, bukan membuka konten.

> **Multi-Device Bootstrap:** (A) Perangkat lama ada → QR code transfer (local peer-to-peer). (B) Perangkat lama hilang → Recovery Contact (Shamir 2-of-3) / seed phrase. (C) OS Keychain → iCloud/Google sync otomatis (default experience).

> **Sync Conflict Resolution:** Berlapis: **HabitLog** (append-only, LWW aman), **JournalEntry/mutable** (Conflict Copy jika timestamp < 5 menit dari perangkat berbeda — kedua versi ditampilkan, pengguna memilih), **Habit metadata** (LWW + conflict warning).

> **Key Rotation:** Re-encryption bertahap di client-side. Key version di metadata entri (`key_version` di DeviceRegistry).

> **Soft Delete:** Setiap tabel memiliki `deleted_at TIMESTAMP NULLABLE`. Record tidak dihapus fisik — ditandai tombstone untuk sinkronisasi multi-perangkat.

## 2. Arsitektur Keamanan

```
┌─────────────────────────────────────────────────────┐
│                    PERANGKAT PENGGUNA                │
│                                                      │
│  ┌──────────┐    ┌────────────┐    ┌─────────────┐  │
│  │ Flutter   │───►│ SQLCipher   │───►│ Seed Phrase │  │
│  │ App       │    │ (Encrypted) │    │ (BIP-39)    │  │
│  │           │    │             │    │  [opsional] │  │
│  └─────┬────┘    └────────────┘    └──────┬──────┘  │
│        │                                  │          │
│        │         ┌────────────────┐       │          │
│        │         │ OS Keychain    │◄──────┘          │
│        │         │ (Auto-Save)    │                  │
│        │         │  [DEFAULT]     │                  │
│        │         └────────────────┘                  │
│        │                                              │
│        │    🔒 App-Level Biometric Lock              │
│        │    (autentikasi saat kembali dari            │
│        │     background > 5 menit)                   │
└────────┼────────────────────────────────────────────┘
         │ E2EE Cloud Sync (Tier Plus only)
         ▼
┌─────────────────────────────────────────────────────┐
│                    SERVER LIFETREE                    │
│                                                      │
│  ┌──────────┐    ┌──────────────────────────┐       │
│  │ Node.js   │───►│ PostgreSQL                │       │
│  │ API       │    │ (Encrypted Ciphertext BLOB)│       │
│  └──────────┘    └──────────────────────────┘       │
│                                                      │
│  ⛔ Server TIDAK MEMILIKI kunci dekripsi konten      │
│  ⛔ Data hanya bisa dibaca di perangkat pengguna     │
│  ℹ️  Metadata sistem tetap terlihat                  │
│  ℹ️  CrisisPromptLog TIDAK di-sync (local-only)      │
└─────────────────────────────────────────────────────┘
```

**Recovery Contact:** Shamir Secret Sharing **(2-of-3)** — tiga fragment dibuat, dua diperlukan:
1. Fragment di OS Keychain pengguna
2. Fragment dikirim ke Recovery Contact (terenkripsi)
3. *Secondary backup fragment* — disimpan pengguna di lokasi terpisah (cetak/cloud lain)

## 3. Core Data Models (Entity Schema Lengkap)

### `UserProfile`
| Kolom | Tipe | Constraint | Keterangan |
|-------|------|-----------|------------|
| `user_id` | UUID | PK | ID unik pengguna |
| `age_band` | VARCHAR(10) | NOT NULL | "18-24", "25-35". Catatan: Fase 2 memerlukan `date_of_birth`. |
| `current_season` | VARCHAR(20) | DEFAULT 'Growth' | 'Growth', 'Recovery', 'Dormant' |
| `canopy_load_capacity` | INTEGER | DEFAULT 10 | Panduan (soft enforcement), bukan batas kaku |
| `crisis_disclaimer_acknowledged` | BOOLEAN | DEFAULT FALSE | Pengguna sudah acknowledge disclaimer krisis |
| `last_wellness_push_at` | TIMESTAMP | NULLABLE | Frequency cap Out-of-App Wellness Check (1x/14 hari) |
| `last_crisis_prompt_at` | TIMESTAMP | NULLABLE | Frequency cap crisis modal (1x/7 hari). **Cloud-syncable** sebagai metadata sistem — bukan konten sensitif. Mencegah frequency cap hilang setelah reinstall. |
| `recovery_contact_email` | VARCHAR(255) | NULLABLE | Email kontak pemulihan (opsional) |
| `recovery_contact_fragment` | TEXT | NULLABLE, ENCRYPTED | Fragment kunci terenkripsi (Shamir 2-of-3) |
| `secondary_backup_fragment` | TEXT | NULLABLE, ENCRYPTED | Fragment cadangan (Shamir 2-of-3) |
| `security_level` | VARCHAR(20) | DEFAULT 'Standard' | 'Standard' (OS Keychain) atau 'Advanced' (Seed Phrase) |
| `deleted_at` | TIMESTAMP | NULLABLE | Tombstone untuk soft delete |
| `created_at` | TIMESTAMP | NOT NULL | |
| `updated_at` | TIMESTAMP | NOT NULL | |

### `LifeAudit`
| Kolom | Tipe | Constraint | Keterangan |
|-------|------|-----------|------------|
| `audit_id` | UUID | PK | |
| `user_id` | UUID | FK → UserProfile | |
| `domain_scores` | JSONB | NOT NULL | MVP: `{"Tubuh": 4}` (hanya domain aktif) |
| `timestamp` | TIMESTAMP | NOT NULL | |
| `deleted_at` | TIMESTAMP | NULLABLE | Tombstone |

### `WeeklyPulse`
| Kolom | Tipe | Constraint | Keterangan |
|-------|------|-----------|------------|
| `pulse_id` | UUID | PK | |
| `user_id` | UUID | FK → UserProfile | |
| `domain_tag` | VARCHAR(30) | NOT NULL | |
| `score` | INTEGER | CHECK(1-10) | Skor domain minggu ini |
| `reflection_text` | TEXT | NULLABLE | |
| `week_start_date` | DATE | NOT NULL | |
| `deleted_at` | TIMESTAMP | NULLABLE | Tombstone |

### `Habit`
| Kolom | Tipe | Constraint | Keterangan |
|-------|------|-----------|------------|
| `habit_id` | UUID | PK | |
| `user_id` | UUID | FK → UserProfile | |
| `domain_tag` | VARCHAR(30) | NULLABLE | |
| `title` | VARCHAR(100) | NOT NULL | |
| `status` | VARCHAR(20) | DEFAULT 'Active' | 'Active', 'Archived' |
| `frequency` | VARCHAR(20) | DEFAULT 'Daily' | 'Daily', '3x/Week', 'Weekly', 'Custom'. Custom: pola jadwal bebas via `scheduled_days`; threshold: `(missed/scheduled_per_period) > 0.5` |
| `scheduled_days` | VARCHAR(20) | NULLABLE | "Mon,Wed,Fri". `3x/Week` default Mon/Wed/Fri. `Weekly` = hari dipilih user. |
| `initiation_friction` | INTEGER | CHECK(1-5), DEFAULT 3 | Bisa berkurang via Automaticity Decay |
| `original_friction` | INTEGER | CHECK(1-5), DEFAULT 3 | **Snapshot baseline** untuk decay calculation |
| `energy_cost` | INTEGER | CHECK(1-5), DEFAULT 3 | TETAP, tidak dipengaruhi decay |
| `total_load_score` | INTEGER | GENERATED | `initiation_friction + energy_cost`. **SQLite ≥ 3.31.0** — gunakan `sqlite3_flutter_libs` |
| `impact_score` | INTEGER | CHECK(1-5), DEFAULT 3 | **UX:** Guided prompt saat membuat habit: *"Seberapa penting habit ini? (1 = tambahan, 5 = sangat penting)"* |
| `cumulative_done_count` | INTEGER | DEFAULT 0 | **Denormalisasi counter** — di-increment setiap HabitLog Done. Menghindari full table scan. Recency adjustment dihitung saat evaluasi decay. |
| `mva_duration_min` | INTEGER | DEFAULT 2 | Durasi Minimum Viable Action (menit). Digunakan saat Friction Intervention opsi "Kurang Waktu" dipilih: sistem menawarkan one-time override durasi ke `mva_duration_min` menit untuk hari berikutnya. Durasi aktual dicatat di `duration_actual_min` HabitLog. Override otomatis terhapus setelah 1 kali. |
| `stacked_to_habit_id` | UUID | FK → Habit, NULLABLE | **Validasi circular reference di application layer: DFS traversal max depth 5 level — jika habit target ada di chain, tolak. Batasan: maks 5 level stacking.** |
| `deleted_at` | TIMESTAMP | NULLABLE | Tombstone |
| `created_at` | TIMESTAMP | NOT NULL | |

### `HabitLog`
| Kolom | Tipe | Constraint | Keterangan |
|-------|------|-----------|------------|
| `log_id` | UUID | PK | |
| `habit_id` | UUID | FK → Habit | |
| `date` | DATE | NOT NULL | **Hanya dibuat pada hari terjadwal.** Hari di luar jadwal = tidak ada log (Not_Scheduled implisit). |
| `status` | VARCHAR(25) | NOT NULL | 'Done', 'Missed', 'Skipped_Intentionally', 'Paused' |
| `friction_reason_selected` | VARCHAR(30) | NULLABLE | 'Kurang_Waktu', 'Kelelahan', 'Lupa' |
| `duration_actual_min` | INTEGER | NULLABLE | |
| `deleted_at` | TIMESTAMP | NULLABLE | Tombstone |
| **UNIQUE** | | `(habit_id, date)` | Satu log per habit per hari terjadwal |

**Catatan Non-Daily Habit:** Untuk habit `3x/Week` (Mon/Wed/Fri), **tidak ada log entry** untuk hari Selasa/Kamis/Sabtu/Minggu. Friction Intervention hanya menghitung Missed dari hari terjadwal.

### `JournalEntry`
| Kolom | Tipe | Constraint | Keterangan |
|-------|------|-----------|------------|
| `entry_id` | UUID | PK | |
| `user_id` | UUID | FK → UserProfile | |
| `date` | DATE | NOT NULL | |
| `mood_score` | INTEGER | CHECK(1-5) | |
| `keyword` | VARCHAR(50) | NULLABLE | Journal Lite |
| `text_content` | TEXT | NULLABLE, ENCRYPTED | Deep Reflection |
| `gratitude_text` | TEXT | NULLABLE, ENCRYPTED | |
| `entry_type` | VARCHAR(15) | DEFAULT 'Lite', **CHECK IN ('Lite', 'Deep')** | |
| `conflict_copy` | TEXT | NULLABLE, ENCRYPTED | Jika sync conflict < 5 menit: versi alternatif disimpan di sini |
| `deleted_at` | TIMESTAMP | NULLABLE | Tombstone |
| `created_at` | TIMESTAMP | NOT NULL | |
| **UNIQUE** | | `(user_id, date, entry_type)` | Maks. 1 Lite + 1 Deep per hari |

### `CoreValue` (LifeTree Plus)
| Kolom | Tipe | Constraint | Keterangan |
|-------|------|-----------|------------|
| `value_id` | UUID | PK | |
| `user_id` | UUID | FK → UserProfile | |
| `value_text` | VARCHAR(100) | NOT NULL | **Maks. 3 per user, validasi di application layer** |
| `deleted_at` | TIMESTAMP | NULLABLE | Tombstone |
| `created_at` | TIMESTAMP | NOT NULL | |

### `DecisionJournal` (LifeTree Plus — Iterasi 2)
| Kolom | Tipe | Constraint | Keterangan |
|-------|------|-----------|------------|
| `decision_id` | UUID | PK | |
| `user_id` | UUID | FK → UserProfile | |
| `decision_title` | VARCHAR(200) | NOT NULL | |
| `context` | TEXT | NULLABLE | |
| `expected_outcome` | TEXT | NULLABLE | |
| `decided_at` | TIMESTAMP | NOT NULL | |
| `review_at` | TIMESTAMP | NOT NULL | Default: 90 hari |
| `reviewed` | BOOLEAN | DEFAULT FALSE | |
| `deleted_at` | TIMESTAMP | NULLABLE | Tombstone |

### `GoalHierarchy` (LifeTree Plus)
| Kolom | Tipe | Constraint | Keterangan |
|-------|------|-----------|------------|
| `goal_id` | UUID | PK | |
| `user_id` | UUID | FK → UserProfile | |
| `parent_goal_id` | UUID | FK → GoalHierarchy, NULLABLE | NULL = Visi (Level 0) |
| `level` | INTEGER | NOT NULL | 0=Visi, 1=Project, 2=Habit/Task |
| `title` | VARCHAR(200) | NOT NULL | |
| `deadline` | DATE | NULLABLE | Hanya level 1 |
| `status` | VARCHAR(20) | DEFAULT 'Active' | |
| `deleted_at` | TIMESTAMP | NULLABLE | Tombstone |

> **Catatan:** Tabel `GoalHierarchy` dibuat sejak MVP Lean untuk menghindari migrasi schema, tapi fitur UI-nya baru diaktifkan di Iterasi 1.

### `Subscription`
| Kolom | Tipe | Constraint | Keterangan |
|-------|------|-----------|------------|
| `sub_id` | UUID | PK | |
| `user_id` | UUID | FK → UserProfile | |
| `tier` | VARCHAR(20) | DEFAULT 'Free' | 'Free', 'Plus', 'Student' |
| `platform` | VARCHAR(20) | NULLABLE | 'ios', 'android' |
| `started_at` | TIMESTAMP | | |
| `expires_at` | TIMESTAMP | NULLABLE | NULL = aktif |
| `auto_renew` | BOOLEAN | DEFAULT TRUE | |

### `CrisisPromptLog` (**LOCAL-ONLY — tidak di-sync ke cloud**)
| Kolom | Tipe | Constraint | Keterangan |
|-------|------|-----------|------------|
| `prompt_id` | UUID | PK | |
| `user_id` | UUID | FK → UserProfile | |
| `trigger_type` | VARCHAR(30) | NOT NULL | 'Mood_3day', 'Mood_Drop', 'Escalation_14day' |
| `prompted_at` | TIMESTAMP | NOT NULL | |
| `user_action` | VARCHAR(30) | NULLABLE | 'Dismissed', 'Opened_Safety_Card', 'Recovery_Mode', 'Tapped_Hotline_CTA'. **Tracking berhenti di interaksi UI — apakah panggilan berhasil tidak dapat diketahui.** |

> **Privacy:** Retention 90 hari (auto-delete). Tidak diekspor JSON/CSV. Tidak di-sync ke cloud.

### `DeviceRegistry`
| Kolom | Tipe | Constraint | Keterangan |
|-------|------|-----------|------------|
| `device_id` | UUID | PK | |
| `user_id` | UUID | FK → UserProfile | |
| `device_name` | VARCHAR(100) | NULLABLE | |
| `platform` | VARCHAR(10) | NOT NULL | 'ios', 'android' |
| `public_key` | TEXT | NOT NULL | Kunci publik perangkat untuk E2EE handshake. **Format:** Base64-encoded X25519 public key (32 byte raw, encoded ~44 karakter). **Algoritma:** X25519 (ECDH) untuk key exchange. **Enkripsi konten:** AES-256-GCM (12-byte nonce). **Key derivation:** BIP-39 seed → HKDF-SHA256 → X25519 keypair + AES-256 key. **QR transfer:** QR berisi ephemeral X25519 public key + encrypted AES-256 master key (via ECDH shared secret). Masa berlaku QR: 5 menit. |
| `key_version` | INTEGER | DEFAULT 1 | Increment saat key rotation |
| `last_sync_at` | TIMESTAMP | NULLABLE | |
| `registered_at` | TIMESTAMP | NOT NULL | |

### `ConsentLog`
| Kolom | Tipe | Constraint | Keterangan |
|-------|------|-----------|------------|
| `consent_id` | UUID | PK | |
| `user_id` | UUID | FK → UserProfile | |
| `consent_type` | VARCHAR(50) | NOT NULL | 'ToS', 'Privacy_Policy', 'Data_Processing', 'Child_Parental', 'Crisis_Disclaimer' |
| `granted_at` | TIMESTAMP | NOT NULL | |
| `version` | VARCHAR(20) | NOT NULL | Misal: "ToS_v1.2" |
| `revoked_at` | TIMESTAMP | NULLABLE | NULL = masih aktif |

### `ReminderPreference`
| Kolom | Tipe | Constraint | Keterangan |
|-------|------|-----------|------------|
| `habit_id` | UUID | FK → Habit, PK | |
| `reminder_enabled` | BOOLEAN | DEFAULT TRUE | |
| `reminder_time` | TIME | DEFAULT '08:00' | |
| `quiet_hours_start` | TIME | DEFAULT '22:00' | |
| `quiet_hours_end` | TIME | DEFAULT '07:00' | |

## 4. Relasi Antar Entitas (ER Overview)

```
UserProfile 1───∞ LifeAudit
UserProfile 1───∞ WeeklyPulse
UserProfile 1───∞ Habit
UserProfile 1───∞ JournalEntry
UserProfile 1───∞ CoreValue (max 3, app-layer validation)
UserProfile 1───∞ DecisionJournal
UserProfile 1───∞ GoalHierarchy
UserProfile 1───1 Subscription
UserProfile 1───∞ CrisisPromptLog (LOCAL-ONLY, retention 90 hari)
UserProfile 1───∞ DeviceRegistry
UserProfile 1───∞ ConsentLog

Habit 1───∞ HabitLog (hanya hari terjadwal)
Habit 1───1 ReminderPreference
Habit 1───0..1 Habit (stacked_to_habit_id, DFS cycle detection, max depth 5)
GoalHierarchy 1───∞ GoalHierarchy (parent_goal_id, tree structure)
```



### 4. Database Index Specification

| Tabel | Index | Tujuan |
|-------|-------|--------|
| `HabitLog` | `(habit_id, date, status)` | Query `cumulative_done` recency-weighted: filter Done dalam 90/180 hari terakhir |
| `HabitLog` | `(habit_id, date DESC)` | Query Missed terbaru untuk Friction Intervention threshold |
| `JournalEntry` | `(user_id, date, mood_score)` | Crisis Detection: scan mood_score ≤ 2 dalam 3–14 hari terakhir |
| `Habit` | `(user_id, status, domain_tag)` | Action of the Day: query habit aktif per domain |
| `WeeklyPulse` | `(user_id, domain_tag, week_start_date DESC)` | Domain score TTL: cek kebaruan skor per domain |
| `CrisisPromptLog` | `(user_id, prompted_at DESC)` | Frequency cap: cek kapan terakhir crisis modal ditampilkan |
| `ConsentLog` | `(user_id, consent_type)` | Cek status consent terkini per tipe |

> **Catatan:** `UNIQUE(habit_id, date)` di HabitLog otomatis membuat index composite — tapi tidak mencakup `status`, sehingga index tambahan diperlukan untuk query yang memfilter status.
## 5. Algoritma Mesin & Logic Flow

### A. Algoritma "Action of the Day"

```
domain_deficit = 10 - latest_domain_score  // dari WeeklyPulse atau LifeAudit
priority_score = (domain_deficit * impact_score) / (initiation_friction + energy_cost)

Langkah:
1. Hitung domain_deficit untuk setiap domain yang aktif
   - Jika domain_score expired (> 30 hari), gunakan fallback dari LifeAudit
2. Cari domain dengan deficit TERTINGGI
   - Domain dengan deficit = 0 TIDAK PERNAH menjadi target
3. Query habit aktif yang domain_tag == domain_terlemah
   - Filter: hanya habit yang dijadwalkan hari ini
4. Jika tidak ada habit, cari domain terlemah berikutnya
5. Urutkan habit berdasarkan priority_score TERTINGGI
6. Tampilkan habit pertama sebagai Action of the Day
7. Jika semua habit di domain terlemah Done → domain terlemah kedua
8. Jika SEMUA habit Done → Celebration State

Cold Start (pengguna baru):
  → Gunakan skor LifeAudit onboarding
  → Jika belum ada habit → prompt onboarding
  → Prioritas: impact_score tertinggi + total_load_score terendah

Caching: Hasil disimpan di cache sampai end-of-day (midnight).
```

### B. Algoritma "Automaticity Decay" (Recency-Weighted)

```
Trigger: HabitLog Done selama 60 hari kumulatif (recency-weighted)

         HIPOTESIS PRODUK — formula decay adalah MODEL YANG
         DISEDERHANAKAN, bukan representasi langsung Lally et al.
         Parameter dikalibrasi via A/B testing (§4.6 README).

Action:
  // Recency-weighted: automaticity bukan "saldo permanen"
  cumulative_done = weighted_count(HabitLog WHERE habit_id = ? AND status = 'Done')
                    90 hari terakhir → bobot 1
                    91-180 hari → bobot 0.5
                    > 180 hari → bobot 0

  // Performance: denormalisasi counter
  // cumulative_done_count di-increment saat HabitLog Done
  // Recency adjustment dihitung saat evaluasi (background job)

  initiation_friction = max(1, original_friction - floor(cumulative_done / 20))
  energy_cost = TETAP
  total_load_score = initiation_friction + energy_cost (dihitung ulang)

Performance optimization:
  - cumulative_done_count menghindari full table scan
  - Background computation (midnight / app idle), bukan real-time
  - Incremental query: 90 hari terakhir untuk update harian
  - Action of the Day cache sampai end-of-day
```

### C. Algoritma "Passive Crisis Intervention"

```
Trigger:
  - mood_score ≤ 2 selama 3 hari berturut-turut, ATAU
  - mood_score turun > 2 poin dalam 5 hari

Frequency Cap: Maks. 1x per 7 hari (modal penuh)

Action 1: Modal empatik + Safety Card
Action 2: Tawarkan Recovery Mode (durasi 1/3/7 hari)

Crisis Escalation (> 14 hari mood_score ≤ 2):
  - Modal eskalasi langsung ke hotline, maks. 1x/14 hari
  - Safety Card highlighted dengan visual berbeda

Out-of-App:
  - > 5 hari tidak buka → 1 push empatik (maks. 1x/14 hari)
  - Frequency cap tracked via last_wellness_push_at

Fallback: Nomor primer di-hardcode (119, 119 ext 8 SEJIWA)
Tracking: 'Tapped_Hotline_CTA' (bukan 'Called_Hotline')
```

## 6. State Machine (Status Habit)

```
                    ┌──────────┐
          ┌────────►│   Done   │──────────┐
          │         └──────────┘          │
          │                               │ (reset hitungan missed)
          │                               ▼
     ┌────┴─────┐   threshold    ┌──────────────┐
     │  Missed  │───────────────►│   Friction   │
     └────┬─────┘ (variasi per   │ Intervention │
          │     frekuensi habit) └──────┬───────┘
          │                             │
          │ (pilih skip)                │ (setelah intervensi)
          ▼                             ▼
 ┌──────────────────┐          ┌──────────────┐
 │Skipped_          │          │   Paused     │◄── Recovery Mode
 │Intentionally     │          │ (Sistem)     │    (durasi 1/3/7 hari)
 └──────────────────┘          └──────┬───────┘
    ▲ TIDAK masuk hitungan            │
    ▲ Missed                          │ (keluar Recovery)
    │                                  ▼
    └──────────────────────────► Active

 ┌──────────────────┐
 │  Not_Scheduled   │  ← Hari di luar jadwal (non-daily)
 │  (implisit)      │    Tidak ada HabitLog dibuat
 └──────────────────┘    Tidak masuk hitungan Missed/Friction
```

**Transisi Status:**

| Dari | Ke | Kondisi |
|------|----|---------|
| Active | Done | Selesaikan habit hari ini (hari terjadwal) |
| Active | Missed | Tidak selesaikan (hari terjadwal) |
| Active | Not_Scheduled | Bukan hari terjadwal — tidak ada log |
| Active | Skipped_Intentionally | Sengaja meliburkan diri |
| Active | Paused | Recovery Mode (manual/auto, durasi 1/3/7 hari) |
| Missed | Friction Intervention | Threshold terpenuhi (variasi per frekuensi) |
| Paused | Active | Keluar dari Recovery Mode |
| Friction Intervention | Active | Setelah intervensi selesai |
