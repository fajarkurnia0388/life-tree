# Whitepaper: Sistem Orientasi Diri "LifeTree" (Grow)
**Versi 14.0 (Master Product & System Spec) – Daily Orientation Loop, Privacy Roadmap, Arsitektur Sistem & Panduan UX**

## 1. Pendahuluan & Filosofi (Anti-Guilt)
LifeTree adalah **Personal OS** untuk orientasi hidup. Dibangun di atas 3 pilar teori:

| Pilar | Referensi | Implikasi Desain |
|-------|-----------|-----------------|
| **Habit Formation** | Lally et al. (2010), UCL | Otomatisasi butuh 18–254 hari (median 66). Kehilangan 1 hari ≠ gagal. |
| **Canopy Load (Konstruk Produk)** | — | Kapasitas harian terbatas; sistem mencegah *overload*. Bukan backing ilmiah yang kuat — lihat §2.2 README untuk konteks ego depletion replication crisis. |
| **Behavioral Design** | Fogg Behavior Model (B=MAP) | Intervensi presisi berdasarkan akar hambatan (Motivasi, Kemampuan, Pemicu). |

**Filosofi inti:** Aplikasi produktivitas konvensional mengandalkan *loss aversion* via sistem *streak* — memicu rasa bersalah dan *burnout* saat pengguna melewatkan 1 hari. LifeTree menolak pendekatan ini dan membangun arsitektur **Anti-Guilt**: kegagalan dikonversi menjadi data refleksi, bukan hukuman.

### Referensi Akademis
- Lally, P., van Jaarsveld, C. H. M., Potts, H. W. W., & Wardle, J. (2010). *How are habits formed: Modelling habit formation in the real world.* European Journal of Social Psychology, 40(6), 998–1009.
- Sweller, J. (1988). *Cognitive load during problem solving: Effects on learning.* Cognitive Science, 12(2), 257–285.
- Fogg, B. J. (2009). *A behavior model for persuasive design.* Proceedings of the 4th International Conference on Persuasive Technology.
- World Health Organization. (1998). *WHO-5 Well-Being Index.* WHO Regional Office for Europe.
- Deci, E. L., & Ryan, R. M. (2000). *The "What" and "Why" of Goal Pursuits: Human Needs and the Self-Determination of Behavior.* Psychological Inquiry, 11(4), 227–268.
- Duhigg, C. (2012). *The Power of Habit.* Random House. *(Habit Loop: Cue–Routine–Reward)*
- Gollwitzer, P. M. (1999). *Implementation Intentions.* American Psychologist, 54(7), 493–503. *(Strategi "kapan-dimana")*

## 2. Central Command Dashboard (Layar Utama)

MVP Lean menampilkan **3 elemen** (Radar ditambahkan di Iterasi 1):

1. **Visual Pohon (Tree Vitality):** Status kesehatan sistem. **Hard Rule Anti-Guilt:** Pohon TIDAK PERNAH mengecil atau mati — hanya bisa tumbuh atau "istirahat" (bersalju).
   - **State Visual:**
     | State | Kondisi | Visual |
     |-------|---------|--------|
     | Seedling | 0–7 hari kumulatif | Tunas kecil |
     | Sapling | 8–30 hari | Batang muda, 2–3 daun |
     | Young Tree | 31–60 hari | Dedaunan mulai rimbun |
     | Mature Tree | > 60 hari | Pohon dewasa, daun penuh |
     | Blooming | Automaticity Decay aktif | Bunga/buah muncul (Iterasi 1) |
     | Snow-Covered | Recovery Mode | Bersalju lembut |
   - **Growth:** Step-based (milestone), bukan linear. Story Moment tiap 30 hari.
2. **Current Season (Konteks Hidup):**
   | Season | Trigger | Perilaku |
   |--------|---------|----------|
   | Growth (Default) | Normal | Semua berjalan normal |
   | Recovery | Manual/Hybrid | Notifikasi pause, pohon bersalju, durasi 1/3/7 hari |
   | Dormant | > 14 hari tidak buka app | Notifikasi dikurangi; saat pengguna kembali, sistem menawarkan review habit. Visual memakai kabut/cahaya redup/idle lebih lambat — bukan daun rontok/regresi. |
3. **Action of the Day (Algoritma Prioritas):**
   `domain_deficit = 10 - latest_domain_score`
   `priority_score = (domain_deficit * impact_score) / (initiation_friction + energy_cost)`
   - **Celebration State:** Jika semua habit Done → *"Hari ini milikmu. Pohonmu sedang tumbuh. 🌳"*
   - **Cold Start Fallback:** Pengguna baru → gunakan skor LifeAudit onboarding; jika belum ada habit → prompt onboarding.
   - **Domain_deficit = 0:** Domain sempurna tidak pernah menjadi target.
   - **Domain Score TTL:** Fresh (0–14 hari), Stale (15–30, tampilkan indikator), Expired (> 30, fallback ke LifeAudit awal).

