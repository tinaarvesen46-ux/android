import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../theme/theme.dart';
import '../providers/app_provider.dart';
import '../services/webrtc_call_controller.dart';
import '../api/services/v32_service.dart';

/// Full-screen call UI backed by [WebRTCCallController] and self-hosted
/// signaling. Handles outgoing (isCaller) and incoming flows, ringing state,
/// mute/speaker/camera controls, and guaranteed teardown.
class CallScreen extends StatefulWidget {
  final String callUuid;
  final bool isCaller;
  final bool isVideo;
  final String peerName;
  final bool incoming;

  const CallScreen({
    super.key,
    required this.callUuid,
    required this.isCaller,
    required this.isVideo,
    required this.peerName,
    this.incoming = false,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final SwiftSnapV32Service _api = SwiftSnapV32Service();
  WebRTCCallController? _ctrl;
  AppProvider? _provider;

  String _status = 'Ringing…';
  bool _answered = false;
  bool _connected = false;
  bool _ending = false;
  DateTime? _connectedAt;
  Timer? _durationTimer;
  String _duration = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider = context.read<AppProvider>();
      _provider!.registerCallSignalHandler(_onSignal);
      _provider!.subscribeToCall(widget.callUuid);
      if (widget.incoming) {
        setState(() => _status = 'Incoming ${widget.isVideo ? 'video' : 'voice'} call');
      } else {
        _start();
      }
    });
  }

  Future<void> _start() async {
    setState(() {
      _answered = true;
      _status = widget.isCaller ? 'Ringing…' : 'Connecting…';
    });
    final ok = await WebRTCCallController.ensurePermissions(widget.isVideo);
    if (!ok) {
      _fail('Camera/microphone permission denied');
      return;
    }
    final ice = await _api.iceServers();
    final iceServers = (ice.data?['ice_servers'] as List?) ?? const [];
    final ctrl = WebRTCCallController(
      video: widget.isVideo,
      sendSignal: (kind, data) => _api.sendCallSignal(widget.callUuid, kind, data),
    );
    _ctrl = ctrl;
    try {
      await ctrl.init(caller: widget.isCaller, iceServers: iceServers);
      ctrl.remoteReady.addListener(_onRemoteReady);
    } catch (e) {
      _fail('Could not start call');
    }
    if (mounted) setState(() {});
  }

  void _onRemoteReady() {
    if (_ctrl?.remoteReady.value == true && !_connected) {
      setState(() {
        _connected = true;
        _status = 'Connected';
        _connectedAt = DateTime.now();
      });
      _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted || _connectedAt == null) return;
        final d = DateTime.now().difference(_connectedAt!);
        setState(() => _duration =
            '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}');
      });
    }
  }

  void _onSignal(String kind, Map<String, dynamic> data) {
    switch (kind) {
      case 'accepted':
        if (widget.isCaller) {
          setState(() => _status = 'Connecting…');
          _ctrl?.makeOffer();
        }
        break;
      case 'declined':
        _fail('Call declined');
        break;
      case 'ended':
      case 'cancelled':
      case 'busy':
        _fail('Call ended');
        break;
      case 'offer':
      case 'answer':
      case 'ice':
        _ctrl?.onSignal(kind, data);
        break;
    }
  }

  Future<void> _accept() async {
    HapticFeedback.mediumImpact();
    await _api.acceptCall(widget.callUuid);
    await _start();
  }

  Future<void> _decline() async {
    HapticFeedback.mediumImpact();
    await _api.declineCall(widget.callUuid);
    _cleanupAndPop();
  }

  Future<void> _hangUp() async {
    HapticFeedback.mediumImpact();
    await _api.endCall(widget.callUuid);
    _cleanupAndPop();
  }

  void _fail(String msg) {
    if (_ending) return;
    _status = msg;
    _cleanupAndPop();
  }

  Future<void> _cleanupAndPop() async {
    if (_ending) return;
    _ending = true;
    _durationTimer?.cancel();
    _ctrl?.remoteReady.removeListener(_onRemoteReady);
    await _ctrl?.dispose();
    _provider?.clearCallSignalHandler();
    _provider?.unsubscribeFromCall(widget.callUuid);
    _provider?.clearIncomingCall();
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    if (!_ending) {
      _ctrl?.remoteReady.removeListener(_onRemoteReady);
      _ctrl?.dispose();
      _provider?.clearCallSignalHandler();
      _provider?.unsubscribeFromCall(widget.callUuid);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = _ctrl;
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B12),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Remote video (video calls only, once connected)
          if (widget.isVideo && ctrl != null && _connected)
            RTCVideoView(ctrl.remoteRenderer, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),

          // Audio call / pre-connect: gradient + avatar
          if (!(widget.isVideo && _connected))
            Container(
              decoration: const BoxDecoration(gradient: SwiftSnapTheme.primaryGradient),
            ),

          // Local PIP (video)
          if (widget.isVideo && ctrl != null && _answered)
            Positioned(
              right: 16,
              top: MediaQuery.of(context).padding.top + 16,
              width: 108,
              height: 150,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: RTCVideoView(ctrl.localRenderer, mirror: true,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
              ),
            ),

          // Header: peer name + status
          Positioned(
            top: MediaQuery.of(context).padding.top + 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (!(widget.isVideo && _connected)) ...[
                  CircleAvatar(
                    radius: 54,
                    backgroundColor: Colors.white24,
                    child: Text(
                      widget.peerName.isNotEmpty ? widget.peerName[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 44, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                Text(widget.peerName,
                    style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(_connected ? _duration : _status,
                    style: const TextStyle(color: Colors.white70, fontSize: 15)),
              ],
            ),
          ),

          // Controls
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).padding.bottom + 40,
            child: widget.incoming && !_answered
                ? _incomingControls()
                : _inCallControls(ctrl),
          ),
        ],
      ),
    );
  }

  Widget _incomingControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _circleButton(Icons.call_end_rounded, Colors.red, _decline, 'decline-call-btn'),
        _circleButton(Icons.call_rounded, Colors.green, _accept, 'accept-call-btn'),
      ],
    );
  }

  Widget _inCallControls(WebRTCCallController? ctrl) {
    if (ctrl == null) {
      return Center(
        child: _circleButton(Icons.call_end_rounded, Colors.red, _hangUp, 'hangup-call-btn'),
      );
    }
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: ctrl.muted,
              builder: (_, m, __) => _circleButton(
                  m ? Icons.mic_off_rounded : Icons.mic_rounded,
                  Colors.white24, ctrl.toggleMute, 'mute-call-btn'),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: ctrl.speakerOn,
              builder: (_, s, __) => _circleButton(
                  s ? Icons.volume_up_rounded : Icons.volume_down_rounded,
                  Colors.white24, ctrl.toggleSpeaker, 'speaker-call-btn'),
            ),
            if (widget.isVideo)
              _circleButton(Icons.cameraswitch_rounded, Colors.white24, ctrl.switchCamera, 'switch-cam-btn'),
            if (widget.isVideo)
              ValueListenableBuilder<bool>(
                valueListenable: ctrl.cameraOn,
                builder: (_, c, __) => _circleButton(
                    c ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                    Colors.white24, ctrl.toggleCamera, 'toggle-cam-btn'),
              ),
          ],
        ),
        const SizedBox(height: 24),
        _circleButton(Icons.call_end_rounded, Colors.red, _hangUp, 'hangup-call-btn'),
      ],
    );
  }

  Widget _circleButton(IconData icon, Color bg, VoidCallback onTap, String testId) {
    return GestureDetector(
      key: Key(testId),
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}
