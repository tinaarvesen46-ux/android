import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/social_provider.dart';
import '../theme/theme.dart';
import '../widgets/common/app_top_bar.dart';

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
  bool _saving = false;

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

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final error = await context.read<SocialProvider>().updateProfile(
          displayName: _displayName.text.trim(),
          username: _username.text.trim(),
          bio: _bio.text.trim(),
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
