import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/services/error_handler_service.dart';

class MorphologicalTemplate {
  final String title;
  final String description;
  final String category;
  final bool isPremium;
  final Map<String, List<String>> dimensions;

  const MorphologicalTemplate({
    required this.title,
    required this.description,
    required this.category,
    required this.isPremium,
    required this.dimensions,
  });

  static const List<MorphologicalTemplate> library = [
    MorphologicalTemplate(
      title: 'Inovasi Startup Tech',
      description: 'Ciptakan ide produk software dan SaaS digital baru.',
      category: 'Bisnis',
      isPremium: false,
      dimensions: {
        'Platform': [
          'Mobile App',
          'SaaS Web',
          'Chrome Extension',
          'Telegram Bot',
        ],
        'Model Bisnis': [
          'Freemium',
          'Langganan Bulanan',
          'Sponsor Iklan',
          'Pay-per-use',
        ],
        'Target Pasar': [
          'B2B Korporat',
          'Pelajar Gen Z',
          'Kreator Konten',
          'UMKM Lokal',
        ],
      },
    ),
    MorphologicalTemplate(
      title: 'Produk Eko-Fisik',
      description: 'Inovasi produk fisik ramah lingkungan dan sirkular.',
      category: 'Fisik',
      isPremium: false,
      dimensions: {
        'Kategori': [
          'Kemasan Makanan',
          'Peralatan Dapur',
          'Alat Tulis',
          'Dekorasi Rumah',
        ],
        'Bahan Organik': [
          'Bambu Serat',
          'Pelepah Pisang',
          'Karton Daur Ulang',
          'Misilium Jamur',
        ],
        'Distribusi': [
          'Shopify DTC',
          'Pasar Tani Lokal',
          'Grosir B2B',
          'Langganan Box',
        ],
      },
    ),
    MorphologicalTemplate(
      title: 'Game Indie Kreatif 🎮',
      description: 'Kombinasi mekanik dan gaya visual untuk game indie Anda.',
      category: 'Game',
      isPremium: true,
      dimensions: {
        'Genre': ['Roguelike', 'Cozy Puzzle', 'Deckbuilder', 'Metroidvania'],
        'Gaya Visual': [
          'Pixel Art Retro',
          'Low Poly 3D',
          'Hand-drawn 2D',
          'Teks Naratif',
        ],
        'Mekanik Kunci': [
          'Time Loop',
          'Peningkatan Gravitasi',
          'Memasak Kuliner',
          'Card Battler',
        ],
      },
    ),
    MorphologicalTemplate(
      title: 'Inovasi F&B / Kuliner 🍜',
      description: 'Eksplorasi resep dan konsep bisnis kuliner unik.',
      category: 'F&B',
      isPremium: true,
      dimensions: {
        'Jenis Kuliner': [
          'Mie Nusantara',
          'Pastry Manis',
          'Kopi Susu',
          'Camilan Sehat',
        ],
        'Bahan Utama': [
          'Tepung Singkong',
          'Susu Gandum (Oat)',
          'Gula Aren Organik',
          'Matcha Uji',
        ],
        'Konsep Saji': [
          'Drive-Thru Kontainer',
          'Fine Dining Santai',
          'Kemasan Bento Keranjang',
          'Dapur Bersama',
        ],
      },
    ),
    MorphologicalTemplate(
      title: 'Kampanye Edukasi Sosial 📣',
      description: 'Metode menyebarkan pesan positif ke masyarakat luas.',
      category: 'Sosial',
      isPremium: true,
      dimensions: {
        'Media': [
          'Video TikTok Pendek',
          'Podcast Dialog',
          'Infografis Instagram',
          'Zine Cetak Mini',
        ],
        'Target Usia': [
          'Anak SD-SMP',
          'Remaja SMA',
          'Keluarga Muda',
          'Lansia Aktif',
        ],
        'Topik Utama': [
          'Kesehatan Mental',
          'Literasi Keuangan',
          'Peduli Sampah Plastik',
          'Gizi Sehat Stunting',
        ],
      },
    ),
  ];
}

// ==========================================
// 3. MORPHOLOGICAL ANALYSIS WORKSPACE (SLOT MACHINE SPIN)
// ==========================================
class MorphologicalWorkspace extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final bool isPremiumUser;
  final VoidCallback onPremiumLocked;

  const MorphologicalWorkspace({
    super.key,
    required this.onChanged,
    required this.isPremiumUser,
    required this.onPremiumLocked,
  });

  @override
  State<MorphologicalWorkspace> createState() => _MorphologicalWorkspaceState();
}

class _MorphologicalWorkspaceState extends State<MorphologicalWorkspace> {
  final List<String> _dimensions = ['Media', 'Bahan', 'Model Bisnis'];
  final Map<String, List<String>> _options = {
    'Media': ['Mobile App', 'Website', 'Buku Fisik', 'Kantung Belanja'],
    'Bahan': ['Kertas Daur Ulang', 'Daun Pisang', 'Bambu', 'Linen Rajutan'],
    'Model Bisnis': ['Berlangganan', 'Beli Putus', 'Sewa', 'Donasi'],
  };

  final Map<String, FixedExtentScrollController> _controllers = {};
  bool _isSpinning = false;
  Map<String, String>? _spinResult;

  @override
  void initState() {
    super.initState();
    for (var dim in _dimensions) {
      _controllers[dim] = FixedExtentScrollController();
    }
  }

