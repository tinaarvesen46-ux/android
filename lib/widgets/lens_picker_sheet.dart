import 'dart:async';
import 'package:flutter/material.dart';
import '../api/services/lens_service.dart';

/// LensPickerSheet
/// ─────────────────────────────────────────────────────────────────
/// Global lens catalog with a search bar at the top.  Debounced 300 ms
/// against `GET /api/v1/lenses?search=...` (backend already supports the
/// query param).  Returns the picked lens back to the caller so the
/// camera / world screen can switch to it in one tap.
///
///     final lens = await LensPickerSheet.show(context);
///     if (lens != null) applyLens(lens);
class LensPickerSheet extends StatefulWidget {
  const LensPickerSheet({super.key});

  static Future<Map<String, dynamic>?> show(BuildContext context) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LensPickerSheet(),
    );
  }

  @override
  State<LensPickerSheet> createState() => _LensPickerSheetState();
}

class _LensPickerSheetState extends State<LensPickerSheet> {
  String _q = '';
  String _category = 'all';
  List<Map<String, dynamic>> _rows = const [];
  List<Map<String, dynamic>> _categories = const [];
  bool _loading = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _refresh();
  }

  @override
  void dispose() { _debounce?.cancel(); super.dispose(); }

  Future<void> _loadCategories() async {
    final cats = await LensService().categories();
    if (mounted) setState(() => _categories = cats);
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final rows = await LensService().browse(
      category: _category == 'all' ? null : _category,
      search: _q.trim().isEmpty ? null : _q.trim(),
      sort: 'popular',
    );
    if (!mounted) return;
    setState(() { _rows = rows; _loading = false; });
  }

  void _onQ(String v) {
    _debounce?.cancel();
    setState(() => _q = v);
    _debounce = Timer(const Duration(milliseconds: 300), _refresh);
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
        child: Column(children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 40, height: 4,
            decoration: BoxDecoration(color: theme.dividerColor.withOpacity(0.4), borderRadius: BorderRadius.circular(4)),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(children: [
              const Icon(Icons.auto_awesome, size: 20),
              const SizedBox(width: 8),
              const Text('Lens catalog', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const Spacer(),
              Text('${_rows.length} results', style: TextStyle(fontSize: 12, color: theme.hintColor)),
            ]),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              key: const Key('lens-search'),
              onChanged: _onQ,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search all lenses — sunglasses, confetti, sparkle…',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _q.isEmpty ? null : IconButton(
                  key: const Key('lens-search-clear'),
                  onPressed: () { _onQ(''); },
                  icon: const Icon(Icons.close, size: 18),
                ),
                filled: true,
                fillColor: theme.dividerColor.withOpacity(0.08),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
          // Category chips
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: [
                _chip('all', 'All'),
                for (final c in _categories)
                  _chip((c['slug'] ?? c['name']).toString(),
                        (c['name'] ?? c['slug'] ?? '?').toString()),
              ],
            ),
          ),
          const Divider(height: 1),
          // Results grid
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _rows.isEmpty
                    ? Center(child: Text(
                        _q.trim().isEmpty ? 'No lenses in this category yet.' : 'No matches for "$_q".',
                        style: TextStyle(color: theme.hintColor)))
                    : GridView.builder(
                        controller: controller,
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.75,
                        ),
                        itemCount: _rows.length,
                        itemBuilder: (_, i) {
                          final l = _rows[i];
                          final thumb = l['thumbnail_url'] as String?;
                          final uses = (l['use_count'] ?? 0) as int;
                          return GestureDetector(
                            key: Key('lens-hit-${l['id']}'),
                            onTap: () => Navigator.of(context).pop(l),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: theme.dividerColor.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(14),
                                    image: thumb != null ? DecorationImage(image: NetworkImage(thumb), fit: BoxFit.cover) : null,
                                  ),
                                  child: thumb == null ? Center(child: Icon(Icons.auto_awesome, size: 28, color: theme.hintColor)) : null,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text((l['name'] ?? '').toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                              Text('$uses uses', style: TextStyle(fontSize: 10, color: theme.hintColor)),
                            ]),
                          );
                        },
                      ),
          ),
        ]),
      ),
    );
  }

  Widget _chip(String slug, String label) {
    final selected = _category == slug;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        key: Key('lens-cat-$slug'),
        label: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: selected ? Colors.white : null)),
        selected: selected,
        onSelected: (_) { setState(() => _category = slug); _refresh(); },
      ),
    );
  }
}
