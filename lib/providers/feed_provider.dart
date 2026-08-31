import 'package:flutter/foundation.dart';

import '../core/api_failure.dart';
import '../core/load_state.dart';
import '../models/discover_item.dart';
import '../models/spotlight_post.dart';
import '../repositories/feed_repository.dart';

class FeedProvider extends ChangeNotifier {
  final FeedRepository _feed;

  FeedProvider({required FeedRepository feedRepository}) : _feed = feedRepository;

  LoadState<List<SpotlightPost>> _reels = LoadState<List<SpotlightPost>>.idle();
  LoadState<List<DiscoverItem>> _discover = LoadState<List<DiscoverItem>>.idle();
  LoadState<List<DiscoverCategory>> _categories =
      LoadState<List<DiscoverCategory>>.idle();
  String? _activeCategoryId;

  LoadState<List<SpotlightPost>> get reels => _reels;

  LoadState<List<DiscoverItem>> get discover => _discover;

  LoadState<List<DiscoverCategory>> get categories => _categories;

  String? get activeCategoryId => _activeCategoryId;

  Future<void> loadReels() async {
    _reels = LoadState<List<SpotlightPost>>.loading();
    notifyListeners();
    try {
      _reels = listState(await _feed.fetchReels());
    } on ApiFailure catch (e) {
      _reels = LoadState<List<SpotlightPost>>.error(e.message);
    }
    notifyListeners();
  }

  Future<void> loadCategories() async {
    _categories = LoadState<List<DiscoverCategory>>.loading();
    notifyListeners();
    try {
      _categories = listState(await _feed.fetchDiscoverCategories());
    } on ApiFailure catch (e) {
      _categories = LoadState<List<DiscoverCategory>>.error(e.message);
    }
    notifyListeners();
  }

  Future<void> loadDiscover({String? categoryId}) async {
    _activeCategoryId = categoryId;
    _discover = LoadState<List<DiscoverItem>>.loading();
    notifyListeners();
    try {
      _discover = listState(await _feed.fetchDiscover(categoryId: categoryId));
    } on ApiFailure catch (e) {
      _discover = LoadState<List<DiscoverItem>>.error(e.message);
    }
    notifyListeners();
  }

  /// Optimistic like: the card updates immediately and is reverted if the
  /// backend rejects the change.
  Future<String?> toggleLike(SpotlightPost post) async {
    final liked = !post.isLiked;
    final nextCount = liked ? post.likeCount + 1 : post.likeCount - 1;
    _replace(
      post.copyWith(
        isLiked: liked,
        likeCount: nextCount < 0 ? 0 : nextCount,
      ),
    );
    try {
      await _feed.likeReel(post.id, liked);
      return null;
    } on ApiFailure catch (e) {
      _replace(post);
      return e.message;
    }
  }

  Future<String?> toggleSave(SpotlightPost post) async {
    final saved = !post.isSaved;
    _replace(post.copyWith(isSaved: saved));
    try {
      await _feed.saveReel(post.id, saved);
      return null;
    } on ApiFailure catch (e) {
      _replace(post);
      return e.message;
    }
  }

  void _replace(SpotlightPost updated) {
    final current = _reels.data;
    if (current == null) return;
    _reels = LoadState<List<SpotlightPost>>.success([
      for (final post in current) post.id == updated.id ? updated : post,
    ]);
    notifyListeners();
  }
}
