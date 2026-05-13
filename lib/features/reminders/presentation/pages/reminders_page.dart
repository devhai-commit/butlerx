import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/reminder.dart';
import '../providers/reminder_notifier.dart';
import 'add_reminder_page.dart';

class RemindersPage extends ConsumerWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reminderNotifierProvider);
    final cs = Theme.of(context).colorScheme;

    ref.listen(reminderNotifierProvider.select((s) => s.error), (_, error) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error),
          backgroundColor: cs.error,
          action: SnackBarAction(
            label: 'OK',
            textColor: cs.onError,
            onPressed: () =>
                ref.read(reminderNotifierProvider.notifier).clearError(),
          ),
        ));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Nhắc nhở'), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddReminderPage()),
        ),
        tooltip: 'Thêm nhắc nhở',
        child: const Icon(Icons.add),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.reminders.isEmpty
              ? const _EmptyState()
              : _ReminderList(reminders: state.reminders),
    );
  }
}

class _ReminderList extends ConsumerWidget {
  const _ReminderList({required this.reminders});
  final List<Reminder> reminders;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcoming = reminders.where((r) => r.isUpcoming && r.isActive).toList();
    final past = reminders.where((r) => !r.isUpcoming || !r.isActive).toList();

    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      children: [
        if (upcoming.isNotEmpty) ...[
          _SectionHeader(title: 'Sắp tới (${upcoming.length})'),
          ...upcoming.map((r) => _ReminderCard(
                reminder: r,
                onToggle: () => ref
                    .read(reminderNotifierProvider.notifier)
                    .toggleActive(r.id),
                onDelete: () => _confirmDelete(context, ref, r.id),
              )),
        ],
        if (past.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionHeader(title: 'Đã qua / Tắt (${past.length})'),
          ...past.map((r) => _ReminderCard(
                reminder: r,
                onToggle: () => ref
                    .read(reminderNotifierProvider.notifier)
                    .toggleActive(r.id),
                onDelete: () => _confirmDelete(context, ref, r.id),
              )),
        ],
        const SizedBox(height: 88),
      ],
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xoá nhắc nhở?'),
        content: const Text('Nhắc nhở này sẽ bị xoá vĩnh viễn.'),
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
      await ref.read(reminderNotifierProvider.notifier).deleteReminder(id);
    }
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.reminder,
    required this.onToggle,
    required this.onDelete,
  });

  final Reminder reminder;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isActive = reminder.isActive;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isActive ? null : cs.surfaceContainerLow,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive
                ? cs.primaryContainer
                : cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isActive
                ? Icons.notifications_active_outlined
                : Icons.notifications_off_outlined,
            color: isActive ? cs.primary : cs.outline,
            size: 20,
          ),
        ),
        title: Text(
          reminder.title,
          style: tt.titleSmall?.copyWith(
            decoration: isActive ? null : TextDecoration.lineThrough,
            color: isActive ? null : cs.outline,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDateTime(reminder.scheduledAt),
              style: tt.bodySmall?.copyWith(color: cs.outline),
            ),
            if (reminder.repeatRule != RepeatRule.none)
              Row(
                children: [
                  Icon(Icons.repeat, size: 12, color: cs.tertiary),
                  const SizedBox(width: 4),
                  Text(
                    reminder.repeatRule.label,
                    style: tt.labelSmall?.copyWith(color: cs.tertiary),
                  ),
                ],
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch.adaptive(
              value: isActive,
              onChanged: (_) => onToggle(),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, size: 20, color: cs.error),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/${dt.year}  $hour:$minute';
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_outlined,
              size: 64, color: cs.outlineVariant),
          const SizedBox(height: 16),
          Text('Chưa có nhắc nhở nào',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: cs.outline)),
          const SizedBox(height: 8),
          Text('Nhấn + để tạo nhắc nhở mới',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: cs.outlineVariant)),
        ],
      ),
    );
  }
}
