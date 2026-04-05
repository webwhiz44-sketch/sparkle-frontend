import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _allNotifications = [
    {
      'type': 'like',
      'avatar': const Color(0xFFEC407A),
      'name': 'Zara M.',
      'action': 'sparkled your story',
      'content': '"The day I chose myself over everyone else"',
      'time': '2m ago',
      'read': false,
    },
    {
      'type': 'comment',
      'avatar': const Color(0xFF9C27B0),
      'name': 'Priya K.',
      'action': 'responded to your story',
      'content': '"This hit different. I needed to read this today 💕"',
      'time': '15m ago',
      'read': false,
    },
    {
      'type': 'follow',
      'avatar': const Color(0xFF26A69A),
      'name': 'Jade L.',
      'action': 'joined your circle',
      'content': '',
      'time': '1h ago',
      'read': false,
    },
    {
      'type': 'mention',
      'avatar': const Color(0xFFFF7043),
      'name': 'Aisha B.',
      'action': 'mentioned you in',
      'content': '#CareerSpill community',
      'time': '2h ago',
      'read': true,
    },
    {
      'type': 'community',
      'avatar': const Color(0xFFBE1373),
      'name': '#MentalHealthSanctuary',
      'action': 'Weekly meditation session starting in',
      'content': '2 hours. Bring your crystals! 💜',
      'time': '3h ago',
      'read': true,
    },
    {
      'type': 'like',
      'avatar': const Color(0xFF5C6BC0),
      'name': 'Sofia R.',
      'action': 'sparkled your story',
      'content': '"How I negotiated a 40% salary raise"',
      'time': '5h ago',
      'read': true,
    },
    {
      'type': 'comment',
      'avatar': const Color(0xFFEF5350),
      'name': 'Nina W.',
      'action': 'responded to your story',
      'content': '"Bookmarked forever. Real radiance comes from within 🌸"',
      'time': '8h ago',
      'read': true,
    },
    {
      'type': 'follow',
      'avatar': const Color(0xFF66BB6A),
      'name': 'Layla H.',
      'action': 'joined your circle',
      'content': '',
      'time': 'Yesterday',
      'read': true,
    },
    {
      'type': 'milestone',
      'avatar': const Color(0xFFFFD600),
      'name': 'Sparkle & Spill',
      'action': 'Your story reached',
      'content': '1,000 sparkles! You\'re glowing 🌟',
      'time': 'Yesterday',
      'read': true,
    },
    {
      'type': 'community',
      'avatar': const Color(0xFF8D6E63),
      'name': '#CareerSpill',
      'action': 'New post trending in your community:',
      'content': '"Salary transparency — are we ready?"',
      'time': '2 days ago',
      'read': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _unread =>
      _allNotifications.where((n) => n['read'] == false).toList();

  List<Map<String, dynamic>> get _mentions => _allNotifications
      .where((n) => n['type'] == 'mention' || n['type'] == 'comment')
      .toList();

  void _markAllRead() {
    setState(() {
      for (final n in _allNotifications) {
        n['read'] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _unread.length;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: _buildAppBar(context, unreadCount),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNotificationList(_allNotifications),
                _buildNotificationList(_unread, emptyLabel: 'You\'re all caught up ✨'),
                _buildNotificationList(_mentions, emptyLabel: 'No mentions yet 💬'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, int unreadCount) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 16, color: Color(0xFF1A1A1A)),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A1A),
            ),
          ),
          if (unreadCount > 0)
            Text(
              '$unreadCount new sparkles waiting',
              style: GoogleFonts.dancingScript(
                fontSize: 13,
                color: const Color(0xFFBE1373),
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
      actions: [
        if (unreadCount > 0)
          TextButton(
            onPressed: _markAllRead,
            child: const Text(
              'Mark all read',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFFBE1373),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFFBE1373),
        unselectedLabelColor: const Color(0xFF888888),
        indicatorColor: const Color(0xFFBE1373),
        indicatorWeight: 2.5,
        labelStyle:
            const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        tabs: [
          const Tab(text: 'All'),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Unread'),
                if (_unread.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBE1373),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_unread.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Tab(text: 'Mentions'),
        ],
      ),
    );
  }

  Widget _buildNotificationList(List<Map<String, dynamic>> items,
      {String emptyLabel = ''}) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_none_outlined,
                size: 56, color: Color(0xFFDDDDDD)),
            const SizedBox(height: 12),
            Text(
              emptyLabel,
              style: GoogleFonts.dancingScript(
                fontSize: 20,
                color: const Color(0xFFAAAAAA),
              ),
            ),
          ],
        ),
      );
    }

    // Group by time
    final todayItems =
        items.where((n) => !['Yesterday', '2 days ago'].contains(n['time'])).toList();
    final yesterdayItems =
        items.where((n) => n['time'] == 'Yesterday').toList();
    final olderItems =
        items.where((n) => n['time'] == '2 days ago').toList();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (todayItems.isNotEmpty) ...[
          _buildSectionHeader('Today'),
          ...todayItems.map((n) => _buildNotificationTile(n)),
        ],
        if (yesterdayItems.isNotEmpty) ...[
          _buildSectionHeader('Yesterday'),
          ...yesterdayItems.map((n) => _buildNotificationTile(n)),
        ],
        if (olderItems.isNotEmpty) ...[
          _buildSectionHeader('Earlier'),
          ...olderItems.map((n) => _buildNotificationTile(n)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Color(0xFFAAAAAA),
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildNotificationTile(Map<String, dynamic> n) {
    final isUnread = n['read'] == false;
    return GestureDetector(
      onTap: () {
        setState(() => n['read'] = true);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUnread ? const Color(0xFFFFF0F5) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isUnread
              ? Border.all(color: const Color(0xFFFFB6C1), width: 1)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar + icon badge
            Stack(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: n['avatar'] as Color,
                  child: Text(
                    (n['name'] as String)[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _iconBgColor(n['type'] as String),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Icon(
                      _notifIcon(n['type'] as String),
                      size: 11,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF333333),
                          height: 1.4),
                      children: [
                        TextSpan(
                          text: '${n['name']} ',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A1A)),
                        ),
                        TextSpan(text: n['action'] as String),
                        if ((n['content'] as String).isNotEmpty) ...[
                          const TextSpan(text: ' '),
                          TextSpan(
                            text: n['content'] as String,
                            style: TextStyle(
                              color: const Color(0xFFBE1373),
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n['time'] as String,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFFAAAAAA)),
                  ),
                ],
              ),
            ),
            // Unread dot
            if (isUnread)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFFBE1373),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _notifIcon(String type) {
    switch (type) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.chat_bubble;
      case 'follow':
        return Icons.person_add;
      case 'mention':
        return Icons.alternate_email;
      case 'community':
        return Icons.people;
      case 'milestone':
        return Icons.star;
      default:
        return Icons.notifications;
    }
  }

  Color _iconBgColor(String type) {
    switch (type) {
      case 'like':
        return const Color(0xFFBE1373);
      case 'comment':
        return const Color(0xFF9C27B0);
      case 'follow':
        return const Color(0xFF26A69A);
      case 'mention':
        return const Color(0xFFFF7043);
      case 'community':
        return const Color(0xFF5C6BC0);
      case 'milestone':
        return const Color(0xFFFFAB00);
      default:
        return const Color(0xFF888888);
    }
  }
}
