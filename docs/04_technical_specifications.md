# Engineering & Technical Specifications: LifeTree

**Dokumen Spesifikasi Teknis - Untuk Software Engineers & Developers**

## 1. System Architecture & Tech Stack (Final Decision)

| Komponen | Teknologi | Alasan |
|----------|-----------|--------|
| **Frontend (Mobile)** | Flutter | Satu *codebase* iOS & Android, percepat *time-to-market* MVP |
| **Local Database** | SQLite + SQLCipher | *Offline-first*, enkripsi *at-rest* di perangkat lokal. **Bundling:** Gunakan `sqlite3_flutter_libs` untuk bundling versi SQLite ≥ 3.31.0 (diperlukan untuk GENERATED columns). Device Android lama mungkin menggunakan versi SQLite yang lebih tua di system library. |
| **Key Management** | BIP-39 (12-Word Seed Phrase) | Standar industri — **opsional, hanya untuk Advanced Security / Cloud Sync** |
| **Auto-Save Key (DEFAULT)** | OS Native Keychain / Android Keystore | Standard Mode: random 256-bit master key dibuat lokal dan disimpan di secure storage OS. iOS dapat memakai synchronizable Keychain jika dipilih; Android dianggap device-bound by default. |
| **Backend (Cloud Sync)** | Node.js + PostgreSQL | Menyimpan *Encrypted Ciphertext BLOB*, server *Zero-Knowledge* |
| **Remote Config** | Firebase Remote Config | Update nomor darurat tambahan tanpa *app update* |
| **Push Notification** | Firebase Cloud Messaging | Out-of-app wellness check |

> **Prinsip Arsitektur:** Seluruh logika komputasi berjalan di perangkat pengguna (*client-side*). Server hanya menerima, menyimpan, dan mengembalikan ciphertext. **Battery/CPU optimization:** lifetime_done_count counter + weighted_done_score materialized value (bukan COUNT query), incremental query 90 hari terakhir, background computation (midnight/app idle), caching Action of the Day sampai end-of-day.

> **Catatan Schema:** Skema database bersifat **konseptual**. `JSONB` (spesifik PostgreSQL) digunakan untuk deskripsi; implementasi lokal di SQLite menggunakan `TEXT` dengan JSON serialization. Terdapat *mapping layer* di aplikasi.

> **Autentikasi Akun:** Email + password hash (bcrypt) di server — terpisah dari enkripsi konten. Server mengautentikasi identitas, bukan membuka konten.

> **Multi-Device Bootstrap:** (A) Perangkat lama ada → QR code transfer (local peer-to-peer). (B) Perangkat lama hilang → Recovery Contact (Shamir 2-of-3) / recovery key. (C) iOS dapat memanfaatkan synchronizable Keychain bila diaktifkan; Android tidak mengandalkan cloud backup untuk pemulihan kunci, sehingga perlu transfer/recovery eksplisit.

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
| `support_mode` | VARCHAR(20) | DEFAULT 'Normal' | 'Normal', 'Recovery' — mode dukungan/UX emosional |
| `engagement_state` | VARCHAR(20) | DEFAULT 'Active' | 'Active', 'Dormant' — state operasional berbasis aktivitas membuka app |
| `timezone` | VARCHAR(50) | DEFAULT 'Asia/Jakarta' | Menentukan batas hari/minggu untuk habit dan pulse |
| `week_start_day` | INTEGER | DEFAULT 1 | ISO 8601: 1=Monday ... 7=Sunday |
| `latest_domain_scores` | JSONB | NULLABLE | Denormalisasi: `{"Tubuh":{"score":7,"updated_at":"..."}}` untuk Action of the Day |
| `canopy_load_capacity` | INTEGER | DEFAULT 10 | Panduan (soft enforcement), bukan batas kaku |
| `crisis_disclaimer_acknowledged` | BOOLEAN | DEFAULT FALSE | Pengguna sudah acknowledge disclaimer krisis |
| `last_wellness_push_at` | TIMESTAMP | NULLABLE | Frequency cap Out-of-App Wellness Check (1x/14 hari) |
| `last_crisis_prompt_at` | TIMESTAMP | NULLABLE | Frequency cap crisis modal (1x/7 hari). **Cloud-syncable** sebagai metadata sistem — bukan konten sensitif. Mencegah frequency cap hilang setelah reinstall. |
| `recovery_contact_email` | VARCHAR(255) | NULLABLE | Email kontak pemulihan (opsional) |
| `recovery_contact_fragment` | TEXT | NULLABLE, ENCRYPTED | Fragment kunci terenkripsi (Shamir 2-of-3) |
| `secondary_backup_configured` | BOOLEAN | DEFAULT FALSE | True jika user sudah menyimpan fragment/backup di luar platform. Fragment cadangan tidak disimpan server. |
| `secondary_backup_hint` | VARCHAR(100) | NULLABLE | Opsional, lokal/terenkripsi: petunjuk lokasi backup tanpa isi fragment |
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
| **UNIQUE** | | `(user_id, domain_tag, week_start_date)` | 1 row per domain per minggu; Weekly Pulse dianggap complete jika minimal 1 domain terisi. Iterasi 2: 6 domain bisa diisi bertahap dalam minggu yang sama. |

