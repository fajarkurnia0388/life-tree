# Siklus Rilis & Fase Pengujian Aplikasi Daoji

Dokumen ini menjelaskan tahapan pengujian perangkat lunak (*Software Release Lifecycle*) yang umum digunakan dalam industri, serta menetapkan status fase pengujian saat ini untuk aplikasi **Daoji**.

---

## 1. Penjelasan Tahapan Rilis & Pengujian

Dalam siklus pengembangan aplikasi, terdapat 5 tahap rilis utama:

### 1. Pre-Alpha / Tahap Pengembangan Aktif
* **Karakteristik:** Kode ditulis dan diuji langsung oleh developer per komponen. Banyak bagian logika masih berupa tiruan (*mock*) atau simulasi.
* **Stabilitas:** Sangat tidak stabil, sering terjadi *crash*, data database sering berubah-ubah secara drastis (*schema breaking changes*).

### 2. Alpha Testing (Internal) 👈 **[STATUS DAOJI SAAT INI]**
* **Karakteristik:** Aplikasi sudah memiliki fungsionalitas dasar yang utuh. Pengujian dilakukan oleh tim internal (developer dan QA) di lingkungan yang terkontrol.
* **Stabilitas:** Cukup stabil untuk dicoba internal, namun masih memiliki bug tersembunyi pada kasus-kasus batas (*edge cases*).
* **Kondisi Daoji saat ini:**
  * Seluruh fitur utama (Akar, Batang, Cabang, dan Kompas) sudah diimplementasi secara lokal (SQLite via Drift).
  * Struktur kode telah dirapikan (*modularized*) dan lulus analisis linter 100%.
  * Memiliki cakupan pengujian otomatis sebanyak **34 pengujian (unit/widget test)** yang semuanya lolos (*passed*).
  * Fitur-fitur tertentu masih berupa simulasi (seperti *Tree Skin Shop* dan pembayaran virtual).

### 3. Closed Beta Testing (Beta Tertutup)
* **Karakteristik:** Distribusi terbatas menggunakan undangan email kepada sekelompok pengguna terpilih (*early adopters*). Di Android menggunakan *Google Play Closed Testing*, di iOS menggunakan *TestFlight*.
* **Tujuan:** Menguji stabilitas pada beragam perangkat fisik nyata di dunia luar serta mengumpulkan masukan awal tentang kenyamanan antarmuka (UX).

### 4. Open Beta Testing (Beta Terbuka / Early Access)
* **Karakteristik:** Aplikasi dipasang di Google Play Store / Apple App Store dengan label *"Beta"* atau *"Akses Awal"*. Publik dapat mengunduh dan mencobanya secara sukarela.
* **Tujuan:** Menguji performa database lokal pada skala besar dan memastikan tidak ada masalah sinkronisasi atau kebocoran memori (*memory leak*).

### 5. Stable / Production Release (Rilis Resmi)
* **Karakteristik:** Versi matang yang dipublikasikan secara komersial ke seluruh pengguna umum tanpa label beta. Aman untuk penggunaan sehari-hari.

---

## 2. Peta Jalan Menuju Rilis Berikutnya

Untuk membawa **Daoji** dari fase **Alpha** saat ini ke fase **Closed Beta**, langkah-langkah teknis berikut perlu diselesaikan:

1. **Penyelesaian Fitur Backlog:**
   * Implementasi algoritma penurunan otomatisasi (*Automaticity Decay*) berbasis sains perilaku (UCL Lally).
   * Enkripsi database SQLite menggunakan SQLCipher agar data privasi pengguna aman.
2. **Penyelesaian Simulasi Pembayaran:**
   * Integrasi payment simulator ke payment gateway nyata atau in-app purchase (IAP) sandbox.
3. **Penyempurnaan Integrasi File Sharing:**
   * Memastikan fitur ekspor data JSON bekerja sempurna menggunakan plugin `share_plus` untuk menyimpan file nyata ke memori perangkat.
