# Whitepaper: Sistem Orientasi Diri "LifeTree" (Grow)
**Versi 7.0 (True Production-Ready Spec) – Arsitektur Sistem, Algoritma & Panduan UX**

## 1. Pendahuluan & Filosofi (Anti-Guilt)
LifeTree adalah **Personal OS** untuk orientasi hidup. Dibangun di atas 3 pilar teori:
1. **Habit Formation** (Lally et al., 2010): Kebiasaan memiliki rentang otomatisasi 18-254 hari. Kehilangan 1 hari tidak merusak proses.
2. **Cognitive Load Theory** (Sweller, 1988): Kapasitas working memory terbatas; sistem mencegah *burnout* dengan pembatasan beban.
3. **Behavioral Design** (Fogg Model): Menganalisa hambatan (Motivasi, Kemampuan, Pemicu) untuk intervensi yang presisi.

## 2. Central Command Dashboard (Layar Utama)
1. **Visual Pohon (Tree Vitality):** Status kesehatan sistem (bukan *streak*).
2. **Current Season (Konteks Hidup):** Diaktifkan secara *Manual* (pengguna memilih) atau *Hybrid* (Sistem menawarkan Mode Recovery jika mendeteksi *Pulse Check* anjlok).
3. **Radar Keseimbangan (Life Audit Snapshot):** Skor 6 domain kehidupan. *Update Mechanism:* Skor diperbarui secara dinamis melalui **Weekly Pulse Check** (1 pertanyaan refleksi per domain di akhir minggu) agar radar tetap relevan.
4. **Action of the Day (Algoritma Prioritas):**
   *Logika Mesin (Priority Score) = (Defisit Domain x Impact) / (Friction + Energy Load).* Sistem memprioritaskan habit yang menambal domain terlemah, namun memiliki *Impact* terbesar dengan *Friction* yang masuk akal.

## 3. Arsitektur Modul (Peta Lapis) & Spesifikasi Algoritma

### Lapis 0: Akar (Refleksi Adaptif & Diagnosis)
- **Adaptive Micro-Journaling:** Sistem menyediakan dua mode harian:
  - *Journal Lite (Default):* Hanya 1 ketuk emoji mood + 1 kata kunci. (Mengurangi beban onboarding).
  - *Deep Reflection:* 3 pertanyaan + *Gratitude prompt* (Hanya jika pengguna memilih untuk mengisinya).
- **Friction Journaling & Status Habit:**
  Habit memiliki 4 status: *Done, Missed, Skipped Intentionally* (Sengaja dilewati), dan *Paused*. Jika status *Missed* terjadi 3x dalam 7 hari (bukan berurutan), sistem memicu intervensi:
  - *Kurang Waktu* → Tawarkan versi 2-menit (*Minimum Viable Action*).
  - *Kelelahan* → Tawarkan opsi *Recovery* 1-7 hari (Fleksibel).
  - *Lingkungan/Lupa* → Tawarkan *Routine Stacking*.

### Lapis 1: Batang (Canopy Load & Goal Hierarchy)
- **Canopy Load (Pemisahan Friksi & Energi):** 
  Sistem menilai habit berdasarkan 2 variabel: *Initiation Friction* (Susah Mulai) dan *Energy Cost* (Kuras Tenaga). Default kapasitas awal: 10 Poin.
  - *Automaticity:* Setelah 30 hari sukses, *Friction Score* turun (karena sudah terbiasa mulai), TETAPI *Energy Cost* tetap (karena olahraga 1 jam tetap menguras energi). Total poin beban turun bertahap, bukan drastis.
- **Goal Hierarchy:** Visi (5 Thn) → Project (Tenggat Waktu) → Habit Harian / *Tasks*.

### Lapis 2: Cabang (6 Domain Kehidupan)
Terdiri dari: Keuangan, Tubuh, Hubungan, Emosi, Karir/Belajar, dan Rekreasi.
- *Tagging Opsional:* Untuk mencegah friksi *onboarding*, sistem menggunakan *Smart Suggestion* saat men-tag habit ke sebuah domain.

### Lapis 3: Buah & Kompas (Advanced)
- **Life Compass:** Memilih 3 *Core Values* opsional.
- **Decision Journal:** Mencatat keputusan sulit dengan pengingat *review* 90 hari.

## 4. Panduan Copywriting UX (Anti-Guilt Tone Guidelines)
Aplikasi harus di-*coding* dengan tata bahasa empati.
- **Hindari (Don't):** *"Kamu gagal menyelesaikan habit ini! Streak-mu kembali ke nol."*
- **Gunakan (Do):** *"Hari ini sepertinya berat. Tidak apa-apa, mau coba versi 2-menitnya saja atau istirahat?"*
- **Hindari (Don't):** *"Hapus habit ini."*
- **Gunakan (Do):** *"Arsipkan habit ini untuk memberi ruang yang lebih penting bulan ini."*

## 5. Segmentasi Usia, Keamanan Data (E2EE) & Aksesibilitas
- **Hukum Privasi (PP TUNAS & COPPA):** Usia 13-17 (Teen Mode) mendapat privasi jurnal mutlak; Orang Tua di dasbor HANYA menerima tren agregat dan *Conversation Starters* (Misal: *"Ajak anak ngobrol ringan, tren emosinya sedang turun"*).
- **Keamanan (Local Encrypted Storage):** Data jurnal dienkripsi *at-rest* via SQLCipher.
- **Recovery Key (Zero-Knowledge):** Untuk keamanan *cloud sync*, disediakan 12-Word Recovery Key dengan UX yang dipermudah (*Wizard Step-by-Step* + Integrasi Auto-Save iCloud/Google Password Manager) untuk mencegah *drop-off*.
- **Aksesibilitas (WCAG 2.1 AA):** Kompatibel dengan *Screen Reader* dan navigasi yang aman bagi *neurodivergent*.

## 6. Keselamatan Pengguna (Passive Crisis Protocol)
LifeTree BUKAN aplikasi medis (Tercantum jelas di T&C).
- Tidak menggunakan deteksi AI/Keyword yang rawan tuntutan hukum (*False Negative/Positive*).
- **Passive Safety:** Menyediakan "Safety Card" permanen berisi tombol Darurat/Hotline Nasional yang dapat di-update secara terpusat (*Remote-Config*).

## 7. Metrik Keberhasilan & Model Bisnis
- **Metrik Orientasi (Outcome):** 
  - *Shame-Free Return Rate* ≥ 30% (Pengguna yang absen > 3 hari kembali aktif setelah dipicu dialog *Friction* yang suportif).
  - Kenaikan skor skala WHO-5 *Well-being* / Penurunan skala *Guilt* (Pengujian berkala tiap 90 hari).
- **Metrik Retensi (Realistis):** *Day-7 Retention* ≥ 20%, *Day-30 Retention* 10% - 15%.
- **Value-Based Freemium:** Orientasi penuh & Enkripsi Lokal (GRATIS). *E2EE Cloud Sync* lintas perangkat, Analitik Pola On-Device, dan fitur *Decision Journal* (BERBAYAR/PLUS).

## 8. Spesifikasi Minimum Viable Product (MVP)
Lingkup pengerjaan untuk 14-16 minggu (Fokus Dewasa 18-35 Tahun):
- *Life Audit* (Onboarding), *Central Command Dashboard*, Lapis 0 (*Journal Lite* + *Friction Intervention*), Lapis 1 (*Canopy Load* Dinamis), 1 Domain Aktif dari Lapis 2, dan Kompas *Core Value*.
- Semua fitur untuk Anak/Remaja dan Dasbor Orang tua ditunda ke Fase 2.