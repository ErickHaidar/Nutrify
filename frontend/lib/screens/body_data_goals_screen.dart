// lib/screens/body_data_goals_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/profile_api_service.dart';
import '../widgets/nutrify_calendar_picker.dart';
import 'package:nutrify/constants/colors.dart';
import 'package:nutrify/utils/locale/app_strings.dart';

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

  static Map<String, String> get _genderApiToDisplay => {
    'male': AppStrings.male,
    'female': AppStrings.female,
  };

  String get _genderDisplay =>
      _genderApiToDisplay[_selectedGender] ?? AppStrings.male;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final profile = await _profileApi.getProfile();
      if (profile != null && mounted) {
        // Restore exact birth date from SharedPreferences if available
        final savedBirthDate = await SharedPreferences.getInstance().then((prefs) => prefs.getString('birth_date'));
        DateTime? birthDate;
        if (savedBirthDate != null) {
          birthDate = DateTime.tryParse(savedBirthDate);
        }
        birthDate ??= profile.age > 0 ? DateTime(DateTime.now().year - profile.age, 1, 1) : null;

        setState(() {
          _heightController.text = profile.height.toString();
          _birthDate = birthDate;
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
        SnackBar(content: Text(AppStrings.fillAllFieldsFirst)),
      );
      return;
    }

    if (age < 13 || age > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usia harus antara 13-100 tahun')),
      );
      return;
    }

    if (weight < 25 || weight > 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berat badan harus antara 25-300 kg')),
      );
      return;
    }

    if (height < 100 || height > 250) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tinggi badan harus antara 100-250 cm')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      // Save birth date to SharedPreferences for exact date sync
      if (_birthDate != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('birth_date', _birthDate!.toIso8601String());
      }

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
          SnackBar(content: Text('${AppStrings.failedToSaveTitle}: $e')),
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
          AppStrings.bodyDataGoals,
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
            _buildSectionHeader(AppStrings.personalInfo),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                    child: ListenableBuilder(
                      listenable: _heightController,
                      builder: (context, _) => _buildInputField(AppStrings.heightBodyCm, _heightController, hintText: '100-250 cm', maxLength: 3, minValue: 100, maxValue: 250, unit: 'cm'),
                    )),
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
                      if (picked != null) {
                          setState(() => _birthDate = picked);
                          SharedPreferences.getInstance().then((prefs) => prefs.setString('birth_date', picked.toIso8601String()));
                        }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.birthDateLabel, style: const TextStyle(color: AppColors.navy, fontSize: 12, fontWeight: FontWeight.bold)),
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
                              ? '${_birthDate!.day.toString().padLeft(2,'0')} ${AppStrings.monthNamesShort[_birthDate!.month-1]} ${_birthDate!.year}'
                              : AppStrings.selectDate,
                            style: TextStyle(color: _birthDate != null ? AppColors.navy : AppColors.navy.withOpacity(0.4)),
                          ),
                        ),
                        const SizedBox(height: 18), // Reserve space to match error text height on sibling
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
                    child: ListenableBuilder(
                      listenable: _weightController,
                      builder: (context, _) => _buildInputField(
                          AppStrings.weightBodyKg, _weightController, hintText: '25-300 kg', maxLength: 3, minValue: 25, maxValue: 300, unit: 'kg'),
                    )),
              ],
            ),
            const SizedBox(height: 16),
            Text(AppStrings.genderLabel,
                style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: _buildChoiceButton(
                        AppStrings.male,
                        _selectedGender == 'male',
                        () => setState(
                            () => _selectedGender = 'male'))),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildChoiceButton(
                        AppStrings.female,
                        _selectedGender == 'female',
                        () => setState(
                            () => _selectedGender = 'female'))),
              ],
            ),
            const SizedBox(height: 35),
            _buildSectionHeader(AppStrings.dailyActivity),
            const SizedBox(height: 15),
            _buildActivityTile(AppStrings.lightlyActive, AppStrings.lightlyActiveSub,
                Icons.directions_walk, 'light'),
            _buildActivityTile(AppStrings.moderatelyActive,
                AppStrings.moderatelyActiveSub, Icons.fitness_center, 'moderate'),
            _buildActivityTile(
                AppStrings.highlyActive, AppStrings.highlyActiveSub, Icons.bolt,
                'active'),
            const SizedBox(height: 35),
            _buildSectionHeader(AppStrings.mainTarget),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildGoalButton(
                    AppStrings.cutting, AppStrings.loseFat, Icons.trending_down, 'cutting'),
                _buildGoalButton(
                    AppStrings.maintain, AppStrings.stayFit, Icons.balance, 'maintenance'),
                _buildGoalButton(
                    AppStrings.bulking, AppStrings.gainMuscle, Icons.trending_up, 'bulking'),
              ],
            ),
            const SizedBox(height: 35),
            _buildSectionHeader(AppStrings.estimatedTarget),
            const SizedBox(height: 15),
            ListenableBuilder(
              listenable: Listenable.merge([_heightController, _weightController]),
              builder: (context, _) => _buildCaloriePreview(),
            ),
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
                    : Text(AppStrings.saveProfile,
                        style: const TextStyle(
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

  Widget _buildInputField(String label, TextEditingController controller, {String? hintText, int? maxLength, double? minValue, double? maxValue, String? unit}) {
    final value = double.tryParse(controller.text);
    final isInvalid = controller.text.isNotEmpty && value != null &&
        ((minValue != null && value < minValue) || (maxValue != null && value > maxValue));

    String errorText = '';
    if (isInvalid) {
      final unitSuffix = unit != null ? ' $unit' : '';
      if (minValue != null && value < minValue) {
        errorText = 'Minimal $minValue$unitSuffix';
      } else if (maxValue != null && value > maxValue) {
        errorText = 'Maksimal $maxValue$unitSuffix';
      }
    }

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
              border: Border.all(
                color: isInvalid ? Colors.red : AppColors.navy.withOpacity(0.1),
                width: isInvalid ? 2 : 1,
              )),
          child: TextField(
            controller: controller,
            style: TextStyle(color: isInvalid ? Colors.red : AppColors.navy),
            keyboardType: TextInputType.number,
            maxLength: maxLength,
            decoration: InputDecoration(
              border: InputBorder.none,
              counterText: '',
              hintText: hintText,
              hintStyle: TextStyle(color: AppColors.navy.withOpacity(0.3), fontSize: 13),
            ),
          ),
        ),
        SizedBox(
          height: 18,
          child: isInvalid && errorText.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: Text(
                    errorText,
                    style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                )
              : const SizedBox.shrink(),
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
          Text(
            AppStrings.estimatedDailyTarget,
            style: const TextStyle(color: AppColors.navy, fontSize: 13),
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
