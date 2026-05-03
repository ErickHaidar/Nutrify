import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutrify/di/service_locator.dart';
import 'package:nutrify/presentation/login/store/login_store.dart';
import 'package:nutrify/presentation/home/store/language/language_store.dart';
import 'package:nutrify/utils/routes/routes.dart';
import 'package:nutrify/constants/assets.dart';
import 'package:nutrify/utils/locale/app_strings.dart';
import 'edit_profile_screen.dart';
import '../services/profile_api_service.dart';
import '../services/notification_service.dart';
import '../constants/colors.dart';

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
            SnackBar(content: Text(AppStrings.notifEnabled)),
          );
        }
      } else {
        // Revert if denied
        setState(() => _notificationsEnabled = false);
        await prefs.setBool('notifications_enabled', false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.notifDenied)),
          );
        }
      }
    } else {
      setState(() => _notificationsEnabled = false);
      await prefs.setBool('notifications_enabled', false);
      await notificationService.cancelAllNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.notifDisabled)),
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

  ImageProvider? _buildProfileImageProvider() {
    // Priority: API photo URL > local cached file
    if (_profile?.photoUrl != null && _profile!.photoUrl!.isNotEmpty) {
      return NetworkImage(_profile!.photoUrl!);
    }
    if (_profileImagePath != null) {
      if (kIsWeb) {
        return NetworkImage(_profileImagePath!);
      }
      return FileImage(File(_profileImagePath!));
    }
    return null;
  }

  void _showLanguagePicker() {
    final languageStore = getIt<LanguageStore>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.navy.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppStrings.chooseLanguage,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildLanguageOption(
                ctx,
                languageStore,
                flag: '🇮🇩',
                label: 'Bahasa Indonesia',
                locale: 'id',
              ),
              const SizedBox(height: 12),
              _buildLanguageOption(
                ctx,
                languageStore,
                flag: '🇺🇸',
                label: 'English',
                locale: 'en',
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext ctx,
    LanguageStore languageStore, {
    required String flag,
    required String label,
    required String locale,
  }) {
    final isSelected = AppStrings.currentLocale == locale;
    return GestureDetector(
      onTap: () {
        languageStore.changeLanguage(locale);
        Navigator.pop(ctx);
        // Rebuild the entire app to reflect language change
        Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.home,
          (route) => false,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.peach : NutrifyTheme.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: AppColors.navy, width: 2)
              : null,
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.navy),
          ],
        ),
      ),
    );
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
                  const SizedBox(width: 8),
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
                              image: _buildProfileImageProvider() != null
                                  ? DecorationImage(
                                      image: _buildProfileImageProvider()!,
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: _buildProfileImageProvider() == null
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
                      _profile?.name ?? '-',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy,
                      ),
                    ),
                    Text(
                      _profile?.email ?? '',
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
                    AppStrings.height,
                    _profile != null ? '${_profile!.height} cm' : '-',
                  ),
                  _buildInfoBox(
                    AppStrings.weight,
                    _profile != null ? '${_profile!.weight} kg' : '-',
                  ),
                  _buildInfoBox(
                    AppStrings.age,
                    _profile != null ? '${_profile!.age} ${AppStrings.years}' : '-',
                  ),
                  _buildInfoBox(AppStrings.gender, _profile?.genderDisplay ?? '-'),
                  _buildInfoBox(
                    'BMI',
                    _profile != null
                        ? '${_profile!.bmi.toStringAsFixed(1)} (${_profile!.bmiStatus})'
                        : '-',
                  ),
                  _buildInfoBox(
                    AppStrings.target,
                    _profile != null ? '${_profile!.targetCalories} kcal' : '-',
                  ),
                ],
              ),

              if (_profile?.macronutrients != null) ...[
                const SizedBox(height: 20),
                Text(
                  'Rekomendasi Makronutrien',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMacroCard(
                        'Protein',
                        '${_profile!.macronutrients!.protein.grams}g',
                        _profile!.macronutrients!.protein.percent,
                        const Color(0xFFE57373),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMacroCard(
                        'Karbohidrat',
                        '${_profile!.macronutrients!.carbohydrates.grams}g',
                        _profile!.macronutrients!.carbohydrates.percent,
                        const Color(0xFF64B5F6),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMacroCard(
                        'Lemak',
                        '${_profile!.macronutrients!.fat.grams}g',
                        _profile!.macronutrients!.fat.percent,
                        const Color(0xFFFFD54F),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 30),

              // 4. General Setting
              Text(
                AppStrings.generalSettings,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildMenuButton(
                context,
                icon: Icons.person_rounded,
                label: AppStrings.editProfile,
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
              Text(
                AppStrings.preferences,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildMenuButton(
                context,
                icon: Icons.notifications_rounded,
                label: AppStrings.notification,
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
                icon: Icons.language_rounded,
                label: AppStrings.language,
                onPressed: _showLanguagePicker,
                trailing: Text(
                  AppStrings.isId ? '🇮🇩 ID' : '🇺🇸 EN',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildMenuButton(
                context,
                icon: Icons.logout_rounded,
                label: AppStrings.logout,
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

  Widget _buildMacroCard(String label, String value, int percent, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: NutrifyTheme.lightCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: AppColors.navy.withOpacity(0.7), fontSize: 11)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text('$percent%', style: TextStyle(color: AppColors.navy.withOpacity(0.5), fontSize: 11)),
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
