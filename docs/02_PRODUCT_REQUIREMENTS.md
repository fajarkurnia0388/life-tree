# 02 — Product Requirements
## Daoji / LifeTree Functional Requirements

> **Primary source of truth for product behavior, user flow, and UX-level requirements.**
>
> Dokumen ini memetakan apa yang harus dilakukan produk, bagaimana user bergerak di dalamnya, dan bagaimana tema cultivation diterapkan tanpa merusak usability.

---

## 1. Target Pengguna

### 1.1 Persona inti
1. **Overloaded self-improver**
   - sering pakai habit/productivity app
   - mudah merasa gagal saat streak putus
   - butuh sistem yang lebih manusiawi

2. **Reflective builder**
   - suka journaling/reflection
   - ingin tindakan nyata, bukan refleksi pasif saja

3. **Recovering user**
   - butuh struktur ringan yang tidak menghukum saat energi rendah

4. **Meaning-driven user**
   - tertarik pada nilai hidup, arah, dan pengembangan diri yang lebih filosofis

---

## 2. Prinsip Requirement

1. **Action + reflection harus berjalan bersama**
2. **Tidak ada flow yang memaksa rasa bersalah**
3. **Semua fitur harus tetap masuk akal tanpa user memahami xianxia**
4. **Cultivation layer harus bisa dimatikan atau dilembutkan lewat vocabulary mode**
5. **Safety lebih penting daripada flavor**

---

## 3. User Journey Inti

## 3.1 Onboarding
### Tujuan
- mengenalkan filosofi produk
- mengumpulkan data minimal untuk orientasi awal
- memastikan persetujuan wellbeing disclaimer

### Input minimal
- age band
- life audit awal (MVP minimal tubuh; target 6 domain)
- acceptance disclaimer
- opsi cultivation theme (plain / hybrid / full) jika fitur ini diaktifkan

### Output
- `UserProfile` terbentuk
- `LifeAudit` awal tersimpan
- `ConsentLog` tersimpan

### Requirement
- harus ringan, tidak mengintimidasi
- cultivation framing hanya pengantar lembut, bukan lore dump
- safety disclaimer tetap plain dan mudah dipahami

---

## 3.2 Dashboard Harian
### Tujuan
Menjadi pusat orientasi harian.

### Komponen wajib
1. **State badge**
   - Growth / Seclusion / Dormant / dst.
2. **Dao Tree Card**
3. **Six Palace Resonance** (radar / visual domain)
4. **Breakthrough Hari Ini**
5. **Scheduled Practices**
6. shortcut ke journaling/reflection yang relevan

### Requirement
- user harus tahu apa satu hal paling berguna hari ini
- user harus bisa melihat kondisi sistem hidupnya tanpa merasa dinilai
- dashboard tidak boleh penuh noise

---

## 3.3 Practice / Habit Flow
### Tujuan
Mengubah niat menjadi tindakan kecil yang realistis.

### Requirement inti
- user bisa menambah/edit/archive practice
- practice terhubung ke domain/palace
- practice punya friction, energy, impact
- scheduled days/frequency didukung
- praktik harian bisa ditandai done/missed

### Naming
- plain: habit / kebiasaan
- hybrid: practice
- full: cultivation technique

### Acceptance criteria
- user bisa membuat practice ≤ 1 menit interaksi utama setelah membuka form
- status done/missed bisa diubah dengan cepat
- practice yang tidak relevan bisa diarsipkan tanpa framing gagal

---

## 3.4 Action of the Day / Breakthrough Hari Ini
### Tujuan
Menentukan satu practice paling relevan berdasarkan deficit domain dan faktor lain.

### Requirement
- rule-based, bukan black-box AI
- prioritas memihak domain paling lemah
- mempertimbangkan impact, friction, energy
- bila semua scheduled practice done → tampilkan celebration state

### Acceptance criteria
- user selalu paham kenapa satu practice dipilih
- tidak ada kesan manipulatif atau “bossy”

---

## 3.5 Friction Intervention / Bottleneck Inquiry
### Tujuan
Mengubah kegagalan eksekusi menjadi data refleksi.

### Trigger minimum
- missed habit melewati threshold sesuai frekuensi

### Pilihan friksi minimum
- kurang waktu
- kelelahan
- lupa / fokus buyar

### Output minimum
- micro-version suggestion
- recovery suggestion
- insight tentang hambatan dominan

### Requirement
- bahasa harus empatik
- tidak boleh ada kata-kata menyalahkan
- bottleneck harus terasa seperti diagnosis, bukan vonis

---

## 3.6 Journal / Qi Log
### Tujuan
Menyediakan refleksi harian ringan yang cepat dilakukan.

### Requirement inti
- mood selection cepat
- optional note singkat
- prefill “hari ini”
- bisa dipakai tanpa menulis panjang

### Deep reflection
- optional expansion
- gratitude / reflection prompts boleh muncul
- tetap tidak boleh terlalu berat atau terapeutik palsu

### Acceptance criteria
- entry mood harian bisa dilakukan dalam <30 detik
- low energy user tetap bisa menyelesaikan flow

---

## 3.7 Thinking Canvas / Insight Array
### Tujuan
Membantu user berpikir lebih jernih saat buntu, bingung, atau terlalu penuh.

### Requirement inti
- paper-first tetap dipertahankan
- user pilih metode berpikir sesuai kondisi
- aplikasi menyimpan ringkasan, bukan menggantikan proses berpikir penuh

### Use cases
- pikiran penuh
- belum punya ide
- terlalu banyak opsi
- takut gagal
- perlu validasi cepat

### Acceptance criteria
- user bisa memilih metode tanpa harus paham jargon desain berpikir
- hasil sesi harus bisa berujung ke satu aksi kecil atau ringkasan jelas

