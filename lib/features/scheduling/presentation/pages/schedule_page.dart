import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/appointment.dart';
import '../../domain/entities/special_occasion.dart';
import '../providers/schedule_notifier.dart';
import '../widgets/voice_confirm_dialog.dart';
import 'add_appointment_page.dart';

class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scheduleNotifierProvider);
    final notifier = ref.read(scheduleNotifierProvider.notifier);
    final cs = Theme.of(context).colorScheme;

    // Show voice confirm dialog when state changes to confirmPending
    ref.listen(scheduleNotifierProvider, (prev, next) {
      if (next.voiceState == VoiceState.confirmPending &&
          next.pendingParsed != null &&
          prev?.voiceState != VoiceState.confirmPending) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => VoiceConfirmDialog(
            parsed: next.pendingParsed!,
            transcript: next.pendingTranscript,
          ),
        );
      }
    });

    // Show error snackbar
    ref.listen(scheduleNotifierProvider.select((s) => s.error), (_, error) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: cs.error,
            action: SnackBarAction(
              label: 'OK',
              textColor: cs.onError,
              onPressed: notifier.clearError,
            ),
          ),
        );
      }
    });

    final selectedDay = state.selectedDay ?? DateTime.now();
    final dayAppts = state.forDay(selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch hẹn'),
        actions: [
          _VoiceFab(state: state, notifier: notifier),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddPage(context),
        tooltip: 'Thêm lịch hẹn',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _MonthCalendar(
            focusedMonth: _focusedMonth,
            selectedDay: selectedDay,
            appointments: state.appointments,
            onDaySelected: (day) => notifier.selectDay(day),
            onMonthChanged: (m) => setState(() => _focusedMonth = m),
          ),
          if (state.upcomingHolidays.isNotEmpty)
            _HolidayBanner(holiday: state.upcomingHolidays.first),
          Expanded(
            child: _AgendaList(
              day: selectedDay,
              appointments: dayAppts,
              onEdit: (a) => _openEditPage(context, a),
              onDelete: (id) => _confirmDelete(context, id, notifier),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAddPage(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddAppointmentPage()),
    );
  }

  Future<void> _openEditPage(BuildContext context, Appointment appt) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddAppointmentPage(initial: appt)),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, String id, ScheduleNotifier notifier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xoá lịch hẹn?'),
        content: const Text('Lịch hẹn này sẽ bị xoá và không thể khôi phục.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Huỷ')),
          FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Xoá')),
        ],
      ),
    );
    if (confirmed == true) await notifier.deleteAppointment(id);
  }
}

// ── Month Calendar ────────────────────────────────────────────────────────────

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({
    required this.focusedMonth,
    required this.selectedDay,
    required this.appointments,
    required this.onDaySelected,
    required this.onMonthChanged,
  });

  final DateTime focusedMonth;
  final DateTime selectedDay;
  final List<Appointment> appointments;
  final void Function(DateTime) onDaySelected;
  final void Function(DateTime) onMonthChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final daysInMonth =
        DateUtils.getDaysInMonth(focusedMonth.year, focusedMonth.month);
    final firstWeekday =
        DateTime(focusedMonth.year, focusedMonth.month, 1).weekday % 7;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [BoxShadow(color: cs.shadow.withValues(alpha: 0.05), blurRadius: 4)],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => onMonthChanged(
                    DateTime(focusedMonth.year, focusedMonth.month - 1),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${_monthName(focusedMonth.month)} ${focusedMonth.year}',
                    textAlign: TextAlign.center,
                    style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => onMonthChanged(
                    DateTime(focusedMonth.year, focusedMonth.month + 1),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7']
                  .map((d) => Expanded(
                        child: Text(d,
                            textAlign: TextAlign.center,
                            style: tt.labelSmall?.copyWith(color: cs.outline)),
                      ))
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                childAspectRatio: 1,
              ),
              itemCount: firstWeekday + daysInMonth,
              itemBuilder: (context, index) {
                if (index < firstWeekday) return const SizedBox();
                final day = index - firstWeekday + 1;
                final date = DateTime(focusedMonth.year, focusedMonth.month, day);
                final isSelected = DateUtils.isSameDay(date, selectedDay);
                final isToday = DateUtils.isSameDay(date, DateTime.now());
                final hasAppt = appointments.any((a) =>
                    a.startAt.year == date.year &&
                    a.startAt.month == date.month &&
                    a.startAt.day == date.day);
                return GestureDetector(
                  onTap: () => onDaySelected(date),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? cs.primary : null,
                      shape: BoxShape.circle,
                      border: isToday && !isSelected
                          ? Border.all(color: cs.primary, width: 1.5)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$day',
                          style: tt.bodySmall?.copyWith(
                            color: isSelected ? cs.onPrimary : null,
                            fontWeight: isToday ? FontWeight.bold : null,
                          ),
                        ),
                        if (hasAppt)
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isSelected ? cs.onPrimary : cs.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int m) {
    const names = [
      'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4',
      'Tháng 5', 'Tháng 6', 'Tháng 7', 'Tháng 8',
      'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'
    ];
    return names[m - 1];
  }
}

