import 'dart:async';

import 'package:flutter/foundation.dart';

import 'api_service.dart';
import 'realtime_service.dart';

/// Light-weight WebRTC signaling abstraction. This file does NOT implement
/// platform-native WebRTC APIs (like `flutter_webrtc`) — it provides the
/// signaling scaffolding that the app can call into once a WebRTC plugin
/// is wired into the project. The service uses REST for offer/answer upload
/// and Reverb (RealtimeService) for incoming call notifications.
class WebRtcService {
  final ApiService _api;
  final RealtimeService _realtime;

  WebRtcService({required ApiService api, required RealtimeService realtime}) : _api = api, _realtime = realtime;

  final Map<String, List<void Function(Map<String, dynamic>)>> _on = {};

  void on(String event, void Function(Map<String, dynamic>) cb) {
    _on.putIfAbsent(event, () => []).add(cb);
  }

  void off(String event, void Function(Map<String, dynamic>) cb) {
    _on[event]?.remove(cb);
  }

  Future<String> createCall({
    required String calleeId,
    required String kind,
    String? conversationId,
  }) async {
    final res = await _api.post('/calls', data: {
      'callee_id': int.tryParse(calleeId),
      if (conversationId != null) 'conversation_id': int.tryParse(conversationId),
      'type': kind == 'video' ? 'video' : 'audio',
    });
    final body = res.data is Map && res.data['data'] != null ? res.data['data'] : res.data;
    return body['call_id']?.toString() ?? body['uuid']?.toString() ?? '';
  }

  Future<void> sendOffer(String callId, Map<String, dynamic> offer) async {
    await _api.post('/calls/$callId/signal', data: {'kind': 'offer', 'data': offer});
  }

  Future<void> sendAnswer(String callId, Map<String, dynamic> answer) async {
    await _api.post('/calls/$callId/signal', data: {'kind': 'answer', 'data': answer});
  }

  Future<void> endCall(String callId) async {
    await _api.post('/calls/$callId/end');
  }

  Future<void> acceptCall(String callId) async {
    await _api.post('/calls/$callId/accept');
  }

  Future<void> declineCall(String callId) async {
    await _api.post('/calls/$callId/decline');
  }

  Future<Map<String, dynamic>> fetchIceServers() async {
    final res = await _api.get('/calls/ice-servers');
    return Map<String, dynamic>.from(res.data as Map);
  }

  // Called by external Realtime message bridge when an incoming call arrives
  void handleIncoming(Map<String, dynamic> payload) {
    for (final cb in List<void Function(Map<String, dynamic>)>.from(_on['incoming'] ?? const [])) {
      cb(payload);
    }
  }
}