  @override
  void dispose() {
    _controllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  void _notifyChanges() {
    final buffer = StringBuffer();
    buffer.writeln('Analisis Morfologi Slot Machine:');
    _options.forEach((dim, list) {
      buffer.writeln('- Dimensi $dim: ${list.join(", ")}');
    });
    if (_spinResult != null) {
      buffer.writeln('Kombinasi Slot Terpilih 🎰:');
      _spinResult!.forEach((key, val) {
        buffer.writeln('  * $key -> $val');
      });
    }
    widget.onChanged(buffer.toString());
  }

  Future<void> _spinCombinations() async {
    if (_isSpinning) return;
    setState(() {
      _isSpinning = true;
      _spinResult = null;
    });

    final rng = Random();
    final result = <String, String>{};

    for (int i = 0; i < _dimensions.length; i++) {
      final dim = _dimensions[i];
      final opts = _options[dim] ?? [];
      if (opts.isEmpty) continue;

      final targetItem = rng.nextInt(opts.length);
      result[dim] = opts[targetItem];

      int currentItem = 0;
      try {
        currentItem = _controllers[dim]!.selectedItem;
      } catch (e, stackTrace) {
        ErrorHandlerService().logError(
          e,
          stackTrace,
          context: 'MorphologicalWorkspace.getControllerSelectedItem',
        );
      }

      final int spinCycles = 24 + (i * 12);
      final int baseTarget = currentItem + spinCycles;
      final int remainderDiff =
          (targetItem - (baseTarget % opts.length) + opts.length) % opts.length;
      final int targetIndex = baseTarget + remainderDiff;

      _controllers[dim]!.animateToItem(
        targetIndex,
        duration: Duration(milliseconds: 1800 + i * 600),
        curve: Curves.easeOutCirc,
      );
    }

    await Future.delayed(
      Duration(milliseconds: 1800 + (_dimensions.length - 1) * 600),
    );

    if (mounted) {
      setState(() {
        _isSpinning = false;
        _spinResult = result;
      });
      _notifyChanges();
    }
  }

  void _addOption(String dimension) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Tambah Opsi di "$dimension"'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Opsi',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    _options[dimension]!.add(controller.text.trim());
                  });
                  _notifyChanges();
                }
                Navigator.pop(context);
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  void _addDimension() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Tambah Dimensi Baru'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Nama Dimensi',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final dim = controller.text.trim();
                if (dim.isNotEmpty) {
                  setState(() {
                    _dimensions.add(dim);
                    _options[dim] = [];
                    _controllers[dim] = FixedExtentScrollController();
                  });
                  _notifyChanges();
                }
                Navigator.pop(context);
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  void _showTemplateMarketplace() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.only(
            top: 16,
            bottom: 24,
            left: 16,
            right: 16,
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Perpustakaan Dimensi 🛒',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Text(
                'Pilih dari set parameter siap-pakai untuk memancing kreativitas Anda secara instan!',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: MorphologicalTemplate.library.length,
                  itemBuilder: (context, index) {
                    final t = MorphologicalTemplate.library[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.08,
                          ),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        title: Row(
                          children: [
                            Text(
                              t.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                t.category,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            if (t.isPremium) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 14,
                              ),
                            ],
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              t.description,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 4,
                              children: t.dimensions.keys.map((k) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.04),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    k,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        onTap: () {
                          if (t.isPremium && !widget.isPremiumUser) {
                            Navigator.pop(context);
                            widget.onPremiumLocked();
                            return;
                          }
                          setState(() {
                            _controllers.forEach((_, c) => c.dispose());
                            _controllers.clear();

                            _dimensions.clear();
                            _options.clear();

                            t.dimensions.forEach((dim, opts) {
                              _dimensions.add(dim);
                              _options[dim] = List.from(opts);
                              _controllers[dim] = FixedExtentScrollController();
                            });
                            _spinResult = null;
                          });
                          _notifyChanges();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Template "${t.title}" berhasil diterapkan!',
                              ),
                              backgroundColor: theme.colorScheme.primary,
                            ),
                          );
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '4. Slot Machine Kombinasi Morfologi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _showTemplateMarketplace,
                  icon: const Icon(Icons.storefront_rounded, size: 16),
                  label: const Text(
                    'Marketplace',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  onPressed: _addDimension,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: Row(
            children: _dimensions.map((dim) {
              final opts = _options[dim] ?? [];
              final controller = _controllers[dim]!;

              return Expanded(
                child: Column(
                  children: [
                    Text(
                      dim.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        letterSpacing: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black45,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.4,
                            ),
                            width: 1.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (opts.isNotEmpty)
                                ListWheelScrollView.useDelegate(
                                  controller: controller,
                                  itemExtent: 32,
                                  physics: const FixedExtentScrollPhysics(),
                                  childDelegate:
                                      ListWheelChildLoopingListDelegate(
                                        children: opts.map((opt) {
                                          return Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 4.0,
                                                  ),
                                              child: Text(
                                                opt,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                )
                              else
                                const Center(
                                  child: Text(
                                    'Kosong',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              IgnorePointer(
                                child: Center(
                                  child: Container(
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.15),
                                      border: Border.symmetric(
                                        horizontal: BorderSide(
                                          color: theme.colorScheme.primary
                                              .withValues(alpha: 0.7),
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                height: 24,
                                child: IgnorePointer(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black,
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                height: 24,
                                child: IgnorePointer(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black,
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _isSpinning ? null : _spinCombinations,
          icon: Icon(
            _isSpinning ? Icons.refresh_rounded : Icons.casino_rounded,
          ),
          label: Text(_isSpinning ? 'Sedang Memutar...' : 'Putar Dadu Acak 🎲'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
        ),
        const SizedBox(height: 12),
        ..._dimensions.map((dim) {
          final list = _options[dim] ?? [];
          return Row(
            children: [
              Expanded(
                child: Text(
                  '$dim (${list.length} opsi)',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _addOption(dim),
                child: const Text('+ Opsi', style: TextStyle(fontSize: 11)),
              ),
            ],
          );
        }),
      ],
    );
  }
}
