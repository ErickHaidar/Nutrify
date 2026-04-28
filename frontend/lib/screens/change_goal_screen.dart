// lib/screens/change_goal_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/profile_api_service.dart';
import 'package:nutrify/constants/colors.dart';
import 'package:nutrify/utils/locale/app_strings.dart';

class ChangeGoalScreen extends StatefulWidget {
  const ChangeGoalScreen({super.key});

  @override
  State<ChangeGoalScreen> createState() => _ChangeGoalScreenState();
}

class _ChangeGoalScreenState extends State<ChangeGoalScreen> {
  final _profileApi = ProfileApiService();
  bool _isLoading = true;
  bool _isSaving = false;

  // API values stored internally
  String _selectedActivityApi = 'moderate'; // sedentary|light|moderate|active|very_active
  String _selectedGoalApi = 'maintenance'; // cutting|maintenance|bulking

  // Original profile data for the save call
  int _age = 0;
  int _weight = 0;
  int _height = 0;
  String _gender = 'male';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ── Mapping between display and API values ────────────────────────────────

  static Map<String, String> get _activityDisplayToApi => {
    AppStrings.lightlyActive: 'light',
    AppStrings.moderatelyActive: 'moderate',
    AppStrings.highlyActive: 'active',
  };

  static Map<String, String> get _activityApiToDisplay => {
    'sedentary': AppStrings.lightlyActive,
    'light': AppStrings.lightlyActive,
    'moderate': AppStrings.moderatelyActive,
    'active': AppStrings.highlyActive,
    'very_active': AppStrings.highlyActive,
  };

  static Map<String, String> get _goalDisplayToApi => {
    AppStrings.cutting: 'cutting',
    AppStrings.maintain: 'maintenance',
    AppStrings.bulking: 'bulking',
  };

  static Map<String, String> get _goalApiToDisplay => {
    'cutting': AppStrings.cutting,
    'maintenance': AppStrings.maintain,
    'bulking': AppStrings.bulking,
  };

  String get _selectedActivityDisplay =>
      _activityApiToDisplay[_selectedActivityApi] ?? 'Moderately Active';

  String get _selectedGoalDisplay =>
      _goalApiToDisplay[_selectedGoalApi] ?? 'Maintain';

  // ── Data loading ──────────────────────────────────────────────────────────

  Future<void> _loadData() async {
    try {
      final profile = await _profileApi.getProfile();
      if (profile != null && mounted) {
        setState(() {
          _age = profile.age;
          _weight = profile.weight;
          _height = profile.height;
          _gender = profile.gender;
          _selectedActivityApi = profile.activityLevel;
          _selectedGoalApi = profile.goal;
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveData() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      await _profileApi.saveProfile(
        age: _age,
        weight: _weight,
        height: _height,
        gender: _gender,
        goal: _selectedGoalApi,
        activityLevel: _selectedActivityApi,
      );
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.failedToSaveTitle}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.cream,
        body: Center(child: CircularProgressIndicator(color: AppColors.navy)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.navy),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.changeTarget,
          style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold, color: AppColors.navy),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppColors.navy),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.whatIsYourFocus,
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.chooseFocusDesc,
              style: const TextStyle(color: AppColors.navy, fontSize: 13),
            ),
            const SizedBox(height: 30),
            _buildActivityTile(AppStrings.lightlyActive, AppStrings.lightlyActiveSub,
                Icons.directions_walk),
            _buildActivityTile(AppStrings.moderatelyActive,
                AppStrings.moderatelyActiveSub, Icons.fitness_center),
            _buildActivityTile(
                AppStrings.highlyActive, AppStrings.highlyActiveSub, Icons.bolt),
            const SizedBox(height: 35),
            Text(AppStrings.mainTarget,
                style: const TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildGoalButton(AppStrings.cutting, AppStrings.loseFat, Icons.trending_down),
                _buildGoalButton(AppStrings.maintain, AppStrings.stayFit, Icons.balance),
                _buildGoalButton(AppStrings.bulking, AppStrings.gainMuscle, Icons.trending_up),
              ],
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        AppStrings.confirmChanges,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(String title, String subtitle, IconData icon) {
    bool isSelected = _selectedActivityDisplay == title;
    return GestureDetector(
      onTap: () {
        final apiValue = _activityDisplayToApi[title];
        if (apiValue != null) {
          setState(() => _selectedActivityApi = apiValue);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.peach : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.navy : AppColors.navy.withOpacity(0.1), width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.navy),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: AppColors.navy, fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style:
                          const TextStyle(color: AppColors.navy, fontSize: 11)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.navy),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalButton(String title, String subtitle, IconData icon) {
    bool isSelected = _selectedGoalDisplay == title;
    return GestureDetector(
      onTap: () {
        final apiValue = _goalDisplayToApi[title];
        if (apiValue != null) {
          setState(() => _selectedGoalApi = apiValue);
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.amber : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: isSelected ? AppColors.navy : AppColors.navy.withOpacity(0.1), width: 2),
            ),
            child: Icon(icon,
                color: AppColors.navy,
                size: 28),
          ),
          const SizedBox(height: 10),
          Text(title,
              style: TextStyle(
                  color: AppColors.navy,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13)),
          Text(subtitle,
              style: const TextStyle(color: AppColors.navy, fontSize: 10)),
        ],
      ),
    );
  }
}
