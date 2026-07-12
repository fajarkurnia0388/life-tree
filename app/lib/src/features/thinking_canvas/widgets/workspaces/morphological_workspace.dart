// RESIDUAL: MorphologicalTemplate.isPremium is NOT billing.
// All templates are free. Do not gate UI on isPremium.
import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/i18n/daoji_text_key.dart';
import '../../../../core/i18n/daoji_text_resolver.dart';
import '../../../../core/i18n/daoji_vocabulary_provider.dart';

class MorphologicalTemplate {
  final String title;
  final String description;
  final String category;
  /// Residual catalog flag — unused for paywall. Prefer ignoring.
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
      isPremium: false, // residual: was true; monetization disabled
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
  ];
}

class MorphologicalWorkspace extends ConsumerStatefulWidget {
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onStructuredOutput;
  final String? initialStructuredOutput;
  const MorphologicalWorkspace({
    super.key,
    required this.onChanged,
    this.onStructuredOutput,
    this.initialStructuredOutput,
  });

  @override
  ConsumerState<MorphologicalWorkspace> createState() =>
      _MorphologicalWorkspaceState();
}

class _MorphologicalWorkspaceState
    extends ConsumerState<MorphologicalWorkspace> {
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
    // Restore from structured output if available
    if (widget.initialStructuredOutput != null) {
      try {
        final data = jsonDecode(widget.initialStructuredOutput!) as Map<String, dynamic>;
        final dims = data['dimensions'] as List<dynamic>?;
        if (dims != null) {
          _dimensions.clear();
          _options.clear();
          for (var c in _controllers.values) { c.dispose(); }
          _controllers.clear();
          for (final d in dims) {
            final dimName = d.toString();
            _dimensions.add(dimName);
            _controllers[dimName] = FixedExtentScrollController();
          }
        }
        final opts = data['options'] as Map<String, dynamic>?;
        if (opts != null) {
          opts.forEach((key, value) {
            _options[key] = (value as List<dynamic>).map((e) => e.toString()).toList();
          });
        }
        final spin = data['spinResult'] as Map<String, dynamic>?;
        if (spin != null) {
          _spinResult = spin.map((k, v) => MapEntry(k, v.toString()));
        }
      } catch (_) {}
    }
    for (var dim in _dimensions) {
      _controllers.putIfAbsent(dim, () => FixedExtentScrollController());
    }
    // keep initial options as-is; UI strings are resolved at build
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _notifyChanges() {
    final buffer = StringBuffer();
    buffer.writeln('Analisis Morfologi Slot Machine:');
    _options.forEach((dim, list) {
      buffer.writeln('- Dimensi $dim: ${list.join(', ')}');
    });
    if (_spinResult != null) {
      buffer.writeln('Kombinasi Slot Terpilih:');
      _spinResult!.forEach((k, v) => buffer.writeln('  * $k -> $v'));
    }
    widget.onChanged(buffer.toString());
    widget.onStructuredOutput?.call(jsonEncode({
      'dimensions': _dimensions,
      'options': _options,
      'spinResult': _spinResult,
    }));
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
      } catch (_) {}

      final int spinCycles = 24 + (i * 12);
      final int baseTarget = currentItem + spinCycles;
      final int remainderDiff =
          (targetItem - (baseTarget % opts.length) + opts.length) % opts.length;
      final int targetIndex = baseTarget + remainderDiff;

      unawaited(_controllers[dim]!.animateToItem(
        targetIndex,
        duration: Duration(milliseconds: 1800 + i * 600),
        curve: Curves.easeOutCirc,
      ));
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
          title: Text(
            DaojiText.resolve(
              DaojiTextKey.morphologicalAddOptionTitle,
              ref.read(daojiVocabularyLevelValueProvider),
              params: {'dimension': dimension},
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              // label is resolved below to avoid const use
              labelText: '',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                DaojiText.resolve(
                  DaojiTextKey.morphologicalCancel,
                  ref.read(daojiVocabularyLevelValueProvider),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final v = controller.text.trim();
                if (v.isNotEmpty) {
                  setState(() {
                    _options[dimension] = List.from(_options[dimension] ?? [])
                      ..add(v);
                  });
                  _notifyChanges();
                }
                Navigator.pop(context);
              },
              child: Text(
                DaojiText.resolve(
                  DaojiTextKey.morphologicalAddButton,
                  ref.read(daojiVocabularyLevelValueProvider),
                ),
              ),
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
          title: Text(
            DaojiText.resolve(
              DaojiTextKey.morphologicalAddDimensionTitle,
              ref.read(daojiVocabularyLevelValueProvider),
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: '',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                DaojiText.resolve(
                  DaojiTextKey.morphologicalCancel,
                  ref.read(daojiVocabularyLevelValueProvider),
                ),
              ),
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
              child: Text(
                DaojiText.resolve(
                  DaojiTextKey.morphologicalAddButton,
                  ref.read(daojiVocabularyLevelValueProvider),
                ),
              ),
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
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DaojiText.resolve(
                      DaojiTextKey.morphologicalMarketplaceTitle,
                      ref.read(daojiVocabularyLevelValueProvider),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                DaojiText.resolve(
                  DaojiTextKey.morphologicalMarketplaceDescription,
                  ref.read(daojiVocabularyLevelValueProvider),
                ),
                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.55)),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: MorphologicalTemplate.library.length,
                  itemBuilder: (context, index) {
                    final t = MorphologicalTemplate.library[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6.0),
                      child: ListTile(
                        title: Row(
                          children: [
                            Text(
                              t.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withAlpha(
                                  (0.1 * 255).round(),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                t.category,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              t.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 4,
                              children: t.dimensions.keys
                                  .map(
                                    (k) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.onSurface
                                            .withAlpha((0.04 * 255).round()),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        k,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            for (var c in _controllers.values) {
                              c.dispose();
                            }
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
                              content: Text('Template "${t.title}" diterapkan'),
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
              'Slot Machine Kombinasi Morfologi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _showTemplateMarketplace,
                  icon: const Icon(Icons.menu_book_rounded, size: 16),
                  label: const Text(
                    'Pustaka Lokal',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  tooltip: 'Tambah dimensi',
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
            color: theme.colorScheme.onSurface.withAlpha((0.04 * 255).round()),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.onSurface.withAlpha(
                (0.08 * 255).round(),
              ),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: Row(
            children: _dimensions.map((dim) {
              final opts = _options[dim] ?? [];
              final controller =
                  _controllers[dim] ?? FixedExtentScrollController();
              _controllers.putIfAbsent(dim, () => controller);

              return Expanded(
                child: Column(
                  children: [
                    Text(
                      dim.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
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
                            color: theme.colorScheme.primary.withAlpha(
                              (0.4 * 255).round(),
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
                                        children: opts
                                            .map(
                                              (opt) => Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 4.0,
                                                      ),
                                                  child: Text(
                                                    opt,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                )
                              else
                                Center(
                                  child: Text(
                                    'Kosong',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                                    ),
                                  ),
                                ),
                              IgnorePointer(
                                child: Center(
                                  child: Container(
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary
                                          .withAlpha((0.15 * 255).round()),
                                      border: Border.symmetric(
                                        horizontal: BorderSide(
                                          color: theme.colorScheme.primary
                                              .withAlpha((0.7 * 255).round()),
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
          label: Text(_isSpinning ? 'Sedang Memutar...' : 'Putar Kombinasi'),
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
                    fontSize: 12,
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
