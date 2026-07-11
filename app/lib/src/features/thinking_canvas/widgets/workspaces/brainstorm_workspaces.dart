import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/i18n/daoji_text_key.dart';
import '../../../../core/i18n/daoji_text_resolver.dart';
import '../../../../core/i18n/daoji_vocabulary_level.dart';

// ==========================================
// 1. RAPID BRAINSTORM WORKSPACE (ANIMATED BUBBLES)
// ==========================================
class RapidBrainstormWorkspace extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const RapidBrainstormWorkspace({super.key, required this.onChanged});

  @override
  State<RapidBrainstormWorkspace> createState() =>
      _RapidBrainstormWorkspaceState();
}

class _RapidBrainstormWorkspaceState extends State<RapidBrainstormWorkspace> {
  final List<String> _ideas = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final TextEditingController _inputController = TextEditingController();

  void _notifyChanges() {
    final buffer = StringBuffer();
    buffer.writeln('Hasil Brainstorming Cepat (Rapid Logger):');
    for (int i = 0; i < _ideas.length; i++) {
      buffer.writeln('${i + 1}. ${_ideas[i]}');
    }
    widget.onChanged(buffer.toString());
  }

  void _submitIdea() {
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      _ideas.insert(0, text);
      _listKey.currentState?.insertItem(
        0,
        duration: const Duration(milliseconds: 350),
      );
      _inputController.clear();
      _notifyChanges();
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DaojiText.resolve(
            DaojiTextKey.rapidBrainstormTitle,
            DaojiVocabularyLevel.mortal,
          ),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _inputController,
          decoration: InputDecoration(
            labelText: DaojiText.resolve(
              DaojiTextKey.rapidBrainstormHint,
              DaojiVocabularyLevel.mortal,
            ),
            hintText: DaojiText.resolve(
              DaojiTextKey.rapidBrainstormHint,
              DaojiVocabularyLevel.mortal,
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle_rounded),
              tooltip: DaojiText.resolve(
                DaojiTextKey.rapidBrainstormAddTooltip,
                DaojiVocabularyLevel.mortal,
              ),
              onPressed: _submitIdea,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onSubmitted: (_) => _submitIdea(),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DaojiText.resolve(
                DaojiTextKey.rapidBrainstormQuantity,
                DaojiVocabularyLevel.mortal,
                params: {'count': _ideas.length},
              ),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            if (_ideas.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() {
                    _ideas.clear();
                  });
                  _notifyChanges();
                },
                child: Text(
                  DaojiText.resolve(
                    DaojiTextKey.rapidBrainstormReset,
                    DaojiVocabularyLevel.mortal,
                  ),
                  style: const TextStyle(color: Colors.redAccent, fontSize: 11),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 120,
          child: AnimatedList(
            key: _listKey,
            initialItemCount: _ideas.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index, animation) {
              final idea = _ideas[index];
              return SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0.0, 1.0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.elasticOut,
                      ),
                    ),
                child: ScaleTransition(
                  scale: animation,
                    child: Container(
                    constraints: const BoxConstraints(maxWidth: 160),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 6.0,
                      vertical: 8.0,
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.08,
                          ),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            idea,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _ideas.removeAt(index);
                            });
                            _listKey.currentState?.removeItem(
                              index,
                              (context, animation) => Container(),
                            );
                            _notifyChanges();
                          },
                          child: const Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 2. QUESTION STORM WORKSPACE (QUESTION LIST & STARS)
// ==========================================
class QuestionStormWorkspace extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const QuestionStormWorkspace({super.key, required this.onChanged});

  @override
  State<QuestionStormWorkspace> createState() => _QuestionStormWorkspaceState();
}

class _QuestionStormWorkspaceState extends State<QuestionStormWorkspace> {
  final List<Map<String, dynamic>> _questions = [];
  final TextEditingController _inputController = TextEditingController();

  void _notifyChanges() {
    final buffer = StringBuffer();
    buffer.writeln('Question Storming List:');
    for (var q in _questions) {
      final star = q['starred'] == true ? ' ⭐️ (PRIORITAS)' : '';
      buffer.writeln('- ${q['text']}$star');
    }
    widget.onChanged(buffer.toString());
  }

