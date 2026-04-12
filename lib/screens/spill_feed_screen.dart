import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/anonymous_post_model.dart';
import '../services/anonymous_post_service.dart';
import 'spill_story_screen.dart';
import 'comments_screen.dart';

class SpillFeedScreen extends StatefulWidget {
  const SpillFeedScreen({super.key});

  @override
  State<SpillFeedScreen> createState() => _SpillFeedScreenState();
}

class _SpillFeedScreenState extends State<SpillFeedScreen> {
  List<AnonymousPostModel> _posts = [];
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
      final posts = await AnonymousPostService.getFeed();
      if (mounted) setState(() { _posts = posts; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _toggleLike(int index) async {
    final post = _posts[index];
    final wasLiked = post.likedByMe;
    setState(() {
      _posts[index] = post.copyWith(
        likedByMe: !wasLiked,
        likeCount: post.likeCount + (wasLiked ? -1 : 1),
      );
    });
    try {
      if (wasLiked) {
        await AnonymousPostService.unlikePost(post.id);
      } else {
        await AnonymousPostService.likePost(post.id);
      }
    } catch (_) {
      if (mounted) setState(() => _posts[index] = post);
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Text(
              'Spill ',
              style: GoogleFonts.dancingScript(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFBE1373),
              ),
            ),
            Text(
              'the Tea',
              style: GoogleFonts.dancingScript(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF9C27B0),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFB6C1)),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_outline, size: 12, color: Color(0xFFBE1373)),
                SizedBox(width: 4),
                Text('Anonymous', style: TextStyle(fontSize: 11, color: Color(0xFFBE1373), fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
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
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('💧', style: TextStyle(fontSize: 52)),
                          const SizedBox(height: 16),
                          Text(
                            'No spills yet...\nBe the first to spill the tea!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dancingScript(
                              fontSize: 20, color: const Color(0xFFAAAAAA),
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPosts,
                      color: const Color(0xFFBE1373),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                        itemCount: _posts.length,
                        itemBuilder: (context, i) => _buildSpillCard(i),
                      ),
                    ),
      floatingActionButton: GestureDetector(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => const SpillStoryScreen(),
            ),
          );
          if (result == true) _loadPosts();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_outlined, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'Spill the Tea ✦',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpillCard(int index) {
    final post = _posts[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
          // Anonymous header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1A0A12), Color(0xFF6B2D5E)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('👤', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Anonymous Sparkle',
                        style: GoogleFonts.dancingScript(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        _formatTime(post.createdAt),
                        style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFB6C1)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lock_outline, size: 11, color: Color(0xFFBE1373)),
                      SizedBox(width: 3),
                      Text('anon', style: TextStyle(fontSize: 10, color: Color(0xFFBE1373), fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Image (if present)
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  post.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          // Content
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                post.content,
                style: const TextStyle(fontSize: 14, color: Color(0xFF333333), height: 1.6),
              ),
            ),
          if (post.topicTags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 6,
                children: post.topicTags.map((t) => Text(
                  '#$t',
                  style: const TextStyle(fontSize: 12, color: Color(0xFFBE1373), fontWeight: FontWeight.w600),
                )).toList(),
              ),
            ),
          ],
          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _toggleLike(index),
                  child: Row(
                    children: [
                      Icon(
                        post.likedByMe ? Icons.favorite : Icons.favorite_outline,
                        color: post.likedByMe ? const Color(0xFFBE1373) : const Color(0xFF888888),
                        size: 22,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likeCount}',
                        style: TextStyle(
                          fontSize: 13,
                          color: post.likedByMe ? const Color(0xFFBE1373) : const Color(0xFF666666),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => CommentsScreen(
                      postId: post.id,
                      isAnonymous: true,
                      postContent: post.content,
                    ),
                  )),
                  child: const Icon(Icons.chat_bubble_outline, color: Color(0xFF888888), size: 20),
                ),
                const SizedBox(width: 4),
                Text('${post.commentCount}', style: const TextStyle(fontSize: 13, color: Color(0xFF666666))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
