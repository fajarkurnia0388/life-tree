# 九炼归道 — Dao Tree Cultivation System

> **Daoji: Personal Cultivation OS**
> Sintesis final dari 4 dokumen referensi migrasi
> **Status:** FINAL | **Tanggal:** 2 Juli 2026

---

## Daftar Isi

1. [Identitas & Spirit Produk](#1-identitas--spirit-produk)
2. [7 Hukum Agung](#2-7-hukum-agung)
3. [4 Lapisan Orthogonal](#3-4-lapisan-orthogonal)
4. [Sumbu A — 8 Realm](#4-sumbu-a--8-realm)
5. [Sumbu B — 5 State/Season](#5-sumbu-b--5-stateseason)
6. [Sumbu C — 6 Palace](#6-sumbu-c--6-palace)
7. [Sumbu D — 6 Path](#7-sumbu-d--6-path)
8. [Sistem Energi: Qi & Canopy Load](#8-sistem-energi-qi--canopy-load)
9. [Heart Demon & Demonic Cultivation](#9-heart-demon--demonic-cultivation)
10. [Tribulation & Friction](#10-tribulation--friction)
11. [Dao Heart (Life Compass)](#11-dao-heart-life-compass)
12. [3-Level Language System](#12-3-level-language-system)
13. [Mapping Fitur → Cultivation](#13-mapping-fitur--cultivation)
14. [Adaptasi per Layar](#14-adaptasi-per-layar)
15. [Implementasi Teknis](#15-implementasi-teknis)
16. [Roadmap 4 Fase](#16-roadmap-4-fase)
17. [Testing & Metrik](#17-testing--metrik)
18. [Batasan & Anti-Pola](#18-batasan--anti-pola)
19. [Glossary](#19-glossary)

---

## 1. Identitas & Spirit Produk

### Nama Sistem

# **九炼归道 — Jalan Sembilan Penyulingan Menuju Dao**

_Jiǔ Liàn Guī Dào_

| Karakter | Makna |
|----------|-------|
| **九** (Jiǔ) | Sembilan — jumlah penyulingan, bukan jumlah realm |
| **炼** (Liàn) | Menempa, memurnikan, menyuling |
| **归** (Guī) | Kembali — bukan naik level, tapi kembali ke hakikat diri |
| **道** (Dào) | Jalan, hukum terdalam realita |

### Nama Produk

> **Daoji: Dao Cultivation OS**

### Metafora Sentral

> **Dao Tree / Inner World Tree**

| Bagian Pohon | Makna Kultivasi | Fitur Produk |
|-------------|-----------------|--------------|
| **Akar** | Dao Heart, nilai inti | Life Compass, Value Mirror |
| **Batang** | Fondasi hidup | Ritme, habits, canopy load |
| **Cabang** | Domain kehidupan | 6 Palace |
| **Daun** | Practice harian | Habit / Action of the Day |
| **Bunga** | Stabil habit | Automaticity / pattern |
| **Buah** | Kebijaksanaan | Decision Journal, insights |
| **Musim** | Fase energi | Season / State |

### Spirit Produk

- **Anti-Guilt** — tidak ada hukuman, streak punishment, atau regresi visual
- **Offline-first** — semua data lokal, privasi terjaga
- **Calm Tech** — tenang, membumi, tidak mendesak
- **Growth tanpa hukuman** — pertumbuhan diukur dari kedalaman, bukan kecepatan
- **Recovery tanpa malu** — pemulihan adalah bagian sah kultivasi

### Definisi Keabadian

Dalam Daoji, keabadian bukan hidup selamanya. Melainkan:

> **Karakter yang tidak mudah hancur oleh perubahan kecil.**
> **Kejernihan yang bertahan di bawah tekanan.**
> **Kontribusi yang melampaui impuls sesaat.**

**Immortality in Daoji = Resilient Alignment.**

### Posisi Sistem

Sistem ini **bukan tangga level kompetitif**. Ia adalah **peta perkembangan diri multi-sumbu** — kerangka interpretasi dan motivasi di atas arsitektur produk yang sudah ada.

---

## 2. 7 Hukum Agung

Semua desain fitur **harus tunduk** pada 7 hukum ini. Tidak ada pengecualian.

### 2.1 Hukum Wadah

**Semua kekuatan membutuhkan wadah.**

Jika tubuh, tidur, ritme rapuh → perhatian bocor, emosi liar, kultivasi runtuh.

- Domain Tubuh selalu fundamental
- Recovery bukan kelemahan
- Overload harus dicegah (Canopy Load)

### 2.2 Hukum Perhatian

**Qi dalam dunia nyata adalah perhatian yang terarah.**

- Practice kecil tetap sah
- Kebocoran energi harus dipetakan
- Distraksi = gangguan aliran qi

### 2.3 Hukum Fondasi

**Kemajuan tanpa fondasi akan retak saat diuji.**

- Tidak ada streak punishment
- Konsistensi tenang > performa heroik sesaat

### 2.4 Hukum Kristalisasi

**Energi menjadi kekuatan hanya saat dikristalkan menjadi prinsip.**

- Life Compass / Dao Heart sangat sentral
- User harus dibantu menemukan nilai inti

### 2.5 Hukum Tribulasi

**Setiap terobosan sejati mengundang tribulasi.**

- Friction = data penting, bukan error
- Bottleneck inquiry = fitur inti
- Recovery, missed habit, low mood = sinyal jalan

### 2.6 Hukum Integrasi

**Pertumbuhan sejati = menyatukan bagian diri yang terpecah.**

- Journaling, reflection, value mirror, weekly pulse = pusat kultivasi
- Bukan fitur tambahan

### 2.7 Hukum Keselarasan

**Puncak kultivasi bukan dominasi, tapi keselarasan dengan realita.**

Yang tertinggi bukan yang paling sibuk — melainkan yang paling jernih, utuh, dan sanggup menata kehidupan.

---

## 3. 4 Lapisan Orthogonal

### Struktur (Bukan Tangga Linear)

```
╔══════════════════════════════════════════════════════════╗
║              九炼归道 — DAOJI CULTIVATION SYSTEM          ║
╚══════════════════════════════════════════════════════════╝

                   ┌─────────────────────────┐
                   │      SEASON / STATE      │  ← kondisi saat ini
                   │  Growth | Recovery       │     (berubah kapan saja)
                   │  Dormant | Tribulation   │
                   │  Quiet Integration       │
                   └────────────┬────────────┘
                                │
┌─────────────────┐            │            ┌─────────────────┐
│     PALACES     │◄───────────┴───────────►│      PATHS      │
│  6 Domain Hidup │    saling mempengaruhi   │ Gaya Bertumbuh  │
│                 │                          │                 │
│ Body Palace     │                          │ Sword Path      │
│ Resource Palace │                          │ Alchemist Path  │
│ Bond Palace     │                          │ Formation Path  │
│ Heart Sea       │                          │ Body Path       │
│ Craft Palace    │                          │ Word Path       │
│ Joy Garden      │                          │ Shadow Path     │
└─────────────────┘                          └─────────────────┘
        │                                            │
        └──────────────────┬─────────────────────────┘
                           │
                   ┌───────┴────────┐
                   │     REALM      │  ← perkembangan jangka panjang
                   │   1 — 8        │     (interpretatif)
                   └────────────────┘
```

### Kenapa Orthogonal?

| Sistem Linear (Lama) | Sistem Orthogonal (Final) |
|----------------------|---------------------------|
| "Aku di Ranah 3" | "Realm Foundation, state Growth, Body Palace tinggi, Heart Sea rendah, dominan Formation Path" |
| Progresi kaku, 1 dimensi | Potret multidimensi, kaya |
| Judgment: "masih rendah" | Pemahaman: "ini polaku" |
| Game-like ladder | Reflective portrait |
| Membosankan setelah puncak | Selalu ada dimensi baru |

### Contoh Pembacaan

> **User A**: Realm Foundation, state Recovery, Heart Sea tinggi, Craft Palace rendah, Path Alchemist
> → Rekomendasi: practice ringan di Craft, jangan push — kamu sedang recovery

> **User B**: Realm Core Formation, state Growth, Body Palace rendah, Path Sword
> → "Fondasi timpang — Body Palace perlu perhatian sebelum lanjut"

> **User C**: Realm Nascent Soul, state Tribulation, Bond Palace drop, Path Shadow
> → Safety Card + Bottleneck Inquiry "Sepertinya ada konflik hubungan yang menguras"

---

## 4. Sumbu A — 8 Realm

### Prinsip Realm

- **Interpretatif** — diukur dari kombinasi sinyal, bukan jumlah hari mutlak
- **Tidak naik otomatis** — indikator membantu refleksi, bukan auto-promote
- **Tidak ada sub-realm** — state menangani variasi kondisi harian
- **Tidak ada judgment** — alat bantu refleksi, bukan peringkat status

### Indikator Realm (Multi-Sinyal)

| Sinyal | Sumber Data | Bobot |
|--------|-------------|-------|
| Cumulative days | `countUniqueDoneDates` | 40% |
| Consistency | `completionRate90d` | 25% |
| Domain balance | `latestDomainScores` | — |
| Reflection depth | `JournalEntries`, `ThinkingCanvasSessions` | 20% |
| Values clarity | `ValueDilemmaResponses`, `coreValues` | 15% |
| Recovery literacy | `WellnessPromptLogs`, `recoveryEndDate` | — |
| Decision maturity | `DecisionEntries` | — |

### Tiga Lingkaran Pertumbuhan

```
Lingkaran I — Menata Wadah
  R1 Body Tempering    → "Tubuhku bejana"
  R2 Qi Gathering      → "Qi-ku terkumpul"
  R3 Foundation Est.   → "Hidupku berstruktur"

Lingkaran II — Membentuk Inti Diri
  R4 Core Formation    → "Nilai intiku lahir"
  R5 Nascent Soul      → "Aku bisa melihat diriku"
  R6 Spirit Transform. → "Kualitas diriku berubah"

Lingkaran III — Menyatu dengan Jalan
  R7 Dao Comprehension → "Aku melihat pola"
  R8 World Bearing     → "Aku menyangga kehidupan"
```

### Detail 8 Realm

#### R1: Body Tempering (炼体) — Penempaan Raga

| Aspek | Deskripsi |
|-------|-----------|
| **Hakikat** | Tubuh berhenti menjadi beban dan mulai menjadi bejana |
| **Fokus** | Tidur, nutrisi, gerak, napas, ritme sirkadian |
| **Indikator** | Tidur lebih konsisten, energi dasar tidak ambruk |
| **Bahaya** | Begadang kronis, tubuh dikorbankan demi produktivitas |
| **Padanan Fitur** | Domain Tubuh, habit body care, Recovery Mode, Canopy Load |
| **Mindset** | _"Tubuhku adalah bejana pertama perjalananku."_ |

#### R2: Qi Gathering (聚气) — Pengumpulan Qi

| Aspek | Deskripsi |
|-------|-----------|
| **Hakikat** | Qi = perhatian + kemauan + kapasitas hadir |
| **Fokus** | Fokus, pengelolaan distraksi, satu aksi kecil yang dituntaskan |
| **Indikator** | Bisa fokus sebentar, bisa menjalankan practice kecil dengan sadar |
| **Bahaya** | Doomscrolling, multitasking kompulsif |
| **Padanan Fitur** | Action of the Day, micro practice, Journal Lite, Friction Intervention |
| **Mindset** | _"Masalahku bukan kurang niat — qi-ku tercerai-berai."_ |

#### R3: Foundation Establishment (筑基) — Pendirian Fondasi

| Aspek | Deskripsi |
|-------|-----------|
| **Hakikat** | Energi yang tadinya liar kini punya struktur |
| **Fokus** | Kebiasaan stabil, jadwal tidak kacau, sistem hidup yang bisa diandalkan |
| **Indikator** | Habit kecil mulai otomatis, bisa kembali ke jalur setelah tergelincir |
| **Bahaya** | Terlalu banyak target, menambah habit tanpa daya tampung |
| **Padanan Fitur** | Canopy Load, habit scheduling, Growth Map, anti-overload |
| **Mindset** | _"Perubahan tidak lagi bergantung pada semangat sesaat."_ |

#### R4: Core Formation (结丹) — Pembentukan Inti

| Aspek | Deskripsi |
|-------|-----------|
| **Hakikat** | Segala latihan mulai mengkristal menjadi prinsip hidup. Dao Heart lahir. |
| **Fokus** | Nilai inti, prioritas hidup, batas sehat, keputusan selaras dengan diri |
| **Indikator** | Mampu jawab "apa yang penting buatku?", keputusan lebih konsisten |
| **Bahaya** | Pencitraan sebagai pengganti identitas, ambisi pinjaman, FOMO |
| **Padanan Fitur** | Life Compass, Core Values, Value Mirror |
| **Mindset** | _"Aku tidak lagi hidup dari validasi eksternal."_ |

#### R5: Nascent Soul (元婴) — Kelahiran Jiwa Pengamat

| Aspek | Deskripsi |
|-------|-----------|
| **Hakikat** | Lahir kesadaran yang dapat menyaksikan diri sendiri |
| **Fokus** | Metakognisi, kesadaran emosi, jeda sebelum reaksi |
| **Indikator** | Bisa berkata "aku sadar aku sedang terpicu", tidak semua emosi jadi tindakan |
| **Bahaya** | Intelektualisasi berlebihan, merasa sadar hanya karena bisa menjelaskan |
| **Padanan Fitur** | Journal Lite / Deep Reflection, Thinking Canvas |
| **Mindset** | _"Diri tidak lagi sepenuhnya tenggelam di dalam pikirannya."_ |

#### R6: Spirit Transformation (化神) — Transformasi Spirit

| Aspek | Deskripsi |
|-------|-----------|
| **Hakikat** | Setelah melewati tribulasi, diri berubah kualitasnya |
| **Fokus** | Integrasi luka, respons lebih matang, ketenangan tanpa mati rasa |
| **Indikator** | Lebih sedikit reaktivitas, kejernihan dalam konflik |
| **Bahaya** | Superioritas spiritual, identitas "aku sudah sembuh" |
| **Padanan Fitur** | Long-form reflection, decision review |
| **Mindset** | _"Luka tidak hilang, tapi tidak lagi menjadi pusat identitas."_ |

#### R7: Dao Comprehension (悟道) — Pemahaman Dao

| Aspek | Deskripsi |
|-------|-----------|
| **Hakikat** | Mulai memahami hukum-hukum realita, bukan hanya menjalani teknik |
| **Fokus** | Sebab-akibat, ritme, leverage, hubungan tindakan kecil dan arah hidup |
| **Indikator** | Keputusan lebih presisi, tidak mudah panik, wisdom dari pengalaman |
| **Bahaya** | Kebijaksanaan palsu, teori tanpa embodiment |
| **Padanan Fitur** | Weekly Pulse synthesis, Decision Journal review, Value Mirror |
| **Mindset** | _"Aku tidak lagi sekadar berusaha keras — aku mulai melihat pola."_ |

#### R8: World Bearing (合道载世) — Menyangga Dunia

| Aspek | Deskripsi |
|-------|-----------|
| **Hakikat** | Puncak kultivasi bukan predator puncak, tapi penyangga keteraturan |
| **Fokus** | Kontribusi, bimbingan, sistem yang menopang orang lain |
| **Indikator** | Struktur hidup membantu orang lain tumbuh |
| **Bahaya** | Mesianic ego, merasa harus jadi guru untuk semua orang |
| **Padanan Fitur** | Marketplace contribution, mentoring/sharing loops |
| **Mindset** | _"Hidup tidak lagi berputar di sekitar 'aku'."_ |

---

## 5. Sumbu B — 5 State/Season

### Prinsip Fundamental

**State BUKAN Realm.** Mereka terpisah.

- Realm = perkembangan jangka panjang (berubah lambat)
- State = kondisi saat ini (bisa berubah kapan saja)

### Daftar State

| State | Visual Pohon | Makna | Intervensi Sistem |
|-------|-------------|-------|-------------------|
| **Growth** 🌱 | Normal, kanopi penuh | Mode aktif, practice berjalan | Action of the Day, Habits aktif |
| **Recovery** ❄️ | Snow-covered, lembut | Pemulihan energi | Notif pause, journal only, Safety Card |
| **Dormant** 🍂 | Daun redup, tenang | Istirahat panjang | Weekly check-in ringan (max 1x/14 hari) |
| **Tribulation** ⚡ | Aura biru redup, getaran halus | Ujian/krisis aktif | Safety Card + Friction + Bottleneck Inquiry |
| **Quiet Integration** 🌙 | Night mode, bintang | Pemrosesan diam-diam | Deep Reflection prompt, Decision Journal |

### Triggers State

| State | Trigger |
|-------|---------|
| **Growth** | Default — tidak ada sinyal negatif |
| **Recovery** | User memilih Recovery Mode ATAU mood ≤3 selama 3 hari ATAU burnout flag |
| **Dormant** | Tidak buka app > 7 hari |
| **Tribulation** | Friction threshold terlewati ATAU user menandai "krisis" ATAU Value Dilemma unresolved |
| **Quiet Integration** | Setelah Recovery selesai — masa transisi 3-7 hari |

### Aturan State

- ✅ Boleh berganti state kapan saja
- ✅ Recovery bukan "turun level"
- ✅ Tribulation adalah sinyal, bukan hukuman
- ❌ Tidak ada visual kematian pohon
- ❌ Tidak ada "state buruk" — semua adalah fase

---

## 6. Sumbu C — 6 Palace

6 Palace adalah peta domain kehidupan — menjadi **6 cabang pohon**.

| Palace | Domain Daoji | Elemen | Warna | Practice Utama |
|--------|----------------|--------|-------|----------------|
| **Body Palace** 🏃 | Tubuh | Tanah (土) | Hijau Sage | Tidur, olahraga, napas, hidrasi |
| **Resource Palace** 💰 | Keuangan | Logam (金) | Emas | Catat pengeluaran, budget, dana darurat |
| **Bond Palace** 🤝 | Hubungan | Api (火) | Pink | Koneksi, quality time, perbaikan konflik |
| **Heart Sea** 💭 | Emosi | Air (水) | Biru | Journaling, meditasi, grounding |
| **Craft Palace** 📚 | Karir | Kayu (木) | Nila/Ungu | Skill, deep work, review pembelajaran |
| **Joy Garden** 🎮 | Rekreasi | Angin (风) | Amber | Hobi, seni, bermain, istirahat sadar |

### Prinsip Palace

1. **Semua palace sama penting** — Joy Garden bukan "kurang serius"
2. **Palace bisa tidak seimbang** — itu normal, bukan kegagalan
3. **Palace saling mempengaruhi** — Body rendah → Heart Sea terpengaruh
4. **Tidak ada palace yang boleh diabaikan selamanya**

### Hubungan Antar Palace (Meridian)

```
Body Palace ──── Heart Sea       (tubuh sehat → emosi stabil)
Resource Palace ── Craft Palace  (finansial stabil → fokus karir)
Bond Palace ──── Joy Garden      (hubungan baik → kebahagiaan)
Heart Sea ──── Semua Palace      (pusat keseimbangan)
```

### Mapping Domain Key → Palace

| Domain Key (kode) | Palace Name |
|-------------------|-------------|
| `Tubuh` | Body Palace |
| `Keuangan` | Resource Palace |
| `Hubungan` | Bond Palace |
| `Emosi` | Heart Sea |
| `Karir` | Craft Palace |
| `Rekreasi` | Joy Garden |

---

## 7. Sumbu D — 6 Path

Paths adalah personalisasi — bagaimana seseorang cenderung bertumbuh. Bukan kasta, tapi kecenderungan energi.

| Path | Inti | Kekuatan | Risiko Bayangan | Praktik Khas |
|------|------|----------|-----------------|-------------|
| **Sword Path** ⚔️ | Kejelasan, pemotongan ilusi | Fokus tajam, tegas | Kaku, dingin relasional | Decision Journal |
| **Alchemist Path** 🧪 | Penyulingan, transformasi halus | Sabar, integratif | Sulit tegas | Deep Reflection, Value Mirror |
| **Formation Path** 🏛️ | Sistem, struktur, desain kehidupan | Teratur, stabil | Over-control | Habit scheduling, Canopy Load |
| **Body Path** 💪 | Ketahanan, eksekusi, disiplin fisik | Action-oriented | Mengabaikan emosi | Action of the Day, micro practice |
| **Word Path** 📖 | Makna, bahasa, cerita | Komunikatif | Retorika tanpa aksi | Journaling, Thinking Canvas |
| **Shadow Path** 🌑 | Masuk ke area sulit: trauma, chaos | Transformasi mendalam | Terjebak kegelapan | Friction Journal, Bottleneck Inquiry |

### Catatan Path

- Semua orang bisa mengembangkan semua path
- Biasanya dominan di 1-2 path
- Path bisa dideteksi dari pola penggunaan fitur
- Path tidak perlu muncul sebagai label besar di awal — bisa muncul sebagai rekomendasi personalisasi

---

## 8. Sistem Energi: Qi & Canopy Load

### Konsep Qi

| Jenis Qi | Definisi Daoji | Representasi Data |
|----------|-------------------|-------------------|
| **先天 Qi (Xiantian)** | Energi bawaan — kapasitas dasar harian | `canopyLoadCapacity` (default: 10) |
| **后天 Qi (Houtian)** | Energi yang diperoleh — habit yang sudah otomatis | `automaticityDecay` |
| **Qi Kotor** | Beban mental — distraksi, stres | `frictionReasonSelected = Kelelahan` |
| **Qi Murni** | Fokus, energi positif | Mood score tinggi, journaling teratur |

### Formula Qi Harian (Canopy Load)

```
canopyLoad = Σ(habit.initiationFriction + habit.energyCost)
             untuk semua habit dengan status == 'Active' && deletedAt == null

canopyCapacity = UserProfile.canopyLoadCapacity  // int, default = 10
loadRatio = canopyLoad / canopyCapacity
```

Jika `loadRatio > 1.0` → **OVERLOAD** → peringatan ramah.

### Dantian — Dashboard sebagai Pusat Energi

| Dantian Xianxia | Daoji | Fungsi |
|-----------------|----------|--------|
| **Dantian Bawah** | Home Dashboard | Energi fisik, habit harian, rutinitas |
| **Dantian Tengah** | Life Audit / Palaces | Energi emosional, domain, keseimbangan |
| **Dantian Atas** | Life Compass / Dao Heart | Energi spiritual, nilai, visi |

---

## 9. Heart Demon & Demonic Cultivation

### Heart Demon (心魔)

Hambatan psikologis yang menghalangi pertumbuhan sejati.

| Heart Demon | Manifestasi | Deteksi Sistem | Intervensi |
|-------------|-------------|----------------|------------|
| **Perfection Demon** | "Harus sempurna" → berhenti total setelah 1 missed | Friction: missed + mood drop | "Pohonmu sedang beristirahat" |
| **Comparison Demon** | "Orang lain lebih baik" → demotivasi | Sering cek Marketplace, jarang praktik | Tidak ada leaderboard |
| **Impatience Demon** | "Kenapa belum berubah?" → frustrasi | Frequent habit change, banyak arsip | Growth Map kumulatif |
| **Denial Demon** | "Aku tidak butuh ini" → resistensi | Skip onboarding, jarang journal | Onboarding bertahap |
| **Attachment Demon** | "Tidak bisa lepas" → over-attachment | Habit overdue, tidak pernah diarsip | "Arsipkan dengan damai" |

### Heart Demon Severing (Pemotongan Iblis Hati)

1. **Identifikasi** — satu keterikatan/ketakutan yang menahan
2. **Tulis** — di Deep Reflection Journal
3. **Lepas** — "Arsipkan practice ini?" dengan bahasa positif
4. **Visual** — daun perlahan memudar (tidak mati — dorman)
5. **21 hari** — jika tidak diaktifkan kembali, daun terlepas dengan damai

### Demonic Cultivation

**Usaha mendapatkan hasil besar tanpa penyulingan diri yang setara.**

| Bentuk | Contoh | Deteksi Sistem |
|--------|--------|----------------|
| Hustle tanpa fondasi | Begadang kerja, skip tidur | Body Palace rendah × Craft tinggi |
| Stimulasi tanpa istirahat | Doomscrolling, binge-watching | Joy Garden kompulsif × Heart Sea rendah |
| Performa tanpa makna | Mengejar target orang lain | Core Values kosong × Craft tinggi |
| Produktivitas sebagai pelarian | Sibuk terus agar tidak merasa | Friction "Kelelahan" berulang × tetap push |

**Bukan judgment.** Demonic Cultivation di Daoji untuk:

> _"Hei, pola ini mungkin perlu diperiksa. Mau lihat?"_

---

## 10. Tribulation & Friction

### Prinsip

**Tribulation bukan hukuman, tapi penguji kepalsuan.**

### Micro Tribulation

| Pemicu | Respon Sistem |
|--------|---------------|
| 3x missed dalam 7 hari | Friction Intervention pop-up |
| Mood ≤ 2 selama 3 hari | Safety Card + tawaran Recovery |
| Overload canopy | Peringatan ramah + tawaran versi ringan |
| Conflict: nilai × tindakan | Value Mirror prompt |

### Major Tribulation (三灾)

| Bencana | Padanan Daoji | Respon |
|---------|-----------------|--------|
| **雷劫 (Petir)** | Burnout — energi habis tiba-tiba | Recovery Mode, semua di-pause |
| **火劫 (Api)** | Konflik hubungan | Friction Journal + Bond Palace check |
| **风劫 (Angin)** | Kehilangan arah — hampa | Life Compass + Dao Heart review |

### Siklus Tribulasi

```
Normal → Friction muncul → Sadar hambatan → Pilih respon →
→ Recovery/Refleksi → Integrasi → Level baru pemahaman
```

---

## 11. Dao Heart (Life Compass)

Dao Heart adalah pusat nilai, integritas, dan arah.

### Declared Dao

Nilai yang dipilih sadar oleh pengguna (Life Compass).

### Revealed Dao

Nilai yang muncul dari pilihan nyata, dilema, dan pola keputusan (Value Mirror).

### Tujuan

Bukan membuat keduanya identik sempurna, tetapi membantu pengguna melihat:

- di mana ada keselarasan,
- di mana ada kontradiksi,
- dan apa yang ingin ia ubah dengan sadar.

---

## 12. 3-Level Language System

### Tiga Tingkat

| Level | Target | Default? |
|-------|--------|----------|
| **Plain** | User umum — bahasa sehari-hari | Tidak |
| **Hybrid** | Perpaduan natural — istilah cultivation ringan | **Ya (default)** |
| **Full Cultivation** | Penggemar Xianxia — immersion penuh | Tidak |

### Contoh Lengkap per Komponen

#### Dashboard

| Konteks | Plain | Hybrid (Default) | Full |
|---------|-------|-------------------|------|
| Title | 🌳 Pohonmu | ☯️ Dao Tree | ☯️ Inner World Tree |
| Hari | Hari ke-45 | Realm Foundation — Hari 45 | 九炼·筑基 — Hari 45 |
| State: Recovery | Mode Istirahat | Seclusion Aktif | Closed-Door Seclusion |

#### Action of the Day

| Konteks | Plain | Hybrid | Full |
|---------|-------|--------|------|
| Label | 📋 Prioritas Hari Ini | ⚔️ Breakthrough Hari Ini | 🧘 One Practice |
| Subtitle | Domain terlemah | Palace butuh Qi | Meridian redup |
| Selesai | ✅ Selesai! | ✅ Practice selesai, +Qi | ✅ Teknik dikuasai |

#### Friction Intervention

| Konteks | Plain | Hybrid | Full |
|---------|-------|--------|------|
| Pop-up | "Hambatan apa?" | "Bottleneck apa?" | "Heart Demon macam apa?" |
| Opsi 1 | Kurang Waktu | Qi belum terkumpul | Qi-mu bocor |
| Opsi 2 | Kelelahan | Energi habis | Shen-mu lelah |
| Opsi 3 | Lupa | Fokus buyar | Pikiranmu tercerai |

#### Growth Map

| Konteks | Plain | Hybrid | Full |
|---------|-------|--------|------|
| Root | Akar Diri | Dao Heart | Dao Heart (道心) |
| Branch | Domain | Palace | Palace (殿) |
| Leaf | Kebiasaan | Practice | Cultivation Technique |
| Flower | Stabil | Pattern Mengakar | Automaticity (自动化) |
| Fruit | Keputusan | Wisdom Fruit | Dao Fruit (道果) |

#### Journal

| Konteks | Plain | Hybrid | Full |
|---------|-------|--------|------|
| Title | 📝 Catatan Harian | 📝 Qi Log | 📜 Heart Scripture (心记) |
| Lite | Cepat | Journal Ringan | Meditasi Cepat |
| Deep | Refleksi | Deep Reflection | Pemurnian Shen (炼神) |

#### Settings

| Konteks | Plain | Hybrid | Full |
|---------|-------|--------|------|
| Language | Bahasa | Gaya Bahasa | Language Level |
| Option | Sehari-hari | Paduan Tenang | Nuansa Kultivasi |
| Dark Mode | Gelap | Mode Malam | Mode Meditasi |

### Aturan Pemakaian

- Onboarding awal: plain/hybrid ringan
- Dashboard utama: hybrid
- Optional theme toggle: full cultivation
- Safety/legal/critical UX: **selalu plain** atau dual label

---

## 13. Mapping Fitur → Cultivation

| Fitur Daoji | Nama Cultivation (Hybrid) | Sumbu | Catatan |
|----------------|--------------------------|-------|---------|
| Tree Vitality | Dao Tree | Realm + State | Pusat visual |
| Canopy Load | Daily Qi Capacity | State | Kapasitas harian |
| Action of the Day | Breakthrough Hari Ini | Palace + State | Practice prioritas |
| Habit | Practice | Palace + Path | Teknik kultivasi |
| Habit Logs | Practice Record | Realm | Catatan latihan |
| Friction Intervention | Bottleneck Inquiry | Tribulation/State | Hambatan = data |
| Journal Lite | Qi Log | State + Heart Sea | Sangat cocok |
| Deep Reflection | Inner Chamber Reflection | Realm | Optional hybrid/full |
| Weekly Pulse | Meridian Check / Resonance Check | Palace + Realm | Cek keseimbangan |
| Life Compass | Dao Heart | Realm | Pusat nilai inti |
| Value Mirror | Dao Heart Mirror | Realm + Tribulation | Declared vs lived |
| Decision Journal | Forked Path Journal | Realm | Keputusan besar |
| Marketplace | Sutra Pavilion / Heritage Archive | Path + World Bearing | Kosmetik/branding |
| Recovery Mode | Seclusion Mode | State | Wajib dimuliakan |
| Safety Card | Safety Card / Talisman Keselamatan | State | Dual label |
| Radar Chart | Six Palace Resonance | Palace | Tetap fungsional |

### Mapping Database → Cultivation

| Tabel Daoji | Konsep Cultivation | Fungsi |
|----------------|-------------------|--------|
| `UserProfiles` | Spirit Root / Jati Diri | Identitas kultivator, Dao Heart |
| `Habits` | Teknik Kultivasi (Practice) | Metode latihan harian |
| `HabitLogs` | Catatan Latihan | Bukti pelaksanaan |
| `LifeAudits` | Inspeksi Diri (Neiguan) | Evaluasi 6 Palace |
| `WeeklyPulses` | Resonance Check | Refleksi periodik |
| `JournalEntries` | Heart Scripture | Pemurnian Shen |
| `ThinkingCanvasSessions` | Sesi Pemahaman (Wudao) | Metode berpikir |
| `DecisionEntries` | Persimpangan Jalan | Momen penentu arah Dao |
| `ValueDilemmaResponses` | Ujian Moral / Heart Demon | Dilema integritas |
| `MarketplaceTemplates` | Warisan Teknik (Heritage) | Sharing antar kultivator |

---

## 14. Adaptasi per Layar

### 14.1 Onboarding

- Welcome copy bernuansa "menata jalan hidup" — bukan "mulailah kultivasi menuju keabadian"
- Life audit = "membaca kondisi enam palace kehidupan" secara ringan
- Disclaimer dan safety messaging tetap plain
- Struktur legal tidak berubah

### 14.2 Dashboard (Pusat Adaptasi Terbesar)

1. **Season Badge** → State badge (Growth / Seclusion / Dormant / Tribulation)
2. **Tree Vitality Card** → **Dao Tree Card** — visual pohon batin, growth tanpa punishment
3. **Radar Chart** → **Six Palace Resonance** — framing resonansi cabang hidup
4. **Action of the Day** → **Breakthrough Hari Ini** — satu practice utama
5. **Habit list** → **Scheduled Practices** — daftar latihan hari ini

**Yang harus dihindari:**
- Menampilkan rank secara agresif
- Mem-frame hari buruk sebagai "kultivasi rusak"

### 14.3 Journal Tab

- Mood log = **Qi Log**
- Deep reflection = **Inner Chamber Reflection**
- Copy: "Bagaimana aliran energimu hari ini?"

### 14.4 Reflection Tab = **Hall of Reflection**

- Cermin Nilai → Dao Heart Mirror
- Weekly Pulse → Meridian Check
- Thinking Canvas → Insight Array (bisa hybrid)
- Safety Card → tetap jelas
- Marketplace → Sutra Pavilion (opsional)

### 14.5 Profile Tab

- Profile = **Cultivator Profile** (optional hybrid)
- Core Values = **Dao Heart**
- Skin = **Dao Tree Skins**
- Export/reset tetap plain

---

## 15. Implementasi Teknis

### 15.1 Prinsip Utama

**Layer kultivasi adalah lapisan interpretasi di atas data yang sudah ada. Tidak perlu migrasi database.**

### 15.2 Struktur File Baru

```
app/lib/src/features/cultivation/
├── cultivation_layer.dart           # Class CultivationLayer — 4 sumbu
├── cultivation_constants.dart       # 8 realm, 5 state, 6 palace, 6 path constants
├── cultivation_strings.dart         # 3-Level Language resolver (50+ method)
├── cultivation_provider.dart        # Riverpod providers
├── cultivation_achievement.dart     # Achievement system (Fase 3)
└── widgets/
    ├── cultivation_badge.dart        # Lencana realm di dashboard
    ├── cultivation_progress_bar.dart # Progress bar realm
    ├── realm_breakthrough_dialog.dart# Dialog milestone
    └── cultivation_status_panel.dart # Panel ringkasan 4 sumbu
```

### 15.3 Core Data Structure

```dart
class CultivationLayer {
  final int realm;                    // 1–8
  final String realmName;             // "Body Tempering", dll
  final CultivationSeason season;     // growth, recovery, dormant, tribulation, integration
  final Map<String, double> palaces;  // 6 palace scores (0.0–10.0)
  final CultivationPath? dominantPath;
  final double qiLevel;              // 0.0–1.0 dari canopy load ratio
  final int cumulativeDays;
  final String? daoHeart;            // core values
  final LanguageLevel languageLevel;
  final String? heartDemon;          // detected heart demon (nullable)

  // Factory dari data existing — TANPA migrasi DB
  static CultivationLayer fromDashboard(DashboardData data, UserProfile profile) { ... }
}

enum CultivationSeason { growth, recovery, dormant, tribulation, quietIntegration }
enum CultivationPath { sword, alchemist, formation, body, word, shadow }
enum LanguageLevel { plain, hybrid, full }
```

### 15.4 Provider Integration

```dart
final cultivationProvider = Provider<CultivationLayer?>((ref) {
  final dashboardAsync = ref.watch(dashboardDataProvider);
  return dashboardAsync.when(
    data: (data) => CultivationLayer.fromDashboard(data),
    loading: () => null,
    error: (_, __) => null,
  );
});

final languageLevelProvider = StateProvider<LanguageLevel>(
  (ref) => LanguageLevel.hybrid, // default
);
```

### 15.5 Multi-Sinyal Realm Calculation

```dart
int _calculateRealm(int cumulativeDays, List<HabitWithLog> habitsToday, UserProfile profile) {
  double signal = 0.0;

  // Sinyal 1: Cumulative days (bobot 40%)
  signal += (cumulativeDays / 730.0).clamp(0, 1) * 0.4;

  // Sinyal 2: Consistency (bobot 25%)
  // rata-rata completionRate90d dari semua habit aktif

  // Sinyal 3: Reflection depth (bobot 20%)
  // dari journal entries dan thinking canvas sessions

  // Sinyal 4: Values clarity (bobot 15%)
  // dari coreValues dan valueDilemmaResponses

  return _mapSignalToRealm(signal);
}
```

### 15.6 String Resolver

```dart
class CultivationStrings {
  static String actionOfTheDay(LanguageLevel level) {
    return switch (level) {
      LanguageLevel.plain => 'Prioritas Hari Ini',
      LanguageLevel.hybrid => 'Breakthrough Hari Ini',
      LanguageLevel.full => 'One Practice',
    };
  }

  static String journal(LanguageLevel level) {
    return switch (level) {
      LanguageLevel.plain => 'Catatan Harian',
      LanguageLevel.hybrid => 'Qi Log',
      LanguageLevel.full => 'Heart Scripture (心记)',
    };
  }

  static String recovery(LanguageLevel level) {
    return switch (level) {
      LanguageLevel.plain => 'Mode Istirahat',
      LanguageLevel.hybrid => 'Seclusion',
      LanguageLevel.full => 'Closed-Door Seclusion',
    };
  }

  // ... 50+ method total
}
```

### 15.7 Data Model Strategy

**Fase 1 — Tidak perlu migrasi schema:**

| Data Existing | Interpretasi Cultivation |
|---------------|-------------------------|
| `latestDomainScores` | Palace resonance |
| `coreValues` | Dao Heart declaration |
| `ValueDilemmaResponses` | Dao Heart Mirror input |
| `HabitLogs` | Practice records |
| `cumulativeDays` | Salah satu sinyal realm |
| `supportMode` | State / seclusion |

**Fase lanjutan (opsional):** field baru `cultivationThemeEnabled`, `vocabularyMode`.

---

## 16. Roadmap 4 Fase

### Fase 0: Foundation (Minggu 1-2) — Layer Interpretasi

_Tambahkan lapisan kultivasi 4 sumbu di atas data yang sudah ada, tanpa mengubah database._

| Task | Detail | Prioritas |
|------|--------|-----------|
| 0.1 | Buat `CultivationLayer` class dengan 4 sumbu | 🔴 P0 |
| 0.2 | Kalkulasi realm dari multi-sinyal | 🔴 P0 |
| 0.3 | Buat 5 state trigger logic | 🔴 P0 |
| 0.4 | Buat `CultivationStrings` — 50+ method 3 level | 🔴 P0 |
| 0.5 | Buat `cultivationProvider` + `languageLevelProvider` | 🔴 P0 |
| 0.6 | Unit test — semua test lama tetap lulus | 🔴 P0 |
| 0.7 | Integrasikan dengan `GrowthMapViewModel` | 🔴 P0 |

**Output:** CultivationLayer bisa di-query dari dashboardDataProvider. 3-Level Language resolver siap pakai. Tidak ada perubahan database.

### Fase 1: Narasi & Bahasa (Minggu 3-4) — 3-Level Language

| Task | Detail | Prioritas |
|------|--------|-----------|
| 1.1 | Implementasi `CultivationStrings` penuh | 🟡 P1 |
| 1.2 | Settings: 3-Level Language picker (radio button) | 🟡 P1 |
| 1.3 | Replace copy Dashboard (Tree Vitality, Action of the Day) | 🟡 P1 |
| 1.4 | Replace copy Growth Map (nodes, labels, semantic) | 🟡 P1 |
| 1.5 | Replace copy Friction Intervention | 🟡 P1 |
| 1.6 | Replace copy Journal & Thinking Canvas | 🟡 P1 |
| 1.7 | Replace copy Settings & Onboarding | 🟡 P1 |
| 1.8 | Test aksesibilitas screen reader di 3 level | 🟡 P1 |

### Fase 2: Visual & UI (Minggu 5-8) — Kosmetik Cultivation

| Task | Detail | Prioritas |
|------|--------|-----------|
| 2.1 | 5 State-based visual pohon (Growth, Recovery, Dormant, Tribulation, Integration) | 🟡 P1 |
| 2.2 | Realm indicator badge + progress bar | 🟡 P1 |
| 2.3 | Palace aura di Growth Map | 🟡 P1 |
| 2.4 | Skin pohon: "Bamboo Immortal", "Peach Blossom", "Ancient Pine" | 🟢 P2 |
| 2.5 | Panel status kultivasi (ringkasan 4 sumbu) | 🟡 P1 |
| 2.6 | Test di device low-end (no jank) | 🟡 P1 |

### Fase 3: Depth (Minggu 9-12) — Achievement, Path & Heart Demon

| Task | Detail | Prioritas |
|------|--------|-----------|
| 3.1 | Achievement system (5 milestone) | 🟡 P1 |
| 3.2 | 6 Paths detection algorithm | 🟢 P2 |
| 3.3 | Path profile UI | 🟢 P2 |
| 3.4 | Heart Demon Detection | 🟡 P1 |
| 3.5 | Heart Demon Severing flow | 🟢 P2 |
| 3.6 | Demonic Cultivation warning | 🟡 P1 |
| 3.7 | Test: tidak ada streak requirement | 🟡 P1 |

**5 Achievement Awal (Anti-Guilt):**

| Achievement | Trigger | Copy Hybrid |
|-------------|---------|-------------|
| Realm Breakthrough | Pertama kali masuk Realm baru | "Selamat, Dao Heart-mu semakin kokoh!" |
| Qi Milestone | 100 practice selesai | "Qi-mu mulai terkumpul — 100 practice!" |
| Tribulation Survivor | Pertama kali selesai Recovery | "Kamu melewati tribulation dan bangkit lebih kuat." |
| Dao Comprehension | 1 tahun berkultivasi | "Setahun dalam Dao — bijaksana dalam setiap langkah." |
| Legacy Builder | Bagikan template di Marketplace | "Warisan teknikmu membantu kultivator lain." |

### Fase 4: Ekspansi (Minggu 13+)

| Task | Detail | Prioritas |
|------|--------|-----------|
| 4.1 | Cultivation Journal Mode | 🟢 P2 |
| 4.2 | Palace Resonance Visualization (radar chart) | 🟢 P2 |
| 4.3 | Mind Demon Diary | 🟢 P2 |
| 4.4 | Dao Alignment Score | 🟢 P2 |
| 4.5 | Sekte (Social Mode — tanpa kompetisi) | 🔵 P3 |
| 4.6 | User Guide — Cultivation Mode | 🟢 P2 |

---

## 17. Testing & Metrik

### Test yang Harus Lolos

| Test | Deskripsi | Kritis? |
|------|-----------|---------|
| CultivationLayer from existing data | Semua 4 sumbu bisa dihitung tanpa data baru | ✅ Ya |
| No DB migration needed | Tidak ada perubahan schema database | ✅ Ya |
| 3-Level Language consistency | Semua komponen punya string di 3 level | ✅ Ya |
| Screen reader compatibility | Semantic label tidak hilang di level manapun | ✅ Ya |
| Anti-Guilt compliance | Tidak ada streak punishment, tidak ada judgment | ✅ Ya |
| State transition logic | State berganti sesuai trigger yang benar | ✅ Ya |
| Multi-sinyal realm calculation | Realm tidak hanya dari hari | ✅ Ya |
| Visual accessibility | Aura/warna tidak mengandalkan warna saja | ✅ Ya |
| Performance impact | Animasi cultivation tidak menyebabkan jank | ✅ Ya |

### Metrik Produk

| Metrik | Target 3 Bulan | Cara Ukur |
|--------|----------------|-----------|
| Adoption | ≥ 40% user menggunakan Hybrid/Full | Language level analytics |
| Retention | Tidak ada penurunan retention | Cohort comparison |
| Session Length | Tetap atau naik (+5-10%) | Session tracking |
| Realm progression | 30% user mencapai Realm 3+ dalam 3 bulan | CultivationLayer provider |

### Boundary Conditions

```
BOUNDARY: 3-Level Language OPSIONAL
  Jika: user pilih Plain
  Maka: semua istilah cultivation HILANG dari UI
  Test: Plain == behavior app saat ini

BOUNDARY: Anti-Guilt adalah hukum tertinggi
  Jika: ada fitur cultivation yang melanggar Anti-Guilt
  Maka: fitur DIBATALKAN

BOUNDARY: State bukan Realm
  Jika: user dalam state Recovery
  Maka: realm TIDAK berubah, hanya state yang berganti

BOUNDARY: Tidak ada "kematian" dalam sistem
  Jika: istilah "mati", "hancur", "gagal" muncul
  Maka: GANTI dengan "redup", "butuh perhatian", "terlewat"
```

---

## 18. Batasan & Anti-Pola

### Hal yang TIDAK BOLEH Dilakukan

| ❌ | Alasan |
|----|--------|
| Memaksa level bahasa tertentu | Alienasi user — harus bisa dipilih |
| Mengubah database untuk cultivation layer | Memperbesar risiko migrasi |
| Leaderboard "Level Kultivasi" | Melanggar Anti-Guilt |
| Streak "Latihan Harian" | Kembali ke streak punishment |
| Judgment "Demonic Cultivation" pada user | Demonic = pola, bukan label user |
| Mikrotransaksi "Pil Peningkat Qi" | Predatory monetization |
| State "mati" atau "gagal" | Tidak ada visual kematian |
| Realm sebagai ranking sosial | Realm interpretatif, bukan prestise |

---

## 19. Glossary

### Istilah Kunci

| Istilah | Arti | Level Bahasa |
|---------|------|-------------|
| **九炼归道** | Jalan Sembilan Penyulingan | Full |
| **Realm** | Tingkat perkembangan jangka panjang | Hybrid |
| **Palace** | Domain kehidupan | Hybrid |
| **Path** | Gaya bertumbuh personal | Hybrid |
| **State/Season** | Kondisi saat ini | Plain |
| **Dao Heart** | Nilai inti yang memandu hidup | Hybrid |
| **Qi** | Energi perhatian dan kapasitas harian | Hybrid |
| **Practice** | Kebiasaan/habit | Hybrid |
| **Breakthrough** | Aksi prioritas harian | Hybrid |
| **Tribulation** | Ujian/krisis yang menguji fondasi | Hybrid |
| **Heart Demon** | Hambatan psikologis batin | Hybrid |
| **Demonic Cultivation** | Pola tumbuh tidak sehat | Hybrid |
| **Seclusion** | Recovery/Mode Istirahat | Full |
| **Heritage** | Marketplace template | Full |
| **Resonance** | Weekly Pulse | Full |

### Perbandingan Tema Lama → Baru

| Tema Pohon (Lama) | Tema Cultivation (Baru) |
|-------------------|------------------------|
| Seed → Mature | 8 Realm |
| 6 Domain | 6 Palace |
| Tree Vitality | 5 State/Season |
| Akar Diri | Dao Heart |
| Daun Aktif | Practice |
| Bunga | Automaticity |
| Buah | Decision/Kebijaksanaan |
| Musim | State |
| Canopy Load | Qi Capacity |

---

## Rumus Final

> **Tubuh ditata → perhatian dikumpulkan → fondasi dibangun → nilai dikristalkan → kesadaran dilahirkan → krisis diolah → spirit diintegrasikan → pola hidup dipahami → dunia ditopang.**

> **Daoji adalah Personal OS bertema kultivasi batin, di mana pertumbuhan tidak diukur dari streak, melainkan dari seberapa dalam seseorang menata tubuh, energi, nilai, refleksi, dan jalan hidupnya.**

---

> _"Sistem kultivasi sejati bukan tentang mencapai realm tertinggi, tapi tentang menemukan ritme pertumbuhanmu sendiri. Daoji adalah Dao Tree-mu. Dao-mu adalah hidupmu."_

---

**Disintesis dari:** `evaluasi/migrasi/1.md`, `2.md`, `3.md`, `4.md`
**Tanggal:** 2 Juli 2026
**Untuk:** Daoji Personal OS
