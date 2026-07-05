# META-008 — Estimasi Effort dan Throughput Planning

## 1. Informasi Dokumen

| Elemen | Nilai |
|---|---|
| ID | META-008 |
| Domain | META |
| Peran | Hub |
| Status temporal | Living |
| Versi | 0.1 |
| Last updated | 2026-07-04 |
| Fungsi | Menetapkan estimasi beban kerja, throughput realistis, dan model produksi arsip |

---

## 2. Fungsi Dokumen

Dokumen ini bertujuan:
1. mengubah proyek dari blueprint konseptual menjadi proyek kerja yang terukur;
2. memperkirakan effort berdasarkan level kedalaman file;
3. menetapkan throughput realistis;
4. membantu mencegah burnout, over-planning, dan stagnasi;
5. menyelaraskan target dengan kapasitas aktual.

---

## 3. Asumsi Dasar Proyek

Arsip ini termasuk proyek skala besar dengan karakteristik berikut:
- jumlah file tinggi;
- file lintas domain dan lintas metode;
- sebagian file membutuhkan sintesis budaya, genre, dan market;
- sejumlah file berstatus Living dan memerlukan pemeliharaan;
- beberapa file Hub membutuhkan standardisasi istilah dan kontrol overlap yang ketat.

Dengan demikian, proyek ini tidak cocok diperlakukan sebagai “satu dokumen besar”, tetapi sebagai **program produksi arsip bertahap**.

---

## 4. Kategori Beban per Level

### 4.1 Level 1
**Karakter:** ringkas operasional, file satelit, file snapshot, atau template tertentu.

**Estimasi effort per file:**
- riset: 1–3 jam
- drafting: 1–2 jam
- revisi: 0.5–1 jam
- total: **2.5–6 jam**

### 4.2 Level 2
**Karakter:** mendalam, cukup representatif, dan dapat dipakai aktif.

**Estimasi effort per file:**
- riset: 3–8 jam
- drafting: 3–6 jam
- revisi: 1–3 jam
- total: **7–17 jam**

### 4.3 Level 3
**Karakter:** file inti / rujukan utama / sintesis besar.

**Estimasi effort per file:**
- riset: 8–20 jam
- drafting: 6–12 jam
- revisi: 3–8 jam
- total: **17–40 jam**

---

## 5. Estimasi Beban Arsip Secara Makro

Dengan konfigurasi V3 saat ini:
- puluhan file L1;
- puluhan file L2;
- belasan file L3.

Secara kasar, total beban proyek dapat masuk rentang:
- **minimum konservatif:** 350+ jam
- **rentang realistis:** 500–900 jam
- **rentang ekspansif:** 1.000+ jam

Ini menjelaskan bahwa proyek harus diperlakukan sebagai:
- program jangka panjang,
- bukan sprint satu fase pendek.

---

## 6. Model Throughput yang Direkomendasikan

### 6.1 Model konservatif
- 1 file L2 setiap 2 minggu
- 1–2 file L1 di sela-sela
- cocok bila kapasitas kerja rendah-menengah

### 6.2 Model seimbang
- 1 file L2 per minggu
- 1 file L1 tambahan per minggu
- 1 file L3 setiap 4–6 minggu
- cocok untuk produksi stabil jangka panjang

### 6.3 Model agresif
- 2 file L2 per minggu
- 1 file L3 setiap 3–4 minggu
- memerlukan disiplin tinggi dan kontrol kualitas ketat

---

## 7. Throughput yang Direkomendasikan untuk Arsip Ini

Untuk menjaga kualitas dan mencegah collapse akibat scope, model yang direkomendasikan adalah:

### Rekomendasi default
- **1 file Hub / L2 atau L3 per siklus utama**
- **1 file Satellite / L1 atau L2 per siklus pendamping**
- **1 sesi maintenance** untuk file Living bila diperlukan

Dalam praktiknya, ini dapat diterjemahkan menjadi:
- 2–4 file per bulan,
- dengan dominasi file governance dan file hub di fase awal.

---

## 8. Fase Produksi yang Direkomendasikan

### Fase A — Governance
Fokus:
- file META inti
- kontrol istilah
- owner matrix
- korpus benchmark

Target throughput:
- cepat, tetapi presisi tinggi
- 4–6 file relatif pendek-menengah

### Fase B — Ontology
Fokus:
- FOUND inti
- CORE inti
- SYS inti awal

Target throughput:
- lambat dan hati-hati
- file-file ini akan menjadi fondasi untuk puluhan file lain

### Fase C — World/System Expansion
Fokus:
- WORLD inti
- PATH inti
- file damage/immortality/inheritance

### Fase D — Narrative / Comparative / Market
Fokus:
- struktur cerita
- perbandingan
- file Living market

