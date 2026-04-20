import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/data/services/openai_service.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _hasApiKey = false;

  @override
  void initState() {
    super.initState();
    _checkApiKey();
  }

  Future<void> _checkApiKey() async {
    final has = await ref.read(openAiServiceProvider).hasApiKey();
    if (mounted) setState(() => _hasApiKey = has);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        children: [
          // Profile card
          if (authState is AuthAuthenticated) ...[
            _SectionHeader(title: 'Tài khoản'),
            _ProfileCard(profile: authState.profile),
            const SizedBox(height: AppConstants.spacingMd),
          ],

          // OpenAI API Key
          _SectionHeader(title: 'OpenAI'),
          _ApiKeyTile(
            hasKey: _hasApiKey,
            onChanged: () => _checkApiKey(),
          ),
          const SizedBox(height: AppConstants.spacingMd),

          // Sign out
          _SectionHeader(title: 'Tài khoản'),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            tileColor: cs.surfaceContainerLow,
            leading: Icon(Icons.logout, color: cs.error),
            title: Text('Đăng xuất', style: TextStyle(color: cs.error)),
            onTap: () => _confirmSignOut(context),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Đăng xuất?'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authNotifierProvider.notifier).signOut();
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
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

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile});
  final profile;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: cs.primary,
            child: Text(
              profile.firstNameGreeting[0].toUpperCase(),
              style: TextStyle(
                  color: cs.onPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.displayName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16),
                ),
                Text(
                  profile.email,
                  style: TextStyle(color: cs.outline, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  children: [
                    _Tag(label: profile.addressTitle.label, cs: cs),
                    _Tag(label: profile.personalityTag.label.split(',').first, cs: cs),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.cs});
  final String label;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: cs.primary)),
    );
  }
}

class _ApiKeyTile extends ConsumerStatefulWidget {
  const _ApiKeyTile({required this.hasKey, required this.onChanged});
  final bool hasKey;
  final VoidCallback onChanged;

  @override
  ConsumerState<_ApiKeyTile> createState() => _ApiKeyTileState();
}

class _ApiKeyTileState extends ConsumerState<_ApiKeyTile> {
  void _showApiKeyDialog() {
    final ctrl = TextEditingController();
    bool obscure = true;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('OpenAI API Key'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nhập API key từ platform.openai.com để dùng chat AI.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                obscureText: obscure,
                decoration: InputDecoration(
                  hintText: 'sk-...',
                  labelText: 'API Key',
                  suffixIcon: IconButton(
                    icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setS(() => obscure = !obscure),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            if (widget.hasKey)
              TextButton(
                onPressed: () async {
                  await ref.read(openAiServiceProvider).deleteApiKey();
                  if (ctx.mounted) Navigator.pop(ctx);
                  widget.onChanged();
                },
                child: Text(
                  'Xóa key',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () async {
                final key = ctrl.text.trim();
                if (key.isEmpty) return;
                await ref.read(openAiServiceProvider).setApiKey(key);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã lưu API key'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                widget.onChanged();
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      tileColor: cs.surfaceContainerLow,
      leading: Icon(
        Icons.key_outlined,
        color: widget.hasKey ? Colors.green : cs.outline,
      ),
      title: const Text('OpenAI API Key'),
      subtitle: Text(
        widget.hasKey ? 'Đã cài đặt ✓' : 'Chưa cài đặt — bắt buộc để dùng chat',
        style: TextStyle(
          color: widget.hasKey ? Colors.green : cs.error,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: _showApiKeyDialog,
    );
  }
}
