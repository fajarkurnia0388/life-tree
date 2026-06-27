# 🌳 LifeTree — Personal OS untuk Orientasi Diri

> **Versi 14.0 (Master Product & System Spec)** — Daily Orientation Loop, Privacy Roadmap, Arsitektur Sistem, Kepatuhan, Strategi Bisnis & Setup Flutter

**Repositori ini adalah canonical documentation hub untuk LifeTree.** README berfungsi sebagai peta induk; detail normatif per domain ditempatkan pada dokumen khusus di folder `docs/`.

## Thinking Canvas — Pilar Refleksi Berbasis Kertas

LifeTree tidak hanya meminta pengguna mencatat mood atau menyelesaikan habit. Di **Lapis 0: Refleksi & Diagnosis**, LifeTree menyediakan **Thinking Canvas**: pilar refleksi berbasis kertas yang membantu pengguna mengurai pikiran, memilih opsi, dan menutup sesi dengan satu aksi kecil.

Thinking Canvas dirancang dengan prinsip **paper-first, app-summary-second**. Pengguna dianjurkan membangun kebiasaan corat-coret di buku/kertas asli — mind dump, mind map, skoring ide, PMI, reverse brainstorming, atau validasi asumsi. LifeTree tidak menggantikan proses berpikir di kertas; LifeTree membantu memilih metode, menjaga ritme refleksi, menyimpan ringkasan, dan menghubungkannya ke Action of the Day, Friction Journal, Weekly Pulse, dan Decision Journal.

---

## Daftar Isi

