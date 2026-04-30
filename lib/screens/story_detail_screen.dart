import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/story_model.dart';
import '../services/story_service.dart';
import 'comments_screen.dart';

class StoryDetailScreen extends StatefulWidget {
  final StoryModel story;

  const StoryDetailScreen({super.key, required this.story});

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  late StoryModel _story;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _story = widget.story;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _toggleLike() async {
    final wasLiked = _story.likedByMe;
    setState(() {
      _story = _story.copyWith(
        likedByMe: !wasLiked,
        likeCount: _story.likeCount + (wasLiked ? -1 : 1),
      );
    });
    try {
      if (wasLiked) {
        await StoryService.unlikeStory(_story.id);
      } else {
        await StoryService.likeStory(_story.id);
      }
    } catch (_) {
      if (mounted) setState(() => _story = widget.story);
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
      if (diff.inDays < 30) return '${diff.inDays}d ago';
      return '${(diff.inDays / 30).floor()}mo ago';
    } catch (_) { return ''; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                _buildSliverAppBar(context),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMeta(),
                      _buildTitle(),
                      _buildAuthorRow(),
                      const Divider(color: Color(0xFFF0F0F0), height: 1),
                      _buildBody(),
                      if (_story.tags.isNotEmpty) _buildTags(),
                      const Divider(color: Color(0xFFF0F0F0), height: 1),
                      _buildEngagementBar(),
                      const Divider(color: Color(0xFFF0F0F0), height: 1),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildCommentBar(context),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: const Color(0xFF1A0A12),
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: _story.coverImageUrl != null
            ? Image.network(
                _story.coverImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _coverGradient(),
              )
            : _coverGradient(),
      ),
    );
  }

  Widget _coverGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A0A12), Color(0xFF3D1535), Color(0xFF6B2D5E)],
        ),
      ),
      child: const Center(child: Text('✨', style: TextStyle(fontSize: 60))),
    );
  }

  Widget _buildMeta() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F5),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFFFB6C1)),
            ),
            child: const Text('RADIANT STORY',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900,
                    color: Color(0xFFBE1373), letterSpacing: 1)),
          ),
          const SizedBox(width: 10),
          Text(
            '${_story.readTimeMinutes} min read',
            style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA)),
          ),
          const SizedBox(width: 6),
          const Text('·', style: TextStyle(color: Color(0xFFCCCCCC))),
          const SizedBox(width: 6),
          Text(_formatTime(_story.createdAt),
              style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA))),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Text(
        _story.title,
        style: GoogleFonts.playfairDisplay(
          fontSize: 26,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          color: const Color(0xFF1A1A1A),
          height: 1.3,
        ),
      ),
    );
  }

  Widget _buildAuthorRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFEC407A),
            backgroundImage: _story.author.profileImageUrl != null
                ? NetworkImage(_story.author.profileImageUrl!)
                : null,
            child: _story.author.profileImageUrl == null
                ? const Icon(Icons.person, color: Colors.white, size: 22)
                : null,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_story.author.displayName,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
              Text('@${_story.author.displayName.toLowerCase().replaceAll(' ', '.')}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFFBE1373))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Text(
        _story.body,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF333333),
          height: 1.9,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildTags() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _story.tags.map((t) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0F5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFB6C1)),
          ),
          child: Text('#$t',
              style: const TextStyle(fontSize: 12, color: Color(0xFFBE1373), fontWeight: FontWeight.w600)),
        )).toList(),
      ),
    );
  }

  Widget _buildEngagementBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: _toggleLike,
            child: Row(
              children: [
                Icon(
                  _story.likedByMe ? Icons.favorite : Icons.favorite_outline,
                  color: _story.likedByMe ? const Color(0xFFBE1373) : const Color(0xFF888888),
                  size: 24,
                ),
                const SizedBox(width: 6),
                Text('${_story.likeCount}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _story.likedByMe ? const Color(0xFFBE1373) : const Color(0xFF666666),
                    )),
              ],
            ),
          ),
          const SizedBox(width: 20),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => CommentsScreen(
                postId: _story.id,
                isAnonymous: false,
                postContent: _story.title,
              ),
            )),
            child: Row(
              children: [
                const Icon(Icons.chat_bubble_outline, color: Color(0xFF888888), size: 22),
                const SizedBox(width: 6),
                Text('${_story.commentCount}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF666666))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentBar(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => CommentsScreen(
            postId: _story.id,
            isAnonymous: false,
            postContent: _story.title,
          ),
        )),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Row(
              children: [
                Text('Add your sparkle to this story...',
                    style: TextStyle(fontSize: 13, color: Color(0xFFBBBBBB))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
