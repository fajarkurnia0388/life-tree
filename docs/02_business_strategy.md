# Business & Strategy Whitepaper: LifeTree

**Dokumen Konfidensial - Untuk Investor, Stakeholders, & Tim Marketing**

## 1. Ringkasan Eksekutif (The Problem & The Solution)

| | |
|---|---|
| **Masalah** | Pasar aplikasi produktivitas dan *habit tracker* saat ini (senilai miliaran dolar) memiliki masalah fundamental: *Churn rate* (pengguna berhenti) yang sangat tinggi. Hal ini disebabkan oleh "Toxic Productivity" di mana aplikasi mengandalkan fitur *streak* (hari beruntun) yang memicu rasa bersalah (*guilt*) dan kelelahan mental (*burnout*) saat pengguna melewatkan 1 hari saja. |
| **Solusi** | LifeTree adalah **Personal OS (Sistem Orientasi Diri)** yang dirancang secara eksplisit dengan filosofi **Anti-Guilt**. LifeTree mengonversi "kegagalan" menjadi data refleksi (*Friction Journaling*), menyediakan **Thinking Canvas** sebagai pilar refleksi berbasis kertas untuk menjernihkan pikiran dan memilih aksi kecil, serta membantu pengguna memetakan kembali arah hidup mereka secara holistik. |
| **Differentiator** | Dirancang secara eksplisit untuk menghapus mekanisme *punishment loop* dari arsitektur, dengan inspirasi dari behavioral science dan privacy-by-design. |

## 2. Target Pasar & Strategi Peluncuran (Go-to-Market)

### Fase 1 (MVP Core — Daily Orientation Loop, 12–16 Minggu, asumsi 3–5 developer)
- **Target Audiens:** Dewasa muda usia 18-35 Tahun (Mahasiswa tingkat akhir, *First-Jobber*, Profesional).
- **Karakteristik:** Digital-native, memiliki kepedulian tinggi pada *mental health*, rentan terhadap *overwhelm/burnout*.
- **Geografi Awal:** Indonesia (Bahasa Indonesia), ekspansi ke Asia Tenggara di Fase 1.5.
- **Scope awal:** Personal OS tetap menjadi visi, tetapi MVP hanya memvalidasi loop harian: Journal Lite, Habit Tubuh, Action of the Day, Friction Intervention, Recovery Mode, Thinking Canvas Lite, dan Safety Card.

### Fase 2 (Ekspansi Masa Depan)
- Menguasai pasar Gen-Alpha dan Keluarga melalui perilisan *Teen Mode*, *Seedling Mode* (Anak), dan *Parental Dashboard*.
- Bahasa Inggris & ekspansi regional.

## 3. Strategi Monetisasi (Value-Based Freemium)
LifeTree **TIDAK** menjual data pengguna dan **TIDAK** menampilkan iklan (*Zero Targeted Ads*). Monetisasi tidak masuk MVP Core; paid tier dibuka setelah loop harian terbukti dipakai. Privacy/E2EE penuh ditunda karena mahal secara teknis dan harus dibangun sebagai fase terpisah.

| Tier | Harga | Fitur |
|------|-------|-------|
| **Tier Dasar (Gratis)** | Rp 0 | Daily Orientation Loop: Journal Lite, Habit Tubuh, Action of the Day, Friction Intervention, Recovery Mode, Thinking Canvas Lite, Safety Card, Ekspor Lokal (JSON/CSV), dan Dark Mode |
| **LifeTree Plus** | Rp 29.000/bln | On-Device Insights non-AI, PDF Export (jurnal → e-book estetik), Life Compass, Decision Journal, dan kosmetik premium. Cloud Sync/E2EE tidak menjadi janji Plus sampai Privacy/E2EE Phase siap. |
| **LifeTree Student** | Rp 19.000/bln | Sama dengan Plus, dengan verifikasi status mahasiswa (self-declaration honor system + verifikasi email `.ac.id` di Fase 1; bisa ditingkatkan ke third-party verification di kemudian hari). |
| **Annual Plan** | Rp 249.000/thn (hemat ~29%) | Sama dengan Plus — mengunci pengguna dan meningkatkan LTV. |
| **Micro-Transactions (Kosmetik)** | Rp 5.000–15.000/item | Skin spesies pohon (Sakura, Maple, Bonsai, dll) — murni kosmetik. Dark Mode tersedia gratis sebagai fitur aksesibilitas. |

> **Justifikasi Harga Rp 29.000/bln:** Berdasarkan *benchmark* langganan digital di Indonesia (Spotify Student Rp 16.500, YouTube Premium Student Rp 27.500, Netflix Basic Rp 54.000). Harga akan divalidasi melalui A/B testing pada 500 pengguna beta sebelum launch.

## 4. Strategi Akuisisi Pengguna

| Channel | Taktik | Estimasi CAC |
|---------|--------|-------------|
| **Community-Led Growth** | Partnership dengan komunitas mental health & produktivitas di Twitter/X, Discord, dan kampus | Rendah (organik) |
| **Content Marketing** | Edukasi tentang "Toxic Productivity" & "Anti-Guilt" via TikTok/Reels/YouTube Shorts | Rendah–Sedang |
| **University Beta Program** | Kampus ambassador (budget Rp 500K/orang/bulan, KPI: 50 sign-up/bulan, Retention D-30 ≥ 15%) + early access untuk 10 kampus di Jabodetabek & kota besar | Sedang |
| **Referral Program** | "Tanam Bersama" — ajak 1 teman, kedua pohon mendapat bonus kosmetik | Rendah (viral loop) |
| **Product Hunt / Media** | Launch di Product Hunt + press kit ke media tech Indonesia (Tech in Asia ID, DailySocial) | Rendah |

