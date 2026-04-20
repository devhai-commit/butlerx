import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/health_record.dart';
import '../providers/health_notifier.dart';
import 'add_health_record_page.dart';

class HealthPage extends ConsumerWidget {
  const HealthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(healthNotifierProvider);
    final cs = Theme.of(context).colorScheme;

    ref.listen(healthNotifierProvider.select((s) => s.error), (_, error) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error),
          backgroundColor: cs.error,
          action: SnackBarAction(
            label: 'OK',
            textColor: cs.onError,
            onPressed: () =>
                ref.read(healthNotifierProvider.notifier).clearError(),
          ),
        ));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Sức khoẻ')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddHealthRecordPage()),
        ),
        tooltip: 'Ghi chép sức khoẻ',
        child: const Icon(Icons.add),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                if (state.latest != null)
                  SliverToBoxAdapter(
                    child: _VitalsSummaryCard(record: state.latest!),
                  ),
                if (state.records.isEmpty)
                  const SliverFillRemaining(child: _EmptyState())
                else
                  SliverList.separated(
                    itemCount: state.records.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) => _HistoryTile(
                      record: state.records[i],
                      onDelete: () => _confirmDelete(
                        context,
                        state.records[i].id,
                        ref,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 88)),
              ],
            ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, String id, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xoá bản ghi?'),
        content: const Text('Dữ liệu sức khoẻ này sẽ bị xoá vĩnh viễn.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Huỷ')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Xoá')),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(healthNotifierProvider.notifier).deleteRecord(id);
    }
  }
}

// ── Vitals Summary Card ───────────────────────────────────────────────────────

class _VitalsSummaryCard extends StatelessWidget {
  const _VitalsSummaryCard({required this.record});
  final HealthRecord record;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final items = <_VitalItem>[];
    if (record.weightKg != null) {
      items.add(_VitalItem(
        icon: Icons.monitor_weight_outlined,
        label: 'Cân nặng',
        value: '${record.weightKg!.toStringAsFixed(1)} kg',
      ));
    }
    if (record.heightCm != null) {
      items.add(_VitalItem(
        icon: Icons.height_outlined,
        label: 'Chiều cao',
        value: '${record.heightCm!.toStringAsFixed(0)} cm',
      ));
    }
    if (record.bmi != null) {
      items.add(_VitalItem(
        icon: Icons.accessibility_new_outlined,
        label: 'BMI',
        value: '${record.bmi!.toStringAsFixed(1)} · ${record.bmiLabel}',
        highlight: record.bmi! < 18.5 || record.bmi! >= 25,
      ));
    }
    if (record.bloodPressureSystolic != null) {
      items.add(_VitalItem(
        icon: Icons.favorite_outline,
        label: 'Huyết áp',
        value:
            '${record.bloodPressureSystolic}/${record.bloodPressureDiastolic} mmHg',
        highlight: record.bloodPressureSystolic! >= 130,
      ));
    }
    if (record.heartRateBpm != null) {
      items.add(_VitalItem(
        icon: Icons.monitor_heart_outlined,
        label: 'Nhịp tim',
        value: '${record.heartRateBpm} bpm',
      ));
    }
    if (record.bloodSugarMmol != null) {
      items.add(_VitalItem(
        icon: Icons.water_drop_outlined,
        label: 'Đường huyết',
        value: '${record.bloodSugarMmol!.toStringAsFixed(1)} mmol/L',
        highlight: record.bloodSugarMmol! > 7.0,
      ));
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.health_and_safety_outlined, color: cs.primary),
                const SizedBox(width: 8),
                Text('Chỉ số gần nhất',
                    style: tt.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(
                  _formatDate(record.recordedAt),
                  style: tt.bodySmall?.copyWith(color: cs.outline),
                ),
              ],
            ),
            if (items.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: items
                    .map((item) => _VitalChip(item: item))
                    .toList(),
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text('Chưa có số liệu.',
                  style: tt.bodySmall?.copyWith(color: cs.outline)),
            ],
            if (record.notes != null) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Text(record.notes!,
                  style: tt.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic, color: cs.outline)),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}

class _VitalItem {
  const _VitalItem(
      {required this.icon,
      required this.label,
      required this.value,
      this.highlight = false});
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;
}

class _VitalChip extends StatelessWidget {
  const _VitalChip({required this.item});
  final _VitalItem item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = item.highlight ? cs.error : cs.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: 14, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.label,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: color)),
              Text(item.value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── History Tile ──────────────────────────────────────────────────────────────

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.record, required this.onDelete});
  final HealthRecord record;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final r = record;

    final subtitle = StringBuffer();
    if (r.weightKg != null) subtitle.write('${r.weightKg!.toStringAsFixed(1)}kg  ');
    if (r.bloodPressureSystolic != null) {
      subtitle.write('${r.bloodPressureSystolic}/${r.bloodPressureDiastolic}mmHg  ');
    }
    if (r.heartRateBpm != null) subtitle.write('${r.heartRateBpm}bpm');

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: cs.primaryContainer,
        child: Icon(Icons.health_and_safety_outlined,
            color: cs.onPrimaryContainer, size: 20),
      ),
      title: Text(
        '${r.recordedAt.day.toString().padLeft(2, '0')}/${r.recordedAt.month.toString().padLeft(2, '0')}/${r.recordedAt.year}  '
        '${r.recordedAt.hour.toString().padLeft(2, '0')}:${r.recordedAt.minute.toString().padLeft(2, '0')}',
        style: tt.bodyMedium,
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(subtitle.toString().trim(),
              style: tt.bodySmall?.copyWith(color: cs.outline))
          : null,
      trailing: IconButton(
        icon: Icon(Icons.delete_outline, color: cs.error),
        onPressed: onDelete,
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.health_and_safety_outlined,
              size: 64, color: cs.outlineVariant),
          const SizedBox(height: 16),
          Text('Chưa có dữ liệu sức khoẻ',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: cs.outline)),
          const SizedBox(height: 8),
          Text('Nhấn + để ghi chép lần đầu',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: cs.outlineVariant)),
        ],
      ),
    );
  }
}
