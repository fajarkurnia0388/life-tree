# Spesifikasi Fitur: Kompas Hidup — Versi Dipilih vs Versi Tersirat ("Cermin Nilai")

> **Status:** Draft siap-implementasi untuk agen coding
> **Versi Skema DB Saat Ini:** 7 → Target: 8
> **Modul Terdampak:** `features/profile/`, `features/reflection/`, `data/local_db/database.dart`
> **Modul Baru:** `features/value_compass/`

---

## 1. Latar Belakang & Definisi Eksplisit

Saat ini **Kompas Hidup** (`life_compass_section.dart`) hanya punya satu bentuk: pengguna memilih sendiri 3 nilai inti dari daftar chip (`coreValues` di tabel `UserProfiles`). Ini punya kelemahan psikologis: orang sering memilih nilai yang **ingin mereka jadi** (aspirational), bukan nilai yang benar-benar tercermin dari **pilihan kecil sehari-hari** mereka.

Fitur ini memperkenalkan **dua sisi Kompas Hidup yang harus dibedakan secara eksplisit** di seluruh kode, UI, dan dokumentasi:

| Istilah | Definisi | Sumber Data | Sifat |
|---|---|---|---|
| **Kompas Hidup — Versi Dipilih** (*Declared*) | Nilai yang pengguna pilih secara sadar lewat chip selector | `UserProfiles.coreValues` (sudah ada) | Top-down, eksplisit, hanya berubah jika pengguna mengedit manual |
| **Kompas Hidup — Versi Tersirat** (*Revealed*) | Nilai yang muncul dari pola jawaban pengguna terhadap dilema nilai ("Cermin Nilai") | `UserProfiles.revealedValueScores` (BARU) | Bottom-up, implisit, terus diperbarui otomatis tiap sesi refleksi baru |

**Prinsip penting:** Versi Tersirat **tidak pernah bisa diedit langsung** oleh pengguna — ia hanya bisa "digeser" secara tidak langsung dengan menjawab lebih banyak dilema. Ini menjaga integritas datanya sebagai cerminan perilaku, bukan deklarasi.

**Insight produk yang dijual ke pengguna:** bukan "mana yang benar", tapi **jarak/selarasnya** antara apa yang kamu *katakan* kamu pegang vs apa yang *pilihan-pilihan kecilmu* tunjukkan. Ini harus dibingkai netral, sesuai filosofi Anti-Guilt aplikasi — lihat §7.

---

## 2. Arsitektur Data

### 2.1 Tabel Baru: `ValueDilemmaResponses`

Menyimpan setiap jawaban individual terhadap dilema/pertanyaan refleksi. Mengikuti pola soft-delete yang sudah dipakai di seluruh tabel lain.

```dart
@DataClassName('ValueDilemmaResponse')
class ValueDilemmaResponses extends Table {
  TextColumn get responseId => text()();
  TextColumn get userId => text()();
  TextColumn get dilemmaKey => text()(); // references static catalog, e.g. 'stabilitas_vs_kebebasan_01'
  TextColumn get chosenValueTag => text().nullable()(); // null jika pertanyaan open-ended
  TextColumn get chosenOptionLabel => text().nullable()(); // 'A' / 'B' / null
  TextColumn get openTextResponse => text().nullable()(); // isi jika open-ended
  DateTimeColumn get answeredAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {responseId};
}
```

### 2.2 Kolom Baru di `UserProfiles`

```dart
// Tambahkan ke class UserProfiles yang sudah ada:
TextColumn get revealedValueScores => text().nullable()(); // JSON: {"Stabilitas": 3, "Kejujuran": 2, ...}
DateTimeColumn get revealedValueLastUpdatedAt => dateTime().nullable()();
```

Pola ini **konsisten** dengan `latestDomainScores` yang sudah ada (JSON string di kolom profil) — jangan buat tabel terpisah untuk skor agregat, cukup cache di profil seperti pola yang sudah berjalan.

### 2.3 Migrasi Schema (v7 → v8)

Tambahkan di `MigrationStrategy.onUpgrade`, mengikuti pola `if (from < N)` yang sudah ada:

```dart
if (from < 8) {
  await m.createTable(valueDilemmaResponses);
  await m.addColumn(userProfiles, userProfiles.revealedValueScores);
  await m.addColumn(userProfiles, userProfiles.revealedValueLastUpdatedAt);
  await customStatement(
    'CREATE INDEX IF NOT EXISTS idx_value_dilemma_user ON value_dilemma_responses (user_id, answered_at DESC);'
  );
}
```

Jangan lupa update `int get schemaVersion => 8;` dan tambahkan index yang sama di blok `onCreate` (untuk instalasi baru).

### 2.4 Integrasi dengan App Reset (Purge DB)

`_resetApplication()` di `profile_dashboard_tab.dart` saat ini menghapus seluruh tabel. **Tabel `ValueDilemmaResponses` wajib ditambahkan ke daftar yang di-purge**, dan kolom `revealedValueScores` otomatis ikut terhapus karena `UserProfiles` di-reset penuh. Jangan sampai data lama "nyangkut" setelah reset.

---

## 3. Katalog Konten Dilema (Starter Set)

### 3.1 Prinsip Desain Konten

- Setiap dilema binary memetakan **2 opsi ke 2 value tag berbeda** — tidak ada opsi "benar/salah".
- Framing dilema **tidak boleh literal soal kematian/kekerasan** (hindari trolley problem mentah) — gunakan skenario kerja/sosial/sehari-hari yang relate ke 6 domain kehidupan yang sudah ada di app.
- Katalog ini **harus mudah ditambah** tanpa mengubah skema DB atau algoritma — idealnya disimpan sebagai `static const List` di Dart (mirip pola `ThinkingMethod.allMethods`), atau lebih baik lagi sebagai asset JSON agar bisa diperluas tanpa rebuild (lihat §8 saran masa depan).
- Sesi refleksi mengambil **5 dilema binary + 2 pertanyaan terbuka secara acak** dari pool, menghindari pengulangan dalam 7 hari terakhir jika memungkinkan.

### 3.2 Master Vocabulary Nilai (v1)

`Stabilitas`, `Kebebasan`, `Kejujuran`, `Harmoni`, `Hasil`, `Kepercayaan`, `Privasi`, `Koneksi`, `Efisiensi`, `Kenyamanan`

### 3.3 Daftar Dilema Binary (Starter — 10 item)

| Key | Prompt | Opsi A → Tag | Opsi B → Tag | Domain Tag (opsional) |
|---|---|---|---|---|
| `stabilitas_vs_kebebasan_01` | Pilih gaji tetap yang aman dan terprediksi, atau penghasilan naik-turun tapi kamu pegang kendali penuh atas waktumu? | Gaji tetap → `Stabilitas` | Kendali waktu → `Kebebasan` | Karir |
| `kejujuran_vs_harmoni_01` | Temanmu minta pendapat jujur soal keputusan besar yang sudah tidak bisa diubah. Pendapatmu sebenarnya negatif. | Jujur meski menyakitkan → `Kejujuran` | Diam demi menjaganya → `Harmoni` | Hubungan |
| `hasil_vs_kepercayaan_01` | Proyek tim akan gagal total kecuali kamu ambil alih tugas satu rekan tanpa bilang dulu. | Ambil alih demi hasil tim → `Hasil` | Biarkan gagal demi menjaga kepercayaan → `Kepercayaan` | Karir |
| `privasi_vs_koneksi_01` | Malam yang tenang sendirian untuk memulihkan energi, atau kumpul bersama orang-orang terdekat meski lelah? | Sendirian → `Privasi` | Kumpul bersama → `Koneksi` | Emosi |
| `efisiensi_vs_kenyamanan_01` | Pilih opsi tercepat untuk menyelesaikan tugas meski hasilnya pas-pasan, atau luangkan waktu ekstra demi hasil yang nyaman? | Tercepat → `Efisiensi` | Hasil nyaman → `Kenyamanan` | Karir |
| `stabilitas_vs_hasil_01` | Bertahan di rutinitas yang sudah terbukti aman, atau coba pendekatan baru yang berisiko tapi berpotensi hasil lebih besar? | Rutinitas aman → `Stabilitas` | Coba hal baru → `Hasil` | Tubuh |
| `kebebasan_vs_kepercayaan_01` | Pegang janji yang sudah kamu buat meski sekarang terasa mengekang, atau batalkan demi kesempatan baru yang lebih bebas? | Pegang janji → `Kepercayaan` | Batalkan demi bebas → `Kebebasan` | Hubungan |
| `kejujuran_vs_koneksi_01` | Beritahu temanmu kesalahannya secara terus terang meski berisiko merenggangkan hubungan, atau simpan demi menjaga kedekatan? | Terus terang → `Kejujuran` | Simpan demi dekat → `Koneksi` | Hubungan |
| `harmoni_vs_privasi_01` | Hadiri acara keluarga besar demi menjaga keharmonisan meski kamu sangat butuh waktu sendiri, atau izin tidak datang? | Hadiri → `Harmoni` | Tidak datang → `Privasi` | Emosi |
| `efisiensi_vs_kenyamanan_02` | Pilih moda transportasi tercepat meski kurang nyaman, atau yang lebih nyaman meski memakan waktu lebih lama? | Tercepat → `Efisiensi` | Nyaman → `Kenyamanan` | Rekreasi |