## 3. Arsitektur Modul (Peta Lapis) & Spesifikasi Algoritma

```
Lapis 3: 🍎 Buah & Kompas (Advanced)     → Life Compass, Decision Journal
Lapis 2: 🌿 Cabang (6 Domain Kehidupan)   → Keuangan, Tubuh, Hubungan, Emosi, Karir/Belajar, Rekreasi
Lapis 1: 🪵 Batang (Canopy Load & Goals)  → Manajemen beban, Goal Hierarchy
Lapis 0: 🌱 Akar (Refleksi & Diagnosis)   → Journal Lite, Deep Reflection, Thinking Canvas, Friction Journaling, Weekly Pulse, Safety Card
```

### Lapis 0: Akar (Refleksi Adaptif & Diagnosis)
- **Adaptive Micro-Journaling:**
  - *Journal Lite (Default):* Hanya 1 ketuk emoji mood + 1 kata kunci.
  - *Deep Reflection:* 3 pertanyaan + *Gratitude prompt* (Hanya jika pengguna memilih).
- **Thinking Canvas — Pilar Refleksi Berbasis Kertas:** mode paper-first untuk kondisi buntu, terlalu banyak opsi, ragu pada rencana, atau perlu mengubah ide menjadi aksi kecil. Pengguna dianjurkan corat-coret di buku/kertas asli; LifeTree menyimpan ringkasan digital berupa metode, temuan, asumsi, dan aksi kecil.
- **Friction Journaling & Status Habit:**
  Habit memiliki 5 status: *Done, Missed, Skipped Intentionally, Paused*, dan implisit *Not_Scheduled* (hari di luar jadwal — tidak ada log dibuat).
  - *Daily:* 3x Missed dalam 7 hari
  - *3x/Minggu:* 2x Missed dalam 7 hari (dari 3 jadwal)
  - *Weekly:* 2x Missed berturut-turut
  - *Custom:* `(missed / scheduled_per_period) > 0.5`
- **Opsi "Kurang Waktu":** Saat user pilih "Kurang Waktu", sistem menawarkan one-time override durasi ke `mva_duration_min` menit untuk hari berikutnya. Durasi aktual dicatat di `duration_actual_min` HabitLog. Override otomatis terhapus setelah 1 kali.

### Lapis 1: Batang (Canopy Load & Goal Hierarchy)
- **Canopy Load:**
  Default kapasitas: 10 poin. **Enforcement:** Soft — peringatan ramah jika melebihi, pengguna tetap bisa menambahkan (Anti-Guilt).
  - *Automaticity Decay:* **Recency-weighted cumulative** — 90 hari terakhir bobot 1, 91-180 hari bobot 0.5, >180 hari tidak dihitung. `lifetime_done_count` counter dan `weighted_done_score` materialized value di Habit table untuk performance. `original_friction` snapshot untuk referensi baseline. Formula decay adalah **model produk yang disederhanakan**, bukan representasi langsung dari Lally et al. — akan dikalibrasi via A/B testing.
- **Goal Hierarchy:** Visi (5 Thn) → Project (Tenggat Waktu) → Habit Harian / *Tasks*.

### Lapis 2: Cabang (6 Domain Kehidupan)
| Domain | Contoh Habit | Catatan |
|--------|-------------|---------|
| 🏃 Tubuh | Olahraga 30 menit | **Domain MVP** — paling terukur & intuitif |
| 💰 Keuangan | Catat pengeluaran harian | Fase 1.5 |
| 🤝 Hubungan | Hubungi 1 teman/keluarga | Fase 1.5 |
| 💭 Emosi | Journaling 5 menit | Fase 1.5 |
| 📚 Karir/Belajar | Baca 10 halaman | Fase 1.5 |
| 🎮 Rekreasi | Main game 30 menit | Fase 1.5 |

> **MVP:** Hanya domain Tubuh aktif saat peluncuran. Domain lain tampil sebagai "Coming Soon" di Radar (Iterasi 1).

- *Tagging Opsional:* Smart Suggestion saat men-tag habit ke domain.

### Lapis 3: Buah & Kompas (Advanced — LifeTree Plus)
- **Life Compass:** 3 Core Values opsional — didukung Self-Determination Theory (Deci & Ryan, 2000).
- **Decision Journal:** Mencatat keputusan sulit + pengingat review 90 hari. **Iterasi 2 (P2)**, bukan Scope OUT.

## 4. Panduan Copywriting UX (Anti-Guilt Tone Guidelines)
Aplikasi harus di-*coding* dengan tata bahasa empati.

