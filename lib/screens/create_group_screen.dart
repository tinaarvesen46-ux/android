import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../providers/app_provider.dart';
import '../widgets/selected_friend_picker.dart';
import 'chat_detail_screen.dart';

/// Create a real group conversation (persisted via POST /chats type=group).
class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _name = TextEditingController();
  List<int> _memberIds = [];
  bool _creating = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickMembers() async {
    final ids = await SelectedFriendPicker.show(context);
    if (ids != null && mounted) setState(() => _memberIds = ids);
  }

  Future<void> _create() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a group name')));
      return;
    }
    if (_memberIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add at least one member')));
      return;
    }
    setState(() => _creating = true);
    HapticFeedback.mediumImpact();
    final chat = await context.read<AppProvider>().createGroup(name, _memberIds);
    if (!mounted) return;
    setState(() => _creating = false);
    if (chat == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not create group')));
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ChatDetailScreen(chat: chat)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: SwiftSnapTheme.backgroundDark,
        elevation: 0,
        title: const Text('New Group', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: const BoxDecoration(gradient: SwiftSnapTheme.primaryGradient, shape: BoxShape.circle),
                child: const Icon(Icons.group_rounded, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextField(
                  controller: _name,
                  key: const Key('group-name-input'),
                  style: const TextStyle(color: SwiftSnapTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Group name',
                    hintStyle: const TextStyle(color: SwiftSnapTheme.textMuted),
                    filled: true,
                    fillColor: SwiftSnapTheme.surfaceColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            key: const Key('group-pick-members'),
            onTap: _pickMembers,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: SwiftSnapTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                const Icon(Icons.person_add_alt_1_rounded, color: SwiftSnapTheme.primaryPurple),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _memberIds.isEmpty ? 'Add members' : '${_memberIds.length} member(s) selected',
                    style: const TextStyle(color: SwiftSnapTheme.textPrimary, fontWeight: FontWeight.w600),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: SwiftSnapTheme.textMuted),
              ]),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              key: const Key('group-create-btn'),
              style: ElevatedButton.styleFrom(
                backgroundColor: SwiftSnapTheme.primaryPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _creating ? null : _create,
              child: _creating
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Create Group', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
