import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_client.dart';
import 'dart:convert';

class CommentsScreen extends StatefulWidget {
  final int postId;
  final bool isAnonymous;
  final String postContent;

  const CommentsScreen({
    super.key,
    required this.postId,
    this.isAnonymous = false,
    required this.postContent,
  });

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _commentController = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;
  bool _isSending = false;

  String get _basePath => widget.isAnonymous
      ? '/api/anonymous-posts/${widget.postId}/comments'
      : '/api/posts/${widget.postId}/comments';

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() { _isLoading = true; });
    try {
      final response = await ApiClient.get('$_basePath?page=0&size=50');
      final data = ApiClient.parseResponse(response);
      final List content = data['content'] ?? [];
      if (mounted) {
        setState(() {
          _comments = content.map((e) => Map<String, dynamic>.from(e)).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    setState(() => _isSending = true);
    try {
      await ApiClient.post(_basePath, {'content': text});
      _commentController.clear();
      await _loadComments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: const Color(0xFFE53935)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  String _formatTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
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
          'Comments',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20, fontWeight: FontWeight.w900, color: const Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: Column(
        children: [
          // Original post snippet
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 3, height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBE1373),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.postContent,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF555555), height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Comments list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFBE1373)))
                : _comments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('💬', style: TextStyle(fontSize: 40)),
                            const SizedBox(height: 12),
                            Text(
                              'No comments yet\nBe the first to comment!',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.dancingScript(fontSize: 18, color: const Color(0xFFAAAAAA)),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _comments.length,
                        itemBuilder: (context, i) => _buildCommentCard(_comments[i]),
                      ),
          ),
          // Input bar
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              left: 16, right: 12, top: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    maxLines: null,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 14),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFFBE1373), width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendComment(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _isSending ? null : _sendComment,
                  child: Container(
                    width: 44, height: 44,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xFFBE1373), Color(0xFFEC407A)]),
                      shape: BoxShape.circle,
                    ),
                    child: _isSending
                        ? const Center(child: SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                        : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(Map<String, dynamic> comment) {
    final author = comment['author'] as Map<String, dynamic>? ?? {};
    final displayName = author['displayName'] as String? ?? 'User';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFEC407A),
                backgroundImage: author['profileImageUrl'] != null
                    ? NetworkImage(author['profileImageUrl'] as String)
                    : null,
                child: author['profileImageUrl'] == null
                    ? Text(displayName[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
                    Text(_formatTime(comment['createdAt'] as String?),
                        style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA))),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.favorite_outline, size: 14, color: Color(0xFF888888)),
                  const SizedBox(width: 3),
                  Text('${comment['likeCount'] ?? 0}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            comment['content'] as String? ?? '',
            style: const TextStyle(fontSize: 14, color: Color(0xFF333333), height: 1.5),
          ),
        ],
      ),
    );
  }
}