// ── Holiday Banner ────────────────────────────────────────────────────────────

class _HolidayBanner extends StatelessWidget {
  const _HolidayBanner({required this.holiday});
  final SpecialOccasion holiday;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final days = holiday.daysUntilNext;
    final daysText = days == 0
        ? 'Hôm nay!'
        : days == 1
            ? 'Ngày mai'
            : 'Còn $days ngày';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: cs.tertiaryContainer,
      child: Row(
        children: [
          Icon(Icons.celebration_outlined, size: 16, color: cs.onTertiaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${holiday.label} — $daysText',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: cs.onTertiaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Agenda List ───────────────────────────────────────────────────────────────

class _AgendaList extends StatelessWidget {
  const _AgendaList({
    required this.day,
    required this.appointments,
    required this.onEdit,
    required this.onDelete,
  });

  final DateTime day;
  final List<Appointment> appointments;
  final void Function(Appointment) onEdit;
  final void Function(String) onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final dateLabel =
        '${day.day.toString().padLeft(2, '0')}/${day.month.toString().padLeft(2, '0')}/${day.year}';

    if (appointments.isEmpty) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(dateLabel, style: tt.labelMedium?.copyWith(color: cs.outline)),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 48, color: cs.outlineVariant),
                  const SizedBox(height: 12),
                  Text('Không có lịch hẹn', style: tt.bodyMedium?.copyWith(color: cs.outline)),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            '$dateLabel · ${appointments.length} lịch hẹn',
            style: tt.labelMedium?.copyWith(color: cs.outline),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
            itemCount: appointments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _AppointmentCard(
              appointment: appointments[i],
              onEdit: () => onEdit(appointments[i]),
              onDelete: () => onDelete(appointments[i].id),
            ),
          ),
        ),
      ],
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.appointment,
    required this.onEdit,
    required this.onDelete,
  });

  final Appointment appointment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final a = appointment;

    final startTime =
        '${a.startAt.hour.toString().padLeft(2, '0')}:${a.startAt.minute.toString().padLeft(2, '0')}';
    final endTime = a.endAt != null
        ? ' – ${a.endAt!.hour.toString().padLeft(2, '0')}:${a.endAt!.minute.toString().padLeft(2, '0')}'
        : '';

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: a.source == AppointmentSource.voice
                      ? cs.tertiary
                      : cs.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.title,
                        style: tt.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.access_time_outlined, size: 14, color: cs.outline),
                        const SizedBox(width: 4),
                        Text('$startTime$endTime',
                            style: tt.bodySmall?.copyWith(color: cs.outline)),
                        if (a.location != null) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.location_on_outlined, size: 14, color: cs.outline),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(a.location!,
                                style: tt.bodySmall?.copyWith(color: cs.outline),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Sửa')),
                  const PopupMenuItem(value: 'delete', child: Text('Xoá')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Voice FAB ────────────────────────────────────────────────────────────────

class _VoiceFab extends StatelessWidget {
  const _VoiceFab({required this.state, required this.notifier});
  final ScheduleState state;
  final ScheduleNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isListening = state.voiceState == VoiceState.listening;
    final isProcessing = state.voiceState == VoiceState.processing;

    if (isProcessing) {
      return const Padding(
        padding: EdgeInsets.all(8),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return IconButton.filled(
      style: IconButton.styleFrom(
        backgroundColor: isListening ? cs.error : cs.primaryContainer,
        foregroundColor: isListening ? cs.onError : cs.onPrimaryContainer,
      ),
      icon: Icon(isListening ? Icons.stop_rounded : Icons.mic_outlined),
      tooltip: isListening ? 'Dừng ghi âm' : 'Đặt lịch bằng giọng nói',
      onPressed: () {
        if (isListening) {
          notifier.stopVoiceListening();
        } else {
          notifier.startVoiceListening();
        }
      },
    );
  }
}
