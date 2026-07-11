import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';

// ==========================================
// RANDOM WORD WORKSPACE (expanded lexicon)
// ==========================================
class RandomWordWorkspace extends ConsumerStatefulWidget {
  final ValueChanged<String> onChanged;
  const RandomWordWorkspace({super.key, required this.onChanged});

  @override
  ConsumerState<RandomWordWorkspace> createState() => _RandomWordWorkspaceState();
}

class _RandomWordWorkspaceState extends ConsumerState<RandomWordWorkspace> {
  /// Expanded internal lexicon (ID). Flutter has no built-in random-word package
  /// for Indonesian; we keep a curated list + contextual hints.
  static const List<String> _words = [
    // Alam
    'Jembatan', 'Awan', 'Kunci', 'Magnet', 'Kepompong', 'Lensa', 'Jaring',
    'Kompas', 'Cermin', 'Benih', 'Sarang', 'Jangkar', 'Roda', 'Lentera',
    'Garam', 'Pahat', 'Pasang', 'Surut', 'Rantai', 'Sayap', 'Pondasi',
    'Katalis', 'Radar', 'Teropong', 'Filter', 'Gema', 'Kristal', 'Saringan',
    'Peta', 'Gembok', 'Sungai', 'Api', 'Angin', 'Kabut', 'Batu', 'Ranting',
    'Akar', 'Daun', 'Badai', 'Pelangi', 'Embun', 'Gunung', 'Lembah', 'Pantai',
    'Pasir', 'Ombak', 'Hutan', 'Gurun', 'Gletser', 'Danau',
    // Benda
    'Palu', 'Kaca', 'Tali', 'Kamera', 'Kipas', 'Tangga', 'Pintu', 'Jendela',
    'Lampu', 'Baterai', 'Kabel', 'Saklar', 'Ransel', 'Payung', 'Jam',
    'Cangkir', 'Piring', 'Pisau', 'Gunting', 'Jarum', 'Benang', 'Kain',
    'Bantal', 'Cermin', 'Laci', 'Kunci Inggris', 'Obeng', 'Paku', 'Baut',
    'Roda Gigi', 'Katrol', 'Timbangan', 'Termometer', 'Mikrofon', 'Speaker',
    'Layar', 'Keyboard', 'Mouse', 'Printer', 'Scanner', 'Drone',
    // Konsep
    'Keseimbangan', 'Batas', 'Transisi', 'Getaran', 'Ritme', 'Kontras',
    'Fokus', 'Perspektif', 'Skala', 'Pola', 'Siklus', 'Ambang', 'Momentum',
    'Gesekan', 'Inersia', 'Elastisitas', 'Kepadatan', 'Transparansi',
    'Redundansi', 'Simplifikasi', 'Abstraksi', 'Konkret', 'Analog',
    'Digital', 'Hibrida', 'Simbiosis', 'Kompetisi', 'Kolaborasi', 'Trade-off',
    'Bottleneck', 'Leverage', 'Feedback', 'Latency', 'Throughput', 'Resilience',
    // Aksi
    'Memanjat', 'Menyaring', 'Memangkas', 'Melebur', 'Menganyam', 'Mengasah',
    'Mengukur', 'Menghubungkan', 'Memecah', 'Menggabung', 'Memutar',
    'Menerjemahkan', 'Merefleksikan', 'Mengamplifikasi', 'Meredam',
    'Mengalirkan', 'Menambat', 'Melepas', 'Menguji', 'Mengiterasi',
    'Mendokumentasikan', 'Memvalidasi', 'Menyederhanakan', 'Mengotomatisasi',
    'Mendelegasikan', 'Menegosiasikan', 'Menyintesis', 'Mendiagnosis',
    'Mereparasi', 'Menyemai',
    // Teknologi / sistem
    'Sinyal', 'Frekuensi', 'Protokol', 'Enkripsi', 'Cache', 'Pipeline',
    'Queue', 'Stack', 'API', 'Sensor', 'Aktuator', 'Firmware', 'Kernel',
    'Sandbox', 'Firewall', 'Load Balancer', 'Replica', 'Snapshot', 'Diff',
    'Merge', 'Branch', 'Commit', 'Rollback', 'Telemetry', 'Dashboard',
    'Webhook', 'Token', 'Session', 'Rate Limit', 'Circuit Breaker',
    // Sosial
    'Komunitas', 'Jaringan', 'Ritual', 'Tradisi', 'Norma', 'Kepercayaan',
    'Reputasi', 'Afiliasi', 'Mentor', 'Mentee', 'Tim', 'Audience',
    'Stakeholder', 'Mediator', 'Ambassador', 'Gatekeeper', 'Champion',
    'Onboarding', 'Retensi', 'Advocacy', 'Feedback Loop', 'Budaya',
    'Inklusivitas', 'Akses', 'Keamanan Psikologis', 'Ownership',
    'Akuntabilitas', 'Transparansi Sosial', 'Saling Percaya', 'Gotong Royong',
  ];

