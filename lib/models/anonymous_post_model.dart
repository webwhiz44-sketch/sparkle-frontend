class AnonymousPostModel {
  final int id;
  final String content;
  final List<String> topicTags;
  final int likeCount;
  final int commentCount;
  final bool likedByMe;
  final String createdAt;

  AnonymousPostModel({
    required this.id,
    required this.content,
    required this.topicTags,
    required this.likeCount,
    required this.commentCount,
    required this.likedByMe,
    required this.createdAt,
  });

  factory AnonymousPostModel.fromJson(Map<String, dynamic> json) {
    return AnonymousPostModel(
      id: json['id'],
      content: json['content'],
      topicTags: List<String>.from(json['topicTags'] ?? []),
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      likedByMe: json['likedByMe'] ?? false,
      createdAt: json['createdAt'] ?? '',
    );
  }

  AnonymousPostModel copyWith({int? likeCount, bool? likedByMe}) {
    return AnonymousPostModel(
      id: id,
      content: content,
      topicTags: topicTags,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount,
      likedByMe: likedByMe ?? this.likedByMe,
      createdAt: createdAt,
    );
  }
}