### `WellnessAssessment` (Iterasi 1 — WHO-5 dan instrumen terstruktur)
| Kolom | Tipe | Constraint | Keterangan |
|-------|------|-----------|------------|
| `assessment_id` | UUID | PK | |
| `user_id` | UUID | FK → UserProfile | |
| `instrument` | VARCHAR(30) | NOT NULL | 'WHO5' untuk Iterasi 1 |
| `item_scores` | JSONB | NOT NULL | 5 item WHO-5; SQLite: TEXT JSON |
| `total_score` | INTEGER | NOT NULL | Skor total instrumen |
| `assessment_date` | DATE | NOT NULL | |
| `consent_context` | VARCHAR(50) | NULLABLE | Konteks consent/disclaimer saat assessment |
| `deleted_at` | TIMESTAMP | NULLABLE | Tombstone |
| **UNIQUE** | | `(user_id, instrument, assessment_date)` | Maks. 1 assessment per instrumen per tanggal |

### `Habit`
| Kolom | Tipe | Constraint | Keterangan |
|-------|------|-----------|------------|
| `habit_id` | UUID | PK | |
| `user_id` | UUID | FK → UserProfile | |
| `domain_tag` | VARCHAR(30) | NULLABLE | |
| `title` | VARCHAR(100) | NOT NULL | |
| `status` | VARCHAR(20) | DEFAULT 'Active' | 'Active', 'Archived' |
| `archived_at` | TIMESTAMP | NULLABLE | Diisi saat status berubah ke Archived |
| `frequency` | VARCHAR(20) | DEFAULT 'Daily' | MVP: 'Daily', '3x/Week', 'Weekly'. True CustomRule ditunda ke Iterasi 2. |
| `scheduled_days` | VARCHAR(20) | NULLABLE | Format ISO day numbers comma-separated sorted ascending: `1,3,5` = Mon/Wed/Fri. 1=Monday ... 7=Sunday; validasi app-layer no duplicate. |
| `schedule_rule_json` | JSONB | NULLABLE | Iterasi 2: recurrence rule untuk interval/custom; SQLite menyimpan TEXT JSON. |
| `initiation_friction` | INTEGER | CHECK(1-5), DEFAULT 3 | Bisa berkurang via Automaticity Decay |
| `original_friction` | INTEGER | CHECK(1-5), DEFAULT 3 | **Snapshot baseline** untuk decay calculation |
| `energy_cost` | INTEGER | CHECK(1-5), DEFAULT 3 | TETAP, tidak dipengaruhi decay |
| `total_load_score` | INTEGER | GENERATED | `initiation_friction + energy_cost`. **SQLite ≥ 3.31.0** — gunakan `sqlite3_flutter_libs` |
| `impact_score` | INTEGER | CHECK(1-5), DEFAULT 3 | **UX:** Guided prompt saat membuat habit: *"Seberapa penting habit ini? (1 = tambahan, 5 = sangat penting)"* |
| `lifetime_done_count` | INTEGER | DEFAULT 0 | Counter mentah sepanjang hidup habit; di-increment setiap HabitLog Done. Bukan input utama decay. |
| `weighted_done_score` | REAL | DEFAULT 0 | Materialized score recency-weighted untuk decay; dihitung background. |
| `completion_rate_90d` | REAL | NULLABLE | Done / scheduled opportunities 90 hari terakhir. |
| `last_decay_evaluated_at` | TIMESTAMP | NULLABLE | Kapan decay terakhir dievaluasi. |
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
| `duration_target_min` | INTEGER | NULLABLE | Snapshot target durasi saat log dibuat |
| `duration_actual_min` | INTEGER | NULLABLE | Durasi aktual yang dikerjakan |
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

