// lib/screens/body_data_goals_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/profile_api_service.dart';
import '../widgets/nutrify_calendar_picker.dart';
import 'package:nutrify/constants/colors.dart';

class BodyDataGoalsScreen extends StatefulWidget {
  const BodyDataGoalsScreen({super.key});

  @override
  State<BodyDataGoalsScreen> createState() => _BodyDataGoalsScreenState();
}

class _BodyDataGoalsScreenState extends State<BodyDataGoalsScreen> {
  final _profileApi = ProfileApiService();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  DateTime? _birthDate;

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
  }

  Future<void> _loadData() async {
    try {
      final profile = await _profileApi.getProfile();
      if (profile != null && mounted) {
        setState(() {
          _heightController.text = profile.height.toString();
          if (profile.age > 0) {
            _birthDate = DateTime(DateTime.now().year - profile.age, 1, 1);
          }
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

    final age = _birthDate != null ? _computeAge(_birthDate!) : 0;
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

  int _computeAge(DateTime dob) {
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) age--;
    return age;
  }

  int _calculateTargetCalories() {
    double w = double.tryParse(_weightController.text) ?? 0;
    double h = double.tryParse(_heightController.text) ?? 0;
    int a = _birthDate != null ? _computeAge(_birthDate!) : 0;
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
          'Body Data & Goals',
          style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold, color: AppColors.navy),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Informasi Personal'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                    child: _buildInputField('Tinggi Badan (cm)', _heightController)),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final picked = await showNutrifyDatePicker(
                        context,
                        initialDate: _birthDate ?? DateTime(DateTime.now().year - 25),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => _birthDate = picked);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tanggal Lahir', style: TextStyle(color: AppColors.navy, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: AppColors.navy.withOpacity(0.1)),
                          ),
                          child: Text(
                            _birthDate != null
                              ? '${_birthDate!.day.toString().padLeft(2,'0')} ${['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'][_birthDate!.month-1]} ${_birthDate!.year}'
                              : 'Pilih tanggal',
                            style: TextStyle(color: _birthDate != null ? AppColors.navy : AppColors.navy.withOpacity(0.4)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _buildInputField(
                        'Berat Badan (kg)', _weightController)),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Jenis Kelamin',
                style: TextStyle(
                    color: AppColors.navy,
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
            _buildSectionHeader('Aktivitas Harian'),
            const SizedBox(height: 15),
            _buildActivityTile('Lightly Active', '1-3 hari olahraga/minggu',
                Icons.directions_walk, 'light'),
            _buildActivityTile('Moderately Active',
                '3-5 hari olahraga/minggu', Icons.fitness_center, 'moderate'),
            _buildActivityTile(
                'Highly Active', '6-7 hari olahraga intensif', Icons.bolt,
                'active'),
            const SizedBox(height: 35),
            _buildSectionHeader('Target Utama'),
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
            _buildSectionHeader('Estimasi Target Kalori'),
            const SizedBox(height: 15),
            _buildCaloriePreview(),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
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
                    : const Text('Simpan Profil',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
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
                color: AppColors.navy,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        const Divider(color: AppColors.navy, thickness: 0.1),
      ],
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.navy,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.navy.withOpacity(0.1))),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: AppColors.navy),
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
          color: isSelected ? AppColors.peach : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: isSelected ? AppColors.navy : AppColors.navy.withOpacity(0.1), width: isSelected ? 2 : 1),
        ),
        child: Text(text,
            style: TextStyle(
                color: AppColors.navy,
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
              color: isSelected ? AppColors.amber : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: isSelected ? AppColors.navy : AppColors.navy.withOpacity(0.1), width: 2),
            ),
            child: Icon(icon,
                color: AppColors.navy,
                size: 28),
          ),
          const SizedBox(height: 8),
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

  Widget _buildCaloriePreview() {
    int target = _calculateTargetCalories();
    String formatted = target.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.peach,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.navy.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Text(
            'Estimasi Target Kalori Harian',
            style: TextStyle(color: AppColors.navy, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            '$formatted kCal',
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
