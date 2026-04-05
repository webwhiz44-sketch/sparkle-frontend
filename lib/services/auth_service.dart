import '../models/user_model.dart';
import 'api_client.dart';
import 'auth_storage.dart';

class AuthService {
  static Future<UserModel> login(String email, String password) async {
    final response = await ApiClient.post(
      '/api/auth/login',
      {'email': email, 'password': password},
      auth: false,
    );
    final data = ApiClient.parseResponse(response);
    await AuthStorage.saveTokens(data['accessToken'], data['refreshToken']);
    return UserModel.fromJson(data['user']);
  }

  static Future<UserModel> signup({
    required String email,
    required String password,
    required String displayName,
    List<String> interests = const [],
  }) async {
    final response = await ApiClient.post(
      '/api/auth/signup',
      {
        'email': email,
        'password': password,
        'displayName': displayName,
        'interests': interests,
      },
      auth: false,
    );
    final data = ApiClient.parseResponse(response);
    await AuthStorage.saveTokens(data['accessToken'], data['refreshToken']);
    return UserModel.fromJson(data['user']);
  }

  static Future<void> logout() async {
    try {
      await ApiClient.post('/api/auth/logout', {});
    } catch (_) {}
    await AuthStorage.clear();
  }
}
