import '../models/community_model.dart';
import 'api_client.dart';

class CommunityService {
  static Future<List<CommunityModel>> getCommunities({int page = 0, int size = 20}) async {
    final response = await ApiClient.get('/api/communities?page=$page&size=$size');
    final data = ApiClient.parseResponse(response);
    final List content = data['content'] ?? [];
    return content.map((e) => CommunityModel.fromJson(e)).toList();
  }

  static Future<void> joinCommunity(int id) async {
    await ApiClient.post('/api/communities/$id/join', {});
  }

  static Future<void> leaveCommunity(int id) async {
    await ApiClient.delete('/api/communities/$id/leave');
  }

  static Future<List<CommunityModel>> getMyCommunities({int page = 0, int size = 20}) async {
    final response = await ApiClient.get('/api/communities/my?page=$page&size=$size');
    final data = ApiClient.parseResponse(response);
    final List content = data['content'] ?? [];
    return content.map((e) => CommunityModel.fromJson(e)).toList();
  }
}
