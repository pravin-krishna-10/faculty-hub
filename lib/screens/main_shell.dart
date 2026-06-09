import 'package:flutter/material.dart';
import '../utils/theme.dart';
import 'home_screen.dart';
import 'saved_screen.dart';
import 'activity_screen.dart';
import 'profile_screen.dart';
import 'post_vacancy_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _screens = [
    HomeScreen(),
    SavedScreen(),
    ActivityScreen(),
    ProfileScreen(),
  ];

  void _onTabTap(int index) {
    if (index == 2) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const PostVacancyScreen()));
      return;
    }
    // Map nav index (0,1,3,4) → screen index (0,1,2,3)
    final screenIndex = index < 2 ? index : index - 1;
    setState(() => _currentIndex = screenIndex);
  }

  int get _navIndex {
    // Map screen index back to nav index (account for skipped + button at index 2)
    return _currentIndex < 2 ? _currentIndex : _currentIndex + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: _onTabTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            activeIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 32, color: AppColors.primary),
            label: 'Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            activeIcon: Icon(Icons.history),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
