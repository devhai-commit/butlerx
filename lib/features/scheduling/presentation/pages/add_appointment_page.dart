import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/appointment.dart';
import '../providers/schedule_notifier.dart';

class AddAppointmentPage extends ConsumerStatefulWidget {
  const AddAppointmentPage({super.key, this.initial});

  final Appointment? initial;

  @override
  ConsumerState<AddAppointmentPage> createState() => _AddAppointmentPageState();
}

class _AddAppointmentPageState extends ConsumerState<AddAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _descCtrl;

  late DateTime _startAt;
  DateTime? _endAt;
  late ReminderOffset _reminder;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final a = widget.initial;
    _titleCtrl = TextEditingController(text: a?.title ?? '');
    _locationCtrl = TextEditingController(text: a?.location ?? '');
    _descCtrl = TextEditingController(text: a?.description ?? '');
    _startAt = a?.startAt ?? _defaultStart();
    _endAt = a?.endAt;
    _reminder = a?.reminderOffset ?? ReminderOffset.fifteenMin;
  }

  DateTime _defaultStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, now.hour + 1, 0);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickStart() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startAt,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startAt),
    );
    if (!mounted) return;
    setState(() {
      _startAt = DateTime(
        date.year, date.month, date.day,
        time?.hour ?? _startAt.hour,
        time?.minute ?? _startAt.minute,
      );
      if (_endAt != null && _endAt!.isBefore(_startAt)) _endAt = null;
    });
  }

  Future<void> _pickEnd() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endAt ?? _startAt,
      firstDate: _startAt,
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endAt ?? _startAt.add(const Duration(hours: 1))),
    );
    if (!mounted) return;
    setState(() {
      _endAt = DateTime(
        date.year, date.month, date.day,
        time?.hour ?? (_startAt.hour + 1),
        time?.minute ?? 0,
      );
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final notifier = ref.read(scheduleNotifierProvider.notifier);
      if (widget.initial != null) {
        await notifier.updateAppointment(
          widget.initial!.copyWith(
            title: _titleCtrl.text.trim(),
            startAt: _startAt,
            endAt: _endAt,
            location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
            description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
            reminderOffset: _reminder,
          ),
        );
      } else {
        final authState = ref.read(authNotifierProvider);
        final uid = authState is AuthAuthenticated ? authState.profile.uid : '';
        await notifier.addAppointment(
          Appointment(
            userId: uid,
            title: _titleCtrl.text.trim(),
            startAt: _startAt,
            endAt: _endAt,
            location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
            description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
            reminderOffset: _reminder,
          ),
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _formatDateTime(DateTime dt) {
    final d = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    final t = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '$d  $t';
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Sửa lịch hẹn' : 'Thêm lịch hẹn'),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
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
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề *',
                prefixIcon: Icon(Icons.event_note_outlined),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tiêu đề' : null,
            ),
            const SizedBox(height: 16),
            _DateTimeField(
              label: 'Bắt đầu *',
              icon: Icons.calendar_today_outlined,
              value: _formatDateTime(_startAt),
              onTap: _pickStart,
            ),
            const SizedBox(height: 16),
            _DateTimeField(
              label: 'Kết thúc (tuỳ chọn)',
              icon: Icons.timer_off_outlined,
              value: _endAt != null ? _formatDateTime(_endAt!) : 'Chưa đặt',
              onTap: _pickEnd,
              trailing: _endAt != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _endAt = null),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationCtrl,
              decoration: const InputDecoration(
                labelText: 'Địa điểm',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Ghi chú',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ReminderOffset>(
              value: _reminder,
              decoration: const InputDecoration(
                labelText: 'Nhắc nhở',
                prefixIcon: Icon(Icons.notifications_outlined),
              ),
              items: ReminderOffset.values
                  .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
                  .toList(),
              onChanged: (v) => setState(() => _reminder = v ?? _reminder),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.save_outlined),
              label: Text(isEdit ? 'Cập nhật' : 'Lưu lịch hẹn'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateTimeField extends StatelessWidget {
  const _DateTimeField({
    required this.label,
    required this.icon,
    required this.value,
    required this.onTap,
    this.trailing,
  });

  final String label;
  final IconData icon;
  final String value;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: trailing,
        ),
        child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}
