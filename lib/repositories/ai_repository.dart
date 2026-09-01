import '../core/api_failure.dart';
import '../core/json_mappers.dart';
import '../services/api_service.dart';

class AiReply {
  final String text;
  final String? conversationId;

  const AiReply({required this.text, this.conversationId});
}

class AiMessage {
  final String id;
  final String role;
  final String content;
  final DateTime createdAt;

  const AiMessage({required this.id, required this.role, required this.content, required this.createdAt});
}

/// Server-side My AI boundary. Flutter never calls an LLM directly; the API
/// decides whether a safe, configured provider is available.
class AiRepository {
  final ApiService _api;

  AiRepository({required ApiService api}) : _api = api;

  Future<List<AiMessage>> history() => guardApi(() async {
        final res = await _api.get('/my-ai/messages');
        return asList(res.data)
            .map((item) => asMap(item))
            .map((json) => AiMessage(
                  id: asString(json['id']),
                  role: asString(json['role']),
                  content: asString(json['content']),
                  createdAt: asDate(json['created_at']),
                ))
            .toList();
      });

  Future<AiReply> sendMessage(String prompt) => guardApi(() async {
        final res = await _api.post('/my-ai/messages', data: {'prompt': prompt});
        final body = res.data is Map && res.data['data'] != null
            ? asMap(res.data['data'])
            : asMap(res.data);
        final text = asString(body['reply'] ?? body['content'] ?? body['message']);
        if (text.isEmpty) throw const ApiFailure('My AI did not return a response.');
        return AiReply(text: text, conversationId: asNullableString(body['conversation_id']));
      });
}
