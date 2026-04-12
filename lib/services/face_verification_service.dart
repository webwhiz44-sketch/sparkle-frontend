import 'package:flutter/services.dart';
import 'api_client.dart';

class FaceVerificationService {
  static const _channel = MethodChannel('com.sparkle.sparkle_app/liveness');

  /// Asks the backend to create a Rekognition Face Liveness session.
  /// Returns the sessionId to pass to the native liveness detector.
  static Future<String> createSession() async {
    final response = await ApiClient.post(
      '/api/face-verification/session',
      {},
      auth: false,
    );
    final data = ApiClient.parseResponse(response);
    return data['sessionId'] as String;
  }

  /// Launches the native AWS FaceLivenessDetector activity.
  /// Throws [PlatformException] with code 'LIVENESS_FAILED' on failure.
  static Future<void> startLiveness(String sessionId) async {
    await _channel.invokeMethod('startLiveness', {
      'sessionId': sessionId,
      'region': 'us-east-1',
    });
  }

  /// Asks the backend to evaluate the completed liveness session.
  /// Backend calls GetFaceLivenessSessionResults + DetectFaces for gender.
  /// Returns faceVerificationToken on success.
  static Future<String> verifySession(String sessionId) async {
    final response = await ApiClient.post(
      '/api/face-verification/verify',
      {'sessionId': sessionId},
      auth: false,
    );
    final data = ApiClient.parseResponse(response);
    return data['faceVerificationToken'] as String;
  }
}