  static const Map<String, String> _wordHints = {
    'Jembatan':
        'Bagaimana Anda bisa menghubungkan dua area/ide yang sebelumnya terpisah?',
    'Awan':
        'Bagaimana jika solusi Anda bisa diakses secara bebas, melayang, atau berubah bentuk?',
    'Kunci': 'Bagaimana cara membuka sumbat/hambatan terbesar dalam masalah Anda?',
    'Magnet':
        'Bagaimana cara menarik orang, sumber daya, atau perhatian secara natural?',
    'Kepompong':
        'Apakah solusi Anda membutuhkan fase proteksi atau transformasi tersembunyi?',
    'Lensa':
        'Bagaimana cara memperbesar detail terkecil, atau melihat masalah dari sudut makro?',
    'Jaring': 'Bagaimana menangkap sinyal lemah tanpa merusak yang rapuh?',
    'Kompas': 'Apa yang menjadi arah utara non-nego untuk keputusan ini?',
    'Cermin': 'Apa yang terlihat jika Anda membalik asumsi 180°?',
    'Benih': 'Investasi kecil apa yang bisa tumbuh besar dengan waktu?',
    'Sarang': 'Bagaimana menciptakan tempat aman untuk eksperimen berisiko?',
    'Jangkar': 'Apa yang harus tetap stabil saat semua berubah?',
    'Roda': 'Bagaimana membuat siklus berulang yang efisien?',
    'Lentera': 'Bagaimana menerangi satu langkah di depan tanpa butuh cahaya penuh?',
    'Garam': 'Sedikit elemen apa yang mengubah rasa keseluruhan sistem?',
    'Pahat': 'Apa yang harus dipahat pelan-pelan, bukan dihancurkan?',
    'Pasang': 'Kapan momentum alami mendorong solusi Anda?',
    'Surut': 'Kapan mundur justru membuka ruang yang lebih baik?',
    'Rantai': 'Di mana mata rantai terlemah yang harus diperkuat dulu?',
    'Sayap': 'Apa yang memberi daya angkat tanpa menambah beban berlebih?',
    'Pondasi': 'Apa fondasi yang jika goyah, seluruh bangunan runtuh?',
    'Katalis': 'Apa yang mempercepat reaksi tanpa ikut terpakai habis?',
    'Radar': 'Bagaimana mendeteksi ancaman atau peluang lebih dini?',
    'Teropong': 'Bagaimana melihat jauh ke depan tanpa kehilangan detail dekat?',
    'Filter': 'Apa yang harus disaring agar noise tidak menenggelamkan sinyal?',
    'Gema': 'Bagaimana satu aksi kecil beresonansi ke banyak tempat?',
    'Kristal': 'Bagaimana menumbuhkan struktur yang jernih dari kekacauan?',
    'Saringan': 'Siapa/apa yang lolos, dan mengapa kriteria itu ada?',
    'Peta': 'Bagaimana memvisualisasikan wilayah yang belum Anda pahami?',
    'Gembok': 'Apa yang sengaja dikunci, dan siapa yang memegang kuncinya?',
    'Sungai': 'Bagaimana mengikuti arus sambil mengarahkan ke muara yang diinginkan?',
    'Api': 'Bagaimana menjaga nyala tanpa membakar seluruh hutan?',
    'Angin': 'Apa gaya tak terlihat yang menggerakkan perilaku user?',
    'Kabut': 'Bagaimana memutuskan saat informasi masih buram?',
    'Batu': 'Apa yang solid dan tidak bisa digeser — apakah itu aset atau hambatan?',
    'Ranting': 'Cabang kecil mana yang bisa tumbuh jadi pohon baru?',
    'Akar': 'Masalah permukaan apa yang sebenarnya berakar di tempat lain?',
    'Daun': 'Output kecil apa yang menandakan sistem masih hidup?',
    'Badai': 'Bagaimana bertahan saat kondisi ekstrem tak terhindarkan?',
    'Pelangi': 'Bagaimana mengekstrak keindahan dari kondisi basah/gelap?',
    'Embun': 'Manfaat kecil pagi-pagi apa yang menumpuk setiap hari?',
    'Gunung': 'Bagaimana memecah puncak tinggi menjadi basecamp berurutan?',
    'Lembah': 'Di mana tempat tenang untuk mengonsolidasi setelah pendakian?',
    'Pantai': 'Di mana batas antara zona nyaman dan zona berisiko?',
    'Pasir': 'Apa yang mudah bergeser dan butuh penahan struktur?',
    'Ombak': 'Bagaimana memanfaatkan ritme pasang-surut peluang?',
    'Hutan': 'Bagaimana menavigasi kompleksitas tanpa menebang semua pohon?',
    'Gurun': 'Bagaimana bertahan dengan sumber daya sangat terbatas?',
    'Gletser': 'Perubahan lambat mana yang tetap tak terbendung?',
    'Danau': 'Di mana energi mengendap dan bisa diambil saat dibutuhkan?',
    'Palu': 'Kapan pukulan tegas lebih baik daripada penyesuaian halus?',
    'Kaca': 'Bagaimana membuat proses transparan tanpa mudah pecah?',
    'Tali': 'Bagaimana mengikat elemen longgar menjadi satu sistem?',
    'Kamera': 'Bagaimana merekam bukti, bukan hanya opini?',
    'Kipas': 'Bagaimana menyebarkan udara segar (ide/energi) ke seluruh ruang?',
    'Tangga': 'Apa anak tangga berikutnya yang realistis, bukan loncatan heroik?',
    'Pintu': 'Siapa yang boleh masuk, dan apa harga masuknya?',
    'Jendela': 'Perspektif luar apa yang kurang Anda lihat dari dalam?',
    'Lampu': 'Apa yang harus disorot agar prioritas jelas?',
    'Baterai': 'Dari mana energi tim diisi ulang, dan apa yang mengurasnya?',
    'Kabel': 'Koneksi mana yang jika putus, sistem lumpuh?',
    'Saklar': 'Saklar on/off sederhana apa yang mengubah perilaku besar?',
    'Ransel': 'Apa saja yang benar-benar perlu dibawa di perjalanan ini?',
    'Payung': 'Proteksi apa yang harus ada sebelum hujan risiko datang?',
    'Jam': 'Deadline mana yang memaksa fokus, bukan panik?',
    'Cangkir': 'Bagaimana menampung kapasitas tanpa tumpah?',
    'Piring': 'Bagaimana menyajikan satu hidangan utama, bukan 10 camilan?',
    'Pisau': 'Keputusan potong mana yang paling membebaskan kompleksitas?',
    'Gunting': 'Apa yang harus dipotong bersih hari ini?',
    'Jarum': 'Detail kecil mana yang menentukan kualitas keseluruhan?',
    'Benang': 'Narasi penghubung apa yang menjahit semua bagian?',
    'Kain': 'Bagaimana menenun fleksibilitas tanpa merobek struktur?',
    'Bantal': 'Di mana sistem boleh “istirahat” tanpa rusak?',
    'Laci': 'Informasi apa yang disimpan, dan apa yang harus selalu di atas meja?',
    'Kunci Inggris': 'Alat serbaguna apa yang mempercepat banyak perbaikan kecil?',
    'Obeng': 'Penyetelan presisi mana yang belum digarap?',
    'Paku': 'Titik jangkar permanen mana yang perlu dipasang dulu?',
    'Baut': 'Bagaimana mengunci modul agar bisa dibuka lagi nanti?',
    'Roda Gigi': 'Bagaimana sinkronisasi antar bagian agar tidak saling menggigit?',
    'Katrol': 'Bagaimana mengurangi usaha dengan mekanika yang cerdas?',
    'Timbangan': 'Trade-off apa yang harus ditimbang secara eksplisit?',
    'Termometer': 'Metrik suhu apa yang menandakan sistem overheat?',
    'Mikrofon': 'Suara siapa yang belum terdengar di ruangan ini?',
    'Speaker': 'Pesan apa yang harus diperkeras agar sampai ke semua?',
    'Layar': 'Apa yang harus terlihat di permukaan, vs di belakang layar?',
    'Keyboard': 'Input cepat apa yang harus diotomatisasi?',
    'Mouse': 'Navigasi mana yang terlalu banyak klik?',
    'Printer': 'Artefak fisik/dokumentasi apa yang perlu “dicetak” dari ide?',
    'Scanner': 'Bagaimana mendeteksi pola tersembunyi di data mentah?',
    'Drone': 'Bagaimana melihat dari ketinggian tanpa mengorbankan detail tanah?',
    'Keseimbangan': 'Di mana sistem miring terlalu jauh ke satu sisi?',
    'Batas': 'Batas mana yang melindungi, dan mana yang menghambat?',
    'Transisi': 'Bagaimana merancang peralihan yang tidak menyakitkan?',
    'Getaran': 'Sinyal kecil apa yang menandakan pergeseran besar?',
    'Ritme': 'Irama kerja apa yang natural vs dipaksakan?',
    'Kontras': 'Perbedaan tajam mana yang memperjelas pilihan?',
    'Fokus': 'Apa yang sengaja tidak dikerjakan agar yang penting menang?',
    'Perspektif': 'Dari kursi siapa masalah ini terlihat berbeda total?',
    'Skala': 'Apa yang bekerja di skala 10 tapi gagal di skala 10.000?',
    'Pola': 'Pola berulang mana yang belum Anda namai?',
    'Siklus': 'Siklus mana yang harus diputus, mana yang harus dijaga?',
    'Ambang': 'Di ambang mana perubahan kecil memicu efek besar?',
    'Momentum': 'Bagaimana menjaga gerak tanpa kelelahan tim?',
    'Gesekan': 'Gesekan mana yang melindungi kualitas, mana yang sia-sia?',
    'Inersia': 'Kebiasaan lama apa yang menolak perubahan berguna?',
    'Elastisitas': 'Seberapa jauh sistem bisa meregang sebelum patah?',
    'Kepadatan': 'Di mana terlalu padat sehingga perlu ruang napas?',
    'Transparansi': 'Apa yang harus terlihat untuk membangun kepercayaan?',
    'Redundansi': 'Cadangan mana yang kritis vs pemborosan?',
    'Simplifikasi': 'Apa yang bisa dihapus tanpa kehilangan nilai inti?',
    'Abstraksi': 'Bagaimana menyembunyikan kompleksitas tanpa menghilangkan kontrol?',
    'Konkret': 'Contoh nyata apa yang membuktikan ide ini hidup?',
    'Analog': 'Metafora dunia fisik apa yang menjelaskan sistem digital Anda?',
    'Digital': 'Apa yang harus diotomatisasi, apa yang tetap manusiawi?',
    'Hibrida': 'Bagaimana menggabungkan dua kekuatan yang biasanya berlawanan?',
    'Simbiosis': 'Siapa yang saling untung jika kerja sama ini berhasil?',
    'Kompetisi': 'Bagaimana menang tanpa menghancurkan ekosistem jangka panjang?',
    'Kolaborasi': 'Antarmuka kerja sama mana yang masih kaku?',
    'Trade-off': 'Pengorbanan apa yang Anda sadari dan terima?',
    'Bottleneck': 'Di mana antrian paling panjang dalam alur kerja?',
    'Leverage': 'Titik tuas mana yang memberi hasil besar dengan usaha kecil?',
    'Feedback': 'Loop umpan balik mana yang terlalu lambat?',
    'Latency': 'Penundaan mana yang merusak pengalaman?',
    'Throughput': 'Berapa banyak yang bisa diproses tanpa menurunkan kualitas?',
    'Resilience': 'Bagaimana bangkit setelah gagal, bukan hanya menghindari gagal?',
    'Memanjat': 'Bagaimana naik bertahap dengan pegangan yang aman?',
    'Menyaring': 'Kriteria saring apa yang masih bias?',
    'Memangkas': 'Cabang mana yang menghabiskan nutrisi tanpa buah?',
    'Melebur': 'Elemen mana yang harus menyatu menjadi satu pengalaman?',
    'Menganyam': 'Bagaimana menenun beberapa alur jadi satu cerita?',
    'Mengasah': 'Keterampilan mana yang perlu diasah, bukan diganti?',
    'Mengukur': 'Apa yang diukur menentukan apa yang diperbaiki — sudah tepatkah?',
    'Menghubungkan': 'Siapa yang belum terhubung padahal saling butuh?',
    'Memecah': 'Bagaimana memecah monolit tanpa kehilangan integritas?',
    'Menggabung': 'Apa yang lebih kuat digabung daripada dipisah?',
    'Memutar': 'Bagaimana memutar sudut pandang 90° hari ini?',
    'Menerjemahkan': 'Bagaimana menjelaskan ide ahli ke bahasa non-ahli?',
    'Merefleksikan': 'Apa yang dipelajari dari iterasi terakhir?',
    'Mengamplifikasi': 'Sinyal baik mana yang perlu diperkuat?',
    'Meredam': 'Noise mana yang harus diredam segera?',
    'Mengalirkan': 'Di mana aliran macet dan mengapa?',
    'Menambat': 'Apa yang perlu ditambat agar tidak hanyut?',
    'Melepas': 'Apa yang harus dilepas agar bisa bergerak lagi?',
    'Menguji': 'Eksperimen termurah apa yang bisa dijalankan minggu ini?',
    'Mengiterasi': 'Siklus umpan balik berikutnya kapan?',
    'Mendokumentasikan': 'Pengetahuan apa yang hilang jika orang kunci cuti?',
    'Memvalidasi': 'Asumsi mana yang belum diuji di dunia nyata?',
    'Menyederhanakan': 'Langkah mana yang bisa digabung atau dihapus?',
    'Mengotomatisasi': 'Pekerjaan berulang mana yang membosankan tapi penting?',
    'Mendelegasikan': 'Apa yang hanya Anda yang bisa, vs yang bisa diajarkan?',
    'Menegosiasikan': 'Kepentingan bersama apa yang bisa jadi titik temu?',
    'Menyintesis': 'Bagaimana merangkum banyak masukan jadi satu arah?',
    'Mendiagnosis': 'Gejala vs akar — sudah dibedakan?',
    'Mereparasi': 'Apa yang rusak tapi masih layak diperbaiki?',
    'Menyemai': 'Kebiasaan kecil apa yang ditanam hari ini?',
    'Sinyal': 'Sinyal mana yang Anda abaikan terlalu lama?',
    'Frekuensi': 'Seberapa sering intervensi harus terjadi agar efektif?',
    'Protokol': 'Aturan main mana yang perlu ditulis agar tidak bias?',
    'Enkripsi': 'Apa yang harus dilindungi, dan dari siapa?',
    'Cache': 'Hasil mana yang boleh diingat agar tidak dihitung ulang?',
    'Pipeline': 'Bagaimana merancang alur dari ide ke pengiriman?',
    'Queue': 'Siapa yang menunggu, dan apakah urutannya adil?',
    'Stack': 'Lapisan mana yang menanggung beban paling berat?',
    'API': 'Kontrak antarmuka mana yang harus stabil?',
    'Sensor': 'Data sensor apa yang kurang untuk keputusan bagus?',
    'Aktuator': 'Aksi otomatis mana yang boleh dijalankan tanpa manusia?',
    'Firmware': 'Aturan tingkat rendah mana yang jarang disentuh tapi kritis?',
    'Kernel': 'Inti sistem mana yang tidak boleh diubah sembarangan?',
    'Sandbox': 'Di mana aman bereksperimen tanpa merusak produksi?',
    'Firewall': 'Batas mana yang melindungi dari gangguan luar?',
    'Load Balancer': 'Bagaimana membagi beban agar tidak satu titik gagal?',
    'Replica': 'Cadangan mana yang harus selalu siap?',
    'Snapshot': 'Momen mana yang perlu difoto sebelum eksperimen besar?',
    'Diff': 'Perubahan mana yang benar-benar beda dari kemarin?',
    'Merge': 'Bagaimana menggabungkan jalur kerja tanpa konflik?',
    'Branch': 'Eksperimen mana yang layak dipisah dulu?',
    'Commit': 'Keputusan mana yang sudah “di-commit” dan tidak bolak-balik?',
    'Rollback': 'Rencana mundur apa jika eksperimen gagal?',
    'Telemetry': 'Metrik hidup apa yang menandakan kesehatan sistem?',
    'Dashboard': 'Satu layar apa yang harus dilihat setiap pagi?',
    'Webhook': 'Event mana yang harus memicu reaksi otomatis?',
    'Token': 'Bukti akses mana yang mewakili kepercayaan?',
    'Session': 'Berapa lama konteks harus diingat sebelum reset?',
    'Rate Limit': 'Batas frekuensi mana yang melindungi dari abuse?',
    'Circuit Breaker': 'Kapan sistem harus “trip” untuk melindungi diri?',
    'Komunitas': 'Bagaimana komunitas saling menguatkan tanpa pusat tunggal?',
    'Jaringan': 'Node mana yang jika hilang memutus banyak orang?',
    'Ritual': 'Ritual kecil apa yang memperkuat budaya tim?',
    'Tradisi': 'Tradisi mana yang masih berguna, mana yang tinggal beban?',
    'Norma': 'Norma tidak tertulis mana yang menghambat kejujuran?',
    'Kepercayaan': 'Bagaimana membangun trust lebih cepat tanpa naif?',
    'Reputasi': 'Sinyal reputasi mana yang paling dipercaya user?',
    'Afiliasi': 'Identitas kelompok mana yang memengaruhi keputusan?',
    'Mentor': 'Siapa yang bisa mempercepat learning curve Anda?',
    'Mentee': 'Siapa yang bisa Anda bantu sambil mengklarifikasi ide sendiri?',
    'Tim': 'Peran mana yang kosong di tim saat ini?',
    'Audience': 'Siapa audiens sejati, bukan yang Anda bayangkan?',
    'Stakeholder': 'Siapa yang terdampak tapi belum diajak bicara?',
    'Mediator': 'Siapa yang bisa menjembatani konflik kepentingan?',
    'Ambassador': 'Siapa yang secara natural menyebarkan pesan Anda?',
    'Gatekeeper': 'Siapa yang mengontrol akses, dan bagaimana meyakinkannya?',
    'Champion': 'Siapa internal champion yang mendorong adopsi?',
    'Onboarding': 'Menit pertama pengalaman — apakah membingungkan?',
    'Retensi': 'Mengapa orang tinggal, bukan hanya kenapa mereka datang?',
    'Advocacy': 'Bagaimana user menjadi juru bicara tanpa dipaksa?',
    'Feedback Loop': 'Seberapa cepat kritik kembali ke pembuat keputusan?',
    'Budaya': 'Perilaku apa yang dihargai secara nyata (bukan di poster)?',
    'Inklusivitas': 'Siapa yang terpinggirkan oleh desain saat ini?',
    'Akses': 'Hambatan akses mana yang paling tidak terlihat?',
    'Keamanan Psikologis': 'Apakah orang berani bilang “saya tidak tahu”?',
    'Ownership': 'Siapa pemilik jelas untuk tiap hasil?',
    'Akuntabilitas': 'Bagaimana accountability tanpa budaya takut?',
    'Transparansi Sosial': 'Informasi mana yang harus terbuka ke semua pihak?',
    'Saling Percaya': 'Tindakan kecil apa yang menumbuhkan trust harian?',
    'Gotong Royong': 'Beban mana yang lebih ringan jika digotong bersama?',
  };

