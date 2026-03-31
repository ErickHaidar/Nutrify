import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boilerplate/data/sharedpref/constants/preferences.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:boilerplate/constants/assets.dart';
import 'edit_profile_screen.dart';
import 'change_goal_screen.dart';
import '../services/profile_api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileApiService = ProfileApiService();
  ApiProfileData? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
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
        backgroundColor: Color(0xFF433D67),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF433D67),
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
                  const Text(
                    'Nutrify',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFFFFDDBE),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 2. Avatar Section
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFF5A5380),
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: Color(0xFFFFDDBE),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D2A4A),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _profile?.name ?? '-',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _profile?.email ?? '-',
                      style: const TextStyle(
                        color: Color(0xFFFFCC80),
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
                'General Setting',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildMenuButton(
                context,
                icon: Icons.person_outline,
                label: 'Edit Profile',
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                  if (result == true) {
                    _loadProfile();
                  }
                },
              ),
              const SizedBox(height: 12),
              _buildMenuButton(
                context,
                icon: Icons.track_changes,
                label: 'Change Goal',
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChangeGoalScreen(),
                    ),
                  );
                  if (result == true) {
                    _loadProfile();
                  }
                },
              ),

              const SizedBox(height: 30),

              // 5. Preferences
              const Text(
                'Preferences',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildMenuButton(
                context,
                icon: Icons.logout,
                label: 'Logout',
                destination: null,
                onPressed: () {
                  SharedPreferences.getInstance().then((preference) {
                    preference.setBool(Preferences.is_logged_in, false);
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.login,
                      (Route<dynamic> route) => false,
                    );
                  });
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
        color: const Color(0xFF2D2A4A),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFFFCC80),
              fontSize: 14,
              fontWeight: FontWeight.bold,
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
    bool isHighlighted = false,
    VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap:
          onPressed ??
          () {
            if (destination != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => destination),
              );
            }
          },
      borderRadius: BorderRadius.circular(35),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2A4A),
          borderRadius: BorderRadius.circular(35),
          border: isHighlighted
              ? Border.all(color: const Color(0xFFFFDDBE), width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFFFCC80), size: 22),
            const SizedBox(width: 15),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFFFCC80),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Color(0xFFFFCC80), size: 20),
          ],
        ),
      ),
    );
  }
}