### 3.4 Daftar Pertanyaan Terbuka (Starter — 4 item)

Tidak punya `valueTag` (tidak dihitung dalam skor) — murni jurnal reflektif ringan, ditampilkan kembali sebagai "memori refleksi" di masa depan jika diperlukan.

| Key | Prompt |
|---|---|
| `open_no_judgment_01` | Sebutkan satu hal yang akan kamu lakukan hari ini kalau kamu tidak takut dinilai orang lain. |
| `open_pride_01` | Kapan terakhir kali kamu merasa benar-benar bangga pada dirimu sendiri? Apa yang terjadi? |
| `open_regret_01` | Adakah keputusan kecil minggu ini yang ingin kamu ambil secara berbeda? |
| `open_energy_01` | Aktivitas apa yang paling membuatmu merasa "hidup" akhir-akhir ini? |

### 3.5 Model Dart untuk Katalog

```dart
// lib/src/features/value_compass/domain/value_dilemma.dart

class ValueDilemma {
  final String key;
  final String prompt;
  final String optionALabel;
  final String optionAValueTag;
  final String optionBLabel;
  final String optionBValueTag;
  final String? domainTag;

  const ValueDilemma({
    required this.key,
    required this.prompt,
    required this.optionALabel,
    required this.optionAValueTag,
    required this.optionBLabel,
    required this.optionBValueTag,
    this.domainTag,
  });
}

class OpenValueQuestion {
  final String key;
  final String prompt;
  const OpenValueQuestion({required this.key, required this.prompt});
}

class ValueDilemmaPool {
  ValueDilemmaPool._();

  static const List<ValueDilemma> binaryDilemmas = [
    ValueDilemma(
      key: 'stabilitas_vs_kebebasan_01',
      prompt: 'Pilih gaji tetap yang aman dan terprediksi, atau penghasilan naik-turun tapi kamu pegang kendali penuh atas waktumu?',
      optionALabel: 'Gaji tetap & aman',
      optionAValueTag: 'Stabilitas',
      optionBLabel: 'Kendali penuh waktu',
      optionBValueTag: 'Kebebasan',
      domainTag: 'Karir',
    ),
    // ... 9 item lainnya, lihat tabel §3.3
  ];

  static const List<OpenValueQuestion> openQuestions = [
    OpenValueQuestion(
      key: 'open_no_judgment_01',
      prompt: 'Sebutkan satu hal yang akan kamu lakukan hari ini kalau kamu tidak takut dinilai orang lain.',
    ),
    // ... 3 item lainnya, lihat tabel §3.4
  ];

  /// Mengambil set acak untuk satu sesi: [binaryCount] dilema + [openCount] pertanyaan terbuka.
  /// [excludeKeys] berisi key yang sudah dijawab dalam 7 hari terakhir, dihindari jika pool cukup besar.
  static List<dynamic> drawSession({
    int binaryCount = 5,
    int openCount = 2,
    Set<String> excludeKeys = const {},
  }) {
    // Implementasi: shuffle pool, prioritaskan yang belum di excludeKeys,
    // fallback ke seluruh pool jika kandidat tidak cukup.
    throw UnimplementedError();
  }
}
```

