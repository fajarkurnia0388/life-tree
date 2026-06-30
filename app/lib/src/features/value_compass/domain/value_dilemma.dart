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

  const OpenValueQuestion({
    required this.key,
    required this.prompt,
  });
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
    ValueDilemma(
      key: 'kejujuran_vs_harmoni_01',
      prompt: 'Temanmu minta pendapat jujur soal keputusan besar yang sudah tidak bisa diubah. Pendapatmu sebenarnya negatif.',
      optionALabel: 'Jujur meski menyakitkan',
      optionAValueTag: 'Kejujuran',
      optionBLabel: 'Diam demi menjaganya',
      optionBValueTag: 'Harmoni',
      domainTag: 'Hubungan',
    ),
    ValueDilemma(
      key: 'hasil_vs_kepercayaan_01',
      prompt: 'Proyek tim akan gagal total kecuali kamu ambil alih tugas satu rekan tanpa bilang dulu.',
      optionALabel: 'Ambil alih demi hasil',
      optionAValueTag: 'Hasil',
      optionBLabel: 'Jaga kepercayaan',
      optionBValueTag: 'Kepercayaan',
      domainTag: 'Karir',
    ),
    ValueDilemma(
      key: 'privasi_vs_koneksi_01',
      prompt: 'Malam yang tenang sendirian untuk memulihkan energi, atau kumpul bersama orang-orang terdekat meski lelah?',
      optionALabel: 'Sendiri (Privasi)',
      optionAValueTag: 'Privasi',
      optionBLabel: 'Kumpul bersama',
      optionBValueTag: 'Koneksi',
      domainTag: 'Emosi',
    ),
    ValueDilemma(
      key: 'efisiensi_vs_kenyamanan_01',
      prompt: 'Pilih opsi tercepat untuk menyelesaikan tugas meski hasilnya pas-pasan, atau luangkan waktu ekstra demi hasil yang nyaman?',
      optionALabel: 'Tercepat (Efisiensi)',
      optionAValueTag: 'Efisiensi',
      optionBLabel: 'Waktu ekstra (Nyaman)',
      optionBValueTag: 'Kenyamanan',
      domainTag: 'Karir',
    ),
    ValueDilemma(
      key: 'stabilitas_vs_hasil_01',
      prompt: 'Bertahan di rutinitas yang sudah terbukti aman, atau coba pendekatan baru yang berisiko tapi berpotensi hasil lebih besar?',
      optionALabel: 'Rutinitas aman',
      optionAValueTag: 'Stabilitas',
      optionBLabel: 'Pendekatan berisiko',
      optionBValueTag: 'Hasil',
      domainTag: 'Tubuh',
    ),
    ValueDilemma(
      key: 'kebebasan_vs_kepercayaan_01',
      prompt: 'Pegang janji yang sudah kamu buat meski sekarang terasa mengekang, atau batalkan demi kesempatan baru yang lebih bebas?',
      optionALabel: 'Pegang janji',
      optionAValueTag: 'Kepercayaan',
      optionBLabel: 'Batalkan demi bebas',
      optionBValueTag: 'Kebebasan',
      domainTag: 'Hubungan',
    ),
    ValueDilemma(
      key: 'kejujuran_vs_koneksi_01',
      prompt: 'Beritahu temanmu kesalahannya secara terus terang meski berisiko merenggangkan hubungan, atau simpan demi menjaga kedekatan?',
      optionALabel: 'Terus terang',
      optionAValueTag: 'Kejujuran',
      optionBLabel: 'Simpan demi dekat',
      optionBValueTag: 'Koneksi',
      domainTag: 'Hubungan',
    ),
    ValueDilemma(
      key: 'harmoni_vs_privasi_01',
      prompt: 'Hadiri acara keluarga besar demi menjaga keharmonisan meski kamu sangat butuh waktu sendiri, atau izin tidak datang?',
      optionALabel: 'Hadiri (Harmoni)',
      optionAValueTag: 'Harmoni',
      optionBLabel: 'Izin tidak datang',
      optionBValueTag: 'Privasi',
      domainTag: 'Emosi',
    ),
    ValueDilemma(
      key: 'efisiensi_vs_kenyamanan_02',
      prompt: 'Pilih moda transportasi tercepat meski kurang nyaman, atau yang lebih nyaman meski memakan waktu lebih lama?',
      optionALabel: 'Tercepat (Efisiensi)',
      optionAValueTag: 'Efisiensi',
      optionBLabel: 'Lebih nyaman',
      optionBValueTag: 'Kenyamanan',
      domainTag: 'Rekreasi',
    ),
  ];

  static const List<OpenValueQuestion> openQuestions = [
    OpenValueQuestion(
      key: 'open_no_judgment_01',
      prompt: 'Sebutkan satu hal yang akan kamu lakukan hari ini kalau kamu tidak takut dinilai orang lain.',
    ),
    OpenValueQuestion(
      key: 'open_pride_01',
      prompt: 'Kapan terakhir kali kamu merasa benar-benar bangga pada dirimu sendiri? Apa yang terjadi?',
    ),
    OpenValueQuestion(
      key: 'open_regret_01',
      prompt: 'Adakah keputusan kecil minggu ini yang ingin kamu ambil secara berbeda?',
    ),
    OpenValueQuestion(
      key: 'open_energy_01',
      prompt: 'Aktivitas apa yang paling membuatmu merasa "hidup" akhir-akhir ini?',
    ),
  ];

  /// Mengambil set acak untuk satu sesi: [binaryCount] dilema + [openCount] pertanyaan terbuka.
  /// [excludeKeys] berisi key yang sudah dijawab dalam 7 hari terakhir, dihindari jika pool cukup besar.
  static List<dynamic> drawSession({
    int binaryCount = 5,
    int openCount = 2,
    Set<String> excludeKeys = const {},
  }) {
    // Saring dan shuffle binary dilemmas
    final unexcludedBinary = binaryDilemmas.where((d) => !excludeKeys.contains(d.key)).toList()..shuffle();
    final excludedBinary = binaryDilemmas.where((d) => excludeKeys.contains(d.key)).toList()..shuffle();
    final combinedBinary = [...unexcludedBinary, ...excludedBinary];
    final selectedBinary = combinedBinary.take(binaryCount).toList();

    // Saring dan shuffle open questions
    final unexcludedOpen = openQuestions.where((q) => !excludeKeys.contains(q.key)).toList()..shuffle();
    final excludedOpen = openQuestions.where((q) => excludeKeys.contains(q.key)).toList()..shuffle();
    final combinedOpen = [...unexcludedOpen, ...excludedOpen];
    final selectedOpen = combinedOpen.take(openCount).toList();

    return [...selectedBinary, ...selectedOpen];
  }
}
