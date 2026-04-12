import '../models/anonymous_post_model.dart';
import 'api_client.dart';

class AnonymousPostService {
  static Future<List<AnonymousPostModel>> getFeed({int page = 0, int size = 20}) async {
    final response = await ApiClient.get('/api/anonymous-posts?page=$page&size=$size');
    final data = ApiClient.parseResponse(response);
    final List content = data['content'] ?? [];
    return content.map((e) => AnonymousPostModel.fromJson(e)).toList();
  }

  static Future<AnonymousPostModel> createPost({
    required String content,
    List<String> topicTags = const [],
    String? imageUrl,
  }) async {
    final body = <String, dynamic>{
      'content': content,
      'topicTags': topicTags,
    };
    if (imageUrl != null) body['imageUrl'] = imageUrl;
    final response = await ApiClient.post('/api/anonymous-posts', body);
    return AnonymousPostModel.fromJson(ApiClient.parseResponse(response));
  }

  static Future<void> likePost(int postId) async {
    await ApiClient.post('/api/anonymous-posts/$postId/like', {});
  }

  static Future<void> unlikePost(int postId) async {
    await ApiClient.delete('/api/anonymous-posts/$postId/like');
  }
}