  void _submitQuestion() {
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _questions.add({'text': text, 'starred': false});
      });
      _inputController.clear();
      _notifyChanges();
    }
  }

  void _toggleStar(int index) {
    final currentStarredCount = _questions
        .where((q) => q['starred'] == true)
        .length;
    final isCurrentlyStarred = _questions[index]['starred'] == true;

    if (!isCurrentlyStarred && currentStarredCount >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            DaojiText.resolve(
              DaojiTextKey.questionStormMaxPriority,
              DaojiVocabularyLevel.mortal,
            ),
          ),
        ),
      );
      return;
    }

    setState(() {
      _questions[index]['starred'] = !isCurrentlyStarred;
    });
    _notifyChanges();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final starredCount = _questions.where((q) => q['starred'] == true).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DaojiText.resolve(
            DaojiTextKey.questionStormTitle,
            DaojiVocabularyLevel.mortal,
          ),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _inputController,
          decoration: InputDecoration(
            labelText: DaojiText.resolve(
              DaojiTextKey.questionStormHint,
              DaojiVocabularyLevel.mortal,
            ),
            hintText: DaojiText.resolve(
              DaojiTextKey.questionStormHint,
              DaojiVocabularyLevel.mortal,
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle_rounded),
              tooltip: DaojiText.resolve(
                DaojiTextKey.questionStormAddTooltip,
                DaojiVocabularyLevel.mortal,
              ),
              onPressed: _submitQuestion,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onSubmitted: (_) => _submitQuestion(),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DaojiText.resolve(
                DaojiTextKey.questionStormStats,
                DaojiVocabularyLevel.mortal,
                params: {'total': _questions.length, 'starred': starredCount},
              ),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _questions.length,
          itemBuilder: (context, index) {
            final q = _questions[index];
            final isStarred = q['starred'] == true;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isStarred
                      ? Colors.amber
                      : theme.colorScheme.onSurface.withValues(alpha: 0.08),
                  width: isStarred ? 2 : 1,
                ),
              ),
              child: ListTile(
                title: Text(q['text'], style: const TextStyle(fontSize: 13)),
                trailing: GestureDetector(
                  onTap: () => _toggleStar(index),
                  child: AnimatedScale(
                    scale: isStarred ? 1.25 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.bounceOut,
                    child: Icon(
                      isStarred
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: isStarred ? Colors.amber : Colors.grey,
                    ),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 2,
                ),
                dense: true,
              ),
            );
          },
        ),
      ],
    );
  }
}

// ==========================================
// 3. RANDOM WORD WORKSPACE
// ==========================================
class RandomWordWorkspace extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const RandomWordWorkspace({super.key, required this.onChanged});

  @override
  State<RandomWordWorkspace> createState() => _RandomWordWorkspaceState();
}

class _RandomWordWorkspaceState extends State<RandomWordWorkspace> {
  final List<String> _words = const [
    'Jembatan',
    'Awan',
    'Kunci',
    'Magnet',
    'Kepompong',
    'Lensa',
    'Jaring',
    'Kompas',
    'Cermin',
    'Benih',
    'Sarang',
    'Jangkar',
    'Roda',
    'Lentera',
    'Garam',
    'Pahat',
    'Pasang',
    'Surut',
    'Rantai',
    'Sayap',
    'Pondasi',
    'Katalis',
    'Radar',
    'Teropong',
    'Filter',
    'Gema',
    'Kristal',
    'Saringan',
    'Peta',
    'Gembok',
  ];

