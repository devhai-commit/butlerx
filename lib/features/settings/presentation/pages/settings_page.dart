import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/providers/tts_provider.dart';
import '../../../auth/domain/entities/user_profile.dart';
import '../../../auth/presentation/pages/profile_edit_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/data/services/openai_service.dart';
import '../../../meal_plan/presentation/pages/meal_plan_page.dart';

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
    final ttsState = ref.watch(ttsNotifierProvider);
    final themeMode = ref.watch(themeNotifierProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        children: [
          // Profile card
          if (authState is AuthAuthenticated) ...[
            _ProfileCard(profile: authState.profile),
            const SizedBox(height: 8),
            _SettingsCard(
              children: [
                ListTile(
                  leading: Icon(Icons.edit_outlined, color: cs.primary),
                  title: const Text('Sửa hồ sơ'),
                  subtitle: const Text('Thay đổi tên, giới tính, xưng hô...'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openPage(context, const ProfileEditPage()),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMd),

            // Meal Plan shortcut (moved from bottom nav)
            _SectionHeader(title: 'Tính năng'),
            _SettingsCard(
              children: [
                ListTile(
                  leading: Icon(Icons.restaurant_outlined, color: cs.primary),
                  title: const Text('Thực đơn AI'),
                  subtitle: const Text('Tạo thực đơn 7 ngày theo sức khoẻ'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openPage(context, const MealPlanPage()),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMd),
          ],

          // OpenAI API Key
          _SectionHeader(title: 'OpenAI'),
          _ApiKeyTile(hasKey: _hasApiKey, onChanged: _checkApiKey),
          const SizedBox(height: AppConstants.spacingMd),

          // TTS
          _SectionHeader(title: 'Giọng đọc (TTS)'),
          _SettingsCard(
            children: [
              SwitchListTile(
                value: ttsState.enabled,
                onChanged: (_) =>
                    ref.read(ttsNotifierProvider.notifier).toggle(),
                title: const Text('Đọc to phản hồi'),
                subtitle: const Text('AI sẽ đọc to câu trả lời bằng tiếng Việt'),
                secondary: Icon(
                  ttsState.enabled
                      ? Icons.volume_up_rounded
                      : Icons.volume_off_outlined,
                ),
              ),
              if (ttsState.enabled) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Row(
                    children: [
                      const Icon(Icons.speed_outlined, size: 18),
                      const SizedBox(width: 8),
                      const Text('Tốc độ đọc'),
                      const Spacer(),
                      Text(
                        ttsState.rate.toStringAsFixed(1),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Slider(
                  value: ttsState.rate,
                  min: 0.25,
                  max: 1.0,
                  divisions: 6,
                  onChanged: (v) =>
                      ref.read(ttsNotifierProvider.notifier).setRate(v),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Row(
                    children: [
                      const Icon(Icons.graphic_eq_outlined, size: 18),
                      const SizedBox(width: 8),
                      const Text('Cao độ giọng'),
                      const Spacer(),
                      Text(
                        ttsState.pitch.toStringAsFixed(1),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Slider(
                  value: ttsState.pitch,
                  min: 0.5,
                  max: 2.0,
                  divisions: 6,
                  onChanged: (v) =>
                      ref.read(ttsNotifierProvider.notifier).setPitch(v),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.play_circle_outline),
                  title: const Text('Thử giọng đọc'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => ref
                      .read(ttsNotifierProvider.notifier)
                      .speak('Xin chào! Tôi là ButlerX, trợ lý gia đình của bạn.'),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppConstants.spacingMd),

          // Appearance
          _SectionHeader(title: 'Giao diện'),
          _SettingsCard(
            children: [
              ...[
                (ThemeMode.system, Icons.brightness_auto_outlined, 'Tự động (hệ thống)'),
                (ThemeMode.light, Icons.light_mode_outlined, 'Sáng'),
                (ThemeMode.dark, Icons.dark_mode_outlined, 'Tối'),
              ].map(
                (item) => RadioListTile<ThemeMode>(
                  value: item.$1,
                  groupValue: themeMode,
                  onChanged: (v) {
                    if (v != null) {
                      ref.read(themeNotifierProvider.notifier).setMode(v);
                    }
                  },
                  secondary: Icon(item.$2),
                  title: Text(item.$3),
                  controlAffinity: ListTileControlAffinity.trailing,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMd),

          // Sign out
          _SectionHeader(title: 'Phiên đăng nhập'),
          _SettingsCard(
            children: [
              ListTile(
                leading: Icon(Icons.logout,
                    color: Theme.of(context).colorScheme.error),
                title: Text(
                  'Đăng xuất',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _confirmSignOut(context),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _openPage(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
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
              await ref.read(ttsNotifierProvider.notifier).stop();
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

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: cs.surfaceContainerLow,
      child: Column(children: children),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile});
  final UserProfile profile;
  // final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final age = DateTime.now().difference(profile.birthdate).inDays ~/ 365;

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
          // onTap: onTap,
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
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _Tag(label: '${profile.addressTitle.label} · $age tuổi', cs: cs),
                    _Tag(label: profile.personalityTag.label.split(',').first, cs: cs),
                    _Tag(
                      label: switch (profile.gender) {
                        Gender.male => 'Nam',
                        Gender.female => 'Nữ',
                        Gender.other => 'Khác',
                      },
                      cs: cs,
                    ),
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
                    icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility),
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
    return _SettingsCard(
      children: [
        ListTile(
          leading: Icon(
            Icons.key_outlined,
            color: widget.hasKey ? Colors.green : cs.outline,
          ),
          title: const Text('OpenAI API Key'),
          subtitle: Text(
            widget.hasKey
                ? 'Đã cài đặt ✓'
                : 'Chưa cài đặt — bắt buộc để dùng chat',
            style: TextStyle(
              color: widget.hasKey ? Colors.green : cs.error,
              fontSize: 12,
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: _showApiKeyDialog,
        ),
      ],
    );
  }
}
