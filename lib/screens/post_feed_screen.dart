import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'create_post_screen.dart';
import 'notifications_screen.dart';
import 'comments_screen.dart';
import '../models/post_model.dart';
import '../models/poll_model.dart';
import '../services/post_service.dart';
import '../widgets/poll_widget.dart';

class PostFeedScreen extends StatefulWidget {
  const PostFeedScreen({super.key});

  @override
  State<PostFeedScreen> createState() => _PostFeedScreenState();
}

class _PostFeedScreenState extends State<PostFeedScreen> {
  List<PostModel> _posts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final posts = await PostService.getFeed();
      if (mounted) setState(() { _posts = posts; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _toggleLike(int index) async {
    final post = _posts[index];
    final wasLiked = post.likedByMe;
    // Optimistic update
    setState(() {
      _posts[index] = post.copyWith(
        likedByMe: !wasLiked,
        likeCount: post.likeCount + (wasLiked ? -1 : 1),
      );
    });
    try {
      if (wasLiked) {
        await PostService.unlikePost(post.id);
      } else {
        await PostService.likePost(post.id);
      }
    } catch (_) {
      // Revert on failure
      if (mounted) {
        setState(() {
          _posts[index] = post;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: _buildAppBar(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFBE1373)))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off_rounded, size: 48, color: Color(0xFFCCCCCC)),
                      const SizedBox(height: 12),
                      Text(_error!, textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF888888))),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _loadPosts,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFBE1373),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('Retry', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                )
              : _posts.isEmpty
                  ? const Center(
                      child: Text('No posts yet. Be the first to share!',
                          style: TextStyle(color: Color(0xFF888888))),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPosts,
                      color: const Color(0xFFBE1373),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: _posts.length,
                        itemBuilder: (context, i) => _buildPostCard(i),
                      ),
                    ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 16, color: Color(0xFF1A1A1A)),
        ),
      ),
      title: Text(
        'Posts',
        style: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF1A1A1A),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined,
              color: Color(0xFF1A1A1A), size: 24),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen())),
        ),
      ],
    );
  }

  Widget _buildPostCard(int i) {
    final post = _posts[i];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
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
          // Author row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFEC407A),
                  backgroundImage: post.author.profileImageUrl != null
                      ? NetworkImage(post.author.profileImageUrl!)
                      : null,
                  child: post.author.profileImageUrl == null
                      ? const Icon(Icons.person, color: Colors.white, size: 22)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author.displayName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '@${post.author.displayName.toLowerCase().replaceAll(' ', '.')}',
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFFBE1373)),
                          ),
                          const Text('  ·  ',
                              style: TextStyle(
                                  color: Color(0xFFCCCCCC), fontSize: 11)),
                          Text(
                            _formatTime(post.createdAt),
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFFAAAAAA)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_horiz,
                    color: Color(0xFF888888), size: 20),
              ],
            ),
          ),
          // Image or placeholder
          if (post.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.zero,
              child: Image.network(
                post.imageUrl!,
                width: double.infinity,
                height: 240,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 240,
                  color: const Color(0xFFF5F5F5),
                  child: const Center(
                      child: Icon(Icons.image_not_supported_outlined,
                          color: Color(0xFFCCCCCC), size: 48)),
                ),
              ),
            )
          else
            Container(
              height: 160,
              width: double.infinity,
              color: const Color(0xFFFFF0F5),
              child: const Center(
                child: Icon(Icons.auto_awesome,
                    color: Color(0xFFFFB6C1), size: 48),
              ),
            ),
          // Poll
          if (post.poll != null)
            PollWidget(
              poll: post.poll!,
              onVoted: (updated) {
                setState(() {
                  _posts[i] = post.copyWith(poll: updated);
                });
              },
            ),
          // Actions row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _toggleLike(i),
                  child: Icon(
                    post.likedByMe ? Icons.favorite : Icons.favorite_outline,
                    color: post.likedByMe
                        ? const Color(0xFFBE1373)
                        : const Color(0xFF888888),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => CommentsScreen(
                      postId: post.id,
                      isAnonymous: false,
                      postContent: post.content,
                    ),
                  )),
                  child: const Icon(Icons.chat_bubble_outline, color: Color(0xFF888888), size: 24),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.share_outlined,
                    color: Color(0xFF888888), size: 24),
                const Spacer(),
                const Icon(Icons.bookmark_outline,
                    color: Color(0xFF888888), size: 24),
              ],
            ),
          ),
          // Likes count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              '${post.likeCount} sparkles',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF333333), height: 1.5),
                children: [
                  TextSpan(
                    text: '${post.author.displayName} ',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(text: post.content),
                ],
              ),
            ),
          ),
          if (post.topicTags.isNotEmpty) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Wrap(
                spacing: 6,
                children: post.topicTags
                    .map((t) => Text(
                          '#$t',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFBE1373),
                            fontWeight: FontWeight.w600,
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
          const SizedBox(height: 8),
          // View comments
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Text(
              'View all ${post.commentCount} comments',
              style: const TextStyle(fontSize: 12, color: Color(0xFFAAAAAA)),
            ),
          ),
        ],
      ),
    );
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
    } catch (_) {
      return '';
    }
  }
}
