import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';
import 'edit_profile_screen.dart';
import 'post_feed_screen.dart';
import 'communities_screen.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/community_model.dart';
import '../services/user_service.dart';
import '../services/post_service.dart';
import '../services/community_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserModel? _user;
  List<PostModel> _myPosts = [];
  List<PostModel> _savedPosts = [];
  List<CommunityModel> _myCommunities = [];
  bool _isLoading = true;
  bool _savedLoading = false;
  bool _clubsLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadProfile();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (_tabController.index == 1 && _savedPosts.isEmpty && !_savedLoading) {
      _loadSavedPosts();
    } else if (_tabController.index == 2 && _myCommunities.isEmpty && !_clubsLoading) {
      _loadMyCommunities();
    }
  }

  Future<void> _loadProfile() async {
    try {
      final results = await Future.wait([
        UserService.getMe(),
        PostService.getFeed(page: 0, size: 20),
      ]);
      if (mounted) {
        setState(() {
          _user = results[0] as UserModel;
          _myPosts = results[1] as List<PostModel>;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSavedPosts() async {
    setState(() => _savedLoading = true);
    try {
      final posts = await PostService.getSavedPosts();
      if (mounted) setState(() { _savedPosts = posts; _savedLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _savedLoading = false);
    }
  }

  Future<void> _loadMyCommunities() async {
    setState(() => _clubsLoading = true);
    try {
      final communities = await CommunityService.getMyCommunities();
      if (mounted) setState(() { _myCommunities = communities; _clubsLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _clubsLoading = false);
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
    _tabController.removeListener(_onTabChanged);
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
          SliverToBoxAdapter(child: _buildProfileInfo()),
          SliverToBoxAdapter(child: _buildStatsRow()),
          SliverToBoxAdapter(child: _buildInterestTags()),
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
                  Tab(text: 'Stories'),
                  Tab(text: 'Saved'),
                  Tab(text: 'Clubs'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildStoriesTab(),
            _buildSavedTab(),
            _buildClubsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: const Color(0xFF1A0A12),
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined,
              color: Colors.white, size: 24),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen())),
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined,
              color: Colors.white, size: 24),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const SettingsScreen())),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A0A12), Color(0xFF6B2D5E), Color(0xFF3D1535)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFBE1373).withOpacity(0.15),
                  ),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -30,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF9C27B0).withOpacity(0.15),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'My Sanctuary',
                    style: GoogleFonts.dancingScript(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.5),
                      fontStyle: FontStyle.italic,
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

  Widget _buildProfileInfo() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + edit button row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Transform.translate(
                offset: const Offset(0, -30),
                child: Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEC407A), Color(0xFF880E4F)],
                        ),
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFBE1373).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.person,
                          color: Colors.white70, size: 46),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD600),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.star_rounded,
                            color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  if (_user == null) return;
                  final result = await Navigator.push(context,
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (_) => EditProfileScreen(user: _user!),
                    ));
                  if (result == true) _loadProfile();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color(0xFFBE1373), width: 1.5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFBE1373),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (ctx) => SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDDDDDD),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            ListTile(
                              leading: const Icon(Icons.share_outlined,
                                  color: Color(0xFFBE1373)),
                              title: const Text('Share Profile',
                                  style: TextStyle(fontWeight: FontWeight.w600)),
                              onTap: () {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Share link copied! ✨'),
                                    backgroundColor: Color(0xFFBE1373),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.settings_outlined,
                                  color: Color(0xFF555555)),
                              title: const Text('Settings',
                                  style: TextStyle(fontWeight: FontWeight.w600)),
                              onTap: () {
                                Navigator.pop(ctx);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const SettingsScreen()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.more_horiz,
                      color: Color(0xFF555555), size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Name & handle
          Text(
            _user?.displayName ?? 'Loading...',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _user != null
                ? '@${_user!.displayName.toLowerCase().replaceAll(' ', '.')}'
                : '',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFBE1373),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          // Sparkle rank badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD600), Color(0xFFFFAB00)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text('Sparkle Member',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
          if (_user?.bio != null && _user!.bio!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              _user!.bio!,
              style: const TextStyle(fontSize: 13, color: Color(0xFF444444), height: 1.6),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFFAAAAAA)),
              const SizedBox(width: 4),
              Text(
                _user != null ? 'Joined ${_formatTime(_user!.createdAt ?? '')}' : '',
                style: const TextStyle(fontSize: 12, color: Color(0xFFAAAAAA)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          const Divider(color: Color(0xFFF0F0F0)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('${_myPosts.length}', 'Posts'),
              _buildStatDivider(),
              _buildStat(
                '${_myPosts.fold(0, (sum, p) => sum + p.likeCount)}',
                'Sparkles',
              ),
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
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF888888),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 32,
      color: const Color(0xFFEEEEEE),
    );
  }

  Widget _buildInterestTags() {
    final tags = (_user?.interests.isNotEmpty == true)
        ? _user!.interests
        : <String>[];
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
    );
  }

  Widget _buildStoriesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFBE1373)));
    }
    if (_myPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome_outlined, size: 48, color: Color(0xFFDDDDDD)),
            const SizedBox(height: 12),
            Text('No posts yet', style: GoogleFonts.dancingScript(fontSize: 20, color: const Color(0xFFAAAAAA))),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myPosts.length,
      itemBuilder: (context, i) {
        final post = _myPosts[i];
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
              if (post.topicTags.isNotEmpty)
                Wrap(
                  spacing: 6,
                  children: post.topicTags.map((t) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFFB6C1)),
                    ),
                    child: Text('#$t', style: const TextStyle(fontSize: 11, color: Color(0xFFBE1373), fontWeight: FontWeight.w700)),
                  )).toList(),
                ),
              const SizedBox(height: 10),
              Text(
                post.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A), height: 1.4),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.favorite_outline, size: 15, color: Color(0xFFBE1373)),
                  const SizedBox(width: 4),
                  Text('${post.likeCount}', style: const TextStyle(fontSize: 12, color: Color(0xFF666666))),
                  const SizedBox(width: 14),
                  const Icon(Icons.chat_bubble_outline, size: 15, color: Color(0xFF888888)),
                  const SizedBox(width: 4),
                  Text('${post.commentCount}', style: const TextStyle(fontSize: 12, color: Color(0xFF666666))),
                  const Spacer(),
                  Text(_formatTime(post.createdAt), style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA))),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSavedTab() {
    if (_savedLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFBE1373)));
    }
    if (_savedPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bookmark_outline, size: 56, color: Color(0xFFDDDDDD)),
            const SizedBox(height: 12),
            Text(
              'Your saved stories\nwill appear here',
              textAlign: TextAlign.center,
              style: GoogleFonts.dancingScript(
                fontSize: 20,
                color: const Color(0xFFAAAAAA),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PostFeedScreen())),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFBE1373), Color(0xFFEC407A)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text(
                  'Explore Stories',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _savedPosts.length,
      itemBuilder: (context, index) {
        final post = _savedPosts[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFFEC407A),
                      backgroundImage: post.author.profileImageUrl != null
                          ? NetworkImage(post.author.profileImageUrl!)
                          : null,
                      child: post.author.profileImageUrl == null
                          ? const Icon(Icons.person, color: Colors.white, size: 18)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      post.author.displayName,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () async {
                        await PostService.unsavePost(post.id);
                        setState(() => _savedPosts.removeAt(index));
                      },
                      child: const Icon(Icons.bookmark, color: Color(0xFFBE1373), size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  post.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF333333), height: 1.5),
                ),
                if (post.topicTags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: post.topicTags.map((t) => Text(
                      '#$t',
                      style: const TextStyle(fontSize: 11, color: Color(0xFFBE1373), fontWeight: FontWeight.w600),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildClubsTab() {
    if (_clubsLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFBE1373)));
    }
    if (_myCommunities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 56, color: Color(0xFFDDDDDD)),
            const SizedBox(height: 12),
            Text(
              'Your clubs will\nappear here',
              textAlign: TextAlign.center,
              style: GoogleFonts.dancingScript(fontSize: 20, color: const Color(0xFFAAAAAA)),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CommunitiesScreen())),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFBE1373), Color(0xFFEC407A)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text(
                  'Browse Clubs',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myCommunities.length,
      itemBuilder: (context, index) {
        final club = _myCommunities[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFBE1373), Color(0xFFEC407A)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: club.coverImageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(club.coverImageUrl!, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.people, color: Colors.white, size: 22)),
                    )
                  : const Icon(Icons.people, color: Colors.white, size: 22),
            ),
            title: Text(
              club.name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              '${club.memberCount} members',
              style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
            ),
            trailing: const Icon(Icons.chevron_right, color: Color(0xFFCCCCCC)),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CommunitiesScreen())),
          ),
        );
      },
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabBarDelegate(this.tabBar);

  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      Container(color: Colors.white, child: tabBar);

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
