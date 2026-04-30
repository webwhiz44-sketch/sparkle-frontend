import 'user_model.dart';

class StoryModel {
  final int id;
  final String title;
  final String body;
  final String? coverImageUrl;
  final UserModel author;
  final List<String> tags;
  final int likeCount;
  final int commentCount;
  final int readTimeMinutes;
  final bool likedByMe;
  final String createdAt;

  StoryModel({
    required this.id,
    required this.title,
    required this.body,
    this.coverImageUrl,
    required this.author,
    required this.tags,
    required this.likeCount,
    required this.commentCount,
    required this.readTimeMinutes,
    required this.likedByMe,
    required this.createdAt,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'],
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      coverImageUrl: json['coverImageUrl'] as String?,
      author: UserModel.fromJson(json['author']),
      tags: List<String>.from(json['tags'] ?? []),
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      readTimeMinutes: json['readTimeMinutes'] ?? 1,
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

  StoryModel copyWith({int? likeCount, bool? likedByMe}) {
    return StoryModel(
      id: id,
      title: title,
      body: body,
      coverImageUrl: coverImageUrl,
      author: author,
      tags: tags,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount,
      readTimeMinutes: readTimeMinutes,
      likedByMe: likedByMe ?? this.likedByMe,
      createdAt: createdAt,
    );
  }
}
