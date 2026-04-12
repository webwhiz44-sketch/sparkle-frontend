import 'user_model.dart';
import 'poll_model.dart';

class PostModel {
  final int id;
  final String content;
  final String? imageUrl;
  final UserModel author;
  final int? communityId;
  final String? communityName;
  final int likeCount;
  final int commentCount;
  final bool likedByMe;
  final List<String> topicTags;
  final String createdAt;
  final PollModel? poll;

  PostModel({
    required this.id,
    required this.content,
    this.imageUrl,
    required this.author,
    this.communityId,
    this.communityName,
    required this.likeCount,
    required this.commentCount,
    required this.likedByMe,
    required this.topicTags,
    required this.createdAt,
    this.poll,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      content: json['content'],
      imageUrl: json['imageUrl'],
      author: UserModel.fromJson(json['author']),
      communityId: json['communityId'],
      communityName: json['communityName'],
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      likedByMe: json['likedByMe'] ?? false,
      topicTags: List<String>.from(json['topicTags'] ?? []),
      createdAt: _parseDateTime(json['createdAt']),
      poll: json['poll'] != null ? PollModel.fromJson(json['poll']) : null,
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

  PostModel copyWith({int? likeCount, bool? likedByMe, PollModel? poll}) {
    return PostModel(
      id: id,
      content: content,
      imageUrl: imageUrl,
      author: author,
      communityId: communityId,
      communityName: communityName,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount,
      likedByMe: likedByMe ?? this.likedByMe,
      topicTags: topicTags,
      createdAt: createdAt,
      poll: poll ?? this.poll,
    );
  }
}
