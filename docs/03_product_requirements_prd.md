# Product Requirements Document (PRD): Daoji

**Dokumen Spesifikasi Desain - Untuk Product Manager & Desainer UI/UX**

## 1. Visi Produk & Scope MVP
Daoji adalah aplikasi yang memadukan jurnal, *habit tracker*, dan peta tujuan hidup. MVP **HANYA** ditujukan untuk pengguna Dewasa (18-35 tahun). Semua desain layar untuk mode anak, remaja, dan *parental control* TIDAK dimasukkan di MVP.

## 2. Struktur Layar Utama (Central Command Dashboard)
Saat pengguna membuka aplikasi, layar "Home" menampilkan **3 elemen** di MVP Lean (Radar ditambahkan di Iterasi 1):

```
┌─────────────────────────┐
│     🌳 Visual Pohon     │  ← Tree Vitality: tumbuh seiring konsistensi,
│    (Tree Vitality)       │     berubah sesuai Current Season
│                          │     HARD RULE: TIDAK PERNAH mengecil/mati
├─────────────────────────┤
│   📋 Action of the Day  │  ← 1 Kartu besar: habit prioritas hari ini
│     (Aksi Prioritas)     │     dipilih oleh algoritma
│                          │     Celebration State jika semua Done
├─────────────────────────┤
│   📝 Quick Journaling   │  ← 1 ketuk → Journal Lite (emoji mood)
│       (Akar)             │
└─────────────────────────┘
```

### Tree Vitality State Specification

| State Visual | Kondisi | Representasi |
|-------------|---------|-------------|
| **Seedling** | 0–7 hari kumulatif | Tunas kecil |
| **Sapling** | 8–30 hari | Batang muda, 2–3 daun |
| **Young Tree** | 31–60 hari | Dedaunan mulai rimbun |
| **Mature Tree** | > 60 hari | Pohon dewasa, daun penuh |
| **Blooming** | Automaticity Decay aktif | Bunga/buah di cabang (Iterasi 1) |
| **Snow-Covered** | Recovery Mode aktif | Bersalju lembut |

**Growth:** Step-based (milestone), Story Moment tiap 30 hari.

### Action of the Day — Exit States

- **Celebration State:** Semua habit Done → *"Hari ini milikmu. Pohonmu sedang tumbuh. 🌳"*
- **Cold Start:** Pengguna baru → gunakan LifeAudit onboarding; jika belum ada habit → onboarding prompt.
- **Domain_deficit = 0:** Domain sempurna tidak pernah menjadi target.

## 3. User Journey & Alur Layar (User Flows)

### A. Onboarding (Progressive Profiling)