| ❌ JANGAN | ✅ GUNAKAN |
|-----------|-----------|
| *"Kamu gagal menyelesaikan habit ini! Streak-mu kembali ke nol."* | *"Hari ini sepertinya berat. Tidak apa-apa, mau coba versi 2-menitnya saja atau istirahat?"* |
| *"Hapus habit ini."* | *"Arsipkan habit ini untuk memberi ruang yang lebih penting bulan ini."* |
| *"Gagal / Failed."* | *"Terlewat (Missed) / Jeda (Paused)."* |
| *"Kamu belum menyelesaikan tugas hari ini!"* | *"Ada sesuatu yang bisa kamu lakukan hari ini, meski hanya 2 menit."* |
| *"Peringatan! Streak-mu terputus."* | *"Pohonmu sedang beristirahat. Tidak apa-apa."* |

## 5. Segmentasi Usia, Privasi Bertahap & Aksesibilitas
- **Hukum Privasi (PP TUNAS & Permenkomdigi 9/2026):** Usia 13-17 (Teen Mode) mendapat privasi jurnal mutlak; Orang Tua di dasbor HANYA menerima tren agregat dan *Conversation Starters*. PP 17/2025 menetapkan 5 kelompok usia: 3–5, 6–9, 10–12, 13–15, 16–<18; Permenkomdigi 9/2026 mengatur tahapan implementasi dan klasifikasi risiko platform. LifeTree Fase 1 menggunakan <13/13–17; Fase 2 mengikuti granularitas ini.
- **Usia < 13 Tahun:** Wajib *Offline-First* mutlak. **Biometrik tidak digunakan untuk akun anak** (*precautionary principle*).
- **Age Graduation:** Tepat hari ulang tahun ke-18, revoke akses orang tua otomatis. Membutuhkan `date_of_birth`, bukan hanya `age_band`.
- **MVP Core Privacy:** Data lokal di perangkat, tanpa akun, tanpa cloud sync, tanpa targeted ads. Ekspor JSON/CSV manual tetap tersedia.
- **Privacy Hardening:** SQLCipher/local encrypted backup, app-level biometric lock, dan retensi `WellnessPromptLog` masuk setelah Daily Orientation Loop terbukti dipakai.
- **Privacy/E2EE Phase:** Cloud Sync, zero-knowledge E2EE, seed phrase, recovery contact, key rotation, dan sync conflict resolution ditunda sebagai fase tersendiri.
- **Multi-Layer Wellness Disclaimer:** Onboarding (scroll+checkbox), Wellness Prompt pertama (acknowledge), Safety Card (always visible). `wellness_disclaimer_acknowledged` di UserProfile, dicatat di ConsentLog.
- **Aksesibilitas (WCAG 2.1 AA):** Screen Reader, color+icon+label, touch target 48×48dp. Palet *Calm Tech* — warna yang diasosiasikan dengan ketenangan (hijau sage, biru redup, krem).

## 6. Keselamatan Pengguna (Passive Wellness & Emergency Resource Protocol)
LifeTree BUKAN aplikasi medis (Tercantum jelas di T&C).
- Tidak menggunakan AI/keyword untuk prediksi krisis mental (*False Negative/Positive* risk).
- **Passive Safety:** Safety Card permanen. **Nomor primer di-hardcode** (119 PSC, 119 ext 8 SEJIWA).
- **Anti-Banner-Blindness:** Visual berrotasi periodik.
- **Out-of-App Wellness Check:** Jika > 5 hari tidak buka → 1 push empatik (maks. 1x/14 hari, tracked via `last_wellness_push_at`). Deep-link ke Home / Journal Lite. Safety Card tetap always-on, tetapi inactivity saja tidak dianggap distress.
- **Sustained Low-Mood Support (> 14 hari `mood_score ≤ 2`):** Prompt dukungan lebih langsung ke resource profesional, maks. 1x/14 hari. Ini bukan diagnosis.
- **`Called_Hotline` → `Tapped_Hotline_CTA`:** Tracking hanya sampai interaksi UI — apakah panggilan berhasil tidak bisa diketahui.

