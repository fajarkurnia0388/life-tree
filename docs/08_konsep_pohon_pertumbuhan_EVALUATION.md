# Evaluasi Dokumen `08_konsep_pohon_pertumbuhan.md`

Tanggal evaluasi: 2026-06-30  
Repo HEAD saat evaluasi: `7585f27` — `docs: add documentation for LifeTree growth concept and visual system`

## Ringkasan Eksekutif

Dokumen `08_konsep_pohon_pertumbuhan.md` punya ide visual yang kuat: LifeTree tidak hanya menampilkan pohon statis, tetapi dapat berkembang menjadi **peta pertumbuhan interaktif** yang menghubungkan nilai inti, domain hidup, kebiasaan, dan keputusan.

Namun, dokumen saat ini masih lebih berupa **narasi konsep visual** daripada spesifikasi implementasi. Ada beberapa konflik dengan prinsip canonical LifeTree yang sudah ada, terutama:

1. Potensi bertentangan dengan **Hard Rule Anti-Guilt** karena menyebut dahan defisit tampak `layu/kering`.
2. Scope-nya melampaui MVP dan implementasi saat ini, tetapi belum diberi label fase/iterasi.
3. Belum sinkron dengan dokumen `07_fitur_kompas_nilai_tersirat.md` tentang Core Values versi Dipilih vs Tersirat.
4. Belum mendefinisikan data source, threshold, state, algoritma, dan fallback secara cukup eksplisit untuk coding agent.
5. Ada elemen desktop/web seperti `hover` yang kurang cocok untuk mobile-first Flutter app.

Rekomendasi utama: dokumen ini sebaiknya diposisikan sebagai **Iterasi 2 / Advanced Visual System**, bukan baseline dashboard MVP. Perlu direvisi agar menjadi spec implementable dengan batasan anti-guilt, data model, mapping state, dan plan integrasi ke komponen Flutter yang sudah ada.

---

## Status Repo Setelah Update

Repo berhasil diperbarui dari GitHub dengan commit terbaru:

```text
7585f27 docs: add documentation for LifeTree growth concept and visual system
```

File baru yang relevan sudah ada:

```text
docs/08_konsep_pohon_pertumbuhan.md
```

Dokumen docs terbaru juga mencakup:

```text
docs/06_release_phases_and_testing.md
docs/07_fitur_kompas_nilai_tersirat.md
docs/08_konsep_pohon_pertumbuhan.md
docs/NAVIGATION_STRATEGY.md
```

---

## Kekuatan Dokumen

### 1. Metafora produk kuat dan mudah dipahami

Pembagian:

- Akar = Core Values
- Dahan = Domain Kehidupan
- Daun/Buah = Habits & Decisions

cukup intuitif dan cocok dengan branding LifeTree.

### 2. Menyatukan habit tracker dan life compass

Dokumen berhasil menghubungkan kebiasaan harian dengan identitas/nilai hidup, bukan sekadar checklist produktivitas. Ini sejalan dengan visi LifeTree sebagai **Personal OS untuk orientasi diri**.

### 3. Memperkenalkan feedback loop dua arah

Konsep:

- Top-down: nilai → domain → aksi
- Bottom-up: aksi → domain → nilai

bagus secara produk karena menjelaskan kenapa habit kecil tetap bermakna.

### 4. Ada arah interaktivitas dashboard

Ide node domain, node daun, quick-toggle, dan dialog insight bisa menjadi evolusi dashboard yang lebih kaya dibanding pohon statis.

### 5. Skin adaptation sudah dipikirkan

Dokumen mempertimbangkan skin Default, Sakura, Maple, dan Bonsai. Ini selaras dengan fitur Skin Shop yang sudah ada di codebase.

---

## Masalah Kritis / Inkonsistensi

### 1. Konflik dengan prinsip Anti-Guilt: `layu/kering`

Bagian dokumen menyebut:

> Dahan yang mengalami defisit akan tampak layu/kering.

Ini berisiko melanggar prinsip canonical yang sudah tertulis di `docs/00_master_blueprint.md`:

> Pohon TIDAK PERNAH mengecil atau mati — hanya bisa tumbuh atau istirahat.

Visual `layu`, `kering`, `rusak`, atau `mati` dapat terasa seperti hukuman bagi pengguna. Ini bertentangan dengan filosofi Anti-Guilt.

#### Rekomendasi revisi

