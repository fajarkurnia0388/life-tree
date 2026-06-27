# Research Paper & Compliance Guideline: LifeTree Personal OS

**Abstrak**
Dokumen ini merupakan landasan empiris, psikologis, dan hukum dari pengembangan LifeTree. Berbeda dengan aplikasi produktivitas konvensional yang mengandalkan *loss aversion* (penghindaran kerugian) melalui sistem *streak*, LifeTree dirarsitekturi berbasis filosofi *Anti-Guilt* (Anti Rasa Bersalah). Makalah ini membedah integrasi *Habit Formation Theory*, *Canopy Load (Konstruk Produk)*, serta batas-batas hukum terkait privasi dan keselamatan pengguna di bawah payung yurisdiksi Indonesia (PP TUNAS + Permenkomdigi 9/2026) dan standar internasional (COPPA).

---

## Bagian 1: Landasan Ilmu Perilaku (Behavioral Science)

### 1.1 Dekonstruksi Mitos 21 Hari & Validasi 66 Hari
Industri pengembangan diri sering berpatokan pada mitos bahwa kebiasaan terbentuk dalam 21 hari. LifeTree menolak kerangka ini dan menggunakan temuan **Lally et al. (2010)** dari University College London (UCL).
- **Temuan Kunci:** Waktu median menuju otomatisasi perilaku adalah 66 hari, dengan rentang variasi yang sangat ekstrem (18 hingga 254 hari).
- **Landasan *Anti-Guilt*:** Studi yang sama membuktikan bahwa hilangnya kesempatan satu atau dua hari berturut-turut (*missed opportunity*) tidak merusak proses otomatisasi secara material. Oleh karena itu, arsitektur LifeTree mengizinkan *Recovery Mode* (Mode Istirahat) tanpa menghukum (*punish*) pengguna dengan me-reset visual pohon mereka.
- **Implikasi Teknis:** Ambang batas *Automaticity Decay* ditetapkan pada **60 hari kumulatif (recency-weighted)** — ini adalah **hipotesis produk** yang terinspirasi oleh literatur pembentukan kebiasaan (median 66 hari, dikurangi buffer 6 hari). Angka ini bukan klaim ilmiah baku, melainkan parameter produk yang akan divalidasi melalui pengujian iteratif dan A/B testing. Formula decay (`floor(cumulative_done / 20)`) adalah **model produk yang disederhanakan**, bukan representasi langsung dari penelitian Lally et al. — Lally hanya mengatakan median 66 hari dan rentang 18–254 hari, tanpa fungsi decay linear. Parameter akan dikalibrasi melalui A/B testing pada 500+ pengguna beta.

### 1.2 Canopy Load — Konstruk Produk (Bukan Klaim Ilmiah)
LifeTree menggunakan konsep *Canopy Load* yang **konstruk produk** — bukan backing ilmiah yang kuat. Otak manusia (terutama *Working Memory*) memiliki kapasitas terbatas.
- **Rasionalisasi:** Kegagalan dalam mempertahankan kebiasaan seringkali bukan masalah motivasi, melainkan *overload* (kelebihan beban).
- **Implementasi Produk:** Sistem mengkalibrasi beban kebiasaan melalui dua matriks: *Initiation Friction* (Kesulitan Memulai) dan *Energy Cost* (Biaya Tenaga). Beban ini otomatis turun seiring berjalannya waktu (*Automaticity Decay*) untuk membebaskan ruang memori kognitif. **Recency-weighted:** 90 hari terakhir bobot penuh, 91–180 hari bobot 0.5, >180 hari tidak dihitung — automaticity bukan "saldo permanen".

### 1.3 Model Intervensi Perilaku (Fogg Behavior Model)
Berdasarkan rumusan B=MAP (*Behavior = Motivation + Ability + Prompt*) dari Dr. BJ Fogg, LifeTree tidak menangani kegagalan dengan "Peringatan Hukuman".

