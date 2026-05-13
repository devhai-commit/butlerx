import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/chat_repository.dart';
import '../../domain/entities/conversation.dart';
import '../providers/chat_notifier.dart';

class ConversationListPage extends ConsumerStatefulWidget {
  const ConversationListPage({super.key});

  @override
  ConsumerState<ConversationListPage> createState() =>
      _ConversationListPageState();
}

class _ConversationListPageState
    extends ConsumerState<ConversationListPage> {
  List<Conversation> _conversations = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = ref.read(authNotifierProvider);
    if (auth is! AuthAuthenticated) return;
    setState(() => _isLoading = true);
    final repo = ref.read(chatRepositoryProvider);
    final convs = await repo.listConversations(auth.profile.uid);
    if (mounted) {
      setState(() {
        _conversations = convs;
        _isLoading = false;
      });
    }
  }

  List<Conversation> get _filtered {
    if (_searchQuery.isEmpty) return _conversations;
    final q = _searchQuery.toLowerCase();
    return _conversations.where((c) {
      return c.title.toLowerCase().contains(q) ||
          c.messages.any((m) => m.content.toLowerCase().contains(q));
    }).toList();
  }

  Future<void> _delete(Conversation conv) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xoá cuộc trò chuyện?'),
        content: Text(
            'Cuộc trò chuyện "${conv.title}" sẽ bị xoá vĩnh viễn.'),
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
    if (confirmed != true) return;

    final auth = ref.read(authNotifierProvider);
    if (auth is! AuthAuthenticated) return;
    await ref
        .read(chatRepositoryProvider)
        .deleteConversation(auth.profile.uid, conv.id);
    await _load();
  }

  void _select(Conversation conv) {
    ref.read(chatNotifierProvider.notifier).loadConversation(conv.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final filtered = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử trò chuyện'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusXl),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: cs.surfaceContainerHigh,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                isDense: true,
              ),
            ),
          ),

          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? _EmptyState(hasSearch: _searchQuery.isNotEmpty)
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (_, i) => _ConversationTile(
                          conversation: filtered[i],
                          onTap: () => _select(filtered[i]),
                          onDelete: () => _delete(filtered[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.onTap,
    required this.onDelete,
  });

  final Conversation conversation;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final c = conversation;
    final date = c.updatedAt ?? c.createdAt;
    final lastMessage =
        c.messages.isNotEmpty ? c.messages.last.content : 'Chưa có tin nhắn';

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: cs.primaryContainer,
                child:
                    Icon(Icons.chat_outlined, size: 18, color: cs.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.title,
                      style: tt.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lastMessage,
                      style: tt.bodySmall?.copyWith(color: cs.outline),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatDate(date),
                    style: tt.labelSmall?.copyWith(color: cs.outline),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${c.messages.length} tin',
                    style: tt.labelSmall?.copyWith(color: cs.outline),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(Icons.delete_outline,
                    size: 18, color: cs.error),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year &&
        dt.month == now.month &&
        dt.day == now.day) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({this.hasSearch = false});
  final bool hasSearch;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasSearch ? Icons.search_off : Icons.chat_outlined,
            size: 56,
            color: cs.outlineVariant,
          ),
          const SizedBox(height: 12),
          Text(
            hasSearch
                ? 'Không tìm thấy kết quả'
                : 'Chưa có cuộc trò chuyện nào',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: cs.outline),
          ),
        ],
      ),
    );
  }
}
