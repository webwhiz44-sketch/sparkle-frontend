import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Notification toggles
  bool _notifLikes = true;
  bool _notifComments = true;
  bool _notifFollows = true;
  bool _notifCommunity = true;
  bool _notifEmail = false;
  bool _quietHours = false;

  // Privacy toggles
  bool _privateAccount = false;
  bool _hideFromSearch = false;
  bool _anonymousDefault = false;
  bool _safespaceMode = true;

  // Appearance
  bool _darkMode = false;
  String _fontSize = 'Medium';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: _buildAppBar(context),
      body: ListView(
        children: [
          _buildProfileHeaderWithAccount(),
          const SizedBox(height: 8),
          _buildSection(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            color: const Color(0xFF9C27B0),
            children: [
              _buildToggleTile(
                icon: Icons.favorite_outline,
                label: 'Sparkles (Likes)',
                value: _notifLikes,
                onChanged: (v) => setState(() => _notifLikes = v),
              ),
              _buildToggleTile(
                icon: Icons.chat_bubble_outline,
                label: 'Comments & Responses',
                value: _notifComments,
                onChanged: (v) => setState(() => _notifComments = v),
              ),
              _buildToggleTile(
                icon: Icons.person_add_outlined,
                label: 'New Followers',
                value: _notifFollows,
                onChanged: (v) => setState(() => _notifFollows = v),
              ),
              _buildToggleTile(
                icon: Icons.people_outline,
                label: 'Community Updates',
                value: _notifCommunity,
                onChanged: (v) => setState(() => _notifCommunity = v),
              ),
              _buildToggleTile(
                icon: Icons.mail_outline,
                label: 'Email Notifications',
                value: _notifEmail,
                onChanged: (v) => setState(() => _notifEmail = v),
              ),
              _buildToggleTile(
                icon: Icons.bedtime_outlined,
                label: 'Quiet Hours',
                subtitle: '10 PM – 8 AM',
                value: _quietHours,
                onChanged: (v) => setState(() => _quietHours = v),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildSection(
            icon: Icons.lock_outline,
            title: 'Privacy & Safety',
            color: const Color(0xFF5C6BC0),
            children: [
              _buildToggleTile(
                icon: Icons.visibility_outlined,
                label: 'Private Account',
                subtitle: 'Only followers can see your stories',
                value: _privateAccount,
                onChanged: (v) => setState(() => _privateAccount = v),
              ),
              _buildToggleTile(
                icon: Icons.search_off_outlined,
                label: 'Hide from Search',
                value: _hideFromSearch,
                onChanged: (v) => setState(() => _hideFromSearch = v),
              ),
              _buildToggleTile(
                icon: Icons.face_outlined,
                label: 'Anonymous by Default',
                subtitle: 'Always post without your name',
                value: _anonymousDefault,
                onChanged: (v) => setState(() => _anonymousDefault = v),
              ),
              _buildNavTile(
                icon: Icons.block_outlined,
                label: 'Blocked Users',
                subtitle: '2 blocked',
                onTap: () {},
              ),
              _buildNavTile(
                icon: Icons.message_outlined,
                label: 'Who Can Message Me',
                subtitle: 'Everyone',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildSection(
            icon: Icons.spa_outlined,
            title: 'Sanctuary',
            color: const Color(0xFFE91E8C),
            children: [
              _buildToggleTile(
                icon: Icons.shield_outlined,
                label: 'Safe Space Mode',
                subtitle: 'Filters sensitive content',
                value: _safespaceMode,
                onChanged: (v) => setState(() => _safespaceMode = v),
              ),
              _buildNavTile(
                icon: Icons.interests_outlined,
                label: 'Content Interests',
                subtitle: 'Self Love, Career, Wellness...',
                onTap: () {},
              ),
              _buildNavTile(
                icon: Icons.volume_off_outlined,
                label: 'Muted Keywords',
                subtitle: '5 muted topics',
                onTap: () {},
              ),
              _buildNavTile(
                icon: Icons.home_outlined,
                label: 'Default Tab on Open',
                subtitle: 'Home',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildSection(
            icon: Icons.star_outline,
            title: 'Sparkle Rank',
            color: const Color(0xFFFFAB00),
            children: [
              _buildRankTile(),
              _buildNavTile(
                icon: Icons.info_outline,
                label: 'How Ranking Works',
                onTap: () {},
              ),
              _buildNavTile(
                icon: Icons.emoji_events_outlined,
                label: 'My Badges',
                subtitle: '7 earned',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildSection(
            icon: Icons.palette_outlined,
            title: 'Appearance',
            color: const Color(0xFF26A69A),
            children: [
              _buildToggleTile(
                icon: Icons.dark_mode_outlined,
                label: 'Dark Mode',
                value: _darkMode,
                onChanged: (v) => setState(() => _darkMode = v),
              ),
              _buildOptionTile(
                icon: Icons.format_size_outlined,
                label: 'Font Size',
                value: _fontSize,
                options: ['Small', 'Medium', 'Large'],
                onChanged: (v) => setState(() => _fontSize = v),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildSection(
            icon: Icons.help_outline,
            title: 'Support & Legal',
            color: const Color(0xFF888888),
            children: [
              _buildNavTile(
                icon: Icons.help_center_outlined,
                label: 'Help Center',
                onTap: () {},
              ),
              _buildNavTile(
                icon: Icons.bug_report_outlined,
                label: 'Report a Bug',
                onTap: () {},
              ),
              _buildNavTile(
                icon: Icons.gavel_outlined,
                label: 'Terms of Sanctuary',
                onTap: () {},
              ),
              _buildNavTile(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Glow Policy',
                onTap: () {},
              ),
              _buildNavTile(
                icon: Icons.info_outline,
                label: 'About Sparkle & Spill',
                subtitle: 'Version 1.0.0',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLogoutButton(),
          const SizedBox(height: 32),
        ],
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
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A1A),
            ),
          ),
          Text(
            'Your sanctuary, your rules',
            style: GoogleFonts.dancingScript(
              fontSize: 13,
              color: const Color(0xFFBE1373),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeaderWithAccount() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile info
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFEC407A), Color(0xFF880E4F)],
                    ),
                  ),
                  child: const Icon(Icons.person, color: Colors.white70, size: 32),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Maya Sterling',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const Text(
                        '@maya.sterling',
                        style: TextStyle(fontSize: 13, color: Color(0xFFBE1373)),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD600), Color(0xFFFFAB00)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded, color: Colors.white, size: 12),
                            SizedBox(width: 3),
                            Text(
                              'Gold Sparkle',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Account fields — inside the same card, no separator
          const Divider(height: 1, color: Color(0xFFF5F5F5)),
          _buildNavTile(
            icon: Icons.edit_outlined,
            label: 'Edit Profile',
            subtitle: 'Name, bio, photo, username',
            onTap: () {},
          ),
          _buildNavTile(
            icon: Icons.email_outlined,
            label: 'Change Email',
            subtitle: 'maya.sterling@gmail.com',
            onTap: () {},
          ),
          _buildNavTile(
            icon: Icons.lock_outline,
            label: 'Change Password',
            onTap: () {},
          ),
          _buildNavTile(
            icon: Icons.link_outlined,
            label: 'Linked Accounts',
            subtitle: 'Google connected',
            onTap: () {},
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 17),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required String label,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF666666)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1A1A1A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFFAAAAAA)),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: Color(0xFFCCCCCC), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String label,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF666666)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFFAAAAAA)),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFBE1373),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: const Color(0xFFEEEEEE),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 16),
                ...options.map((opt) => InkWell(
                      onTap: () {
                        onChanged(opt);
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Text(
                              opt,
                              style: TextStyle(
                                fontSize: 15,
                                color: opt == value
                                    ? const Color(0xFFBE1373)
                                    : const Color(0xFF333333),
                                fontWeight: opt == value
                                    ? FontWeight.w800
                                    : FontWeight.normal,
                              ),
                            ),
                            const Spacer(),
                            if (opt == value)
                              const Icon(Icons.check_rounded,
                                  color: Color(0xFFBE1373), size: 20),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF666666)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFFBE1373), fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Color(0xFFCCCCCC), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRankTile() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF9C4), Color(0xFFFFF3E0)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFD600).withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star_rounded,
                    color: Color(0xFFFFAB00), size: 22),
                const SizedBox(width: 8),
                const Text(
                  'Gold Sparkle',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const Spacer(),
                const Text(
                  '7,240 pts',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFFAB00),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: 0.72,
                backgroundColor: const Color(0xFFEEEEEE),
                valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFFAB00)),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '2,760 pts to Platinum ✨',
              style: TextStyle(fontSize: 11, color: Color(0xFF888888)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: Text(
                    'Leave the Sanctuary?',
                    style: GoogleFonts.playfairDisplay(
                        fontWeight: FontWeight.w900),
                  ),
                  content: const Text(
                    'Are you sure you want to sign out?',
                    style: TextStyle(color: Color(0xFF666666)),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Stay',
                          style: TextStyle(color: Color(0xFF888888))),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context); // close dialog
                        await AuthService.logout();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (_) => false,
                          );
                        }
                      },
                      child: const Text('Sign Out',
                          style: TextStyle(
                              color: Color(0xFFBE1373),
                              fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              );
            },
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFB6C1), width: 1.5),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded,
                      color: Color(0xFFBE1373), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFBE1373),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {},
            child: const Text(
              'Delete Account',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFFCCCCCC),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
