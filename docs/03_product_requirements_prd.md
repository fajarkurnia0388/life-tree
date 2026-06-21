# Product Requirements Document (PRD): LifeTree

**Dokumen Spesifikasi Desain - Untuk Product Manager & Desainer UI/UX**

## 1. Visi Produk & Scope MVP
LifeTree adalah aplikasi yang memadukan jurnal, *habit tracker*, dan peta tujuan hidup. MVP HANYA ditujukan untuk pengguna Dewasa (18-35 tahun). Semua desain layar untuk mode anak, remaja, dan *parental control* TIDAK dimasukkan di MVP.

## 2. Struktur Layar Utama (Central Command Dashboard)
Saat pengguna membuka aplikasi, layar "Home" wajib menampilkan 4 elemen secara hierarkis (dari atas ke bawah):
1. **Visual Pohon (Tree Vitality):** Estetika utama aplikasi. Pohon tumbuh seiring konsistensi, bisa berubah sesuai *Current Season* (misal: bersalju saat *Recovery Mode*).
2. **Action of the Day (Aksi Prioritas):** 1 Kartu besar di tengah layar yang merekomendasikan **1 Habit** paling penting untuk dikerjakan hari ini.
3. **Radar Keseimbangan (Wheel of Life):** Diagram jaring laba-laba (*spider chart*) mini yang menampilkan 6 titik domain kehidupan.
4. **Quick Journaling (Akar):** Tombol akses cepat ke *Journal Lite* (1 ketuk emoji).

## 3. User Journey & Alur Layar (User Flows)

### A. Onboarding (Progressive Profiling)
Untuk mencegah pengguna menghapus aplikasi karena kelelahan (*drop-off*), proses *onboarding* dilakukan secara bertahap:
1. **Welcome Screen (Hari 1):** Menjelaskan filosofi *Anti-Guilt*. Pengguna hanya ditanya 2 dari 6 pertanyaan *Life Audit* sebagai *Quick Start*.
2. **Setup Keamanan (Hari 3):** Setelah pengguna merasa betah, sistem baru akan meminta pengguna mengamankan jurnal dengan mengunduh *12-Word Recovery Key* (Terdapat opsi cepat: *Save to iCloud/Google Passwords*).
3. **Full Audit (Akhir Minggu 1):** Sisa 4 pertanyaan audit diselesaikan saat pengguna melakukan *Weekly Pulse* pertama.

### B. Friction Intervention (Flow Saat Gagal Habit)
Jika sebuah habit berstatus *Missed* 3x dalam 7 hari:
1. Muncul Pop-up ramah (Bukan warna merah/peringatan keras).
2. Teks: *"Hari ini sepertinya berat. Apa hambatan terbesarmu kemarin?"*
3. Pilihan (A) Kurang Waktu, (B) Kelelahan, (C) Lupa.
4. Jika pilih (A), UI memunculkan tombol: *"Mau potong durasi habit ini jadi 5 menit saja untuk besok?"*

### C. Weekly Pulse Check (Akhir Minggu)
- Setiap hari Minggu, muncul notifikasi untuk *Weekly Pulse*.
- Pengguna menjawab 1 pertanyaan refleksi pendek per domain hidup agar skor Radar Keseimbangan di layar Home terus ter-*update*.

## 4. Panduan Copywriting (UX Writing Guidelines)
**Nada Suara (Tone of Voice):** Empatik, Tenang, Netral, Mendukung.
**Aturan Wajib (Do & Don'ts):**
- ❌ **JANGAN:** *"Kamu merusak streak-mu! Kembali ke Nol."* 
- ✅ **GUNAKAN:** *"Pohonmu sedang beristirahat. Kapanpun kamu siap, mari menanam lagi."*
- ❌ **JANGAN:** *"Hapus Habit."*
- ✅ **GUNAKAN:** *"Arsipkan Habit (Beri ruang untuk hal lain)."*
- ❌ **JANGAN:** *"Gagal / Failed."*
- ✅ **GUNAKAN:** *"Missed (Terlewat) / Paused (Jeda)."*

## 5. Aksesibilitas Visual (Accessibility)
- Radar Chart wajib memiliki versi alternatif berupa **List View / Tabel** bagi pengguna tuna netra (agar terbaca *Screen Reader*).
- Hindari penggunaan indikator yang HANYA mengandalkan warna (Misal: merah = bahaya). Gunakan kombinasi warna + Ikon.