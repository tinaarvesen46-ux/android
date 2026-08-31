import 'user.dart';

class Story {
  final String id;
  final User author;
  final List<StoryItem> items;
  final bool isSeen;
  final DateTime createdAt;

  const Story({
    required this.id,
    required this.author,
    required this.items,
    this.isSeen = false,
    required this.createdAt,
  });
}

class StoryItem {
  final String id;
  final String mediaUrl;
  final bool isVideo;
  final Duration duration;
  final DateTime createdAt;
  final int viewCount;
  final int replyCount;

  const StoryItem({
    required this.id,
    required this.mediaUrl,
    this.isVideo = false,
    this.duration = const Duration(seconds: 5),
    required this.createdAt,
    this.viewCount = 0,
    this.replyCount = 0,
  });
}