1. [Pendahuluan & Filosofi Anti-Guilt](#1-pendahuluan--filosofi-anti-guilt)
2. [Landasan Ilmu Perilaku (Behavioral Science)](#2-landasan-ilmu-perilaku-behavioral-science)
3. [Kepatuhan Hukum & Etika Digital (Compliance)](#3-kepatuhan-hukum--etika-digital-compliance)
4. [Strategi Bisnis & Go-to-Market](#4-strategi-bisnis--go-to-market)
5. [Product Requirements & Desain UX](#5-product-requirements--desain-ux)
6. [Arsitektur Modul & Algoritma](#6-arsitektur-modul--algoritma)
7. [Spesifikasi Teknis & Data Model](#7-spesifikasi-teknis--data-model)
8. [Spesifikasi MVP](#8-spesifikasi-mvp)
9. [Analisis Kompetitif](#9-analisis-kompetitif)
10. [Setup Project Flutter](#10-setup-project-flutter)
11. [Changelog Revisi](#changelog-revisi)

---

## 1. Pendahuluan & Filosofi Anti-Guilt

LifeTree adalah **Personal OS (Sistem Orientasi Diri)** — bukan sekadar *habit tracker* atau *to-do list*. Dibangun di atas 3 pilar teori yang saling menguatkan:

| Pilar | Referensi | Implikasi Desain |
|-------|-----------|-----------------|
| **Habit Formation** | Lally et al. (2010), UCL | Otomatisasi butuh 18–254 hari (median 66). Kehilangan 1 hari ≠ gagal. |
| **Canopy Load (Konstruk Produk)** | — | Kapasitas harian terbatas; sistem mencegah *overload*. Bukan teori ilmiah yang mapan — lihat §2.2. |
| **Behavioral Design** | Fogg Behavior Model (B=MAP) | Intervensi presisi berdasarkan akar hambatan (Motivasi, Kemampuan, Pemicu). |

**Filosofi inti:** Aplikasi produktivitas konvensional mengandalkan *loss aversion* via sistem *streak* — memicu rasa bersalah dan *burnout* saat pengguna melewatkan 1 hari. LifeTree menolak pendekatan ini dan membangun arsitektur **Anti-Guilt**: kegagalan dikonversi menjadi data refleksi, bukan hukuman.

---

## 2. Landasan Ilmu Perilaku (Behavioral Science)

### 2.1 Dekonstruksi Mitos 21 Hari & Validasi 66 Hari

Industri pengembangan diri berpatokan pada mitos 21 hari. LifeTree menggunakan temuan **Lally et al. (2010)** dari University College London (UCL):

- **Temuan Kunci:** Waktu median menuju otomatisasi perilaku adalah **66 hari**, dengan rentang variasi ekstrem (18–254 hari).
- **Landasan *Anti-Guilt*:** Studi yang sama membuktikan bahwa hilangnya kesempatan 1–2 hari berturut-turut (*missed opportunity*) **tidak merusak proses otomatisasi secara material**. Oleh karena itu, arsitektur LifeTree mengizinkan *Recovery Mode* tanpa me-reset visual pohon.
- **Implikasi Teknis:** Ambang batas *Automaticity Decay* ditetapkan pada **60 hari kumulatif** — ini adalah **hipotesis produk** yang terinspirasi oleh literatur pembentukan kebiasaan (median 66 hari, dikurangi buffer 6 hari). Angka ini bukan klaim ilmiah baku, melainkan parameter produk yang akan divalidasi melalui pengujian iteratif. Formula decay (`floor(cumulative_done / 20)`) adalah **model produk yang disederhanakan**, bukan representasi langsung dari penelitian Lally et al. — Lally hanya mengatakan median 66 hari dan rentang 18–254 hari, tanpa fungsi decay linear. Parameter akan dikalibrasi melalui A/B testing pada 500+ pengguna beta (lihat §4.6).

### 2.2 Canopy Load — Konstruk Produk (Bukan Klaim Ilmiah)

LifeTree menggunakan konsep *Canopy Load* sebagai **konstruk produk** untuk memodelkan kapasitas harian pengguna:

- **Rasionalisasi:** Kegagalan mempertahankan kebiasaan seringkali **bukan** masalah motivasi, melainkan *overload*. Ini adalah asumsi produk yang intuitif, bukan klaim yang didukung teori ilmiah tunggal yang kuat.
- **Konteks ilmiah:** Awalnya konsep ini mengacu pada *Cognitive Load Theory* (Sweller, 1988) — namun CLT adalah teori tentang **pembelajaran dan instruksi**, bukan manajemen energi harian. Menggunakannya untuk menjelaskan "olahraga + belajar coding = overload" adalah kategori yang salah. Teori yang lebih relevan adalah *ego depletion* (Baumeister et al., 1998) — namun ego depletion sendiri mengalami **replication crisis** serius sejak 2016 (Hagger et al., meta-analysis). Oleh karena itu, Canopy Load diposisikan murni sebagai **konstruk produk** yang terinspirasi oleh intuisi sehari-hari, bukan backing ilmiah yang kuat. Validasi akan datang dari A/B testing, bukan paper.
- **Implementasi Produk:** Sistem mengkalibrasi beban melalui dua matriks:
  - *Initiation Friction* (Kesulitan Memulai) — skala 1–5
  - *Energy Cost* (Biaya Tenaga) — skala 1–5
- **Automaticity Decay:** Beban otomatis turun seiring waktu — `initiation_friction` berkurang secara bertahap setelah habit terlaksana konsisten, membebaskan ruang kapasitas untuk habit baru.

### 2.3 Model Intervensi Perilaku (Fogg Behavior Model)

Berdasarkan rumusan **B = MAP** (*Behavior = Motivation + Ability + Prompt*) dari Dr. BJ Fogg:

| Hambatan | Diagnosis | Intervensi LifeTree |
|----------|-----------|-------------------|
| *Ability* bermasalah ("Kurang Waktu/Energi") | Daya tampung terlampaui | Turunkan durasi aksi → *Minimum Viable Action* (versi `mva_duration_min` menit — satu kali, lalu kembali ke durasi normal. Jika user pilih "Kurang Waktu" di Friction Intervention, sistem menawarkan mengurangi target durasi besok ke `mva_duration_min` menit; durasi aktual dicatat di `duration_actual_min` HabitLog) |
| *Prompt* bermasalah ("Lupa") | Kebiasaan belum menempel pada rutinitas | Sarankan *Routine Stacking* (tumpuk ke kebiasaan lama yang sudah otomatis) |
| *Motivation* bermasalah ("Tidak mau") | Domain hidup tidak sejalan dengan nilai | Arahkan ke *Life Compass* & *Decision Journal* |
| *Clarity* bermasalah ("Bingung harus mulai dari mana") | Pikiran belum terstruktur, terlalu banyak opsi, atau takut salah langkah | Arahkan ke **Thinking Canvas** — sesi paper-first untuk dump, klaster, skoring, PMI, dan aksi kecil |

### 2.4 Referensi Akademis

- Lally, P., van Jaarsveld, C. H. M., Potts, H. W. W., & Wardle, J. (2010). *How are habits formed: Modelling habit formation in the real world.* European Journal of Social Psychology, 40(6), 998–1009.
- Baumeister, R. F., Bratslavsky, E., Muraven, M., & Tice, D. M. (1998). *Ego depletion: Is the active self a limited resource?* Journal of Personality and Social Psychology, 74(5), 1252–1265. *(Referensi konteks: teori ego depletion yang menginspirasi intuisi Canopy Load — namun lihat catatan replication crisis di §2.2)*
- Hagger, M. S., Chatzisarantis, N. L. D., Alberts, H., et al. (2016). *A multilab preregistered replication of the ego-depletion effect.* Perspectives on Psychological Science, 11(4), 546–573. *(Meta-analysis: ego depletion gagal direplikasi — Canopy Load tidak boleh mengklaim backing ilmiah dari teori ini)*
- Fogg, B. J. (2009). *A behavior model for persuasive design.* Proceedings of the 4th International Conference on Persuasive Technology.
- World Health Organization. (1998). *WHO-5 Well-Being Index.* WHO Regional Office for Europe.
- Deci, E. L., & Ryan, R. M. (2000). *The "What" and "Why" of Goal Pursuits: Human Needs and the Self-Determination of Behavior.* Psychological Inquiry, 11(4), 227–268. *(Pendukung pilar Life Compass — motivasi intrinsik vs ekstrinsik)*
- Duhigg, C. (2012). *The Power of Habit: Why We Do What We Do in Life and Business.* Random House. *(Habit Loop: Cue–Routine–Reward; pendukung strategi Routine Stacking)*
- Gollwitzer, P. M. (1999). *Implementation Intentions: Strong Effects of Simple Plans.* American Psychologist, 54(7), 493–503. *(Pendukung strategi "kapan-dimana" habit — Implementation Intention)*

---

## 3. Kepatuhan Hukum & Etika Digital (Compliance)

### 3.1 Perlindungan Data Pribadi (UU PDP & PP 17/2025 — PP TUNAS)

Menurut UU PDP, data kesehatan, data anak, dan data keuangan pribadi termasuk Data Pribadi yang bersifat spesifik. Dalam konteks LifeTree, jurnal emosi, skor mood, sinyal krisis, dan data finansial pengguna **diperlakukan dengan standar proteksi setara data sensitif** karena dapat memuat atau menghasilkan inferensi terkait kesehatan mental/kehidupan pribadi. LifeTree merancang arsitektur yang directionally aligned dengan regulasi Indonesia; seluruh bagian compliance membutuhkan formal legal counsel review sebelum launch:

#### Usia 13–17 Tahun (Teen Mode — Fase 2)
- Sesuai **PP No. 17 Tahun 2025** tentang Penyelenggaraan Sistem Elektronik dalam Pelindungan Anak (ditetapkan 28 Maret 2025; implementasi bertahap mulai 28 Maret 2026 melalui Permenkomdigi 9/2026) dan **Permenkomdigi No. 9 Tahun 2026** sebagai aturan pelaksanaannya, remaja (di bawah 18 tahun) membutuhkan ruang aman. PP ini mengacu pada praktik *Age-Appropriate Design Code*. PP 17/2025 menetapkan kelompok usia anak 3–5, 6–9, 10–12, 13–15, dan 16–<18 tahun. Permenkomdigi 9/2026 menjadi aturan pelaksana yang mengatur tahapan implementasi, termasuk pembatasan/penonaktifan akun anak di bawah 16 tahun pada platform digital berisiko tinggi. LifeTree saat ini menggunakan pembagian sederhana (< 13, 13–17) untuk Fase 1; jika masuk Fase 2, compliance rule akan mengikuti granularitas ini.
- *Parental Dashboard* **hanya** menampilkan **tren agregat** (grafik sentimen) dan *Conversation Starters* (contoh: *"Ajak anak ngobrol ringan, tren emosinya sedang turun"*).
- Sistem **membatasi orang tua membaca teks asli jurnal anak** — jembatan antara perlindungan wali dan *trust* remaja.

#### Usia < 13 Tahun (Seedling Mode — Fase 2)
- Wajib **Offline-First mutlak** — tanpa sinkronisasi *cloud*, data tidak pernah keluar dari perangkat.
- **Autentikasi Biometrik tidak digunakan untuk akun anak.** LifeTree secara kebijakan internal memilih tidak memakai biometrik untuk akun anak sebagai tindakan perlindungan berlebih (*precautionary principle*). COPPA mengatur biometrik sebagai *personal information* yang memerlukan consent/protection/retention controls — kami memilih jalan paling konservatif demi keamanan anak.

#### Age Graduation (Kelulusan Usia)
- Tepat pada hari ulang tahun ke-18, sistem **mencabut (*revoke*) akses orang tua** dari akun secara otomatis.
- Pengguna menerima notifikasi: *"Akunmu sekarang sepenuhnya milikmu. Semua akses orang tua telah dihapus."*
- **Catatan teknis:** Untuk mendukung fitur ini, `UserProfile` membutuhkan `date_of_birth` atau `verified_age_token` (bukan hanya `age_band`). Hal ini diimplementasikan di Fase 2.

### 3.2 Passive Wellness & Emergency Resource Protocol

> **Pernyataan Tegas:** LifeTree BUKAN *Medical Device* atau layanan terapi. Tercantum jelas di Terms & Conditions.

**Multi-Layer Medical Disclaimer:**

| Lapisan | Timing | Teks |
|---------|--------|------|
| **Onboarding** | Saat pendaftaran (wajib scroll + checkbox) | *\"LifeTree adalah alat refleksi diri, BUKAN pengganti konseling profesional atau layanan kesehatan mental. Jika Anda mengalami krisis, hubungi 119 atau profesional kesehatan mental segera.\"* |
| **Wellness Prompt (pertama kali)** | Sebelum prompt dukungan pertama muncul | *\"Beberapa catatan mood-mu terlihat berat belakangan ini. LifeTree tidak dapat mendiagnosis kondisi kesehatan mental. Jika kamu butuh bantuan segera, gunakan kontak profesional di bawah.\"* |
| **Safety Card (selalu)** | Terlihat di tombol darurat | *\"Darurat? Hubungi profesional.\"* |

Field `wellness_disclaimer_acknowledged BOOLEAN DEFAULT FALSE` di `UserProfile` mencatat apakah pengguna sudah menyatakan pemahaman disclaimer keselamatan. Persetujuan dicatat di `ConsentLog` dengan `consent_type = 'Wellness_Disclaimer'`.

**Mengapa menolak AI/ML untuk prediksi krisis mental?**
- *False Negative* (gagal membaca risiko) → tuntutan kelalaian (*liability*).
- *False Positive* (salah membaca risiko) → trauma, kecemasan, erosi kepercayaan.
- Menjanjikan kemampuan yang tidak bisa dijamin secara ilmiah adalah tidak etis.

**Implementasi: Passive Safety Protocol**

| Komponen | Deskripsi |
|----------|-----------|
| **Safety Card (Always-On)** | Tombol permanen di antarmuka Lapis 0. Nomor darurat Indonesia **di-hardcode** sebagai *absolute fallback* di kode aplikasi (119 — PSC, 119 ext 8 — SEJIWA). Remote Config digunakan untuk nomor tambahan/regional, bukan pengganti nomor primer. |
| **Emergency Resource Governance** | Nomor darurat diverifikasi sebelum launch dan direview tiap 90 hari oleh Legal/Ops menggunakan sumber resmi (Kemenkes/KemenPPPA/partner regional). Remote Config dipakai untuk update nomor sekunder tanpa app update. |
| **Mood-Based Gentle Prompt** | Jika `mood_score ≤ 2` selama 3 hari berturut-turut ATAU turun > 2 poin dalam 5 hari → muncul prompt empatik + Safety Card. Ini adalah sinyal dukungan, bukan deteksi/diagnosis krisis. Frequency Cap: maks. 1x per 7 hari untuk prompt penuh. |
| **Sustained Low-Mood Support (> 14 hari)** | Jika `mood_score ≤ 2` terus berlanjut > 14 hari berturut-turut → tampilkan 1 prompt yang lebih langsung ke resource profesional, maks. 1x per 14 hari. Safety Card tetap *highlighted* dengan visual berbeda selama periode tersebut. |
| **Recovery Mode Offer** | Di saat prompt dukungan, ditawarkan untuk mengubah `support_mode` ke *Recovery Mode* → semua notifikasi habit di-pause, status harian menjadi `Paused`. |
| **Anti-Banner-Blindness** | Safety Card menggunakan **posisi tetap tapi visual berrotasi** (ikon berubah periodik, warna halus berubah per musim) agar tetap terlihat tanpa menjadi *noise*. |
| **Out-of-App Wellness Check** | Jika pengguna tidak membuka aplikasi > 5 hari, kirim **1 push notification empatik** (bukan alarm): *"Kalau hari-hari ini berat, kamu bisa mulai dari sesuatu yang kecil 🌱"* — dengan deep-link ke Home / Journal Lite. Safety Card tetap always-on, tetapi inactivity saja tidak dianggap distress. Maks. 1x per 14 hari. |

### 3.3 Hak Atas Data & Privasi Bertahap

MVP Core memakai strategi **privacy-by-minimization**, bukan arsitektur E2EE penuh. Alasan produk: E2EE multi-device, recovery key, sync conflict, dan key rotation adalah pekerjaan teknis mahal yang dapat mengalihkan fokus dari validasi loop utama LifeTree.

| Fase | Implementasi |
|------|-------------|
| **MVP Core** | Data disimpan lokal di perangkat. Tidak ada akun, tidak ada cloud sync, tidak ada iklan, dan tidak ada targeted analytics. Ekspor JSON/CSV tetap tersedia sebagai backup manual yang dipicu pengguna. |
| **Privacy Hardening** | Setelah Daily Orientation Loop terbukti dipakai, tambahkan SQLCipher/local encrypted backup, app-level biometric lock untuk pengguna dewasa, dan retensi lokal untuk `WellnessPromptLog`. |
| **Privacy/E2EE Phase** | Cloud Sync, zero-knowledge E2EE, seed phrase, recovery contact, key rotation, dan sync conflict resolution masuk fase terpisah setelah retensi dan value proposition tervalidasi. |
| **Right to Erasure** | MVP menyediakan hapus data lokal. Fase cloud menambahkan penghapusan server, tombstone sync, DSAR workflow, vendor register, dan data flow map. |

---

## 4. Strategi Bisnis & Go-to-Market

### 4.1 Ringkasan Eksekutif

| | |
|---|---|
| **Masalah** | Pasar *habit tracker* (senilai miliaran dolar) memiliki *churn rate* tinggi akibat "Toxic Productivity" — *streak* memicu *guilt* & *burnout*. |
| **Solusi** | LifeTree: Personal OS berbasis **Anti-Guilt**. Mengonversi "kegagalan" menjadi data refleksi (*Friction Journaling*), menyediakan **Thinking Canvas** sebagai pilar refleksi berbasis kertas untuk menjernihkan pikiran dan memilih aksi kecil, serta memetakan arah hidup secara holistik. |
| **Differentiator** | Dirancang secara eksplisit untuk menghapus mekanisme *punishment loop* dari arsitektur, dengan inspirasi dari behavioral science dan privacy-by-design. |

### 4.2 Target Pasar & Strategi Peluncuran

#### Fase 1 — MVP Core (Daily Orientation Loop, 12–16 Minggu, *revised*)
- **Target:** Dewasa muda 18–35 tahun (mahasiswa tingkat akhir, *first-jobber*, profesional muda).
- **Karakteristik:** Digital-native, peduli *mental health*, rentan *overwhelm/burnout*.
- **Geografi Awal:** Indonesia (Bahasa Indonesia), ekspansi ke Asia Tenggara di Fase 1.5.

#### Fase 2 — Ekspansi Masa Depan
- *Teen Mode* (13–17 tahun) + *Seedling Mode* (< 13 tahun) + *Parental Dashboard*.
- Bahasa Inggris & ekspansi regional.

### 4.3 Strategi Monetisasi (Value-Based Freemium)

LifeTree **TIDAK** menjual data pengguna dan **TIDAK** menampilkan iklan (*Zero Targeted Ads*). Monetisasi tidak masuk MVP Core; paid tier dibuka setelah loop harian terbukti dipakai.

| Tier | Harga | Fitur |
|------|-------|-------|
| **Dasar (Gratis)** | Rp 0 | Akses penuh Daily Orientation Loop: Journal Lite, Habit Tubuh, Action of the Day, Friction Intervention, Recovery Mode, Thinking Canvas Lite, Safety Card, Ekspor Lokal (JSON/CSV), dan Dark Mode |
| **LifeTree Plus** | Rp 29.000/bln | On-Device Insights non-AI, PDF Export (jurnal → e-book), Life Compass, Decision Journal, dan kosmetik premium. Cloud Sync/E2EE tidak menjadi janji Plus sampai Privacy/E2EE Phase siap. |
| **LifeTree Student** | Rp 19.000/bln | Sama dengan Plus, dengan verifikasi status mahasiswa (self-declaration honor system + verifikasi email `.ac.id` di Fase 1; bisa ditingkatkan ke third-party verification di kemudian hari). |
| **Annual Plan** | Rp 249.000/thn (hemat ~29%) | Sama dengan Plus — diskon moderat untuk mengunci pengguna tanpa menekan perceived value. |
| **Micro-Transactions** | Rp 5.000–15.000/item | **Skin spesies pohon** (Pohon Sakura, Maple, Bonsai, dll) — murni kosmetik. Dark Mode tersedia gratis sebagai fitur aksesibilitas. |

> **Justifikasi Harga:** Berdasarkan *benchmark* langganan digital di Indonesia (Spotify Student Rp 16.500, YouTube Premium Student Rp 27.500, Netflix Basic Rp 54.000). Segmen mahasiswa dan first-jobber memiliki elastisitas harga berbeda — Student Tier mengakomodasi ini. Harga akan divalidasi melalui A/B testing pada 500 pengguna beta sebelum launch.

### 4.4 Strategi Akuisisi Pengguna

| Channel | Taktik | Estimasi CAC |
|---------|--------|-------------|
| **Community-Led Growth** | Partnership dengan komunitas mental health & produktivitas di Twitter/X, Discord, dan kampus | Rendah (organik) |
| **Content Marketing** | Edukasi tentang "Toxic Productivity" & "Anti-Guilt" via TikTok/Reels/YouTube Shorts | Rendah–Sedang |
| **University Beta Program** | Kampus ambassador + early access untuk 10 kampus di Jabodetabek & kota besar | Sedang |
| **Referral Program** | "Tanam Bersama" — ajak 1 teman, kedua pohon mendapat bonus kosmetik | Rendah (viral loop) |
| **Product Hunt / Media** | Launch di Product Hunt + press kit ke media tech Indonesia (Tech in Asia ID, DailySocial) | Rendah |

### 4.5 Key Performance Indicators (KPIs)

Berbeda dari aplikasi yang memuja DAU berbasis kecanduan, LifeTree mengukur **retensi yang bermakna**:

| Metrik | Target | Rasional |
|--------|--------|----------|
| **Day-7 Retention** | ≥ 20% | Baseline realistis untuk *wellness app* |
| **Day-30 Retention** | 10–15% | *Top-quartile* di industri |
| **Shame-Free Return Rate** *(North Star)* | ≥ 30% | Pengguna absen > 3 hari kembali aktif setelah *Friction Journaling* empatik. **Formula eksplisit:** `(Jumlah pengguna yang absen > 3 hari DAN complete ≥ 1 habit dalam 7 hari setelah Friction Intervention) / (Total pengguna yang absen > 3 hari DAN melihat Friction Intervention)`. Periode: rolling 30 hari. |
| **Weekly Clarity Rate** | ≥ 40% | Pengguna menyatakan "Saya tahu fokus saya minggu depan" setelah *Weekly Pulse Check* |
| **Clarity-to-Action Rate** | ≥ 35% | Sesi Thinking Canvas yang berakhir dengan 1 aksi kecil, asumsi yang diuji, atau kandidat Action of the Day |
| **WHO-5 Well-being Monitoring** | Pantau tren skor WHO-5 setiap 90 hari | Skor WHO-5 digunakan sebagai **indikator monitoring**, bukan klaim kausal efektivitas aplikasi. Peningkatan tidak bisa diatribusikan secara kausal tanpa *control group*. **UX:** 5 pertanyaan WHO-5 ditampilkan di layar Weekly Pulse (opsional, bukan wajib). Hasil ditampilkan sebagai tren pribadi di samping Radar Keseimbangan. Disimpan di tabel `WellnessAssessment` terpisah (Iterasi 1), bukan di `JournalEntry`. |
| **Anti-Guilt Score** *(Internal)* | Pantau secara internal, bukan KPI publik | Metrik internal: rasio (Friction Journaling events + Recovery Mode activations) / total Missed habits. Semakin tinggi rasio → semakin banyak pengguna yang menggunakan fitur suportif alih-alih menyerah. |
| **CAC : LTV Ratio** | ≤ 1:3 | Target *unit economics* sehat. **LTV Calculation:** LTV = ARPU × (1 / monthly_churn_rate). Asumsi: Plus Rp 29.000/bln, monthly churn 15% (benchmark wellness app Indonesia — belum ada data empiris, merupakan estimasi konservatif). LTV = Rp 29.000 × (1/0.15) = **Rp 193.000**. Untuk CAC:LTV = 1:3 → CAC maksimal ≤ Rp 64.000 per pengguna berbayar. **Sensitivitas:** Jika churn 20%, LTV = Rp 145.000 → CAC maks ≤ Rp 48.000. Jika churn 10%, LTV = Rp 290.000 → CAC maks ≤ Rp 97.000. Angka ini akan divalidasi setelah 3 bulan data churn aktual. |

### 4.6 Rencana Pengukuran Dampak

| Metode | Jadwal | Tujuan |
|--------|--------|--------|
| **Kuantitatif: WHO-5 + Shame-Free Return Rate** | Tiap 90 hari (otomatis via app) | Pantau tren wellbeing & retensi |
| **Kualitatif: User Interview** | Bulan 2, 4, 6 pasca-launch (10–15 user per sesi) | Pahami *mengapa* pengguna kembali/berhenti; validasi apakah filosofi Anti-Guilt dirasakan |
| **Perceived Support Score** | Tiap 30 hari (1 pertanyaan in-app) | *"Pohon saya mendukung saya bulan ini"* — skala 1–5 |
| **A/B Testing: Onboarding Flow** | Bulan 1–2 | Validasi jumlah pertanyaan onboarding dan copy anti-guilt |
| **A/B Testing: Automaticity Decay Rate** | Setelah Iterasi 1 punya cukup data | Variant A: decay per 15 hari. Variant B: decay per 20 hari (default). Variant C: decay per 30 hari. Metrik: Retention Day-30, Shame-Free Return Rate, Perceived Support Score. |

### 4.7 Infrastruktur Analytics (Privacy-Compliant)

Untuk aplikasi yang menekankan privacy dan zero-knowledge, pilihan analytics tool adalah keputusan arsitektural yang sensitif:

| Opsi | Kelebihan | Kekurangan | Keputusan |
|------|-----------|------------|-----------|
| Amplitude / Mixpanel | Mature, real-time | Data ke pihak ketiga | ❌ Tidak selaras dengan filosofi |
| PostHog (self-hosted) | Open-source, data di server sendiri | Perlu infra tambahan | ✅ **Fase 1** — self-hosted di server LifeTree |
| Custom event logging | Penuh kontrol | Maintenance overhead | ✅ **Long-term** — migrasi ke custom jika scale |

**Prinsip:** Analytics hanya mengumpulkan **metadata perilaku** (event type, timestamp, device info) — **tidak pernah konten** (teks jurnal, gratitude, dsb). Seluruh event analytics dikategorikan sebagai metadata sistem yang tidak terenkripsi. Pengguna bisa memilih keluar dari analytics di Settings (dicatat di `ConsentLog`).

**Event yang di-track (minimal):** `app_open`, `habit_done`, `habit_missed`, `friction_intervention_shown`, `friction_reason_selected`, `recovery_mode_activated`, `wellness_prompt_shown`, `safety_card_tapped`, `weekly_pulse_completed`, `subscription_started`.

### 4.8 Internasionalisasi (i18n)

Meskipun Fase 1 hanya Bahasa Indonesia, struktur i18n disiapkan sejak awal:
- Semua *string* UI disimpan di file terpisah (`id.json`, `en.json`) — bukan hardcode di widget.
- Format tanggal/waktu menggunakan `Intl` package Flutter (locale-aware).
- Teks copywriting Anti-Guilt perlu di-lokalize oleh *native speaker*, bukan diterjemahkan langsung — filosofi empati bersifat kultural.

---

## 5. Product Requirements & Desain UX

### 5.1 Visi Produk & Scope MVP

LifeTree memadukan **jurnal**, **habit tracker**, dan **peta tujuan hidup**. MVP **HANYA** untuk pengguna Dewasa (18–35 tahun). Semua fitur mode anak, remaja, dan *parental control* ditunda ke Fase 2.

### 5.2 Central Command Dashboard (Layar Utama)

Saat pengguna membuka aplikasi, layar "Home" menampilkan 4 elemen hierarkis (atas → bawah):

```
┌─────────────────────────┐
│     🌳 Visual Pohon     │  ← Tree Vitality: tumbuh seiring konsistensi,
│    (Tree Vitality)       │     berubah sesuai Current Season
│                          │     (bersalju = Recovery Mode, dll)
├─────────────────────────┤
│   📋 Action of the Day  │  ← 1 Kartu besar: habit prioritas hari ini
│     (Aksi Prioritas)     │     dipilih oleh algoritma
├─────────────────────────┤
│   📝 Quick Journaling   │  ← 1 ketuk → Journal Lite (emoji mood)
│       (Akar)             │
└─────────────────────────┘
```

> **Catatan MVP Lean:** Dashboard MVP Lean menampilkan **3 elemen: Pohon + Action + Journal**. Radar Keseimbangan ditambahkan di Iterasi 1 saat ada lebih banyak konteks untuk ditampilkan.

**§5.2A Tree Vitality State Specification**

Visual pohon adalah *emotional anchor* pertama yang dilihat pengguna. Spesifikasi status visual:

| State Visual | Kondisi | Representasi |
|-------------|---------|-------------|
| **Seedling** | 0–7 hari kumulatif habit Done | Tunas kecil di tanah |
| **Sapling** | 8–30 hari kumulatif | Batang muda dengan 2–3 daun |
| **Young Tree** | 31–60 hari kumulatif | Pohon muda, dedaunan mulai rimbun |
| **Mature Tree** | > 60 hari kumulatif | Pohon dewasa, dedaunan penuh |
| **Blooming** | Saat Automaticity Decay aktif (habit tertentu sudah "otomatis") | Bunga/buah muncul di cabang habit yang sudah otomatis |
| **Snow-Covered** | Recovery Mode aktif | Pohon bersalju lembut, dedaunan tertutup sebagian |

**Hard Rule Anti-Guilt:** Pohon **TIDAK PERNAH mengecil atau mati**. Ini adalah aturan mutlak dari filosofi Anti-Guilt — tidak ada visual punishment. Pohon hanya bisa tumbuh atau "istirahat" (bersalju), tidak pernah mundur.

**Growth Mapping:** Pertumbuhan visual tree berdasarkan milestone akumulatif non-streak; automaticity habit memakai `completion_rate_90d` + `weighted_done_score`, bukan raw done count. Mapping bersifat *step-based* (bukan linear) — perubahan visual terjadi di milestone tertentu, bukan setiap hari. Setiap 30 hari, muncul *Story Moment*: pohon berubah state + notifikasi *"Pohonmu sekarang punya X daun baru. Setiap daun mewakili 1 minggu konsistensi."* — pengguna bisa tap daun untuk melihat HabitLog minggu itu.

**Catatan MVP:** Pohon hanya menampilkan state Seedling → Mature + Snow-Covered. Blooming ditambahkan di Iterasi 1 saat Automaticity Decay aktif.

---

**§5.2B Action of the Day — Exit State & Cold Start**

**Celebration State:** Jika semua habit di **semua domain aktif** sudah Done hari ini (khususnya di MVP Lean yang hanya 1 domain):
- Sembunyikan kartu Action of the Day
- Tampilkan: *"Hari ini milikmu. Pohonmu sedang tumbuh. 🌳"*
- Ini menghindari *logical crash* saat tidak ada habit yang bisa direkomendasikan

**Cold Start Fallback:** Untuk pengguna baru yang belum memiliki `WeeklyPulse` atau `domain_score`:
1. Jika belum ada skor domain → gunakan skor dari `LifeAudit` onboarding
2. Jika belum ada habit → tampilkan onboarding prompt: *"Mulai dengan 1 habit pertamamu?"*
3. Prioritas: habit dengan `impact_score` tertinggi dan `total_load_score` terendah

**Domain_deficit = 0:** Domain dengan skor sempurna (skor 10, deficit 0) tidak akan pernah menjadi Action of the Day — semua habit di domain itu memiliki `priority_score = 0`. Algoritma otomatis memilih domain dengan deficit tertinggi berikutnya.

### 5.3 User Journey & Alur Layar

#### A. Onboarding (Progressive Profiling)

Mencegah *drop-off* dengan membagi proses secara bertahap:

| Tahap | Waktu | Aksi | Beban Kognitif |
|-------|-------|------|---------------|
| **Welcome Screen** | Hari 1 | Jelaskan filosofi Anti-Guilt. Tanya 1 pertanyaan *Life Audit* (*Quick Start* — pertanyaan #1 Tubuh). | Rendah |
| **Privasi Lokal** | Hari 1 | Jelaskan bahwa MVP Core menyimpan data di perangkat, tanpa akun dan tanpa cloud sync. | Rendah |
| **Full Audit** | Akhir Minggu 1 | Sisa 5 pertanyaan audit diselesaikan saat *Weekly Pulse* pertama. | Sedang |

> **Perubahan UX Keamanan:** Seed phrase BIP-39 di onboarding terasa seperti *crypto wallet*, bukan *wellness app*. MVP Core tidak memakai seed phrase, OS Keychain, atau Cloud Sync. Semua itu masuk Privacy/E2EE Phase.

**6 Pertanyaan Life Audit (Wheel of Life):**

| # | Domain | Pertanyaan | Skala |
|---|--------|-----------|-------|
| 1 | 🏃 Tubuh | *"Secara keseluruhan, seberapa puas kamu dengan kesehatan dan kebugaran fisikmu?"* | 1–10 |
| 2 | 💰 Keuangan | *"Seberapa stabil dan aman kondisi keuanganmu saat ini?"* | 1–10 |
| 3 | 🤝 Hubungan | *"Seberapa puas kamu dengan kualitas hubunganmu dengan orang-orang terdekat?"* | 1–10 |
| 4 | 💭 Emosi | *"Seberapa sering kamu merasa emosional seimbang dan tenang?"* | 1–10 |
| 5 | 📚 Karir/Belajar | *"Seberapa puas kamu dengan perkembangan karir atau belajarmu?"* | 1–10 |
| 6 | 🎮 Rekreasi | *"Seberapa sering kamu punya waktu untuk kegiatan yang menyenangkan?"* | 1–10 |

**MVP Quick Start (Hari 1):** Hanya tanyakan #1 (Tubuh). Skor ini menjadi baseline `domain_deficit` untuk algoritma Action of the Day. 5 pertanyaan lain diselesaikan di Weekly Pulse pertama (Akhir Minggu 1).

#### B. Friction Intervention (Flow Saat Gagal Habit)

Jika habit berstatus *Missed* melebihi threshold berdasarkan **frekuensi habit**:

| Frekuensi Habit | Trigger Intervensi |
|-----------------|-------------------|
| Daily | 3x Missed dalam 7 hari |
| 3x/Minggu | 2x Missed dalam 7 hari (dari 3 jadwal) |
| Weekly | 2x Missed berturut-turut |

```
1. Muncul Pop-up ramah (BUKAN merah/peringatan keras)
   └→ Teks: "Hari ini sepertinya berat. Apa hambatan terbesarmu kemarin?"

2. Pilihan:
   ├→ (A) Kurang Waktu  → Tombol: "Mau potong durasi jadi `mva_duration_min` menit saja besok?"
   │                       Jika diterima: target durasi habit besok = `mva_duration_min` menit (one-time override).
   │                       Durasi aktual dicatat di `duration_actual_min`. Setelah 1 kali, override otomatis terhapus.
   ├→ (B) Kelelahan     → Tombol: "Mau aktifkan Recovery Mode?"
   └→ (C) Lupa          → Saran: "Mau tumpuk habit ini ke rutinitas yang sudah ada?"

3. Jika pilih (B) Kelelahan → Recovery Mode Flow:
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

#### C. Weekly Pulse Check (Akhir Minggu)

- Setiap hari Minggu, notifikasi untuk *Weekly Pulse*.
- Pengguna menjawab **1 pertanyaan refleksi per domain aktif** agar skor Radar Keseimbangan ter-*update*.
- Pulse Check dirancang < 2 menit untuk menghormati waktu pengguna.

#### D. Out-of-App Wellness Check

- Jika pengguna tidak membuka aplikasi > 5 hari:
  - Kirim **1 push notification empatik** (bukan alarm): *"Kalau hari-hari ini berat, kamu bisa mulai dari sesuatu yang kecil 🌱"*
  - Deep-link ke Home / Journal Lite. Safety Card tetap always-on, tetapi inactivity saja tidak dianggap distress.
  - Maks. 1x per 14 hari.

### 5.4 Panduan Copywriting UX (Anti-Guilt Tone)

**Nada Suara:** Empatik, Tenang, Netral, Mendukung.

| ❌ JANGAN | ✅ GUNAKAN |
|-----------|-----------|
| *"Kamu merusak streak-mu! Kembali ke Nol."* | *"Pohonmu sedang beristirahat. Kapanpun kamu siap, mari menanam lagi."* |
| *"Hapus Habit."* | *"Arsipkan Habit (Beri ruang untuk hal lain)."* |
| *"Gagal / Failed."* | *"Terlewat (Missed) / Jeda (Paused)."* |
| *"Kamu belum menyelesaikan tugas hari ini!"* | *"Ada sesuatu yang bisa kamu lakukan hari ini, meski hanya 2 menit."* |
| *"Peringatan! Streak-mu terputus."* | *"Pohonmu sedang beristirahat. Tidak apa-apa."* |

### 5.5 Aksesibilitas Visual (WCAG 2.1 AA)

- Radar Chart wajib memiliki **versi alternatif List View/Tabel** bagi *screen reader*.
- Hindari indikator yang **hanya** mengandalkan warna — gunakan kombinasi **warna + ikon + label teks**.
- Navigasi harus aman bagi pengguna *neurodivergent* (tanpa animasi flash, tanpa suara tiba-tiba).
- Ukuran *touch target* minimum 48×48dp (sesuai Material Design accessibility guidelines).
- **Palet warna "Calm Tech":** Palet warna terinspirasi dari prinsip *Calm Tech* — warna yang secara konvensional diasosiasikan dengan ketenangan (hijau sage, biru redup, krem). Hindari animasi yang terlalu cepat.
- **Dark Mode:** Tersedia **gratis** di tier Dasar — bukan kosmetik berbayar. Dark mode adalah kebutuhan aksesibilitas untuk pengguna fotosensitif dan journaling malam hari. Menjualnya bertentangan dengan filosofi Calm Tech dan akan dibandingkan negatif dengan kompetitor yang memberikannya gratis.

### 5.6 Tree Vitality — Art Direction

Visual pohon adalah *emotional anchor* utama. Spesifikasi produksi:

| Aspek | Keputusan |
|-------|-----------|
| **Style** | Flat illustration dengan subtle gradients — bukan pixel art, watercolor, atau 3D. Dipilih karena: scalable, ringan di rendering, dan konsisten dengan tone "calm tech". |
| **Format** | SVG animated via Lottie — memungkinkan transisi halus antar state tanpa frame-by-frame animation yang berat. |
| **Aset** | 6 state × variant musiman = ~20 Lottie file. Dibuat oleh illustrator kontrak (bukan AI-generated, untuk konsistensi gaya). |
| **Animasi** | Transisi state: cross-fade 800ms. Daun bergoyang subtle (idle animation loop 8 detik). Snow particles saat Recovery Mode. Tidak ada animasi "mundur". |

### 5.7 App Store Compliance

Aplikasi kesehatan mental menghadapi scrutiny khusus:

| Platform | Requirement | Implementasi LifeTree |
|----------|------------|----------------------|
| **Apple App Store** | Guideline 1.4.1: health-related claims harus akurat, metodologi jelas, dan tidak misleading; pengguna diarahkan ke profesional untuk keputusan medis | LifeTree BUKAN medical device — tegas di ToS + onboarding disclaimer; tidak memberi diagnosis/terapi |
| **Apple App Store** | Guideline 1.4.5 relevan untuk challenge/aktivitas yang berisiko menimbulkan cedera fisik | Tidak ada challenge berbahaya; Action of the Day selalu bisa dibuat ringan dan non-punitive |
| **Apple App Store** | Age rating ditentukan via App Store Connect questionnaire dan aturan regional | Target bisnis MVP = 18+, tetapi rating store tidak diasumsikan otomatis 18+ |
| **Google Play** | Health apps declaration, Data Safety, prominent disclosure/consent untuk data personal/sensitif | Local-only MVP + WellnessPromptLog lokal + deklarasi data sebelum submission |
| **Google Play** | Content rating ditentukan via IARC/content rating questionnaire | Target bisnis MVP = 18+, rating publik mengikuti hasil questionnaire aktual |

**Risiko Rejection:** Apple/Google bisa menolak jika klaim kesehatan, disclaimer, deklarasi data, atau age/content rating tidak akurat. Mitigasi: legal/privacy review, audit Data Safety/Health declaration, dan submission checklist sebelum rilis.

### 5.8 Testing Strategy

| Level | Cakupan | Tools/Pendekatan |
|-------|---------|------------------|
| **Unit Test** | Algoritma (Action of the Day, Friction Intervention threshold per frekuensi, domain score TTL; Automaticity Decay mulai Iterasi 1) | Flutter test framework — setiap formula punya test case dengan input/output eksplisit |
| **Integration Test** | Local database roundtrip, export JSON/CSV, state recovery setelah app restart | Flutter integration_test |
| **Manual QA** | Wellness prompt flow (frequency cap, sustained low-mood support, disclaimer acknowledgment), Safety Card tampil di semua layar | Checklist QA per sprint — wajib 1 orang QA tester |
| **Edge Case Test** | Offline 30 hari lalu online, device clock salah, timezone change, reinstall + frequency cap recovery | Automated scenario test suite |
| **Security Audit** | Privacy hardening lokal; E2EE audit dilakukan saat Privacy/E2EE Phase | Third-party audit sebelum fitur cloud privacy dirilis |

---

## 6. Arsitektur Modul & Algoritma

### 6.1 Peta Lapisan Arsitektur

```
Lapis 3: 🍎 Buah & Kompas (Advanced)     → Life Compass, Decision Journal
Lapis 2: 🌿 Cabang (6 Domain Kehidupan)   → Keuangan, Tubuh, Hubungan, Emosi, Karir/Belajar, Rekreasi
Lapis 1: 🪵 Batang (Canopy Load & Goals)  → Manajemen beban, Goal Hierarchy
Lapis 0: 🌱 Akar (Refleksi & Diagnosis)   → Journal Lite, Deep Reflection, Thinking Canvas, Friction Journaling, Weekly Pulse, Safety Card
```

### 6.2 Lapis 0: Akar (Refleksi Adaptif & Diagnosis)

**Adaptive Micro-Journaling** — dua mode harian:
- *Journal Lite (Default):* 1 ketuk emoji mood + 1 kata kunci. Beban minimal.
- *Deep Reflection:* 3 pertanyaan + *Gratitude prompt*. Hanya jika pengguna memilih.

**Thinking Canvas — Pilar Refleksi Berbasis Kertas:** mode paper-first untuk kondisi buntu, terlalu banyak opsi, ragu pada rencana, atau perlu mengubah ide menjadi aksi kecil. Pengguna dianjurkan corat-coret di buku/kertas asli, lalu LifeTree menyimpan ringkasan: metode, temuan, asumsi, dan aksi kecil. Output dapat menjadi Action of the Day, bahan Friction Journal, Weekly Pulse, atau catatan Decision Journal.

**Friction Journaling & Status Habit:**
- 4 status habit: `Done`, `Missed`, `Skipped_Intentionally`, `Paused`.
- Jika *Missed* melebihi threshold (disesuaikan per frekuensi habit, lihat §5.3B) → intervensi berbasis Fogg Model.

### 6.3 Lapis 1: Batang (Canopy Load & Goal Hierarchy)

**Canopy Load — Pemisahan Friksi & Energi:**

```
Total Load Score = initiation_friction + energy_cost
Kapasitas Default = 10 poin

Contoh:
  Meditasi 10 menit  → friction:2 + energy:1 = 3 poin ✅
  Olahraga 1 jam     → friction:3 + energy:5 = 8 poin ⚠️
  Belajar coding 2 jam → friction:4 + energy:4 = 8 poin ⚠️
```

**Canopy Load Capacity Enforcement:** Jika penambahan habit baru membuat `total_load_score` melebihi `canopy_load_capacity`:
- Sistem menampilkan peringatan ramah: *"Pohonmu sudah cukup penuh. Mau arsipkan habit lain dulu, atau tambah habit ini dengan beban yang lebih ringan?"*
- Pengguna tetap bisa menambahkan (soft enforcement, bukan hard block) — sesuai filosofi Anti-Guilt
- Catatan: `canopy_load_capacity` adalah panduan, bukan batas kaku

**Automaticity Decay:**
- **Trigger:** `HabitLog` berstatus `Done` selama **60 hari kumulatif** (tidak harus berurutan — sesuai median Lally et al.).
- **Action:** Turunkan `initiation_friction` secara bertahap. `energy_cost` **TETAP** tidak berubah — olahraga 1 jam tetap menguras energi fisik.
- Total poin beban dihitung ulang, membebaskan *capacity* untuk habit baru.

**Goal Hierarchy:** Visi (5 Tahun) → Project (Tenggat Waktu) → Habit Harian / Tasks

### 6.4 Lapis 2: Cabang (6 Domain Kehidupan)

| Domain | Contoh Habit | Catatan |
|--------|-------------|---------|
| 🏃 Tubuh | Olahraga 30 menit | **Domain MVP** — paling terukur & intuitif; kesehatan fisik adalah fondasi domain lain |
| 💰 Keuangan | Catat pengeluaran harian | Fase 1.5 |
| 🤝 Hubungan | Hubungi 1 teman/keluarga | Fase 1.5 |
| 💭 Emosi | Journaling 5 menit | Fase 1.5 |
| 📚 Karir/Belajar | Baca 10 halaman | Fase 1.5 |
| 🎮 Rekreasi | Main game 30 menit | Fase 1.5 |

> **MVP:** Hanya **domain Tubuh** yang aktif saat peluncuran. Domain lain diaktifkan bertahap setelah *Day-7 Retention* stabil. Domain belum aktif di Radar ditampilkan sebagai "Coming Soon".

**Domain Score Staleness (TTL):** `latest_domain_score` memiliki masa berlaku:
- **Fresh:** 0–14 hari sejak WeeklyPulse/LifeAudit terakhir → digunakan langsung
- **Stale:** 15–30 hari → digunakan tapi dengan indikator visual *"skor mungkin tidak akurat"*
- **Expired:** > 30 hari → sistem menggunakan fallback: skor dari LifeAudit awal, dan memprioritaskan prompt untuk mengisi Weekly Pulse. **Untuk Iterasi 2 (6 domain):** Jika semua domain expired, sistem menggunakan skor terakhir yang diketahui (stale) dengan indikator visual, bukan LifeAudit awal — karena LifeAudit hanya dilakukan sekali dan bisa sangat outdated. Domain tanpa skor apapun mendapat skor default 5 (netral).

**Tagging Opsional:** Sistem menggunakan *Smart Suggestion* saat men-tag habit ke domain, menghindari friksi *onboarding*.

**Current Season — Definisi Lengkap:**

| Season | Trigger | Perilaku Sistem |
|--------|---------|-----------------|
| **Growth** (Default) | Normal | Semua notifikasi dan algoritma berjalan normal |
| **Recovery** | Manual (pengguna memilih) atau Hybrid (sistem menawarkan saat prompt dukungan) | Semua notifikasi habit di-pause, status harian → Paused, pohon bersalju (Snow-Covered). Journaling tetap aktif. Durasi dipilih pengguna (1/3/7 hari). |
| **Dormant** | Pengguna tidak membuka aplikasi > 14 hari (meskipun sudah dikirimi Out-of-App Wellness Check) | Sistem mengurangi frekuensi notifikasi. Saat pengguna kembali, tampilkan review: *"Mau lanjutkan habit lama, ubah jadi versi ringan, atau arsipkan?"* Tidak ada auto-archive tanpa persetujuan. Visual Dormant memakai kabut/cahaya redup/idle animation lebih lambat — bukan daun rontok — agar tidak terasa seperti regresi. |

### 6.5 Lapis 3: Buah & Kompas (Advanced — LifeTree Plus)

- **Life Compass:** Memilih 3 *Core Values* opsional sebagai "kompas utara" pengambilan keputusan — didukung oleh *Self-Determination Theory* (Deci & Ryan, 2000) untuk memastikan motivasi yang dibangun adalah intrinsik.
- **Decision Journal:** Mencatat keputusan sulit dengan pengingat *review* 90 hari. **Iterasi 2 (P2)**, bukan Scope OUT — Decision Journal adalah fitur Plus yang ditunda ke Iterasi 2 untuk menjaga fokus MVP Lean.

### 6.6 Algoritma Inti

#### A. Algoritma "Action of the Day"

Sistem memprioritaskan 1 habit untuk *Central Dashboard* — **Rule-Based, NO AI/ML**:

```
domain_deficit = 10 - latest_domain_score  // computed dari UserProfile.latest_domain_scores; fallback ke WeeklyPulse/LifeAudit jika kosong
priority_score = (domain_deficit * impact_score) / (initiation_friction + energy_cost)

Langkah:
1. Hitung domain_deficit untuk setiap domain yang aktif
   - Jika domain_score expired (> 30 hari tanpa update), gunakan fallback dari LifeAudit
2. Cari domain dengan deficit TERTINGGI (domain terlemah)
   - Domain dengan deficit = 0 (skor sempurna) TIDAK PERNAH menjadi target
3. Query semua habit aktif yang domain_tag == domain_terlemah
   - Filter: hanya habit yang dijadwalkan hari ini (cek scheduled_days vs hari ini)
4. Jika tidak ada habit di domain terlemah, cari domain terlemah berikutnya
5. Urutkan habit berdasarkan priority_score TERTINGGI
6. Tampilkan habit urutan pertama sebagai Action of the Day
7. Jika semua habit di domain terlemah sudah Done hari ini,
   tampilkan habit dari domain terlemah kedua
8. Jika semua habit di SEMUA domain aktif sudah Done hari ini
   → Celebration State: "Hari ini milikmu. Pohonmu sedang tumbuh. 🌳"

Cold Start Fallback (pengguna baru tanpa skor domain):
  → Gunakan skor LifeAudit onboarding
  → Jika belum ada habit → prompt: "Mulai dengan 1 habit pertamamu?"
  → Prioritas: habit dengan impact_score tertinggi + total_load_score terendah
```

> **Catatan v9.0:** Algoritma sebelumnya memiliki konflik — formula Priority Score vs sort by `total_load_score`. Sekarang **menggunakan Priority Score saja** sebagai pengurut utama, karena formula ini sudah memperhitungkan friction/energy di denominator. Pendekatan ini lebih komprehensif dan konsisten.

#### B. Algoritma "Automaticity Decay" (Opportunity-Normalized)

```
Prinsip:
  Jangan gunakan raw done count saja, karena habit weekly akan kalah adil dari habit daily.
  Decay dievaluasi berdasarkan scheduled opportunities dan completion rate.

Definitions:
  scheduled_opportunities_90d = jumlah jadwal habit dalam 90 hari terakhir
  done_count_90d = jumlah Done dari kesempatan tersebut
  completion_rate_90d = done_count_90d / scheduled_opportunities_90d

  weighted_done_score = done_count_90d + (0.5 * done_count_91_180d)

Threshold exposure minimum:
  Daily    → 45 kesempatan
  3x/Week → 18 kesempatan
  Weekly  → 8 kesempatan
  Custom  → 6–12 kesempatan sesuai schedule_rule_json

automaticity_ready = completion_rate_90d >= 0.70
                     AND scheduled_opportunities_90d >= threshold_by_frequency

if automaticity_ready:
  decay_step = floor(weighted_done_score / threshold_by_frequency)
  initiation_friction = max(1, original_friction - decay_step)
else:
  initiation_friction tetap

energy_cost = TETAP
total_load_score = initiation_friction + energy_cost
```

> **Catatan:** Ini tetap hipotesis produk, bukan parameter ilmiah baku. `lifetime_done_count` hanya counter mentah untuk statistik/performa; input utama decay adalah `completion_rate_90d` dan `weighted_done_score`.

#### C. Algoritma "Passive Wellness Support"

```
Trigger:
  - mood_score ≤ 2 selama 3 hari berturut-turut, ATAU
  - mood_score turun > 2 poin dalam rentang 5 hari

Frequency Cap: Maks. 1x per 7 hari per pengguna (prompt penuh)

Action 1: Prompt empatik + Safety Card (Hotline Darurat)
Action 2: Tawarkan ubah support_mode → Recovery Mode
          (pause notifikasi habit, status harian → Paused)

Sustained Low-Mood Support (> 14 hari mood_score ≤ 2 berturut-turut):
  - Tampilkan 1 prompt dukungan yang lebih langsung ke hotline/resource profesional
  - Maks. 1x per 14 hari
  - Safety Card tetap highlighted dengan visual berbeda

Out-of-App Trigger (Anti-Ghosting):
  - Jika pengguna tidak membuka aplikasi > 5 hari:
    → 1 push notification empatik (maks. 1x per 14 hari)
    → Deep-link ke Home / Journal Lite
    → Teks: "Kalau hari-hari ini berat, kamu bisa mulai dari sesuatu yang kecil 🌱"

Fallback nomor darurat:
  - Nomor primer di-hardcode di aplikasi (119, 119 ext 8)
  - Remote Config hanya untuk nomor tambahan/regional
```

### 6.7 State Machine (Status Habit)

```
                    ┌──────────┐
          ┌────────►│   Done   │──────────┐
          │         └──────────┘          │
          │                               │ (reset hitungan
          │                               │  missed jika Done)
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
 │Intentionally     │          │ (Sistem)     │    (manual/auto)
 └──────────────────┘          └──────┬───────┘
    ▲ TIDAK masuk hitungan            │
    ▲ Missed                          │ (keluar Recovery)
    │                                  ▼
    └──────────────────────────► Active

 ┌──────────────────┐
 │  Not_Scheduled   │  ← Hari di luar jadwal habit (non-daily)
 │  (Otomatis)      │    TIDAK masuk hitungan Missed / Friction
 └──────────────────┘    Tidak ada HabitLog dibuat
```

**Transisi Status:**

| Dari | Ke | Kondisi |
|------|----|---------|
| Active | Done | Pengguna menyelesaikan habit hari ini (hari terjadwal) |
| Active | Missed | Pengguna tidak menyelesaikan habit hari ini (hari terjadwal) |
| Active | Not_Scheduled | Hari ini bukan hari terjadwal (habit non-daily). Tidak ada HabitLog dibuat. |
| Active | Skipped_Intentionally | Pengguna dengan sadar meliburkan diri |
| Active | Paused | Sistem (Recovery Mode) atau pengguna manual |
| Missed | Friction Intervention | Threshold terpenuhi (variasi per frekuensi) |
| Paused | Active | Keluar dari Recovery Mode |
| Friction Intervention | Active | Setelah intervensi selesai (pilih opsi) |

**HabitLog untuk Habit Non-Daily:** HabitLog **hanya dibuat pada hari terjadwal**. Untuk habit `3x/Week` (jadwal Mon/Wed/Fri), tidak ada log entry untuk hari Selasa/Kamis/Sabtu/Minggu — hari-hari tersebut tidak dianggap Missed maupun Done. Friction Intervention hanya menghitung Missed dari hari yang terjadwal. `frequency = 'Custom'` berarti pengguna menentukan hari spesifik via `scheduled_days` (contoh: "Mon,Thu,Sat"). Bedanya dengan `3x/Week`: Custom bisa 5x/minggu, 1x/2 minggu, atau pola tidak beraturan — threshold intervensi dihitung proporsional: `(missed_count / scheduled_count_per_period) > 0.5`. **Definisi `per_period`:** periode evaluasi = **rolling 14 hari** untuk semua frekuensi Custom. Alasan: 14 hari cukup untuk mendeteksi pola bahkan untuk habit 1x/2 minggu, sekaligus tidak terlalu lambat untuk habit harian. Dalam 14 hari, sistem menghitung: berapa kali habit dijadwalkan vs berapa kali Missed. Jika rasio Missed > 50% → trigger Friction Intervention.

---

## 7. Spesifikasi Teknis & Data Model

### 7.1 System Architecture & Tech Stack

| Komponen | Teknologi | Alasan |
|----------|-----------|--------|
| **Frontend (Mobile)** | Flutter | Satu *codebase* iOS & Android, percepat *time-to-market* MVP |
| **Local Database (MVP)** | SQLite via Drift atau sqflite | *Offline-first*, cepat untuk MVP, tanpa akun dan tanpa cloud sync |
| **Privacy Hardening (Iterasi 1)** | SQLCipher/local encrypted backup + app-level biometric lock | Ditambahkan setelah Daily Orientation Loop terbukti dipakai |
| **Backend (MVP)** | Tidak ada backend | MVP Core berjalan local-only. Ekspor JSON/CSV dilakukan manual oleh pengguna |
| **Privacy/E2EE Phase** | Node.js + PostgreSQL + zero-knowledge E2EE | Cloud Sync, seed phrase, recovery contact, key rotation, dan sync conflict resolution masuk fase terpisah |
| **Remote Config** | Ditunda | Nomor primer Safety Card di-hardcode; remote config untuk nomor tambahan masuk setelah public beta |
| **Push Notification** | Local notification; FCM ditunda | Reminder lokal cukup untuk MVP. Out-of-app wellness check berbasis push remote masuk Iterasi 1/Fase backend |

> **Prinsip Arsitektur MVP:** Seluruh logika komputasi berjalan di perangkat pengguna (*client-side*). Tidak ada akun, tidak ada server, tidak ada cloud sync, dan tidak ada E2EE multi-device di MVP Core. Automaticity Decay pindah ke Iterasi 1.

> **Catatan Schema:** Skema database di bawah bersifat **konseptual**. Implementasi lokal di SQLite menggunakan `TEXT` dengan JSON serialization. Kolom yang terkait cloud/E2EE adalah desain masa depan, bukan kebutuhan MVP Core.

### 7.2 Arsitektur Keamanan MVP

```
┌─────────────────────────────────────────────────────┐
│                    PERANGKAT PENGGUNA                │
│                                                      │
│  ┌──────────┐    ┌────────────┐    ┌─────────────┐  │
│  │ Flutter  │───►│ SQLite     │───►│ Export       │  │
│  │ App      │    │ Local DB   │    │ JSON/CSV     │  │
│  └──────────┘    └────────────┘    └─────────────┘  │
│                                                      │
│  Tidak ada akun, server, cloud sync, atau key setup  │
│  pada MVP Core. Privacy hardening ditambahkan        │
│  setelah loop utama tervalidasi.                    │
└─────────────────────────────────────────────────────┘
```

**Privacy/E2EE Phase (bukan MVP):** Shamir recovery, seed phrase, QR key transfer, DeviceRegistry, cloud sync, dan conflict resolution tetap menjadi desain masa depan.

### 7.3 Core Data Models (Entity Schema Lengkap)

#### `UserProfile`
| Kolom | Tipe | Constraint | Keterangan |
|-------|------|-----------|------------|
| `user_id` | UUID | PK | ID unik pengguna |
| `age_band` | VARCHAR(10) | NOT NULL | "18-24", "25-35", dll |
| `support_mode` | VARCHAR(20) | DEFAULT 'Normal' | 'Normal', 'Recovery' — mode dukungan/UX emosional |
| `engagement_state` | VARCHAR(20) | DEFAULT 'Active' | 'Active', 'Dormant' — state operasional berbasis aktivitas membuka app |
| `canopy_load_capacity` | INTEGER | DEFAULT 10 | Kapasitas beban total (panduan, bukan batas kaku — soft enforcement) |
| `wellness_disclaimer_acknowledged` | BOOLEAN | DEFAULT FALSE | Pengguna sudah menyatakan pemahaman disclaimer wellness/safety |
| `last_wellness_push_at` | TIMESTAMP | NULLABLE | Terakhir push notifikasi Out-of-App Wellness Check (frequency cap: 1x/14 hari) |
| `last_wellness_prompt_at` | TIMESTAMP | NULLABLE | Frequency cap wellness prompt (1x/7 hari). MVP Core menyimpan ini lokal; cloud metadata baru relevan pada fase backend. |
| `recovery_contact_email` | VARCHAR(255) | NULLABLE | Privacy/E2EE Phase: email kontak pemulihan (opsional) |
| `recovery_contact_fragment` | TEXT | NULLABLE, ENCRYPTED | Privacy/E2EE Phase: fragment kunci terenkripsi untuk Recovery Contact |
| `secondary_backup_configured` | BOOLEAN | DEFAULT FALSE | Privacy/E2EE Phase: true jika user sudah menyimpan fragment/backup di luar platform |
| `secondary_backup_hint` | VARCHAR(100) | NULLABLE | Privacy/E2EE Phase: petunjuk lokasi backup tanpa isi fragment |
| `security_level` | VARCHAR(20) | DEFAULT 'Local' | 'Local' di MVP Core; 'Standard'/'Advanced' baru relevan pada Privacy/E2EE Phase |
| `deleted_at` | TIMESTAMP | NULLABLE | Tombstone; sinkronisasi multi-perangkat baru relevan pada fase cloud |
| `created_at` | TIMESTAMP | NOT NULL | Waktu pembuatan akun |
| `updated_at` | TIMESTAMP | NOT NULL | Waktu update terakhir |

#### `LifeAudit`
| Kolom | Tipe | Constraint | Keterangan |
|-------|------|-----------|------------|
| `audit_id` | UUID | PK | ID unik audit |
| `user_id` | UUID | FK → UserProfile | Pemilik audit |
| `domain_scores` | JSONB | NOT NULL | `{"Tubuh": 4}` (MVP: hanya domain aktif) |
| `timestamp` | TIMESTAMP | NOT NULL | Waktu audit |

#### `WeeklyPulse`
| Kolom | Tipe | Constraint | Keterangan |
|-------|------|-----------|------------|
| `pulse_id` | UUID | PK | ID unik pulse |
| `user_id` | UUID | FK → UserProfile | Pemilik pulse |
| `domain_tag` | VARCHAR(30) | NOT NULL | Domain yang direfleksikan |
| `score` | INTEGER | CHECK(1-10) | Skor domain minggu ini |
| `reflection_text` | TEXT | NULLABLE | Jawaban refleksi singkat |
| `week_start_date` | DATE | NOT NULL | Tanggal mulai minggu |

#### `WellnessAssessment` (Iterasi 1 — WHO-5 dan instrumen terstruktur)
| Kolom | Tipe | Constraint | Keterangan |
|-------|------|-----------|------------|
| `assessment_id` | UUID | PK | ID assessment |
| `user_id` | UUID | FK → UserProfile | Pemilik assessment |
| `instrument` | VARCHAR(30) | NOT NULL | 'WHO5' untuk Iterasi 1 |
| `item_scores` | JSONB | NOT NULL | 5 item WHO-5 |
| `total_score` | INTEGER | NOT NULL | Skor total |
| `assessment_date` | DATE | NOT NULL | Tanggal assessment |
| `consent_context` | VARCHAR(50) | NULLABLE | Konteks consent/disclaimer |
| `deleted_at` | TIMESTAMP | NULLABLE | Tombstone |
| UNIQUE | | `(user_id, instrument, assessment_date)` | Maks. 1 assessment per instrumen per tanggal |

#### `Habit`
| Kolom | Tipe | Constraint | Keterangan |
|-------|------|-----------|------------|
| `habit_id` | UUID | PK | ID unik habit |
| `user_id` | UUID | FK → UserProfile | Pemilik habit |
| `domain_tag` | VARCHAR(30) | NULLABLE | Domain terkait (opsional) |
| `title` | VARCHAR(100) | NOT NULL | Nama habit |
| `status` | VARCHAR(20) | DEFAULT 'Active' | 'Active', 'Archived' |
| `archived_at` | TIMESTAMP | NULLABLE | Diisi saat status berubah ke Archived |
| `frequency` | VARCHAR(20) | DEFAULT 'Daily' | 'Daily', '3x/Week', 'Weekly', 'Custom'. Custom = pola jadwal bebas via `scheduled_days`; threshold intervensi dihitung proporsional: `(missed/scheduled_per_period) > 0.5` |
| `scheduled_days` | VARCHAR(20) | NULLABLE | "Mon,Wed,Fri" (untuk Custom). `3x/Week` default = Mon/Wed/Fri. `Weekly` = hari yang dipilih pengguna. |
| `initiation_friction` | INTEGER | CHECK(1-5), DEFAULT 3 | Kesulitan memulai (bisa berkurang via Automaticity Decay) |
| `original_friction` | INTEGER | CHECK(1-5), DEFAULT 3 | Snapshot friction awal (untuk referensi decay calculation) |
| `energy_cost` | INTEGER | CHECK(1-5), DEFAULT 3 | Biaya tenaga (TETAP, tidak dipengaruhi decay) |
| `total_load_score` | INTEGER | GENERATED | `initiation_friction + energy_cost`. Catatan: SQLite mendukung generated columns ≥ 3.31.0; gunakan `sqlite3_flutter_libs` untuk bundling versi terbaru. |
| `impact_score` | INTEGER | CHECK(1-5), DEFAULT 3 | Dampak pada domain. **UX:** Saat pengguna membuat habit, tampilkan guided prompt: *"Seberapa penting habit ini untuk kesehatan/domainmu? (1 = sekadar tambahan, 5 = sangat penting)"* |
| `lifetime_done_count` | INTEGER | DEFAULT 0 | Counter mentah sepanjang hidup habit; bukan input utama decay. |
| `weighted_done_score` | REAL | DEFAULT 0 | Materialized score recency-weighted untuk decay. |
| `completion_rate_90d` | REAL | NULLABLE | Done / scheduled opportunities 90 hari terakhir. |
| `last_decay_evaluated_at` | TIMESTAMP | NULLABLE | Kapan decay terakhir dievaluasi. |
| `mva_duration_min` | INTEGER | DEFAULT 2 | Durasi Minimum Viable Action (menit) |
| `stacked_to_habit_id` | UUID | FK → Habit, NULLABLE | Habit yang ditumpuk (Routine Stacking). **Validasi circular reference di application layer:** sebelum insert/update, traverse chain `stacked_to_habit_id` dengan DFS hingga depth maksimal 5 level — jika habit target sudah ada di chain, tolak dengan pesan: *"Habit ini sudah ditumpuk ke dalam rantai yang sama."* Batasan: maksimal 5 level stacking (A→B→C→D→E), mencegah chain yang terlalu dalam. |
| `deleted_at` | TIMESTAMP | NULLABLE | Tombstone untuk soft delete |
| `created_at` | TIMESTAMP | NOT NULL | |

#### `HabitLog`
| Kolom | Tipe | Constraint | Keterangan |
|-------|------|-----------|------------|
| `log_id` | UUID | PK | ID unik log |
| `habit_id` | UUID | FK → Habit | Habit terkait |
| `date` | DATE | NOT NULL | Tanggal log (**hanya dibuat pada hari terjadwal**) |
| `status` | VARCHAR(25) | NOT NULL | 'Done', 'Missed', 'Skipped_Intentionally', 'Paused'. Catatan: hari di luar jadwal tidak membuat log entry (Not_Scheduled implisit). |
| `friction_reason_selected` | VARCHAR(30) | NULLABLE | 'Kurang_Waktu', 'Kelelahan', 'Lupa' |
| `duration_target_min` | INTEGER | NULLABLE | Snapshot target durasi saat log dibuat |
| `duration_actual_min` | INTEGER | NULLABLE | Durasi aktual (jika Done) |
| `deleted_at` | TIMESTAMP | NULLABLE | Tombstone |
| UNIQUE | | `(habit_id, date)` | Satu log per habit per hari terjadwal |

#### `JournalEntry`
| Kolom | Tipe | Constraint | Keterangan |
|-------|------|-----------|------------|
| `entry_id` | UUID | PK | ID unik entry |
| `user_id` | UUID | FK → UserProfile | Pemilik jurnal |
| `date` | DATE | NOT NULL | Tanggal entry |
| `mood_score` | INTEGER | CHECK(1-5) | 1=Sangat Buruk, 5=Sangat Baik |
| `keyword` | VARCHAR(50) | NULLABLE | 1 kata kunci (Journal Lite) |
| `text_content` | TEXT | NULLABLE, ENCRYPTED | Isi jurnal (Deep Reflection) |
| `gratitude_text` | TEXT | NULLABLE, ENCRYPTED | Hal yang disyukuri |
| `entry_type` | VARCHAR(15) | DEFAULT 'Lite', CHECK IN ('Lite', 'Deep') | Tipe entry |
| `created_at` | TIMESTAMP | NOT NULL | |
| UNIQUE | | `(user_id, date, entry_type)` | Maks. 1 Lite + 1 Deep per hari |

#### `ThinkingCanvasSession` (Iterasi 1 — Refleksi Terstruktur)
| Kolom | Tipe | Constraint | Keterangan |
|-------|------|-----------|------------|
| `session_id` | UUID | PK | ID unik sesi |
| `user_id` | UUID | FK → UserProfile | Pemilik sesi |
| `method_key` | VARCHAR(30) | NOT NULL | 'MindDump', 'Brainstorming', 'Scoring', 'PMI', 'ReverseBrainstorming', 'Validation' |
| `topic` | VARCHAR(200) | NULLABLE | Pertanyaan/topik sesi |
| `raw_notes` | TEXT | NULLABLE, ENCRYPTED | Coretan mentah pengguna; untuk paper-first, boleh hanya ringkasan singkat |
| `summary_text` | TEXT | NULLABLE, ENCRYPTED | Ringkasan hasil corat-coret di kertas |
| `paper_session` | BOOLEAN | DEFAULT TRUE | Sesi dianjurkan/dilakukan di kertas fisik |
| `paper_artifact_ref` | VARCHAR(100) | NULLABLE | Referensi opsional: `Buku A hal. 12`, `sticky notes meja kerja` — tanpa upload foto |
| `structured_output` | JSONB | NULLABLE, ENCRYPTED | Klaster, skor, PMI, risiko, asumsi, dsb. |
| `next_action` | VARCHAR(200) | NULLABLE | Aksi kecil berikutnya |
| `linked_habit_id` | UUID | FK → Habit, NULLABLE | Jika hasil sesi menjadi habit/action |
| `linked_decision_id` | UUID | FK → DecisionJournal, NULLABLE | Jika dikirim ke Decision Journal (Iterasi 2) |
| `created_at` | TIMESTAMP | NOT NULL | |
| `deleted_at` | TIMESTAMP | NULLABLE | Tombstone |

#### `CoreValue` (LifeTree Plus)
| Kolom | Tipe | Constraint | Keterangan |
|-------|------|-----------|------------|
| `value_id` | UUID | PK | |
| `user_id` | UUID | FK → UserProfile | |
| `value_text` | VARCHAR(100) | NOT NULL | Nilai inti (maks. 3 per user, validasi di application layer) |
| `created_at` | TIMESTAMP | NOT NULL | |

#### `DecisionJournal` (LifeTree Plus)
| Kolom | Tipe | Constraint | Keterangan |
|-------|------|-----------|------------|
| `decision_id` | UUID | PK | |
| `user_id` | UUID | FK → UserProfile | |
| `decision_title` | VARCHAR(200) | NOT NULL | Keputusan yang diambil |
| `context` | TEXT | NULLABLE | Situasi saat mengambil keputusan |
| `expected_outcome` | TEXT | NULLABLE | Hasil yang diharapkan |
| `decided_at` | TIMESTAMP | NOT NULL | |
| `review_at` | TIMESTAMP | NOT NULL | Pengingat review (default: 90 hari) |
| `reviewed` | BOOLEAN | DEFAULT FALSE | |

#### `GoalHierarchy` (LifeTree Plus)
| Kolom | Tipe | Constraint | Keterangan |
|-------|------|-----------|------------|
| `goal_id` | UUID | PK | |
| `user_id` | UUID | FK → UserProfile | |
| `parent_goal_id` | UUID | FK → GoalHierarchy, NULLABLE | NULL = Visi (Level 0) |
| `level` | INTEGER | NOT NULL | 0=Visi, 1=Project, 2=Habit/Task |
| `title` | VARCHAR(200) | NOT NULL | |
| `deadline` | DATE | NULLABLE | Hanya untuk level 1 (Project) |
| `status` | VARCHAR(20) | DEFAULT 'Active' | 'Active', 'Completed', 'Archived' |

#### `Subscription`
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

#### `WellnessPromptLog`
| Kolom | Tipe | Constraint | Keterangan |
|-------|------|-----------|------------|
| `prompt_id` | UUID | PK | |
| `user_id` | UUID | FK → UserProfile | |
| `trigger_type` | VARCHAR(30) | NOT NULL | 'Mood_3day', 'Mood_Drop', 'Sustained_Low_Mood_14day' |
| `prompted_at` | TIMESTAMP | NOT NULL | |
| `user_action` | VARCHAR(30) | NULLABLE | 'Dismissed', 'Opened_Safety_Card', 'Recovery_Mode', 'Tapped_Hotline_CTA'. Tracking berhenti di interaksi UI; apakah panggilan berhasil dilakukan tidak dapat diketahui aplikasi. Tabel ini local-only, retention 90 hari, dan tidak diekspor. |

#### `DeviceRegistry` (Privacy/E2EE Phase)
| Kolom | Tipe | Constraint | Keterangan |
|-------|------|-----------|------------|
| `device_id` | UUID | PK | |
| `user_id` | UUID | FK → UserProfile | |
| `device_name` | VARCHAR(100) | NULLABLE | "iPhone 15", "Pixel 8" |
| `platform` | VARCHAR(10) | NOT NULL | 'ios', 'android' |
| `public_key` | TEXT | NOT NULL | Kunci publik perangkat untuk E2EE handshake. **Format:** Base64-encoded X25519 public key (32 byte raw, encoded ~44 karakter). **Algoritma:** X25519 (ECDH) untuk key exchange — dipilih karena ukuran kunci kecil (32 byte) dan performa tinggi di mobile. **Enkripsi konten:** AES-256-GCM dengan 12-byte nonce. **Key derivation:** Standard Mode memakai random 256-bit master key di secure storage OS. Advanced Mode dapat memakai recovery phrase/seed untuk recovery material; HKDF-SHA256 dipakai untuk derivasi wrapping/key material yang relevan. **Proses QR key transfer:** QR berisi *ephemeral X25519 public key* + *encrypted AES-256 master key* (dienkripsi dengan shared secret dari ECDH antara perangkat). Masa berlaku QR: 5 menit. |
| `key_version` | INTEGER | DEFAULT 1 | Versi kunci enkripsi — increment saat key rotation |
| `last_sync_at` | TIMESTAMP | NULLABLE | Terakhir sinkronisasi |
| `registered_at` | TIMESTAMP | NOT NULL | |

#### `ConsentLog`
| Kolom | Tipe | Constraint | Keterangan |
|-------|------|-----------|------------|
| `consent_id` | UUID | PK | |
| `user_id` | UUID | FK → UserProfile | |
| `consent_type` | VARCHAR(50) | NOT NULL | 'ToS', 'Privacy_Policy', 'Data_Processing', 'Child_Parental', 'Wellness_Disclaimer' |
| `granted_at` | TIMESTAMP | NOT NULL | |
| `version` | VARCHAR(20) | NOT NULL | Versi dokumen yang disetujui (misal: "ToS_v1.2") |
| `revoked_at` | TIMESTAMP | NULLABLE | NULL = masih aktif |

#### `ReminderPreference`
| Kolom | Tipe | Constraint | Keterangan |
|-------|------|-----------|------------|
| `habit_id` | UUID | FK → Habit, PK | Satu preferensi per habit |
| `reminder_enabled` | BOOLEAN | DEFAULT TRUE | |
| `reminder_time` | TIME | DEFAULT '08:00' | Waktu notifikasi |
| `quiet_hours_start` | TIME | DEFAULT '22:00' | Jam mulai tidak diganggu |
| `quiet_hours_end` | TIME | DEFAULT '07:00' | Jam selesai tidak diganggu |

### 7.4 Relasi Antar Entitas (ER Overview)

```
UserProfile 1───∞ LifeAudit
UserProfile 1───∞ WeeklyPulse
UserProfile 1───∞ Habit
UserProfile 1───∞ JournalEntry
UserProfile 1───∞ CoreValue (max 3, app-layer validation)
UserProfile 1───∞ DecisionJournal
UserProfile 1───∞ GoalHierarchy
UserProfile 1───1 Subscription
UserProfile 1───∞ WellnessPromptLog
UserProfile 1───∞ DeviceRegistry
UserProfile 1───∞ ConsentLog

Habit 1───∞ HabitLog
Habit 1───1 ReminderPreference
Habit 1───0..1 Habit (stacked_to_habit_id: Routine Stacking, no circular ref)
GoalHierarchy 1───∞ GoalHierarchy (parent_goal_id: tree structure)
```

### 7.5 Database Index Specification

Index krusial untuk performa query yang sering dijalankan:

| Tabel | Index | Tujuan |
|-------|-------|--------|
| `HabitLog` | `(habit_id, date, status)` | Query `cumulative_done` recency-weighted: filter Done dalam 90/180 hari terakhir |
| `HabitLog` | `(habit_id, date DESC)` | Query Missed terbaru untuk Friction Intervention threshold |
| `JournalEntry` | `(user_id, date, mood_score)` | Wellness support: scan mood_score ≤ 2 dalam 3–14 hari terakhir |
| `Habit` | `(user_id, status, domain_tag)` | Action of the Day: query habit aktif per domain |
| `WeeklyPulse` | `(user_id, domain_tag, week_start_date DESC)` | Domain score TTL: cek kebaruan skor per domain |
| `WellnessPromptLog` | `(user_id, prompted_at DESC)` | Frequency cap: cek kapan terakhir wellness prompt ditampilkan |
| `ConsentLog` | `(user_id, consent_type)` | Cek status consent terkini per tipe |

> **Catatan:** `UNIQUE(habit_id, date)` di HabitLog otomatis membuat index composite — tapi tidak mencakup `status`, sehingga index tambahan diperlukan untuk query yang memfilter status.

---

## 8. Spesifikasi MVP

**Timeline:** 12–16 minggu untuk MVP Core yang dipangkas | **Target:** Dewasa 18–35 tahun | **Asumsi Tim:** 3–5 developer (untuk 1–2 developer, timeline realistis 18–24 minggu)

MVP Core tetap membawa visi **Personal OS**, tetapi hanya membangun satu irisan sempit: **Daily Orientation Loop**. Loop ini menjawab 3 pertanyaan harian: "Apa kondisiku?", "Apa satu aksi kecil hari ini?", dan "Jika terlewat, hambatannya apa?"

### MVP Lean — "MVP Core" (Daily Orientation Loop)

| Komponen | Fitur | Prioritas |
|----------|-------|-----------|
| Onboarding | Life Audit (domain Tubuh, 1 pertanyaan) | P0 |
| Dashboard | Central Command Dashboard (3 elemen: Pohon + Action + Journal) | P0 |
| Lapis 0 | Journal Lite (emoji + keyword) | P0 |
| Lapis 0 | Thinking Canvas Lite: prompt paper-first + simpan ringkasan | P0 |
| Lapis 0 | Friction Intervention (threshold per frekuensi) | P0 |
| Lapis 0 | Recovery Mode duration selector + `mva_duration_min` one-time override | P0 |
| Lapis 0 | Safety Card (hardcoded 119 + 119 ext 8) | P0 |
| Lapis 1 | Canopy Load Basic (friction + energy + soft warning) | P0 |
| Lapis 2 | Domain Tubuh saja | P0 |
| Privacy | Local-only storage, tanpa akun dan tanpa cloud sync | P0 |
| Security | Ekspor Lokal (JSON/CSV) | P0 |
| UX | Dark Mode (aksesibilitas, bukan kosmetik) | P0 |
| Accessibility | Screen Reader + Color+Icon+Label | P0 |
| Monetisasi | Tier Gratis | P0 |

### MVP Iterasi 1 (Bulan 3–4 setelah core stabil)

| Komponen | Fitur | Prioritas |
|----------|-------|-----------|
| Dashboard | Radar Keseimbangan (domain Tubuh + Coming Soon lainnya) | P1 |
| Lapis 0 | Deep Reflection (opsional) | P1 |
| Lapis 0 | Thinking Canvas Full: skoring, reverse brainstorming, validasi, review mingguan, Decision Journal link | P1 |
| Lapis 0 | Anti-Banner-Blindness Safety Card | P1 |
| Weekly | Weekly Pulse Check | P1 |
| Notification | Out-of-App Wellness Check | P1 |
| Lapis 1 | Automaticity Decay (recency-weighted) | P1 |
| Privacy | SQLCipher/local encrypted backup + app-level biometric lock | P1 |
| Monetisasi | LifeTree Plus (Insights non-AI, PDF Export, Life Compass, Decision Journal preview) | P1 |
| Monetisasi | LifeTree Student | P1 |
| Monetisasi | Annual Plan Rp 249K/thn | P1 |
| Lapis 3 | Life Compass (3 Core Values) | P1 |
| Lapis 1 | Goal Hierarchy (2 level: Project → Habit) | P1 |

### MVP Iterasi 2 (Fase 1.5)

| Komponen | Fitur | Prioritas |
|----------|-------|-----------|
| Lapis 2 | Domain Keuangan, Hubungan, Emosi, Karir, Rekreasi (aktif bertahap) | P1 |
| Monetisasi | Micro-transaksi kosmetik (skin pohon saja, Dark Mode gratis) | P2 |
| Lapis 3 | Decision Journal | P2 |

### Scope OUT (Fase 2)

- Teen Mode (13–17 tahun)
- Seedling Mode (< 13 tahun)
- Parental Dashboard
- Age Graduation
- Goal Hierarchy level Visi (5 tahun)
- Cloud Sync, zero-knowledge E2EE, seed phrase, recovery contact, key rotation, dan sync conflict resolution
- On-Device Insights (AI-based) — catatan: hanya komponen AI yang Scope OUT; Insights non-AI (statistik dasar, tren) masuk Iterasi 1 sebagai Plus
- Bahasa Inggris & regionalisasi

### Canonical Scope Matrix

| Fitur | MVP Lean | Iterasi 1 | Iterasi 2 | Fase 2 |
|-------|:--------:|:---------:|:---------:|:------:|
| Dark Mode | ✅ P0 | — | — | — |
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
| Weekly Pulse | ❌ | ✅ P1 | — | — |
| Life Compass | ❌ | ✅ P1 | — | — |
| Decision Journal | ❌ | ❌ | ✅ P2 | — |
| Goal Hierarchy | ❌ | ✅ P1 | — | — |
| Cloud Sync | ❌ | ❌ | ❌ | ✅ |
| Zero-Knowledge E2EE | ❌ | ❌ | ❌ | ✅ |
| On-Device Insights (non-AI) | ❌ | ✅ P1 | — | — |
| On-Device Insights (AI) | ❌ | ❌ | ❌ | ✅ |
| Micro-transaksi (skin pohon) | ❌ | ❌ | ✅ P2 | — |
| Teen/Seedling Mode | ❌ | ❌ | ❌ | ✅ |

---

## 9. Analisis Kompetitif

### 9.1 Pemetaan Kompetitor

| Aplikasi | Kategori | Streak System | Anti-Guilt | Jurnal | Habit Tracker | Life Audit | E2EE | Child Safety | Harga |
|----------|----------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|-------|
| **LifeTree** | Personal OS | ❌ | ✅ | ✅ | ✅ | ✅ | Future | ✅ (Fase 2) | Freemium Rp 29K |
| **Fabulous** | Habit + Coaching | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ~Rp 65K/bln |
| **Habitica** | Gamified Habits | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ~Rp 65K/bln |
| **Streaks** | Habit Tracker | ✅✅ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | One-time Rp 65K |
| **Day One** | Journaling | ❌ | Netral | ✅✅ | ❌ | ❌ | ✅ | ❌ | Rp 44K/bln |
| **Reflectly** | AI Journal | ❌ | Netral | ✅ | ❌ | ❌ | ❌ | ❌ | Rp 75K/bln |
| **Finch** | Self-care Gamified | ✅ | Sebagian | ✅ | ✅ | ❌ | ❌ | ❌ | Rp 50K/bln |
| **Notion Life OS** | Template System | ❌ | Netral | ❌ | ✅ | Sebagian | ❌ | ❌ | Gratis (Notion) + Rp 50-200K (template, one-time) |
| **Daylio** | Mood + Habit Tracker | ❌ | Sebagian | ✅ (mood) | ✅ | ❌ | ❌ | ❌ | Gratis + Premium ~Rp 50K/bln |

### 9.2 Differentiator Utama LifeTree

1. **Secara eksplisit menghindari streak punishment** — berbeda dari mayoritas habit apps yang masih memakai *loss aversion*.
2. **Canopy Load System** — manajemen beban kognitif, tidak ada di kompetitor mana pun.
3. **Life Audit / Radar Keseimbangan** — integrasi 6 domain kehidupan, bukan sekadar daftar habit.
4. **Friction Journaling** — kegagalan dikonversi menjadi data refleksi, bukan hukuman.
5. **Thinking Canvas** — pilar refleksi paper-first untuk membangun kebiasaan corat-coret di kertas asli dan mengubah kebingungan menjadi aksi kecil.
6. **Compliance anak Indonesia (PP TUNAS)** — disiapkan sebagai future compliance track, bukan klaim sertifikasi hukum.
7. **Privacy roadmap** — dimulai dari minimisasi data lokal, lalu naik ke zero-knowledge E2EE setelah core retention terbukti.

### 9.3 Notion Life OS — Kompetitor Template

Notion memiliki ekosistem template gratis/berbayar untuk *life management* ("Life OS"). Perbandingan:

| Aspek | LifeTree | Notion Life OS |
|-------|----------|----------------|
| **Learning Curve** | Rendah (guided) | Tinggi (butuh setup manual) |
| **Mobile Experience** | Native app | Web-based (lambat) |
| **Automation** | Built-in (Action of the Day, Automaticity Decay) | Manual |
| **Privacy** | Local-first MVP, E2EE roadmap | Notion bisa baca semua data |
| **Harga** | Rp 29K/bln | Gratis (Notion) + Rp 50-200K (template, one-time) |

**Rekomendasi:** Pertimbangkan fitur **import dari Notion** di Fase 1.5 — user export Notion database → JSON → LifeTree import habits + journal entries. Ini menurunkan switching cost.

- Tidak ada pemain lokal yang memadukan **jurnal + habit tracker + life audit** dalam satu aplikasi.
- Aplikasi kesehatan mental Indonesia (misal: *Riliv*, *Kalm*) fokus pada terapi/konseling — bukan *self-orientation* harian.
- LifeTree mengisi celah antara **aplikasi produktivitas yang menghukum** dan **aplikasi kesehatan mental yang terlalu klinis**.

---

## 10. Setup Project Flutter

Gunakan folder `app/` untuk project Flutter agar dokumentasi (`README.md`, `docs/`, dan `index.html`) tetap menjadi documentation hub di root repo.

**Prasyarat resmi:**
- Install Flutter SDK: https://docs.flutter.dev/install
- Setup Android tooling: https://docs.flutter.dev/platform-integration/android/setup
- Setup editor: https://docs.flutter.dev/tools/vs-code atau https://docs.flutter.dev/tools/android-studio
- Referensi `flutter create`: https://docs.flutter.dev/reference/create-new-app

**Buat project Flutter dari root repo:**

```powershell
cd D:\LAB\git\life-tree
flutter doctor -v
flutter create app --project-name life_tree --org id.lifetree --platforms android,ios
cd app
flutter run
```

Jika development utama di Windows dan ingin preview desktop lokal, tambahkan platform Windows dari dalam folder `app/`:

```powershell
flutter create . --platforms windows
flutter run -d windows
```

**Dependency awal yang disarankan untuk MVP local-only:**

```powershell
flutter pub add go_router flutter_riverpod drift sqlite3_flutter_libs path_provider path uuid intl flutter_local_notifications share_plus
flutter pub add dev:build_runner drift_dev flutter_lints
```

**Struktur folder awal:**

```text
app/
  lib/
    main.dart
    src/
      app.dart
      core/
        theme/
        routing/
        time/
      data/
        local_db/
        export/
      features/
        dashboard/
        habit/
        journal/
        thinking_canvas/
        safety/
        onboarding/
      shared/
        widgets/
        copy/
```

**Aturan setup MVP:**
- Jangan tambah Firebase/backend dulu.
- Jangan desain onboarding seed phrase, recovery contact, atau E2EE di MVP Core.
- Simpan data lokal dengan SQLite; SQLCipher dan biometric lock masuk Privacy Hardening.
- Buat semua copy anti-guilt di file terpisah agar siap i18n.
- Jalankan `flutter analyze` dan `flutter test` sebelum commit.

**Checklist pertama setelah scaffold:**
- Ganti app title menjadi `LifeTree`.
- Buat theme Calm Tech, dark mode, dan typography dasar.
- Buat route kosong untuk Dashboard, Journal Lite, Habit Setup, Thinking Canvas Lite, dan Safety Card.
- Tambahkan schema lokal untuk `Habit`, `HabitLog`, `JournalEntry`, `ThinkingCanvasSession`, dan `UserProfile`.
- Tambahkan export JSON/CSV manual sebelum fitur sync apa pun.

---

## Changelog Revisi

### Versi 14.0 — MVP Daily Orientation Loop & Privacy Roadmap

| # | Perubahan | Sumber Evaluasi | Alasan |
|---|-----------|----------------|--------|
| 98 | **Personal OS tetap menjadi visi, MVP dipangkas menjadi Daily Orientation Loop** | Evaluasi konsep internal | MVP awal terlalu berat. Loop harian memvalidasi inti produk: kondisi diri, satu aksi kecil, dan refleksi saat terlewat. |
| 99 | **Privacy/E2EE ditunda dari MVP Core** | Keputusan produk | E2EE multi-device, recovery, key rotation, dan conflict resolution mahal secara teknis; fokus awal harus ke retensi dan value proposition. |
| 100 | **Crisis terminology → Wellness support** | Evaluasi safety/compliance | Menghindari kesan diagnosis/deteksi klinis. LifeTree hanya memberi prompt dukungan dan akses resource profesional. |
| 101 | **Annual Plan dikonsistenkan ke Rp 249K/tahun** | Audit dokumen | Menghapus sisa kontradiksi Rp 199K vs Rp 249K. |
| 102 | **Tambah panduan setup Flutter** | Kebutuhan implementasi | Developer bisa membuat app Flutter di folder `app/` tanpa menimpa documentation hub. |

### Versi 13.0 — Penutupan Inkonsistensi & Spesifikasi Eksplisit

| # | Perubahan | Sumber Evaluasi | Alasan |
|---|-----------|----------------|--------|
| 91 | **MVP Quick Start: "2 pertanyaan" → "1 pertanyaan"** — Onboarding table menyebut "2 dari 6 pertanyaan Life Audit (Quick Start — pilih 2 pertanyaan Tubuh)" tapi §5.3A Life Audit mengatakan "Hanya tanyakan #1 (Tubuh)". Domain Tubuh hanya punya 1 pertanyaan di tabel — "2 pertanyaan Tubuh" tidak masuk akal. | Evaluasi v12.0 (🔴) | Inkonsistensi internal. Developer tidak tahu apakah harus menanyakan 1 atau 2 pertanyaan di MVP Quick Start. Jika domain Tubuh hanya punya 1 pertanyaan (#1), maka Quick Start = 1 pertanyaan. |
| 92 | **`mva_duration_min` integrasi eksplisit ke Friction Intervention** — Field ada di Habit table (DEFAULT 2) tapi Friction Intervention hardcoded "5 menit" alih-alih mereferensikan field. Sekarang: opsi "Kurang Waktu" menawarkan durasi `mva_duration_min` menit sebagai *one-time override* untuk hari berikutnya; setelah 1 kali, override otomatis terhapus. Durasi aktual dicatat di `duration_actual_min`. | Evaluasi v12.0 (🟡) | Field orphaned = developer tidak tahu kapan nilainya digunakan. Hardcoded "5 menit" mengabaikan per-habit customization. |
| 93 | **Public key format precision** — "Base64-encoded raw bytes" → "Base64-encoded X25519 public key (32 byte raw, encoded ~44 karakter)" | Evaluasi v12.0 (🟡) | "Raw bytes" ambigu — berapa byte? X25519 = 32 byte, tapi tanpa spesifikasi developer bisa salah asumsi (misal: 64 karakter hex). |
| 94 | **Fix docs/04 Database Index Specification table** — Sel tabel kosong di dokumen teknis (README §7.5 benar tapi docs/04 rusak). Diisi ulang dengan data yang sama. | Evaluasi v12.0 + audit internal (🟡) | Dokumen teknis yang tidak bisa dibaca = tidak berguna untuk developer. |
| 95 | **Tambah Daylio ke docs/00 competitive table + fix column alignment docs/02** — Daylio ada di README dan docs/02 tapi hilang dari blueprint; docs/02 Daylio row memiliki kolom tergeser (Kategori masuk ke kolom Streak). | Evaluasi v12.0 + audit internal (🟡) | Kompetitor paling relevan (mood + habit, SEA) tidak muncul di semua dokumen; formatting rusak menyesatkan. |
| 96 | **Fix docs/01 §1.2 title** — "Manajemen Beban Kognitif (*Cognitive Load Theory*)" → "Canopy Load — Konstruk Produk (Bukan Klaim Ilmiah)" | Audit internal (🟢) | Judul masih menyebut CLT padahal konten sudah diposisikan sebagai konstruk produk — inkonsistensi antara README dan docs. |
| 97 | **Fix docs/01 abstrak** — "integrasi *Habit Formation Theory*, *Cognitive Load Theory*" → "integrasi *Habit Formation Theory*, *Canopy Load (Konstruk Produk)*" | Audit internal (🟢) | Abstrak masih menyebut CLT sebagai integrasi, bertentangan dengan reframing v12.0 yang menyatakan Canopy Load bukan backing ilmiah. |

### Versi 12.0 — Perbaikan Fondasi Ilmiah, Kriptografi & Operasional

| # | Perubahan | Sumber Evaluasi | Alasan |
|---|-----------|----------------|--------|
| 74 | **CLT → Konstruk Produk** — Canopy Load tidak lagi mengklaim backing dari CLT; ditambahkan konteks ego depletion + replication crisis | Sonnet 4.6 (🔴) | CLT = teori pembelajaran, bukan manajemen energi harian. Ego depletion sendiri gagal direplikasi. Canopy Load = konstruk produk murni. |
| 75 | **Custom frequency `per_period`** didefinisikan: rolling 14 hari untuk semua frekuensi Custom | Sonnet 4.6 (🔴) | Tanpa definisi, developer membuat asumsi berbeda-beda. 14 hari cukup untuk habit 1x/2 minggu dan tidak terlalu lambat. |
| 76 | **CrisisPromptLog frequency cap fix** — `last_crisis_prompt_at` di UserProfile sebagai cloud metadata | Sonnet 4.6 (🔴) | Local-only = frequency cap hilang setelah reinstall. Cloud metadata bukan konten sensitif — konsisten dengan arsitektur zero-knowledge. |
| 77 | **Dark Mode → fitur gratis** — dipindahkan dari micro-transaction ke tier Dasar | Sonnet 4.6 (🔴) | Dark mode = kebesaran aksesibilitas, bukan kosmetik. Menjualnya bertentangan dengan Calm Tech + kalah dari kompetitor. |
| 78 | **Spesifikasi kriptografi konkret** — X25519 (ECDH) + AES-256-GCM + QR key exchange protocol | Sonnet 4.6 (🔴) | `public_key TEXT` tanpa format/algoritma = developer harus keputusan sendiri — berisiko untuk sistem zero-knowledge. |
| 79 | **Database index specification** — 7 index krusial untuk query performance | Sonnet 4.6 (🟡) | HabitLog tanpa index `(habit_id, date, status)` = suboptimal untuk cumulative_done calculation. |
| 80 | **LTV calculation eksplisit** — Rp 193.000 (churn 15%), sensitivitas churn 10–20% | Sonnet 4.6 (🟡) | CAC:LTV target tanpa LTV calculation = tidak bermakna. CAC maks Rp 64.000 per pengguna berbayar. |
| 81 | **Daylio ditambahkan** ke analisis kompetitif | Sonnet 4.6 (🟡) | Kompetitor paling langsung (mood + habit, desain minimal) — absennya melemahkan credibility. |
| 82 | **Infrastruktur analytics** — PostHog self-hosted (Fase 1), custom long-term | Sonnet 4.6 (🟡) | KPI terdefinisi tapi tidak ada solusi analytics — rencana pengukuran tidak bisa dilaksanakan. |
| 83 | **6 pertanyaan Life Audit** dispesifikasikan — MVP Quick Start: hanya #1 Tubuh | Sonnet 4.6 (🟡) | Developer tidak bisa implementasi onboarding tanpa pertanyaan yang konkret. |
| 84 | **App Store compliance** — Apple Guideline 1.4.5, Google Sensitive Data Policy, age rating 18+ | Sonnet 4.6 (🟡) | Mental health apps menghadapi scrutiny khusus — rejection bisa menghambat launch. |
| 85 | **Testing strategy** — unit, integration, manual QA, edge case, security audit | Sonnet 4.6 (🟡) | Crisis intervention tanpa testing strategy = risiko serius. |
| 86 | **Tree art direction** — flat illustration + Lottie, ~20 Lottie file, 800ms cross-fade | Sonnet 4.6 (🟢) | Pohon = emotional anchor tapi tidak ada art direction — penghambat produksi. |
| 87 | **`mva_duration_min` usage** — digunakan saat Friction Intervention menawarkan "versi ringan" | Sonnet 4.6 (🟢) | Field ada tapi tidak direferensikan di algoritma manapun — sekarang terintegrasi. |
| 88 | **Annual Plan Rp 249.000/thn** (diskon ~29%, bukan 43%) | Sonnet 4.6 (🟢) | Diskon 43% terlalu dalam untuk startup baru — menekan cash flow dan perceived value. 29% lebih moderat, benchmark Notion ~20%. |
| 89 | **Circular reference validation** — DFS depth maks 5 level untuk stacked_to_habit_id | Sonnet 4.6 (🟢) | Disebutkan "validasi di application layer" tapi tidak dijelaskan implementasinya — bukan trivial untuk graph arbitrarily deep. |
| 90 | **Domain score expired fallback** untuk Iterasi 2 — gunakan stale score terakhir + default 5 | Sonnet 4.6 (🔴) | LifeAudit awal bisa sangat outdated untuk 6 domain — fallback ke stale score lebih masuk akal. |

### Versi 11.0 — Perbaikan Kritis Pre-Build

| # | Perubahan | Sumber Evaluasi | Alasan |
|---|-----------|----------------|--------|
| 39 | **Action of the Day: Celebration State** — exit state saat semua habit Done + cold start fallback | Agent A (🔴), Agent C | Tanpa exit state, algoritma crash di MVP Lean (1 domain, semua Done). Cold start: pengguna baru tanpa skor domain. |
| 40 | **HabitLog: hanya buat di hari terjadwal** — `Not_Scheduled` implisit, tidak ada log untuk hari di luar jadwal | Agent A (🔴), Agent B (🟡), Agent C | `UNIQUE(habit_id, date)` + habit non-daily = ambigu. Friction Intervention hanya menghitung Missed dari hari terjadwal. |
| 41 | **`cumulative_done_count` counter** di tabel Habit — denormalisasi untuk menghindari full table scan | Agent A (🔴) | `COUNT(HabitLog WHERE Done)` = full table scan untuk pengguna aktif 2+ tahun. Counter di-increment saat log ditambahkan. |
| 42 | **Shamir 2-of-2 → 2-of-3** — tiga fragment, dua diperlukan untuk recovery | Agent B (🔴), Agent A (🟡) | 2-of-2 = kehilangan 1 fragment = gagal total. 2-of-3 toleransi kehilangan 1 fragment. Secondary backup disimpan pengguna. |
| 43 | **Sync Conflict: LWW + Conflict Copy** untuk mutable data (JournalEntry) | Agent B (🔴), Agent C (🔴), Agent D (🟡) | LWW untuk jurnal = data loss diam-diam. Konflik < 5 menit → kedua versi ditampilkan, pengguna memilih. |
| 44 | **E2EE Multi-Device Bootstrap** — QR code transfer + OS Keychain auto-sync | Agent C (🔴) | Kalau default Keychain, bagaimana pindah HP? QR code lokal jika perangkat lama ada; Keychain sync jika OS mendukung. |
| 45 | **Canonical Scope Matrix** — satu tabel menentukan fitur mana di iterasi mana | Agent A (🟡), Agent C (🔴) | Decision Journal di 3 tempat berbeda, Radar ambigu, On-Device Insights vs AI. Matrix menghapus semua kontradiksi. |
| 46 | **`Called_Hotline` → `Tapped_Hotline_CTA`** | Agent A (🔴), Agent C, Agent D | Aplikasi tidak bisa tahu apakah panggilan berhasil. Tracking hanya sampai interaksi UI. |
| 47 | **`cumulative_done` → recency-weighted** — 90 hari bobot 1, 91-180 hari bobot 0.5, >180 tidak dihitung | Agent C (🔴) | Automaticity bukan saldo permanen — 100x sukses tahun lalu + 6 bulan berhenti ≠ "mudah dimulai". |
| 48 | **`Dormant` season definition** — trigger, perilaku, visual | Agent B (🟢), Agent C | Season Dormant sebelumnya tidak pernah didefinisikan. Sekarang: > 14 hari tidak buka app → notifikasi dikurangi; sistem menawarkan review habit saat user kembali. |
| 49 | **Canopy Load capacity enforcement** — soft enforcement dengan peringatan ramah | Agent B (🟡) | `canopy_load_capacity = 10` tanpa enforcement = angka dekoratif. Sekarang: soft enforcement + peringatan Anti-Guilt. |
| 50 | **Tree Vitality State Specification** — 6 state visual + hard rule "tidak pernah mengecil" | Agent B (🟡) | Pohon = emotional anchor tapi paling sedikit dispesifikasikan. Step-based growth, Story Moment tiap 30 hari. |
| 51 | **`impact_score` user guidance** — guided prompt saat membuat habit | Agent B (🟡) | Jika semua user isi default 3, variabel tidak berpengaruh. Tooltip + deskriptor membantu pengguna mengisi secara bermakna. |
| 52 | **Decision Journal scope unifikasi** — Iterasi 2 (P2), bukan Scope OUT | Agent A (🟡) | Decision Journal muncul di 3 tempat berbeda dengan sinyal kontradiktif. Sekarang konsisten: Iterasi 2. |
| 53 | **Student Tier verification** — self-declaration + `.ac.id` email di Fase 1 | Agent A (🟡), Agent B | Verifikasi belum terdeskripsi. Fase 1: honor system + email domain. Bisa ditingkatkan ke SheerID nanti. |
| 54 | **MVP timeline + team size assumption** — 3-5 dev untuk 16-20 minggu, 1-2 dev realistis 24-30 minggu | Agent B (🟡), Agent D (🟡) | Timeline tanpa asumsi ukuran tim tidak bermakna. |
| 55 | **`frequency = 'Custom'` definition** — pola jadwal bebas + threshold proporsional | Agent A (🟢), Agent C | Custom tanpa definisi = ambigu. Threshold intervensi: `(missed/scheduled_per_period) > 0.5`. |
| 56 | **Domain score TTL / staleness** — fresh (0-14 hari), stale (15-30), expired (>30) | Agent C | Skor lama tanpa TTL bisa menyesatkan algoritma Action of the Day. |
| 57 | **Multi-layer medical disclaimer** + `crisis_disclaimer_acknowledged` | Agent D (🔴) | Disclaimer di ToS saja tidak cukup. Tiga lapisan: onboarding, crisis modal pertama, safety card. |
| 58 | **Shame-Free Return Rate formula eksplisit** | Agent D (🟡) | "Kembali aktif" tidak terdefinisi — cukup buka app? Complete 1 habit? Sekarang: complete ≥ 1 habit dalam 7 hari. |
| 59 | **Automaticity Decay: A/B testing framework** — 3 variant (15/20/30 hari) | Agent D (🔴) | Formula decay terlihat pseudo-scientific. A/B testing + disclaimer eksplisit bahwa ini model produk. |
| 60 | **WHO-5 UX description** — di Weekly Pulse, opsional, disimpan di WellnessAssessment | Agent A (🟢) | WHO-5 sebagai KPI tapi tidak ada deskripsi UX. |
| 61 | **`last_wellness_push_at`** di UserProfile — frequency cap Out-of-App Wellness Check | Agent A (🟡) | Frequency cap 1x/14 hari tidak bisa diterapkan tanpa storage kapan terakhir dikirim. |
| 62 | **"Calm Tech" kortisol hedging** — "diasosiasikan dengan ketenangan", bukan "menurunkan kortisol" | Agent A (🟢) | Evidence kortisol langsung debatable. Lebih aman secara ilmiah. |
| 63 | **`deleted_at` tombstone** di semua tabel — soft delete untuk sinkronisasi | Agent C | Hard delete = penghapusan di satu perangkat tidak ter-propagate ke perangkat lain. |
| 64 | **"MVP Berdarah" → "MVP Core"** — penamaan selaras dengan tone brand | Agent B (🟢) | "Berdarah" bertentangan dengan filosofi calm tech dan anti-guilt. |
| 65 | **CrisisPromptLog: local-only + retention 90 hari** — tidak di-sync, tidak diekspor | Agent B (🟢) | Data kesehatan sangat sensitif. Jika ikut di-sync ke cloud, risiko privacy. |
| 66 | **App-level biometric lock** — autentikasi saat kembali dari background > 5 menit | Agent D | Device theft mitigation: jika HP hilang dalam keadaan unlocked, data tetap aman. |
| 67 | **Permenkomdigi No. 9/2026** alignment — 5 kelompok usia anak | Agent B (🟢) | PP 17/2025 sudah punya aturan pelaksana. Pembagian usia produk perlu mengacu ini untuk Fase 2. |
| 68 | **Duhigg (Habit Loop) + Gollwitzer (Implementation Intention)** referensi akademis | Agent D | Memperkuat justifikasi strategi Routine Stacking dan "kapan-dimana" habit. |
| 69 | **`original_friction` snapshot** di tabel Habit | — | Diperlukan untuk Automaticity Decay calculation (baseline sebelum decay). |
| 70 | **Recovery Mode UX flow** — duration selector (1/3/7 hari) + visual pohon bersalju | Agent D | Flow Friction Intervention belum detail. Sekarang: pilih Kelelahan → pilih durasi → konfirmasi. |
| 71 | **Notion Life OS sebagai kompetitor** + rekomendasi fitur import | Agent D | Notion template adalah kompetitor indirect yang perlu diperhitungkan. |
| 72 | **Annual Plan Rp 199.000/thn** | Agent D | Mengunci pengguna dan meningkatkan LTV — diskon 43% dari monthly. |
| 73 | **SQLite version bundling** via `sqlite3_flutter_libs` — untuk GENERATED columns | Agent B (🟢) | Device Android lama mungkin SQLite < 3.31.0. Bundling menghindari isu kompatibilitas. |

### Versi 10.0 — Penutupan Celah Sisa dari Evaluasi Eksternal

| # | Perubahan | Sumber Evaluasi | Alasan |
|---|-----------|----------------|--------|
| 27 | **Tambahkan Auth mechanism** — email+password hash terpisah dari enkripsi konten | Agent A | Zero-knowledge tapi butuh cara mengautentikasi akun. Server autentikasi identitas, bukan konten. |
| 28 | **Tambahkan Sync Conflict Resolution** — Last-Write-Wins berbasis timestamp, append-only untuk HabitLog | Agent A | Multi-device sync butuh strategi resolusi konflik. |
| 29 | **Tambahkan Key Rotation** — re-encryption bertahap di client-side + key version | Agent A | Kunci enkripsi perlu bisa dirotasi tanpa kehilangan data. |
| 30 | **Tambahkan `DeviceRegistry`** tabel — multi-device E2EE butuh daftar perangkat + public key + key version | Agent A | Cloud sync antar perangkat memerlukan key exchange. |
| 31 | **Tambahkan `ConsentLog`** tabel — audit trail persetujuan data (ToS, Privacy Policy, dll) | Agent A | UU PDP mensyaratkan pencatatan persetujuan; juga untuk compliance anak. |
| 32 | **Tambahkan `ReminderPreference`** tabel — waktu notifikasi + quiet hours per habit | Agent A | Tanpa preferensi notifikasi, sistem bisa mengganggu di jam yang salah. |
| 33 | **Tambahkan rencana pengukuran kualitatif** — user interview bulan 2/4/6 + Perceived Support Score | Agent C | WHO-5 + Shame-Free Return Rate hanya kuantitatif; perlu data kualitatif. |
| 34 | **Tambahkan Anti-Guilt Score** metrik internal | Agent C | Metrik internal yang mengukur seberapa sering fitur suportif digunakan saat gagal. |
| 35 | **Tambahkan i18n structure** — string terpisah, locale-aware, lokalize kultural | Agent C | Ekspansi Asia Tenggara butuh persiapan sejak awal. |
| 36 | **Tambahkan referensi pasal spesifik** PP No. 17 Tahun 2025 + tanggal berlaku | Agent C | Dokumen compliance perlu rujukan hukum yang bisa diverifikasi. |
| 37 | **Tambahkan battery/CPU usage concern** untuk client-side computation + optimasi incremental query | Agent D | Komputasi di client bisa membebani perangkat lama — perlu mitigasi. |
| 38 | **Perjelas zero-knowledge scope** — konten saja, bukan metadata sistem | Agent A | Klaim "zero-knowledge" sebelumnya terlalu luas; perlu nuance yang lebih aman secara legal. |

### Versi 9.0 — Revisi Berdasarkan Evaluasi Eksternal

| # | Perubahan | Sumber Evaluasi | Alasan |
|---|-----------|----------------|--------|
| 1 | **`consecutive_done` → `cumulative_done`** di algoritma Automaticity Decay | Agent D (🔴), Agent A | `consecutive_done` bertentangan dengan klaim "tidak harus berurutan" — reset ke 0 jika miss 1 hari = streak punishment. |
| 2 | **Definisikan `domain_deficit` secara matematis:** `10 - latest_domain_score` | Agent D (🔴) | Sebelumnya "Defisit Domain" tidak didefinisikan — ambigu. |
| 3 | **Selesaikan konflik: Priority Score saja** sebagai pengurut (hapus sort by `total_load_score`) | Agent D (🔴) | Sebelumnya formula dan langkah implementasi saling bertentangan. |
| 4 | **Hardcode nomor darurat** (119, 119 ext 8 SEJIWA) sebagai absolute fallback; Remote Config hanya untuk tambahan | Agent D (🔴) | Remote Config punya fetch latency 1–12 jam — jika fetch belum terjadi, nomor bisa outdated. |
| 5 | **Nyatakan eksplisit: semua komputasi client-side** | Agent D (🔴) | Fundamental untuk arsitektur zero-knowledge — tidak ada asumsi server-side computation. |
| 6 | **Domain MVP: hapus konflik Keuangan vs Tubuh** — Tubuh saja, hapus catatan "Domain MVP pertama" dari Keuangan | Agent A, Agent D | Sebelumnya tabel 6 domain menandai Keuangan sebagai "Domain MVP pertama" tapi paragraf bawah menetapkan Tubuh. |
| 7 | **Tambahkan field `frequency` + `scheduled_days`** ke tabel Habit + variasi trigger intervensi per frekuensi | Agent D (🟡) | Sebelumnya "3x Missed/7 hari" terlalu sensitif untuk habit yang memang 3x/minggu. |
| 8 | **Tambahkan missing constraints** di Data Model: `CHECK(entry_type IN ('Lite','Deep'))`, `UNIQUE(user_id, date, entry_type)` di JournalEntry, validasi circular reference di `stacked_to_habit_id`, validasi max 3 CoreValue di application layer | Agent D (🟡) | Constraint hilang bisa menyebabkan data inconsistent. |
| 9 | **Crisis Escalation protocol** untuk > 14 hari `mood_score ≤ 2` berturut-turut | Agent D (🟡) | Frequency cap 1x/7 hari terlalu pasif untuk krisis berkepanjangan. |
| 10 | **Tambahkan strategi akuisisi pengguna** (Community-Led Growth, Content Marketing, University Beta, Referral, Product Hunt) | Agent D (🟡) | KPI CAC:LTV ada tapi tidak ada strategi akuisisi. |
| 11 | **Student Tier Rp 19.000/bln** | Agent D | Segmen mahasiswa dan first-jobber punya elastisitas harga berbeda. |
| 12 | **Reframe WHO-5** sebagai "indikator monitoring", bukan klaim kausal | Agent D, Agent A | Tanpa control group, peningkatan WHO-5 tidak bisa diatribusikan kausal ke aplikasi. |
| 13 | **MVP scope reduction:** bagi jadi "MVP Lean" + "Iterasi 1" + "Iterasi 2" | Agent A (Prioritas 1), Agent D, Agent C | Scope sebelumnya terlalu lebar untuk 14–16 minggu. Timeline direvisi ke 16–20 minggu dengan iterasi. |
| 14 | **Softwarakan compliance wording:** "dilarang mutlak sesuai PP TUNAS" → "kebijakan internal sebagai precautionary principle" | Agent A | Klaim larangan absolut tidak ditemukan secara eksplisit di teks PP/COPPA. Lebih aman secara legal. |
| 15 | **BIP-39 seed phrase jadi opsional (advanced)** — default: OS Keychain | Agent A, Agent C | 12-word seed phrase di hari ke-3 terasa seperti crypto wallet, bukan wellness app. Friction terlalu tinggi untuk non-tech user. |
| 16 | **Recovery Contact: spesifikasikan Shamir Secret Sharing (2-of-2)** | Agent A | Sebelumnya "encrypted recovery fragment" tanpa model kriptografi — belum cukup spesifik untuk dibangun aman. |
| 17 | **Tambahkan `CrisisPromptLog` tabel** untuk audit trail | Agent A (data model kurang) | Diperlukan untuk memastikan frequency cap bekerja dan untuk compliance/audit. |
| 18 | **Tambahkan `security_level`** di UserProfile | — | Membedakan pengguna Standard (Keychain) vs Advanced (Seed Phrase). |
| 19 | **Tambahkan Self-Determination Theory** ke referensi akademis | Agent B | Memperkuat pilar Life Compass — motivasi intrinsik vs ekstrinsik. |
| 20 | **Calm Tech palet warna** di panduan aksesibilitas | Agent B | Warna yang menurunkan kortisol (hijau sage, biru redup, krem). |
| 21 | **Catatan SQLite vs PostgreSQL** — schema konseptual, ada mapping layer | Agent A | `JSONB` spesifik PostgreSQL, tapi lokal pakai SQLite — perlu penjelasan. |
| 22 | **Catatan `age_band` tidak cukup** untuk Fase 2 (perlu `date_of_birth`) | Agent A | Age Graduation butuh tanggal lahir eksak, bukan hanya age band. |
| 23 | **Framing parameter produk sebagai "hipotesis produk"** bukan klaim ilmiah | Agent A | Angka seperti 60 hari dan "turun 1 poin tiap 20 hari" adalah parameter produk, bukan fakta ilmiah. |
| 24 | **Cross-Border Data** compliance untuk Firebase/FCM | Agent A | UU PDP mengatur transfer data lintas negara — perlu penilaian kesetaraan. |
| 25 | **Radar MVP hanya tampilkan domain aktif** + Coming Soon | Agent D | Menghindari pengguna frustrasi melihat domain rendah tapi tidak bisa di-track. |
| 26 | **Tambahkan `domain_deficit` di LifeAudit** hanya untuk domain aktif di MVP | Agent D | Konsisten dengan MVP 1 domain. |

### Versi 8.0 — Revisi Komprehensif

*(Changelog v8.0 tetap tercatat di riwayat, namun item sudah tercakup oleh v9.0)*

---

> *LifeTree menjembatani kesejajaran antara aplikasi produktivitas yang menghukum, dengan aplikasi kesehatan mental yang terlalu klinis. Dengan berlandaskan sains perilaku dan kepatuhan hukum yang ketat, LifeTree berdiri sebagai paradigma baru dalam Ethical Technology Design.*

---

**© 2025 Fajar Kurnia — LifeTree Personal OS**
