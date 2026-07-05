# META-007 — Protokol Revisi, Verifikasi, dan Versioning

## 1. Informasi Dokumen

| Elemen | Nilai |
|---|---|
| ID | META-007 |
| Domain | META |
| Peran | Hub |
| Status temporal | Stable |
| Versi | 0.1 |
| Last updated | 2026-07-04 |
| Fungsi | Menetapkan aturan revisi, verifikasi isi, dan versioning arsip |

---

## 2. Tujuan Dokumen

Dokumen ini menetapkan:
1. bagaimana sebuah file diperbarui;
2. bagaimana kualitas isi diverifikasi;
3. kapan sebuah file naik versi;
4. bagaimana perubahan besar dan kecil dicatat;
5. bagaimana file Stable, Living, dan Snapshot dikelola dari waktu ke waktu.

---

## 3. Prinsip Umum

1. Tidak ada file yang dianggap final mutlak.
2. File Stable boleh direvisi, tetapi tidak dengan frekuensi tinggi.
3. File Living wajib memiliki jejak pembaruan yang jelas.
4. File Snapshot tidak diubah isinya setelah dikunci; revisi dilakukan dengan snapshot baru.
5. Revisi definisional harus memperhatikan owner concept dan overlap matrix.

---

## 4. Tipe Perubahan

### 4.1 Minor revision
Contoh:
- perbaikan istilah;
- koreksi typo;
- penambahan cross-reference kecil;
- penyempurnaan satu subbagian tanpa mengubah struktur utama.

### 4.2 Major revision
Contoh:
- perubahan struktur file;
- perubahan owner concept;
- penambahan atau pengurangan bagian inti;
- perubahan metodologi internal file;
- penambahan banyak karya acuan baru yang mengubah kesimpulan.

### 4.3 Structural revision
Contoh:
- pemecahan satu file menjadi dua atau lebih;
- merger beberapa file;
- perubahan domain/peran file;
- perubahan hubungan file terhadap milestone proyek.

---

## 5. Aturan Versioning

### 5.1 Format versi
- `0.x` = draft kerja awal
- `1.x` = struktur file stabil dan siap dirujuk aktif
- `2.x` = revisi besar pasca implementasi fase utama

### 5.2 Pedoman praktis
- koreksi minor → naik `0.1` ke `0.2`, atau `1.1` ke `1.2`
- revisi besar → naik `0.x` ke `1.0`, atau `1.x` ke `2.0`
- perubahan struktural besar → wajib dicatat di `META-001`

---

## 6. Verifikasi Isi

### 6.1 Verifikasi minimum untuk file L1
- batas file jelas
- istilah inti konsisten dengan glosarium
- owner concept tidak dilanggar
- minimal 3 sumber/karya acuan sesuai done criteria

### 6.2 Verifikasi minimum untuk file L2
- semua syarat L1
- overlap dicek terhadap file terkait
- contoh karya lebih dari satu
- klaim inti tidak hanya bertumpu pada satu sumber sekunder

### 6.3 Verifikasi minimum untuk file L3
- semua syarat L2
- sintesis lintas domain masuk akal
- terminologi stabil
- file siap dijadikan rujukan inti untuk file lain
- ada catatan pertanyaan terbuka atau batas pengetahuan

---

## 7. Protokol Revisi per Status File

### Stable
- direvisi bila ditemukan:
  - kesalahan definisional,
  - bias sumber,
  - perubahan struktur arsip yang memaksa penyesuaian.
- frekuensi revisi rendah.

### Living
- diperbarui berkala.
- wajib mencantumkan `Last updated`.
- perubahan isi dapat signifikan selama jejak revisi tetap terbaca.

### Snapshot
- tidak diedit setelah snapshot dikunci.
- pembaruan dilakukan dengan membuat file snapshot baru atau versi snapshot baru.

### Draft
- bebas direvisi intensif sampai struktur dasar dianggap layak.

---

## 8. Protokol Review

Setiap file yang naik dari Draft ke Draft Ready atau ke Stable sebaiknya dicek melalui urutan berikut:

1. **self-review struktur**
   - apakah pertanyaan inti tetap fokus?
   - apakah file keluar dari scope?

2. **scope review**
   - apakah file melanggar owner matrix?
   - apakah overlap dengan file terkait terlalu besar?

3. **terminology review**
   - apakah istilah sesuai `META-005`?

4. **source review**
   - apakah sumber cukup beragam untuk level target?

5. **cross-reference review**
   - apakah file terkait sudah disebut dengan benar?

---

## 9. Change Logging

Setiap file disarankan memuat catatan perubahan singkat di bagian bawah bila revisi sudah mulai sering terjadi.

Contoh format:
- v0.1 — draft awal
- v0.2 — penambahan karya acuan dan pembatasan scope
- v1.0 — struktur stabil dan siap dirujuk aktif

Untuk file sangat sentral, perubahan besar juga dicatat di `META-001`.

---

## 10. Kapan Sebuah File Dianggap “Naik Tahap”

### Draft → Draft Ready
Syarat minimum:
- struktur dasar lengkap;
- bagian inti terisi;
- file sudah bisa dibaca sebagai unit berdiri sendiri.

### Draft Ready → Stable
Syarat minimum:
- done criteria level target tercapai;
- scope file jelas;
- owner concept aman;
- istilah konsisten;
- file dapat dirujuk oleh file lain tanpa menghasilkan kebingungan besar.

### Stable → Revised Stable
Syarat minimum:
- revisi besar tercatat;
- versi dinaikkan;
- perubahan terhadap kesimpulan inti dijelaskan singkat.

---

## 11. Protokol untuk File Living Market

Untuk file market yang berstatus Living:
- pembaruan tidak harus menjaga semua simpulan lama tetap berlaku;
- data lama tidak dihapus tanpa jejak;
- bila perubahan besar terjadi, file harus menyebut “apa yang berubah dari pembaruan sebelumnya”.

Contoh file:
- `MARKET-002`
- `MARKET-003`
- `MARKET-004`
- `MARKET-006`
- `MARKET-014`

---

## 12. Protokol Bila Struktur Proyek Berubah

Jika terjadi:
- pemecahan file,
- merger file,
- perubahan domain,
- perubahan numbering,
- perubahan milestone,

maka langkah berikut wajib dilakukan:
1. perbarui `META-001`;
2. perbarui `META-003`;
3. perbarui file terkait langsung;
4. catat perubahan versi file yang terdampak.

---

## 13. File Terkait

| File | Fungsi relasional |
|---|---|
| META-001 | log status dan milestone proyek |
| META-003 | scope dan owner matrix |
| META-005 | terminologi |
| META-008 | throughput dan ritme kerja |
| META-009 | MVA dan milestone |

---

## 14. Status Implementasi

Dokumen ini menetapkan aturan minimum agar arsip dapat bertumbuh tanpa kehilangan konsistensi. Revisi lanjutan dapat menambahkan:
- template change log baku;
- matriks review per level;
- jadwal pembaruan standar untuk file Living tertentu.
