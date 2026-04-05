import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StoryDetailScreen extends StatefulWidget {
  const StoryDetailScreen({super.key});

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  bool _isLiked = false;
  bool _isBookmarked = false;
  int _likeCount = 1243;
  final _commentController = TextEditingController();

  final List<Map<String, dynamic>> _comments = [
    {
      'name': 'Zara M.',
      'handle': '@zara_glows',
      'avatar': const Color(0xFFEC407A),
      'comment': 'This hit different. I needed to read this today 💕',
      'likes': 48,
      'time': '2h ago',
    },
    {
      'name': 'Priya K.',
      'handle': '@priya.sparkles',
      'avatar': const Color(0xFF9C27B0),
      'comment':
          'The part about standing in your own truth — that\'s my entire 2024 mantra. Thank you Elena ✨',
      'likes': 32,
      'time': '4h ago',
    },
    {
      'name': 'Jade L.',
      'handle': '@jade_collective',
      'avatar': const Color(0xFF26A69A),
      'comment': 'Bookmarked forever. Real radiance really does come from within 🌸',
      'likes': 19,
      'time': '6h ago',
    },
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(context),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildAuthorSection(),
                      _buildStoryContent(),
                      _buildTags(),
                      _buildEngagementBar(),
                      const Divider(color: Color(0xFFEEEEEE), thickness: 1),
                      _buildCommentsSection(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: const Color(0xFF1A0A12),
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => setState(() => _isBookmarked = !_isBookmarked),
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
              color: _isBookmarked ? const Color(0xFFFFD600) : Colors.white,
              size: 20,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.share_outlined, color: Colors.white, size: 20),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A0A12), Color(0xFF4A1A3A)],
            ),
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFBE1373).withOpacity(0.2),
                  ),
                ),
              ),
              Positioned(
                left: -20,
                bottom: 20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF9C27B0).withOpacity(0.2),
                  ),
                ),
              ),
              // Center portrait
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [Color(0xFFEC407A), Color(0xFF880E4F)],
                        ),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.3), width: 3),
                      ),
                      child: const Icon(Icons.person,
                          color: Colors.white54, size: 55),
                    ),
                    const SizedBox(height: 12),
                    const Text('🌸', style: TextStyle(fontSize: 24)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBE1373),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'MEMBER SPOTLIGHT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthorSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            '"Empowering the\nVoice Within"',
            style: GoogleFonts.playfairDisplay(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1A1A1A),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          // Author row
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFEC407A), Color(0xFF880E4F)],
                  ),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Elena Rosario',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    '@elena.radiant  ·  Sparkle Rank ✦ Gold',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFFBE1373),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color(0xFFBE1373), width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Follow',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFBE1373),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Meta row
          Row(
            children: [
              const Icon(Icons.access_time_outlined,
                  size: 14, color: Color(0xFFAAAAAA)),
              const SizedBox(width: 4),
              const Text(
                '5 min read  ·  Yesterday at 9:42 PM',
                style: TextStyle(fontSize: 12, color: Color(0xFFAAAAAA)),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFB6C1)),
                ),
                child: const Text(
                  '#GlowUp',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFBE1373),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoryContent() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: Color(0xFFF0F0F0)),
          const SizedBox(height: 12),
          Text(
            'I used to shrink myself in every room I walked into.',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              color: const Color(0xFFBE1373),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Not because I was told to. Not because anyone asked me to. But because somewhere along the way, I convinced myself that taking up space was selfish. That having opinions was too much. That my voice — loud, passionate, unfiltered — was a problem to be managed.\n\nFor years, I perfected the art of making myself smaller. Agreeing when I didn\'t. Smiling when I was screaming inside. Celebrating others while quietly burying my own dreams under layers of "someday" and "maybe later."',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF333333),
              height: 1.8,
            ),
          ),
          const SizedBox(height: 20),
          // Pull quote
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F5),
              borderRadius: BorderRadius.circular(12),
              border: const Border(
                left: BorderSide(color: Color(0xFFBE1373), width: 4),
              ),
            ),
            child: Text(
              '"True radiance comes from the courage to stand in your own truth — even when your voice shakes."',
              style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: const Color(0xFFBE1373),
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'The turning point came on a Tuesday — ordinary in every way except that it wasn\'t. I was in a meeting, about to let someone else take credit for my idea, when something shifted. A quiet voice inside me said: enough.\n\nI spoke up. Clearly. Without apology. And the world didn\'t end. In fact, something beautiful began.\n\nIf you\'re reading this and you\'ve been holding your voice hostage — this is your sign. Your story matters. Your truth matters. You matter.',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF333333),
              height: 1.8,
            ),
          ),
          const SizedBox(height: 20),
          // Closing signature
          Text(
            'With love & radiance,\nElena ✨',
            style: GoogleFonts.dancingScript(
              fontSize: 22,
              color: const Color(0xFFBE1373),
              fontWeight: FontWeight.bold,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags() {
    final tags = ['#GlowUp', '#SelfLove', '#WomenEmpowerment', '#Radiance'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: tags
            .map((tag) => Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F5),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: const Color(0xFFFFB6C1), width: 1),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFBE1373),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildEngagementBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: [
          // Like button
          GestureDetector(
            onTap: () {
              setState(() {
                _isLiked = !_isLiked;
                _likeCount += _isLiked ? 1 : -1;
              });
            },
            child: Row(
              children: [
                Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_outline,
                  color: _isLiked
                      ? const Color(0xFFBE1373)
                      : const Color(0xFF888888),
                  size: 24,
                ),
                const SizedBox(width: 6),
                Text(
                  '$_likeCount',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _isLiked
                        ? const Color(0xFFBE1373)
                        : const Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Comments
          Row(
            children: [
              const Icon(Icons.chat_bubble_outline,
                  color: Color(0xFF888888), size: 22),
              const SizedBox(width: 6),
              const Text(
                '84',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          // Share
          const Icon(Icons.share_outlined,
              color: Color(0xFF888888), size: 22),
          const Spacer(),
          // Bookmark
          GestureDetector(
            onTap: () => setState(() => _isBookmarked = !_isBookmarked),
            child: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
              color: _isBookmarked
                  ? const Color(0xFFFFD600)
                  : const Color(0xFF888888),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Responses (84)',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          ..._comments.map((c) => _buildCommentCard(c)),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'View all 84 responses →',
                style: TextStyle(
                  color: Color(0xFFBE1373),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(Map<String, dynamic> c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: c['avatar'] as Color,
                child: Text(
                  (c['name'] as String)[0],
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c['name'] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    '${c['handle']}  ·  ${c['time']}',
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFFAAAAAA)),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.favorite_outline,
                      size: 14, color: Color(0xFFBBBBBB)),
                  const SizedBox(width: 3),
                  Text(
                    '${c['likes']}',
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFFAAAAAA)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            c['comment'] as String,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF444444),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, MediaQuery.of(context).viewInsets.bottom + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFBE1373),
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _commentController,
              style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
              decoration: InputDecoration(
                hintText: 'Add your sparkle to this story...',
                hintStyle: const TextStyle(
                    color: Color(0xFFBBBBBB), fontSize: 13),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFBE1373), Color(0xFFEC407A)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
