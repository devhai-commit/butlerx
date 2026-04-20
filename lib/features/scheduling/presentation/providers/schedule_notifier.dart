import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/appointment_repository.dart';
import '../../data/services/reminder_service.dart';
import '../../data/services/voice_intent_parser.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/special_occasion.dart';

part 'schedule_notifier.g.dart';

enum VoiceState { idle, listening, processing, confirmPending }

final class ScheduleState {
  const ScheduleState({
    this.appointments = const [],
    this.selectedDay,
    this.voiceState = VoiceState.idle,
    this.pendingParsed,
    this.pendingTranscript,
    this.isLoading = false,
    this.error,
  });

  final List<Appointment> appointments;
  final DateTime? selectedDay;
  final VoiceState voiceState;
  final ParsedAppointment? pendingParsed;
  final String? pendingTranscript;
  final bool isLoading;
  final String? error;

  List<Appointment> get upcoming =>
      appointments.where((a) => a.isUpcoming).toList();

  List<Appointment> forDay(DateTime day) =>
      appointments.where((a) => a.isToday || _sameDay(a.startAt, day)).toList();

  List<SpecialOccasion> get upcomingHolidays => VietnameseHolidays.all
      .where((h) => h.daysUntilNext <= 30)
      .toList()
    ..sort((a, b) => a.daysUntilNext.compareTo(b.daysUntilNext));

  ScheduleState copyWith({
    List<Appointment>? appointments,
    DateTime? selectedDay,
    VoiceState? voiceState,
    ParsedAppointment? Function()? pendingParsed,
    String? Function()? pendingTranscript,
    bool? isLoading,
    String? Function()? error,
  }) =>
      ScheduleState(
        appointments: appointments ?? this.appointments,
        selectedDay: selectedDay ?? this.selectedDay,
        voiceState: voiceState ?? this.voiceState,
        pendingParsed: pendingParsed != null ? pendingParsed() : this.pendingParsed,
        pendingTranscript: pendingTranscript != null ? pendingTranscript() : this.pendingTranscript,
        isLoading: isLoading ?? this.isLoading,
        error: error != null ? error() : this.error,
      );

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

@riverpod
class ScheduleNotifier extends _$ScheduleNotifier {
  final _stt = SpeechToText();

  @override
  ScheduleState build() {
    Future.microtask(_loadAppointments);
    return ScheduleState(selectedDay: DateTime.now());
  }

  Future<void> _loadAppointments() async {
    final uid = _uid;
    if (uid == null) return;
    final appts =
        await ref.read(appointmentRepositoryProvider).getAll(uid);
    state = state.copyWith(appointments: appts);
  }

  String? get _uid {
    final auth = ref.read(authNotifierProvider);
    return auth is AuthAuthenticated ? auth.profile.uid : null;
  }

  void selectDay(DateTime day) => state = state.copyWith(selectedDay: day);

  // ── Manual add ─────────────────────────────────────────────────────────────

  Future<Appointment> addAppointment(Appointment appt) async {
    final saved = await ref.read(appointmentRepositoryProvider).save(appt);
    await ref.read(reminderServiceProvider).scheduleReminder(saved);
    state = state.copyWith(appointments: [...state.appointments, saved]
      ..sort((a, b) => a.startAt.compareTo(b.startAt)));
    return saved;
  }

  Future<void> updateAppointment(Appointment appt) async {
    final old = state.appointments.firstWhere((a) => a.id == appt.id,
        orElse: () => appt);
    if (old.notificationId != null) {
      await ref.read(reminderServiceProvider).cancelReminder(old.notificationId!);
    }
    final saved = await ref.read(appointmentRepositoryProvider).save(appt);
    await ref.read(reminderServiceProvider).scheduleReminder(saved);
    final updated = [
      for (final a in state.appointments) a.id == saved.id ? saved : a,
    ]..sort((a, b) => a.startAt.compareTo(b.startAt));
    state = state.copyWith(appointments: updated);
  }

  Future<void> deleteAppointment(String id) async {
    final uid = _uid;
    if (uid == null) return;
    final appt = state.appointments.firstWhere((a) => a.id == id,
        orElse: () => throw StateError('Not found'));
    if (appt.notificationId != null) {
      await ref.read(reminderServiceProvider).cancelReminder(appt.notificationId!);
    }
    await ref.read(appointmentRepositoryProvider).delete(uid, id);
    state = state.copyWith(
        appointments: state.appointments.where((a) => a.id != id).toList());
  }

  // ── Voice scheduling ────────────────────────────────────────────────────────

  Future<void> startVoiceListening() async {
    final available = await _stt.initialize();
    if (!available) {
      state = state.copyWith(error: () => 'Microphone không khả dụng');
      return;
    }
    state = state.copyWith(voiceState: VoiceState.listening);
    await _stt.listen(
      localeId: 'vi_VN',
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 3),
      onResult: (result) {
        if (result.finalResult) {
          _processVoiceResult(result.recognizedWords);
        }
      },
    );
  }

  Future<void> stopVoiceListening() async {
    await _stt.stop();
    if (state.voiceState == VoiceState.listening) {
      state = state.copyWith(voiceState: VoiceState.idle);
    }
  }

  Future<void> _processVoiceResult(String transcript) async {
    if (transcript.trim().isEmpty) {
      state = state.copyWith(voiceState: VoiceState.idle);
      return;
    }
    state = state.copyWith(
      voiceState: VoiceState.processing,
      pendingTranscript: () => transcript,
    );
    try {
      final parsed = await ref.read(voiceIntentParserProvider).parse(transcript);
      if (parsed != null) {
        state = state.copyWith(
          voiceState: VoiceState.confirmPending,
          pendingParsed: () => parsed,
        );
      } else {
        state = state.copyWith(
          voiceState: VoiceState.idle,
          error: () => 'Không nhận ra lịch hẹn. Thử lại với câu rõ hơn.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        voiceState: VoiceState.idle,
        error: () => e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> confirmVoiceAppointment() async {
    final parsed = state.pendingParsed;
    final uid = _uid;
    if (parsed == null || uid == null) return;

    final appt = Appointment(
      userId: uid,
      title: parsed.title,
      startAt: parsed.startAt,
      endAt: parsed.endAt,
      location: parsed.location,
      description: parsed.description,
      source: AppointmentSource.voice,
      rawTranscript: state.pendingTranscript,
    );

    await addAppointment(appt);
    state = state.copyWith(
      voiceState: VoiceState.idle,
      pendingParsed: () => null,
      pendingTranscript: () => null,
    );
  }

  void cancelVoicePending() => state = state.copyWith(
        voiceState: VoiceState.idle,
        pendingParsed: () => null,
        pendingTranscript: () => null,
        error: () => null,
      );

  void clearError() => state = state.copyWith(error: () => null);
}
