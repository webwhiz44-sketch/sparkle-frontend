import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/story_service.dart';
import '../services/post_service.dart';
import '../services/api_client.dart';

class WriteStoryScreen extends StatefulWidget {
  const WriteStoryScreen({super.key});

  @override
  State<WriteStoryScreen> createState() => _WriteStoryScreenState();
}

class _WriteStoryScreenState extends State<WriteStoryScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _tagController = TextEditingController();
  File? _coverImage;
  final List<String> _tags = [];
  bool _isPosting = false;
  int _wordCount = 0;

  @override
  void initState() {
    super.initState();
    _bodyController.addListener(() {
      final words = _bodyController.text.trim().isEmpty
          ? 0
          : _bodyController.text.trim().split(RegExp(r'\s+')).length;
      if (words != _wordCount) setState(() => _wordCount = words);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  int get _readTime => (_wordCount / 200).ceil().clamp(1, 999);

  Future<void> _pickCover() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) setState(() => _coverImage = File(picked.path));
  }

  void _addTag(String value) {
    final tag = value.trim().replaceAll('#', '').toLowerCase();
    if (tag.isEmpty || _tags.contains(tag) || _tags.length >= 5) return;
    setState(() { _tags.add(tag); _tagController.clear(); });
  }

  Future<void> _publish() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a title'), backgroundColor: Color(0xFFBE1373)),
      );
      return;
    }
    if (body.length < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Story must be at least 100 characters'), backgroundColor: Color(0xFFBE1373)),
      );
      return;
    }

    setState(() => _isPosting = true);
    try {
      String? coverImageUrl;
      if (_coverImage != null) {
        coverImageUrl = await PostService.uploadImage(_coverImage!.path);
      }
      await StoryService.createStory(
        title: title,
        body: body,
        coverImageUrl: coverImageUrl,
        tags: _tags,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Story published ✨'), backgroundColor: Color(0xFFBE1373)),
      );
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFE53935)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to publish. Please try again.'), backgroundColor: Color(0xFFE53935)),
      );
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Write a Story',
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: GestureDetector(
              onTap: _isPosting ? null : _publish,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFBE1373), Color(0xFFEC407A)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _isPosting
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Publish',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image picker
            GestureDetector(
              onTap: _pickCover,
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: const Color(0xFFF5F5F5),
                  image: _coverImage != null
                      ? DecorationImage(image: FileImage(_coverImage!), fit: BoxFit.cover)
                      : null,
                ),
                child: _coverImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_photo_alternate_outlined,
                              size: 40, color: Color(0xFFCCCCCC)),
                          const SizedBox(height: 8),
                          Text('Add Cover Image',
                              style: GoogleFonts.dancingScript(
                                  fontSize: 16, color: const Color(0xFFAAAAAA))),
                        ],
                      )
                    : Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () => setState(() => _coverImage = null),
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                                color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            TextField(
              controller: _titleController,
              maxLines: null,
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic,
                color: const Color(0xFF1A1A1A),
              ),
              decoration: const InputDecoration(
                hintText: 'Your story title...',
                hintStyle: TextStyle(
                  fontSize: 24,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFFCCCCCC),
                ),
                border: InputBorder.none,
              ),
            ),
            const Divider(color: Color(0xFFF0F0F0)),
            const SizedBox(height: 12),

            // Body
            TextField(
              controller: _bodyController,
              maxLines: null,
              minLines: 10,
              style: const TextStyle(fontSize: 15, color: Color(0xFF333333), height: 1.8),
              decoration: const InputDecoration(
                hintText: 'Tell your story...',
                hintStyle: TextStyle(fontSize: 15, color: Color(0xFFCCCCCC)),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 8),

            // Word count + read time
            Row(
              children: [
                Text(
                  '$_wordCount words  ·  ~$_readTime min read',
                  style: const TextStyle(fontSize: 12, color: Color(0xFFAAAAAA)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Color(0xFFF0F0F0)),
            const SizedBox(height: 16),

            // Tags
            Text('Tags', style: GoogleFonts.playfairDisplay(
                fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A1A))),
            const SizedBox(height: 10),
            if (_tags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags.map((t) => GestureDetector(
                  onTap: () => setState(() => _tags.remove(t)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFFB6C1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('#$t', style: const TextStyle(
                            fontSize: 12, color: Color(0xFFBE1373), fontWeight: FontWeight.w600)),
                        const SizedBox(width: 5),
                        const Icon(Icons.close, size: 12, color: Color(0xFFBE1373)),
                      ],
                    ),
                  ),
                )).toList(),
              ),
            const SizedBox(height: 10),
            if (_tags.length < 5)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      onSubmitted: _addTag,
                      decoration: InputDecoration(
                        hintText: 'Add a tag (e.g. healing)',
                        hintStyle: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 13),
                        prefixText: '#',
                        prefixStyle: const TextStyle(color: Color(0xFFBE1373), fontWeight: FontWeight.w700),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _addTag(_tagController.text),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFBE1373), Color(0xFFEC407A)]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
