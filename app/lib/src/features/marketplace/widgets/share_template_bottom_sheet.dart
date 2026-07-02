import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/domain/app_constants.dart';
import '../../../core/providers/db_provider.dart';
import '../../../core/theme/button_theme.dart';
import '../../../core/widgets/loading_state_widget.dart';
import '../../../data/local_db/database.dart';
import '../marketplace_service.dart';

class ShareTemplateBottomSheet extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;
  const ShareTemplateBottomSheet({super.key, required this.onSuccess});

  @override
  ConsumerState<ShareTemplateBottomSheet> createState() =>
      _ShareTemplateBottomSheetState();
}

class _ShareTemplateBottomSheetState
    extends ConsumerState<ShareTemplateBottomSheet> {
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
    final profiles = await db.select(db.userProfiles).get();
    if (profiles.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }
    final userId = profiles.first.userId;

    final list =
        await (db.select(db.habits)..where(
              (tbl) =>
                  tbl.userId.equals(userId) &
                  tbl.status.equals(HabitStatus.active) &
                  tbl.deletedAt.isNull(),
            ))
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
        creatorPenName: _penNameController.text.trim().isEmpty
            ? 'Anonim'
            : _penNameController.text.trim(),
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
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: _isLoading
          ? SizedBox(
              height: 200,
              child: Center(
                child: LoadingStateWidget(message: 'Memuat kebiasaan...'),
              ),
            )
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
                    style: AppButtonStyles.secondary(context),
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
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.2,
                          ),
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
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    DropdownButtonFormField<Habit>(
                      initialValue: _selectedHabit,
                      decoration: InputDecoration(
                        labelText: 'Pilih Kebiasaan Aktif',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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

                    TextFormField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi / Tips Sukses',
                        hintText:
                            'Tulis tips Anda: Kapan mengerjakannya? Di mana ditumpuk? dll.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Harap berikan sedikit deskripsi atau panduan';
                        }
                        if (val.trim().length < 10) {
                          return 'Deskripsi minimal 10 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _penNameController,
                      maxLength: 30,
                      decoration: InputDecoration(
                        labelText: 'Nama Pena (Opsional)',
                        hintText: 'Misal: SehatSelalu (Default: Anonim)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (val) {
                        if (val != null &&
                            val.trim().isNotEmpty &&
                            val.trim().length < 2) {
                          return 'Nama pena minimal 2 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _submitShare,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        minimumSize: const Size(88, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Bagikan Sekarang',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