### Fase E — Toolkit dan Ekspansi
Fokus:
- synthesis
- anti-klise
- original design support

---

## 9. Strategi Anti-Burnout

### 9.1 Jangan memulai langsung dari file L3 paling besar
Disarankan memulai dengan:
- file governance,
- file hub menengah,
- atau satu file pilot L2.

### 9.2 Gunakan pola Hub–Satellite
Setelah satu file hub berat selesai, sisipkan satu file satelit yang lebih ringan.

Contoh:
- selesai `CORE-001` → lanjut `SYS-012` atau `PATH-012`
- selesai `WORLD-003` → lanjut `ENT-010`

### 9.3 Jangan memelihara terlalu banyak Living files terlalu awal
File Living market sebaiknya diaktifkan serius setelah fondasi ontologis dan struktural cukup kokoh.

### 9.4 Gunakan milestone, bukan hanya to-do list
Milestone memberi rasa selesai yang lebih sehat dibanding daftar file tanpa akhir.

---

## 10. File Pilot yang Direkomendasikan

Sebelum menyerang semua file L3 besar, disarankan ada **satu file pilot** untuk menguji template, gaya, dan protokol lintas file.

### Kandidat pilot yang direkomendasikan
1. `SYS-004_akar_spiritual_spiritual_roots_talent_dan_aptitude.md`
   - ruang lingkup jelas,
   - cukup sentral,
   - tidak sebesar Qi atau Dao.

2. `FOUND-008_bahasa_terjemahan_dan_masalah_terminologi_cultivation.md`
   - sangat berguna untuk standardisasi awal,
   - cepat menyehatkan arsip.

3. `ENT-004_tumbuhan_kultivasi_herbs_elixirs_spiritual_flora_dan_ekologi_obat.md`
   - topik luas tapi cukup terukur.

### File yang tidak direkomendasikan sebagai pilot pertama
- `CORE-001`
- `CORE-004`
- `WORLD-001`

File-file tersebut terlalu sentral dan cenderung berubah setelah governance matang.

---

## 11. Definisi “Siklus Produksi”

Satu siklus produksi minimum dapat didefinisikan sebagai:

1. memilih 1 file target utama;
2. mengecek owner matrix dan file terkait;
3. menulis draft;
4. merevisi berdasarkan scope, istilah, dan cross-reference;
5. memperbarui `META-001`.

### Output minimal per siklus
- 1 file baru atau 1 revisi besar;
- 1 pembaruan status di master index.

---

## 12. Throughput Planning Awal yang Direkomendasikan

### Bulan/Fase awal
- fokus pada 1–2 file governance per minggu,
- hindari membuka terlalu banyak file inti sekaligus,
- usahakan setiap file baru langsung masuk ke alur status di `META-001`.

### Setelah governance stabil
- 1 file hub per minggu atau per dua minggu,
- 1 file ringan di sela-sela,
- update living files secara terbatas.

---

## 13. Risiko Produksi dan Mitigasi

| Risiko | Dampak | Mitigasi |
|---|---|---|
| membuka terlalu banyak file sekaligus | proyek pecah fokus | batasi file aktif utama per fase |
| memaksa Level 3 terlalu awal | stagnasi | mulai dengan L2 untuk file pilot |
| file Living terlalu dini | kelelahan maintenance | aktifkan serius setelah governance stabil |
| tidak ada throughput target | proyek tidak bergerak | pakai ritme bulanan/milestone |
| terlalu lama di planning | tidak ada riset substantif | tetapkan transisi dari governance ke ontology |

---

## 14. Rekomendasi Operasional Saat Ini

Berdasarkan status saat ini, prioritas produksi yang paling masuk akal adalah:

1. menyelesaikan governance awal (`META-003`, `META-005`, `META-006`, `META-007`, `META-008`, `META-009`);
2. menetapkan file pilot L2;
3. baru memulai file ontologis besar.

Secara praktis, file pilot yang paling aman untuk memulai riset substantif adalah:
- `SYS-004`, atau
- `FOUND-008`.

Setelah itu, `CORE-001` dapat mulai ditulis dengan risiko revisi yang lebih rendah.

---

## 15. File Terkait

| File | Fungsi relasional |
|---|---|
| META-001 | status dan progress proyek |
| META-007 | protokol revisi dan versioning |
| META-009 | milestone dan MVA |

---

## 16. Status Implementasi

Versi ini menetapkan baseline effort planning untuk fase awal. Revisi berikut dapat menambahkan:
- estimasi jam per domain lebih rinci;
- contoh throughput aktual setelah beberapa file selesai;
- pembaruan model jika proyek bergerak lebih cepat atau lebih lambat dari perkiraan.
