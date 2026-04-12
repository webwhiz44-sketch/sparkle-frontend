import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'auth_storage.dart';
import '../screens/login_screen.dart';

class ApiClient {
  static const String baseUrl = 'https://sparkle-backend-927496695401.asia-south1.run.app';
  static GlobalKey<NavigatorState>? navigatorKey;

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await AuthStorage.getAccessToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // --- Token refresh ---

  static Future<bool> _tryRefresh() async {
    final refreshToken = await AuthStorage.getRefreshToken();
    if (refreshToken == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        await AuthStorage.saveTokens(
          data['accessToken'],
          data['refreshToken'],
        );
        return true;
      }
    } catch (_) {}
    return false;
  }

  static void _forceLogout() async {
    await AuthStorage.clear();
    navigatorKey?.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  // --- HTTP helpers with auto-refresh ---

  static Future<http.Response> _withRefresh(
      Future<http.Response> Function() request) async {
    var response = await request();
    if (response.statusCode == 401) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        response = await request();
      } else {
        _forceLogout();
        throw ApiException('Session expired. Please sign in again.');
      }
    }
    return response;
  }

  static Future<http.Response> get(String path) async {
    return _withRefresh(() async => http.get(
          Uri.parse('$baseUrl$path'),
          headers: await _headers(),
        ));
  }

  static Future<http.Response> post(String path, Map<String, dynamic> body,
      {bool auth = true}) async {
    return _withRefresh(() async => http.post(
          Uri.parse('$baseUrl$path'),
          headers: await _headers(auth: auth),
          body: jsonEncode(body),
        ));
  }

  static Future<http.Response> delete(String path) async {
    return _withRefresh(() async => http.delete(
          Uri.parse('$baseUrl$path'),
          headers: await _headers(),
        ));
  }

  static Future<http.Response> put(String path, Map<String, dynamic> body) async {
    return _withRefresh(() async => http.put(
          Uri.parse('$baseUrl$path'),
          headers: await _headers(),
          body: jsonEncode(body),
        ));
  }

  static Future<http.Response> uploadImage(String path, String filePath) async {
    return _withRefresh(() async {
      final token = await AuthStorage.getAccessToken();
      final request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl$path'));
      if (token != null) request.headers['Authorization'] = 'Bearer $token';
      final ext = filePath.toLowerCase().split('.').last;
      final mimeType = switch (ext) {
        'png' => 'image/png',
        'gif' => 'image/gif',
        'webp' => 'image/webp',
        _ => 'image/jpeg',
      };
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: MediaType('image', mimeType.split('/').last),
      ));
      final streamed = await request.send();
      return http.Response.fromStream(streamed);
    });
  }

  static dynamic parseResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body['data'];
    }
    throw ApiException(body['message'] ?? 'Something went wrong');
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
