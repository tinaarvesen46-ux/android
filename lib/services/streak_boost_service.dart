import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../api/api_config.dart';

/// StreakBoostService
/// ─────────────────────────────────────────────────────────────────
/// Fetches friends whose streak is expiring within `hours` and, if enabled,
/// schedules a **local** notification per friend so the user gets a
/// tap-to-snap reminder shortly before the streak dies.
///
/// The service intentionally uses *local* notifications (no push server) so
/// the alert fires even when the mobile app is asleep — no external push
/// infra needed for MVP.  The push channel `swiftsnap.streak_boost` bundles
/// all reminders so a burst doesn't spam the user's status bar.
class StreakBoostService {
  StreakBoostService._();
  static final instance = StreakBoostService._();

  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConfig.apiBaseUrl, connectTimeout: const Duration(seconds: 10)));
  final FlutterLocalNotificationsPlugin _notif = FlutterLocalNotificationsPlugin();
  bool _notifInited = false;

  Future<Map<String, String>> _auth() async {
    final token = await const FlutterSecureStorage().read(key: 'token');
    return token == null ? {} : {'Authorization': 'Bearer $token', 'Accept': 'application/json'};
  }

  Future<List<Map<String, dynamic>>> expiring({int hours = 6}) async {
    try {
      final r = await _dio.get('/streaks/expiring',
          queryParameters: {'hours': hours},
          options: Options(headers: await _auth()));
      return List<Map<String, dynamic>>.from(r.data as List);
    } catch (_) {
      return const [];
    }
  }

  Future<void> _ensureInit() async {
    if (_notifInited) return;
    tzdata.initializeTimeZones();
    await _notif.initialize(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS:     DarwinInitializationSettings(),
    ));
    _notifInited = true;
  }

  /// Schedule one local reminder per expiring streak.  Cancels any previously
  /// scheduled boost reminders first so we don't accumulate stale IDs when the
  /// friend list shrinks.  Fires 30 min before expiry (min 10 min from now).
  Future<int> scheduleReminders({int hours = 6}) async {
    await _ensureInit();
    // Clear old boost notifications (channel-scoped ids: 90000..99999).
    for (int i = 90000; i < 90050; i++) {
      await _notif.cancel(i);
    }
    final list = await expiring(hours: hours);
    int scheduled = 0;
    for (int i = 0; i < list.length && scheduled < 50; i++) {
      final f = list[i];
      final iso = f['streak_expires_at'] as String?;
      if (iso == null) continue;
      final expiresAt = DateTime.tryParse(iso);
      if (expiresAt == null) continue;
      // Fire 30 minutes before expiry, but no sooner than 10 min from now.
      final fireAt = expiresAt.subtract(const Duration(minutes: 30));
      final now = DateTime.now().add(const Duration(minutes: 10));
      final when = fireAt.isBefore(now) ? now : fireAt;
      final username = (f['display_name'] ?? f['username'] ?? 'a friend').toString();
      final days = (f['streak_days'] ?? 0) as int;
      await _notif.zonedSchedule(
        90000 + i,
        '$username\'s streak is about to break 🔥',
        'You\'re $days days deep.  Send a snap in the next 30 min to save it.',
        _tz(when),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'swiftsnap.streak_boost',
            'Streak boost reminders',
            channelDescription: 'Reminders 30 minutes before a streak expires.',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'streak_boost:${f['id']}',
      );
      scheduled++;
    }
    return scheduled;
  }

  /// Wrap DateTime in a `tz.TZDateTime` in the device's local timezone —
  /// required by `flutter_local_notifications.zonedSchedule()`.
  tz.TZDateTime _tz(DateTime dt) => tz.TZDateTime.from(dt, tz.local);
}

/// A small horizontal strip that visualises `StreakBoostService.expiring()`.
/// Tapping a card fires the `onSendSnap` callback with the friend id so the
/// parent screen can route to the camera / chat pre-filled with that friend.
class StreakBoostStrip extends StatefulWidget {
  const StreakBoostStrip({super.key, required this.onSendSnap});
  final void Function(int friendId, Map<String, dynamic> friend) onSendSnap;

  @override
  State<StreakBoostStrip> createState() => _StreakBoostStripState();
}

class _StreakBoostStripState extends State<StreakBoostStrip> {
  List<Map<String, dynamic>> _rows = const [];
  bool _loading = true;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _refresh();
    _tick = Timer.periodic(const Duration(minutes: 5), (_) => _refresh());
  }

  @override
  void dispose() { _tick?.cancel(); super.dispose(); }

  Future<void> _refresh() async {
    final rows = await StreakBoostService.instance.expiring();
    if (!mounted) return;
    setState(() { _rows = rows; _loading = false; });
    // Also schedule/refresh local reminders on every refresh so if the user
    // just added a friend the notifications are current.  Fire-and-forget.
    unawaited(StreakBoostService.instance.scheduleReminders());
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox.shrink();
    if (_rows.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: const [
            Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 16),
            SizedBox(width: 6),
            Text('Streaks about to break',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.6)),
          ]),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _rows.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final f = _rows[i];
              final id = (f['id'] as num).toInt();
              final avatar = f['avatar_url'] ?? f['profile']?['avatar_url'];
              final name = (f['display_name'] ?? f['username'] ?? '?').toString();
              final days = (f['streak_days'] ?? 0) as int;
              final hoursLeft = (f['streak_expires_in_hours'] as num? ?? 0).toDouble();
              return GestureDetector(
                key: Key('streak-boost-$id'),
                onTap: () => widget.onSendSnap(id, f),
                child: SizedBox(
                  width: 76,
                  child: Column(children: [
                    Stack(children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Colors.orangeAccent, Colors.deepOrange]),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: CircleAvatar(
                          radius: 26,
                          backgroundImage: avatar != null ? NetworkImage(avatar) : null,
                          child: avatar == null ? Text(name.substring(0,1).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900)) : null,
                        ),
                      ),
                      Positioned(
                        right: -4, top: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.75), borderRadius: BorderRadius.circular(999)),
                          child: Text('${days}d', style: const TextStyle(color: Colors.orangeAccent, fontSize: 9, fontWeight: FontWeight.w900)),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 4),
                    Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: theme.hintColor)),
                    Text('${hoursLeft.toStringAsFixed(1)}h left', style: const TextStyle(fontSize: 9, color: Colors.orangeAccent, fontWeight: FontWeight.w700)),
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}
