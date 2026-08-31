import 'user.dart';

class SpotlightPost {
  final String id;
  final User creator;
  final String mediaUrl;
  final String? thumbnailUrl;
  final bool isVideo;
  final String? caption;
  final List<String> hashtags;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final int viewCount;
  final bool isLiked;
  final bool isSaved;
  final DateTime createdAt;

  const SpotlightPost({
    required this.id,
    required this.creator,
    required this.mediaUrl,
    this.thumbnailUrl,
    this.isVideo = true,
    this.caption,
    this.hashtags = const [],
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.viewCount = 0,
    this.isLiked = false,
    this.isSaved = false,
    required this.createdAt,
  });

  SpotlightPost copyWith({
    bool? isLiked,
    int? likeCount,
    bool? isSaved,
  }) =>
      SpotlightPost(
        id: id,
        creator: creator,
        mediaUrl: mediaUrl,
        thumbnailUrl: thumbnailUrl,
        isVideo: isVideo,
        caption: caption,
        hashtags: hashtags,
        likeCount: likeCount ?? this.likeCount,
        commentCount: commentCount,
        shareCount: shareCount,
        viewCount: viewCount,
        isLiked: isLiked ?? this.isLiked,
        isSaved: isSaved ?? this.isSaved,
        createdAt: createdAt,
      );
}