---

## 3.8 Weekly Pulse / Meridian Check
### Tujuan
Meninjau keseimbangan domain dan ritme hidup secara berkala.

### Requirement
- cukup singkat untuk diisi berkala
- hasil memberi sinyal domain paling perlu perhatian
- bisa memengaruhi prioritas dashboard

### Acceptance criteria
- hasil tidak terasa seperti penilaian rapor
- hasil bisa dipahami sebagai arah, bukan label diri

---

## 3.9 Life Compass / Dao Heart
### Tujuan
Membantu user mendeklarasikan nilai inti dan arah hidup.

### Requirement
- user bisa memilih / menulis 1–3 nilai inti
- ada preset chips untuk mempercepat
- values bisa diubah seiring waktu
- values harus dipakai di bagian lain sistem (mis. alignment)

### Acceptance criteria
- values bukan dekorasi; harus punya efek interpretatif pada sistem
- copywriting tidak menggurui

---

## 3.10 Value Mirror / Dao Heart Mirror
### Tujuan
Membandingkan nilai yang dinyatakan dengan pola pilihan yang nyata.

### Requirement
- gunakan dilema ringan atau pilihan nilai tersirat
- hasil tidak boleh menghukum
- hasil harus memancing refleksi, bukan rasa malu

### Acceptance criteria
- user dapat melihat “gap” tanpa merasa dipermalukan
- sistem menekankan pola berkembang, bukan kebohongan diri

---

## 3.11 Decision Journal / Forked Path Journal
### Tujuan
Menyimpan keputusan penting agar bisa direview jujur di masa depan.

### Requirement
- create decision entry
- set review date
- mark reviewed
- reflection on outcome / bias

### Acceptance criteria
- keputusan overdue terlihat di dashboard/journal area
- review keputusan membantu pembelajaran, bukan penyesalan pasif

---

## 3.12 Safety Card
### Tujuan
Menyediakan jalur bantuan yang jelas saat user mengalami distress signifikan.

### Requirement mutlak
- label harus tetap eksplisit dan aman
- kontak bantuan harus nyata
- tidak boleh disamarkan terlalu jauh oleh lore

### Penamaan aman
- `Safety Card`
- optional subtitle: `Talisman Keselamatan`

### Acceptance criteria
- user dapat memahami fungsi fitur ini tanpa memahami tema cultivation sama sekali

---

## 3.13 Profile / Settings
### Tujuan
Tempat personalisasi dan kontrol sistem.

### Requirement minimum
- theme mode
- cultivation language level (future/active bila tersedia)
- core values editing
- export/reset
- developer mode jika relevan

### Optional future
- path preference
- root/archetype preference
- cultivation skin selection

---

## 3.14 Marketplace / Sutra Pavilion
### Tujuan
Menyediakan template practice dan, di masa depan, warisan teknik antar pengguna.

### Requirement inti
- discover template
- import template
- (opsional) share template
- metadata jelas

### Prinsip
Marketplace bukan gamified shop.
Ia adalah perpustakaan teknik / template yang membantu growth.

---

## 4. Requirement Copywriting

## 4.1 Tone of voice
- lembut
- jernih
- tidak manipulatif
- tidak memalukan
- tidak terlalu teatrikal pada mode default

## 4.2 Do / Don’t
### Jangan
- “kamu gagal lagi”
- “streak rusak”
- “kamu belum cukup disiplin”
- “naik level sekarang atau tertinggal”

### Gunakan
- “hari ini tampaknya berat”
- “mau coba versi lebih kecil?”
- “pohonmu sedang beristirahat”
- “palace ini bisa diberi lebih banyak ruang”

---

## 5. Requirement Visual

1. pohon tidak mengecil sebagai hukuman
2. state buruk tidak divisualkan sebagai kematian
3. sinyal perhatian harus lembut
4. warna bukan satu-satunya pembawa informasi
5. animasi lambat dan aman untuk sensitivitas visual

---

## 6. Requirement Progressive Disclosure

### Prinsip
Feature exposure harus bertahap berdasarkan kebutuhan dan kesederhanaan onboarding, bukan rank gate keras.

### Maka
- user baru tidak perlu melihat semua konsep cultivation sekaligus
- user berpengalaman bisa masuk lebih dalam
- tidak ada “fitur terkunci karena level kamu rendah” sebagai framing utama

---

## 7. Requirement Keamanan & Etika

1. produk bukan pengganti terapi
2. produk tidak boleh mensimulasikan diagnosis klinis
3. fitur insights tidak boleh overclaim
4. state user sensitif harus diperlakukan hati-hati
5. copywriting krisis harus jelas dan sederhana

---

## 8. Requirement Integrasi Cultivation

Agar cultivation theme dianggap berhasil, implementasi harus memenuhi:
- user non-xianxia tetap bisa memakai produk dengan nyaman
- user yang suka cultivation merasa theme ini meaningful
- semua konsep cultivation harus memperjelas, bukan mengaburkan, fungsi produk

---

## 9. Prioritas Implementasi Requirement

### P0 — wajib untuk identitas baru
- dashboard language
- dao tree framing
- breakthrough hari ini
- qi log
- seclusion mode naming
- dao heart naming

### P1 — memperdalam sistem
- palace framing
- bottleneck inquiry language
- value mirror as dao heart mirror
- reflection hall consistency

### P2 — advanced flavor
- path personalization
- full cultivation vocabulary mode
- technique library flavor
- root/archetype light personalization

---

## 10. Ringkasan Akhir

Product requirements Daoji harus memastikan bahwa:
- sistem tetap actionable,
- refleksi tetap ringan dan aman,
- cultivation menjadi bahasa makna yang memperkaya,
- dan Anti-Guilt tetap menjadi hukum tertinggi di semua flow.
