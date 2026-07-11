import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';

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
  /// Residual only — not billing. Do not lock packs on this flag.
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
      isPremium: false, // residual: was true; monetization disabled
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
      isPremium: false, // residual: was true; monetization disabled
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
      isPremium: false, // residual: was true; monetization disabled
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


class RoleStormingWorkspace extends ConsumerStatefulWidget {
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onStructuredOutput;
  final String? initialStructuredOutput;
  const RoleStormingWorkspace({
    super.key,
    required this.onChanged,
    this.onStructuredOutput,
    this.initialStructuredOutput,
  });

  @override
  ConsumerState<RoleStormingWorkspace> createState() => _RoleStormingWorkspaceState();
}

class _RoleStormingWorkspaceState extends ConsumerState<RoleStormingWorkspace> {
  PersonaPackage _activePackage = PersonaPackage.library[0];
  int _selectedPersonaIndex = 0;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final Map<String, String> _personaNotes = {}; // key: packageId_personaName

  void _notifyChanges() {
    if (_selectedPersonaIndex >= _activePackage.personas.length) {
      _selectedPersonaIndex = 0;
    }
    
    // Save current persona note to map
    final activePersona = _activePackage.personas[_selectedPersonaIndex];
    final activeKey = '${_activePackage.id}_${activePersona.name}';
    _personaNotes[activeKey] = _notesController.text;

    final buffer = StringBuffer();
    buffer.writeln('Sudut Pandang Persona (Role Storming):');
    buffer.writeln('- Paket Aktif: ${_activePackage.title}');
    
    _personaNotes.forEach((key, note) {
      if (note.trim().isNotEmpty) {
        final name = key.split('_').last;
        buffer.writeln('  • $name: ${note.trim()}');
      }
    });

    final summary = _summaryController.text.trim();
    if (summary.isNotEmpty) {
      buffer.writeln('- Ringkasan Lintas Persona: $summary');
    }
    widget.onChanged(buffer.toString());
    widget.onStructuredOutput?.call(jsonEncode({
      'activePackage': _activePackage.id,
      'personaNotes': _personaNotes,
      'summary': _summaryController.text.trim(),
    }));
  }

  void _selectPersona(int index) {
    final oldPersona = _activePackage.personas[_selectedPersonaIndex];
    final oldKey = '${_activePackage.id}_${oldPersona.name}';
    _personaNotes[oldKey] = _notesController.text;

    setState(() {
      _selectedPersonaIndex = index;
      final newPersona = _activePackage.personas[index];
      final newKey = '${_activePackage.id}_${newPersona.name}';
      _notesController.text = _personaNotes[newKey] ?? '';
    });
    _notifyChanges();
  }

  @override
  void initState() {
    super.initState();
    // Restore from structured output if available
    if (widget.initialStructuredOutput != null) {
      try {
        final data = jsonDecode(widget.initialStructuredOutput!) as Map<String, dynamic>;
        final packageId = data['activePackage'] as String?;
        if (packageId != null) {
          final idx = PersonaPackage.library.indexWhere((p) => p.id == packageId);
          if (idx >= 0) _activePackage = PersonaPackage.library[idx];
        }
        final personaNotes = data['personaNotes'] as Map<String, dynamic>?;
        if (personaNotes != null) {
          personaNotes.forEach((k, v) => _personaNotes[k] = v.toString());
        }
        final summary = data['summary'] as String?;
        if (summary != null) _summaryController.text = summary;
      } catch (_) {}
    }
    _notesController.addListener(_notifyChanges);
    _summaryController.addListener(_notifyChanges);
  }

  @override
  void dispose() {
    _notesController.removeListener(_notifyChanges);
    _notesController.dispose();
    _summaryController.removeListener(_notifyChanges);
    _summaryController.dispose();
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
                                color: Colors.blue.withValues(alpha: 0.1),
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
                                // Save current persona's note first
                                final oldPersona = _activePackage.personas[_selectedPersonaIndex];
                                final oldKey = '${_activePackage.id}_${oldPersona.name}';
                                _personaNotes[oldKey] = _notesController.text;

                                _activePackage = pkg;
                                _selectedPersonaIndex = 0;

                                final newPersona = pkg.personas[0];
                                final newKey = '${pkg.id}_${newPersona.name}';
                                _notesController.text = _personaNotes[newKey] ?? '';
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
              'Pilih Persona Berpikir',
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
                onTap: () => _selectPersona(index),
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
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _summaryController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Ringkasan Lintas Persona (Kesimpulan)',
            hintText: 'Sintesis semua sudut pandang di atas menjadi solusi cerdas...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}

