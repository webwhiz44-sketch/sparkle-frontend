import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'community_detail_screen.dart';
import 'notifications_screen.dart';
import '../models/community_model.dart';
import '../services/community_service.dart';
import '../services/api_client.dart';

class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {
  final _searchController = TextEditingController();
  List<CommunityModel> _communities = [];
  List<CommunityModel> _filtered = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCommunities();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearch);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _communities
          : _communities.where((c) => c.name.toLowerCase().contains(q)).toList();
    });
  }

  Future<void> _showCreateCommunitySheet() async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    String selectedCategory = 'GENERAL';
    bool isPosting = false;

    final categories = [
      {'value': 'CAREER', 'label': 'Career 💼'},
      {'value': 'RELATIONSHIPS', 'label': 'Relationships 💕'},
      {'value': 'MENTAL_HEALTH', 'label': 'Mental Health 💜'},
      {'value': 'PARENTING', 'label': 'Parenting 🌸'},
      {'value': 'LIFESTYLE', 'label': 'Lifestyle ✨'},
      {'value': 'HEALTH', 'label': 'Health 🌿'},
      {'value': 'GENERAL', 'label': 'General 💫'},
    ];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheet) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20, right: 20, top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDDDDD),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Create a Community',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22, fontWeight: FontWeight.w900,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    'Build your tribe ✨',
                    style: GoogleFonts.dancingScript(
                      fontSize: 16, color: const Color(0xFFBE1373),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Name
                  const Text('COMMUNITY NAME',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                          color: Color(0xFF555555), letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    maxLength: 150,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
                    decoration: InputDecoration(
                      hintText: 'e.g. GlowUpGirls',
                      hintStyle: const TextStyle(color: Color(0xFFBBBBBB)),
                      filled: true, fillColor: const Color(0xFFF5F5F5),
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFBE1373), width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text('DESCRIPTION (optional)',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                          color: Color(0xFF555555), letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    maxLength: 300,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
                    decoration: InputDecoration(
                      hintText: 'What is this community about?',
                      hintStyle: const TextStyle(color: Color(0xFFBBBBBB)),
                      filled: true, fillColor: const Color(0xFFF5F5F5),
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFBE1373), width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category
                  const Text('CATEGORY',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                          color: Color(0xFF555555), letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCategory,
                        isExpanded: true,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
                        onChanged: (val) {
                          if (val != null) setSheet(() => selectedCategory = val);
                        },
                        items: categories.map((c) => DropdownMenuItem(
                          value: c['value'],
                          child: Text(c['label']!),
                        )).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Create button
                  isPosting
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFFBE1373)))
                      : GestureDetector(
                          onTap: () async {
                            final name = nameController.text.trim();
                            if (name.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Community name is required')),
                              );
                              return;
                            }
                            setSheet(() => isPosting = true);
                            try {
                              await ApiClient.post('/api/communities', {
                                'name': name,
                                if (descController.text.trim().isNotEmpty)
                                  'description': descController.text.trim(),
                                'category': selectedCategory,
                              });
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Community created! ✨'),
                                    backgroundColor: Color(0xFFBE1373),
                                  ),
                                );
                                _loadCommunities(); // Refresh list
                              }
                            } on ApiException catch (e) {
                              setSheet(() => isPosting = false);
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.message),
                                      backgroundColor: const Color(0xFFE53935)),
                                );
                              }
                            } catch (_) {
                              setSheet(() => isPosting = false);
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Failed to create community. Try again.'),
                                      backgroundColor: Color(0xFFE53935)),
                                );
                              }
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            height: 54,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFBE1373), Color(0xFFEC407A)],
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFBE1373).withOpacity(0.35),
                                  blurRadius: 12, offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'CREATE COMMUNITY ✦',
                                style: TextStyle(color: Colors.white, fontSize: 14,
                                    fontWeight: FontWeight.bold, letterSpacing: 1.5),
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Future<void> _loadCommunities() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final list = await CommunityService.getCommunities();
      if (mounted) setState(() { _communities = list; _filtered = list; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  // Category → emoji mapping
  String _categoryEmoji(String? category) {
    switch (category) {
      case 'CAREER': return '💼';
      case 'MENTAL_HEALTH': return '💜';
      case 'RELATIONSHIPS': return '💕';
      case 'PARENTING': return '🌸';
      case 'LIFESTYLE': return '✨';
      case 'HEALTH': return '🌿';
      default: return '💫';
    }
  }

  // Category → color mapping
  Color _categoryColor(String? category) {
    switch (category) {
      case 'CAREER': return const Color(0xFFBE1373);
      case 'MENTAL_HEALTH': return const Color(0xFF7B1FA2);
      case 'RELATIONSHIPS': return const Color(0xFFEC407A);
      case 'PARENTING': return const Color(0xFFFF7043);
      case 'LIFESTYLE': return const Color(0xFF26A69A);
      default: return const Color(0xFFBE1373);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: _buildAppBar(),
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
                        onTap: _loadCommunities,
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
              : RefreshIndicator(
                  onRefresh: _loadCommunities,
                  color: const Color(0xFFBE1373),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        _buildSearchAndCreate(),
                        const SizedBox(height: 16),
                        if (_filtered.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(
                              child: Text('No communities found',
                                  style: TextStyle(color: Color(0xFF888888))),
                            ),
                          )
                        else
                          ..._filtered.asMap().entries.map((e) => Padding(
                            padding: EdgeInsets.only(
                              bottom: e.key < _filtered.length - 1 ? 12 : 100,
                            ),
                            child: _buildCommunityCard(e.value),
                          )),
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
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen())),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find Your',
            style: GoogleFonts.playfairDisplay(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF1A1A1A),
              height: 1.1,
            ),
          ),
          Text(
            'Tribe',
            style: GoogleFonts.playfairDisplay(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              color: const Color(0xFFBE1373),
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Where every whisper finds a home\nand every glow-up is celebrated.',
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFF888888),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSearchAndCreate() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Search bar
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
              decoration: const InputDecoration(
                hintText: 'Search for a secret or a sanctuary...',
                hintStyle: TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
                prefixIcon:
                    Icon(Icons.search, color: Color(0xFFAAAAAA), size: 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Create Community button
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: _showCreateCommunitySheet,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFBE1373),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.add_circle_outline,
                        color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Create Community',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityCard(CommunityModel community) {
    final emoji = _categoryEmoji(community.category);
    final color = _categoryColor(community.category);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CommunityDetailScreen(
            communityId: community.id,
            name: community.name,
            emoji: emoji,
            tag: '#${community.name}',
            color: color,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
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
                Text(emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '#${community.name}',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Text(
                    community.category ?? 'GENERAL',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: color),
                  ),
                ),
              ],
            ),
            if (community.description != null && community.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                community.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Color(0xFF666666), height: 1.5),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatChip('${community.memberCount} Members'),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Join', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFB6C1), width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFFBE1373),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStackedAvatars(List<Color> colors, String overflow) {
    return SizedBox(
      height: 32,
      width: 110,
      child: Stack(
        children: [
          ...List.generate(
            colors.length,
            (i) => Positioned(
              left: i * 20.0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors[i],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ),
          Positioned(
            left: colors.length * 20.0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF9C27B0),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  overflow,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
