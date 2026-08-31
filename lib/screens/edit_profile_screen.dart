import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/api_failure.dart';
import '../providers/social_provider.dart';
import '../repositories/account_repository.dart';
import '../theme/theme.dart';
import '../widgets/common/app_top_bar.dart';
import '../widgets/common/snap_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _displayName;
  late final TextEditingController _username;
  late final TextEditingController _bio;
  DateTime? _birthday;
  bool _saving = false;
  bool _uploadingAvatar = false;
  String? _avatarError;

  @override
  void initState() {
    super.initState();
    final user = context.read<SocialProvider>().me.data;
    _displayName = TextEditingController(text: user?.displayName ?? '');
    _username = TextEditingController(text: user?.username ?? '');
    _bio = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    _displayName.dispose();
    _username.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _changeAvatar() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    setState(() {
      _uploadingAvatar = true;
      _avatarError = null;
    });
    try {
      await context.read<AccountRepository>().uploadAvatar(File(picked.path));
      if (!mounted) return;
      await context.read<SocialProvider>().loadMe();
    } on ApiFailure catch (e) {
      setState(() => _avatarError = e.message);
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year - 13, now.month, now.day),
    );
    if (picked != null) setState(() => _birthday = picked);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final error = await context.read<SocialProvider>().updateProfile(
          displayName: _displayName.text.trim(),
          username: _username.text.trim(),
          bio: _bio.text.trim(),
          birthday: _birthday != null ? DateFormat('yyyy-MM-dd').format(_birthday!) : null,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(error ?? 'Profile updated.')));
    if (error == null) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    final user = context.watch<SocialProvider>().me.data;

    return Scaffold(
      body: Column(
        children: [
          const AppTopBar(showBack: true, title: 'Edit profile'),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _uploadingAvatar ? null : _changeAvatar,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          SnapAvatar(
                            imageUrl: user?.avatarUrl,
                            fallbackText: user?.displayName ?? '',
                            size: AppTheme.avatarXl,
                          ),
                          if (_uploadingAvatar)
                            const Positioned.fill(
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else
                            CircleAvatar(
                              radius: AppTheme.iconSm,
                              backgroundColor: appColors.storyRing,
                              child: const Icon(Icons.camera_alt_rounded,
                                  size: AppTheme.iconSm, color: Colors.white),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (_avatarError != null) ...[
                    const SizedBox(height: AppTheme.spacingSm),
                    Text(_avatarError!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(color: appColors.danger)),
                  ],
                  const SizedBox(height: AppTheme.spacingXl),
                  TextFormField(
                    controller: _displayName,
                    decoration:
                        const InputDecoration(hintText: 'Display name'),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Enter a display name'
                            : null,
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  TextFormField(
                    controller: _username,
                    decoration: const InputDecoration(hintText: 'Username'),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.length < 3) {
                        return 'Usernames need at least 3 characters';
                      }
                      if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(text)) {
                        return 'Use letters, numbers, dots or underscores';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  TextFormField(
                    controller: _bio,
                    maxLines: 3,
                    maxLength: 160,
                    decoration: const InputDecoration(hintText: 'Bio'),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.cake_outlined),
                    title: const Text('Birthday'),
                    subtitle: Text(
                      _birthday != null
                          ? DateFormat.yMMMd().format(_birthday!)
                          : 'Not set',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _pickBirthday,
                  ),
                  const SizedBox(height: AppTheme.spacingXl),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: AppTheme.iconSm,
                            height: AppTheme.iconSm,
                            child: CircularProgressIndicator(
                                strokeWidth: AppTheme.borderThick),
                          )
                        : const Text('Save changes'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

