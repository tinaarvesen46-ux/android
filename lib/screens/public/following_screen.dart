import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/social_provider.dart';

class FollowingScreen extends StatefulWidget {
  final String userId;

  const FollowingScreen({super.key, required this.userId});

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  bool _loading = true;
  List<dynamic> _items = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await context.read<SocialProvider>().fetchFollowingList(widget.userId);
      setState(() { _items = list; });
    } catch (e) {
      setState(() { _error = e.toString(); });
    }
    setState(() { _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Following')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _items.isEmpty
                  ? const Center(child: Text('Not following anyone'))
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (context, i) {
                        final u = _items[i];
                        return ListTile(
                          leading: u.avatarUrl != null ? CircleAvatar(backgroundImage: NetworkImage(u.avatarUrl!)) : null,
                          title: Text(u.displayName),
                          subtitle: Text('@${u.username}'),
                        );
                      },
                    ),
    );
  }
}
