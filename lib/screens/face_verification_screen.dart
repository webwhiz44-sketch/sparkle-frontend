import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/face_verification_service.dart';
import '../services/auth_service.dart';
import '../services/auth_storage.dart';
import '../services/api_client.dart';
import 'login_screen.dart';

class FaceVerificationScreen extends StatefulWidget {
  final String displayName;
  final String email;
  final String password;

  const FaceVerificationScreen({
    super.key,
    required this.displayName,
    required this.email,
    required this.password,
  });

  @override
  State<FaceVerificationScreen> createState() => _FaceVerificationScreenState();
}

class _FaceVerificationScreenState extends State<FaceVerificationScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  String? _sessionId;

  Future<void> _startVerification() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Step 1: Ensure camera permission is granted before launching native activity
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = 'Camera access is required for face verification. Please allow it in Settings.';
        });
        return;
      }

      // Step 2: Backend creates Rekognition Face Liveness session
      final sessionId = await FaceVerificationService.createSession();
      _sessionId = sessionId;

      // Step 3: Native Android SDK runs the liveness check (streaming)
      await FaceVerificationService.startLiveness(sessionId);

      // Step 3: Backend gets session results + detects gender
      final token = await FaceVerificationService.verifySession(sessionId);

      // Step 5: Create account with verified token
      await AuthService.signup(
        displayName: widget.displayName,
        email: widget.email,
        password: widget.password,
        faceVerificationToken: token,
      );

      if (!mounted) return;
      await AuthStorage.clear();
      await _showSuccessDialog();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _sessionId = null;
        _errorMessage = _friendlyLivenessError(e);
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _sessionId = null;
        _errorMessage = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _sessionId = null;
        _errorMessage = 'Verification failed. Please try again.';
      });
    }
  }

  String _friendlyLivenessError(PlatformException e) {
    final msg = (e.message ?? '').toLowerCase();
    if (msg.contains('cancel')) return 'Verification cancelled. Tap below to try again.';
    if (msg.contains('timeout') || msg.contains('oval')) {
      return 'Time ran out. Look directly at the camera and try again.';
    }
    if (msg.contains('face')) return 'Face not detected. Make sure your face is well lit and fully visible.';
    if (msg.contains('session')) return 'Session expired. Please try again.';
    if (msg.contains('gender') || msg.contains('female')) {
      return 'Gender verification failed. Sparkle & Spill is a women-only sanctuary.';
    }
    return 'Liveness check failed. Please try again in good lighting.';
  }

  Future<void> _showSuccessDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFBE1373), Color(0xFFEC407A)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 38),
              ),
              const SizedBox(height: 20),
              Text(
                'Welcome to the Sanctuary!',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your identity has been verified ✨\nSign in to start sparkling.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dancingScript(
                  fontSize: 17,
                  color: const Color(0xFF888888),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFBE1373), Color(0xFFEC407A)],
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Center(
                    child: Text(
                      'GO TO SIGN IN →',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _isLoading
            ? const SizedBox.shrink()
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF1A1A1A), size: 18),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(
          'Identity Verification',
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: _isLoading ? _buildLoading() : _buildContent(),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFFBE1373)),
          const SizedBox(height: 20),
          Text(
            _sessionId == null
                ? 'Starting verification...'
                : 'Analysing results...',
            style: const TextStyle(fontSize: 15, color: Color(0xFF888888)),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            width: 110,
            height: 110,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFBE1373), Color(0xFFEC407A)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.face_retouching_natural_rounded,
                color: Colors.white, size: 58),
          ),
          const SizedBox(height: 24),
          Text(
            'Women-Only Sanctuary',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Sparkle & Spill is a safe space for women. We use a quick face scan to verify your identity.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),
          _buildTip(Icons.wb_sunny_outlined, 'Good lighting — face a window or bright light'),
          const SizedBox(height: 12),
          _buildTip(Icons.remove_red_eye_outlined, 'Face fully visible — no sunglasses or mask'),
          const SizedBox(height: 12),
          _buildTip(Icons.phone_android_rounded, 'Hold your phone steady at eye level'),
          if (_errorMessage != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: Color(0xFFE53935), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFFE53935), height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Spacer(),
          GestureDetector(
            onTap: _startVerification,
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFBE1373), Color(0xFFEC407A)],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFBE1373).withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _errorMessage != null ? 'TRY AGAIN ✦' : 'START FACE SCAN ✦',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your face data is processed by AWS Rekognition and is not stored by Sparkle & Spill.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTip(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFFCE4EC),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFFBE1373), size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF444444),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
