import 'package:flutter/material.dart';
import '../../../core/domain/app_constants.dart';
import '../../../core/theme/theme.dart';

class DomainInsightDialog extends StatefulWidget {
  final String domain;
  final double score;
  final VoidCallback? onFocusApplied;

  const DomainInsightDialog({
    super.key,
    required this.domain,
    required this.score,
    this.onFocusApplied,
  });

  static void show(BuildContext context, {
    required String domain,
    required double score,
    VoidCallback? onFocusApplied,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'DomainInsight',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return ScaleTransition(
          scale: anim1,
          child: DomainInsightDialog(
            domain: domain,
            score: score,
            onFocusApplied: onFocusApplied,
          ),
        );
      },
    );
  }

  @override
  State<DomainInsightDialog> createState() => _DomainInsightDialogState();
}

class _DomainInsightDialogState extends State<DomainInsightDialog> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fillController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseOpacity;

  bool _isAnimationFinished = false;

  @override
  void initState() {
    super.initState();

    // Pulse animation for expanding energy rings
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 0.8, end: 2.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    _pulseOpacity = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    // Energy filling progress
    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _fillController.forward().then((_) {
      if (mounted) {
        setState(() {
          _isAnimationFinished = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fillController.dispose();
    super.dispose();
  }

  // Get assets/content per domain
  IconData _getIcon() {
    switch (widget.domain) {
      case 'Tubuh': return Icons.favorite_rounded;
      case 'Keuangan': return Icons.account_balance_wallet_rounded;
      case 'Hubungan': return Icons.people_alt_rounded;
      case 'Emosi': return Icons.sentiment_satisfied_alt_rounded;
      case 'Karir': return Icons.work_rounded;
      case 'Rekreasi': return Icons.sports_esports_rounded;
      default: return Icons.star_rounded;
    }
  }

  String _getQuote() {
    switch (widget.domain) {
      case 'Tubuh':
        return '"Kesehatan adalah aset utama. Rawatlah tubuhmu, itu adalah satu-satunya tempat tinggal jiwamu."';
      case 'Keuangan':
        return '"Jangan menabung apa yang tersisa setelah belanja, tapi belanjakanlah apa yang tersisa setelah menabung."';
      case 'Hubungan':
        return '"Hubungan yang bermakna dibangun dari ribuan interaksi kecil yang dipenuhi perhatian."';
      case 'Emosi':
        return '"Kamu tidak bisa menghentikan ombak emosi, tetapi kamu bisa belajar bagaimana cara berselancar."';
      case 'Karir':
        return '"Satu-satunya cara untuk melakukan pekerjaan hebat adalah dengan mencintai apa yang kamu lakukan."';
      case 'Rekreasi':
        return '"Rekreasi bukanlah pemborosan waktu, melainkan investasi untuk meremajakan energi jiwa."';
      default:
        return '"Setiap tindakan kecil hari ini membawa pertumbuhan bagi masa depanmu."';
    }
  }

  String _getQuoteAuthor() {
    switch (widget.domain) {
      case 'Tubuh': return 'Jim Rohn';
      case 'Keuangan': return 'Warren Buffett';
      case 'Hubungan': return 'John Gottman';
      case 'Emosi': return 'Jon Kabat-Zinn';
      case 'Karir': return 'Steve Jobs';
      case 'Rekreasi': return 'Ovid';
      default: return 'LifeTree';
    }
  }

  List<String> _getTips() {
    switch (widget.domain) {
      case 'Tubuh':
        return [
          'Lakukan peregangan singkat 2 menit setelah duduk selama 1-2 jam.',
          'Minum segelas air putih hangat segera setelah bangun tidur.',
          'Pastikan berjalan kaki minimal 3.000 langkah hari ini.',
        ];
      case 'Keuangan':
        return [
          'Catat semua pengeluaran kecil (kopi, jajan) hari ini.',
          'Tunda pembelian non-esensial selama 24 jam sebelum checkout.',
          'Sisihkan minimal 10% pendapatan harian/bulanan secara konsisten.',
        ];
      case 'Hubungan':
        return [
          'Kirim pesan penyemangat atau tanyakan kabar ke satu sahabat dekat.',
          'Dengarkan keluh kesah pasangan/teman tanpa langsung menyela.',
          'Jadwalkan makan bersama keluarga tanpa layar ponsel di meja.',
        ];
      case 'Emosi':
        return [
          'Lakukan Box Breathing: Tarik napas 4s, tahan 4s, buang 4s, tahan 4s.',
          'Tuliskan 3 hal kecil yang Anda syukuri hari ini di jurnal.',
          'Berikan ruang bagi emosi negatif tanpa mengkritik diri sendiri.',
        ];
      case 'Karir':
        return [
          'Selesaikan tugas tersulit (Eat That Frog) di pagi hari.',
          'Batasi waktu membuka media sosial di sela-sela jam kerja.',
          'Luangkan 15 menit untuk membaca modul atau belajar skill baru.',
        ];
      case 'Rekreasi':
        return [
          'Jalan santai di taman sekitar 10 menit tanpa membuka ponsel.',
          'Nikmati hobi atau permainan kesukaan Anda secara bebas.',
          'Dengarkan instrumen tenang untuk merilekskan pikiran.',
        ];
      default:
        return [
          'Mulailah dengan MVA (Minimum Viable Action) hari ini.',
          'Tetapkan prioritas harian yang jelas.',
          'Evaluasi kemajuan Anda di penghujung hari.',
        ];
    }
  }

  String _getInsight() {
    switch (widget.domain) {
      case 'Tubuh':
        return '💡 Keseimbangan hidrasi terbukti meningkatkan fokus mental hingga 20% secara instan.';
      case 'Keuangan':
        return '💡 Membatasi jajan impulsif kecil dapat menghemat rata-rata 15% pengeluaran bulanan.';
      case 'Hubungan':
        return '💡 Pesan apresiasi singkat 1 menit meningkatkan rasa terhubung sosial hingga 40%.';
      case 'Emosi':
        return '💡 Box Breathing selama 2 menit menurunkan detak jantung dan meredakan cemas mendadak.';
      case 'Karir':
        return '💡 Menuntaskan tugas terberat di awal memotong tingkat stres kerja harian hingga 30%.';
      case 'Rekreasi':
        return '💡 Berjalan 10 menit di alam terbuka menurunkan kadar hormon kortisol (stres) secara nyata.';
      default:
        return '💡 Langkah konsisten 1% setiap hari berlipat ganda menjadi 37 kali pertumbuhan dalam setahun.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = DomainColors.forDomain(widget.domain);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: !_isAnimationFinished
              ? _buildEnergyLoader(color)
              : _buildInsightCard(context, theme, isDark, color),
        ),
      ),
    );
  }

  Widget _buildEnergyLoader(Color domainColor) {
    const double loaderSize = 92.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Concentric pulsing ripples
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: loaderSize * _scaleAnimation.value,
                  height: loaderSize * _scaleAnimation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: domainColor.withValues(alpha: _pulseOpacity.value),
                  ),
                );
              },
            ),
            // Glowing core
            Container(
              width: loaderSize,
              height: loaderSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: domainColor,
                boxShadow: [
                  BoxShadow(
                    color: domainColor.withValues(alpha: 0.6),
                    blurRadius: 24,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: AnimatedBuilder(
                animation: _fillController,
                builder: (context, child) {
                  return SizedBox(
                    width: loaderSize,
                    height: loaderSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: loaderSize,
                          height: loaderSize,
                          child: CircularProgressIndicator(
                            value: _fillController.value,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 4.5,
                          ),
                        ),
                        Icon(
                          _getIcon(),
                          size: 36,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          'Mengalirkan Energi ${widget.domain}...',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(BuildContext context, ThemeData theme, bool isDark, Color domainColor) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 420),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2622) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: domainColor.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: domainColor.withValues(alpha: isDark ? 0.2 : 0.08),
            blurRadius: 32,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Upper banner with domain header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: domainColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: domainColor,
                  radius: 20,
                  child: Icon(_getIcon(), color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Domain ${widget.domain}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: domainColor,
                        ),
                      ),
                      Text(
                        'Tingkat Penjajaran Energi',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: domainColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Skor: ${widget.score.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: domainColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quotes section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _getQuote(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '— ${_getQuoteAuthor()}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: domainColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Tips Header
                  Text(
                    '💡 Tips & Nasihat Praktis',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Tips list
                  ..._getTips().map((tip) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Icon(Icons.circle, size: 6, color: domainColor),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            tip,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                  
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  
                  // Micro insight / news
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: CalmTheme.primarySage.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getInsight(),
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Action Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Tutup'),
                  ),
                ),
                if (widget.onFocusApplied != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onFocusApplied!();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: domainColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Fokus Dasbor'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
