import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/providers/db_provider.dart';
import '../../data/local_db/database.dart';
import '../dashboard/dashboard_provider.dart';
import 'marketplace_service.dart';
import 'package:drift/drift.dart' as drift;

class MarketplaceView extends ConsumerStatefulWidget {
  const MarketplaceView({super.key});

  @override
  ConsumerState<MarketplaceView> createState() => _MarketplaceViewState();
}

class _MarketplaceViewState extends ConsumerState<MarketplaceView> {
  final _searchController = TextEditingController();
  String _selectedDomain = 'Semua';
  String _sortBy = 'Terpopuler';
  late Future<List<PublicTemplate>> _templatesFuture;

  final List<String> _domains = ['Semua', 'Tubuh', 'Keuangan', 'Hubungan', 'Emosi', 'Karir', 'Rekreasi'];
  final List<String> _sortOptions = ['Terpopuler', 'Terbaik', 'Terbaru'];

  @override
  void initState() {
    super.initState();
    _refreshTemplates();
  }

  void _refreshTemplates() {
    final service = ref.read(marketplaceServiceProvider);
    setState(() {
      _templatesFuture = service.fetchTemplates(
        domain: _selectedDomain,
        query: _searchController.text,
        sortBy: _sortBy,
      );
    });
  }

  Future<void> _downloadTemplate(PublicTemplate t) async {
    final db = ref.read(dbProvider);
    final service = ref.read(marketplaceServiceProvider);

    try {
      // 1. Get user profile ID
      final profiles = await db.select(db.userProfiles).get();
      if (profiles.isEmpty) throw Exception('Profil tidak ditemukan');
      final userId = profiles.first.userId;

      // Check if habit with same title already exists
      final existing = await (db.select(db.habits)
            ..where((tbl) => tbl.userId.equals(userId) & tbl.title.equals(t.title) & tbl.deletedAt.isNull()))
          .get();

      if (existing.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Anda sudah memiliki kebiasaan "${t.title}"!'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // 2. Map to local Drift database model
      final habitId = const Uuid().v4();
      final now = DateTime.now();

      final newHabit = HabitsCompanion.insert(
        habitId: habitId,
        userId: userId,
        domainTag: drift.Value(t.domainTag),
        title: t.title,
        status: const drift.Value('Active'),
        frequency: const drift.Value('Daily'),
        initiationFriction: drift.Value(t.friction),
        originalFriction: drift.Value(t.friction),
        energyCost: drift.Value(t.energy),
        impactScore: drift.Value(t.impact),
        mvaDurationMin: drift.Value(t.mvaDuration),
        createdAt: now,
      );

      final reminder = ReminderPreferencesCompanion.insert(
        habitId: habitId,
      );

      // 3. Write locally and notify backend service
      await db.into(db.habits).insert(newHabit);
      await db.into(db.reminderPreferences).insert(reminder);
      await service.incrementDownloads(t.templateId);

      // Invalidate dashboard provider
      ref.invalidate(dashboardDataProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kebiasaan "${t.title}" berhasil diunduh ke daftar lokal!'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshTemplates();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengunduh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rateTemplate(PublicTemplate t) async {
    final service = ref.read(marketplaceServiceProvider);
    int selectedStars = 5;

    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Beri Rating Kebiasaan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Seberapa bermanfaat kebiasaan "${t.title}" ini bagi Anda?',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      return IconButton(
                        icon: Icon(
                          starIndex <= selectedStars ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: Colors.amber,
                          size: 36,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            selectedStars = starIndex;
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: const Text('Kirim Rating'),
                ),
              ],
            );
          },
        );
      },
    );

    if (proceed == true) {
      await service.rateTemplate(t.templateId, selectedStars);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terima kasih atas rating Anda!'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshTemplates();
      }
    }
  }

  void _showShareDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _ShareTemplateBottomSheet(
          onSuccess: () {
            _refreshTemplates();
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace Kebiasaan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Bagikan Kebiasaan Saya',
            onPressed: _showShareDialog,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search & Filter header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari template kebiasaan...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _refreshTemplates();
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (_) => _refreshTemplates(),
            ),
          ),

          // Horizontal domain filters
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _domains.length,
              itemBuilder: (context, index) {
                final domain = _domains[index];
                final isSelected = _selectedDomain == domain;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(domain),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedDomain = domain;
                        });
                        _refreshTemplates();
                      }
                    },
                  ),
                );
              },
            ),
          ),

          // Sorting Selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text('Urutkan:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _sortOptions.length,
                      itemBuilder: (context, index) {
                        final option = _sortOptions[index];
                        final isSelected = _sortBy == option;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(option, style: const TextStyle(fontSize: 11)),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _sortBy = option;
                                });
                                _refreshTemplates();
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main list content
          Expanded(
            child: FutureBuilder<List<PublicTemplate>>(
              future: _templatesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Terjadi kesalahan: ${snapshot.error}'),
                  );
                }

                final list = snapshot.data ?? [];
                if (list.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('😔', style: TextStyle(fontSize: 48)),
                        SizedBox(height: 12),
                        Text(
                          'Tidak ada template kebiasaan yang cocok.',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final t = list[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    t.domainTag,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                    const SizedBox(width: 2),
                                    Text(
                                      t.averageRating.toStringAsFixed(1),
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      ' (${t.ratingsCount})',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              t.title,
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Oleh: ${t.creatorPenName}',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              t.description,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.timer_outlined,
                                      size: 14,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'MVA: ${t.mvaDuration}m',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(
                                      Icons.fitness_center_rounded,
                                      size: 14,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Beban: ${t.friction + t.energy} Poin',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.download_rounded,
                                      size: 14,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${t.downloadsCount}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: () => _rateTemplate(t),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(88, 36),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('Beri Rating', style: TextStyle(fontSize: 12)),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () => _downloadTemplate(t),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor: theme.colorScheme.onPrimary,
                                    minimumSize: const Size(88, 36),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('Gunakan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareTemplateBottomSheet extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;
  const _ShareTemplateBottomSheet({required this.onSuccess});

  @override
  ConsumerState<_ShareTemplateBottomSheet> createState() => _ShareTemplateBottomSheetState();
}

class _ShareTemplateBottomSheetState extends ConsumerState<_ShareTemplateBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _penNameController = TextEditingController();
  Habit? _selectedHabit;
  List<Habit> _localHabits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocalHabits();
  }

  Future<void> _loadLocalHabits() async {
    final db = ref.read(dbProvider);
    final list = await (db.select(db.habits)
          ..where((tbl) => tbl.status.equals('Active') & tbl.deletedAt.isNull()))
        .get();
    if (mounted) {
      setState(() {
        _localHabits = list;
        if (list.isNotEmpty) {
          _selectedHabit = list.first;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _submitShare() async {
    if (!_formKey.currentState!.validate() || _selectedHabit == null) return;

    final service = ref.read(marketplaceServiceProvider);

    try {
      await service.uploadTemplate(
        title: _selectedHabit!.title,
        description: _descController.text.trim(),
        domainTag: _selectedHabit!.domainTag ?? 'Tubuh',
        friction: _selectedHabit!.initiationFriction,
        energy: _selectedHabit!.energyCost,
        impact: _selectedHabit!.impactScore,
        mvaDuration: _selectedHabit!.mvaDurationMin,
        creatorPenName: _penNameController.text.trim().isEmpty ? 'Anonim' : _penNameController.text.trim(),
      );

      widget.onSuccess();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kebiasaan Anda berhasil dibagikan ke publik!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membagikan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _penNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: _isLoading
          ? const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
          : _localHabits.isEmpty
              ? SizedBox(
                  height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('😔', style: TextStyle(fontSize: 40)),
                      const SizedBox(height: 12),
                      const Text(
                        'Anda belum memiliki kebiasaan aktif untuk dibagikan.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Tutup'),
                      ),
                    ],
                  ),
                )
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Bagikan Kebiasaan Saya 👥',
                          style: theme.textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bantu orang lain membangun rutinitas sehat berdasarkan pengalaman Anda.',
                          style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // Dropdown selection
                        DropdownButtonFormField<Habit>(
                          value: _selectedHabit,
                          decoration: InputDecoration(
                            labelText: 'Pilih Kebiasaan Aktif',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: _localHabits.map((h) {
                            return DropdownMenuItem<Habit>(
                              value: h,
                              child: Text(h.title, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedHabit = val;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Description/Guideline textfield
                        TextFormField(
                          controller: _descController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Deskripsi / Tips Sukses',
                            hintText: 'Tulis tips Anda: Kapan mengerjakannya? Di mana ditumpuk? dll.',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Harap berikan sedikit deskripsi atau panduan';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Pen name
                        TextFormField(
                          controller: _penNameController,
                          decoration: InputDecoration(
                            labelText: 'Nama Pena (Opsional)',
                            hintText: 'Misal: SehatSelalu (Default: Anonim)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 24),

                        ElevatedButton(
                          onPressed: _submitShare,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            minimumSize: const Size(88, 52),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Bagikan Sekarang',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
