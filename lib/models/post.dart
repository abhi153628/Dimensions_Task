// models/post.dart
class Post {
  final int userId;
  final int id;
  final String title;
  final String body;
  bool isSaved;

  Post({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
    this.isSaved = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }
}