## 5. Key Performance Indicators (KPIs) & Target Sukses

| Metrik | Target | Rasional |
|--------|--------|----------|
| **Day-7 Retention** | ≥ 20% | Baseline realistis untuk *wellness app* |
| **Day-30 Retention** | 10% - 15% | *Top-Quartile* di industri |
| **Shame-Free Return Rate** *(North Star)* | ≥ 30% | **Formula:** `(pengguna absen > 3 hari DAN complete ≥ 1 habit dalam 7 hari setelah Friction Intervention) / (total pengguna absen > 3 hari DAN melihat Friction Intervention)`. Rolling 30 hari. |
| **Weekly Clarity Rate** | ≥ 40% | Pengguna menyatakan *"Saya tahu apa yang menjadi fokus saya minggu depan"* setelah *Weekly Pulse Check* |
| **Clarity-to-Action Rate** | ≥ 35% | Sesi Thinking Canvas yang berakhir dengan 1 aksi kecil, asumsi yang diuji, atau kandidat Action of the Day |
| **Paper Reflection Adoption** | ≥ 25% | Pengguna aktif mingguan yang menandai minimal 1 sesi Thinking Canvas sebagai paper session |
| **WHO-5 Well-being Monitoring** | Pantau tren skor WHO-5 setiap 90 hari | Indikator monitoring, bukan klaim kausal. UX: di Weekly Pulse (opsional), hasil sebagai tren pribadi. |
| **Anti-Guilt Score** *(Internal)* | Pantau secara internal, bukan KPI publik | Rasio (Friction Journaling + Recovery Mode) / total Missed. Semakin tinggi → semakin banyak fitur suportif digunakan. |
| **CAC : LTV Ratio** | ≤ 1:3 | LTV = ARPU × (1/churn). Asumsi: Plus Rp 29K/bln, churn 15% → LTV ≈ Rp 193K. CAC maks ≤ Rp 64K. Sensitivitas: churn 20% → LTV Rp 145K; churn 10% → LTV Rp 290K. |

## 6. Rencana Pengukuran Dampak

| Metode | Jadwal | Tujuan |
|--------|--------|--------|
| **Kuantitatif: Shame-Free Return Rate** | Rolling 30 hari | Pantau apakah pengguna kembali setelah absen tanpa merasa dihukum |
| **Kualitatif: User Interview** | Bulan 2, 4, 6 pasca-launch (10–15 user per sesi) | Pahami *mengapa* pengguna kembali/berhenti; validasi filosofi Anti-Guilt |
| **Perceived Support Score** | Tiap 30 hari (1 pertanyaan in-app) | *"Pohon saya mendukung saya bulan ini"* — skala 1–5 |
| **A/B Testing: Onboarding Flow** | Bulan 1–2 | Validasi jumlah pertanyaan onboarding dan copy anti-guilt |
| **A/B Testing: Automaticity Decay Rate** | Setelah Iterasi 1 punya cukup data | Variant A: decay per 15 hari. Variant B: 20 hari (default). Variant C: 30 hari. Metrik: Retention D-30, Shame-Free Return Rate, Perceived Support Score. |

## 7. Internasionalisasi (i18n)

Fase 1 hanya Bahasa Indonesia, tapi struktur i18n disiapkan sejak awal:
- String UI di file terpisah (`id.json`, `en.json`), bukan hardcode di widget.
- Format tanggal/waktu menggunakan `Intl` package Flutter (locale-aware).
- Teks copywriting Anti-Guilt perlu di-lokalize oleh *native speaker* — filosofi empati bersifat kultural, bukan sekadar diterjemahkan.

## 8. Analisis Kompetitif

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

**Catatan:** Competitive positioning based on publicly observable product behavior at time of writing; not legal certification.

**Differentiator Utama:**
1. Secara eksplisit menghindari *streak punishment* — berbeda dari mayoritas habit apps berbasis loss aversion.
2. *Canopy Load System* — tidak ada di kompetitor.
3. *Life Audit / Radar Keseimbangan* — integrasi 6 domain.
4. *Friction Journaling* — kegagalan = data refleksi.
5. *Thinking Canvas* — pilar refleksi paper-first untuk membangun kebiasaan corat-coret di kertas asli dan mengubah kebingungan menjadi aksi kecil.
6. *Compliance* anak Indonesia (PP TUNAS) sebagai fase masa depan.
7. *Privacy roadmap* yang dimulai dari minimisasi data lokal, lalu naik ke E2EE setelah core retention terbukti.

**Notion Life OS:** Kompetitor indirect — template gratis/berbayar untuk life management. LifeTree unggul di: guided experience, native mobile, automation built-in, dan privacy roadmap yang lebih ketat. Rekomendasi: fitur import dari Notion di Fase 1.5 untuk menurunkan switching cost.

**Gap Pasar Indonesia:** Tidak ada pemain lokal yang memadukan jurnal + habit tracker + life audit. Aplikasi kesehatan mental Indonesia (Riliv, Kalm) fokus pada terapi/konseling — bukan *self-orientation* harian.