| Hambatan | Diagnosis | Intervensi LifeTree |
|----------|-----------|-------------------|
| *Ability* bermasalah ("Kurang Waktu/Energi") | Daya tampung kognitif terlampaui | Turunkan durasi aksi → *Minimum Viable Action* (versi 2 menit) |
| *Prompt* bermasalah ("Lupa") | Kebiasaan belum menempel pada rutinitas | Sarankan *Routine Stacking* (Habit Loop: Cue–Routine–Reward, Duhigg 2012; Implementation Intention: Gollwitzer 1999) |
| *Motivation* bermasalah ("Tidak mau") | Domain hidup tidak sejalan dengan nilai | Arahkan ke *Life Compass* & *Decision Journal* — motivasi intrinsik via Self-Determination Theory |
| *Clarity* bermasalah ("Bingung harus mulai dari mana") | Pikiran belum terstruktur, terlalu banyak opsi, atau takut salah langkah | Arahkan ke **Thinking Canvas** — sesi paper-first untuk dump, klaster, skoring, PMI, dan aksi kecil |

### 1.4 Thinking Canvas — Rationale Kognitif dan Paper-First

Thinking Canvas diposisikan sebagai **mekanisme produk**, bukan klaim terapi atau intervensi klinis. Rasionalnya: sebagian pengguna tidak gagal karena malas, tetapi karena belum jelas memilih langkah berikutnya. Dengan memindahkan pikiran ke kertas/kanvas, pengguna melakukan *cognitive offloading* praktis: menulis, mengelompokkan, memilih, lalu menutup sesi dengan satu aksi kecil.

Thinking Canvas juga mengikuti prinsip **paper-first, app-summary-second**. Pengguna dianjurkan melakukan eksplorasi awal di buku/kertas asli karena menulis membantu proses elaborasi: pengguna tidak sekadar menyalin, tetapi memilih, menyusun, menghubungkan, dan menguji ide. Dalam diskursus pendidikan Indonesia, Prof. Stella Christie sering dikutip menekankan bahwa menulis berkaitan erat dengan berpikir; dokumen ini memakai gagasan tersebut sebagai inspirasi produk, bukan sebagai klaim klinis atau kutipan primer tanpa timestamp.

Riset tentang pencatatan dan handwriting juga mendukung arah desain ini dengan nuansa: mencatat dengan kata-kata sendiri dapat mendorong pemrosesan konseptual yang lebih dalam, dan beberapa studi EEG menunjukkan handwriting dapat melibatkan konektivitas otak yang lebih luas dibanding typing. Namun LifeTree **tidak** mengklaim bahwa menulis tangan selalu lebih baik daripada mengetik. Prinsip produknya: gunakan kertas untuk eksplorasi awal yang bebas; gunakan aplikasi untuk memilih metode, menyimpan ringkasan, dan menentukan aksi kecil.

Prinsip desain:
- **Paper-first:** sesi utama dianjurkan di buku/kertas asli, bukan layar.
- **Low pressure:** pengguna tidak diminta membuat rencana sempurna.
- **Small next action:** setiap sesi berakhir dengan satu aksi kecil atau asumsi yang perlu diuji.
- **Anti-Guilt:** ide yang tidak valid diperlakukan sebagai data, bukan kegagalan.
- **App-summary-second:** LifeTree menyimpan ringkasan, bukan menggantikan proses berpikir di kertas.

### 1.5 Referensi Akademis
- Lally, P., van Jaarsveld, C. H. M., Potts, H. W. W., & Wardle, J. (2010). *How are habits formed: Modelling habit formation in the real world.* European Journal of Social Psychology, 40(6), 998–1009.
- Sweller, J. (1988). *Cognitive load during problem solving: Effects on learning.* Cognitive Science, 12(2), 257–285.
- Fogg, B. J. (2009). *A behavior model for persuasive design.* Proceedings of the 4th International Conference on Persuasive Technology.
- World Health Organization. (1998). *WHO-5 Well-Being Index.* WHO Regional Office for Europe.
- Deci, E. L., & Ryan, R. M. (2000). *The "What" and "Why" of Goal Pursuits: Human Needs and the Self-Determination of Behavior.* Psychological Inquiry, 11(4), 227–268.
- Duhigg, C. (2012). *The Power of Habit: Why We Do What We Do in Life and Business.* Random House.
- Gollwitzer, P. M. (1999). *Implementation Intentions: Strong Effects of Simple Plans.* American Psychologist, 54(7), 493–503.
- Mueller, P. A., & Oppenheimer, D. M. (2014). *The Pen Is Mightier Than the Keyboard: Advantages of Longhand Over Laptop Note Taking.* Psychological Science.
- Van der Weel, F. R., & Van der Meer, A. L. H. (2024). *Handwriting but not typewriting leads to widespread brain connectivity: A high-density EEG study with implications for the classroom.* Frontiers in Psychology.