## 7. Metrik Keberhasilan & Model Bisnis
- **Shame-Free Return Rate** ≥ 30% — Formula: `(pengguna absen > 3 hari DAN complete ≥ 1 habit dalam 7 hari setelah Friction Intervention) / (total pengguna absen > 3 hari DAN melihat Friction Intervention)`. Rolling 30 hari.
- WHO-5 Well-being Monitoring setiap 90 hari — indikator monitoring, bukan klaim kausal. UX: di Weekly Pulse (opsional), hasil sebagai tren pribadi.
- **Day-7 Retention** ≥ 20%, **Day-30 Retention** 10–15%.
- **Anti-Guilt Score (Internal):** (Friction Journaling + Recovery Mode) / total Missed.
- **Value-Based Freemium:** Gratis = Daily Orientation Loop + export. Plus Rp 29K/bln = Insights non-AI + PDF + Life Compass + Decision Journal + kosmetik premium. Student Rp 19K/bln (self-declaration + `.ac.id` email). Annual Rp 249K/thn (hemat ~29%). Cloud Sync/E2EE bukan janji Plus sampai Privacy/E2EE Phase siap.
- **A/B Testing:** Onboarding (bulan 1–2), Automaticity Decay Rate setelah Iterasi 1 cukup data (variant 15/20/30 hari).

### Internasionalisasi (i18n)
String UI file terpisah, format locale-aware, Anti-Guit dilokalize oleh native speaker (bukan diterjemahkan langsung).

## 8. Spesifikasi Minimum Viable Product (MVP)

**Asumsi Tim:** 3–5 developer (12–16 minggu). 1–2 developer: 18–24 minggu realistis.

### MVP Core (Daily Orientation Loop)
- Onboarding Life Audit (domain Tubuh, 1 pertanyaan), Dashboard 3 elemen (Pohon + Action + Journal), Journal Lite, Thinking Canvas Lite (paper-first prompt + ringkasan), Friction Intervention (dengan Recovery Mode duration selector + `mva_duration_min` one-time override), Safety Card (hardcoded), Canopy Load Basic, local-only storage tanpa akun/cloud sync, Export, Accessibility, Tier Gratis.

### Iterasi 1 (Bulan 3–4 setelah core stabil)
- Radar Keseimbangan, Deep Reflection, **Thinking Canvas Full**, Anti-Banner-Blindness, Weekly Pulse + WHO-5, Out-of-App Wellness Check, Automaticity Decay, SQLCipher/local encrypted backup, LifeTree Plus & Student & Annual, Life Compass, Goal Hierarchy, Tree Vitality Blooming.

### Iterasi 2 (Fase 1.5)
- Domain Keuangan/Hubungan/Emosi/Karir/Rekreasi, Micro-transaksi kosmetik, Decision Journal.

### Privacy/E2EE Phase
- Cloud Sync, zero-knowledge E2EE, seed phrase, recovery contact, key rotation, sync conflict resolution, dan DSAR workflow.

Semua fitur untuk Anak/Remaja dan Dasbor Orang tua ditunda ke Fase 2.

## 9. Analisis Kompetitif

| Aplikasi | Streak | Anti-Guilt | Jurnal | Habit | Life Audit | E2EE | Child Safety | Harga |
|----------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|-------|
| **LifeTree** | ❌ | ✅ | ✅ | ✅ | ✅ | Future | ✅ (Fase 2) | Freemium Rp 29K |
| **Fabulous** | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ~Rp 65K/bln |
| **Habitica** | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ~Rp 65K/bln |
| **Streaks** | ✅✅ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | One-time Rp 65K |
| **Day One** | ❌ | Netral | ✅✅ | ❌ | ❌ | ✅ | ❌ | Rp 44K/bln |
| **Reflectly** | ❌ | Netral | ✅ | ❌ | ❌ | ❌ | ❌ | Rp 75K/bln |
| **Finch** | ✅ | Sebagian | ✅ | ✅ | ❌ | ❌ | ❌ | Rp 50K/bln |
| **Daylio** | ❌ | Sebagian | ✅ (mood) | ✅ | ❌ | ❌ | ❌ | Gratis + Premium ~Rp 50K/bln |
| **Notion Life OS** | ❌ | Netral | ❌ | ✅ | Sebagian | ❌ | ❌ | Gratis + template Rp 50-200K |

**Differentiator Utama:**
1. Secara eksplisit menghindari *streak punishment* — berbeda dari mayoritas habit apps berbasis loss aversion.
2. *Canopy Load System* — tidak ada di kompetitor.
3. *Life Audit / Radar Keseimbangan* — integrasi 6 domain.
4. *Friction Journaling* — kegagalan = data refleksi.
5. *Thinking Canvas* — pilar refleksi paper-first untuk membangun kebiasaan corat-coret di kertas asli dan mengubah kebingungan menjadi aksi kecil.
6. *Compliance* anak Indonesia (PP TUNAS).
6. *Privacy roadmap* dari minimisasi data lokal menuju zero-knowledge E2EE setelah core retention terbukti.

**Notion Life OS:** Kompetitor indirect. Keunggulan LifeTree: guided (bukan setup manual), native mobile, automation built-in, dan privacy roadmap yang lebih ketat. Rekomendasi: fitur import dari Notion di Fase 1.5.
