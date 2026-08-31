import 'package:dio/dio.dart' show FormData, MultipartFile;
import 'package:flutter/foundation.dart';

import '../core/api_failure.dart';
import '../core/json_mappers.dart';
import '../models/media.dart';
import '../services/api_service.dart';

/// Media upload and the Memories archive.
///
/// BACKEND CONTRACT (bearer auth on every route):
///   POST /media  (multipart: file, kind=photo|video)
///        -> { id, media_url, thumbnail_url }
///        Validation: mime image/* or video/*, max 25 MB photo / 150 MB video.
///   POST /stories        { media_id, audience: friends|custom|public }
///   POST /spotlight      { media_id, caption?, hashtags[]? }
///   POST /memories       { media_id }
///   POST /conversations/{id}/messages { type, media_id }
///   GET  /memories?kind= -> paginated memory list
///   DELETE /memories/{id}
///   POST /memories/{id}/favorite
class MediaRepository {
  final ApiService _api;

  MediaRepository({required ApiService api}) : _api = api;

  /// Uploads a captured file and returns the backend media id.
  Future<String> uploadCapture(CaptureDraft draft) => guardApi(() async {
        if (kIsWeb) {
          // On web the capture path is an object URL; the backend media
          // endpoint expects a real multipart file upload.
          throw const ApiFailure(
            'Publishing captures is available on the SwiftSnap mobile app.',
          );
        }
        final form = FormData.fromMap({
          'kind': draft.isVideo ? 'video' : 'photo',
          'file': await MultipartFile.fromFile(draft.path),
        });
        final res = await _api.post('/media', data: form);
        final data = asMap(res.data is Map && res.data['data'] != null
            ? res.data['data']
            : res.data);
        final id = asString(data['id']);
        if (id.isEmpty) {
          throw const ApiFailure('The upload did not complete. Please retry.');
        }
        return id;
      });

  Future<void> publish({
    required CaptureDestination destination,
    required String mediaId,
    String? caption,
    String? conversationId,
  }) =>
      guardApi(() async {
        switch (destination) {
          case CaptureDestination.story:
            await _api.post('/stories', data: {
              'media_id': mediaId,
              'audience': 'friends',
            });
            break;
          case CaptureDestination.reels:
            await _api.post('/spotlight', data: {
              'media_id': mediaId,
              if (caption != null && caption.isNotEmpty) 'caption': caption,
            });
            break;
          case CaptureDestination.memories:
            await _api.post('/memories', data: {'media_id': mediaId});
            break;
          case CaptureDestination.sendTo:
            if (conversationId == null) {
              throw const ApiFailure('Choose a conversation to send this to.');
            }
            await _api.post('/conversations/$conversationId/messages', data: {
              'type': 'snap',
              'media_id': mediaId,
            });
            break;
        }
      });

  Future<List<MemoryItem>> fetchMemories({String? kind}) => guardApi(() async {
        final res = await _api.get(
          '/memories',
          queryParams: kind == null ? null : {'kind': kind},
        );
        return asList(res.data).map(memoryFromJson).toList();
      });

  Future<void> deleteMemory(String id) =>
      guardApi(() => _api.delete('/memories/$id'));

  Future<void> toggleFavorite(String id) =>
      guardApi(() => _api.post('/memories/$id/favorite'));
}
