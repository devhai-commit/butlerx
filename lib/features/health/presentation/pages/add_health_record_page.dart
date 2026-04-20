import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/health_record.dart';
import '../providers/health_notifier.dart';

class AddHealthRecordPage extends ConsumerStatefulWidget {
  const AddHealthRecordPage({super.key});

  @override
  ConsumerState<AddHealthRecordPage> createState() =>
      _AddHealthRecordPageState();
}

class _AddHealthRecordPageState extends ConsumerState<AddHealthRecordPage> {
  final _formKey = GlobalKey<FormState>();

  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _systolicCtrl = TextEditingController();
  final _diastolicCtrl = TextEditingController();
  final _heartRateCtrl = TextEditingController();
  final _bloodSugarCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _systolicCtrl.dispose();
    _diastolicCtrl.dispose();
    _heartRateCtrl.dispose();
    _bloodSugarCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = ref.read(authNotifierProvider);
    final uid = authState is AuthAuthenticated ? authState.profile.uid : '';

    final record = HealthRecord(
      userId: uid,
      recordedAt: DateTime.now(),
      weightKg: _weightCtrl.text.trim().isEmpty
          ? null
          : double.tryParse(_weightCtrl.text.trim()),
      heightCm: _heightCtrl.text.trim().isEmpty
          ? null
          : double.tryParse(_heightCtrl.text.trim()),
      bloodPressureSystolic: _systolicCtrl.text.trim().isEmpty
          ? null
          : int.tryParse(_systolicCtrl.text.trim()),
      bloodPressureDiastolic: _diastolicCtrl.text.trim().isEmpty
          ? null
          : int.tryParse(_diastolicCtrl.text.trim()),
      heartRateBpm: _heartRateCtrl.text.trim().isEmpty
          ? null
          : int.tryParse(_heartRateCtrl.text.trim()),
      bloodSugarMmol: _bloodSugarCtrl.text.trim().isEmpty
          ? null
          : double.tryParse(_bloodSugarCtrl.text.trim()),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    setState(() => _saving = true);
    try {
      await ref.read(healthNotifierProvider.notifier).addRecord(record);
      if (mounted) Navigator.of(context).pop(true);
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghi chép sức khoẻ'),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            )
          else
            TextButton(onPressed: _save, child: const Text('Lưu')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionHeader(label: 'Cơ thể'),
            Row(
              children: [
                Expanded(
                  child: _NumberField(
                    controller: _weightCtrl,
                    label: 'Cân nặng (kg)',
                    hint: 'vd: 65.5',
                    decimal: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _NumberField(
                    controller: _heightCtrl,
                    label: 'Chiều cao (cm)',
                    hint: 'vd: 170',
                    decimal: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionHeader(label: 'Huyết áp (mmHg)'),
            Row(
              children: [
                Expanded(
                  child: _NumberField(
                    controller: _systolicCtrl,
                    label: 'Tâm thu',
                    hint: 'vd: 120',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _NumberField(
                    controller: _diastolicCtrl,
                    label: 'Tâm trương',
                    hint: 'vd: 80',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionHeader(label: 'Chỉ số khác'),
            Row(
              children: [
                Expanded(
                  child: _NumberField(
                    controller: _heartRateCtrl,
                    label: 'Nhịp tim (bpm)',
                    hint: 'vd: 72',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _NumberField(
                    controller: _bloodSugarCtrl,
                    label: 'Đường huyết (mmol/L)',
                    hint: 'vd: 5.5',
                    decimal: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Ghi chú',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Lưu kết quả'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelMedium
            ?.copyWith(color: cs.primary, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.hint,
    this.decimal = false,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool decimal;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, hintText: hint),
      keyboardType:
          TextInputType.numberWithOptions(decimal: decimal, signed: false),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
            decimal ? RegExp(r'[\d.]') : RegExp(r'\d')),
      ],
    );
  }
}
