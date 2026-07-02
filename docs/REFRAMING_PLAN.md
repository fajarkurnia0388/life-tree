# Rencana Implementasi Reframing Konsep Pertumbuhan Daoji

Dokumen ini merinci langkah-langkah untuk menyelaraskan istilah dan visualisasi di dalam aplikasi agar sepenuhnya konsisten dengan konsep **Peta Pertumbuhan Konseptual (Growth Map / Skill Tree)**, menggantikan sisa-sisa metafora pertumbuhan pohon fisik-linear yang lama.

---

## 🎯 Tujuan

1. Menghilangkan sisa-sisa metafora pertumbuhan linear (seperti "laju pertumbuhan", "keberhasilan kumulatif" yang kaku) yang berpotensi memicu kecemasan produktivitas (_guilt_).
2. Menyelaraskan UI Copywriting dengan metafora _Growth Map_ yang berfokus pada keseimbangan (_life balance_) dan kedalaman (_self-integration_).
3. Membuat progress bar di dashboard menjadi dinamis dan bermakna secara harian/keseimbangan, bukan sekadar statis atau linear.

---

## 📋 Langkah-Langkah Implementasi

### Langkah 1: Penyelarasan Istilah UI (UI Copywriting)

Kita akan memperbarui teks di beberapa widget utama agar lebih selaras dengan konsep peta konseptual:

#### 1. `app/lib/src/features/dashboard/widgets/tree_display_widget.dart`

- **Sebelumnya:** `"Kesehatan & Pertumbuhan Pohon"`
  - **Sesudah:** `"Peta Vitalitas & Keseimbangan Diri"`
- **Sebelumnya:** `"Pohon Istirahat dan Pemulihan ❄️"`
  - **Sesudah:** `"Peta Istirahat & Pemulihan Diri ❄️"`
- **Sebelumnya:** `"${widget.cumulativeDays} Hari Keberhasilan Kumulatif"`
  - **Sesudah:** `"${widget.cumulativeDays} Hari Perjalanan Refleksi & Aksi"`

#### 2. `app/lib/src/features/dashboard/widgets/season_badge_widget.dart`

- **Sebelumnya:** `"Musim Tumbuh (Growth Mode)"`
  - **Sesudah:** `"Musim Aktif & Seimbang (Active Mode)"`
- **Sebelumnya:** `"Laju pertumbuhan normal."`
  - **Sesudah:** `"Keseimbangan energi hidup terjaga."`

#### 3. `app/lib/src/features/dashboard/widgets/dev_toolbar_widget.dart`

- **Sebelumnya:** `"SIMULASI PERTUMBUHAN"`
  - **Sesudah:** `"SIMULASI HARI VIRTUAL"`
- **Sebelumnya:** `"Pertumbuhan"`
  - **Sesudah:** `"Hari Perjalanan"`

---

### Langkah 2: Refaktorisasi Progress Bar di `TreeVitalityCard`

Saat ini, progress bar di `TreeVitalityCard` di-hardcode ke `1.0` (selalu penuh). Kita akan mengubahnya agar mencerminkan **Indeks Keseimbangan Hidup** (Life Balance Index) berdasarkan rata-rata skor domain saat ini, atau **Keseimbangan Hari Ini** berdasarkan kebiasaan yang diselesaikan.

#### Opsi Terpilih: Indeks Keseimbangan Hidup (Life Balance Index)

Kita akan menghitung rata-rata skor dari 6 domain kehidupan (skala 1-10) yang ada di profil pengguna, lalu membaginya dengan 10.0 untuk mendapatkan nilai progress (0.0 - 1.0).

1.  **Modifikasi `TreeVitalityCard`:**
    Tambahkan parameter `double? balanceIndex` ke `TreeVitalityCard`.
2.  **Modifikasi `dashboard_view.dart`:**
    Hitung rata-rata skor domain dari `data.profile.latestDomainScores` dan kirimkan ke `TreeVitalityCard`.
    ```dart
    // Contoh kalkulasi di dashboard_view.dart
    double calculateBalanceIndex(String? latestDomainScoresJson) {
      if (latestDomainScoresJson == null) return 0.5; // default
      try {
        final Map<String, dynamic> scores = jsonDecode(latestDomainScoresJson);
        if (scores.isEmpty) return 0.5;
        final total = scores.values.fold<double>(0.0, (sum, val) => sum + (val as num).toDouble());
        return (total / scores.length) / 10.0; // skala 0.0 - 1.0
      } catch (_) {
        return 0.5;
      }
    }
    ```

---

### Langkah 3: Verifikasi & Pengujian

1.  **Analisis Kode:** Jalankan `flutter analyze` untuk memastikan tidak ada error kompilasi atau tipe data setelah perubahan parameter.
2.  **Unit Test:** Pastikan test yang ada di `app/test/` tetap berjalan dengan sukses. Jika ada test yang memverifikasi teks lama, sesuaikan dengan teks baru.

---

## 🚀 Dampak Terhadap Pengguna

- **Bebas Rasa Bersalah (Anti-Guilt):** Pengguna tidak lagi melihat "laju pertumbuhan" mereka melambat atau merasa gagal jika tidak produktif. Fokusnya adalah menjaga keseimbangan energi hidup.
- **Kejelasan Konseptual:** Menghilangkan kebingungan mengapa pohon tidak berubah bentuk secara fisik, karena sekarang UI memperjelas bahwa ini adalah "Peta Vitalitas" interaktif.
