import 'package:flutter/material.dart';
import '../api/services/location_service.dart';

/// SelectedFriendPicker — Snapchat-style "who can see me" modal.
///
/// Shown from SwiftMap's actions FAB when the current visibility is
/// `selected`.  Loads the full friend list, pre-checks anyone already on
/// the whitelist (from `/location/settings.selected_friend_ids`), and
/// PUTs the new set on save.
///
/// The server is the source of truth: it will drop any id that isn't
/// currently an accepted friend, so this widget doesn't need to guard
/// against stale relationships.
class SelectedFriendPicker extends StatefulWidget {
  const SelectedFriendPicker({super.key, this.initialSelected = const []});
  final List<int> initialSelected;

  static Future<List<int>?> show(BuildContext context, {List<int> initial = const []}) {
    return showModalBottomSheet<List<int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SelectedFriendPicker(initialSelected: initial),
    );
  }

  @override
  State<SelectedFriendPicker> createState() => _SelectedFriendPickerState();
}

class _SelectedFriendPickerState extends State<SelectedFriendPicker> {
  List<Map<String, dynamic>> _friends = const [];
  List<Map<String, dynamic>> _recent = const [];
  Set<int> _selected = <int>{};
  String _q = '';
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelected.toSet();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      LocationService().friendList(),
      LocationService().recentPartners(limit: 8),
    ]);
    if (!mounted) return;
    setState(() {
      _friends = results[0];
      _recent  = results[1];
      _loading = false;
    });
  }

  List<Map<String, dynamic>> get _filtered {
    if (_q.trim().isEmpty) return _friends;
    final q = _q.toLowerCase();
    return _friends.where((f) {
      final name = (f['display_name'] ?? f['username'] ?? '').toString().toLowerCase();
      final uname = (f['username'] ?? '').toString().toLowerCase();
      return name.contains(q) || uname.contains(q);
    }).toList();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final ids = _selected.toList();
    await LocationService().updateSettings(
      visibility: 'selected',
      selectedFriendIds: ids,
    );
    if (!mounted) return;
    Navigator.of(context).pop(ids);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, controller) => Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor.withOpacity(0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.people_alt, size: 20),
                  const SizedBox(width: 8),
                  const Text('Who can see me?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  Text('${_selected.length} selected',
                      style: TextStyle(color: theme.hintColor, fontSize: 12)),
                ],
              ),
            ),
            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                onChanged: (v) => setState(() => _q = v),
                decoration: InputDecoration(
                  hintText: 'Search friends…',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: theme.dividerColor.withOpacity(0.08),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
            // Quick actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  TextButton.icon(
                    key: const Key('picker-select-all'),
                    onPressed: _friends.isEmpty ? null : () =>
                        setState(() => _selected = _friends.map((f) => (f['id'] as num).toInt()).toSet()),
                    icon: const Icon(Icons.checklist, size: 16),
                    label: const Text('Select all'),
                  ),
                  TextButton.icon(
                    key: const Key('picker-clear'),
                    onPressed: _selected.isEmpty ? null : () => setState(() => _selected.clear()),
                    icon: const Icon(Icons.clear_all, size: 16),
                    label: const Text('Clear'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Recent snap partners — quick-pick strip
            if (_recent.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department, size: 14, color: Colors.orangeAccent),
                    const SizedBox(width: 4),
                    Text('Recent snap partners',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: theme.hintColor, letterSpacing: 0.6)),
                  ],
                ),
              ),
              SizedBox(
                height: 88,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _recent.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final f = _recent[i];
                    final id = (f['id'] as num).toInt();
                    final checked = _selected.contains(id);
                    final avatar = f['avatar_url'] ?? f['profile']?['avatar_url'];
                    final name = (f['display_name'] ?? f['username'] ?? '?').toString();
                    final count = (f['interaction_count'] ?? 0) as int;
                    return GestureDetector(
                      key: Key('picker-recent-$id'),
                      onTap: () => setState(() {
                        if (checked) { _selected.remove(id); } else { _selected.add(id); }
                      }),
                      child: SizedBox(
                        width: 62,
                        child: Column(
                          children: [
                            Stack(children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundImage: avatar != null ? NetworkImage(avatar) : null,
                                child: avatar == null ? Text(name.substring(0,1).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800)) : null,
                              ),
                              if (count >= 3) Positioned(
                                right: -2, top: -2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.orangeAccent, borderRadius: BorderRadius.circular(999), border: Border.all(color: theme.scaffoldBackgroundColor, width: 1.5)),
                                  child: Text('$count', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.black)),
                                ),
                              ),
                              if (checked) Positioned(
                                right: -2, bottom: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(color: Colors.tealAccent[400], borderRadius: BorderRadius.circular(999), border: Border.all(color: theme.scaffoldBackgroundColor, width: 1.5)),
                                  child: const Icon(Icons.check, size: 10, color: Colors.black),
                                ),
                              ),
                            ]),
                            const SizedBox(height: 4),
                            Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: theme.hintColor)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1),
            ],
            // Friend list
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _filtered.isEmpty
                      ? Center(child: Text(
                          _friends.isEmpty ? 'You have no friends yet.' : 'No matches.',
                          style: TextStyle(color: theme.hintColor)))
                      : ListView.builder(
                          controller: controller,
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) {
                            final f = _filtered[i];
                            final id = (f['id'] as num).toInt();
                            final checked = _selected.contains(id);
                            final name = (f['display_name'] ?? f['username'] ?? '?').toString();
                            final uname = (f['username'] ?? '').toString();
                            final avatar = f['avatar_url'] ?? f['profile']?['avatar_url'];
                            return CheckboxListTile(
                              key: Key('picker-friend-$id'),
                              value: checked,
                              onChanged: (v) => setState(() {
                                if (v == true) { _selected.add(id); } else { _selected.remove(id); }
                              }),
                              controlAffinity: ListTileControlAffinity.trailing,
                              secondary: CircleAvatar(
                                backgroundImage: avatar != null ? NetworkImage(avatar) : null,
                                child: avatar == null
                                    ? Text(name.substring(0, 1).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800))
                                    : null,
                              ),
                              title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: uname.isEmpty ? null : Text('@$uname', style: TextStyle(color: theme.hintColor, fontSize: 12)),
                            );
                          },
                        ),
            ),
            // Save button
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: const Key('picker-save'),
                    onPressed: _saving ? null : _save,
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: _saving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('Save (${_selected.length})', style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