  static const String _defaultHint =
      'Gunakan analogi kata ini untuk memecahkan hambatan berpikir Anda. '
      'Sifat, fungsi, atau metafora apa yang relevan dengan masalah Anda?';

  String? _currentWord;
  final TextEditingController _notesController = TextEditingController();
  final List<({String word, String note})> _saved = [];

  String _hintFor(String? word) {
    if (word == null) return _defaultHint;
    return _wordHints[word] ?? _defaultHint;
  }

  void _generateWord() {
    final rng = Random();
    var word = _words[rng.nextInt(_words.length)];
    // Avoid immediate repeat when possible.
    if (_words.length > 1 && word == _currentWord) {
      word = _words[rng.nextInt(_words.length)];
    }
    setState(() => _currentWord = word);
    _notifyChanges();
  }

  void _saveAssociation() {
    final word = _currentWord;
    final note = _notesController.text.trim();
    if (word == null || note.isEmpty) return;
    setState(() {
      _saved.add((word: word, note: note));
      _notesController.clear();
    });
    _notifyChanges();
  }

  void _notifyChanges() {
    final hint = _hintFor(_currentWord);
    final buffer = StringBuffer();
    buffer.writeln('Asosiasi Kata Acak (Random Word):');
    if (_currentWord != null) {
      buffer.writeln('- Kata terpilih: $_currentWord');
      buffer.writeln('- Analogi pemicu: $hint');
    }
    final live = _notesController.text.trim();
    if (live.isNotEmpty) {
      buffer.writeln('- Catatan Ide (aktif): $live');
    }
    if (_saved.isNotEmpty) {
      buffer.writeln('- Asosiasi tersimpan:');
      for (final s in _saved) {
        buffer.writeln('  • ${s.word}: ${s.note}');
      }
    }
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
    final hint = _hintFor(_currentWord);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Eksplorasi Asosiasi Kata Acak (${_words.length} kata)',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
              ] else ...[
                Icon(
                  Icons.help_outline_rounded,
                  size: 40,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tekan tombol di bawah untuk menarik kata acak inspiratif!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _generateWord,
                icon: const Icon(Icons.casino_rounded),
                label: const Text('Dapatkan Kata Acak'),
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
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _currentWord == null ? null : _saveAssociation,
          icon: const Icon(Icons.bookmark_add_outlined, size: 18),
          label: const Text('Simpan asosiasi & lanjut kata lain'),
        ),
        if (_saved.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Tersimpan (${_saved.length})',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 6),
          ..._saved.reversed.take(8).map((s) {
            return Card(
              margin: const EdgeInsets.only(bottom: 4),
              child: ListTile(
                dense: true,
                title: Text(
                  s.word,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                subtitle: Text(s.note, style: const TextStyle(fontSize: 11)),
              ),
            );
          }),
        ],
      ],
    );
  }
}
