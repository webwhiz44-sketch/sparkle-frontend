import '../models/user_model.dart';
import 'api_client.dart';

class UserService {
  static Future<UserModel> getMe() async {
    final response = await ApiClient.get('/api/users/me');
    return UserModel.fromJson(ApiClient.parseResponse(response));
  }

  static Future<UserModel> updateProfile({
    String? displayName,
    String? bio,
    List<String>? interests,
    String? profileImageUrl,
  }) async {
    final body = <String, dynamic>{};
    if (displayName != null) body['displayName'] = displayName;
    if (bio != null) body['bio'] = bio;
    if (interests != null) body['interests'] = interests;
    if (profileImageUrl != null) body['profileImageUrl'] = profileImageUrl;
    final response = await ApiClient.put('/api/users/me', body);
    return UserModel.fromJson(ApiClient.parseResponse(response));
  }
}
