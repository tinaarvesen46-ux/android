import 'dart:async';
import 'package:flutter/material.dart';
import 'presence_service.dart';

/// PresenceHeartbeat — top-level widget wrapper that fires a heartbeat every
/// 45 s while the app is in the foreground and an explicit offline signal
/// when the app is backgrounded or resumed to a signed-out state.
///
/// Wrap your MaterialApp with this once, no other setup needed.
class PresenceHeartbeat extends StatefulWidget {
  final Widget child;
  final bool enabled;
  const PresenceHeartbeat({super.key, required this.child, this.enabled = true});

  @override
  State<PresenceHeartbeat> createState() => _PresenceHeartbeatState();
}

class _PresenceHeartbeatState extends State<PresenceHeartbeat> with WidgetsBindingObserver {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.enabled) _start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    // best-effort: tell the server we've gone offline
    PresenceService().offline();
    super.dispose();
  }

  void _start() {
    _timer?.cancel();
    // Send one immediately so the user appears online right after login.
    PresenceService().heartbeat();
    _timer = Timer.periodic(const Duration(seconds: 45), (_) => PresenceService().heartbeat());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.enabled) return;
    if (state == AppLifecycleState.resumed) {
      _start();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _timer?.cancel();
      PresenceService().offline();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
