import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/profile_api_service.dart';
import '../utils/age_calculator.dart';
import '../widgets/nutrify_calendar_picker.dart';
import '../constants/colors.dart';
import 'package:nutrify/utils/locale/app_strings.dart';
import 'image_preview_screen.dart';

import '../../di/service_locator.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _profileApiService = getIt<ProfileApiService>();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  final _targetWeightController = TextEditingController();

  String _gender = 'male';
  String _goal = 'maintenance';
  String _activityLevel = 'sedentary';
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isPhotoChanged = false;
  bool _isPickingImage = false;

  // Initial State Tracking
  String? _initialHeight;
  String? _initialWeight;
  String? _initialAge;
  String? _initialTargetWeight;
  String? _initialGender;
  String? _initialGoal;
  String? _initialActivityLevel;

  DateTime? _birthDate;
  DateTime? _initialBirthDate;

  bool get _hasChanges {
    return _heightController.text != _initialHeight ||
        _weightController.text != _initialWeight ||
        _ageController.text != _initialAge ||
        _gender != _initialGender ||
        _goal != _initialGoal ||
        _activityLevel != _initialActivityLevel ||
        (_birthDate != null && _initialBirthDate != null && _birthDate != _initialBirthDate) ||
        (_birthDate != null && _initialBirthDate == null) ||
        _targetWeightController.text != _initialTargetWeight ||
        _isPhotoChanged ||
        _profileImage != null; // <--- Memastikan tombol tetap aktif ketika ada gambar dipilih
  }

  XFile? _profileImage;
  final ImagePicker _picker = getIt<ImagePicker>();

  @override
  void initState() {
    super.initState();
    _loadProfile();
    final savedImagePath = getIt<SharedPreferences>().getString('profile_image');
    if (savedImagePath != null) {
      _profileImage = XFile(savedImagePath);
    }
    _heightController.addListener(() => setState(() {}));
    _weightController.addListener(() => setState(() {}));
    _ageController.addListener(() => setState(() {}));
    _targetWeightController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileApiService.getProfile();
      if (profile != null && mounted) {
        setState(() {
          _heightController.text = profile.height.toString();
          _weightController.text = profile.weight.toString();
          _ageController.text = profile.age.toString();
          _gender = profile.gender;
          _goal = profile.goal;
          _activityLevel = profile.activityLevel;

          // Restore actual birthDate from SharedPreferences if available,
          // otherwise estimate from age (Jan 1 estimate — less accurate)
          final savedBirthDate = getIt<SharedPreferences>().getString('birth_date');
          if (savedBirthDate != null) {
            _birthDate = DateTime.tryParse(savedBirthDate);
          }
          _birthDate ??= DateTime(DateTime.now().year - profile.age, 1, 1);

          // Load target weight dari database jika ada
          if (profile.targetWeight != null) {
            _targetWeightController.text = profile.targetWeight.toString();
          }

          _initialHeight = _heightController.text;
          _initialBirthDate = _birthDate;
          _initialWeight = _weightController.text;
          _initialAge = _ageController.text;
          _initialTargetWeight = _targetWeightController.text;
          _initialGender = _gender;
          _initialGoal = _goal;
          _initialActivityLevel = _activityLevel;

          _isLoading = false;
        });

      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveChanges() async {
    final height = int.tryParse(_heightController.text) ?? 0;
    final weight = int.tryParse(_weightController.text) ?? 0;
    final age = int.tryParse(_ageController.text) ?? 0;

    // Validasi input
    if (height == 0 || weight == 0 || age == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi semua kolom dengan benar')),
      );
      return;
    }

    // Validasi batasan wajar
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
      // Siapkan file foto jika ada dan berubah
      File? photoFile;
      if (_profileImage != null && kIsWeb == false && _isPhotoChanged) {
        photoFile = File(_profileImage!.path);
      }

      // Ambil target weight dari input
      final targetWeight = int.tryParse(_targetWeightController.text);

      // Simpan profile dan foto dalam satu request
      await _profileApiService.saveProfile(
        age: age,
        weight: weight,
        height: height,
        gender: _gender,
        goal: _goal,
        activityLevel: _activityLevel,
        targetWeight: targetWeight, // Kirim target weight!
        photo: photoFile,
      );

      // Reset flag photo changed setelah berhasil
      if (_isPhotoChanged) {
        _isPhotoChanged = false;
      }

      if (mounted) {
        setState(() => _isSaving = false);
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);

    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null && mounted) {
        
        final file = File(pickedFile.path);
        final sizeInBytes = await file.length();
        final sizeInMb = sizeInBytes / (1024 * 1024);

        if (sizeInMb > 10.0) {
          // Tambahkan pengecekan context.mounted di sini
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ukuran foto terlalu besar. Maksimal 10 MB.'),
              duration: Duration(seconds: 4),
            ),
          );
          return;
        }

        // Tambahkan pengecekan context.mounted sebelum Navigator.push
        if (!context.mounted) return;
        final String? finalImagePath = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImagePreviewScreen(imagePath: pickedFile.path),
          ),
        );

        if (finalImagePath != null && mounted) {
          setState(() {
            _profileImage = XFile(finalImagePath);
            _isPhotoChanged = true;
          });
          await getIt<SharedPreferences>().setString('profile_image', finalImagePath);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.failedToPickImage}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  Future<void> _showBirthDatePicker() async {
    final now = DateTime.now();
    final defaultBirthYear = now.year - 20;
    final picked = await showNutrifyDatePicker(
      context,
      initialDate: _birthDate ?? DateTime(defaultBirthYear, 1, 1),
      firstDate: DateTime(now.year - 80),
      lastDate: DateTime(now.year - 10),
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _ageController.text = calculateAge(picked).toString();
      });
      getIt<SharedPreferences>().setString('birth_date', picked.toIso8601String());
    }
  }

  String _birthDateText() {
    if (_birthDate == null) return AppStrings.selectBirthDate;
    final d = _birthDate!;
    final months = AppStrings.monthNames;
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }

  void _showImagePickerModal() {

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2D2A4A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFFFFCC80)),
              title: Text(AppStrings.openGallery, style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFFFCC80)),
              title: Text(AppStrings.openCamera, style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  int _calculateTarget() {
    final w = double.tryParse(_weightController.text) ?? 0;
    final h = double.tryParse(_heightController.text) ?? 0;
    final a = int.tryParse(_ageController.text) ?? 0;
    if (w == 0 || h == 0 || a == 0) return 0;
    final bmr = _gender == 'male'
        ? 10 * w + 6.25 * h - 5 * a + 5
        : 10 * w + 6.25 * h - 5 * a - 161;
    const factors = {
      'sedentary': 1.2,
      'light': 1.375,
      'moderate': 1.55,
      'active': 1.725,
      'very_active': 1.9,
    };
    final tdee = bmr * (factors[_activityLevel] ?? 1.2);
    if (_goal == 'cutting') return (tdee - 500).round();
    if (_goal == 'bulking') return (tdee + 500).round();
    return tdee.round();
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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.navy),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.editProfile,
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            const SizedBox(height: 8),

            _buildSectionLabel(AppStrings.bodyComposition),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ProfileInput(
                    controller: _heightController,
                    label: AppStrings.heightCm,
                    icon: Icons.height,
                    keyboardType: TextInputType.number,
                    hintText: '100-250 cm',
                    maxLength: 3,
                    isDecimal: false,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ProfileInput(
                    controller: _weightController,
                    label: AppStrings.weightKg,
                    icon: Icons.monitor_weight_outlined,
                    keyboardType: TextInputType.number,
                    hintText: '25-300 kg',
                    maxLength: 3,
                    isDecimal: false,
                  ),
                ),
              ],
            ),
            CustomInputField(
              label: AppStrings.birthDate,
              initialValue: _birthDateText(),
              onTap: _showBirthDatePicker,
            ),
            ProfileInput(
              controller: _targetWeightController,
              label: AppStrings.targetWeight,
              icon: Icons.track_changes,
              keyboardType: TextInputType.number,
              hintText: '25-300 kg',
              maxLength: 3,
              isDecimal: false,
            ),

            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.activity,
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  AppStrings.selectOneActivity,
                  style: TextStyle(
                    color: AppColors.navy.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildActivitySelection(),

            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppStrings.mainGoal,
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildGoalSelection(),

            const SizedBox(height: 32),
            _buildCaloriePreview(),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: (_isSaving || !_hasChanges) ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  disabledBackgroundColor: const Color(0xFF8F8E9D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        AppStrings.saveChanges,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GENDER',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFFFFCC80),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2D2A4A),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _gender,
              isExpanded: true,
              dropdownColor: const Color(0xFF2D2A4A),
              style: const TextStyle(color: Colors.white, fontSize: 15),
              iconEnabledColor: const Color(0xFFFFCC80),
              items: const [
                DropdownMenuItem(value: 'male', child: Text('Laki-Laki')),
                DropdownMenuItem(value: 'female', child: Text('Perempuan')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _gender = v);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalDropdown() {
    const goals = {
      'cutting': 'Cutting (Defisit)',
      'maintenance': 'Maintenance',
      'bulking': 'Bulking (Surplus)',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GOAL',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFFFFCC80),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2D2A4A),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _goal,
              isExpanded: true,
              dropdownColor: const Color(0xFF2D2A4A),
              style: const TextStyle(color: Colors.white, fontSize: 15),
              iconEnabledColor: const Color(0xFFFFCC80),
              items: goals.entries
                  .map(
                    (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _goal = v);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivitySelection() {
    final levels = [
      {'id': 'light', 'title': AppStrings.lightActivity, 'subtitle': AppStrings.lightActivitySub, 'icon': Icons.directions_walk},
      {'id': 'moderate', 'title': AppStrings.moderateActivity, 'subtitle': AppStrings.moderateActivitySub, 'icon': Icons.fitness_center},
      {'id': 'active', 'title': AppStrings.highActivity, 'subtitle': AppStrings.highActivitySub, 'icon': Icons.bolt},
    ];

    return Column(
      children: levels.map((level) {
        final bool isSelected = _activityLevel == level['id'];
        return GestureDetector(
          onTap: () => setState(() => _activityLevel = level['id'] as String),
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD1A8),
              borderRadius: BorderRadius.circular(40),
              border: isSelected ? Border.all(color: AppColors.navy, width: 2) : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(level['icon'] as IconData, color: AppColors.navy, size: 24),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level['title'] as String,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        level['subtitle'] as String,
                        style: TextStyle(
                          color: AppColors.navy.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: AppColors.navy, size: 24),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGoalSelection() {
    final goals = [
      {'id': 'cutting', 'title': AppStrings.cutting, 'subtitle': AppStrings.loseFat, 'icon': Icons.trending_down},
      {'id': 'maintenance', 'title': AppStrings.maintain, 'subtitle': AppStrings.stayFit, 'icon': Icons.scale},
      {'id': 'bulking', 'title': AppStrings.bulking, 'subtitle': AppStrings.gainMuscle, 'icon': Icons.trending_up},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: goals.map((goal) {
        final bool isSelected = _goal == goal['id'];
        return GestureDetector(
          onTap: () => setState(() => _goal = goal['id'] as String),
          child: Column(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD1A8),
                  shape: BoxShape.circle,
                  border: isSelected ? Border.all(color: AppColors.navy, width: 2) : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(goal['icon'] as IconData, color: AppColors.navy, size: 28),
              ),
              const SizedBox(height: 10),
              Text(
                goal['title'] as String,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                goal['subtitle'] as String,
                style: TextStyle(
                  color: AppColors.navy.withOpacity(0.5),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCaloriePreview() {
    final target = _calculateTarget();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD1A8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'Estimated Daily Calorie Target',
            style: TextStyle(color: AppColors.navy, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            target > 0
                ? '${target.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} kCal'
                : '- kCal',
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

  Widget _buildSectionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.navy,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD1AB),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 25),
                Text(
                  AppStrings.savedSuccessfully,
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppStrings.profileUpdated,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Pop dialog
                      Navigator.pop(context, true); // Pop screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      AppStrings.ok,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomInputField extends StatelessWidget {
  final String label;
  final String initialValue;
  final VoidCallback? onTap;

  const CustomInputField({
    super.key,
    required this.label,
    required this.initialValue,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.navy,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD1A8),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Text(
              initialValue,
              style: const TextStyle(color: AppColors.navy, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final String? hintText;
  final int? maxLength;
  final bool isDecimal;
  final double? maxValue;
  final double? minValue;
  final String? fieldName;

  const ProfileInput({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.hintText,
    this.maxLength,
    this.isDecimal = false,
    this.maxValue,
    this.minValue,
    this.fieldName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.navy,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFD1A8),
            borderRadius: BorderRadius.circular(40),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLength: maxLength,
            style: const TextStyle(color: AppColors.navy, fontSize: 15),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: TextStyle(
                color: AppColors.navy.withOpacity(0.4),
                fontSize: 13,
              ),
              counterText: '', // Hide character counter
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            onChanged: isDecimal ? (value) {
              final number = double.tryParse(value);
              final max = maxValue; // Fix type promotion issue
              if (number != null && max != null && number > max) {
                // Show error real-time jika melebihi batas
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$fieldName tidak boleh lebih dari $max'),
                    duration: const Duration(seconds: 2),
                  ),
                );
                // Hapus karakter terakhir
                final newValue = value.substring(0, value.length - 1);
                controller.value = TextEditingValue(
                  text: newValue,
                  selection: TextSelection.collapsed(offset: newValue.length),
                );
              }
            } : null,
          ),
        ),
      ],
    );
  }
}
