import 'user.dart';

/// A friend's last shared position, as reported by the backend.
class MapFriend {
  final User user;
  final double latitude;
  final double longitude;
  final DateTime updatedAt;

  const MapFriend({
    required this.user,
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
  });
}
