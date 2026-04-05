import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'story_detail_screen.dart';
import 'notifications_screen.dart';
import 'post_feed_screen.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';
import '../widgets/poll_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  /// Call this from anywhere to trigger a feed reload.
  static VoidCallback? refreshCallback;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _tags = [
    '#GlowUp',
    '#Career',
    '#Relationships',
    '#Wellness',
    '#Style',
  ];
  int _selectedTagIndex = 0;
  List<PostModel> _previewPosts = [];
  bool _postsLoading = true;

  @override
  void initState() {
    super.initState();
    HomeScreen.refreshCallback = _loadPreviewPosts;
    _loadPreviewPosts();
  }

  @override
  void dispose() {
    HomeScreen.refreshCallback = null;
    super.dispose();
  }

  Future<void> _loadPreviewPosts() async {
    try {
      final posts = await PostService.getFeed(page: 0, size: 3);
      if (mounted) setState(() { _previewPosts = posts; _postsLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _postsLoading = false);
    }
  }

  String _formatTime(String isoString) {
    if (isoString.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoString);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays == 1) return 'Yesterday';
      return '${diff.inDays}d ago';
    } catch (_) { return ''; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadPreviewPosts,
        color: const Color(0xFFBE1373),
        child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTagsRow(),
            _buildHeroBanner(),
            const SizedBox(height: 20),
            _buildRadiantStoriesHeader(),
            const SizedBox(height: 12),
            _buildMemberSpotlightCard(),
            const SizedBox(height: 12),
            _buildFeaturedStoryCard(),
            const SizedBox(height: 12),
            _buildDailyPromptCard(),
            const SizedBox(height: 20),
            _buildPostsSectionHeader(context),
            const SizedBox(height: 12),
            if (_postsLoading)
              const Center(child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: Color(0xFFBE1373)),
              ))
            else if (_previewPosts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('No posts yet — be the first to share!',
                    style: TextStyle(color: const Color(0xFF888888), fontSize: 13)),
              )
            else
              ..._previewPosts.asMap().entries.map((e) => Padding(
                padding: EdgeInsets.only(bottom: e.key < _previewPosts.length - 1 ? 12 : 0),
                child: _buildApiPostCard(e.value),
              )),
            const SizedBox(height: 12),
            _buildSpillingTeaBanner(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: CircleAvatar(
          radius: 16,
          backgroundColor: const Color(0xFF8D6E63),
          child: const Icon(Icons.person, color: Colors.white, size: 18),
        ),
      ),
      title: Text(
        'Sparkle & Spill',
        style: GoogleFonts.dancingScript(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFBE1373),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined,
              color: Color(0xFF1A1A1A), size: 26),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()));
          },
        ),
      ],
    );
  }

  Widget _buildTagsRow() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(_tags.length, (i) {
            final isSelected = _selectedTagIndex == i;
            return GestureDetector(
              onTap: () => setState(() => _selectedTagIndex = i),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFBE1373)
                      : const Color(0xFFFFF0F5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFBE1373)
                        : const Color(0xFFFFB6C1),
                  ),
                ),
                child: Text(
                  _tags[i],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : const Color(0xFFBE1373),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A0A12), Color(0xFF3D1535), Color(0xFF6B2D5E)],
        ),
      ),
      child: Stack(
        children: [
          // Background art figures (decorative circles)
          Positioned(
            right: -10,
            top: -10,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8B1A6B).withOpacity(0.4),
              ),
            ),
          ),
          Positioned(
            right: 30,
            top: 10,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD4607A).withOpacity(0.3),
              ),
            ),
          ),
          // Decorative woman silhouettes
          Positioned(
            right: 16,
            bottom: 0,
            child: Row(
              children: [
                _buildSilhouette(const Color(0xFF8B5E6B), 80, 120),
                const SizedBox(width: 4),
                _buildSilhouette(const Color(0xFFBE7A8A), 70, 130),
                const SizedBox(width: 4),
                _buildSilhouette(const Color(0xFF6B3D4E), 75, 115),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBE1373),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'ARTIST SPOTLIGHT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The Art of Us',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Celebrate Our Collective Radiance...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSilhouette(Color color, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(50)),
      ),
      child: Center(
        child: Icon(Icons.person, color: color.withOpacity(0.5), size: 40),
      ),
    );
  }

  Widget _buildRadiantStoriesHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Radiant Stories',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              color: const Color(0xFFBE1373),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: const Text(
              'View all →',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFFBE1373),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberSpotlightCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Story image — dark with flower woman art
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1A0A12), Color(0xFF4A1A3A)],
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [Color(0xFFE91E8C), Color(0xFF880E4F)],
                            ),
                          ),
                          child: const Icon(Icons.person,
                              color: Colors.white54, size: 60),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '🌸',
                          style: TextStyle(fontSize: 32),
                        ),
                      ],
                    ),
                  ),
                  // Overlay text
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'mulher',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'Empodere\numa mulher,\ntransformo\nmundo',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white70,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Card content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Member Spotlight Elena',
                  style: GoogleFonts.dancingScript(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFBE1373),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '"Empowering the Voice Within"',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '"True radiance comes from the courage to stand in your own truth..."',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF666666),
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const StoryDetailScreen()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFBE1373), Color(0xFFEC407A)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: Text(
                        'READ HER STORY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedStoryCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 140,
              width: double.infinity,
              color: const Color(0xFFFFF9C4),
              child: const Center(
                child: Text('🎁', style: TextStyle(fontSize: 60)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F5),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFFFB6C1)),
                  ),
                  child: const Text(
                    'FEATURED STORY',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFBE1373),
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manifesting Dreams...',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyPromptCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                'Daily Prompt',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "What is one thing you're letting go of this month to make room for growth?",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF333333),
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          _buildStackedAvatars(),
        ],
      ),
    );
  }

  Widget _buildStackedAvatars() {
    final colors = [
      const Color(0xFF8D6E63),
      const Color(0xFFFF8A65),
      const Color(0xFFF06292),
    ];
    return SizedBox(
      height: 30,
      width: 90,
      child: Stack(
        children: List.generate(
          colors.length,
          (i) => Positioned(
            left: i * 20.0,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: colors[i],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserPostCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFF06292),
                  child: const Icon(Icons.person, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Maya Sterling',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      '#Always #GLOWer',
                      style: TextStyle(
                        fontSize: 11,
                        color: const Color(0xFFBE1373),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.more_horiz, color: Color(0xFF888888)),
              ],
            ),
          ),
          // Post image
          Container(
            height: 160,
            width: double.infinity,
            color: const Color(0xFFF5F0E8),
            child: const Center(
              child: Text('🌸  🕯️  💐', style: TextStyle(fontSize: 40)),
            ),
          ),
          // Post caption
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Finally invested in my morning sanctuary. They say you can't pour from an empty cup...",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF333333),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.favorite_outline,
                        color: Color(0xFFBE1373), size: 20),
                    const SizedBox(width: 4),
                    const Text(
                      '1.2k',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF555555),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.chat_bubble_outline,
                        color: Color(0xFF888888), size: 20),
                    const SizedBox(width: 4),
                    const Text(
                      '84',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF555555),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsSectionHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Posts',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PostFeedScreen())),
            child: const Text(
              'View all →',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFFBE1373),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiPostCard(PostModel post) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFEC407A),
                  backgroundImage: post.author.profileImageUrl != null
                      ? NetworkImage(post.author.profileImageUrl!)
                      : null,
                  child: post.author.profileImageUrl == null
                      ? const Icon(Icons.person, color: Colors.white, size: 20)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.author.displayName,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A1A))),
                      Text(
                          '@${post.author.displayName.toLowerCase().replaceAll(' ', '.')}',
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFFBE1373))),
                    ],
                  ),
                ),
                Text(_formatTime(post.createdAt),
                    style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA))),
              ],
            ),
          ),
          if (post.imageUrl != null)
            Image.network(
              post.imageUrl!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 120,
                color: const Color(0xFFFFF0F5),
                child: const Center(child: Icon(Icons.auto_awesome, color: Color(0xFFFFB6C1), size: 40)),
              ),
            )
          else
            Container(
              height: 120,
              width: double.infinity,
              color: const Color(0xFFFFF0F5),
              child: const Center(child: Icon(Icons.auto_awesome, color: Color(0xFFFFB6C1), size: 40)),
            ),
          if (post.poll != null)
            PollWidget(
              poll: post.poll!,
              onVoted: (updated) {
                setState(() {
                  _previewPosts = _previewPosts.map((p) =>
                    p.id == post.id ? p.copyWith(poll: updated) : p).toList();
                });
              },
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF333333), height: 1.5)),
                if (post.topicTags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: post.topicTags
                        .map((t) => Text('#$t',
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFFBE1373), fontWeight: FontWeight.w600)))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      post.likedByMe ? Icons.favorite : Icons.favorite_outline,
                      color: post.likedByMe ? const Color(0xFFBE1373) : const Color(0xFF888888),
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text('${post.likeCount}',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF666666), fontWeight: FontWeight.w600)),
                    const SizedBox(width: 20),
                    const Icon(Icons.chat_bubble_outline, color: Color(0xFF888888), size: 20),
                    const SizedBox(width: 4),
                    Text('${post.commentCount}',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF666666))),
                    const Spacer(),
                    const Icon(Icons.bookmark_outline, color: Color(0xFF888888), size: 20),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpillingTeaBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A0A12), Color(0xFF4A1A3A)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spilling the Tea...',
            style: GoogleFonts.dancingScript(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFEC407A),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '"The biggest secret to high-\nmake your own..."',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text('❝',
                  style: TextStyle(color: Color(0xFFEC407A), fontSize: 24)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFBE1373),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Read More',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
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

}
