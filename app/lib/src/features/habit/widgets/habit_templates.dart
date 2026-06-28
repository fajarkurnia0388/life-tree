class HabitTemplate {
  final String title;
  final int friction;
  final int energy;
  final int impact;
  final int mvaDuration;
  final String description;
  final String domain;

  const HabitTemplate({
    required this.title,
    required this.friction,
    required this.energy,
    required this.impact,
    required this.mvaDuration,
    required this.description,
    required this.domain,
  });
}

const List<HabitTemplate> bodyHabitTemplates = [
  HabitTemplate(
    title: 'Minum segelas air hangat pagi',
    friction: 1,
    energy: 1,
    impact: 4,
    mvaDuration: 1,
    description: 'Rehidrasi instan untuk merangsang metabolisme tubuh.',
    domain: 'Tubuh',
  ),
  HabitTemplate(
    title: 'Peregangan leher & pundak',
    friction: 1,
    energy: 2,
    impact: 3,
    mvaDuration: 2,
    description: 'Melepaskan otot kaku setelah duduk atau bekerja.',
    domain: 'Tubuh',
  ),
  HabitTemplate(
    title: 'Plank statis 1 menit',
    friction: 2,
    energy: 3,
    impact: 4,
    mvaDuration: 1,
    description: 'Latihan core singkat untuk stabilitas tulang belakang.',
    domain: 'Tubuh',
  ),
  HabitTemplate(
    title: 'Jalan kaki santai 10 menit',
    friction: 2,
    energy: 3,
    impact: 5,
    mvaDuration: 5,
    description: 'Sirkulasi darah & udara segar di luar ruangan.',
    domain: 'Tubuh',
  ),
  HabitTemplate(
    title: 'Jeda mata 20-20-20 rule',
    friction: 1,
    energy: 1,
    impact: 3,
    mvaDuration: 1,
    description: 'Jeda mata melihat jauh mengurangi screen fatigue.',
    domain: 'Tubuh',
  ),
  HabitTemplate(
    title: 'Pernapasan 4-7-8 sebelum tidur',
    friction: 1,
    energy: 1,
    impact: 5,
    mvaDuration: 3,
    description: 'Latihan pernapasan rileks untuk kualitas tidur nyenyak.',
    domain: 'Tubuh',
  ),
];

const List<HabitTemplate> financeHabitTemplates = [
  HabitTemplate(
    title: 'Catat pengeluaran harian',
    friction: 1,
    energy: 1,
    impact: 4,
    mvaDuration: 1,
    description: 'Mencatat pengeluaran segera setelah bertransaksi agar sadar finansial.',
    domain: 'Keuangan',
  ),
  HabitTemplate(
    title: 'Periksa budget mingguan',
    friction: 2,
    energy: 1,
    impact: 4,
    mvaDuration: 2,
    description: 'Meninjau sisa anggaran minggu ini untuk mencegah overspending.',
    domain: 'Keuangan',
  ),
  HabitTemplate(
    title: 'Menabung uang receh kembalian',
    friction: 1,
    energy: 1,
    impact: 3,
    mvaDuration: 1,
    description: 'Menyisihkan uang kembalian kecil ke celengan/rekening khusus.',
    domain: 'Keuangan',
  ),
];

const List<HabitTemplate> relationshipHabitTemplates = [
  HabitTemplate(
    title: 'Kirim pesan kabar ke keluarga',
    friction: 1,
    energy: 1,
    impact: 4,
    mvaDuration: 1,
    description: 'Menyapa orang tua atau kerabat dekat lewat pesan singkat.',
    domain: 'Hubungan',
  ),
  HabitTemplate(
    title: 'Dengar aktif tanpa distraksi',
    friction: 2,
    energy: 2,
    impact: 5,
    mvaDuration: 3,
    description: 'Mendengarkan cerita pasangan/teman selama 3 menit tanpa melihat ponsel.',
    domain: 'Hubungan',
  ),
  HabitTemplate(
    title: 'Ucapkan apresiasi ke rekan kerja',
    friction: 1,
    energy: 1,
    impact: 4,
    mvaDuration: 1,
    description: 'Mengucapkan terima kasih yang tulus atas bantuan rekan kerja hari ini.',
    domain: 'Hubungan',
  ),
];

const List<HabitTemplate> emotionHabitTemplates = [
  HabitTemplate(
    title: 'Jurnal emosi 3 baris',
    friction: 2,
    energy: 1,
    impact: 5,
    mvaDuration: 2,
    description: 'Menuliskan perasaan saat ini dan pemicunya secara singkat.',
    domain: 'Emosi',
  ),
  HabitTemplate(
    title: 'Pernapasan hening 2 menit',
    friction: 1,
    energy: 1,
    impact: 4,
    mvaDuration: 2,
    description: 'Duduk diam dan menyadari napas masuk dan keluar untuk ketenangan.',
    domain: 'Emosi',
  ),
  HabitTemplate(
    title: 'Afirmasi positif pagi',
    friction: 1,
    energy: 1,
    impact: 3,
    mvaDuration: 1,
    description: 'Mengucapkan satu kalimat penyemangat untuk diri sendiri di cermin.',
    domain: 'Emosi',
  ),
];

const List<HabitTemplate> careerHabitTemplates = [
  HabitTemplate(
    title: 'Baca artikel industri/buku',
    friction: 2,
    energy: 2,
    impact: 4,
    mvaDuration: 2,
    description: 'Membaca materi edukasi atau profesional selama 5 menit.',
    domain: 'Karir',
  ),
  HabitTemplate(
    title: 'Tulis 3 tugas penting esok',
    friction: 1,
    energy: 1,
    impact: 5,
    mvaDuration: 2,
    description: 'Merencanakan fokus utama pekerjaan esok sebelum menutup hari.',
    domain: 'Karir',
  ),
  HabitTemplate(
    title: 'Tinjau target mingguan',
    friction: 2,
    energy: 2,
    impact: 4,
    mvaDuration: 3,
    description: 'Melihat kembali pencapaian karir atau rencana belajar minggu ini.',
    domain: 'Karir',
  ),
];

const List<HabitTemplate> recreationHabitTemplates = [
  HabitTemplate(
    title: 'Dengar 1 lagu favorit penuh',
    friction: 1,
    energy: 1,
    impact: 3,
    mvaDuration: 3,
    description: 'Mendengarkan musik kesukaan dengan fokus tanpa melakukan hal lain.',
    domain: 'Rekreasi',
  ),
  HabitTemplate(
    title: 'Teh/kopi tanpa layar gadget',
    friction: 1,
    energy: 1,
    impact: 4,
    mvaDuration: 3,
    description: 'Menikmati minuman hangat tanpa terpaku pada layar hp/komputer.',
    domain: 'Rekreasi',
  ),
  HabitTemplate(
    title: 'Berjalan kaki tanpa tujuan',
    friction: 1,
    energy: 1,
    impact: 4,
    mvaDuration: 3,
    description: 'Jalan santai di sekitar rumah untuk menyegarkan pikiran tanpa target.',
    domain: 'Rekreasi',
  ),
];
