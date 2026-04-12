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
    required String faceVerificationToken,
    List<String> interests = const [],
  }) async {
    final response = await ApiClient.post(
      '/api/auth/signup',
      {
        'email': email,
        'password': password,
        'displayName': displayName,
        'interests': interests,
        'faceVerificationToken': faceVerificationToken,
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

  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await ApiClient.put('/api/auth/change-password', {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
    ApiClient.parseResponse(response);
    // Backend revokes all refresh tokens — clear local tokens to force re-login
    await AuthStorage.clear();
  }
}
