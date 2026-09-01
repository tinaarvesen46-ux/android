import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/social_provider.dart';
import '../../providers/social_provider.dart' as sp;
import '../../theme/theme.dart';

class PublicProfileEditScreen extends StatefulWidget {
  const PublicProfileEditScreen({super.key});

  @override
  State<PublicProfileEditScreen> createState() => _PublicProfileEditScreenState();
}

class _PublicProfileEditScreenState extends State<PublicProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _display;
  late final TextEditingController _username;
  late final TextEditingController _bio;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final me = context.read<SocialProvider>().me.data;
    _display = TextEditingController(text: me?.displayName ?? '');
    _username = TextEditingController(text: me?.username ?? '');
    _bio = TextEditingController(text: me?.bio ?? '');
  }

  @override
  void dispose() {
    _display.dispose();
    _username.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final me = context.read<SocialProvider>().me.data;
    if (me == null) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile unavailable')));
      return;
    }
    final res = await context.read<SocialProvider>().updatePublicProfile(
          profileId: me.id,
          displayName: _display.text.trim(),
          username: _username.text.trim(),
          bio: _bio.text.trim(),
        );
    setState(() => _loading = false);
    if (res != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res)));
      return;
    }
    Navigator.of(context).pop();
  }

  Future<void> _disable() async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Disable public profile?'),
            content: const Text('This will remove your public profile.'),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Disable')),
            ],
          ),
        ) ?? false;
    if (!ok) return;
    setState(() => _loading = true);
    final me = context.read<SocialProvider>().me.data;
    if (me == null) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile unavailable')));
      return;
    }
    final res = await context.read<SocialProvider>().disablePublicProfile(me.id);
    setState(() => _loading = false);
    if (res != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res)));
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Public Profile')),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _display,
                decoration: const InputDecoration(labelText: 'Display name'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppTheme.spacingMd),
              TextFormField(
                controller: _username,
                decoration: const InputDecoration(labelText: 'Public username'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppTheme.spacingMd),
              TextFormField(
                controller: _bio,
                decoration: const InputDecoration(labelText: 'Bio'),
                maxLines: 3,
              ),
              const SizedBox(height: AppTheme.spacingLg),
              Row(
                children: [
                  ElevatedButton(onPressed: _loading ? null : _save, child: _loading ? const CircularProgressIndicator() : const Text('Save')),
                  const SizedBox(width: AppTheme.spacingMd),
                  OutlinedButton(onPressed: _loading ? null : _disable, child: const Text('Disable')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
