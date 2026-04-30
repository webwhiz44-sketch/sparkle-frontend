import '../models/story_model.dart';
import 'api_client.dart';

class StoryService {
  static Future<List<StoryModel>> getFeed({int page = 0, int size = 20}) async {
    final response = await ApiClient.get('/api/stories?page=$page&size=$size');
    final data = ApiClient.parseResponse(response);
    final List content = data['content'] ?? [];
    return content.map((e) => StoryModel.fromJson(e)).toList();
  }

  static Future<StoryModel> getStory(int id) async {
    final response = await ApiClient.get('/api/stories/$id');
    return StoryModel.fromJson(ApiClient.parseResponse(response));
  }

  static Future<StoryModel> createStory({
    required String title,
    required String body,
    String? coverImageUrl,
    List<String> tags = const [],
  }) async {
    final bodyMap = <String, dynamic>{
      'title': title,
      'body': body,
      'tags': tags,
    };
    if (coverImageUrl != null) bodyMap['coverImageUrl'] = coverImageUrl;
    final response = await ApiClient.post('/api/stories', bodyMap);
    return StoryModel.fromJson(ApiClient.parseResponse(response));
  }

  static Future<void> likeStory(int storyId) async {
    await ApiClient.post('/api/stories/$storyId/like', {});
  }

  static Future<void> unlikeStory(int storyId) async {
    await ApiClient.delete('/api/stories/$storyId/like');
  }
}
