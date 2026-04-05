import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/post_model.dart';
import '../services/api_client.dart';
import '../services/community_service.dart';
import 'comments_screen.dart';

class CommunityDetailScreen extends StatefulWidget {
  final int? communityId;
  final String name;
  final String emoji;
  final String tag;
  final Color color;

  const CommunityDetailScreen({
    super.key,
    this.communityId,
    this.name = 'CareerSpill',
    this.emoji = '💼',
    this.tag = '#CareerSpill',
    this.color = const Color(0xFFBE1373),
  });

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isJoined = false;
  bool _joinLoading = false;
  List<PostModel> _posts = [];
  bool _postsLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    if (widget.communityId != null) _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _postsLoading = true);
    try {
      final response = await ApiClient.get(
          '/api/communities/${widget.communityId}/posts?page=0&size=20');
      final data = ApiClient.parseResponse(response);
      final List content = data['content'] ?? [];
      if (mounted) {
        setState(() {
          _posts = content.map((e) => PostModel.fromJson(e)).toList();
          _postsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _postsLoading = false);
    }
  }

  Future<void> _toggleJoin() async {
    if (widget.communityId == null) return;
    setState(() => _joinLoading = true);
    try {
      if (_isJoined) {
        await CommunityService.leaveCommunity(widget.communityId!);
      } else {
        await CommunityService.joinCommunity(widget.communityId!);
      }
      if (mounted) setState(() => _isJoined = !_isJoined);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: const Color(0xFFE53935)),
        );
      }
    } finally {
      if (mounted) setState(() => _joinLoading = false);
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(child: _buildCommunityInfo()),
          SliverToBoxAdapter(child: _buildStatsRow()),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: const Color(0xFFBE1373),
                unselectedLabelColor: const Color(0xFF888888),
                indicatorColor: const Color(0xFFBE1373),
                indicatorWeight: 2.5,
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 13),
                tabs: const [
                  Tab(text: 'Spills'),
                  Tab(text: 'Members'),
                  Tab(text: 'About'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildSpillsTab(),
            _buildMembersTab(),
            _buildAboutTab(),
          ],
        ),
      ),
      floatingActionButton: _isJoined ? _buildSpillFab() : null,
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
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
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.share_outlined,
                color: Colors.white, size: 20),
            onPressed: () {},
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A0A12),
                widget.color.withOpacity(0.8),
                const Color(0xFF3D1535),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withOpacity(0.15),
                  ),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF9C27B0).withOpacity(0.1),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    Text(widget.emoji,
                        style: const TextStyle(fontSize: 52)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.3)),
                      ),
                      child: const Text(
                        'OFFICE DRAMA',
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

  Widget _buildCommunityInfo() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.tag,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              _joinLoading
                  ? const SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(color: Color(0xFFBE1373), strokeWidth: 2),
                    )
                  : GestureDetector(
                      onTap: _toggleJoin,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: _isJoined ? null : const LinearGradient(
                              colors: [Color(0xFFBE1373), Color(0xFFEC407A)]),
                          border: _isJoined
                              ? Border.all(color: const Color(0xFFBE1373), width: 1.5)
                              : null,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          _isJoined ? 'Joined ✓' : 'Join Circle',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: _isJoined ? const Color(0xFFBE1373) : Colors.white,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Navigating the glass ceiling with a glass of champagne. Salary transparency, boss battles, and corporate couture.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF666666),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          // Stacked avatars
          Row(
            children: [
              _buildStackedAvatars(),
              const SizedBox(width: 10),
              Text(
                '820 spilling right now',
                style: GoogleFonts.dancingScript(
                  fontSize: 16,
                  color: const Color(0xFFBE1373),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStackedAvatars() {
    final colors = [
      const Color(0xFFFF7043),
      const Color(0xFF5C6BC0),
      const Color(0xFF9C27B0),
    ];
    return SizedBox(
      width: 72,
      height: 28,
      child: Stack(
        children: List.generate(
          colors.length,
          (i) => Positioned(
            left: i * 18.0,
            child: Container(
              width: 28,
              height: 28,
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

  Widget _buildStatsRow() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        children: [
          const Divider(color: Color(0xFFF0F0F0)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('246', 'Members'),
              _buildDivider(),
              _buildStat('820', 'Online'),
              _buildDivider(),
              _buildStat('1.4k', 'Stories'),
              _buildDivider(),
              _buildStat('48k', 'Sparkles'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
        width: 1, height: 28, color: const Color(0xFFEEEEEE));
  }

  Widget _buildSpillsTab() {
    if (widget.communityId == null) {
      return const Center(child: Text('No community ID', style: TextStyle(color: Color(0xFF888888))));
    }
    if (_postsLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFBE1373)));
    }
    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('✨', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text('No posts yet in this community',
                style: GoogleFonts.dancingScript(fontSize: 18, color: const Color(0xFFAAAAAA))),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadPosts,
      color: const Color(0xFFBE1373),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _posts.length,
        itemBuilder: (context, i) => _buildPostCard(_posts[i]),
      ),
    );
  }

  Widget _buildPostCard(PostModel post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFEC407A),
                backgroundImage: post.author.profileImageUrl != null
                    ? NetworkImage(post.author.profileImageUrl!)
                    : null,
                child: post.author.profileImageUrl == null
                    ? Text(post.author.displayName[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.author.displayName,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
                    Text(_formatTime(post.createdAt),
                        style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA))),
                  ],
                ),
              ),
              const Icon(Icons.more_horiz, color: Color(0xFF888888), size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Text(post.content,
              style: const TextStyle(fontSize: 14, color: Color(0xFF333333), height: 1.6)),
          if (post.topicTags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: post.topicTags.map((t) => Text('#$t',
                  style: const TextStyle(fontSize: 11, color: Color(0xFFBE1373), fontWeight: FontWeight.w600))).toList(),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                post.likedByMe ? Icons.favorite : Icons.favorite_outline,
                size: 18,
                color: post.likedByMe ? const Color(0xFFBE1373) : const Color(0xFF888888),
              ),
              const SizedBox(width: 4),
              Text('${post.likeCount}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF666666), fontWeight: FontWeight.w600)),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => CommentsScreen(postId: post.id, isAnonymous: false, postContent: post.content),
                )),
                child: const Icon(Icons.chat_bubble_outline, size: 18, color: Color(0xFF888888)),
              ),
              const SizedBox(width: 4),
              Text('${post.commentCount}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF666666))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMembersTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_outline, size: 48, color: Color(0xFFDDDDDD)),
          const SizedBox(height: 12),
          Text('Members info coming soon',
              style: GoogleFonts.dancingScript(fontSize: 18, color: const Color(0xFFAAAAAA))),
        ],
      ),
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAboutCard(
            icon: Icons.info_outline,
            title: 'About this Community',
            content:
                'A safe space for women to talk about the real, unfiltered side of career life. From glass ceilings to salary negotiations, office politics to corporate fashion — spill it all here.',
          ),
          const SizedBox(height: 12),
          _buildAboutCard(
            icon: Icons.rule_outlined,
            title: 'Community Rules',
            content:
                '1. No judgment — only growth\n2. Salary transparency is celebrated\n3. Support > competition\n4. Keep it real, keep it kind\n5. No mansplaining proxies allowed 💅',
          ),
          const SizedBox(height: 12),
          _buildAboutCard(
            icon: Icons.calendar_today_outlined,
            title: 'Weekly Events',
            content:
                '🗓 Monday: Salary Talk Tuesdays\n🗓 Wednesday: Boss Battle Stories\n🗓 Friday: Win of the Week ✨',
          ),
          const SizedBox(height: 12),
          _buildAboutCard(
            icon: Icons.local_fire_department_outlined,
            title: 'Trending Tags',
            content: '',
            tags: [
              '#SalaryTalk',
              '#GlassCeiling',
              '#OfficeDrama',
              '#CareerGlow',
              '#WorkLifeBalance',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard({
    required IconData icon,
    required String title,
    required String content,
    List<String>? tags,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
              Icon(icon, color: const Color(0xFFBE1373), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (content.isNotEmpty)
            Text(
              content,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF555555),
                height: 1.6,
              ),
            ),
          if (tags != null) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags
                  .map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: const Color(0xFFFFB6C1), width: 1),
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
          ],
        ],
      ),
    );
  }

  Widget _buildSpillFab() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFBE1373), Color(0xFFEC407A)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFBE1373).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: Colors.transparent,
        elevation: 0,
        label: const Text(
          'Spill Here ✦',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 18),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabBarDelegate(this.tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      Container(color: Colors.white, child: tabBar);

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
