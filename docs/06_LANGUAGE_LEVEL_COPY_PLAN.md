# 06 - Language Level Copy Evaluation & Rencana Perubahan

Tanggal: 2026-07-05
Status: Draft untuk review
Ruang lingkup: evaluasi dan rencana perbaikan copy untuk 4 level bahasa (`mortal`, `human`, `earth`, `heaven`).

## 1) Ringkasan Evaluasi Saat Ini

### Temuan Umum
- Tone antar level sudah berbeda, tapi belum konsisten di semua surface.
- Campuran Indonesia + Inggris + istilah kultivasi kadang terlalu acak per layar.
- Beberapa label terlalu panjang untuk komponen padat (terutama navbar, button, subtitle).
- Istilah inti yang sama belum selalu memakai kata yang sama (contoh: habit/practice/discipline/technique).
- Sebagian copy masih berorientasi tema, belum cukup berorientasi aksi pengguna.

### Dampak UX
- Pengguna sulit membedakan kapan copy bersifat "gaya" vs "instruksi".
- Beban baca meningkat, terutama pada level `earth` dan `heaven`.
- Pada komponen kecil, visual jadi tidak rapi jika teks panjang.

## 2) Prinsip Bahasa Global (Berlaku untuk Semua Level)

- Satu komponen, satu maksud: judul untuk konteks, subtitle untuk tindakan.
- Konsisten istilah per level (jangan gonta-ganti sinonim tanpa alasan produk).
- Batasi panjang copy:
  - Label navbar: ideal <= 10 karakter (atau gunakan label aktif saja).
  - Tombol aksi utama: ideal <= 18 karakter.
  - Subtitle kartu: ideal <= 55 karakter.
- Hindari frasa ambigu dan metafora berlapis untuk aksi kritis (hapus, reset, warning).
- Semua pesan error/warning tetap jelas, tidak terlalu puitis.

## 3) Rencana Voice per Level

## Level 1 - Mortal
Tujuan:
- Super jelas, ramah pemula, minim jargon.

Karakter bahasa:
- Indonesia sederhana sehari-hari.
- Hindari istilah kultivasi kecuali nama brand.

Pilihan kata utama:
- Habit, Catatan harian, Refleksi, Toko, Profil.

Contoh arah copy:
- "Add Habit" -> "Tambah Kebiasaan"
- "Bottleneck" -> "Hambatan"
- "Qi capacity exceeded" (jika muncul) -> "Kapasitas harian terlampaui"

Kapan dipakai:
- Default onboarding dan mode pemakaian umum.

## Level 2 - Human
Tujuan:
- Tetap jelas, tetapi lebih suportif, hangat, dan coaching.

Karakter bahasa:
- Bahasa Indonesia dengan nuansa motivasional ringan.
- Istilah kultivasi boleh muncul tipis sebagai flavor.

Pilihan kata utama:
- Discipline, Insight, Compass, Recovery.

Contoh arah copy:
- "Tidak sanggup hari ini" -> "Energi belum cukup hari ini"
- "Save & Reflect" -> "Simpan dan Tinjau"

Kapan dipakai:
- Pengguna yang butuh konteks emosional tanpa tone terlalu teknis.

## Level 3 - Earth
Tujuan:
- Tema Dao kuat, tetap mudah dipahami dan operasional.

Karakter bahasa:
- Bilingual ringan (EN istilah produk + ID instruksi).
- Istilah kultivasi dipakai konsisten, bukan dekoratif.

Pilihan kata utama:
- Practice, Dao Path, Qi Log, Refinement.

Contoh arah copy:
- "Add Practice" + subtitle Indonesia operasional.
- "Seclusion" tetap dipakai, tapi penjelasan harus plain.

Kapan dipakai:
- Pengguna yang suka nuansa tematik tapi tetap ingin efisien.

## Level 4 - Heaven
Tujuan:
- Nuansa puitis premium, tetapi tetap ringkas dan tidak mengganggu usability.

Karakter bahasa:
- Terminologi kultivasi lebih kental.
- Untuk UI padat (navbar/button/switch), gunakan istilah pendek terkurasi.

Pilihan kata utama:
- Sanctuary, Scripture, Alchemy, Archive, Dao Heart.

Contoh arah copy:
- Label ringkas untuk area padat, deskripsi puitis di area long-form.
- Warning tetap plain dan tegas (jangan puitis berlebihan).

Kapan dipakai:
- Pengguna advanced yang ingin immersion maksimal.

## 4) Kamus Istilah Inti per Level (Agar Konsisten)

| Konsep | Mortal | Human | Earth | Heaven |
|---|---|---|---|---|
| habit entity | Kebiasaan | Disiplin | Practice | Technique |
| journal | Catatan Harian | Discipline Log | Qi Log | Heart Scripture |
| reflection | Refleksi | Insight | Refinement | Inner Alchemy |
| profile | Profil | Compass | Compass | Dao Heart |
| reset | Reset Aplikasi | Reset Aplikasi | Reset App | Reset App |
| friction | Hambatan | Bottleneck | Bottleneck | Heart Demon Inquiry (judul), hambatan plain (isi) |

Catatan:
- Untuk aksi destruktif dan keamanan, gunakan bahasa plain di semua level.

