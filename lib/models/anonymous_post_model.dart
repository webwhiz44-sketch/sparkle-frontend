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
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  static String _parseDateTime(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map) {
      try {
        final y = value['year'], mo = value['monthValue'], d = value['dayOfMonth'];
        final h = value['hour'] ?? 0, mi = value['minute'] ?? 0, s = value['second'] ?? 0;
        return '${y.toString().padLeft(4,'0')}-${mo.toString().padLeft(2,'0')}-${d.toString().padLeft(2,'0')}T${h.toString().padLeft(2,'0')}:${mi.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
      } catch (_) { return ''; }
    }
    if (value is List) {
      try {
        final y = value[0], mo = value[1], d = value[2];
        final h = value.length > 3 ? value[3] : 0, mi = value.length > 4 ? value[4] : 0, s = value.length > 5 ? value[5] : 0;
        return '${y.toString().padLeft(4,'0')}-${mo.toString().padLeft(2,'0')}-${d.toString().padLeft(2,'0')}T${h.toString().padLeft(2,'0')}:${mi.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
      } catch (_) { return ''; }
    }
    return value.toString();
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
