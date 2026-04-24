import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/profile_api_service.dart';
import '../../di/service_locator.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _profileApiService = ProfileApiService();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();

  String _gender = 'male';
  String _goal = 'maintenance';
  String _activityLevel = 'sedentary';
  bool _isLoading = true;
  bool _isSaving = false;

  XFile? _profileImage;
  final ImagePicker _picker = ImagePicker();

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
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
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
    if (height == 0 || weight == 0 || age == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi semua kolom dengan benar')),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      await _profileApiService.saveProfile(
        age: age,
        weight: weight,
        height: height,
        gender: _gender,
        goal: _goal,
        activityLevel: _activityLevel,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui')),
        );
        Navigator.pop(context, true);
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
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _profileImage = pickedFile;
        });
        await getIt<SharedPreferences>().setString('profile_image', pickedFile.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
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
              title: const Text('Buka Galeri', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFFFCC80)),
              title: const Text('Buka Kamera', style: TextStyle(color: Colors.white)),
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
        backgroundColor: Color(0xFF433D67),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF433D67),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            // Avatar placeholder
            GestureDetector(
              onTap: _showImagePickerModal,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF2D2A4A),
                    backgroundImage: _profileImage != null
                        ? (kIsWeb
                            ? NetworkImage(_profileImage!.path)
                            : FileImage(File(_profileImage!.path))) as ImageProvider
                        : null,
                    child: _profileImage == null
                        ? const Icon(Icons.person, size: 60, color: Color(0xFFFFCC80))
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFCC80),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF433D67), width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: Color(0xFF2D2A4A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _buildSectionLabel('BODY COMPOSITION'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ProfileInput(
                    controller: _heightController,
                    label: 'HEIGHT (CM)',
                    icon: Icons.height,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ProfileInput(
                    controller: _weightController,
                    label: 'WEIGHT (KG)',
                    icon: Icons.monitor_weight_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ProfileInput(
                    controller: _ageController,
                    label: 'AGE',
                    icon: Icons.cake_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: _buildGenderDropdown()),
              ],
            ),

            const SizedBox(height: 32),
            _buildSectionLabel('GOAL & ACTIVITY'),
            const SizedBox(height: 16),
            _buildGoalDropdown(),
            const SizedBox(height: 16),
            _buildActivityDropdown(),

            const SizedBox(height: 32),
            _buildCaloriePreview(),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFCC80),
                  foregroundColor: const Color(0xFF2D2A4A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 2,
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Color(0xFF2D2A4A),
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save Profile Changes',
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

  Widget _buildActivityDropdown() {
    const levels = {
      'sedentary': 'Sedentary (Tidak aktif)',
      'light': 'Light (Sedikit aktif)',
      'moderate': 'Moderate (Cukup aktif)',
      'active': 'Active (Aktif)',
      'very_active': 'Very Active (Sangat aktif)',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ACTIVITY LEVEL',
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
              value: _activityLevel,
              isExpanded: true,
              dropdownColor: const Color(0xFF2D2A4A),
              style: const TextStyle(color: Colors.white, fontSize: 15),
              iconEnabledColor: const Color(0xFFFFCC80),
              items: levels.entries
                  .map(
                    (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _activityLevel = v);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCaloriePreview() {
    final target = _calculateTarget();
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
            style: TextStyle(color: Color(0xFFFFCC80), fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            target > 0
                ? '${target.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} kCal'
                : '- kCal',
            style: const TextStyle(
              color: Colors.white,
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
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          letterSpacing: 1.2,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ProfileInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;

  const ProfileInput({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
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
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: const Color(0xFFFFCC80).withOpacity(0.7),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
