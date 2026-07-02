import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/domain/app_constants.dart';
import '../../core/providers/db_provider.dart';
import '../../core/services/error_handler_service.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/local_db/database.dart';
import '../dashboard/dashboard_provider.dart';
import 'package:drift/drift.dart' as drift;
import 'domain/thinking_method.dart';
import 'domain/mind_map_model.dart';
import 'widgets/mind_map_canvas_view.dart';
import 'widgets/specialized_workspace_widgets.dart';
import 'widgets/thinking_canvas_onboarding_dialog.dart';
import 'widgets/method_picker_bottom_sheet.dart';

class ThinkingCanvasLiteView extends ConsumerStatefulWidget {
  const ThinkingCanvasLiteView({super.key});

  @override
  ConsumerState<ThinkingCanvasLiteView> createState() =>
      _ThinkingCanvasLiteViewState();
}

class _ThinkingCanvasLiteViewState
    extends ConsumerState<ThinkingCanvasLiteView> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  final _summaryController = TextEditingController();
  final _actionController = TextEditingController();
  final _refController = TextEditingController();

  String _selectedMethod = 'MindDump';
  bool _addToHabits = false;
  String _habitDomain = 'Tubuh';

  // Dynamic workspace controllers
  final Map<String, TextEditingController> _dynamicControllers = {};
  final List<ScoringItem> _scoringItems = [];

  List<MindMapNode> _mindMapNodes = [];
  String _customWorkspaceValue = '';

  void _onMethodChanged(String methodKey) {
    // Reset visual workspace variables
    _mindMapNodes = [];
    _customWorkspaceValue = '';
    _summaryController.clear();

    // Clear and dispose previous dynamic controllers
    _dynamicControllers.forEach((_, controller) => controller.dispose());
    _dynamicControllers.clear();

    for (var item in _scoringItems) {
      item.nameController.dispose();
    }
    _scoringItems.clear();

    final method = ThinkingMethod.allMethods.firstWhere(
      (m) => m.key == methodKey,
    );

    if (method.template == WorkspaceTemplate.multiColumn &&
        method.columns != null) {
      for (final col in method.columns!) {
        _dynamicControllers[col] = TextEditingController();
      }
    } else if (method.template == WorkspaceTemplate.sequential &&
        method.stepLabels != null) {
      for (final step in method.stepLabels!) {
        _dynamicControllers[step] = TextEditingController();
      }
    } else if (method.template == WorkspaceTemplate.scoring) {
      _addScoringRow();
      _addScoringRow(); // start with 2 empty rows
    }

    setState(() {
      _selectedMethod = methodKey;
    });
  }

  void _addScoringRow() {
    setState(() {
      _scoringItems.add(
        ScoringItem(
          nameController: TextEditingController(),
          impact: 3,
          ease: 3,
        ),
      );
    });
  }

  void _removeScoringRow(int index) {
    if (_scoringItems.length > 1) {
      setState(() {
        _scoringItems[index].nameController.dispose();
        _scoringItems.removeAt(index);
      });
    }
  }

  Widget _buildMethodGuidelineCard(ThemeData theme) {
    final method = ThinkingMethod.allMethods.firstWhere(
      (m) => m.key == _selectedMethod,
    );
    final steps = method.steps;
    final format = method.format;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: theme.colorScheme.primary, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Panduan Coretan Kertas Fisik',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...steps.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final step = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$idx. ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      fontSize: 12,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      step,
                      style: const TextStyle(fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          const Divider(height: 16),
          const Text(
            'Rekomendasi Format Kertas:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
              ),
            ),
            child: Text(
              format,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 16),
          // Timer section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Timer Sesi:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatCanvasTime(_canvasSecondsRemaining),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                if (!_canvasTimerActive)
                  DropdownButton<int>(
                    value: _canvasSelectedMinutes,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface,
                    ),
                    underline: const SizedBox(),
                    items: [1, 2, 3, 5, 7, 10, 15].map((m) {
                      return DropdownMenuItem(value: m, child: Text('$m mnt'));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        _changeCanvasTimerDuration(val);
                      }
                    },
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    _canvasTimerActive
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_filled_rounded,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  onPressed: () {
                    if (_canvasTimerActive) {
                      _pauseCanvasTimer();
                    } else {
                      _startCanvasTimer();
                    }
                  },
                ),
                if (!_canvasTimerActive &&
                    _canvasSecondsRemaining != _canvasSelectedMinutes * 60) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.replay_rounded, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    onPressed: _resetCanvasTimer,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCanvasSession() async {
    if (!_formKey.currentState!.validate()) return;

    final db = ref.read(dbProvider);
    final now = DateTime.now();

    // Get user id
    final profiles = await db.select(db.userProfiles).get();
    if (profiles.isEmpty) return;
    final userId = profiles.first.userId;

    final sessionId = const Uuid().v4();
    String? createdHabitId;

    final actionText = _actionController.text.trim();

    // If user checked "Add to Habits", insert a new habit in the selected domain
    if (_addToHabits && actionText.isNotEmpty) {
      createdHabitId = const Uuid().v4();
      await db
          .into(db.habits)
          .insert(
            HabitsCompanion.insert(
              habitId: createdHabitId,
              userId: userId,
              domainTag: drift.Value(_habitDomain),
              title: actionText,
              status: const drift.Value(HabitStatus.active),
              frequency: const drift.Value('Daily'),
              initiationFriction: const drift.Value(
                2,
              ), // low friction default for next action steps
              originalFriction: const drift.Value(2),
              energyCost: const drift.Value(2),
              impactScore: const drift.Value(4),
              createdAt: now,
            ),
          );

      await db
          .into(db.reminderPreferences)
          .insert(ReminderPreferencesCompanion.insert(habitId: createdHabitId));
    }

    String finalSummary = '';
    final method = ThinkingMethod.allMethods.firstWhere(
      (m) => m.key == _selectedMethod,
    );
    if (method.template == WorkspaceTemplate.freeform) {
      if (_selectedMethod == 'MindMapping') {
        finalSummary = jsonEncode({
          'mind_map': _mindMapNodes.map((n) => n.toJson()).toList(),
        });
      } else if (_customWorkspaceValue.isNotEmpty) {
        finalSummary = _customWorkspaceValue;
      } else {
        finalSummary = _summaryController.text.trim();
      }
    } else if (method.template == WorkspaceTemplate.multiColumn) {
      final data = <String, String>{};
      _dynamicControllers.forEach((key, controller) {
        data[key] = controller.text.trim();
      });
      finalSummary = jsonEncode(data);
    } else if (method.template == WorkspaceTemplate.sequential) {
      final data = <String, String>{};
      _dynamicControllers.forEach((key, controller) {
        data[key] = controller.text.trim();
      });
      finalSummary = jsonEncode(data);
    } else if (method.template == WorkspaceTemplate.scoring) {
      final data = _scoringItems
          .map(
            (item) => {
              'name': item.nameController.text.trim(),
              'impact': item.impact,
              'ease': item.ease,
              'total': item.impact * item.ease,
            },
          )
          .toList();
      finalSummary = jsonEncode({'items': data});
    }

    final newSession = ThinkingCanvasSessionsCompanion.insert(
      sessionId: sessionId,
      userId: userId,
      methodKey: _selectedMethod,
      topic: drift.Value(
        _topicController.text.trim().isEmpty
            ? null
            : _topicController.text.trim(),
      ),
      summaryText: drift.Value(finalSummary.isEmpty ? null : finalSummary),
      nextAction: drift.Value(actionText.isEmpty ? null : actionText),
      paperArtifactRef: drift.Value(
        _refController.text.trim().isEmpty ? null : _refController.text.trim(),
      ),
      paperSession: const drift.Value(true),
      linkedHabitId: drift.Value(createdHabitId),
      createdAt: now,
    );

    await db.into(db.thinkingCanvasSessions).insert(newSession);

    ref.invalidate(dashboardDataProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesi Thinking Canvas berhasil dicatat!'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    }
  }

  Timer? _canvasTimer;
  int _canvasSecondsRemaining = 300;
  int _canvasSelectedMinutes = 5;
  bool _canvasTimerActive = false;

  void _startCanvasTimer() {
    _canvasTimer?.cancel();
    setState(() {
      _canvasTimerActive = true;
    });
    _canvasTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_canvasSecondsRemaining <= 1) {
        setState(() {
          _canvasSecondsRemaining = 0;
          _canvasTimerActive = false;
        });
        _canvasTimer?.cancel();
        _showCanvasTimerFinishedDialog();
      } else {
        setState(() {
          _canvasSecondsRemaining--;
        });
      }
    });
  }

  void _pauseCanvasTimer() {
    _canvasTimer?.cancel();
    setState(() {
      _canvasTimerActive = false;
    });
  }

  void _resetCanvasTimer() {
    _canvasTimer?.cancel();
    setState(() {
      _canvasTimerActive = false;
      _canvasSecondsRemaining = _canvasSelectedMinutes * 60;
    });
  }

  void _changeCanvasTimerDuration(int minutes) {
    _canvasTimer?.cancel();
    setState(() {
      _canvasTimerActive = false;
      _canvasSelectedMinutes = minutes;
      _canvasSecondsRemaining = minutes * 60;
    });
  }

  void _showCanvasTimerFinishedDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Waktu Sesi Habis! ⏱️'),
          content: const Text(
            'Sesi coretan kertas Anda telah mencapai batas waktu.\n\n'
            'Mari ringkas poin-poin utama Anda di lembar kerja digital di bawah.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Lanjut ke Digitalisasi'),
            ),
          ],
        );
      },
    );
  }

  String _formatCanvasTime(int totalSeconds) {
    final mins = totalSeconds ~/ 60;
    final secs = totalSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  bool _isPremiumUserCached = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstTimeUsage();
      _loadPremiumStatus();
    });
  }

  Future<void> _loadPremiumStatus() async {
    final status = await _isUserPremium();
    if (mounted) {
      setState(() {
        _isPremiumUserCached = status;
      });
    }
  }

  bool _dontShowOnboardingAgain = false;

  Future<File> _getSettingsFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/hide_canvas_onboarding.txt');
  }

  Future<void> _loadOnboardingPreference() async {
    try {
      final file = await _getSettingsFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        _dontShowOnboardingAgain = content.trim() == 'true';
      }
    } catch (e, stackTrace) {
      ErrorHandlerService().logError(
        e,
        stackTrace,
        context: 'ThinkingCanvasLiteView.loadOnboardingPreference',
      );
    }
  }

  Future<void> _setHideOnboarding(bool hide) async {
    try {
      final file = await _getSettingsFile();
      if (hide) {
        await file.writeAsString('true');
      } else {
        if (await file.exists()) {
          await file.delete();
        }
      }
      setState(() {
        _dontShowOnboardingAgain = hide;
      });
    } catch (e, stackTrace) {
      ErrorHandlerService().logError(
        e,
        stackTrace,
        context: 'ThinkingCanvasLiteView.setHideOnboarding',
      );
    }
  }

  Future<void> _checkFirstTimeUsage() async {
    await _loadOnboardingPreference();
    if (_dontShowOnboardingAgain) return;

    final db = ref.read(dbProvider);
    final sessions = await db.select(db.thinkingCanvasSessions).get();
    if (sessions.isEmpty && mounted) {
      _showOnboardingGuide();
    }
  }

  void _showOnboardingGuide() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return ThinkingCanvasOnboardingDialog(
          onMethodSelected: (method) {
            _onMethodChanged(method);
          },
          initialDontShowAgain: _dontShowOnboardingAgain,
          onDontShowAgainChanged: (val) {
            _setHideOnboarding(val);
          },
        );
      },
    );
  }

  Future<bool> _isUserPremium() async {
    final db = ref.read(dbProvider);
    final profiles = await db.select(db.userProfiles).get();
    if (profiles.isNotEmpty) {
      final p = profiles.first;
      return p.unlockedSkins.contains('Sakura') ||
          p.unlockedSkins.contains('Maple') ||
          p.unlockedSkins.contains('Bonsai');
    }
    return false;
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Fitur Premium 👑'),
          content: const Text(
            'Metode berpikir tingkat lanjut dan workspace interaktif ini eksklusif untuk pengguna Premium.\n\n'
            'Aktifkan Mode Developer di menu dashboard utama untuk membuka kunci seluruh fitur premium secara gratis!',
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

  void _showMethodPickerSheet() async {
    final isPremiumUser = await _isUserPremium();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return MethodPickerBottomSheet(
          currentMethodKey: _selectedMethod,
          isPremiumUser: isPremiumUser,
          onSelected: (key) {
            _onMethodChanged(key);
          },
        );
      },
    );
  }

  Widget _buildWorkspace(ThemeData theme) {
    final method = ThinkingMethod.allMethods.firstWhere(
      (m) => m.key == _selectedMethod,
    );
    switch (method.template) {
      case WorkspaceTemplate.freeform:
        if (_selectedMethod == 'MindMapping') {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '4. Kanvas Mind Map Visual',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                _mindMapNodes.isEmpty
                    ? 'Belum ada peta pikiran yang dibuat. Buat visual mind map sekarang!'
                    : 'Peta pikiran aktif: ${_mindMapNodes.length} gelembung ide.',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MindMapCanvasView(
                        initialNodes: _mindMapNodes,
                        onSaved: (nodes) {
                          setState(() {
                            _mindMapNodes = nodes;
                          });
                        },
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.palette_rounded),
                label: const Text('Buka Editor Kanvas Visual 🎨'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          );
        } else if (_selectedMethod == 'Freewriting') {
          return FreewritingWorkspace(controller: _summaryController);
        } else if (_selectedMethod == 'LotusBlossom') {
          return LotusBlossomWorkspace(
            onChanged: (val) => _customWorkspaceValue = val,
          );
        } else if (_selectedMethod == 'MorphologicalAnalysis') {
          return MorphologicalWorkspace(
            onChanged: (val) => _customWorkspaceValue = val,
            isPremiumUser: _isPremiumUserCached,
            onPremiumLocked: _showPremiumDialog,
          );
        } else if (_selectedMethod == 'Brainstorming' ||
            _selectedMethod == 'WorstPossibleIdea') {
          return RapidBrainstormWorkspace(
            onChanged: (val) => _customWorkspaceValue = val,
          );
        } else if (_selectedMethod == 'QuestionStorming') {
          return QuestionStormWorkspace(
            onChanged: (val) => _customWorkspaceValue = val,
          );
        } else if (_selectedMethod == 'RandomWord') {
          return RandomWordWorkspace(
            onChanged: (val) => _customWorkspaceValue = val,
          );
        } else if (_selectedMethod == 'RoleStorming') {
          return RoleStormingWorkspace(
            onChanged: (val) => _customWorkspaceValue = val,
            isPremiumUser: _isPremiumUserCached,
            onPremiumLocked: _showPremiumDialog,
          );
        } else if (_selectedMethod == 'SixThinkingHats') {
          return SixThinkingHatsWorkspace(
            onChanged: (val) => _customWorkspaceValue = val,
          );
        } else if (_selectedMethod == 'DisneyStrategy') {
          return DisneyStrategyWorkspace(
            onChanged: (val) => _customWorkspaceValue = val,
          );
        } else if (_selectedMethod == 'SCAMPER') {
          return ScamperWorkspace(
            onChanged: (val) => _customWorkspaceValue = val,
          );
        } else if (_selectedMethod == 'SWOT') {
          return SwotMatrixWorkspace(
            onChanged: (val) => _customWorkspaceValue = val,
          );
        } else if (_selectedMethod == 'Starbursting') {
          return StarburstingWorkspace(
            onChanged: (val) => _customWorkspaceValue = val,
          );
        } else if (_selectedMethod == 'MindDump') {
          return MindDumpWorkspace(
            onChanged: (val) => _customWorkspaceValue = val,
          );
        } else if (_selectedMethod == 'AffinityMapping') {
          return AffinityMappingWorkspace(
            onChanged: (val) => _customWorkspaceValue = val,
          );
        } else if (_selectedMethod == '5Whys') {
          return FiveWhysWorkspace(
            onChanged: (val) => _customWorkspaceValue = val,
          );
        } else if (_selectedMethod == 'FirstPrinciples') {
          return FirstPrinciplesWorkspace(
            onChanged: (val) => _customWorkspaceValue = val,
          );
        } else if (_selectedMethod == 'DoubleDiamond') {
          return DoubleDiamondWorkspace(
            onChanged: (val) => _customWorkspaceValue = val,
          );
        } else if (_selectedMethod == 'Validation') {
          return ValidationWorkspace(
            onChanged: (val) => _customWorkspaceValue = val,
          );
        }

        // Fallback for default freeform (e.g. Mind Dump)
        return TextFormField(
          controller: _summaryController,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: '4. Ringkasan Hasil Berpikir',
            hintText:
                method.placeholder ?? 'Tuliskan hasil berpikir Anda di sini...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Harap masukkan hasil berpikir Anda';
            }
            return null;
          },
        );

      case WorkspaceTemplate.multiColumn:
        final columns = method.columns ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '4. Input Kolom Hasil Berpikir',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            ...columns.map((col) {
              final controller =
                  _dynamicControllers[col] ?? TextEditingController();
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextFormField(
                  controller: controller,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: col,
                    hintText: 'Masukkan poin untuk kolom $col...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Kolom $col tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              );
            }),
          ],
        );

      case WorkspaceTemplate.sequential:
        final steps = method.stepLabels ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '4. Langkah Berurutan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            ...steps.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final stepLabel = entry.value;
              final controller =
                  _dynamicControllers[stepLabel] ?? TextEditingController();
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextFormField(
                  controller: controller,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Langkah $idx: $stepLabel',
                    hintText: 'Tulis tanggapan langkah ini...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Langkah ini tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              );
            }),
          ],
        );

      case WorkspaceTemplate.scoring:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '4. Tabel Skoring Ide',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                TextButton.icon(
                  onPressed: _addScoringRow,
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                  label: const Text(
                    'Tambah Opsi',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._scoringItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final totalScore = item.impact * item.ease;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: item.nameController,
                              decoration: InputDecoration(
                                labelText: 'Opsi Ide ${index + 1}',
                                hintText: 'Misal: Buka jasa kurir sayur',
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Nama opsi ide tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                          ),
                          if (_scoringItems.length > 1)
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                              onPressed: () => _removeScoringRow(index),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dampak: ${item.impact}/5',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Slider(
                                  value: item.impact.toDouble(),
                                  min: 1,
                                  max: 5,
                                  divisions: 4,
                                  onChanged: (val) {
                                    setState(() {
                                      item.impact = val.toInt();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kemudahan: ${item.ease}/5',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Slider(
                                  value: item.ease.toDouble(),
                                  min: 1,
                                  max: 5,
                                  divisions: 4,
                                  onChanged: (val) {
                                    setState(() {
                                      item.ease = val.toInt();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'SKOR',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '$totalScore',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
    }
  }

  @override
  void dispose() {
    _canvasTimer?.cancel();
    _topicController.dispose();
    _summaryController.dispose();
    _actionController.dispose();
    _refController.dispose();
    _dynamicControllers.forEach((_, controller) => controller.dispose());
    for (var item in _scoringItems) {
      item.nameController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeMethod = ThinkingMethod.allMethods.firstWhere(
      (m) => m.key == _selectedMethod,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thinking Canvas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'Panduan Metode',
            onPressed: _showOnboardingGuide,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Urai Pikiran Anda di Kertas 📝',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Prinsip LifeTree: Paper-First. Tulislah coretan Anda di buku atau kertas asli terlebih dahulu untuk mengurangi screen fatigue.',
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),

              // Method Selector
              const Text(
                '1. Metode Berpikir',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _showMethodPickerSheet,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  activeMethod.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                if (activeMethod.isPremium) ...[
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.lock_rounded,
                                    color: Colors.amber[700],
                                    size: 14,
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              activeMethod.desc,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down_rounded,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
              _buildMethodGuidelineCard(theme),
              const SizedBox(height: 24),

              // Topic
              TextFormField(
                controller: _topicController,
                decoration: InputDecoration(
                  labelText: '2. Topik / Masalah yang Sedang Dipikirkan',
                  hintText:
                      'Misal: Memilih opsi karir baru atau mengurai burnout',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Harap masukkan topik yang sedang dipikirkan';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Paper Artifact Ref
              TextFormField(
                controller: _refController,
                decoration: InputDecoration(
                  labelText: '3. Referensi Kertas Fisik (Opsional)',
                  hintText:
                      'Misal: Buku Jurnal A hal. 14, Sticky note meja kerja',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.menu_book_rounded),
                ),
              ),
              const SizedBox(height: 24),

              // Dynamic Workspace
              _buildWorkspace(theme),
              const SizedBox(height: 24),

              // Next Action
              TextFormField(
                controller: _actionController,
                decoration: InputDecoration(
                  labelText: '5. Satu Aksi Kecil Berikutnya (Next Small Step)',
                  hintText:
                      'Aksi sangat kecil, misal: Cari info kontak dokter olahraga',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Harap tentukan satu aksi kecil berikutnya';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Checkbox to automatically add to habits
              Row(
                children: [
                  Checkbox(
                    value: _addToHabits,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (val) {
                      setState(() {
                        _addToHabits = val ?? false;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'Masukkan aksi kecil ini ke daftar kebiasaan hari ini',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),

              if (_addToHabits) ...[
                const SizedBox(height: 12),
                const Text(
                  'Domain Kebiasaan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _habitDomain,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Tubuh',
                      child: Text('Tubuh (Body) 🏃'),
                    ),
                    DropdownMenuItem(
                      value: 'Keuangan',
                      child: Text('Keuangan (Finance) 💰'),
                    ),
                    DropdownMenuItem(
                      value: 'Hubungan',
                      child: Text('Hubungan (Relations) 🤝'),
                    ),
                    DropdownMenuItem(
                      value: 'Emosi',
                      child: Text('Emosi (Emotion) 🧠'),
                    ),
                    DropdownMenuItem(
                      value: 'Karir',
                      child: Text('Karir/Belajar (Career) 📚'),
                    ),
                    DropdownMenuItem(
                      value: 'Rekreasi',
                      child: Text('Rekreasi (Recreation) 🎮'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _habitDomain = val;
                      });
                    }
                  },
                ),
              ],

              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _saveCanvasSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  minimumSize: const Size(88, 52), // WCAG touch target
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Simpan Sesi',
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
