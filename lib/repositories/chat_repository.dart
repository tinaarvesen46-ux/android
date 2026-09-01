import '../core/api_failure.dart';
import '../core/json_mappers.dart';
import '../models/chat.dart';
import '../services/api_service.dart';

/// Conversations and messages.
///
/// BACKEND CONTRACT (bearer auth on every route):
///   GET    /conversations                     -> conversation list
///   POST   /conversations                     { user_id }
///   GET    /conversations/{id}/messages       -> messages, oldest first
///   POST   /conversations/{id}/messages       { type: text, content }
///   POST   /conversations/{id}/read
///   POST   /conversations/{id}/mute           { muted: bool }
///   DELETE /conversations/{id}
///
/// REALTIME: message fan-out is delivered on the Reverb private channel
/// `private-conversation.{id}` with event `message.created`, carrying the same
/// message shape as the REST response. ChatsProvider subscribes on load/open
/// and reconciles duplicate events by message id.
class ChatRepository {
  final ApiService _api;

  ChatRepository({required ApiService api}) : _api = api;

  Future<List<Conversation>> fetchConversations() => guardApi(() async {
        final res = await _api.get('/conversations');
        return asList(res.data).map(conversationFromJson).toList();
      });

  Future<String> createConversation(String userId) => guardApi(() async {
        final res = await _api.post('/conversations', data: {'user_id': userId});
        final body = res.data;
        final data =
            body is Map && body['data'] != null ? asMap(body['data']) : asMap(body);
        final id = asString(data['id']);
        if (id.isEmpty) {
          throw const ApiFailure('The conversation could not be created.');
        }
        return id;
      });

  Future<List<ChatMessage>> fetchMessages(String conversationId) =>
      guardApi(() async {
        final res = await _api.get('/conversations/$conversationId/messages');
        return asList(res.data).map(messageFromJson).toList();
      });

  Future<ChatMessage> sendTextMessage({
    required String conversationId,
    required String content,
  }) =>
      guardApi(() async {
        final res = await _api.post(
          '/conversations/$conversationId/messages',
          data: {'type': 'text', 'content': content},
        );
        final body = res.data;
        return messageFromJson(
          body is Map && body['data'] != null ? asMap(body['data']) : asMap(body),
        );
      });

  Future<void> markRead(String conversationId) =>
      guardApi(() => _api.post('/conversations/$conversationId/read'));

  Future<void> setMuted(String conversationId, bool muted) => guardApi(
        () => _api.post(
          '/conversations/$conversationId/mute',
          data: {'muted': muted},
        ),
      );

  Future<void> deleteConversation(String conversationId) =>
      guardApi(() => _api.delete('/conversations/$conversationId'));

  /// Realtime-only signal, not persisted. Fans out as `user.typing` on
  /// `private-conversation.{id}`.
  Future<void> sendTyping(String conversationId, bool isTyping) => guardApi(
        () => _api.post(
          '/conversations/$conversationId/typing',
          data: {'is_typing': isTyping},
        ),
      );

  // --- Call signaling (optional, backend must implement /calls endpoints) ---
  Future<String> createCall({required String calleeId, required String kind, String? conversationId}) => guardApi(() async {
        final res = await _api.post('/calls', data: {
          'callee_id': int.tryParse(calleeId),
          if (conversationId != null) 'conversation_id': int.tryParse(conversationId),
          'type': kind == 'video' ? 'video' : 'audio',
        });
        final data = res.data is Map && res.data['data'] != null ? asMap(res.data['data']) : asMap(res.data);
        return asString(data['call_id'] ?? data['uuid']);
      });

  Future<void> sendCallOffer(String callId, Map<String, dynamic> offer) => guardApi(() => _api.post('/calls/' + callId + '/signal', data: {'kind': 'offer', 'data': offer}));

  Future<void> sendCallAnswer(String callId, Map<String, dynamic> answer) => guardApi(() => _api.post('/calls/' + callId + '/signal', data: {'kind': 'answer', 'data': answer}));

  Future<void> endCall(String callId) => guardApi(() => _api.post('/calls/' + callId + '/end'));
}
