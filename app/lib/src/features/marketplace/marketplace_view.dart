import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/domain/app_constants.dart';
import '../../core/providers/db_provider.dart';
import '../../core/widgets/loading_state_widget.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/local_db/database.dart';
import '../dashboard/dashboard_provider.dart';
import 'marketplace_service.dart';
import 'widgets/share_template_bottom_sheet.dart';
import 'widgets/marketplace_template_card.dart';

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

  final List<String> _domains = [
    'Semua',
    'Tubuh',
    'Keuangan',
    'Hubungan',
    'Emosi',
    'Karir',
    'Rekreasi',
  ];
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
      final profiles = await db.select(db.userProfiles).get();
      if (profiles.isEmpty) throw Exception('Profil tidak ditemukan');
      final userId = profiles.first.userId;

      final existing =
          await (db.select(db.habits)..where(
                (tbl) =>
                    tbl.userId.equals(userId) &
                    tbl.title.equals(t.title) &
                    tbl.deletedAt.isNull(),
              ))
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

      final habitId = const Uuid().v4();
      final now = DateTime.now();

      final newHabit = HabitsCompanion.insert(
        habitId: habitId,
        userId: userId,
        domainTag: drift.Value(t.domainTag),
        title: t.title,
        status: const drift.Value(HabitStatus.active),
        frequency: const drift.Value('Daily'),
        initiationFriction: drift.Value(t.friction),
        originalFriction: drift.Value(t.friction),
        energyCost: drift.Value(t.energy),
        impactScore: drift.Value(t.impact),
        mvaDurationMin: drift.Value(t.mvaDuration),
        createdAt: now,
      );

      final reminder = ReminderPreferencesCompanion.insert(habitId: habitId);

      await db.into(db.habits).insert(newHabit);
      await db.into(db.reminderPreferences).insert(reminder);
      await service.incrementDownloads(t.templateId);

      ref.invalidate(dashboardDataProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Kebiasaan "${t.title}" berhasil diunduh ke daftar lokal!',
            ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
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
                          starIndex <= selectedStars
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
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
        return ShareTemplateBottomSheet(
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari Template',
                hintText: 'Cari template kebiasaan...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _refreshTemplates();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) => _refreshTemplates(),
            ),
          ),

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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text(
                  'Urutkan:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
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
                            label: Text(
                              option,
                              style: const TextStyle(fontSize: 11),
                            ),
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

          Expanded(
            child: FutureBuilder<List<PublicTemplate>>(
              future: _templatesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: LoadingStateWidget(message: 'Memuat template...'),
                  );
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
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final t = list[index];
                    return MarketplaceTemplateCard(
                      template: t,
                      onRate: () => _rateTemplate(t),
                      onDownload: () => _downloadTemplate(t),
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