---

## Bagian 2: Kepatuhan Hukum & Etika Digital (Compliance)

### 2.1 Perlindungan Data Pribadi (UU PDP & PP 17/2025 - PP TUNAS + Permenkomdigi 9/2026)
Menurut UU PDP, data kesehatan, data anak, dan data keuangan pribadi termasuk Data Pribadi yang bersifat spesifik. Dalam konteks LifeTree, jurnal emosi, skor mood, sinyal krisis, dan data finansial pengguna diperlakukan dengan standar proteksi setara data sensitif karena dapat memuat atau menghasilkan inferensi terkait kesehatan mental/kehidupan pribadi. Seluruh bagian compliance membutuhkan formal legal counsel review sebelum launch.

#### Hak Atas Privasi Anak (Usia 13-17)
Sesuai **PP No. 17 Tahun 2025** tentang Penyelenggaraan Sistem Elektronik dalam Pelindungan Anak (ditetapkan 28 Maret 2025; implementasi bertahap mulai 28 Maret 2026 melalui Permenkomdigi 9/2026) dan **Permenkomdigi No. 9 Tahun 2026** sebagai aturan pelaksanaannya, remaja adalah anak di bawah 18 tahun. PP ini mengacu pada praktik *Age-Appropriate Design Code*. PP 17/2025 menetapkan kelompok usia anak 3–5, 6–9, 10–12, 13–15, dan 16–<18 tahun. Permenkomdigi 9/2026 menjadi aturan pelaksana yang mengatur tahapan implementasi, termasuk pembatasan/penonaktifan akun anak di bawah 16 tahun pada platform digital berisiko tinggi. LifeTree saat ini menggunakan pembagian sederhana (< 13, 13–17) untuk Fase 1; jika masuk Fase 2, compliance rule akan mengikuti granularitas ini.

*Parental Dashboard* **hanya** menampilkan tren agregat dan *Conversation Starters*, dan secara sistem **membatasi orang tua untuk membaca teks asli isi jurnal anak**.

#### Usia < 13 Tahun (COPPA & PP TUNAS)
Anak usia 3-12 tahun diwajibkan menggunakan mode *Offline-First* mutlak tanpa sinkronisasi *cloud*.

**Kebijakan Biometrik:** LifeTree secara kebijakan internal memilih **tidak menggunakan autentikasi biometrik (FaceID)** untuk akun anak sebagai tindakan perlindungan berlebih (*precautionary principle*). COPPA memperlakukan biometrik sebagai *personal information* yang menuntut consent/protection/retention controls — bukan larangan absolut.

**Catatan:** App-level biometric lock untuk pengguna dewasa (saat kembali dari background > 5 menit) berbeda dari larangan biometrik untuk akun anak — ini adalah keamanan akses, bukan autentikasi akun anak.

#### Age Graduation (Kelulusan Usia)
Tepat pada hari ulang tahun ke-18, sistem mencabut (*revoke*) akses orang tua dari akun secara otomatis. Membutuhkan `date_of_birth` atau `verified_age_token` (bukan hanya `age_band`). Diimplementasikan di Fase 2.

### 2.2 Passive Crisis Safety Protocol (Protokol Keselamatan)
LifeTree BUKAN *Medical Device* atau layanan terapi.

