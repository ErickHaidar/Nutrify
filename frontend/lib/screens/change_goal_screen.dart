// lib/screens/change_goal_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/profile_api_service.dart';

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

  static const _activityDisplayToApi = {
    'Lightly Active': 'light',
    'Moderately Active': 'moderate',
    'Highly Active': 'active',
  };

  static const _activityApiToDisplay = {
    'sedentary': 'Lightly Active',
    'light': 'Lightly Active',
    'moderate': 'Moderately Active',
    'active': 'Highly Active',
    'very_active': 'Highly Active',
  };

  static const _goalDisplayToApi = {
    'Cutting': 'cutting',
    'Maintain': 'maintenance',
    'Bulking': 'bulking',
  };

  static const _goalApiToDisplay = {
    'cutting': 'Cutting',
    'maintenance': 'Maintain',
    'bulking': 'Bulking',
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
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Change Goal',
          style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Color(0xFFFFCC80)),
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
              "What's your focus?",
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'select the primary goal for your fitness journey.',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 30),
            _buildActivityTile('Lightly Active', '1-3 days of exercise/week',
                Icons.directions_walk),
            _buildActivityTile('Moderately Active',
                '3-5 days of exercise/week', Icons.fitness_center),
            _buildActivityTile(
                'Highly Active', '6-7 days of intense exercise', Icons.bolt),
            const SizedBox(height: 35),
            const Text('Main Goal',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildGoalButton('Cutting', 'Lose Fat', Icons.trending_down),
                _buildGoalButton('Maintain', 'Stay Fit', Icons.balance),
                _buildGoalButton('Bulking', 'Gain Muscle', Icons.trending_up),
              ],
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: OutlinedButton(
                onPressed: _isSaving ? null : _saveData,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFFCC80), width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  backgroundColor: Colors.transparent,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFFFCC80),
                        ),
                      )
                    : const Text(
                        'Confirm Change',
                        style: TextStyle(
                            color: Color(0xFFFFCC80),
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
          color: const Color(0xFF2D2A4A),
          borderRadius: BorderRadius.circular(40),
          border: isSelected
              ? Border.all(color: const Color(0xFFFFCC80), width: 2)
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFFFFCC80)),
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
              color: const Color(0xFF2D2A4A),
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: const Color(0xFFFFCC80), width: 2)
                  : null,
            ),
            child: Icon(icon,
                color: isSelected ? const Color(0xFFFFCC80) : Colors.white54,
                size: 28),
          ),
          const SizedBox(height: 10),
          Text(title,
              style: TextStyle(
                  color: isSelected ? const Color(0xFFFFCC80) : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          Text(subtitle,
              style: const TextStyle(color: Colors.white54, fontSize: 10)),
        ],
      ),
    );
  }
}
