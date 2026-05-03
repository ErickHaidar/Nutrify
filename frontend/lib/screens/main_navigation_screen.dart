import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'history_screen.dart';
import 'komunitas_screen.dart';
import 'package:nutrify/constants/colors.dart';
import 'package:nutrify/utils/locale/app_strings.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      _homeKey.currentState?.loadDailyData();
    }
    if (index == 1) {
      _historyKey.currentState?.refreshData();
    }
    if (index == 2) {
      _komunitasKey.currentState?.refreshPosts();
    }
    if (index == 3) {
      _profileKey.currentState?.loadProfile();
      _profileKey.currentState?.switchToUmumTab();
    }
  }

  void _switchToProfileTab() {
    setState(() => _selectedIndex = 3);
    _profileKey.currentState?.loadProfile();
    _profileKey.currentState?.switchToSocialTab();
  }

  void _switchToProfileAndCreatePost() {
    setState(() => _selectedIndex = 2);
    _komunitasKey.currentState?.navigateToAddPost();
  }

  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();
  final GlobalKey<HistoryScreenState> _historyKey = GlobalKey<HistoryScreenState>();
  final GlobalKey<KomunitasScreenState> _komunitasKey =
      GlobalKey<KomunitasScreenState>();
  final GlobalKey<ProfileScreenState> _profileKey =
      GlobalKey<ProfileScreenState>();

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(key: _homeKey),
      HistoryScreen(key: _historyKey),
      KomunitasScreen(key: _komunitasKey, onNavigateToProfile: _switchToProfileTab),
      ProfileScreen(key: _profileKey, onNavigateToCreatePost: _switchToProfileAndCreatePost),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NutrifyTheme.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: NutrifyTheme.darkCard,
        selectedItemColor: NutrifyTheme.accentOrange,
        unselectedItemColor: NutrifyTheme.background.withOpacity(0.5),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.restaurant),
            label: AppStrings.navCalorie,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history),
            label: AppStrings.navHistory,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.forum),
            label: AppStrings.navCommunity,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: AppStrings.navProfile,
          ),
        ],
      ),
    );
  }
}
