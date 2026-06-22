# Product Requirements Document (PRD): LifeTree

**Dokumen Spesifikasi Desain - Untuk Product Manager & Desainer UI/UX**

## 1. Visi Produk & Scope MVP
LifeTree adalah aplikasi yang memadukan jurnal, *habit tracker*, dan peta tujuan hidup. MVP **HANYA** ditujukan untuk pengguna Dewasa (18-35 tahun). Semua desain layar untuk mode anak, remaja, dan *parental control* TIDAK dimasukkan di MVP.

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
| **Welcome Screen** | Hari 1 | Jelaskan filosofi Anti-Guilt. Tanya 2 pertanyaan *Life Audit* (domain Tubuh). | Rendah |
| **Setup Keamanan** | Hari 3 | **Default:** OS Keychain auto-save (1-ketuk). **Opsi lanjutan:** 12-Word Recovery Key + Recovery Contact (Shamir 2-of-3). | Rendah → Sedang |
| **Full Audit** | Akhir Minggu 1 | Sisa pertanyaan audit diselesaikan saat *Weekly Pulse* pertama. | Sedang |
| **Medical Disclaimer** | Hari 1 | Scroll + checkbox: *"LifeTree adalah alat refleksi diri, BUKAN pengganti konseling profesional."* | Rendah |

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
   ├→ (A) Kurang Waktu  → "Mau potong durasi jadi 5 menit saja besok?"
   ├→ (B) Kelelahan     → "Mau aktifkan Recovery Mode?"
   └→ (C) Lupa          → "Mau tumpuk habit ini ke rutinitas yang sudah ada?"

3. Jika pilih (B) → Recovery Mode Flow:
   ┌──────────────────────────────────────┐
   │ "Tidak apa-apa untuk istirahat."     │
   │                                      │
   │ Mau aktifkan Recovery Mode?          │
   │ - Semua notifikasi habit di-pause    │
   │ - Pohonmu tetap tumbuh perlahan      │
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
  - Kirim 1 push notification empatik: *"Kamu sudah tidur cukup? Pohonmu menunggu dengan sabar 🌱"*
  - Deep-link ke Safety Card. Maks. 1x per 14 hari (tracked via `last_wellness_push_at`).

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

| Fitur | MVP Lean | Iterasi 1 | Iterasi 2 | Fase 2 |
|-------|:--------:|:---------:|:---------:|:------:|
| Journal Lite | ✅ P0 | — | — | — |
| Deep Reflection | ❌ | ✅ P1 | — | — |
| Friction Intervention | ✅ P0 | — | — | — |
| Safety Card | ✅ P0 | — | — | — |
| Canopy Load | ✅ P0 | — | — | — |
| Automaticity Decay | ✅ P0 | — | — | — |
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
| Cloud Sync | ❌ | ✅ P1 | — | — |
| On-Device Insights (non-AI) | ❌ | ✅ P1 | — | — |
| On-Device Insights (AI) | ❌ | ❌ | ❌ | ✅ |
| Micro-transaksi | ❌ | ❌ | ✅ P2 | — |
| Teen/Seedling Mode | ❌ | ❌ | ❌ | ✅ |

### MVP Core (16–20 Minggu — asumsi 3–5 developer; 1–2 developer: 24–30 minggu)

| Komponen | Fitur | Prioritas |
|----------|-------|-----------|
| Onboarding | Life Audit (domain Tubuh, 2 pertanyaan) | P0 |
| Onboarding | OS Keychain setup (1-ketuk, default) | P0 |
| Onboarding | Medical Disclaimer (scroll + checkbox) | P0 |
| Dashboard | Central Command Dashboard (3 elemen: Pohon + Action + Journal) | P0 |
| Dashboard | Tree Vitality (Seedling → Mature + Snow-Covered) | P0 |
| Dashboard | Action of the Day + Celebration State | P0 |
| Lapis 0 | Journal Lite (emoji + keyword) | P0 |
| Lapis 0 | Friction Intervention (threshold per frekuensi + Recovery Mode duration selector) | P0 |
| Lapis 0 | Safety Card (hardcoded 119 + 119 ext 8) | P0 |
| Lapis 1 | Canopy Load System (friction + energy, soft enforcement) | P0 |
| Lapis 1 | Automaticity Decay (60 hari, recency-weighted) | P0 |
| Lapis 2 | Domain Tubuh saja | P0 |
| Security | SQLCipher enkripsi lokal | P0 |
| Security | App-level biometric lock | P0 |
| Security | Local Encrypted Backup | P0 |
| Security | Dark Mode (aksesibilitas, bukan kosmetik) | P0 |
| Security | Ekspor Lokal (JSON/CSV) | P0 |
| Accessibility | Screen Reader + Color+Icon+Label | P0 |
| Monetisasi | Tier Gratis | P0 |

### Iterasi 1 (Bulan 3–4 setelah core stabil)

| Komponen | Fitur | Prioritas |
|----------|-------|-----------|
| Onboarding | 12-Word Recovery Key (opsional, advanced) | P1 |
| Onboarding | Recovery Contact setup (Shamir 2-of-3) | P1 |
| Dashboard | Radar Keseimbangan (domain Tubuh + Coming Soon) | P1 |
| Dashboard | Tree Vitality Blooming state | P1 |
| Lapis 0 | Deep Reflection (opsional) | P1 |
| Lapis 0 | Anti-Banner-Blindness Safety Card | P1 |
| Weekly | Weekly Pulse Check + WHO-5 (opsional) | P1 |
| Notification | Out-of-App Wellness Check | P1 |
| Monetisasi | LifeTree Plus (Cloud Sync, Insights non-AI, PDF Export) | P1 |
| Monetisasi | LifeTree Student (self-declaration + `.ac.id`) | P1 |
| Monetisasi | Annual Plan Rp 199K/thn | P1 |
| Lapis 3 | Life Compass (3 Core Values) | P1 |
| Lapis 1 | Goal Hierarchy (2 level: Project → Habit) | P1 |

### Iterasi 2 (Fase 1.5)

| Komponen | Fitur | Prioritas |
|----------|-------|-----------|
| Lapis 2 | Domain Keuangan, Hubungan, Emosi, Karir, Rekreasi (bertahap) | P1 |
| Monetisasi | Micro-transaksi kosmetik (skin pohon saja, Dark Mode gratis) | P2 |
| Lapis 3 | Decision Journal | P2 |

### OUT (Fase 2)
- Teen Mode (13–17 tahun)
- Seedling Mode (< 13 tahun)
- Parental Dashboard
- Age Graduation
- Goal Hierarchy level Visi (5 tahun)
- On-Device Insights (AI-based)
- Bahasa Inggris & regionalisasi