| Tahap | Waktu | Aksi | Beban Kognitif |
|-------|-------|------|---------------|
| **Welcome Screen** | Hari 1 | Jelaskan filosofi Anti-Guilt. Tanya 1 pertanyaan *Life Audit* (pertanyaan #1 Tubuh). | Rendah |
| **Privasi Lokal** | Hari 1 | Jelaskan bahwa MVP Core menyimpan data di perangkat, tanpa akun dan tanpa cloud sync. | Rendah |
| **Full Audit** | Akhir Minggu 1 | Sisa pertanyaan audit diselesaikan saat *Weekly Pulse* pertama. | Sedang |
| **Medical Disclaimer** | Hari 1 | Scroll + checkbox: *"Daoji adalah alat refleksi diri, BUKAN pengganti konseling profesional."* | Rendah |

### B. Friction Intervention (Flow Saat Gagal Habit)
Trigger intervensi **bervariasi berdasarkan frekuensi habit**:

| Frekuensi Habit | Trigger Intervensi |
|-----------------|-------------------|
| Daily | 3x Missed dalam 7 hari |
| 3x/Minggu | 2x Missed dalam 7 hari (dari 3 jadwal) |
| Weekly | 2x Missed berturut-turut |
| Custom | `(missed / scheduled_per_period) > 0.5` |

```
1. Muncul Pop-up ramah
   └→ Teks: "Hari ini sepertinya berat. Apa hambatan terbesarmu kemarin?"

2. Pilihan:
   ├→ (A) Kurang Waktu  → "Mau potong durasi jadi `mva_duration_min` menit saja besok?"
   │                       Jika diterima: target durasi besok = `mva_duration_min` menit (one-time override).
   │                       Durasi aktual dicatat di `duration_actual_min`. Override otomatis terhapus setelah 1 kali.
   ├→ (B) Kelelahan     → "Mau aktifkan Recovery Mode?"
   └→ (C) Lupa          → "Mau tumpuk habit ini ke rutinitas yang sudah ada?"

3. Jika pilih (B) → Recovery Mode Flow:
   ┌──────────────────────────────────────┐
   │ "Tidak apa-apa untuk istirahat."     │
   │                                      │
   │ Mau aktifkan Recovery Mode?          │
   │ - Semua notifikasi habit di-pause    │
   │ - Pohonmu tetap terawat saat kamu beristirahat      │
   │ - Kamu tetap bisa journaling         │
   │                                      │
   │ Durasi: [1 hari] [3 hari] [7 hari]  │
   │                                      │
   │ [Tidak, Terima Kasih] [Ya, Istirahat]│
   └──────────────────────────────────────┘
   → Semua habit status → Paused
   → Dashboard menampilkan pohon bersalju (Snow-Covered)

4. Apapun pilihannya → log sebagai friction_reason_selected di HabitLog
```

### C. Weekly Pulse Check (Akhir Minggu)
- Setiap hari Minggu, muncul notifikasi untuk *Weekly Pulse*.
- Pengguna menjawab 1 pertanyaan refleksi per domain aktif.
- WHO-5 ditampilkan di Weekly Pulse (opsional, bukan wajib). Hasil sebagai tren pribadi.
- Pulse Check dirancang < 2 menit.

### D. Out-of-App Wellness Check
- Jika pengguna tidak membuka aplikasi > 5 hari:
  - Kirim 1 push notification empatik: *"Kalau hari-hari ini berat, kamu bisa mulai dari sesuatu yang kecil 🌱"*
  - Deep-link ke Home / Journal Lite. Safety Card tetap always-on, tetapi inactivity saja tidak dianggap distress. Maks. 1x per 14 hari (tracked via `last_wellness_push_at`).


### E. Thinking Canvas — Pilar Refleksi Berbasis Kertas

Thinking Canvas adalah pilar refleksi berbasis kertas dalam Lapis 0 Daoji. Mode ini muncul saat pengguna buntu, terlalu banyak opsi, ragu pada rencana, takut gagal, atau perlu mengubah ide menjadi aksi kecil. Prinsip utamanya: **Daoji tidak menggantikan buku catatan**. Daoji menyarankan pengguna membangun kebiasaan corat-coret di buku/kertas asli, lalu menyimpan ringkasan hasilnya di aplikasi.

Untuk mempermudah penggunaan awal, disediakan **Panduan Interaktif (Onboarding Tour)** berupa dialog 4-langkah. Pada langkah pemilihan metode, disediakan tombol pilihan interaktif berdasarkan kondisi kognitif pengguna saat ini (misalnya: Pikiran Penuh → Mind Dump, Ragu → PMI) yang secara dinamis memperbarui pilihan Dropdown formulir di halaman utama secara real-time. Panduan ini juga dapat diakses ulang melalui tombol bantuan di AppBar.

| Kondisi Pengguna | Metode yang Disarankan | Output Produk |
|------------------|------------------------|---------------|
| Pikiran penuh | Mind Dump + Cluster + Refine | 1 klaster pikiran + 1 aksi kecil |
| Belum punya ide | Brainstorming Klasik | 20–30 ide mentah |
| Terlalu banyak opsi | Skoring Ide Sederhana | 2–3 kandidat prioritas |
| Ragu pada ide | PMI (Plus, Minus, Implications) | Keputusan: lanjut/ubah/butuh data/tunda |
| Takut gagal | Reverse Brainstorming | 3 risiko utama + pencegahan |
| Perlu uji nyata | Validasi Ide 48 Jam–2 Minggu | Sinyal awal dari calon pengguna/lingkungan |

#### Paper-First Interaction Model

1. Daoji menyarankan metode berdasarkan kondisi pengguna.
2. Pengguna dianjurkan mengambil buku/kertas asli.
3. Pengguna melakukan sesi corat-coret 5–30 menit: mind dump, mind map, skoring ide, PMI, reverse brainstorming, atau validasi asumsi.
4. Setelah selesai, pengguna hanya memasukkan ringkasan:
   - metode yang dipakai,
   - temuan utama,
   - asumsi yang perlu diuji,
   - satu aksi kecil.
5. Aksi kecil dapat dikirim ke Action of the Day atau disimpan untuk Weekly Pulse.

**MVP copy principle:** *“Gunakan kertas untuk berpikir. Gunakan Daoji untuk memilih metode, menyimpan ringkasan, dan menentukan aksi kecil.”*

#### Thinking Canvas Integration Contract

| Elemen | Kontrak Produk |
|--------|----------------|
| Entry point | Dashboard, Friction Intervention, Weekly Pulse, dan Decision Journal (Iterasi 2) |
| Trigger | User buntu, terlalu banyak opsi, ragu, takut gagal, atau perlu validasi ringan |
| Mode | Ringan = 3 field (topik, coretan, aksi kecil). Penuh = metode terstruktur sesuai kondisi |
| Data output | `ThinkingCanvasSession`: `method_key`, `topic`, `paper_session`, `paper_artifact_ref`, `summary_text`, `raw_notes`, `structured_output`, `next_action` |
| Relasi | `linked_habit_id` jika menjadi habit/action; `linked_decision_id` jika dikirim ke Decision Journal |
| Scope | Thinking Canvas Lite masuk MVP Lean P0; Thinking Canvas Full masuk Iterasi 1 P1. Bukan Plus-gated untuk mode ringan. Export/PDF bisa menjadi Plus value later |
| Algorithmic effect | Tidak otomatis mengubah rekomendasi tanpa konfirmasi user. `next_action` bisa ditawarkan menjadi Action of the Day |

**Integrasi Daoji:**
- Hasil Thinking Canvas dapat diubah menjadi **Action of the Day**.
- Hambatan yang muncul dapat masuk ke **Friction Journal**.
- Keputusan penting dapat dikirim ke **Decision Journal** (Iterasi 2).
- Review mingguan memakai pertanyaan: *Apa yang jadi lebih jelas? Asumsi apa yang perlu diuji? Apa satu tindakan besok?*

## 4. Panduan Copywriting (UX Writing Guidelines)
**Nada Suara (Tone of Voice):** Empatik, Tenang, Netral, Mendukung.

| ❌ JANGAN | ✅ GUNAKAN |
|-----------|-----------|
| *"Kamu merusak streak-mu! Kembali ke Nol."* | *"Pohonmu sedang beristirahat. Kapanpun kamu siap, mari menanam lagi."* |
| *"Hapus Habit."* | *"Arsipkan Habit (Beri ruang untuk hal lain)."* |
| *"Gagal / Failed."* | *"Missed (Terlewat) / Paused (Jeda)."* |
| *"Kamu belum menyelesaikan tugas hari ini!"* | *"Ada sesuatu yang bisa kamu lakukan hari ini, meski hanya 2 menit."* |
| *"Peringatan! Streak-mu terputus."* | *"Pohonmu sedang beristirahat. Tidak apa-apa."* |

## 5. Aksesibilitas Visual (Accessibility - WCAG 2.1 AA)
- Radar Chart wajib memiliki versi alternatif berupa **List View / Tabel** bagi *screen reader*.
- Hindari penggunaan indikator yang HANYA mengandalkan warna — gunakan kombinasi **warna + Ikon + label teks**.
- Navigasi aman bagi pengguna *neurodivergent* (tanpa animasi flash, tanpa suara tiba-tiba).
- Ukuran *touch target* minimum 48×48dp.
- **Palet "Calm Tech":** Warna yang secara konvensional diasosiasikan dengan ketenangan (hijau sage, biru redup, krem). Hindari animasi cepat.

## 6. Scope MVP — Canonical Scope Matrix

MVP Core tetap membawa visi **Personal OS**, tetapi implementasinya dipangkas menjadi **Daily Orientation Loop**: Journal Lite → Action of the Day → Friction Intervention/Recovery Mode → ringkasan refleksi kecil. Fitur privacy/E2EE penuh ditunda sampai loop ini terbukti dipakai.

| Fitur | MVP Lean | Iterasi 1 | Iterasi 2 | Fase 2 |
|-------|:--------:|:---------:|:---------:|:------:|
| Journal Lite | ✅ P0 | — | — | — |
| Deep Reflection | ❌ | ✅ P1 | — | — |
| Thinking Canvas Lite (paper-first summary) | ✅ P0 | — | — | — |
| Thinking Canvas Full | ❌ | ✅ P1 | — | — |
| Friction Intervention | ✅ P0 | — | — | — |
| Safety Card | ✅ P0 | — | — | — |
| Canopy Load | ✅ P0 | — | — | — |
| Automaticity Decay | ❌ | ✅ P1 | — | — |
| Domain Tubuh | ✅ P0 | — | — | — |
| Domain 5 lainnya | ❌ | ❌ | ✅ P1 | — |
| Radar Keseimbangan | ❌ | ✅ P1 | — | — |
| Action of the Day | ✅ P0 | — | — | — |
| Tree Vitality (basic) | ✅ P0 | — | — | — |
| Tree Vitality (Blooming) | ❌ | ✅ P1 | — | — |
| Weekly Pulse + WHO-5 | ❌ | ✅ P1 | — | — |
| Life Compass | ❌ | ✅ P1 | — | — |
| Decision Journal | ❌ | ❌ | ✅ P2 | — |
| Goal Hierarchy | ❌ | ✅ P1 | — | — |
| Cloud Sync | ❌ | ❌ | ❌ | ✅ |
| Zero-Knowledge E2EE | ❌ | ❌ | ❌ | ✅ |
| On-Device Insights (non-AI) | ❌ | ✅ P1 | — | — |
| On-Device Insights (AI) | ❌ | ❌ | ❌ | ✅ |
| Micro-transaksi | ❌ | ❌ | ✅ P2 | — |
| Teen/Seedling Mode | ❌ | ❌ | ❌ | ✅ |

### MVP Core (Daily Orientation Loop — 12–16 Minggu untuk 3–5 developer; 18–24 minggu untuk 1–2 developer)

| Komponen | Fitur | Prioritas |
|----------|-------|-----------|
| Onboarding | Life Audit (domain Tubuh, 1 pertanyaan) | P0 |
| Onboarding | Medical Disclaimer (scroll + checkbox) | P0 |
| Dashboard | Central Command Dashboard (3 elemen: Pohon + Action + Journal) | P0 |
| Dashboard | Tree Vitality (Seedling → Mature + Snow-Covered) | P0 |
| Dashboard | Action of the Day + Celebration State | P0 |
| Lapis 0 | Journal Lite (emoji + keyword) | P0 |
| Lapis 0 | Thinking Canvas Lite (paper-first prompt + simpan ringkasan) | P0 |
| Lapis 0 | Friction Intervention (threshold per frekuensi + Recovery Mode duration selector) | P0 |
| Lapis 0 | Safety Card (hardcoded 119 + 119 ext 8) | P0 |
| Lapis 1 | Canopy Load System (friction + energy, soft enforcement) | P0 |
| Lapis 2 | Domain Tubuh saja | P0 |
| Privacy | Local-only storage, tanpa akun dan tanpa cloud sync | P0 |
| Security | Dark Mode (aksesibilitas, bukan kosmetik) | P0 |
| Security | Ekspor Lokal (JSON/CSV) | P0 |
| Accessibility | Screen Reader + Color+Icon+Label | P0 |
| Monetisasi | Tier Gratis | P0 |

### Iterasi 1 (Bulan 3–4 setelah core stabil)

| Komponen | Fitur | Prioritas |
|----------|-------|-----------|
| Dashboard | Radar Keseimbangan (domain Tubuh + Coming Soon) | P1 |
| Dashboard | Tree Vitality Blooming state | P1 |
| Lapis 0 | Deep Reflection (opsional) | P1 |
| Lapis 0 | Thinking Canvas Full: skoring, reverse brainstorming, validasi, review mingguan, Decision Journal link | P1 |
| Lapis 0 | Anti-Banner-Blindness Safety Card | P1 |
| Weekly | Weekly Pulse Check + WHO-5 (opsional) | P1 |
| Notification | Out-of-App Wellness Check | P1 |
| Lapis 1 | Automaticity Decay (recency-weighted) | P1 |
| Privacy | SQLCipher/local encrypted backup + app-level biometric lock | P1 |
| Monetisasi | Daoji Plus (Insights non-AI, PDF Export, Life Compass, Decision Journal preview) | P1 |
| Monetisasi | Daoji Student (self-declaration + `.ac.id`) | P1 |
| Monetisasi | Annual Plan Rp 249K/thn | P1 |
| Lapis 3 | Life Compass (3 Core Values) | P1 |
| Lapis 1 | Goal Hierarchy (2 level: Project → Habit) | P1 |

### Iterasi 2 (Fase 1.5)

| Komponen | Fitur | Prioritas |
|----------|-------|-----------|
| Lapis 2 | Domain Keuangan, Hubungan, Emosi, Karir, Rekreasi (bertahap) | P1 |
| Monetisasi | Micro-transaksi kosmetik (skin pohon saja, Dark Mode gratis) | P2 |
| Lapis 3 | Decision Journal | P2 |
| Marketplace | **Habit Template Marketplace**: Upload, share, rate (1-5 stars), and download habit configurations to local database, with 100% E2EE/anonymous profile isolation and no social loops (no comments/likes) | P1 |

### OUT (Fase 2)
- Teen Mode (13–17 tahun)
- Seedling Mode (< 13 tahun)
- Parental Dashboard
- Age Graduation
- Goal Hierarchy level Visi (5 tahun)
- Cloud Sync, zero-knowledge E2EE, seed phrase, recovery contact, key rotation, dan sync conflict resolution
- On-Device Insights (AI-based)
- Bahasa Inggris & regionalisasi