---

## 4. Algoritma Agregasi Nilai Tersirat

### 4.1 Pendekatan v1 — Tally Sederhana (Bukan Decay)

Untuk v1, **gunakan hitungan frekuensi sederhana**, bukan exponential decay seperti `weightedDoneScore` pada Habit. Alasan: data masih sedikit di awal, dan transparansi/explainability lebih penting daripada kecanggihan algoritma untuk fitur reflektif seperti ini. Decay berbasis waktu bisa jadi peningkatan P2 (lihat §8).

```dart
// lib/src/features/value_compass/services/value_compass_service.dart

class ValueCompassService {
  final AppDatabase _db;
  ValueCompassService(this._db);

  /// Catat satu jawaban binary, lalu hitung ulang & cache skor tersirat.
  Future<void> recordBinaryResponse({
    required String userId,
    required String dilemmaKey,
    required String chosenOptionLabel, // 'A' atau 'B'
    required String chosenValueTag,
  }) async {
    final responseId = const Uuid().v4();
    await _db.into(_db.valueDilemmaResponses).insert(
      ValueDilemmaResponsesCompanion.insert(
        responseId: responseId,
        userId: userId,
        dilemmaKey: dilemmaKey,
        chosenValueTag: drift.Value(chosenValueTag),
        chosenOptionLabel: drift.Value(chosenOptionLabel),
        answeredAt: DateTime.now(),
      ),
    );
    await _recomputeRevealedValues(userId);
  }

  Future<void> recordOpenResponse({
    required String userId,
    required String dilemmaKey,
    required String text,
  }) async {
    final responseId = const Uuid().v4();
    await _db.into(_db.valueDilemmaResponses).insert(
      ValueDilemmaResponsesCompanion.insert(
        responseId: responseId,
        userId: userId,
        dilemmaKey: dilemmaKey,
        openTextResponse: drift.Value(text),
        answeredAt: DateTime.now(),
      ),
    );
    // Tidak memengaruhi skor — tidak perlu recompute.
  }

  /// Hitung ulang tally lengkap dari seluruh respons (bukan incremental).
  /// Dataset kecil (puluhan-ratusan baris per user) sehingga full-scan aman.
  Future<void> _recomputeRevealedValues(String userId) async {
    final responses = await (_db.select(_db.valueDilemmaResponses)
          ..where((tbl) =>
              tbl.userId.equals(userId) &
              tbl.deletedAt.isNull() &
              tbl.chosenValueTag.isNotNull()))
        .get();

    final tally = <String, int>{};
    for (final r in responses) {
      final tag = r.chosenValueTag!;
      tally[tag] = (tally[tag] ?? 0) + 1;
    }

    await (_db.update(_db.userProfiles)..where((tbl) => tbl.userId.equals(userId)))
        .write(UserProfilesCompanion(
          revealedValueScores: drift.Value(jsonEncode(tally)),
          revealedValueLastUpdatedAt: drift.Value(DateTime.now()),
        ));
  }

  /// Ambil top-N nilai tersirat. Mengembalikan list kosong jika data
  /// belum cukup (minResponses belum tercapai) — JANGAN tampilkan
  /// insight prematur ke pengguna.
  Future<List<String>> getTopRevealedValues({
    required UserProfile profile,
    int topN = 3,
    int minResponses = 5,
  }) async {
    if (profile.revealedValueScores == null) return [];
    final Map<String, dynamic> raw = jsonDecode(profile.revealedValueScores!);
    final totalResponses = raw.values.fold<int>(0, (sum, v) => sum + (v as int));
    if (totalResponses < minResponses) return [];

    final entries = raw.entries.toList()
      ..sort((a, b) {
        final cmp = (b.value as int).compareTo(a.value as int);
        if (cmp != 0) return cmp;
        return a.key.compareTo(b.key); // tie-break alfabetis, deterministik
      });
    return entries.take(topN).map((e) => e.key).toList();
  }
}

final valueCompassServiceProvider = Provider<ValueCompassService>((ref) {
  return ValueCompassService(ref.watch(dbProvider));
});
```

