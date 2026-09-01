import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:web_socket_channel/web_socket_channel.dart';

import 'api_service.dart';

/// Minimal Pusher-protocol client for the self-hosted Laravel Reverb server.
///
/// BACKEND CONTRACT:
///   GET  /realtime/config      -> { key, host, port, scheme } (public app key)
///   POST /broadcasting/auth    { socket_id, channel_name }   -> { auth, channel_data? }
///
/// Speaks the Pusher wire protocol directly (connect, subscribe, ping/pong,
/// reconnect with backoff) so the app has no dependency on Pusher's own
/// hosted service — everything terminates on the user's own VPS.
class RealtimeService {
  RealtimeService({required ApiService api}) : _api = api;

  final ApiService _api;
  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  String? _socketId;
  bool _connected = false;
  bool _connecting = false;
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  int _reconnectAttempts = 0;

  final Set<String> _subscribed = {};
  final Map<String, Map<String, List<void Function(Map<String, dynamic>)>>>
      _listeners = {};
  final Map<String, int> _lastEventAt = {};

  bool get isConnected => _connected;

  Future<void> connect() async {
    if (_connected || _connecting) return;
    _connecting = true;
    try {
      final res = await _api.get('/realtime/config');
      final cfg = res.data as Map;
      final scheme = cfg['scheme'] == 'https' ? 'wss' : 'ws';
      final uri = Uri.parse(
        '$scheme://${cfg['host']}:${cfg['port']}/app/${cfg['key']}'
        '?protocol=7&client=flutter&version=1.0&flash=false',
      );
      _channel = WebSocketChannel.connect(uri);
      _sub = _channel!.stream.listen(
        _onMessage,
        onDone: _handleDisconnect,
        onError: (_) => _handleDisconnect(),
        cancelOnError: true,
      );
    } catch (_) {
      _connecting = false;
      _scheduleReconnect();
    }
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    _heartbeatTimer?.cancel();
    _sub?.cancel();
    _channel?.sink.close();
    _channel = null;
    _connected = false;
    _connecting = false;
    _socketId = null;
    _reconnectAttempts = 0;
    _subscribed.clear();
    _listeners.clear();
    _lastEventAt.clear();
    unawaited(_api.post('/presence/offline').catchError((_) {}));
  }

  /// Subscribe to a private channel (`private-...`). Auth happens via
  /// POST /broadcasting/auth using the current bearer token.
  Future<void> subscribePrivate(String channel) => _subscribe(channel);

  /// Subscribe to a presence channel (`presence-...`).
  Future<void> subscribePresence(String channel) => _subscribe(channel);

  void unsubscribe(String channel) {
    _subscribed.remove(channel);
    _send({'event': 'pusher:unsubscribe', 'data': {'channel': channel}});
  }

  void on(String channel, String event, void Function(Map<String, dynamic>) callback) {
    _listeners.putIfAbsent(channel, () => {}).putIfAbsent(event, () => []).add(callback);
  }

  void off(String channel, String event, void Function(Map<String, dynamic>) callback) {
    _listeners[channel]?[event]?.remove(callback);
  }

  Future<void> _subscribe(String channel) async {
    _subscribed.add(channel);
    if (!_connected || _socketId == null) return; // resolved on (re)connect
    try {
      final res = await _api.post('/broadcasting/auth', data: {
        'socket_id': _socketId,
        'channel_name': channel,
      });
      final body = res.data as Map;
      _send({
        'event': 'pusher:subscribe',
        'data': {
          'channel': channel,
          'auth': body['auth'],
          if (body['channel_data'] != null) 'channel_data': body['channel_data'],
        },
      });
    } catch (_) {
      _subscribed.remove(channel);
    }
  }

  void _resubscribeAll() {
    for (final channel in List<String>.of(_subscribed)) {
      _subscribed.remove(channel);
      _subscribe(channel);
    }
  }

  void _send(Map<String, dynamic> payload) {
    try {
      _channel?.sink.add(jsonEncode(payload));
    } catch (_) {}
  }

  void _onMessage(dynamic raw) {
    Map<String, dynamic> msg;
    try {
      msg = jsonDecode(raw as String) as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    final event = msg['event'] as String?;
    final channel = msg['channel'] as String?;
    dynamic data = msg['data'];
    if (data is String) {
      try {
        data = jsonDecode(data);
      } catch (_) {}
    }
    final payload = data is Map<String, dynamic> ? data : <String, dynamic>{};

    if (event == 'pusher:connection_established') {
      _socketId = payload['socket_id'] as String?;
      _connected = true;
      _connecting = false;
      _reconnectAttempts = 0;
      _startPing();
      _startHeartbeat();
      _resubscribeAll();
      _replayMissedEvents();
      return;
    }
    if (event == null || channel == null) return;
    for (final cb in List<void Function(Map<String, dynamic>)>.of(
        _listeners[channel]?[event] ?? const [])) {
      cb(payload);
    }
    // record last-seen timestamp for reconciliation
    try {
      final ts = (payload['timestamp'] ?? payload['ts']) as int?;
      if (ts != null) _lastEventAt[channel!] = ts;
    } catch (_) {}
  }

  Future<void> _replayMissedEvents() async {
    try {
      final since = _lastEventAt.values.isEmpty ? null : (_lastEventAt.values.reduce((a, b) => a > b ? a : b));
      if (since == null) return;
      final res = await _api.get('/realtime/missed', queryParams: {'since': since});
      final list = res.data as List? ?? [];
      for (final raw in list) {
        try {
          final channel = raw['channel'] as String?;
          final event = raw['event'] as String?;
          final data = raw['data'] as Map<String, dynamic>? ?? {};
          if (channel != null && event != null) {
            for (final cb in List<void Function(Map<String, dynamic>)>.of(_listeners[channel]?[event] ?? const [])) {
              cb(data);
            }
            final ts = raw['timestamp'] as int?;
            if (ts != null) _lastEventAt[channel] = ts;
          }
        } catch (_) {}
      }
    } catch (_) {}
  }

  void _startPing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      _send({'event': 'pusher:ping', 'data': {}});
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    unawaited(_api.post('/presence/heartbeat').catchError((_) {}));
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      unawaited(_api.post('/presence/heartbeat').catchError((_) {}));
    });
  }

  void _handleDisconnect() {
    final wasConnected = _connected;
    _connected = false;
    _connecting = false;
    _socketId = null;
    _pingTimer?.cancel();
    _heartbeatTimer?.cancel();
    if (wasConnected || _reconnectAttempts == 0) _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    final seconds = math.min(30, 2 * (1 << math.min(_reconnectAttempts, 4)));
    _reconnectAttempts++;
    _reconnectTimer = Timer(Duration(seconds: seconds), connect);
  }
}
