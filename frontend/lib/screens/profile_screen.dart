import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutrify/di/service_locator.dart';
import 'package:nutrify/presentation/login/store/login_store.dart';
import 'package:nutrify/utils/routes/routes.dart';
import 'package:nutrify/constants/assets.dart';
import 'edit_profile_screen.dart';
import 'change_goal_screen.dart';
import '../services/profile_api_service.dart';
import '../services/notification_service.dart';
import '../constants/colors.dart';
import 'package:nutrify/presentation/login/store/login_store.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final _profileApiService = ProfileApiService();
  ApiProfileData? _profile;
  bool _isLoading = true;
  String? _profileImagePath;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _profileImagePath = getIt<SharedPreferences>().getString('profile_image');
    _notificationsEnabled = getIt<SharedPreferences>().getBool('notifications_enabled') ?? true;
    loadProfile();
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = getIt<SharedPreferences>();
    final notificationService = getIt<NotificationService>();

    if (value) {
      // Show intent to enable immediately for better UX
      setState(() => _notificationsEnabled = true);
      
      final granted = await notificationService.requestPermissions();
      if (granted) {
        await prefs.setBool('notifications_enabled', true);
        await notificationService.scheduleMealReminders();
        
        // Step 1: Push Registration (Token to Server)
        await notificationService.registerPushNotifications();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notifikasi pengingat makan diaktifkan')),
          );
        }
      } else {
        // Revert if denied
        setState(() => _notificationsEnabled = false);
        await prefs.setBool('notifications_enabled', false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Izin notifikasi ditolak. Silakan aktifkan di pengaturan sistem.')),
          );
        }
      }
    } else {
      setState(() => _notificationsEnabled = false);
      await prefs.setBool('notifications_enabled', false);
      await notificationService.cancelAllNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifikasi pengingat makan dinonaktifkan')),
        );
      }
    }
  }

  Future<void> loadProfile() async {
    try {
      final profile = await _profileApiService.getProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.cream,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // 1. Logo & Brand
              Row(
                children: [
                  Image.asset(Assets.nutrifyLogo, height: 40, width: 40),
                  Text(
                    'Nutrify',
                    style: GoogleFonts.inter(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFFFB26B),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 2. Avatar Section
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                        if (result == true) {
                          setState(() {
                            _profileImagePath = getIt<SharedPreferences>().getString('profile_image');
                          });
                          loadProfile();
                        }
                      },
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFFC4BDB1),
                              borderRadius: BorderRadius.circular(25),
                              image: _profileImagePath != null
                                  ? DecorationImage(
                                      image: (kIsWeb
                                              ? NetworkImage(_profileImagePath!)
                                              : FileImage(
                                                  File(_profileImagePath!)))
                                          as ImageProvider,
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: _profileImagePath == null
                                ? const Icon(Icons.person,
                                    size: 60, color: AppColors.navy)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.navy,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit,
                                  size: 14, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _profile?.name ?? 'Zayn Malik',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy,
                      ),
                    ),
                    Text(
                      _profile?.email ?? 'Zaynmalik@nutrify.app',
                      style: TextStyle(
                        color: AppColors.navy.withOpacity(0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 3. Info Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2.2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _buildInfoBox(
                    'Height',
                    _profile != null ? '${_profile!.height} cm' : '-',
                  ),
                  _buildInfoBox(
                    'Weight',
                    _profile != null ? '${_profile!.weight} kg' : '-',
                  ),
                  _buildInfoBox(
                    'Age',
                    _profile != null ? '${_profile!.age} Years' : '-',
                  ),
                  _buildInfoBox('Gender', _profile?.genderDisplay ?? '-'),
                  _buildInfoBox(
                    'BMI',
                    _profile != null
                        ? '${_profile!.bmi.toStringAsFixed(1)} (${_profile!.bmiStatus})'
                        : '-',
                  ),
                  _buildInfoBox(
                    'Target',
                    _profile != null ? '${_profile!.targetCalories} kcal' : '-',
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // 4. General Setting
              const Text(
                'Pengaturan Umum',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildMenuButton(
                context,
                icon: Icons.person_rounded,
                label: 'Edit Profil',
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                  if (result == true) {
                    setState(() {
                      _profileImagePath = getIt<SharedPreferences>().getString('profile_image');
                    });
                    loadProfile();
                  }
                },
              ),

              const SizedBox(height: 30),

              // 5. Preferences
              const Text(
                'Preferensi',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildMenuButton(
                context,
                icon: Icons.notifications_rounded,
                label: 'Notifikasi',
                onPressed: () => _toggleNotifications(!_notificationsEnabled),
                trailing: Switch.adaptive(
                  value: _notificationsEnabled,
                  onChanged: (val) => _toggleNotifications(val),
                  activeColor: AppColors.navy,
                ),
              ),
              const SizedBox(height: 12),
              _buildMenuButton(
                context,
                icon: Icons.logout_rounded,
                label: 'Keluar',
                onPressed: () async {
                  await getIt<UserStore>().logout();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.login,
                      (Route<dynamic> route) => false,
                    );
                  }
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: NutrifyTheme.lightCard,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.navy.withOpacity(0.7), fontSize: 11),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    Widget? destination,
    Widget? trailing,
    VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: NutrifyTheme.lightCard,
        borderRadius: BorderRadius.circular(35),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed ??
              () {
                if (destination != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => destination),
                  );
                }
              },
          borderRadius: BorderRadius.circular(35),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.navy.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.navy.withOpacity(0.6), size: 22),
                ),
                const SizedBox(width: 15),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                trailing ?? const Icon(Icons.chevron_right, color: AppColors.navy, size: 20),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
