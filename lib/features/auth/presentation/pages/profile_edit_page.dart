import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/auth_provider.dart';

class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  late TextEditingController _nameCtrl;
  late DateTime _birthdate;
  late Gender _gender;
  late AddressTitle _addressTitle;
  late PersonalityTag _personalityTag;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final auth = ref.read(authNotifierProvider);
    if (auth is AuthAuthenticated) {
      final p = auth.profile;
      _nameCtrl = TextEditingController(text: p.displayName);
      _birthdate = p.birthdate;
      _gender = p.gender;
      _addressTitle = p.addressTitle;
      _personalityTag = p.personalityTag;
    } else {
      _nameCtrl = TextEditingController();
      _birthdate = DateTime(1990, 1, 1);
      _gender = Gender.other;
      _addressTitle = AddressTitle.anh;
      _personalityTag = PersonalityTag.warm;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final auth = ref.read(authNotifierProvider);
    if (auth is! AuthAuthenticated) return;
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final updated = auth.profile.copyWith(
      displayName: _nameCtrl.text.trim(),
      birthdate: _birthdate,
      gender: _gender,
      addressTitle: _addressTitle,
      personalityTag: _personalityTag,
    );
    await ref.read(authNotifierProvider.notifier).updateProfile(updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật hồ sơ'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _pickBirthdate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthdate,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      helpText: 'Chọn ngày sinh',
      cancelText: 'Huỷ',
      confirmText: 'Chọn',
    );
    if (picked != null) setState(() => _birthdate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sửa hồ sơ'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: cs.primary),
                  )
                : const Text('Lưu'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        children: [
          // Name
          TextFormField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Họ và tên',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 24),

          // Birthdate
          _SectionLabel('NGÀY SINH'),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading:
                  Icon(Icons.cake_outlined, color: cs.primary),
              title: Text(
                '${_birthdate.day.toString().padLeft(2, '0')}/${_birthdate.month.toString().padLeft(2, '0')}/${_birthdate.year}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickBirthdate,
            ),
          ),
          const SizedBox(height: 24),

          // Gender
          _SectionLabel('GIỚI TÍNH'),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: Gender.values.map((g) {
                final label = switch (g) {
                  Gender.male => 'Nam',
                  Gender.female => 'Nữ',
                  Gender.other => 'Khác',
                };
                return RadioListTile<Gender>(
                  value: g,
                  groupValue: _gender,
                  onChanged: (v) {
                    if (v != null) setState(() => _gender = v);
                  },
                  title: Text(label),
                  controlAffinity: ListTileControlAffinity.trailing,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Address Title
          _SectionLabel('CÁCH XƯNG HÔ'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: AddressTitle.values.map((t) {
              final selected = _addressTitle == t;
              return ChoiceChip(
                label: Text(t.label),
                selected: selected,
                onSelected: (_) => setState(() => _addressTitle = t),
                selectedColor: cs.primaryContainer,
                labelStyle: TextStyle(
                  color: selected ? cs.primary : cs.onSurface,
                  fontWeight: selected ? FontWeight.w600 : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Personality
          _SectionLabel('PHONG CÁCH TRÒ CHUYỆN'),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: PersonalityTag.values.map((p) {
                return RadioListTile<PersonalityTag>(
                  value: p,
                  groupValue: _personalityTag,
                  onChanged: (v) {
                    if (v != null) setState(() => _personalityTag = v);
                  },
                  title: Text(p.label),
                  controlAffinity: ListTileControlAffinity.trailing,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.primary,
        letterSpacing: 1.2,
      ),
    );
  }
}