**Multi-Layer Medical Disclaimer:**
1. **Onboarding** (wajib scroll + checkbox): *"LifeTree adalah alat refleksi diri, BUKAN pengganti konseling profesional. Jika Anda mengalami krisis, hubungi 119."*
2. **Crisis Modal pertama** (sebelum muncul): *"Kami mendeteksi pola yang mungkin memerlukan perhatian. LifeTree tidak dapat mendiagnosis kondisi kesehatan mental."*
3. **Safety Card** (selalu terlihat): *"Darurat? Hubungi profesional."*

`crisis_disclaimer_acknowledged` di UserProfile mencatat pemahaman pengguna. Dicatat di ConsentLog `consent_type = 'Crisis_Disclaimer'`.

**Implementasi Kepatuhan:** Sistem menggunakan **Passive Safety Protocol**:
- **Safety Card (Always-On):** Tombol permanen. **Nomor primer di-hardcode** (119 PSC, 119 ext 8 SEJIWA).
- **`Called_Hotline` → `Tapped_Hotline_CTA`:** Tracking berhenti di interaksi UI — apakah panggilan berhasil tidak bisa diketahui aplikasi.
- **Anti-Banner-Blindness:** Visual berrotasi periodik.
- **Out-of-App Wellness Check:** > 5 hari tidak buka → 1 push empatik (maks. 1x/14 hari, tracked via `last_wellness_push_at`). Deep-link ke Home / Journal Lite. Safety Card tetap always-on, tetapi inactivity saja tidak dianggap distress.
- **Crisis Escalation (> 14 hari):** Modal eskalasi langsung ke hotline, maks. 1x/14 hari.

### 2.3 Hak Atas Data & Enkripsi (*Right to Erasure*)
- **E2EE:** Semua data cloud dienkripsi. Server hanya menyimpan *Encrypted Ciphertext BLOB*.
- **Zero-Knowledge untuk Konten:** Server tidak memiliki kunci dekripsi konten. Metadata sistem (device token, last sync, subscription, timestamps) tetap terlihat.
- **Client-Side Computation:** Seluruh logika komputasi berjalan di perangkat pengguna. Optimasi: incremental query 90 hari terakhir, background computation, lifetime_done_count counter + weighted_done_score materialized value.
- **Multi-Device Bootstrap:** (A) QR code transfer jika perangkat lama ada, (B) Recovery Contact / seed phrase jika hilang, (C) OS Keychain auto-sync sebagai default.
- **Autentikasi Akun:** Email + password hash (bcrypt) — terpisah dari enkripsi konten.
- **Key Rotation:** Re-encryption bertahap di client-side. Key version di metadata.
- **Sync Conflict Resolution:** Berlapis — HabitLog: LWW aman (append-only). JournalEntry/mutable: Conflict Copy jika timestamp < 5 menit, pengguna memilih. Habit metadata: LWW + warning.
- **Recovery Contact:** **Shamir 2-of-3** — tiga fragment, dua diperlukan: (1) OS Keychain, (2) Recovery Contact, (3) Secondary backup. Toleransi kehilangan 1 fragment.
- **Soft Delete (Tombstone):** `deleted_at` di setiap tabel — sinkronisasi penghapusan antar perangkat.
- **CrisisPromptLog: Local-Only** — tidak di-sync ke cloud, retention 90 hari, tidak diekspor JSON/CSV.
- **App-Level Biometric Lock:** Autentikasi saat kembali dari background > 5 menit.
- **Ekspor Lokal (JSON/CSV):** Pencadangan mandiri di tier gratis.
- **Right to Erasure:** Data lokal: factory wipe terenkripsi. Data cloud: secure deletion dengan konfirmasi ganda.
- **Cross-Border Data:** Penilaian kesetaraan perlindungan data sesuai UU PDP. Dokumentasi: data flow map, vendor register, lawful basis, retention schedule, DSAR workflow, breach response plan.

---

## Kesimpulan Akademis
LifeTree menjembatani kesejajaran antara aplikasi produktivitas yang menghukum, dengan aplikasi kesehatan mental yang terlalu klinis. Dengan berlandaskan sains perilaku dan kepatuhan hukum yang ketat (terutama pelindungan anak), LifeTree berdiri sebagai paradigma baru dalam *Ethical Technology Design* (Desain Teknologi Beretika).
