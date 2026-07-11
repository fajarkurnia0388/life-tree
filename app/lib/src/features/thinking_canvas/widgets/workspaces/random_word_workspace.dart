import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';

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