  final Map<String, String> _wordHints = const {
    'Jembatan':
        'Bagaimana Anda bisa menghubungkan dua area/ide yang sebelumnya terpisah?',
    'Awan':
        'Bagaimana jika solusi Anda bisa diakses secara bebas, melayang, atau berubah bentuk?',
    'Kunci':
        'Bagaimana cara membuka sumbat/hambatan terbesar dalam masalah Anda?',
    'Magnet':
        'Bagaimana cara menarik orang, sumber daya, atau perhatian secara natural?',
    'Kepompong':
        'Apakah solusi Anda membutuhkan fase proteksi atau transformasi tersembunyi terlebih dahulu?',
    'Lensa':
        'Bagaimana cara memperbesar detail terkecil, atau melihat masalah dari sudut pandang makro?',
  };

  String? _currentWord;
  final TextEditingController _notesController = TextEditingController();

  void _generateWord() {
    final rng = Random();
    final word = _words[rng.nextInt(_words.length)];
    setState(() {
      _currentWord = word;
    });
    _notifyChanges();
  }

  void _notifyChanges() {
    final hint =
        _wordHints[_currentWord] ??
        'Gunakan analogi kata ini untuk memecahkan hambatan berpikir Anda.';
    final buffer = StringBuffer();
    buffer.writeln('Asosiasi Kata Acak (Random Word):');
    if (_currentWord != null) {
      buffer.writeln('- Kata terpilih: $_currentWord');
      buffer.writeln('- Analogi pemicu: $hint');
    }
    buffer.writeln('- Catatan Ide: ${_notesController.text.trim()}');
    widget.onChanged(buffer.toString());
  }

  @override
  void initState() {
    super.initState();
    _notesController.addListener(_notifyChanges);
  }

  @override
  void dispose() {
    _notesController.removeListener(_notifyChanges);
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hint =
        _wordHints[_currentWord] ??
        'Gunakan analogi kata ini untuk memecahkan hambatan berpikir Anda.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '4. Eksplorasi Asosiasi Kata Acak',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              if (_currentWord != null) ...[
                Text(
                  _currentWord!,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  hint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ] else ...[
                const Icon(
                  Icons.help_outline_rounded,
                  size: 40,
                  color: Colors.grey,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tekan tombol di bawah untuk menarik kata acak inspiratif!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _generateWord,
                icon: const Icon(Icons.casino_rounded),
                label: const Text('Dapatkan Kata Acak 🎲'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _notesController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Bagaimana kata ini memicu ide baru Anda?',
            hintText: 'Tuliskan asosiasi atau analogi ide Anda di sini...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Harap tuliskan ide atau asosiasi Anda';
            }
            return null;
          },
        ),
      ],
    );
  }
}

// ==========================================
// 4. ROLE STORMING WORKSPACE
// ==========================================
class PersonaModel {
  final String name;
  final String mindset;
  final String avatar;
  final String detailedDescription;

  const PersonaModel({
    required this.name,
    required this.mindset,
    required this.avatar,
    required this.detailedDescription,
  });
}

class PersonaPackage {
  final String id;
  final String title;
  final String desc;
  final bool isPremium;
  final List<PersonaModel> personas;

  const PersonaPackage({
    required this.id,
    required this.title,
    required this.desc,
    required this.isPremium,
    required this.personas,
  });