Ganti bahasa dan visual menjadi:

| Jangan | Gunakan |
|---|---|
| dahan layu | dahan membutuhkan perhatian |
| dahan kering | glow lebih redup |
| daun mati | daun belum aktif hari ini |
| visual rusak | visual tenang / dormant / soft dim |

Contoh kalimat pengganti:

> Domain dengan skor rendah tidak divisualkan sebagai dahan mati atau rusak. Ia ditampilkan dengan glow yang lebih lembut, ring perhatian halus, atau label “butuh perhatian”, agar tetap selaras dengan prinsip Anti-Guilt.

---

### 2. Scope belum diberi fase: MVP vs Advanced Visual System

Dokumen menggambarkan **Growth Tech Tree** interaktif dengan root node, branch node, leaf node, energy flow, quick-toggle, dan domain insight.

Sementara implementasi saat ini masih memakai:

- `TreeDisplayWidget`
- `TreeVitalityCard`
- `OrganicTreePainter`
- `RadarChartWidget`
- `DomainInsightDialog`
- `TreeSkinConfig`

Tidak terlihat ada komponen `GrowthTechTreeWidget` atau graph/node-based dashboard penuh.

#### Rekomendasi revisi

Tambahkan status di awal dokumen:

```markdown
> Status: Konsep Visual Iterasi 2 / Advanced Dashboard
> Bukan scope MVP Core.
> MVP tetap menggunakan Tree Vitality + Action of the Day + Journal.
```

Lalu pisahkan:

1. **MVP Existing:** pohon tunggal + progress + season.
2. **Iterasi 1:** domain aura + domain insight.
3. **Iterasi 2:** Growth Tech Tree interaktif.

---

### 3. Belum sinkron dengan `07_fitur_kompas_nilai_tersirat.md`

Dokumen 08 menyebut akar sebagai:

> 3 Core Values, baik Dipilih secara sadar maupun Tersirat dari Cermin Nilai.

Tetapi dokumen 07 sudah membedakan secara eksplisit:

| Jenis | Sumber | Sifat |
|---|---|---|
| Versi Dipilih / Declared | `UserProfiles.coreValues` | bisa diedit manual |
| Versi Tersirat / Revealed | `revealedValueScores` | hasil Cermin Nilai, read-only |

Dokumen 08 belum menjelaskan bagaimana dua jenis nilai ini divisualkan di akar.

#### Rekomendasi revisi

Tambahkan mapping:

| Bagian akar | Data source | Visual |
|---|---|---|
| Akar utama | Declared Core Values | akar tebal / solid |
| Serabut akar | Revealed Values | akar tipis / outline / shimmer |
| Overlap nilai | Declared ∩ Revealed | akar lebih terang |
| Belum cukup data | minResponses belum tercapai | akar netral + CTA “Mulai Cermin Nilai” |

Ini akan membuat konsep pohon selaras dengan fitur Cermin Nilai.

---

### 4. Domain health belum punya formula dan threshold

Dokumen menyebut dahan sehat/defisit berdasarkan skor domain, tetapi tidak mendefinisikan:

- sumber skor domain
- rentang skor
- threshold visual
- staleness/TTL
- fallback jika skor belum ada

Padahal dokumen lain sudah punya konsep `latest_domain_score`, `WeeklyPulse`, `LifeAudit`, dan TTL.

#### Rekomendasi threshold visual

Gunakan pendekatan anti-guilt:

| Skor domain | State | Visual aman |
|---:|---|---|
| 8–10 | Stabil | glow lembut, warna penuh |
| 5–7 | Netral | warna normal, ring tipis |
| 1–4 | Butuh perhatian | glow redup + ikon kecil “perhatian”, bukan layu |
| Tidak ada data | Unknown | outline netral + CTA isi Weekly Pulse |
| Stale | Perlu update | badge “perlu check-in” |

Jangan gunakan state visual seperti `dead`, `withered`, `broken`, atau `dry`.

---

### 5. Daun dan buah masih ambigu

Dokumen menggabungkan:

- Habit aktif hari ini
- Habit log
- Decisions

sebagai `Daun/Buah`.

Ini perlu diperjelas karena perilakunya berbeda:

| Elemen | Cocok sebagai | Catatan |
|---|---|---|
| Habit aktif hari ini | Daun | Bisa quick-toggle |
| HabitLog Done | Daun menyala | Event harian |
| Habit otomatis / mature habit | Bunga | Terkait Automaticity Decay |
| Decision Journal | Buah | Bukan quick-toggle harian |
| Goal milestone | Buah besar | Cocok untuk momen pencapaian |

