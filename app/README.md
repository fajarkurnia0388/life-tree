# Daoji Application

Daoji is a dynamic habit tracker built with Flutter, focusing on life balance and mental health, visually represented by a customizable growth tree.

## Fitur Utama
- **Radar Chart Keseimbangan Hidup:** Visualisasi skor domain kehidupan (Tubuh, Pikiran, Sosial, Karier, dll.).
- **Pohon Vitalitas Dinamis:** Pohon tumbuh dan berganti musim/warna sesuai dengan kemajuan kebiasaan harian Anda.
- **Onboarding Terstruktur:** Menuntun pengguna menetapkan prioritas dan preferensi keselamatan sejak awal.
- **Toko Skin Pohon:** Kustomisasi visual pohon dengan variasi Oak, Sakura, Maple, dan Bonsai.
- **Ekspor Data:** Pencadangan data pengguna secara aman ke dalam berkas JSON menggunakan sistem native sharing.

## Setup & Pengembangan

### Prasyarat
- Flutter SDK (versi `3.32.x` atau lebih baru)
- Dart SDK

### Langkah Awal
1. Ambil dependensi Flutter:
   ```bash
   flutter pub get
   ```
2. Jalankan build_runner untuk menghasilkan kode database (Drift):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
3. Jalankan aplikasi:
   ```bash
   flutter run
   ```

## Pengujian / Testing
Jalankan perintah berikut untuk mengeksekusi semua unit dan widget test:
```bash
flutter test
```
Untuk menjalankan analisis kode statis:
```bash
flutter analyze
```

## Arsitektur & Teknologi
- **State Management:** Riverpod (`flutter_riverpod`)
- **Database Lokal:** Drift SQLite (`drift`)
- **Penyimpanan Berkas:** Path Provider (`path_provider`)
- **Pemicu Sharing:** Share Plus (`share_plus`)
