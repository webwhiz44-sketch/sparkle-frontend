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
      createdAt: json['createdAt'],
    );
  }
}