#### Rekomendasi

Pisahkan:

- **Daun:** kebiasaan harian/terjadwal.
- **Bunga:** habit yang mulai otomatis / stabil.
- **Buah:** keputusan besar, milestone, atau insight penting.

Jangan jadikan Decision Journal sebagai node quick-toggle.

---

### 6. `hover` tidak mobile-first

Tabel interaktivitas menyebut:

> saat di-hover

Target utama LifeTree adalah mobile Flutter. Hover hanya relevan untuk web/desktop.

#### Rekomendasi

Ubah menjadi:

| Platform | Interaksi |
|---|---|
| Mobile | tap, long press, bottom sheet |
| Desktop/Web | hover optional tooltip, click |
| Accessibility | semantic label + focus traversal |

Contoh:

> Tap node akar untuk membuka ringkasan nilai. Long press untuk tooltip detail. Pada desktop/web, hover dapat menampilkan preview singkat.

---

### 7. Istilah `Tech Tree / Skill Tree` perlu hati-hati

`Tech Tree` dan `Skill Tree` memberi nuansa game/RPG. Ini menarik, tetapi LifeTree juga mengusung Calm Tech dan anti-toxic productivity.

Risiko:

- terlalu gamified
- mendorong completionism
- terasa seperti “harus unlock semua cabang”

#### Rekomendasi

Gunakan istilah internal:

```text
Growth Map
```

atau:

```text
Peta Pertumbuhan
```

Jika tetap memakai `Tech Tree`, beri catatan:

> Istilah Tech Tree hanya digunakan sebagai inspirasi struktur visual, bukan sistem unlock kompetitif atau progression yang menghukum.

---

### 8. Tema skin terlalu agresif untuk Calm Tech

Beberapa nama skin:

- `Cyberpunk Amber`
- `Matrix Green`
- `hologram`
- `neon`

berpotensi bertabrakan dengan prinsip Calm Tech yang lembut dan tidak overstimulating.

#### Rekomendasi tone

| Saat ini | Alternatif lebih Calm Tech |
|---|---|
| Sakura Neon Pink | Sakura Dawn |
| Maple Cyberpunk Amber | Maple Ember |
| Bonsai Matrix Green | Bonsai Zen |
| Hologram | Soft Glow |

Efek visual harus tetap:

- animasi lambat
- tidak flashing
- aman untuk fotosensitivitas
- tidak bergantung pada warna saja

---

### 9. Energy loop belum punya event model

Dokumen menyebut:

> daun berfotosintesis, mengirim aliran energi visual

Bagus sebagai narasi, tetapi belum implementable.

#### Rekomendasi definisi event

Tambahkan mapping event:

| Event | Trigger data | Visual |
|---|---|---|
| Habit Done | insert/update `HabitLog.status = Done` | leaf glow 800ms |
| Habit Missed | `HabitLog.status = Missed` | tidak ada hukuman; leaf menjadi netral |
| Recovery Mode | `supportMode = Recovery` | snow/soft blue overlay |
| Domain focus | Action of the Day domain | domain aura lembut |
| Weekly Pulse updated | insert/update `WeeklyPulse` | branch ring pulse |
| Cermin Nilai selesai | new `ValueDilemmaResponses` | root shimmer halus |

---

### 10. Diagram Mermaid belum cukup menjelaskan aliran dua arah

Diagram sekarang memakai arah:

```text
Habit → Domain → Root → Values
```

Ini bisa dibaca sebagai hierarki terbalik, padahal dokumen menjelaskan dua aliran:

- top-down
- bottom-up

#### Rekomendasi

Gunakan dua diagram:

1. Diagram struktur pohon:

```text
Values → Root → Domains → Habits/Decisions
```

2. Diagram feedback loop:

```text
Values → Domains → Actions → Logs → Domain Signals → Values Reflection
```

---

## Rekomendasi Struktur Revisi Dokumen

Agar dokumen menjadi siap-implementasi, susun ulang menjadi:

```markdown
# 08 — Konsep Pohon Pertumbuhan LifeTree

> Status: Iterasi 2 / Advanced Visual System
> Canonical constraints: Anti-Guilt, Offline-first, Mobile-first, Accessibility-first

## 1. Prinsip Non-Negotiable
- Pohon tidak pernah mati/layu/mundur
- Defisit = sinyal perhatian, bukan hukuman
- Tidak ada streak punishment
- Semua visual punya label aksesibilitas

## 2. Scope per Fase
- MVP: Tree Vitality Card
- Iterasi 1: Domain aura + insight dialog
- Iterasi 2: Growth Map node-based

## 3. Mapping Konseptual
- Root = Self + Core Values
- Branch = Life Domains
- Leaf = Scheduled Habits
- Flower = Automaticity / stable habit
- Fruit = Decision / milestone

## 4. Data Source
- UserProfiles.coreValues
- UserProfiles.revealedValueScores
- WeeklyPulse / LifeAudit / latestDomainScores
- Habit / HabitLog
- DecisionEntry

## 5. Visual State & Threshold
- Domain score thresholds
- Habit status visual
- Recovery visual
- Unknown/stale state

## 6. Interaction Spec
- Tap / long press / accessibility labels
- Quick-toggle rules
- Dialog routes

## 7. Skin Adaptation
- calm palette per skin
- reduced motion
- color + icon + label

## 8. Implementation Plan
- files to create
- files to modify
- tests

## 9. Copywriting Anti-Guilt
- allowed and banned wording
```

---

## Saran Copy Revisi untuk Bagian Bermasalah

### Sebelum

> Dahan yang mengalami defisit akan tampak layu/kering.

### Sesudah

> Domain dengan skor rendah tidak divisualkan sebagai dahan mati, layu, atau rusak. Untuk menjaga prinsip Anti-Guilt, domain tersebut ditampilkan dengan glow yang lebih lembut, ring perhatian halus, dan label “butuh perhatian”. Tujuannya bukan menghukum, tetapi membantu pengguna melihat area yang mungkin layak diberi ruang minggu ini.

---

### Sebelum

> memastikan bahwa nilai yang kita pilih bukan sekadar niat di atas kertas

### Potensi masalah

Kalimat ini bisa terasa menghakimi, seolah nilai yang belum tampak dalam tindakan adalah palsu.

### Sesudah

> membantu pengguna melihat bagaimana nilai yang dipilih perlahan mulai muncul dalam tindakan kecil sehari-hari, tanpa menilai benar atau salah.

---

## Rekomendasi Implementasi Teknis

Jika konsep ini ingin diimplementasikan, jangan langsung mengganti dashboard utama. Buat sebagai eksperimen terisolasi:

### File baru yang disarankan

```text
app/lib/src/features/dashboard/widgets/growth_map/
  growth_map_widget.dart
  growth_map_painter.dart
  growth_map_node.dart
  growth_map_layout.dart
  growth_map_semantics.dart
```

### Provider/helper baru

```text
app/lib/src/features/dashboard/growth_map_provider.dart
```

Berisi transformasi data mentah menjadi view model:

```dart
class GrowthMapViewModel {
  final RootNode root;
  final List<DomainBranchNode> branches;
  final List<HabitLeafNode> leaves;
  final List<FruitNode> fruits;
}
```

### Test yang perlu dibuat

```text
app/test/growth_map_view_model_test.dart
app/test/growth_map_domain_state_test.dart
app/test/growth_map_accessibility_label_test.dart
```

Test minimal:

1. Domain score rendah menghasilkan state `needsAttention`, bukan `withered`/`dead`.
2. Habit non-daily hanya muncul di hari terjadwal.
3. Decision Journal muncul sebagai fruit, bukan quick-toggle leaf.
4. Recovery Mode tidak mengurangi progress visual.
5. Node punya semantic label yang jelas.

---

## Kesimpulan

Dokumen `08_konsep_pohon_pertumbuhan.md` adalah fondasi konsep visual yang bagus, tetapi belum aman untuk langsung dijadikan instruksi coding. Perlu revisi agar:

1. Selaras dengan Anti-Guilt.
2. Jelas status fasenya.
3. Sinkron dengan dokumen Cermin Nilai.
4. Memiliki data source dan threshold eksplisit.
5. Mobile-first dan accessibility-first.
6. Tidak terlalu gamified/overstimulating.
7. Bisa diterjemahkan menjadi komponen Flutter dan unit test.

Prioritas revisi tertinggi adalah mengganti seluruh bahasa/visual `layu/kering` menjadi state `butuh perhatian` yang tidak menghukum.