### 4.2 Ambang Batas Minimum (`minResponses`)

**Wajib diterapkan**: jangan tampilkan "Kompas Tersirat" sampai pengguna menjawab minimal **5 dilema binary**. Di bawah ambang ini, tampilkan state "Belum cukup data" (lihat §5.3). Ini mencegah insight yang prematur/tidak akurat — penting untuk kepercayaan pengguna di aplikasi wellness.

---

## 5. Rancangan UI/UX

### 5.1 Entry Point — Reflection Tab

Tambahkan card baru di `reflection_dashboard_tab.dart`, di posisi atas (paling relevan untuk fitur reflektif harian):

```dart
{
  'title': 'Cermin Nilai 🪞',
  'desc': 'Jawab dilema ringan untuk melihat nilai apa yang sebenarnya kamu pegang lewat pilihan kecilmu.',
  'route': '/value-mirror',
  'icon': Icons.balance_rounded,
  'color': CalmTheme.secondaryBlue,
}
```

### 5.2 Alur Sesi — `/value-mirror`

Struktur baru di `features/value_compass/`:

```
features/value_compass/
├── domain/
│   └── value_dilemma.dart          (katalog statis, lihat §3.5)
├── services/
│   └── value_compass_service.dart  (lihat §4.1)
├── value_mirror_intro_view.dart    (penjelasan singkat + tombol Mulai)
├── value_mirror_session_view.dart  (PageView kartu, mirip pola onboarding_view.dart)
└── widgets/
    ├── value_dilemma_card.dart     (kartu binary: 2 tombol pilihan)
    ├── value_open_question_card.dart (kartu open-ended: TextField)
    └── value_mirror_summary_sheet.dart (bottom sheet hasil akhir sesi)
```

**`value_mirror_intro_view.dart`:**
- Ikon 🪞 besar, judul "Cermin Nilai"
- Teks: "Tidak ada jawaban benar atau salah. Ini bukan tes — ini cermin. ~2 menit, 7 pertanyaan."
- Tombol "Mulai" → push ke `value_mirror_session_view.dart`

**`value_mirror_session_view.dart`:**
- Pola sama seperti `OnboardingView`: `PageController` + indikator progres pill di atas + tombol Lanjut/Kembali di bawah.
- Setiap halaman = satu `ValueDilemmaCard` atau `ValueOpenQuestionCard`.
- `ValueDilemmaCard`: dua tombol besar (label opsi A & B) bertumpuk vertikal — saat ditekan langsung lanjut ke kartu berikutnya (tanpa perlu tombol "Lanjut" terpisah, untuk mempercepat alur).
- `ValueOpenQuestionCard`: `TextField` multiline + tombol "Lanjut" (boleh dikosongkan/skip).
- Setelah kartu terakhir → panggil `recordBinaryResponse`/`recordOpenResponse` untuk setiap jawaban yang terkumpul (bisa batch di akhir atau on-the-fly per kartu — disarankan **on-the-fly** agar progres tidak hilang jika app force-close di tengah sesi), lalu tampilkan `value_mirror_summary_sheet.dart`.

**`value_mirror_summary_sheet.dart`:**
- Jika `getTopRevealedValues()` masih kosong (belum capai `minResponses`): tampilkan "Teruskan beberapa sesi lagi untuk mulai melihat pola dirimu."
- Jika sudah cukup data: tampilkan 2-3 chip nilai dominan dengan framing netral: *"Belakangan ini, pilihan-pilihanmu condong ke: **Stabilitas**, **Kejujuran**"*
- Tombol "Lihat Kompas Hidupku" → navigasi ke Profile tab (`context.go('/')` lalu set tab index, atau cukup `context.push` ke route profile jika tersedia terpisah).
- Tombol "Selesai" → tutup sheet, kembali ke Reflection tab.

### 5.3 Restrukturisasi `LifeCompassSection` (Profile Tab)

`life_compass_section.dart` perlu dipecah jadi dua sub-blok di dalam card yang sama, dengan judul section diperjelas:

