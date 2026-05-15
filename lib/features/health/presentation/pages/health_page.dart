import 'package:fl_chart/fl_chart.dart';
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
      floatingActionButton: _GradientFab(
        tooltip: 'Ghi chép sức khoẻ',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddHealthRecordPage()),
        ),
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
                else ...[
                  // Weight trend chart
                  if (state.records.where((r) => r.weightKg != null).length >= 2)
                    SliverToBoxAdapter(
                      child: _WeightTrendChart(records: state.records),
                    ),
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
                ],
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

// ── Weight Trend Chart ────────────────────────────────────────────────────────

class _WeightTrendChart extends StatelessWidget {
  const _WeightTrendChart({required this.records});
  final List<HealthRecord> records;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Filter records with weight and sort by date
    final weightRecords = records
        .where((r) => r.weightKg != null)
        .toList()
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

    if (weightRecords.length < 2) return const SizedBox.shrink();

    // Take last 14 records max for readability
    final data = weightRecords.length > 14
        ? weightRecords.sublist(weightRecords.length - 14)
        : weightRecords;

    final spots = <FlSpot>[];
    for (var i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i].weightKg!));
    }

    final minWeight = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxWeight = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final padding = (maxWeight - minWeight) * 0.2;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart_outlined, color: cs.primary, size: 20),
                const SizedBox(width: 8),
                Text('Biểu đồ cân nặng',
                    style: tt.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _interval(minWeight, maxWeight),
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: cs.outlineVariant.withValues(alpha: 0.3),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toStringAsFixed(0)}',
                          style: tt.labelSmall?.copyWith(
                              color: cs.outline, fontSize: 10),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        interval: (data.length / 4).ceilToDouble().clamp(1, 7),
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= data.length) {
                            return const SizedBox.shrink();
                          }
                          final dt = data[idx].recordedAt;
                          return Text(
                            '${dt.day}/${dt.month}',
                            style: tt.labelSmall?.copyWith(
                                color: cs.outline, fontSize: 9),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (data.length - 1).toDouble(),
                  minY: (minWeight - padding).clamp(0, double.infinity),
                  maxY: maxWeight + padding,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.3,
                      color: cs.primary,
                      barWidth: 2.5,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, _, __, ___) =>
                            FlDotCirclePainter(
                          radius: 3,
                          color: cs.primary,
                          strokeWidth: 1.5,
                          strokeColor: cs.surface,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: cs.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (spots) => spots
                          .map((s) => LineTooltipItem(
                                '${s.y.toStringAsFixed(1)} kg',
                                TextStyle(
                                  color: cs.onPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${data.length} bản ghi gần nhất',
              style: tt.labelSmall?.copyWith(color: cs.outline),
            ),
          ],
        ),
      ),
    );
  }

  double _interval(double min, double max) {
    final range = max - min;
    if (range <= 2) return 0.5;
    if (range <= 5) return 1;
    if (range <= 10) return 2;
    return 5;
  }
}

// ─── Gradient FAB ─────────────────────────────────────────────────────────────

class _GradientFab extends StatelessWidget {
  const _GradientFab({required this.tooltip, required this.onPressed});
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cs.primary, Color.lerp(cs.primary, cs.secondary, 0.3)!],
          ),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.40),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white, size: 26),
          ),
        ),
      ),
    );
  }
}