### `ThinkingCanvasSession` (MVP Lean + Iterasi 1 — Refleksi Paper-First)
| Kolom | Tipe | Constraint | Keterangan |
|-------|------|-----------|------------|
| `session_id` | UUID | PK | |
| `user_id` | UUID | FK → UserProfile | |
| `method_key` | VARCHAR(30) | NOT NULL | 'MindDump', 'Brainstorming', 'Scoring', 'PMI', 'ReverseBrainstorming', 'Validation' |
| `topic` | VARCHAR(200) | NULLABLE | Pertanyaan/topik sesi |
| `raw_notes` | TEXT | NULLABLE, ENCRYPTED | Coretan mentah pengguna; untuk paper-first, boleh hanya ringkasan singkat |
| `summary_text` | TEXT | NULLABLE, ENCRYPTED | Ringkasan hasil corat-coret di kertas |
| `paper_session` | BOOLEAN | DEFAULT TRUE | Sesi dianjurkan/dilakukan di kertas fisik |
| `paper_artifact_ref` | VARCHAR(100) | NULLABLE | Referensi opsional: `Buku A hal. 12`, `sticky notes meja kerja` — tanpa upload foto |
| `structured_output` | JSONB | NULLABLE, ENCRYPTED | Klaster, skor, PMI, risiko, daftar asumsi, dsb. SQLite: TEXT JSON terenkripsi |
| `next_action` | VARCHAR(200) | NULLABLE | Aksi kecil berikutnya; dapat dikonversi ke Habit/Action of the Day |
| `linked_habit_id` | UUID | FK → Habit, NULLABLE | Jika hasil sesi menjadi habit/action |
| `linked_decision_id` | UUID | FK → DecisionJournal, NULLABLE | Jika hasil sesi dikirim ke Decision Journal (Iterasi 2) |
| `created_at` | TIMESTAMP | NOT NULL | |
| `deleted_at` | TIMESTAMP | NULLABLE | Tombstone |

> **Paper-first privacy note:** Foto halaman kertas tidak masuk MVP karena risiko privasi dan storage. Jika kelak ditambahkan, attachment harus opt-in, local-first/E2EE, dan memiliki kontrol hapus/export eksplisit.

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
| `platform` | VARCHAR(20) | NULLABLE | 'ios', 'android', 'web' |
| `billing_period` | VARCHAR(20) | NULLABLE | 'monthly', 'annual' |
| `status` | VARCHAR(30) | DEFAULT 'active' | 'active', 'grace_period', 'expired', 'canceled', 'billing_retry' |
| `store_product_id` | VARCHAR(100) | NULLABLE | Product ID dari store |
| `store_transaction_id` | VARCHAR(150) | NULLABLE | Transaction ID terakhir |
| `original_transaction_id` | VARCHAR(150) | NULLABLE | Untuk subscription chain |
| `current_period_end` | TIMESTAMP | NULLABLE | Akhir periode aktif saat ini |
| `started_at` | TIMESTAMP | | |
| `expires_at` | TIMESTAMP | NULLABLE | Backward-compatible; prefer `current_period_end` |
| `auto_renew` | BOOLEAN | DEFAULT TRUE | |
| `cancelled_at` | TIMESTAMP | NULLABLE | |
| `cancel_reason` | VARCHAR(50) | NULLABLE | 'Price', 'Not_Using', 'Found_Alternative', 'Privacy_Concern', 'Other' |
| `cancel_feedback` | TEXT | NULLABLE | Feedback opsional |
| `student_verification_status` | VARCHAR(30) | NULLABLE | 'unverified', 'verified', 'expired' |
| `student_verified_until` | DATE | NULLABLE | Masa berlaku verifikasi student |

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
| `public_key` | TEXT | NOT NULL | Kunci publik perangkat untuk E2EE handshake. **Format:** Base64-encoded X25519 public key (32 byte raw, encoded ~44 karakter). **Algoritma:** X25519 (ECDH) untuk key exchange. **Enkripsi konten:** AES-256-GCM (12-byte nonce). **Key derivation:** Standard Mode memakai random 256-bit master key di secure storage OS. Advanced Mode dapat memakai recovery phrase/seed untuk recovery material; HKDF-SHA256 dipakai untuk derivasi wrapping/key material yang relevan. **QR transfer:** QR berisi ephemeral X25519 public key + encrypted AES-256 master key (via ECDH shared secret). Masa berlaku QR: 5 menit. |
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
UserProfile 1───∞ ThinkingCanvasSession
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
| `ThinkingCanvasSession` | `(user_id, created_at DESC)` | Riwayat sesi refleksi dan review mingguan |
| `ThinkingCanvasSession` | `(user_id, method_key, created_at DESC)` | Analisis pola metode yang paling sering dipakai |
| `Habit` | `(user_id, status, domain_tag)` | Action of the Day: query habit aktif per domain |
| `WeeklyPulse` | `(user_id, domain_tag, week_start_date DESC)` | Domain score TTL: cek kebaruan skor per domain |
| `WellnessAssessment` | `(user_id, instrument, assessment_date DESC)` | Tren WHO-5/instrumen terstruktur |
| `CrisisPromptLog` | `(user_id, prompted_at DESC)` | Frequency cap: cek kapan terakhir crisis modal ditampilkan |
| `ConsentLog` | `(user_id, consent_type)` | Cek status consent terkini per tipe |

