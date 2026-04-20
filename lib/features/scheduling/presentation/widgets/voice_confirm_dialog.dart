import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/voice_intent_parser.dart';
import '../providers/schedule_notifier.dart';

class VoiceConfirmDialog extends ConsumerWidget {
  const VoiceConfirmDialog({super.key, required this.parsed, required this.transcript});

  final ParsedAppointment parsed;
  final String? transcript;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final start = parsed.startAt;
    final dateStr =
        '${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')}/${start.year}';
    final timeStr =
        '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';

    return AlertDialog(
      title: const Text('Xác nhận lịch hẹn'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (transcript != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('"$transcript"',
                    style: tt.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic, color: cs.outline)),
              ),
              const SizedBox(height: 16),
            ],
            _Row(icon: Icons.event_note_outlined, label: 'Tiêu đề', value: parsed.title),
            const SizedBox(height: 8),
            _Row(icon: Icons.calendar_today_outlined, label: 'Ngày', value: dateStr),
            const SizedBox(height: 8),
            _Row(icon: Icons.access_time_outlined, label: 'Giờ', value: timeStr),
            if (parsed.endAt != null) ...[
              const SizedBox(height: 8),
              _Row(
                icon: Icons.timer_off_outlined,
                label: 'Kết thúc',
                value:
                    '${parsed.endAt!.hour.toString().padLeft(2, '0')}:${parsed.endAt!.minute.toString().padLeft(2, '0')}',
              ),
            ],
            if (parsed.location != null) ...[
              const SizedBox(height: 8),
              _Row(
                  icon: Icons.location_on_outlined,
                  label: 'Địa điểm',
                  value: parsed.location!),
            ],
            if (parsed.description != null) ...[
              const SizedBox(height: 8),
              _Row(
                  icon: Icons.notes_outlined,
                  label: 'Ghi chú',
                  value: parsed.description!),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(scheduleNotifierProvider.notifier).cancelVoicePending();
            Navigator.of(context).pop();
          },
          child: const Text('Huỷ'),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await ref
                .read(scheduleNotifierProvider.notifier)
                .confirmVoiceAppointment();
          },
          child: const Text('Lưu lịch hẹn'),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: cs.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: cs.outline)),
              Text(value, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