## 5) Prioritas Perubahan (Urutan Implementasi)

P0 - High Impact (wajib dulu)
- Navigation labels
- Tombol CTA utama (Add/Save/Delete/Reset)
- Warning/error states
- Settings labels

P1 - Medium Impact
- Dashboard cards & subtitle
- Habit form labels
- Friction/recovery copy

P2 - Polish
- Empty states
- Tooltip dan microcopy sekunder
- Konsistensi tanda baca/kapitalisasi

## 6) Aturan Komponen Kecil vs Komponen Besar

Komponen kecil (navbar, tab, chip, button):
- Selalu pakai versi ringkas (compact lexicon).
- Hindari frasa 2-3 kata panjang jika bisa jadi 1 kata kuat.

Komponen besar (dialog, info card, onboarding explanation):
- Boleh pakai versi deskriptif/puitis sesuai level.
- Tetap sertakan satu kalimat aksi yang jelas.

## 7) Usulan Teknis Implementasi Copy

- Pertahankan registry berbasis `DaojiTextKey` per level.
- Tambahkan konsep "compact label" untuk key tertentu:
  - nav labels
  - CTA buttons
  - status badge
- Tambahkan lint/checklist internal untuk panjang copy pada key tertentu.
- Tambahkan review pass khusus: "tone + action clarity" sebelum merge.

## 8) Kriteria Selesai (Definition of Done)

- Semua key P0 konsisten antar 4 level.
- Tidak ada overflow teks pada komponen padat utama.
- User test cepat menunjukkan:
  - Level bisa dibedakan jelas gayanya.
  - Instruksi inti tetap mudah dipahami.
- Tidak ada regresi accessibility (kontras, keterbacaan, scanability).

## 9) Rencana Review

Yang direview dari dokumen ini:
- Apakah peran masing-masing level sudah tepat?
- Apakah istilah inti per level cocok dengan brand voice kamu?
- Apakah kamu ingin level Heaven lebih puitis lagi, atau justru lebih ringkas?

Jika disetujui, langkah berikutnya:
1. Susun daftar key P0 yang akan diganti per level.
2. Terapkan perubahan registry per batch kecil.
3. Validasi visual komponen padat + smoke test route utama.

## 10) Addendum Evaluasi Berbasis Gambar (Input User)

Catatan: screenshot yang kamu kirim sangat relevan dan harus dianggap sebagai data audit utama, bukan sekadar contoh visual.

Temuan dari screenshot:
- Kartu `Six Meridians` dan `Meridian Resonance` menunjukkan tone Heaven/Earth kuat, tetapi masih ada ketidakseimbangan antara istilah puitis vs label utilitarian (`Status`, `50%`, dsb).
- Komponen padat (badge, heading, dan label domain radar) sudah lebih rapi setelah perbaikan navbar, tapi hierarchy bahasa masih campur:
  - Judul sangat tematik.
  - Beberapa label tetap generik/teknis.
- Ada indikasi ketidakselarasan register lintas widget yang tampil berdampingan (contoh: istilah kultivasi tinggi di satu kartu, istilah netral di kartu lain).

Implikasi:
- Evaluasi copy tidak boleh hanya dari registry teks global; harus cross-check per layar nyata (composed UI), karena disharmoni muncul saat beberapa widget dirender bersamaan.

## 11) Area yang Belum Kamu Paparkan (Potensi Terlewat)

Berikut area yang kemungkinan belum tervalidasi dari sisi bahasa, tetapi berisiko tinggi inkonsistensi:

P0 (harus audit dulu)
- Dialog dan snackbar (error/sukses/konfirmasi) di dashboard, profile, journal, value mirror.
- Label form dan CTA di habit/journal/decision flow.
- Settings, reset, export, dark mode, dev mode.
- Tooltip ikon di widget interaktif (map/tree/canvas).

P1 (audit setelah P0)
- Thinking Canvas workspaces (banyak teks hardcoded per metode).
- Marketplace + payment simulation copy.
- Onboarding step copy (tone awal produk sering menentukan ekspektasi level bahasa).

P2 (polish)
- Empty states, helper text, dan microcopy sekunder.
- Konsistensi kapitalisasi, tanda baca, dan istilah domain.

## 12) Temuan Baru: Coverage Registry Belum Menyeluruh

Audit cepat menunjukkan masih banyak teks hardcoded di fitur utama, artinya:
- Perubahan level bahasa belum bisa konsisten 100% walaupun registry sudah bagus.
- Evaluasi level bahasa berisiko bias jika hanya lihat `DaojiTextKey`.

Rencana mitigasi:
1. Buat inventaris "hardcoded text" per fitur.
2. Kelompokkan: migrate ke registry vs tetap lokal (jika memang technical/debug text).
3. Tetapkan target coverage registry:
   - Target awal: 80% surface user-facing utama.
   - Target akhir: 95%+ untuk semua surface produksi.

Kriteria tambahan agar tidak ada yang terlewat:
- Setiap screen utama punya checklist "tone, clarity, length, consistency".
- Review dilakukan per-level (Mortal/Human/Earth/Heaven), bukan per-file.
- Screenshot comparison wajib untuk komponen padat (navbar, cards, dialogs, chips, forms).
