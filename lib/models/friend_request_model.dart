import 'user_model.dart';

enum FriendRequestStatus { pending, accepted, rejected }

class FriendRequestModel {
  final String id;
  final UserModel sender;
  final UserModel receiver;
  final FriendRequestStatus status;
  final DateTime createdAt;
  final String? message;
  
  const FriendRequestModel({
    required this.id,
    required this.sender,
    required this.receiver,
    this.status = FriendRequestStatus.pending,
    required this.createdAt,
    this.message,
  });
  
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return '${(diff.inDays / 30).floor()}mo ago';
  }
  
  FriendRequestModel copyWith({
    String? id,
    UserModel? sender,
    UserModel? receiver,
    FriendRequestStatus? status,
    DateTime? createdAt,
    String? message,
  }) {
    return FriendRequestModel(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      message: message ?? this.message,
    );
  }
}
