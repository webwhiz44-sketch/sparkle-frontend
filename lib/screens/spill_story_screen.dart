import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/anonymous_post_service.dart';
import '../services/api_client.dart';

class SpillStoryScreen extends StatefulWidget {
  const SpillStoryScreen({super.key});

  @override
  State<SpillStoryScreen> createState() => _SpillStoryScreenState();
}

class _SpillStoryScreenState extends State<SpillStoryScreen> {
  final _narrativeController = TextEditingController();
  bool _isAnonymous = false;
  bool _isPosting = false;
  String _selectedPostType = 'text';
  final List<String> _selectedTags = [];

  final List<Map<String, String>> _tags = [
    {'label': '#GlowUp✨', 'value': 'glowup'},
    {'label': '#DatingDiaries💕', 'value': 'dating'},
    {'label': '#CareerSpill💼', 'value': 'career'},
  ];

  @override
  void dispose() {
    _narrativeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildPostTypeSelector(),
            const SizedBox(height: 16),
            _buildNarrativeCard(),
            const SizedBox(height: 16),
            _buildTopicTags(),
            const SizedBox(height: 16),
            _buildAnonymousToggle(),
            const SizedBox(height: 20),
            _buildPostButton(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Color(0xFF1A1A1A)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Spill Your Story',
        style: GoogleFonts.dancingScript(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFBE1373),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.favorite, color: Color(0xFFBE1373), size: 22),
          const SizedBox(height: 8),
          Text(
            'Spill Your\nStory',
            style: GoogleFonts.playfairDisplay(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              color: const Color(0xFFBE1373),
              height: 1.05,
            ),
          ),
          // Yellow highlight under "Story"
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD600),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Story',
              style: GoogleFonts.playfairDisplay(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: const Color(0xFFBE1373),
                height: 1.05,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Share a secret or a sparkling moment...',
            style: GoogleFonts.dancingScript(
              fontSize: 18,
              color: const Color(0xFF888888),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPostTypeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildPostTypeCard(
            icon: Icons.article_outlined,
            label: 'Text\nPost',
            value: 'text',
          ),
          const SizedBox(width: 12),
          _buildPostTypeCard(
            icon: Icons.add_photo_alternate_outlined,
            label: 'Add\nPhoto',
            value: 'photo',
          ),
        ],
      ),
    );
  }

  Widget _buildPostTypeCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isSelected = _selectedPostType == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPostType = value),
      child: Container(
        width: 100,
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFBE1373)
                : const Color(0xFFDDDDDD),
            width: isSelected ? 2 : 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 24,
                color: isSelected
                    ? const Color(0xFFBE1373)
                    : const Color(0xFF888888)),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFFBE1373)
                    : const Color(0xFF555555),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNarrativeCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'THE NARRATIVE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF555555),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _narrativeController,
              maxLines: 8,
              maxLength: 2500,
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.dancingScript(
                fontSize: 17,
                color: const Color(0xFF333333),
              ),
              decoration: InputDecoration(
                hintText: 'Once upon a time in a coffee\nshop downtown...',
                hintStyle: GoogleFonts.dancingScript(
                  fontSize: 17,
                  color: const Color(0xFFBBBBBB),
                  fontStyle: FontStyle.italic,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
                counterText: '',
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('✦', style: TextStyle(color: Color(0xFFFFD600), fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                '${_narrativeController.text.length} / 2500',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFAAAAAA),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopicTags() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOPIC TAGS',
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
            spacing: 10,
            runSpacing: 10,
            children: [
              ..._tags.map((tag) => _buildTagChip(tag)),
              _buildAddCustomChip(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(Map<String, String> tag) {
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFBE1373) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF1A1A1A),
            width: 1.5,
          ),
        ),
        child: Text(
          tag['label']!,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
      ),
    );
  }

  Widget _buildAddCustomChip() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFCCCCCC),
            width: 1.5,
          ),
        ),
        child: const Text(
          '+ Add Custom',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF888888),
          ),
        ),
      ),
    );
  }

  Widget _buildAnonymousToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFB6C1),
          width: 1.5,
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        children: [
          Switch(
            value: _isAnonymous,
            onChanged: (val) => setState(() => _isAnonymous = val),
            activeColor: const Color(0xFFBE1373),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: const Color(0xFFEEEEEE),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Go Anonymous?',
                  style: GoogleFonts.dancingScript(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const Text(
                  'Your sparkle rank and name\nwill be a mystery... 😏',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          // Thumbtack decoration
          const Text('📌', style: TextStyle(fontSize: 20)),
        ],
      ),
    );
  }

  Future<void> _handleSpill() async {
    final content = _narrativeController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write your story first ✨')),
      );
      return;
    }
    setState(() => _isPosting = true);
    try {
      // Always posts anonymously via anonymous-posts endpoint
      await AnonymousPostService.createPost(
        content: content,
        topicTags: _selectedTags,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your story is out there! ✦'),
          backgroundColor: Color(0xFFBE1373),
        ),
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
        const SnackBar(
          content: Text('Failed to post. Try again.'),
          backgroundColor: Color(0xFFE53935),
        ),
      );
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  Widget _buildPostButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _isPosting
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFBE1373)))
              : GestureDetector(
            onTap: _handleSpill,
            child: Container(
              width: double.infinity,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFBE1373), Color(0xFFEC407A)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFBE1373).withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'POST MY\nSTORY',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('✦', style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Ready to shine?',
            style: GoogleFonts.dancingScript(
              fontSize: 17,
              color: const Color(0xFF888888),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