  static const List<PersonaPackage> library = [
    PersonaPackage(
      id: 'universal',
      title: 'Universal Archetypes (Umum)',
      desc:
          'Set tipe berpikir kognitif universal yang sangat praktis untuk memecahkan segala hambatan hidup.',
      isPremium: false,
      personas: [
        PersonaModel(
          name: 'Sang Empatis',
          mindset:
              'Melihat dari kacamata perasaan orang lain yang terdampak. Bagaimana mengurangi gesekan emosional dan memberi kedamaian?',
          avatar: '🤝',
          detailedDescription:
              'Sang Empatis menaruh perhatian penuh pada dimensi kemanusiaan, kenyamanan emosional, dan dampak sosial. Dia selalu memikirkan bagaimana perasaan orang yang menggunakan atau terkena dampak dari solusi ini.\n\n🛡️ Aturan Berpikir:\n- Utamakan keselamatan psikologis, kemudahan interaksi, dan inklusivitas.\n- Kurangi gesekan emosional (frustrasi, kebingungan, kecemasan) di setiap titik sentuh.\n\n❓ Pertanyaan Kunci:\n- Apakah solusi ini melukai perasaan atau mendiskriminasi seseorang?\n- Bagaimana kita bisa membangun kedekatan emosional dan empati dengan pengguna?\n- Bagaimana cara membuat pengguna merasa sangat dihargai dan aman sejak detik pertama?',
        ),
        PersonaModel(
          name: 'Sang Skeptis',
          mindset:
              'Mencari asumsi yang salah, cacat logika, dan apa saja yang bisa berjalan buruk dari ide ini.',
          avatar: '🔎',
          detailedDescription:
              'Sang Skeptis berperan sebagai Devil\'s Advocate (penentang ide). Tugas utamanya adalah meragukan segala hal, berasumsi bahwa rencana ini pasti gagal, dan mencari semua lubang atau cacat logika di dalamnya.\n\n🛡️ Aturan Berpikir:\n- Jangan menerima klaim atau asumsi tanpa bukti nyata.\n- Anggap kondisi terburuk (Murphy\'s Law) pasti akan terjadi jika dibiarkan tanpa mitigasi.\n\n❓ Pertanyaan Kunci:\n- Asumsi apa saja yang belum terbukti atau mengandung bias subjektif di sini?\n- Di mana letak kegagalan sistem paling fatal jika rencana ini dieksekusi hari ini?\n- Apa rencana cadangan kita jika server mati, pasar hancur, atau user membenci fitur ini?',
        ),
        PersonaModel(
          name: 'Sang Minimalis',
          mindset:
              'Menerapkan prinsip Pareto 80/20. Solusi apa yang paling sederhana, membuang kompleksitas tak perlu?',
          avatar: '🍃',
          detailedDescription:
              'Sang Minimalis menganut filosofi \'Less is More\' dan hukum Pareto 80/20. Dia membenci fitur berlebihan (feature creep), opsi yang membingungkan, dan kompleksitas alur kerja.\n\n🛡️ Aturan Berpikir:\n- Sederhanakan alur hingga ke titik yang tidak bisa dikurangi lagi tanpa merusak fungsi inti.\n- Pangkas 80% hal tidak krusial dan fokus 100% pada 20% inti yang mendatangkan nilai terbesar.\n\n❓ Pertanyaan Kunci:\n- Apa satu-satunya elemen paling bernilai and esensial di dalam solusi ini?\n- Apa yang bisa kita hapus sepenuhnya tanpa mengurangi kegunaan utama?\n- Bagaimana cara agar solusi ini bekerja hanya dalam sekali klik atau langkah?',
        ),
        PersonaModel(
          name: 'Sang Futuris',
          mindset:
              'Menganalisis dampak jangka panjang ke depan. Apa konsekuensinya dalam 10 hari, 10 bulan, dan 10 tahun (Prinsip 10/10/10)?',
          avatar: '⏳',
          detailedDescription:
              'Sang Futuris memikirkan rantai efek jangka panjang (second-order effects). Dia tidak tertarik pada hasil instan hari ini saja, melainkan dampak kelangsungan di masa depan menggunakan aturan 10/10/10.\n\n🛡️ Aturan Berpikir:\n- Lihat konsekuensi dari konsekuensi (efek domino masa depan).\n- Pastikan solusi berkelanjutan dan tidak menciptakan utang teknis atau moral di kemudian hari.\n\n❓ Pertanyaan Kunci:\n- Apa akibat langsung keputusan ini dalam 10 hari ke depan?\n- Bagaimana keadaan dan tantangannya dalam 10 bulan mendatang?\n- Bagaimana posisi dan dampaknya dalam 10 tahun ke depan? Apakah ini berkelanjutan?',
        ),
      ],
    ),
    PersonaPackage(
      id: 'business',
      title: 'Bisnis & Produk 👑',
      desc:
          'Set persona eksternal untuk menguji kelayakan pasar, profitabilitas, dan kenyamanan pengguna.',
      isPremium: true,
      personas: [
        PersonaModel(
          name: 'Pelanggan Cerewet',
          mindset:
              'Mencari-cari keluhan penggunaan, kerepotan kecil, dan alasan mengapa ia enggan membayar solusi ini.',
          avatar: '🤬',
          detailedDescription:
              'Pelanggan Cerewet mewakili pengguna akhir yang tidak sabaran, mudah bingung, mudah menyerah, dan sangat sensitif terhadap biaya atau waktu yang dihabiskan.\n\n🛡️ Aturan Berpikir:\n- Abaikan keindahan teknologi di belakang layar, fokus hanya pada kenyamanan instan.\n- Asumsikan pengguna memiliki waktu perhatian (attention span) yang sangat pendek dan malas membaca panduan.\n\n❓ Pertanyaan Kunci:\n- Mengapa saya harus repot-repot mendaftar dan menggunakan aplikasi ini?\n- Mengapa alur pendaftaran, pembayaran, atau navigasi ini sangat menyulitkan saya?\n- Jika ada masalah kecil, apakah saya langsung ingin menutup aplikasi ini?',
        ),
        PersonaModel(
          name: 'Investor Kejam',
          mindset:
              'Menghitung efisiensi alokasi dana dan kelangsungan modal. Bagaimana cara solusi ini mencetak profit berlipat?',
          avatar: '💰',
          detailedDescription:
              'Investor Kejam memandang ide murni dari kacamata angka, matematika bisnis, efisiensi alokasi modal, dan pengembalian investasi (ROI).\n\n🛡️ Aturan Berpikir:\n- Cari kejelasan model bisnis dan aliran pendapatan (monetisasi).\n- Tolak proyek idealis tanpa rencana skalabilitas ekonomi yang masuk akal.\n\n❓ Pertanyaan Kunci:\n- Berapa biaya akuisisi pengguna (CAC) dan nilai hidup pengguna (LTV)?\n- Kapan proyek ini mencapai titik impas (break-even point)?\n- Di mana potensi kebocoran anggaran terbesar yang harus dipangkas?',
        ),
        PersonaModel(
          name: 'Kompetitor Licik',
          mindset:
              'Menganalisis cara pesaing akan meniru ide Anda, menyerang kelemahan Anda, atau mencuri audiens Anda.',
          avatar: '🦊',
          detailedDescription:
              'Kompetitor Licik memikirkan bagaimana cara merebut pangsa pasar Anda, memplagiasi fitur Anda secara legal dengan biaya lebih murah, atau membalikkan keunggulan kompetitif Anda.\n\n🛡️ Aturan Berpikir:\n- Cari kelemahan pemasaran, operasional, atau hukum Anda.\n- Pikirkan cara memotong harga atau menawarkan fitur serupa secara gratis untuk merusak posisi Anda.\n\n❓ Pertanyaan Kunci:\n- Apa keunikan produk ini yang tidak bisa kami tiru dalam waktu 2 minggu?\n- Bagaimana cara merebut basis pengguna mereka dengan kampanye pemasaran tandingan?\n- Di mana letak celah geografis atau demografis yang mereka abaikan?',
        ),
      ],
    ),
    PersonaPackage(
      id: 'career',
      title: 'Karir & Self-Growth 👑',
      desc:
          'Persona pendukung untuk memoles kualitas portofolio, masa depan karir, dan kebiasaan harian Anda.',
      isPremium: true,
      personas: [
        PersonaModel(
          name: 'Mentor Bijaksana',
          mindset:
              'Nasihat objektif berumur panjang dari kacamata sosok guru spiritual atau panutan terpintar Anda.',
          avatar: '🦉',
          detailedDescription:
              'Mentor Bijaksana mewakili kebijaksanaan jangka panjang, integritas diri, ketenangan emosional, dan kesehatan mental.\n\n🛡️ Aturan Berpikir:\n- Utamakan kedamaian hidup, kesehatan hubungan, dan prinsip etika.\n- Jauhi obsesi kepuasan instan dan kepanikan jangka pendek.\n\n❓ Pertanyaan Kunci:\n- Apakah keputusan ini selaras dengan nilai inti hidup Anda?\n- Nasihat apa yang akan diberikan versi diri Anda yang berumur 80 tahun?\n- Bagaimana keputusan ini berkontribusi pada warisan hidup Anda?',
        ),
        PersonaModel(
          name: 'Perekrut Kerja',
          mindset:
              'Menilai apakah langkah/tindakan ini benar-benar bernilai tinggi di industri nyata atau hanya sekadar buang waktu.',
          avatar: '🎯',
          detailedDescription:
              'Perekrut Kerja menilai segala tindakan dari kacamata nilai industri, kelayakan profesional, dan relevansi keahlian Anda di pasar kerja.\n\n🛡️ Aturan Berpikir:\n- Cari keahlian yang sedang diminati pasar tinggi.\n- Pastikan hasil kerja bisa diukur secara konkret untuk ditaruh di CV/Resume.\n\n❓ Pertanyaan Kunci:\n- Apakah mempelajari hal ini membuat portofolio Anda bernilai tinggi?\n- Bagaimana cara Anda mendemonstrasikan keahlian ini secara konkret kepada perekrut?',
        ),
        PersonaModel(
          name: 'Sahabat Jujur',
          mindset:
              'Mengatakan kebenaran paling pahit secara telanjang tanpa polesan basa-basi demi menyadarkan Anda.',
          avatar: '💬',
          detailedDescription:
              'Sahabat Jujur adalah orang terdekat yang tidak memiliki agenda selain menginginkan keselamatan dan keberhasilan sejati Anda.\n\n🛡️ Aturan Berpikir:\n- Katakan kebenaran pahit secara telanjang demi kebaikan jangka panjang.\n- Jangan biarkan teman Anda terjebak dalam angan-angan kosong (delusi).\n\n❓ Pertanyaan Kunci:\n- Apakah kamu benar-benar bekerja keras atau hanya sibuk mencari pembenaran?\n- Mengapa kamu terus mempertahankan proyek yang jelas-jelas tidak berhasil ini?',
        ),
      ],
    ),
    PersonaPackage(
      id: 'relationships',
      title: 'Hubungan & Konflik 👑',
      desc:
          'Set persona netral untuk menengahi gesekan komunikasi dengan teman, pasangan, atau rekan tim.',
      isPremium: true,
      personas: [
        PersonaModel(
          name: 'Mediator Netral',
          mindset:
              'Menyeimbangkan keadilan bagi kedua belah pihak. Bagaimana solusi jalan tengah (win-win) tanpa berat sebelah?',
          avatar: '⚖️',
          detailedDescription:
              'Mediator Netral bertindak sebagai penengah yang adil di tengah konflik interpersonal.\n\n🛡️ Aturan Berpikir:\n- Dengarkan kedua belah pihak dengan empati seimbang.\n- Cari solusi kompromi (win-win) di mana kedua pihak tidak merasa dirugikan.\n\n❓ Pertanyaan Kunci:\n- Apa kebutuhan mendasar yang diinginkan oleh Pihak A?\n- Apa ketakutan terbesar dari Pihak B?\n- Bagaimana membuat kesepakatan tengah yang menjembatani perbedaan?',
        ),
        PersonaModel(
          name: 'Pasangan Terluka',
          mindset:
              'Berempati penuh pada kerentanan emosional atau rasa diabaikan dari orang terdekat akibat keputusan Anda.',
          avatar: '💔',
          detailedDescription:
              'Pasangan Terluka menyuarakan kerentanan perasaan, kebutuhan akan kehadiran fisik/emosional, dan dampak pengabaian dari keputusan Anda terhadap hubungan pribadi.\n\n🛡️ Aturan Berpikir:\n- Utamakan keharmonisan rumah tangga, keluarga, dan waktu bersama orang tercinta.\n- Ingatkan bahwa karir/bisnis bukanlah segalanya.\n\n❓ Pertanyaan Kunci:\n- Apakah kesibukan mengejar karir ini membuatku kehilangan kehadiranmu?\n- Mengapa keputusan penting ini tidak didiskusikan denganku terlebih dahulu?',
        ),
      ],
    ),
  ];
}

