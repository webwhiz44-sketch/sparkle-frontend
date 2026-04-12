class UserModel {
  final int id;
  final String email;
  final String displayName;
  final String? bio;
  final String? profileImageUrl;
  final List<String> interests;
  final String? createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.bio,
    this.profileImageUrl,
    required this.interests,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      bio: json['bio'],
      profileImageUrl: json['profileImageUrl'],
      interests: List<String>.from(json['interests'] ?? []),
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  static String? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    // LocalDateTime serialized as object or array by Jackson
    if (value is Map) {
      try {
        final y = value['year'];
        final mo = value['monthValue'];
        final d = value['dayOfMonth'];
        final h = value['hour'] ?? 0;
        final mi = value['minute'] ?? 0;
        final s = value['second'] ?? 0;
        return '${y.toString().padLeft(4, '0')}-${mo.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}T${h.toString().padLeft(2, '0')}:${mi.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
      } catch (_) { return null; }
    }
    if (value is List) {
      try {
        final y = value[0], mo = value[1], d = value[2];
        final h = value.length > 3 ? value[3] : 0;
        final mi = value.length > 4 ? value[4] : 0;
        final s = value.length > 5 ? value[5] : 0;
        return '${y.toString().padLeft(4, '0')}-${mo.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}T${h.toString().padLeft(2, '0')}:${mi.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
      } catch (_) { return null; }
    }
    return value.toString();
  }
}
