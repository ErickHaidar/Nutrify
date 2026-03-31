import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'history_screen.dart';

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
    // If switching to Home tab, trigger a refresh
    if (index == 0) {
      _homeKey.currentState?.loadDailyData();
    }
  }

  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(key: _homeKey),
      const HistoryScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF433D67),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF2D2A4A),
        selectedItemColor: const Color(0xFFFFCC80),
        unselectedItemColor: Colors.white38,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Kalori',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