class RoleStormingWorkspace extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const RoleStormingWorkspace({
    super.key,
    required this.onChanged,
  });

  @override
  State<RoleStormingWorkspace> createState() => _RoleStormingWorkspaceState();
}

class _RoleStormingWorkspaceState extends State<RoleStormingWorkspace> {
  PersonaPackage _activePackage = PersonaPackage.library[0];
  int _selectedPersonaIndex = 0;
  final TextEditingController _notesController = TextEditingController();

  void _notifyChanges() {
    if (_selectedPersonaIndex >= _activePackage.personas.length) {
      _selectedPersonaIndex = 0;
    }
    final persona = _activePackage.personas[_selectedPersonaIndex];
    final buffer = StringBuffer();
    buffer.writeln('Sudut Pandang Persona (Role Storming):');
    buffer.writeln('- Paket Aktif: ${_activePackage.title}');
    buffer.writeln('- Persona Aktif: ${persona.name} ${persona.avatar}');
    buffer.writeln('- Pola Pikir: ${persona.mindset}');
    buffer.writeln('- Catatan Ide Persona: ${_notesController.text.trim()}');
    widget.onChanged(buffer.toString());
  }

  @override
  void initState() {
    super.initState();
    _notesController.addListener(_notifyChanges);
  }

  @override
  void dispose() {
    _notesController.removeListener(_notifyChanges);
    _notesController.dispose();
    super.dispose();
  }

