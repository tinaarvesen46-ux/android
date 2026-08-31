class DiscoverCategory {
  final String id;
  final String name;
  final String icon;

  const DiscoverCategory({
    required this.id,
    required this.name,
    required this.icon,
  });
}

class DiscoverItem {
  final String id;
  final String title;
  final String? subtitle;
  final String imageUrl;
  final String category;
  final String source;
  final int viewCount;
  final DateTime publishedAt;
  final bool isSponsored;

  const DiscoverItem({
    required this.id,
    required this.title,
    this.subtitle,
    required this.imageUrl,
    required this.category,
    required this.source,
    this.viewCount = 0,
    required this.publishedAt,
    this.isSponsored = false,
  });
}