> **Catatan:** `UNIQUE(habit_id, date)` di HabitLog otomatis membuat index composite — tapi tidak mencakup `status`, sehingga index tambahan diperlukan untuk query yang memfilter status.
## 5. Algoritma Mesin & Logic Flow

### A. Algoritma "Action of the Day"

```
domain_deficit = 10 - latest_domain_score  // computed dari UserProfile.latest_domain_scores; fallback ke WeeklyPulse/LifeAudit jika kosong
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

### B. Thinking Canvas Flow

```
Trigger:
  - Pengguna menekan Thinking Canvas dari Dashboard
  - Pengguna memilih “Mulai sesi kertas” dari Journal Lite / Weekly Pulse
  - Friction Intervention menemukan alasan ambigu: "bingung", "takut gagal", atau "terlalu banyak opsi"
  - Weekly Pulse meminta pengguna memilih fokus minggu depan

Langkah:
1. Tampilkan kondisi pengguna: pikiran penuh, belum punya ide, terlalu banyak opsi, ragu, takut gagal, perlu validasi
2. Map kondisi → method_key
3. Sarankan pengguna menulis di buku/kertas asli 5–30 menit
4. Simpan ringkasan digital: paper_session, paper_artifact_ref opsional, summary_text, raw_notes, structured_output
5. Jika next_action terisi:
   - tawarkan "Jadikan Action of the Day" atau "Buat Habit ringan"
6. Jika sesi menghasilkan keputusan besar:
   - tawarkan kirim ke DecisionJournal (Iterasi 2)
7. Weekly Review membaca sesi 7 hari terakhir untuk pertanyaan refleksi:
   - Apa yang jadi lebih jelas?
   - Asumsi apa yang perlu diuji?
   - Apa satu tindakan besok?
```

### C. Algoritma "Automaticity Decay" (Opportunity-Normalized, Recency-Weighted)

```
Prinsip:
  Jangan tanya "berapa kali habit ini done?" secara mentah.
  Tanyakan: dari kesempatan yang memang dijadwalkan, seberapa sering berhasil dilakukan,
  dan apakah exposure-nya cukup untuk frekuensi habit tersebut?

Definitions:
  scheduled_opportunities_90d = jumlah hari/jadwal habit seharusnya dilakukan dalam 90 hari terakhir
  done_count_90d = HabitLog Done dalam scheduled opportunities 90 hari terakhir
  completion_rate_90d = done_count_90d / scheduled_opportunities_90d

  scheduled_opportunities_91_180d = kesempatan terjadwal 91-180 hari lalu
  done_count_91_180d = Done pada rentang tersebut
  weighted_done_score = done_count_90d + (0.5 * done_count_91_180d)

Threshold exposure minimum by frequency:
  Daily      → minimal 45 scheduled opportunities
  3x/Week   → minimal 18 scheduled opportunities
  Weekly    → minimal 8 scheduled opportunities
  Custom    → minimal 6-12 opportunities sesuai schedule_rule_json

Eligibility:
  automaticity_ready = completion_rate_90d >= 0.70
                       AND scheduled_opportunities_90d >= threshold_by_frequency

Action:
  if automaticity_ready:
    decay_step = floor(weighted_done_score / threshold_by_frequency)
    initiation_friction = max(1, original_friction - decay_step)
  else:
    initiation_friction = current value (tidak turun)

  energy_cost = TETAP
  total_load_score = initiation_friction + energy_cost

Stored values:
  lifetime_done_count      = counter mentah untuk statistik/performa, bukan input utama decay
  weighted_done_score      = materialized value untuk decay
  completion_rate_90d      = materialized rate untuk debug/insight
  last_decay_evaluated_at  = timestamp evaluasi terakhir

HIPOTESIS PRODUK:
  Threshold dan rate 0.70 adalah parameter produk, bukan klaim ilmiah baku.
  Dikalibrasi melalui A/B testing setelah data beta cukup.
```

### D. Algoritma "Passive Crisis Intervention"

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
  - > 5 hari tidak buka → 1 push empatik ke Home/Journal Lite (maks. 1x/14 hari)
  - Mood-risk trigger, bukan inactivity, yang boleh deep-link/highlight Safety Card
  - Frequency cap tracked via last_wellness_push_at

Fallback: Nomor primer di-hardcode (119, 119 ext 8 SEJIWA)
Tracking: 'Tapped_Hotline_CTA' (bukan 'Called_Hotline')

Limitasi: Crisis detection hanya seaktif data mood yang tersedia. Jika pengguna aktif membuka app tetapi tidak pernah mengisi mood, sistem tidak boleh mengasumsikan distress. Gunakan prompt mood ringan berkala dan Safety Card always-on sebagai mitigasi non-intrusif.
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