  void _openMarketplace() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 20.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.style_rounded, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Marketplace Paket Persona 🎭',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: 'Tutup',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Text(
                    'Pilih paket sudut pandang kognitif untuk memancing gagasan kreatif secara instan.',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: PersonaPackage.library.length,
                      itemBuilder: (context, index) {
                        final pkg = PersonaPackage.library[index];
                        final isCurrentlyActive = pkg.id == _activePackage.id;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isCurrentlyActive
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface.withValues(
                                      alpha: 0.08,
                                    ),
                              width: isCurrentlyActive ? 2 : 1,
                            ),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: pkg.isPremium
                                    ? Colors.amber.withValues(alpha: 0.1)
                                    : Colors.blue.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  pkg.personas.first.avatar,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                            title: Text(
                              pkg.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            subtitle: Text(
                              pkg.desc,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            trailing: isCurrentlyActive
                                ? Icon(
                                    Icons.check_circle_rounded,
                                    color: theme.colorScheme.primary,
                                  )
                                : const Icon(Icons.chevron_right_rounded),
                            onTap: () {
                              setState(() {
                                _activePackage = pkg;
                                _selectedPersonaIndex = 0;
                              });
                              _notifyChanges();
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDetailedDescription(PersonaModel persona) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Text(persona.avatar, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  persona.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(
              persona.detailedDescription,
              style: const TextStyle(fontSize: 12, height: 1.5),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final persona = _activePackage.personas[_selectedPersonaIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '4. Pilih Persona Berpikir',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            TextButton.icon(
              onPressed: _openMarketplace,
              icon: const Icon(Icons.storefront_rounded, size: 16),
              label: const Text(
                'Marketplace',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 65,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _activePackage.personas.length,
            itemBuilder: (context, index) {
              final p = _activePackage.personas[index];
              final isSelected = index == _selectedPersonaIndex;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPersonaIndex = index;
                  });
                  _notifyChanges();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(p.avatar, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        p.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mindset ${persona.name}:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showDetailedDescription(persona),
                    icon: const Icon(Icons.menu_book_rounded, size: 12),
                    label: const Text(
                      'Hayati Lebih Dalam 📖',
                      style: TextStyle(fontSize: 10),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                persona.mindset,
                style: const TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _notesController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Bagaimana ${persona.name} menyelesaikan masalah ini?',
            hintText:
                'Tuliskan analisis atau pemikiran dari sudut pandang ini...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Harap tuliskan pemikiran dari sudut pandang ${persona.name}';
            }
            return null;
          },
        ),
      ],
    );
  }
}
