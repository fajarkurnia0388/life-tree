# Implementation Plan

## Tujuan

Memastikan transisi tampilan pohon dari representasi gambar menjadi representasi konseptual selesai secara konsisten, bersih, dan mudah dipelihara.

## Fokus Perbaikan

### 1. Konsistensi arsitektur UI pohon

- Pastikan seluruh tampilan pohon di dashboard menggunakan alur konseptual yang sama melalui widget pertumbuhan dan painter yang sudah ada.
- Hindari sisa-sisa kode atau komentar yang masih mengacu pada ilustrasi PNG atau representasi gambar lama.

### 2. Pembersihan kode yang tertinggal

- Periksa dan rapikan komentar, docstring, dan label UI yang masih menyebutkan "illustration" atau "image" walaupun implementasinya sudah konseptual.
- Pastikan nama kelas, file, dan deskripsi tidak menyesatkan pengguna maupun developer.

### 3. Pembersihan dev tool terkait pohon

- Review fitur dev tool yang berhubungan dengan pohon, terutama tombol, override, dan helper debugging yang memengaruhi visualisasi.
- Pastikan dev tool tidak lagi menyimpan logika atau label yang mengacu pada mekanisme gambar lama.
- Sederhanakan pengaturan dev tool agar fokus pada pengujian fase, skin, dan kondisi recovery.

### 4. Pembersihan konsep skin pohon

- Menyelaraskan definisi skin pohon pada seluruh layer: data, UI, dan tema visual.
- Pastikan mapping skin ke warna, nuansa, dan perilaku visual konsisten dan tidak saling tumpang tindih.
- Hilangkan elemen skin yang tidak lagi relevan atau duplikasi aturan penamaan.

### 5. Pembersihan konsep fase pohon

- Meninjau ulang sistem fase pertumbuhan agar label, threshold, dan visualisasi saling konsisten.
- Pastikan fase pohon tidak lagi bercampur dengan konsep musim/recovery atau istilah UI lama.
- Sederhanakan transisi fase agar lebih mudah dipahami oleh pengguna dan developer.

### 6. Penguatan integrasi data ke pohon konseptual

- Verifikasi bahwa data kebiasaan, domain, keputusan, dan skor kesehatan terhubung dengan benar ke node-node pohon konseptual.
- Pastikan placeholder dan interaksi klik tetap berfungsi dengan baik untuk habit yang belum ada.

### 7. Perbaikan UX dan semantik

- Menjaga label aksesibilitas dan deskripsi semantik agar pohon konseptual tetap mudah dipahami oleh pengguna layar pembaca.
- Memastikan elemen visual tetap informatif tanpa bergantung pada gambar statis.

### 8. Pengujian dan validasi

- Jalankan pengujian terkait dashboard dan widget pohon untuk memastikan tidak ada regresi.
- Lakukan review visual pada tampilan pohon di berbagai skenario: hari normal, recovery, skin berbeda, dan fase pertumbuhan berbeda.

## Area Prioritas

1. [app/lib/src/features/dashboard/widgets/tree_display_widget.dart](../app/lib/src/features/dashboard/widgets/tree_display_widget.dart)
   - Perbaiki komentar dan wording yang masih mengacu pada ilustrasi gambar lama.
2. [app/lib/src/features/dashboard/widgets/growth_map/growth_map_widget.dart](../app/lib/src/features/dashboard/widgets/growth_map/growth_map_widget.dart)
   - Pastikan interaksi node dan placeholder tetap konsisten.
3. [app/lib/src/features/dashboard/widgets/growth_map/growth_map_painter.dart](../app/lib/src/features/dashboard/widgets/growth_map/growth_map_painter.dart)
   - Periksa visual koneksi dan warna untuk memastikan representasi konsep tetap jelas.
4. [app/lib/src/features/dashboard/growth_map_provider.dart](../app/lib/src/features/dashboard/growth_map_provider.dart)
   - Verifikasi mapping data ke node pohon sudah benar.
5. [app/lib/src/features/dashboard/widgets/dev_toolbar_widget.dart](../app/lib/src/features/dashboard/widgets/dev_toolbar_widget.dart)
   - Review pengaturan dev tool yang berkaitan dengan visualisasi pohon dan fase.
6. [app/lib/src/core/domain/app_constants.dart](../app/lib/src/core/domain/app_constants.dart)
   - Periksa konstanta yang memengaruhi skin dan fase pohon.
7. [app/lib/src/core/domain/tree_skin_config.dart](../app/lib/src/core/domain/tree_skin_config.dart)
   - Bersihkan definisi skin dan fase agar lebih konsisten.

## Rencana Pelaksanaan

- Tahap 1: pembersihan dokumentasi, label, dan dev tool yang menyesatkan.
- Tahap 2: penyelarasan konsep skin pohon dan fase pertumbuhan di seluruh layer kode.
- Tahap 3: verifikasi flow data dan interaksi node.
- Tahap 4: validasi UI dan pengujian regresi.
- Tahap 5: dokumentasi final dan penutupan perubahan.

## Kriteria Selesai

- Tidak ada lagi bagian penting yang masih mengacu pada representasi gambar lama.
- Pohon konseptual tampil konsisten dan berfungsi dengan baik di dashboard.
- Konsep skin pohon dan fase pohon tersusun rapi, konsisten, dan mudah dipelihara.
- Dev tool terkait pohon tidak lagi menimbulkan kebingungan atau logika usang.
- Tidak ada regresi signifikan pada fitur terkait dashboard, habit, dan pengujian visual.
