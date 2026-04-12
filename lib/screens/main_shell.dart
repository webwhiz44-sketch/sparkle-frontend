import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'communities_screen.dart';
import 'spill_story_screen.dart';
import 'spill_feed_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';
import 'create_post_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // 0=Home, 1=Clubs, 2=Spill Feed, 3=Profile
  int _currentIndex = 0;

  // visual position → screen index in IndexedStack
  // pos 0=Home→0, pos 1=Clubs→1, pos 2=FAB(null), pos 3=Spill→2, pos 4=Me→3
  static const _visualToScreen = {0: 0, 1: 1, 3: 2, 4: 3};

  void _onNavTap(int visualPos, BuildContext context) {
    final screenIdx = _visualToScreen[visualPos];
    if (screenIdx != null) setState(() => _currentIndex = screenIdx);
  }

  // Reverse map: screen index → visual position (for highlighting)
  int get _currentVisual {
    if (_currentIndex == 0) return 0;
    if (_currentIndex == 1) return 1;
    if (_currentIndex == 2) return 3;
    if (_currentIndex == 3) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomeScreen(),
          CommunitiesScreen(),
          SpillFeedScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
      floatingActionButton: _buildFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildFab(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => const CreatePostScreen(),
          ),
        );
        if (result == true) HomeScreen.refreshCallback?.call();
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFBE1373), Color(0xFFEC407A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFBE1373).withOpacity(0.45),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final items = <Map<String, dynamic>?>[
      {'icon': Icons.auto_awesome_outlined, 'activeIcon': Icons.auto_awesome, 'label': 'Home'},
      {'icon': Icons.people_outline, 'activeIcon': Icons.people, 'label': 'Communities'},
      null, // FAB slot
      {'icon': Icons.water_drop_outlined, 'activeIcon': Icons.water_drop, 'label': 'Spill', 'chip': true},
      {'icon': Icons.person_outline, 'activeIcon': Icons.person, 'label': 'Me'},
    ];

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: Colors.white,
      elevation: 16,
      child: SizedBox(
        height: 62,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (i) {
            if (items[i] == null) return const SizedBox(width: 56);
            final item = items[i]!;
            final isSelected = _currentVisual == i;

            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _onNavTap(i, context),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isSelected
                          ? item['activeIcon'] as IconData
                          : item['icon'] as IconData,
                      size: 24,
                      color: isSelected
                          ? const Color(0xFFBE1373)
                          : const Color(0xFF888888),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item['label'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.normal,
                        color: isSelected
                            ? const Color(0xFFBE1373)
                            : const Color(0xFF888888),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
