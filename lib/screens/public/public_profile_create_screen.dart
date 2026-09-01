import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/social_provider.dart';
import '../../theme/theme.dart';

class PublicProfileCreateScreen extends StatefulWidget {
  const PublicProfileCreateScreen({super.key});

  @override
  State<PublicProfileCreateScreen> createState() => _PublicProfileCreateScreenState();
}

class _PublicProfileCreateScreenState extends State<PublicProfileCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _display = TextEditingController();
  final _username = TextEditingController();
  final _bio = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _display.dispose();
    _username.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final res = await context.read<SocialProvider>().createPublicProfile(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Public Profile')),
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
              ElevatedButton(
                onPressed: _loading ? null : _create,
                child: _loading ? const CircularProgressIndicator() : const Text('Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
