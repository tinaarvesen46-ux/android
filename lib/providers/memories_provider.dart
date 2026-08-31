import 'package:flutter/foundation.dart';

import '../core/api_failure.dart';
import '../core/load_state.dart';
import '../models/media.dart';
import '../repositories/media_repository.dart';

class MemoriesProvider extends ChangeNotifier {
  final MediaRepository _media;

  MemoriesProvider({required MediaRepository mediaRepository})
      : _media = mediaRepository;

  LoadState<List<MemoryItem>> _memories = LoadState<List<MemoryItem>>.idle();
  String? _activeKind;

  LoadState<List<MemoryItem>> get memories => _memories;

  String? get activeKind => _activeKind;

  Future<void> load({String? kind}) async {
    _activeKind = kind;
    _memories = LoadState<List<MemoryItem>>.loading();
    notifyListeners();
    try {
      _memories = listState(await _media.fetchMemories(kind: kind));
    } on ApiFailure catch (e) {
      _memories = LoadState<List<MemoryItem>>.error(e.message);
    }
    notifyListeners();
  }

  Future<String?> delete(String id) async {
    try {
      await _media.deleteMemory(id);
      await load(kind: _activeKind);
      return null;
    } on ApiFailure catch (e) {
      return e.message;
    }
  }

  Future<String?> toggleFavorite(String id) async {
    try {
      await _media.toggleFavorite(id);
      await load(kind: _activeKind);
      return null;
    } on ApiFailure catch (e) {
      return e.message;
    }
  }
}
