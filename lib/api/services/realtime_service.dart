import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;
import '../api_config.dart';
import '../api_client.dart';

/// Called for every real (non-internal) event on a subscribed channel.
typedef RealtimeEventHandler = void Function(
    String channelName, String eventName, Map<String, dynamic> data);

/// Pure-Dart Pusher-protocol client for the self-hosted Laravel Reverb server
/// (wss://ws.vexor.to). No native SDK — works with any host. Handles private
/// channel auth via /api/v1/broadcasting/auth, ping/pong, reconnect and
/// client events (whispers) for typing.
class RealtimeService {
  RealtimeService._();
  static final RealtimeService instance = RealtimeService._();

  final Dio _authDio = Dio();
  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  Timer? _pingTimer;
  Timer? _reconnectTimer;

  String? _socketId;
  bool _connected = false;
  bool _disposed = false;
  int _retry = 0;
  final Set<String> _channels = {};

  RealtimeEventHandler? onEvent;
  void Function(bool connected)? onConnectionChange;
  /// Presence: full member id set for a presence channel (on subscribe).
  void Function(String channel, Set<String> userIds)? onPresenceSync;
  /// Presence: a single member joined (true) or left (false).
  void Function(String channel, String userId, bool joined)? onPresenceChange;

  bool get isConnected => _connected;
  String? get socketId => _socketId;

  Future<void> connect() async {
    _disposed = false;
    if (_channel != null) return;
    final token = await ApiClient().getAccessToken();
    if (token == null) return;

    final url =
        'wss://${ApiConfig.reverbHost}:${ApiConfig.reverbPort}/app/${ApiConfig.reverbKey}'
        '?protocol=7&client=flutter&version=1.0';
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _sub = _channel!.stream.listen(
        _onData,
        onError: (_) => _scheduleReconnect(),
        onDone: _scheduleReconnect,
        cancelOnError: true,
      );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _onData(dynamic raw) {
    Map<String, dynamic> msg;
    try {
      msg = Map<String, dynamic>.from(jsonDecode(raw as String));
    } catch (_) {
      return;
    }
    final event = msg['event'] as String? ?? '';
    final channel = msg['channel'] as String? ?? '';

    // pusher `data` is a JSON-encoded string.
    Map<String, dynamic> data = {};
    final rawData = msg['data'];
    if (rawData is String && rawData.isNotEmpty) {
      try {
        final d = jsonDecode(rawData);
        if (d is Map) data = Map<String, dynamic>.from(d);
      } catch (_) {}
    } else if (rawData is Map) {
      data = Map<String, dynamic>.from(rawData);
    }

    switch (event) {
      case 'pusher:connection_established':
        _socketId = data['socket_id'] as String?;
        _connected = true;
        _retry = 0;
        onConnectionChange?.call(true);
        _startPing();
        for (final c in _channels) {
          _sendSubscribe(c);
        }
        return;
      case 'pusher:ping':
        _send({'event': 'pusher:pong', 'data': {}});
        return;
      case 'pusher:error':
        return;
      case 'pusher_internal:subscription_succeeded':
        if (channel.startsWith('presence-')) {
          // data = { presence: { ids: [...], hash: {...}, count } }
          final presence = data['presence'];
          if (presence is Map && presence['ids'] is List) {
            final ids = (presence['ids'] as List).map((e) => e.toString()).toSet();
            onPresenceSync?.call(channel, ids);
          }
        }
        return;
      case 'pusher_internal:member_added':
        if (channel.startsWith('presence-')) {
          final id = (data['user_id'] ?? data['id'] ?? '').toString();
          if (id.isNotEmpty) onPresenceChange?.call(channel, id, true);
        }
        return;
      case 'pusher_internal:member_removed':
        if (channel.startsWith('presence-')) {
          final id = (data['user_id'] ?? data['id'] ?? '').toString();
          if (id.isNotEmpty) onPresenceChange?.call(channel, id, false);
        }
        return;
    }

    if (event.startsWith('pusher:') || event.startsWith('pusher_internal:')) {
      return;
    }
    onEvent?.call(channel, event, data);
  }

  void _startPing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _send({'event': 'pusher:ping', 'data': {}});
    });
  }

  void _scheduleReconnect() {
    _connected = false;
    _socketId = null;
    onConnectionChange?.call(false);
    _pingTimer?.cancel();
    _sub?.cancel();
    _sub = null;
    _channel = null;
    if (_disposed) return;
    _reconnectTimer?.cancel();
    final delay = Duration(seconds: (1 << (_retry.clamp(0, 5))).clamp(1, 30));
    _retry++;
    _reconnectTimer = Timer(delay, connect);
  }

  Future<void> _sendSubscribe(String channelName) async {
    final payload = <String, dynamic>{'channel': channelName};
    if (channelName.startsWith('private-') || channelName.startsWith('presence-')) {
      final auth = await _authorize(channelName);
      if (auth == null) return;
      payload['auth'] = auth['auth'];
      if (auth['channel_data'] != null) payload['channel_data'] = auth['channel_data'];
    }
    _send({'event': 'pusher:subscribe', 'data': payload});
  }

  Future<Map<String, dynamic>?> _authorize(String channelName) async {
    final sid = _socketId;
    if (sid == null) return null;
    try {
      final token = await ApiClient().getAccessToken();
      final resp = await _authDio.post(
        ApiConfig.broadcastAuthUrl,
        data: {'socket_id': sid, 'channel_name': channelName},
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
        ),
      );
      if (resp.data is Map) return Map<String, dynamic>.from(resp.data as Map);
    } catch (_) {}
    return null;
  }

  void _send(Map<String, dynamic> msg) {
    try {
      _channel?.sink.add(jsonEncode(msg));
    } catch (_) {}
  }

  Future<void> subscribe(String channelName) async {
    if (_channels.add(channelName) && _connected) {
      await _sendSubscribe(channelName);
    }
  }

  Future<void> unsubscribe(String channelName) async {
    if (_channels.remove(channelName) && _connected) {
      _send({'event': 'pusher:unsubscribe', 'data': {'channel': channelName}});
    }
  }

  /// Client event (whisper) — used for typing. Only valid on private/presence
  /// channels the user is subscribed to. Event name must start with `client-`.
  void whisper(String channelName, String event, Map<String, dynamic> data) {
    if (!_connected) return;
    final name = event.startsWith('client-') ? event : 'client-$event';
    _send({'event': name, 'channel': channelName, 'data': data});
  }

  Future<void> disconnect() async {
    _disposed = true;
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    await _sub?.cancel();
    _sub = null;
    try {
      await _channel?.sink.close(ws_status.normalClosure);
    } catch (_) {}
    _channel = null;
    _connected = false;
    _socketId = null;
    _channels.clear();
  }
}
