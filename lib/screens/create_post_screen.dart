import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/post_service.dart';
import '../services/api_client.dart';

class CreatePostScreen extends StatefulWidget {
  final int? communityId;

  const CreatePostScreen({super.key, this.communityId});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _captionController = TextEditingController();
  File? _selectedImage;
  bool _isAnonymous = false;
  bool _isPosting = false;
  final List<String> _selectedTags = [];
  final ImagePicker _picker = ImagePicker();

  // Poll
  bool _addPoll = false;
  final _pollQuestionController = TextEditingController();
  final List<TextEditingController> _pollOptionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  final List<Map<String, String>> _tags = [
    {'label': '#GlowUp✨', 'value': 'glowup'},
    {'label': '#SelfLove💗', 'value': 'selflove'},
    {'label': '#CareerSpill💼', 'value': 'career'},
    {'label': '#Wellness🌿', 'value': 'wellness'},
    {'label': '#DatingDiaries💕', 'value': 'dating'},
  ];

  Future<void> _pickFromGallery() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  Future<void> _pickFromCamera() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Add a Photo',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 20),
              _buildPickerOption(
                icon: Icons.photo_library_outlined,
                label: 'Choose from Gallery',
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
              const SizedBox(height: 12),
              _buildPickerOption(
                icon: Icons.camera_alt_outlined,
                label: 'Take a Photo',
                onTap: () {
                  Navigator.pop(context);
                  _pickFromCamera();
                },
              ),
              if (_selectedImage != null) ...[
                const SizedBox(height: 12),
                _buildPickerOption(
                  icon: Icons.delete_outline,
                  label: 'Remove Photo',
                  color: const Color(0xFFE53935),
                  onTap: () {
                    setState(() => _selectedImage = null);
                    Navigator.pop(context);
                  },
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = const Color(0xFFBE1373),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _captionController.dispose();
    _pollQuestionController.dispose();
    for (final c in _pollOptionControllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImagePicker(),
            const SizedBox(height: 16),
            _buildCaptionField(),
            const SizedBox(height: 16),
            _buildTagSelector(),
            const SizedBox(height: 16),
            _buildAnonymousToggle(),
            const SizedBox(height: 12),
            _buildPollToggle(),
            if (_addPoll) ...[
              const SizedBox(height: 12),
              _buildPollBuilder(),
            ],
            const SizedBox(height: 24),
            _buildPostButton(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Color(0xFF1A1A1A)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'New Post',
        style: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF1A1A1A),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PHOTO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF555555),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _showPickerOptions,
            child: Container(
              width: double.infinity,
              height: 260,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _selectedImage != null
                      ? const Color(0xFFFFB6C1)
                      : const Color(0xFFDDDDDD),
                  width: 1.5,
                ),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                          // Edit overlay
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: _showPickerOptions,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.edit, color: Colors.white, size: 14),
                                    SizedBox(width: 4),
                                    Text('Change',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF0F5),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFFFFB6C1), width: 1.5),
                          ),
                          child: const Icon(Icons.add_photo_alternate_outlined,
                              color: Color(0xFFBE1373), size: 32),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Tap to add a photo',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF555555),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Gallery or Camera',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFFAAAAAA)),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptionField() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CAPTION',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF555555),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFEC407A), Color(0xFF880E4F)],
                  ),
                ),
                child: const Icon(Icons.person, color: Colors.white60, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _captionController,
                  maxLines: 4,
                  maxLength: 500,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF333333)),
                  decoration: const InputDecoration(
                    hintText: 'Write a caption... what\'s the vibe? ✨',
                    hintStyle: TextStyle(
                        color: Color(0xFFBBBBBB), fontSize: 14),
                    border: InputBorder.none,
                    counterText: '',
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              '${_captionController.text.length}/500',
              style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagSelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TAGS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF555555),
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                'Select up to 3',
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFFBE1373),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) {
              final isSelected = _selectedTags.contains(tag['value']);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedTags.remove(tag['value']);
                    } else if (_selectedTags.length < 3) {
                      _selectedTags.add(tag['value']!);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFBE1373)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFBE1373)
                          : const Color(0xFFDDDDDD),
                    ),
                  ),
                  child: Text(
                    tag['label']!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF555555),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnonymousToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFB6C1), width: 1.5),
      ),
      child: Row(
        children: [
          Switch(
            value: _isAnonymous,
            onChanged: (v) => setState(() => _isAnonymous = v),
            activeColor: const Color(0xFFBE1373),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: const Color(0xFFEEEEEE),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Post Anonymously',
                  style: GoogleFonts.dancingScript(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const Text(
                  'Your name won\'t appear on this post',
                  style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePost(BuildContext context) async {
    final caption = _captionController.text.trim();
    if (_selectedImage == null && caption.isEmpty) return;

    setState(() => _isPosting = true);
    try {
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await PostService.uploadImage(_selectedImage!.path);
      }
      Map<String, dynamic>? poll;
      if (_addPoll) {
        final question = _pollQuestionController.text.trim();
        final options = _pollOptionControllers
            .map((c) => c.text.trim())
            .where((s) => s.isNotEmpty)
            .toList();
        if (question.isNotEmpty && options.length >= 2) {
          poll = {'question': question, 'options': options};
        }
      }
      await PostService.createPost(
        content: caption.isEmpty ? '✨' : caption,
        imageUrl: imageUrl,
        topicTags: _selectedTags,
        communityId: widget.communityId,
        poll: poll,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post shared! ✨'),
          backgroundColor: Color(0xFFBE1373),
        ),
      );
      Navigator.pop(context, true); // true = post was created
    } on ApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFE53935)),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to share post. Try again.'),
          backgroundColor: Color(0xFFE53935),
        ),
      );
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  Widget _buildPollToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFB6C1), width: 1.5),
      ),
      child: Row(
        children: [
          Switch(
            value: _addPoll,
            onChanged: (v) => setState(() => _addPoll = v),
            activeColor: const Color(0xFFBE1373),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: const Color(0xFFEEEEEE),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add a Poll',
                    style: GoogleFonts.dancingScript(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A1A))),
                const Text('Let your community vote',
                    style: TextStyle(fontSize: 12, color: Color(0xFF888888))),
              ],
            ),
          ),
          const Icon(Icons.bar_chart_rounded,
              color: Color(0xFFBE1373), size: 22),
        ],
      ),
    );
  }

  Widget _buildPollBuilder() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('POLL QUESTION',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF555555),
                  letterSpacing: 1.5)),
          const SizedBox(height: 10),
          TextField(
            controller: _pollQuestionController,
            maxLength: 200,
            style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
            decoration: InputDecoration(
              hintText: 'Ask your question...',
              hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 14),
              filled: true,
              fillColor: const Color(0xFFFAFAFA),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFBE1373), width: 1.5)),
              counterStyle:
                  const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA)),
            ),
          ),
          const SizedBox(height: 14),
          const Text('OPTIONS',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF555555),
                  letterSpacing: 1.5)),
          const SizedBox(height: 10),
          ...List.generate(_pollOptionControllers.length, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pollOptionControllers[i],
                    style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
                    decoration: InputDecoration(
                      hintText: 'Option ${i + 1}',
                      hintStyle: const TextStyle(
                          color: Color(0xFFBBBBBB), fontSize: 14),
                      filled: true,
                      fillColor: const Color(0xFFFAFAFA),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFEEEEEE))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFEEEEEE))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFFBE1373), width: 1.5)),
                    ),
                  ),
                ),
                if (i >= 2) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() {
                      _pollOptionControllers[i].dispose();
                      _pollOptionControllers.removeAt(i);
                    }),
                    child: const Icon(Icons.remove_circle_outline,
                        color: Color(0xFFE53935), size: 22),
                  ),
                ],
              ],
            ),
          )),
          if (_pollOptionControllers.length < 6)
            GestureDetector(
              onTap: () => setState(() =>
                  _pollOptionControllers.add(TextEditingController())),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFFFFB6C1),
                      style: BorderStyle.solid),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Color(0xFFBE1373), size: 18),
                    SizedBox(width: 6),
                    Text('Add Option',
                        style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFBE1373),
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPostButton(BuildContext context) {
    final canPost = _selectedImage != null ||
        _captionController.text.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _isPosting
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFBE1373)))
          : GestureDetector(
              onTap: canPost ? () => _handlePost(context) : null,
              child: Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  gradient: canPost
                      ? const LinearGradient(
                          colors: [Color(0xFFBE1373), Color(0xFFEC407A)],
                        )
                      : null,
                  color: canPost ? null : const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: canPost
                      ? [
                          BoxShadow(
                            color: const Color(0xFFBE1373).withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'SHARE POST ✦',
                    style: TextStyle(
                      color: canPost ? Colors.white : const Color(0xFFAAAAAA),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
