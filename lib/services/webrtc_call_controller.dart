import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';

/// WebRTC engine for SwiftSnap calls. Transport-agnostic: it calls [sendSignal]
/// to relay SDP/ICE to the peer (via Laravel /calls/{uuid}/signal → Reverb) and
/// receives peer signals through [onSignal]. Self-hosted coturn ICE servers.
class WebRTCCallController {
  WebRTCCallController({required this.video, required this.sendSignal});

  final bool video;
  final Future<void> Function(String kind, Map<String, dynamic> data) sendSignal;

  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  RTCPeerConnection? _pc;
  MediaStream? _local;
  bool _closed = false;
  bool _remoteSet = false;
  final List<RTCIceCandidate> _pendingCandidates = [];

  final ValueNotifier<bool> remoteReady = ValueNotifier(false);
  final ValueNotifier<bool> muted = ValueNotifier(false);
  final ValueNotifier<bool> speakerOn = ValueNotifier(true);
  final ValueNotifier<bool> cameraOn = ValueNotifier(true);

  static Future<bool> ensurePermissions(bool video) async {
    final perms = <Permission>[Permission.microphone];
    if (video) perms.add(Permission.camera);
    final res = await perms.request();
    return res.values.every((s) => s.isGranted);
  }

  Future<void> init({
    required bool caller,
    required List<dynamic> iceServers,
  }) async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();

    _pc = await createPeerConnection({
      'iceServers': iceServers,
      'sdpSemantics': 'unified-plan',
      'iceTransportPolicy': 'all',
    });

    _pc!.onIceCandidate = (c) {
      if (c.candidate != null && !_closed) {
        unawaited(sendSignal('ice', {
          'candidate': c.candidate,
          'sdpMid': c.sdpMid,
          'sdpMLineIndex': c.sdpMLineIndex,
        }));
      }
    };
    _pc!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        remoteRenderer.srcObject = event.streams.first;
        remoteReady.value = true;
      }
    };
    _pc!.onConnectionState = (state) {
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        // let the screen decide to end; do not auto-dispose mid-negotiation
      }
    };

    _local = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': video ? {'facingMode': 'user'} : false,
    });
    localRenderer.srcObject = _local;
    for (final track in _local!.getTracks()) {
      await _pc!.addTrack(track, _local!);
    }

    // Route audio to the loudspeaker for video calls by default.
    try { await Helper.setSpeakerphoneOn(video); } catch (_) {}
    speakerOn.value = video;
  }

  /// Caller creates & sends the SDP offer. Deferred until the callee has
  /// accepted and both peers are subscribed, so the offer is never lost.
  Future<void> makeOffer() async {
    final pc = _pc;
    if (pc == null || _closed) return;
    final offer = await pc.createOffer({
      'offerToReceiveAudio': true,
      'offerToReceiveVideo': video,
    });
    await pc.setLocalDescription(offer);
    await sendSignal('offer', {'type': offer.type, 'sdp': offer.sdp});
  }

  Future<void> onSignal(String kind, Map<String, dynamic> data) async {
    final pc = _pc;
    if (pc == null || _closed) return;
    switch (kind) {
      case 'offer':
        await pc.setRemoteDescription(
            RTCSessionDescription(data['sdp'] as String?, data['type'] as String?));
        _remoteSet = true;
        await _flushCandidates();
        final answer = await pc.createAnswer({
          'offerToReceiveAudio': true,
          'offerToReceiveVideo': video,
        });
        await pc.setLocalDescription(answer);
        await sendSignal('answer', {'type': answer.type, 'sdp': answer.sdp});
        break;
      case 'answer':
        await pc.setRemoteDescription(
            RTCSessionDescription(data['sdp'] as String?, data['type'] as String?));
        _remoteSet = true;
        await _flushCandidates();
        break;
      case 'ice':
        final cand = RTCIceCandidate(
          data['candidate'] as String?,
          data['sdpMid'] as String?,
          (data['sdpMLineIndex'] as num?)?.toInt(),
        );
        if (_remoteSet) {
          await pc.addCandidate(cand);
        } else {
          _pendingCandidates.add(cand);
        }
        break;
    }
  }

  Future<void> _flushCandidates() async {
    for (final c in _pendingCandidates) {
      try { await _pc?.addCandidate(c); } catch (_) {}
    }
    _pendingCandidates.clear();
  }

  void toggleMute() {
    muted.value = !muted.value;
    for (final t in _local?.getAudioTracks() ?? const <MediaStreamTrack>[]) {
      t.enabled = !muted.value;
    }
  }

  Future<void> toggleSpeaker() async {
    speakerOn.value = !speakerOn.value;
    try { await Helper.setSpeakerphoneOn(speakerOn.value); } catch (_) {}
  }

  void toggleCamera() {
    cameraOn.value = !cameraOn.value;
    for (final t in _local?.getVideoTracks() ?? const <MediaStreamTrack>[]) {
      t.enabled = cameraOn.value;
    }
  }

  Future<void> switchCamera() async {
    final tracks = _local?.getVideoTracks() ?? const <MediaStreamTrack>[];
    if (tracks.isNotEmpty) {
      try { await Helper.switchCamera(tracks.first); } catch (_) {}
    }
  }

  Future<void> dispose() async {
    if (_closed) return;
    _closed = true;
    for (final t in _local?.getTracks() ?? const <MediaStreamTrack>[]) {
      try { await t.stop(); } catch (_) {}
    }
    try { await _local?.dispose(); } catch (_) {}
    try { await _pc?.close(); } catch (_) {}
    try { await _pc?.dispose(); } catch (_) {}
    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;
    try { await localRenderer.dispose(); } catch (_) {}
    try { await remoteRenderer.dispose(); } catch (_) {}
  }
}
