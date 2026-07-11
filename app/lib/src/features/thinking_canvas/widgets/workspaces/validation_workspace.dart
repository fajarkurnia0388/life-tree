import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/i18n/daoji_text_key.dart';
import '../../../../core/i18n/daoji_text_resolver.dart';
import '../../../../core/i18n/daoji_vocabulary_provider.dart';

// ==========================================
// 6. VALIDATION WORKSPACE (SCORECARD)
// ==========================================
class ValidationWorkspace extends ConsumerStatefulWidget {
  final ValueChanged<String> onChanged;
  const ValidationWorkspace({super.key, required this.onChanged});

  @override
  ConsumerState<ValidationWorkspace> createState() =>
      _ValidationWorkspaceState();
}


class _ValidationWorkspaceState extends ConsumerState<ValidationWorkspace> {
  final TextEditingController _asumsiController = TextEditingController();
  final List<String> _supports = [];
  final List<String> _opposes = [];
  bool _isValidated = true;

  final TextEditingController _supportInput = TextEditingController();
  final TextEditingController _opposeInput = TextEditingController();

  @override
  void initState() {
    super.initState();
    _asumsiController.addListener(_notifyChanges);
  }

  @override
  void dispose() {
    _asumsiController.removeListener(_notifyChanges);
    _asumsiController.dispose();
    _supportInput.dispose();
    _opposeInput.dispose();
    super.dispose();
  }

  void _addSupport() {
    final text = _supportInput.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _supports.add(text);
        _supportInput.clear();
      });
      _notifyChanges();
    }
  }

  void _addOppose() {
    final text = _opposeInput.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _opposes.add(text);
        _opposeInput.clear();
      });
      _notifyChanges();
    }
  }

  void _removeSupport(int index) {
    setState(() {
      _supports.removeAt(index);
    });
    _notifyChanges();
  }

  void _removeOppose(int index) {
    setState(() {
      _opposes.removeAt(index);
    });
    _notifyChanges();
  }

  void _toggleValidation(bool val) {
    setState(() {
      _isValidated = val;
    });
    _notifyChanges();
  }

  void _notifyChanges() {
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);
    final buffer = StringBuffer();
    buffer.writeln('Lembar Validasi Asumsi Ide:');
    buffer.writeln('- ASUMSI UTAMA: ${_asumsiController.text.trim()}');
    buffer.writeln(
      '- STATUS VALIDASI: ${_isValidated ? "VALID (Terbukti) 🟢" : "GUGUR (Terbantahkan) 🔴"}',
    );
    buffer.writeln('- BUKTI PENDUKUNG (Supports):');
    if (_supports.isEmpty) {
      buffer.writeln('  (Tidak ada)');
    }
    for (final s in _supports) {
      buffer.writeln('  + $s');
    }
    buffer.writeln(
      '- ${DaojiText.resolve(DaojiTextKey.validationOpposeTitle, vocabularyLevel)} (Opposes):',
    );
    if (_opposes.isEmpty) {
      buffer.writeln(
        '  ${DaojiText.resolve(DaojiTextKey.validationNoOpposes, vocabularyLevel)}',
      );
    }
    for (final o in _opposes) {
      buffer.writeln('  - $o');
    }
    widget.onChanged(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DaojiText.resolve(DaojiTextKey.validationTitle, vocabularyLevel),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _asumsiController,
          style: const TextStyle(fontSize: 12),
          decoration: InputDecoration(
            labelText: DaojiText.resolve(
              DaojiTextKey.validationAssumptionLabel,
              vocabularyLevel,
            ),
            hintText: DaojiText.resolve(
              DaojiTextKey.validationAssumptionHint,
              vocabularyLevel,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _isValidated
                ? Colors.green.withValues(alpha: 0.06)
                : Colors.red.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isValidated
                  ? Colors.green.withValues(alpha: 0.3)
                  : Colors.red.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DaojiText.resolve(
                  DaojiTextKey.validationResultTitle,
                  vocabularyLevel,
                ),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _isValidated ? Colors.green : Colors.red,
                ),
              ),
              Row(
                children: [
                  Text(
                    DaojiText.resolve(
                      _isValidated
                          ? DaojiTextKey.validationValidState
                          : DaojiTextKey.validationInvalidState,
                      vocabularyLevel,
                    ),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: _isValidated,
                    onChanged: _toggleValidation,
                    activeThumbColor: Colors.green,
                    inactiveThumbColor: Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    DaojiText.resolve(
                      DaojiTextKey.validationSupportTitle,
                      vocabularyLevel,
                    ),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _supportInput,
                    style: const TextStyle(fontSize: 11),
                    decoration: InputDecoration(
                      labelText: DaojiText.resolve(
                        DaojiTextKey.validationSupportInputLabel,
                        vocabularyLevel,
                      ),
                      hintText: DaojiText.resolve(
                        DaojiTextKey.validationSupportInputHint,
                        vocabularyLevel,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: _addSupport,
                        child: const Icon(
                          Icons.add_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                    ),
                    onSubmitted: (_) => _addSupport(),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(_supports.length, (index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: Colors.green.withValues(alpha: 0.03),
                      child: ListTile(
                        title: Text(
                          _supports[index],
                          style: const TextStyle(fontSize: 10),
                        ),
                        trailing: GestureDetector(
                          onTap: () => _removeSupport(index),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 12,
                            color: Colors.redAccent,
                          ),
                        ),
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 6,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    DaojiText.resolve(
                      DaojiTextKey.validationOpposeTitle,
                      vocabularyLevel,
                    ),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _opposeInput,
                    style: const TextStyle(fontSize: 11),
                    decoration: InputDecoration(
                      labelText: DaojiText.resolve(
                        DaojiTextKey.validationOpposeInputLabel,
                        vocabularyLevel,
                      ),
                      hintText: DaojiText.resolve(
                        DaojiTextKey.validationOpposeInputHint,
                        vocabularyLevel,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: _addOppose,
                        child: const Icon(
                          Icons.add_circle,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                    ),
                    onSubmitted: (_) => _addOppose(),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(_opposes.length, (index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: Colors.red.withValues(alpha: 0.03),
                      child: ListTile(
                        title: Text(
                          _opposes[index],
                          style: const TextStyle(fontSize: 10),
                        ),
                        trailing: GestureDetector(
                          onTap: () => _removeOppose(index),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 12,
                            color: Colors.redAccent,
                          ),
                        ),
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 6,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
