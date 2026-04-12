import '../models/post_model.dart';
import 'api_client.dart';

class PostService {
  static Future<List<PostModel>> getFeed({int page = 0, int size = 20}) async {
    final response = await ApiClient.get('/api/posts?page=$page&size=$size');
    final data = ApiClient.parseResponse(response);
    final List content = data['content'] ?? [];
    return content.map((e) => PostModel.fromJson(e)).toList();
  }

  static Future<PostModel> createPost({
    required String content,
    String? imageUrl,
    List<String> topicTags = const [],
    int? communityId,
    Map<String, dynamic>? poll, // {question: String, options: List<String>}
  }) async {
    final body = <String, dynamic>{'content': content, 'topicTags': topicTags};
    if (imageUrl != null) body['imageUrl'] = imageUrl;
    if (communityId != null) body['communityId'] = communityId;
    if (poll != null) body['poll'] = poll;
    final response = await ApiClient.post('/api/posts', body);
    return PostModel.fromJson(ApiClient.parseResponse(response));
  }

  static Future<void> likePost(int postId) async {
    await ApiClient.post('/api/posts/$postId/like', {});
  }

  static Future<void> unlikePost(int postId) async {
    await ApiClient.delete('/api/posts/$postId/like');
  }

  static Future<void> savePost(int postId) async {
    await ApiClient.post('/api/posts/$postId/save', {});
  }

  static Future<void> unsavePost(int postId) async {
    await ApiClient.delete('/api/posts/$postId/save');
  }

  static Future<List<PostModel>> getSavedPosts({int page = 0, int size = 20}) async {
    final response = await ApiClient.get('/api/posts/saved?page=$page&size=$size');
    final data = ApiClient.parseResponse(response);
    final List content = data['content'] ?? [];
    return content.map((e) => PostModel.fromJson(e)).toList();
  }

  static Future<String> uploadImage(String filePath) async {
    final response = await ApiClient.uploadImage('/api/uploads/image', filePath);
    final data = ApiClient.parseResponse(response);
    return data['url'] as String;
  }
}
