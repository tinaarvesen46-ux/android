import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../models/chat_model.dart';
import '../providers/app_provider.dart';
import '../widgets/selected_friend_picker.dart';

/// Real group management: members list, add/remove (owner/admin), rename, leave.
/// All actions persist through Laravel (/chats/{id}/participants, PUT /chats/{id}).
class GroupInfoScreen extends StatefulWidget {
  final ChatModel chat;
  const GroupInfoScreen({super.key, required this.chat});

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _members = [];
  String _myRole = 'member';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final members = await context.read<AppProvider>().getGroupParticipants(widget.chat.id);
    if (!mounted) return;
    final myId = context.read<AppProvider>().currentUser?.id;
    final mine = members.firstWhere(
      (m) => '${m['user_id'] ?? m['user']?['id']}' == myId,
      orElse: () => const {},
    );
    setState(() {
      _members = members;
      _myRole = (mine['role'] ?? 'member').toString();
      _loading = false;
    });
  }

  bool get _canManage => _myRole == 'owner' || _myRole == 'admin';

  Future<void> _addMembers() async {
    final ids = await SelectedFriendPicker.show(context);
    if (ids == null || ids.isEmpty || !mounted) return;
    final p = context.read<AppProvider>();
    for (final id in ids) {
      final err = await p.addGroupMember(widget.chat.id, id);
      if (err != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      }
    }
    await _load();
  }

  Future<void> _remove(int userId, String username) async {
    final err = await context.read<AppProvider>().removeGroupMember(widget.chat.id, userId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(err ?? 'Removed @$username')),
    );
    if (err == null) await _load();
  }

  Future<void> _rename() async {
    final ctrl = TextEditingController(text: widget.chat.groupName ?? '');
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: SwiftSnapTheme.surfaceColor,
        title: const Text('Rename group', style: TextStyle(color: SwiftSnapTheme.textPrimary)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: SwiftSnapTheme.textPrimary),
          decoration: const InputDecoration(hintText: 'Group name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    if (name == null || name.isEmpty || !mounted) return;
    final err = await context.read<AppProvider>().renameGroup(widget.chat.id, name);
    if (mounted && err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    } else if (mounted) {
      setState(() {});
    }
  }

  Future<void> _leave() async {
    final err = await context.read<AppProvider>().leaveGroup(widget.chat.id);
    if (!mounted) return;
    if (err == null) {
      Navigator.of(context)..pop()..pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: SwiftSnapTheme.backgroundDark,
        elevation: 0,
        title: const Text('Group Info', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        actions: [
          if (_canManage)
            IconButton(icon: const Icon(Icons.edit_rounded, size: 20), onPressed: _rename),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: SwiftSnapTheme.primaryPurple))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Center(
                  child: Column(children: [
                    Container(
                      width: 76, height: 76,
                      decoration: const BoxDecoration(gradient: SwiftSnapTheme.primaryGradient, shape: BoxShape.circle),
                      child: const Icon(Icons.group_rounded, color: Colors.white, size: 36),
                    ),
                    const SizedBox(height: 10),
                    Text(widget.chat.title,
                        style: const TextStyle(color: SwiftSnapTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                    Text('${_members.length} members',
                        style: const TextStyle(color: SwiftSnapTheme.textMuted, fontSize: 13)),
                  ]),
                ),
                const SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Members',
                      style: TextStyle(color: SwiftSnapTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w700)),
                  if (_canManage)
                    TextButton.icon(
                      onPressed: _addMembers,
                      icon: const Icon(Icons.add_rounded, size: 18, color: SwiftSnapTheme.primaryPurple),
                      label: const Text('Add', style: TextStyle(color: SwiftSnapTheme.primaryPurple)),
                    ),
                ]),
                ..._members.map(_memberTile),
                const SizedBox(height: 20),
                GestureDetector(
                  key: const Key('group-leave-btn'),
                  onTap: _leave,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: SwiftSnapTheme.busy.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.logout_rounded, color: SwiftSnapTheme.busy, size: 20),
                      SizedBox(width: 8),
                      Text('Leave Group', style: TextStyle(color: SwiftSnapTheme.busy, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _memberTile(Map<String, dynamic> m) {
    final user = m['user'] is Map ? m['user'] as Map : const {};
    final uid = int.tryParse('${m['user_id'] ?? user['id'] ?? ''}') ?? 0;
    final username = (user['username'] ?? 'user').toString();
    final display = (user['display_name'] ?? username).toString();
    final role = (m['role'] ?? 'member').toString();
    final myId = context.read<AppProvider>().currentUser?.id;
    final isMe = '$uid' == myId;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: SwiftSnapTheme.surfaceColor, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: SwiftSnapTheme.primaryPurple.withOpacity(0.2),
          child: Text(display.isNotEmpty ? display[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(isMe ? '$display (You)' : display,
                style: const TextStyle(color: SwiftSnapTheme.textPrimary, fontWeight: FontWeight.w600)),
            Text('@$username', style: const TextStyle(color: SwiftSnapTheme.textMuted, fontSize: 12)),
          ]),
        ),
        if (role == 'owner' || role == 'admin')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: SwiftSnapTheme.primaryPurple.withOpacity(0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(role, style: const TextStyle(color: SwiftSnapTheme.primaryPurple, fontSize: 11)),
          ),
        if (_canManage && !isMe && role != 'owner')
          IconButton(
            icon: const Icon(Icons.remove_circle_outline_rounded, color: SwiftSnapTheme.busy, size: 20),
            onPressed: () => _remove(uid, username),
          ),
      ]),
    );
  }
}
