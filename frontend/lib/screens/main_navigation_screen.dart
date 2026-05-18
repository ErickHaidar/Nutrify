import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'history_screen.dart';
import 'community_screen.dart';
import 'package:nutrify/constants/colors.dart';
import 'package:nutrify/utils/locale/app_strings.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nutrify/presentation/home/store/language/language_store.dart';
import 'package:nutrify/di/service_locator.dart';
import 'package:nutrify/domain/repository/profile/profile_repository.dart';
import 'package:nutrify/data/sharedpref/shared_preference_helper.dart';
import 'onboarding_screen.dart';

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
      _communityKey.currentState?.refreshPosts();
    }
    if (index == 3) {
      _profileKey.currentState?.loadProfile();
      _profileKey.currentState?.refreshSocialData();
      _profileKey.currentState?.switchToGeneralTab();
    }
  }

  void _switchToProfileTab() {
    setState(() => _selectedIndex = 3);
    _profileKey.currentState?.loadProfile();
    _profileKey.currentState?.refreshSocialData();
    _profileKey.currentState?.switchToSocialTab();
  }

  void _switchToProfileAndCreatePost() {
    setState(() => _selectedIndex = 2);
    _communityKey.currentState?.navigateToAddPost();
  }

  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();
  final GlobalKey<HistoryScreenState> _historyKey = GlobalKey<HistoryScreenState>();

  final GlobalKey<CommunityScreenState> _communityKey =
      GlobalKey<CommunityScreenState>();
  final GlobalKey<ProfileScreenState> _profileKey =
      GlobalKey<ProfileScreenState>();

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(key: _homeKey),
      HistoryScreen(key: _historyKey),
      CommunityScreen(key: _communityKey, onNavigateToProfile: _switchToProfileTab),
      ProfileScreen(key: _profileKey, onNavigateToCreatePost: _switchToProfileAndCreatePost),
    ];
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOnboarding();
    });
  }

  Future<void> _checkOnboarding() async {
    try {
      final sharedPrefs = getIt<SharedPreferenceHelper>();
      final profileApi = getIt<ProfileRepository>();
      
      // Ambil profile dengan forceRefresh: true agar tidak salah mengenali user lama/baru
      final profile = await profileApi.getProfile(forceRefresh: true);
      final isProfileIncomplete = profile == null || 
                                  profile.age == 0 || 
                                  profile.weight == 0 || 
                                  profile.height == 0;
                                  
      if (!isProfileIncomplete) {
        // User lama yang profilnya sudah lengkap. 
        // Tandai onboarding sudah dilihat agar tidak pernah muncul.
        await sharedPrefs.saveHasSeenOnboarding(true);
        return; // Tidak perlu munculkan onboarding atau lengkapi profil
      }

      // User baru (atau lama yang belum lengkap)
      if (!mounted) return;
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
      if (result == true) {
        _homeKey.currentState?.loadDailyData(forceRefresh: true);
      }
    } catch (e) {
      // Abaikan jika gagal koneksi
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageStore = getIt<LanguageStore>();
    return Observer(
      builder: (_) {
        final _ = languageStore.locale;
        return Scaffold(
          backgroundColor: NutrifyTheme.background,
          body: IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: NutrifyTheme.darkCard,
            selectedItemColor: NutrifyTheme.accentOrange,
            unselectedItemColor: NutrifyTheme.background.withValues(alpha: 0.5),
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
      },
    );
  }
}