```
┌─────────────────────────────────────────┐
│  🧭 Kompas Hidup                          │
│  Dua sisi: yang kamu pilih sadar, dan    │
│  yang tercermin dari pilihan kecilmu.    │
│                                           │
│  ── Versi Dipilih ──────────── [✏️ Edit] │
│  [Disiplin] [Kesehatan] [Keluarga]       │
│                                           │
│  ── Versi Tersirat ───────────────────── │
│  [Stabilitas] [Kejujuran] [Koneksi]      │
│  Diperbarui dari 8 refleksi · 3 hari lalu│
│                                           │
│         [ Lihat Perbandingan → ]         │
└─────────────────────────────────────────┘
```

- **Versi Dipilih**: UI lama tetap (chip + tombol edit), hanya label di-rename eksplisit.
- **Versi Tersirat**: chip read-only (tanpa tombol edit), warna sedikit berbeda (mis. outline bukan filled, untuk menandakan "ini bukan klaim, ini observasi"). Jika data belum cukup: tampilkan tombol "Mulai Cermin Nilai" yang push ke `/value-mirror`.
- Tombol **"Lihat Perbandingan"** hanya muncul jika kedua sisi (Dipilih DAN Tersirat) sudah terisi. Membuka `CompassComparisonDialog`.

### 5.4 `CompassComparisonDialog` (Baru)

File: `features/profile/widgets/compass_comparison_dialog.dart`

Logika murni (testable tanpa DB):

```dart
class CompassComparisonResult {
  final List<String> aligned;       // muncul di kedua sisi
  final List<String> declaredOnly;  // hanya di Versi Dipilih
  final List<String> revealedOnly;  // hanya di Versi Tersirat

  const CompassComparisonResult({
    required this.aligned,
    required this.declaredOnly,
    required this.revealedOnly,
  });
}

CompassComparisonResult compareCompass({
  required List<String> declaredValues,
  required List<String> revealedValues,
}) {
  final declaredSet = declaredValues.toSet();
  final revealedSet = revealedValues.toSet();
  return CompassComparisonResult(
    aligned: declaredSet.intersection(revealedSet).toList(),
    declaredOnly: declaredSet.difference(revealedSet).toList(),
    revealedOnly: revealedSet.difference(declaredSet).toList(),
  );
}
```

UI dialog menampilkan 3 kelompok dengan **copy netral** (lihat §7 untuk daftar kata terlarang):

1. **"Selaras ✅"** (aligned) — "Nilai-nilai ini konsisten antara yang kamu pilih dan yang tercermin dari tindakanmu."
2. **"Baru di Niat 🌱"** (declaredOnly) — "Kamu memilih ini sebagai nilai penting, tapi pola pilihanmu belum banyak mencerminkannya. Wajar — nilai butuh waktu untuk terlihat dalam tindakan kecil."
3. **"Pola yang Muncul 🔍"** (revealedOnly) — "Pilihanmu menunjukkan kecenderungan ke arah ini, meski belum kamu tuliskan sebagai nilai inti. Mungkin ini layak dipertimbangkan?" + tombol kecil "Tambahkan ke Versi Dipilih" yang membuka dialog edit Core Values yang sudah ada, pre-filled dengan nilai ini.

---

## 6. Provider & State Management

Mengikuti pola Riverpod yang sudah konsisten di codebase:

```dart
// Stream/Future provider untuk top revealed values, dependent pada profile
final revealedValuesProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.watch(valueCompassServiceProvider);
  final db = ref.watch(dbProvider);
  final profiles = await db.select(db.userProfiles).get();
  if (profiles.isEmpty) return [];
  return service.getTopRevealedValues(profile: profiles.first);
});

// Invalidate setelah setiap sesi Cermin Nilai selesai:
// ref.invalidate(revealedValuesProvider);
// ref.invalidate(dashboardDataProvider); // jika ingin radar/profile ikut refresh
```

---

## 7. Pedoman Bahasa (Anti-Guilt Framing) — WAJIB DIPATUHI

Karena ini fitur reflektif yang menyentuh identitas/nilai pribadi, bahasa di UI **tidak boleh**:

❌ Dilarang: "kontradiksi", "tidak konsisten", "munafik", "gagal", "salah", "seharusnya", "kamu tidak benar-benar peduli soal..."

✅ Gunakan: "perbedaan", "pola", "belum terlihat dalam tindakan", "mungkin layak dipertimbangkan", "wajar", "ini observasi, bukan penilaian"

Setiap copy baru yang ditulis untuk fitur ini harus melewati cek ini sebelum di-merge. Tambahkan komentar di kode pada bagian string UI sensitif: `// ANTI-GUILT: jangan gunakan kata menghakimi di sini`.

---

## 8. Saran Pengembangan Lanjutan (Di Luar Scope v1)

Tidak perlu dikerjakan sekarang, tapi catat di backlog (`docs/05_implementation_status.md`):

| Item | Deskripsi |
|---|---|
| Decay berbasis waktu | Ganti tally sederhana dengan exponential weighting (pola sama seperti `weightedDoneScore` di Habit) supaya jawaban lama berangsur "memudar" |
| Sinyal perilaku tambahan | Selain dilema, masukkan juga data riil (domain habit mana yang paling konsisten dikerjakan) sebagai sinyal tambahan ke Versi Tersirat — bukan hanya dari kuis |
| Katalog dilema sebagai asset JSON | Pindahkan `ValueDilemmaPool` dari Dart statis ke `assets/value_dilemmas.json` agar konten bisa diperluas tanpa rebuild aplikasi |
| Riwayat "Memori Refleksi" | Tampilkan kembali jawaban open-ended lama sebagai semacam jurnal nilai, bisa di-scroll di Profile |
| Notifikasi lembut mingguan | Ingatkan sesi baru tersedia (mengikuti cadence Weekly Pulse), opsional, bisa di-skip tanpa konsekuensi |

---

## 9. Checklist Unit Test

Tambahkan file test baru mengikuti konvensi penamaan yang sudah ada di `app/test/`:

- `value_compass_service_test.dart`
  - Insert binary response → tally bertambah benar di `revealedValueScores`
  - Insert open response → TIDAK memengaruhi tally
  - `getTopRevealedValues` mengembalikan `[]` jika respons < `minResponses`
  - `getTopRevealedValues` mengembalikan top-N terurut benar, tie-break alfabetis
  - Soft-deleted response (`deletedAt` terisi) tidak ikut dihitung dalam tally
- `compass_comparison_test.dart`
  - `compareCompass()` menghasilkan `aligned`/`declaredOnly`/`revealedOnly` yang benar untuk berbagai kombinasi himpunan
  - Kasus edge: kedua list kosong, salah satu list kosong, seluruhnya overlap

---

## 10. Ringkasan File yang Dibuat/Diubah

**Baru:**
- `app/lib/src/features/value_compass/domain/value_dilemma.dart`
- `app/lib/src/features/value_compass/services/value_compass_service.dart`
- `app/lib/src/features/value_compass/value_mirror_intro_view.dart`
- `app/lib/src/features/value_compass/value_mirror_session_view.dart`
- `app/lib/src/features/value_compass/widgets/value_dilemma_card.dart`
- `app/lib/src/features/value_compass/widgets/value_open_question_card.dart`
- `app/lib/src/features/value_compass/widgets/value_mirror_summary_sheet.dart`
- `app/lib/src/features/profile/widgets/compass_comparison_dialog.dart`
- `app/test/value_compass_service_test.dart`
- `app/test/compass_comparison_test.dart`

**Diubah:**
- `app/lib/src/data/local_db/database.dart` (tabel baru + kolom baru + migrasi v7→v8)
- `app/lib/src/core/routing/router.dart` (tambah route `/value-mirror`)
- `app/lib/src/features/reflection/reflection_dashboard_tab.dart` (tambah card entry)
- `app/lib/src/features/profile/widgets/life_compass_section.dart` (restrukturisasi 2 sub-blok)
- `app/lib/src/features/profile/profile_dashboard_tab.dart` (pastikan `_resetApplication` ikut purge tabel baru)
- `docs/05_implementation_status.md` (tambah baris status fitur ini)
