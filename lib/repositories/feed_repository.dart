import '../core/api_failure.dart';
import '../core/json_mappers.dart';
import '../models/discover_item.dart';
import '../models/spotlight_post.dart';
import '../models/story.dart';
import '../services/api_service.dart';

/// Stories, the Reels feed and Discover.
///
/// BACKEND CONTRACT (bearer auth on every route):
///   GET  /stories                     -> stories grouped per author
///   POST /stories/{itemId}/view
///   POST /stories/{itemId}/reply      { content }
///   GET  /spotlight                   -> reels list
///   POST /spotlight/{id}/like         { liked: bool }
///   POST /spotlight/{id}/save         { saved: bool }
///   GET  /discover/categories         -> category list
///   GET  /discover?category=          -> discover items
class FeedRepository {
  final ApiService _api;

  FeedRepository({required ApiService api}) : _api = api;

  Future<List<Story>> fetchStories() => guardApi(() async {
        final res = await _api.get('/stories');
        return asList(res.data).map(storyFromJson).toList();
      });

  Future<void> markStoryViewed(String storyItemId) =>
      guardApi(() => _api.post('/stories/$storyItemId/view'));

  Future<void> replyToStory({
    required String storyItemId,
    required String content,
  }) =>
      guardApi(() => _api.post(
            '/stories/$storyItemId/reply',
            data: {'content': content},
          ));

  Future<List<dynamic>> fetchStoryReplies(String storyItemId) => guardApi(() async {
        final res = await _api.get('/stories/$storyItemId/replies');
        return asList(res.data);
      });

  Future<List<SpotlightPost>> fetchReels() => guardApi(() async {
        final res = await _api.get('/spotlight');
        return asList(res.data).map(spotlightPostFromJson).toList();
      });

  Future<List<dynamic>> fetchStoryReactions(String storyItemId) => guardApi(() async {
        final res = await _api.get('/stories/$storyItemId/reactions');
        return asList(res.data);
      });

  Future<void> postStoryReaction(String storyItemId, String reaction) => guardApi(
        () => _api.post('/stories/$storyItemId/reaction', data: {'reaction': reaction}),
      );

  Future<void> removeStoryReaction(String storyItemId) =>
      guardApi(() => _api.delete('/stories/$storyItemId/reaction'));

  Future<void> likeReel(String postId, bool liked) => guardApi(
        () => _api.post('/spotlight/$postId/like', data: {'liked': liked}),
      );

  Future<void> saveReel(String postId, bool saved) => guardApi(
        () => _api.post('/spotlight/$postId/save', data: {'saved': saved}),
      );

  Future<List<DiscoverCategory>> fetchDiscoverCategories() => guardApi(() async {
        final res = await _api.get('/discover/categories');
        return asList(res.data).map(discoverCategoryFromJson).toList();
      });

  Future<List<DiscoverItem>> fetchDiscover({String? categoryId}) =>
      guardApi(() async {
        final res = await _api.get(
          '/discover',
          queryParams: categoryId == null ? null : {'category': categoryId},
        );
        return asList(res.data).map(discoverItemFromJson).toList();
      });
}
