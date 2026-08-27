import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../api_config.dart';
import '../api_client.dart';

/// Called for every real (non-internal) event received on a subscribed channel.
typedef RealtimeEventHandler = void Function(
    String channelName, String eventName, Map<String, dynamic> data);

/// Thin wrapper around the Pusher protocol client, pointed at the self-hosted
/// Laravel Reverb server (wss://ws.vexor.to). Handles token-based private
/// channel auth via /api/v1/broadcasting/auth.
class RealtimeService {
  RealtimeService._();
  static final RealtimeService instance = RealtimeService._();

  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
  final Dio _authDio = Dio();

  bool _initialized = false;
  bool _connected = false;
  final Set<String> _channels = {};

  RealtimeEventHandler? onEvent;

  /// Initialise + open the socket. Safe to call multiple times.
  Future<void> connect() async {
    if (_connected) return;
    final token = await ApiClient().getAccessToken();
    if (token == null) return;

    if (!_initialized) {
      await _pusher.init(
        apiKey: ApiConfig.reverbKey,
        cluster: 'mt1', // required by the SDK; ignored for self-hosted Reverb
        useTLS: true,
        host: ApiConfig.reverbHost,
        wsPort: ApiConfig.reverbPort,
        wssPort: ApiConfig.reverbPort,
        onEvent: _onEvent,
        onAuthorizer: _authorize,
        onError: (String message, int? code, dynamic e) {},
      );
      _initialized = true;
    }

    await _pusher.connect();
    _connected = true;

    // (Re)subscribe any channels requested before the socket was ready.
    for (final c in _channels) {
      await _pusher.subscribe(channelName: c);
    }
  }

  Future<dynamic> _authorize(
      String channelName, String socketId, dynamic options) async {
    final token = await ApiClient().getAccessToken();
    final resp = await _authDio.post(
      ApiConfig.broadcastAuthUrl,
      data: {'socket_id': socketId, 'channel_name': channelName},
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
    );
    // Laravel returns { "auth": "key:sig" } (+ "channel_data" for presence).
    if (resp.data is Map) return Map<String, dynamic>.from(resp.data as Map);
    return resp.data;
  }

  void _onEvent(PusherEvent event) {
    final name = event.eventName;
    if (name.startsWith('pusher:') || name.startsWith('pusher_internal:')) return;
    Map<String, dynamic> data = {};
    try {
      final raw = event.data;
      if (raw is String && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map) data = Map<String, dynamic>.from(decoded);
      } else if (raw is Map) {
        data = Map<String, dynamic>.from(raw);
      }
    } catch (_) {}
    onEvent?.call(event.channelName, name, data);
  }

  Future<void> subscribe(String channelName) async {
    if (_channels.add(channelName) && _connected) {
      await _pusher.subscribe(channelName: channelName);
    }
  }

  Future<void> unsubscribe(String channelName) async {
    if (_channels.remove(channelName) && _connected) {
      await _pusher.unsubscribe(channelName: channelName);
    }
  }

  Future<void> disconnect() async {
    try {
      await _pusher.disconnect();
    } catch (_) {}
    _connected = false;
    _channels.clear();
  }
}
