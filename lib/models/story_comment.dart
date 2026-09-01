import 'user.dart';

class StoryComment {
  final String id;
  final User author;
  final String content;
  final DateTime createdAt;

  const StoryComment({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
  });
}
