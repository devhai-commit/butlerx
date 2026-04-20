import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/health_repository.dart';
import '../../domain/entities/health_record.dart';

part 'health_notifier.g.dart';

final class HealthState {
  const HealthState({
    this.records = const [],
    this.isLoading = false,
    this.error,
  });

  final List<HealthRecord> records;
  final bool isLoading;
  final String? error;

  HealthRecord? get latest => records.firstOrNull;

  HealthState copyWith({
    List<HealthRecord>? records,
    bool? isLoading,
    String? Function()? error,
  }) =>
      HealthState(
        records: records ?? this.records,
        isLoading: isLoading ?? this.isLoading,
        error: error != null ? error() : this.error,
      );
}

@riverpod
class HealthNotifier extends _$HealthNotifier {
  @override
  HealthState build() {
    Future.microtask(_load);
    return const HealthState();
  }

  String? get _uid {
    final auth = ref.read(authNotifierProvider);
    return auth is AuthAuthenticated ? auth.profile.uid : null;
  }

  Future<void> _load() async {
    final uid = _uid;
    if (uid == null) return;
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      final records = await ref.read(healthRepositoryProvider).getAll(uid);
      state = state.copyWith(records: records, isLoading: false);
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> addRecord(HealthRecord record) async {
    final saved = await ref.read(healthRepositoryProvider).save(record);
    final updated = [saved, ...state.records]
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    state = state.copyWith(records: updated);
  }

  Future<void> deleteRecord(String id) async {
    final uid = _uid;
    if (uid == null) return;
    await ref.read(healthRepositoryProvider).delete(uid, id);
    state = state.copyWith(
      records: state.records.where((r) => r.id != id).toList(),
    );
  }

  void clearError() => state = state.copyWith(error: () => null);
}
