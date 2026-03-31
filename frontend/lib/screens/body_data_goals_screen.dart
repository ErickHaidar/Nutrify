// lib/screens/body_data_goals_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/profile_api_service.dart';

class BodyDataGoalsScreen extends StatefulWidget {
  const BodyDataGoalsScreen({super.key});

  @override
  State<BodyDataGoalsScreen> createState() => _BodyDataGoalsScreenState();
}

class _BodyDataGoalsScreenState extends State<BodyDataGoalsScreen> {
  final _profileApi = ProfileApiService();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();

  // API enum values
  String _selectedGender = 'male'; // 'male' | 'female'
  String _selectedActivity = 'moderate'; // sedentary|light|moderate|active|very_active
  String _selectedGoal = 'maintenance'; // cutting|maintenance|bulking

  bool _isLoading = true;
  bool _isSaving = false;

  // ── Mapping between display and API values ────────────────────────────────

  static const _genderApiToDisplay = {
    'male': 'Laki-Laki',
    'female': 'Perempuan',
  };

  String get _genderDisplay =>
      _genderApiToDisplay[_selectedGender] ?? 'Laki-Laki';

  @override
  void initState() {
    super.initState();
    _loadData();
    _heightController.addListener(() => setState(() {}));
    _weightController.addListener(() => setState(() {}));
    _ageController.addListener(() => setState(() {}));
  }

  Future<void> _loadData() async {
    try {
      final profile = await _profileApi.getProfile();
      if (profile != null && mounted) {
        setState(() {
          _heightController.text = profile.height.toString();
          _ageController.text = profile.age.toString();
          _weightController.text = profile.weight.toString();
          _selectedGender = profile.gender;
          _selectedActivity = profile.activityLevel;
          _selectedGoal = profile.goal;
          _isLoading = false;
        });
      } else if (mounted) {
        // New user – show form with empty fields
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveData() async {
    if (_isSaving) return;

    final age = int.tryParse(_ageController.text) ?? 0;
    final weight = int.tryParse(_weightController.text) ?? 0;
    final height = int.tryParse(_heightController.text) ?? 0;

    if (age == 0 || weight == 0 || height == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi semua field terlebih dahulu')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _profileApi.saveProfile(
        age: age,
        weight: weight,
        height: height,
        gender: _selectedGender,
        goal: _selectedGoal,
        activityLevel: _selectedActivity,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    }
  }

  // ── Live calorie preview (client-side Mifflin-St Jeor) ────────────────────

  int _calculateTargetCalories() {
    double w = double.tryParse(_weightController.text) ?? 0;
    double h = double.tryParse(_heightController.text) ?? 0;
    int a = int.tryParse(_ageController.text) ?? 0;
    if (w == 0 || h == 0 || a == 0) return 0;

    double bmr;
    if (_selectedGender == 'male') {
      bmr = 10 * w + 6.25 * h - 5 * a + 5;
    } else {
      bmr = 10 * w + 6.25 * h - 5 * a - 161;
    }

    const activityFactors = {
      'sedentary': 1.2,
      'light': 1.375,
      'moderate': 1.55,
      'active': 1.725,
      'very_active': 1.9,
    };

    double tdee = bmr * (activityFactors[_selectedActivity] ?? 1.2);

    if (_selectedGoal == 'cutting') return (tdee - 500).round();
    if (_selectedGoal == 'bulking') return (tdee + 500).round();
    return tdee.round();
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
          'Body Data & Goals',
          style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Personal Information'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                    child: _buildInputField('Height (cm)', _heightController)),
                const SizedBox(width: 16),
                Expanded(child: _buildInputField('Age', _ageController)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _buildInputField(
                        'Weight (kg)', _weightController)),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Gender',
                style: TextStyle(
                    color: Color(0xFFFFCC80),
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: _buildChoiceButton(
                        'Laki-Laki',
                        _genderDisplay == 'Laki-Laki',
                        () => setState(
                            () => _selectedGender = 'male'))),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildChoiceButton(
                        'Perempuan',
                        _genderDisplay == 'Perempuan',
                        () => setState(
                            () => _selectedGender = 'female'))),
              ],
            ),
            const SizedBox(height: 35),
            _buildSectionHeader('Daily Activity'),
            const SizedBox(height: 15),
            _buildActivityTile('Lightly Active', '1-3 days of exercise/week',
                Icons.directions_walk, 'light'),
            _buildActivityTile('Moderately Active',
                '3-5 days of exercise/week', Icons.fitness_center, 'moderate'),
            _buildActivityTile(
                'Highly Active', '6-7 days of intense exercise', Icons.bolt,
                'active'),
            const SizedBox(height: 35),
            _buildSectionHeader('Main Goal'),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildGoalButton(
                    'Cutting', 'Lose Fat', Icons.trending_down, 'cutting'),
                _buildGoalButton(
                    'Maintain', 'Stay Fit', Icons.balance, 'maintenance'),
                _buildGoalButton(
                    'Bulking', 'Gain Muscle', Icons.trending_up, 'bulking'),
              ],
            ),
            const SizedBox(height: 35),
            _buildSectionHeader('Live Calorie Preview'),
            const SizedBox(height: 15),
            _buildCaloriePreview(),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D2A4A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: Color(0xFFFFCC80), width: 1),
                  ),
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
                    : const Text('Confirm Profile',
                        style: TextStyle(
                            color: Color(0xFFFFCC80),
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        const Divider(color: Colors.white24),
      ],
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFFFFCC80),
                fontSize: 12,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
              color: const Color(0xFF2D2A4A),
              borderRadius: BorderRadius.circular(20)),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF2D2A4A),
          borderRadius: BorderRadius.circular(25),
          border: isSelected
              ? Border.all(color: const Color(0xFFFFCC80), width: 2)
              : null,
        ),
        child: Text(text,
            style: TextStyle(
                color: isSelected ? const Color(0xFFFFCC80) : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  Widget _buildActivityTile(
      String title, String subtitle, IconData icon, String apiValue) {
    bool isSelected = _selectedActivity == apiValue;
    return GestureDetector(
      onTap: () => setState(() => _selectedActivity = apiValue),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2A4A),
          borderRadius: BorderRadius.circular(25),
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

  Widget _buildGoalButton(
      String title, String subtitle, IconData icon, String apiValue) {
    bool isSelected = _selectedGoal == apiValue;
    return GestureDetector(
      onTap: () => setState(() => _selectedGoal = apiValue),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
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
          const SizedBox(height: 8),
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

  Widget _buildCaloriePreview() {
    int target = _calculateTargetCalories();
    String formatted = target.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2A4A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFCC80).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Text(
            'Estimated Daily Calorie Target',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            '$formatted kCal',
            style: const TextStyle(
              color: Color(0xFFFFCC80),
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
