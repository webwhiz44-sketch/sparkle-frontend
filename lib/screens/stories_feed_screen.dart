import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/story_model.dart';
import '../services/story_service.dart';
import 'story_detail_screen.dart';
import 'write_story_screen.dart';

class StoriesFeedScreen extends StatefulWidget {
  const StoriesFeedScreen({super.key});

  @override
  State<StoriesFeedScreen> createState() => _StoriesFeedScreenState();
}

class _StoriesFeedScreenState extends State<StoriesFeedScreen> {
  List<StoryModel> _stories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  Future<void> _loadStories() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final stories = await StoryService.getFeed();
      if (mounted) setState(() { _stories = stories; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _toggleLike(int index) async {
    final story = _stories[index];
    final wasLiked = story.likedByMe;
    setState(() {
      _stories[index] = story.copyWith(
        likedByMe: !wasLiked,
        likeCount: story.likeCount + (wasLiked ? -1 : 1),
      );
    });
    try {
      if (wasLiked) {
        await StoryService.unlikeStory(story.id);
      } else {
        await StoryService.likeStory(story.id);
      }
    } catch (_) {
      if (mounted) setState(() => _stories[index] = story);
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
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Color(0xFFF5F5F5), shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF1A1A1A)),
          ),
        ),
        title: Text(
          'Radiant Stories',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            color: const Color(0xFFBE1373),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(context,
                  MaterialPageRoute(fullscreenDialog: true, builder: (_) => const WriteStoryScreen()));
              if (result == true) _loadStories();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFBE1373), Color(0xFFEC407A)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.edit_outlined, color: Colors.white, size: 14),
                  SizedBox(width: 5),
                  Text('Write', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                ],
              ),
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
                        onTap: _loadStories,
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
              : _stories.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('✨', style: TextStyle(fontSize: 52)),
                          const SizedBox(height: 16),
                          Text(
                            'No stories yet.\nBe the first to share yours!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dancingScript(
                              fontSize: 20, color: const Color(0xFFAAAAAA),
                            ),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(context,
                                  MaterialPageRoute(fullscreenDialog: true, builder: (_) => const WriteStoryScreen()));
                              if (result == true) _loadStories();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFFBE1373), Color(0xFFEC407A)]),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Text('Write a Story ✦',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadStories,
                      color: const Color(0xFFBE1373),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        itemCount: _stories.length,
                        itemBuilder: (context, i) => _buildStoryCard(i),
                      ),
                    ),
    );
  }

  Widget _buildStoryCard(int index) {
    final story = _stories[index];
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => StoryDetailScreen(story: story))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: story.coverImageUrl != null
                  ? Image.network(
                      story.coverImageUrl!,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _coverPlaceholder(),
                    )
                  : _coverPlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags
                  if (story.tags.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      children: story.tags.take(3).map((t) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFFB6C1)),
                        ),
                        child: Text('#$t',
                            style: const TextStyle(fontSize: 10, color: Color(0xFFBE1373), fontWeight: FontWeight.w700)),
                      )).toList(),
                    ),
                  const SizedBox(height: 8),
                  // Title
                  Text(
                    story.title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF1A1A1A),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Body preview
                  Text(
                    story.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  // Author + meta row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: const Color(0xFFEC407A),
                        backgroundImage: story.author.profileImageUrl != null
                            ? NetworkImage(story.author.profileImageUrl!)
                            : null,
                        child: story.author.profileImageUrl == null
                            ? const Icon(Icons.person, color: Colors.white, size: 16)
                            : null,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(story.author.displayName,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
                            Text(
                              '${story.readTimeMinutes} min read  ·  ${_formatTime(story.createdAt)}',
                              style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA)),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _toggleLike(index),
                        child: Row(
                          children: [
                            Icon(
                              story.likedByMe ? Icons.favorite : Icons.favorite_outline,
                              color: story.likedByMe ? const Color(0xFFBE1373) : const Color(0xFF888888),
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text('${story.likeCount}',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF666666))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Row(
                        children: [
                          const Icon(Icons.chat_bubble_outline, color: Color(0xFF888888), size: 16),
                          const SizedBox(width: 4),
                          Text('${story.commentCount}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF666666))),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _coverPlaceholder() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A0A12), Color(0xFF6B2D5E)],
        ),
      ),
      child: const Center(
        child: Text('✨', style: TextStyle(fontSize: 48)),
      ),
    );
  }
}
