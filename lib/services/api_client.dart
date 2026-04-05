import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'auth_storage.dart';

class ApiClient {
  // 10.0.2.2 = localhost on Android emulator
  static const String baseUrl = 'http://10.0.2.2:8080';

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await AuthStorage.getAccessToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<http.Response> get(String path) async {
    return http.get(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
    );
  }

  static Future<http.Response> post(String path, Map<String, dynamic> body,
      {bool auth = true}) async {
    return http.post(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> delete(String path) async {
    return http.delete(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
    );
  }

  static Future<http.Response> put(String path, Map<String, dynamic> body) async {
    return http.put(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
  }

  // Multipart upload for images
  static Future<http.Response> uploadImage(String path, String filePath) async {
    final token = await AuthStorage.getAccessToken();
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$path'));
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
