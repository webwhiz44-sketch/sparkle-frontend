class CommunityModel {
  final int id;
  final String name;
  final String? description;
  final String? category;
  final String? coverImageUrl;
  final int memberCount;
  final String createdAt;

  CommunityModel({
    required this.id,
    required this.name,
    this.description,
    this.category,
    this.coverImageUrl,
    required this.memberCount,
    required this.createdAt,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      coverImageUrl: json['coverImageUrl'],
      memberCount: json['memberCount'] ?? 0,
      createdAt: json['createdAt'] ?? '',
    );
  }
}
