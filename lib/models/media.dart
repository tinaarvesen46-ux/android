/// A file that has just been captured or picked but not yet uploaded.
class CaptureDraft {
  final String path;
  final bool isVideo;
  final bool isFrontCamera;

  const CaptureDraft({
    required this.path,
    this.isVideo = false,
    this.isFrontCamera = false,
  });
}

enum CaptureDestination { story, sendTo, reels, memories }

enum MemoryKind { snap, story, cameraRoll }

class MemoryItem {
  final String id;
  final String mediaUrl;
  final String? thumbnailUrl;
  final bool isVideo;
  final MemoryKind kind;
  final bool isFavorite;
  final DateTime createdAt;

  const MemoryItem({
    required this.id,
    required this.mediaUrl,
    this.thumbnailUrl,
    this.isVideo = false,
    this.kind = MemoryKind.snap,
    this.isFavorite = false,
    required this.createdAt,
  });
}
