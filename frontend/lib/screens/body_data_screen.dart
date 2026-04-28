import 'package:flutter/material.dart';
import '../widgets/nutrify_calendar_picker.dart';
import '../widgets/custom_input.dart';
import '../widgets/activity_tile.dart';
import 'package:nutrify/constants/colors.dart';
import 'package:nutrify/utils/locale/app_strings.dart';

class BodyDataScreen extends StatefulWidget {
  const BodyDataScreen({super.key});
  @override
  State<BodyDataScreen> createState() => _BodyDataScreenState();
}

class _BodyDataScreenState extends State<BodyDataScreen> {
  DateTime? _birthDate;
  String _selectedActivity = 'moderate'; // matched with state logic if any

  String _birthDateText() {
    if (_birthDate == null) return AppStrings.selectBirthDate;
    final d = _birthDate!;
    final months = AppStrings.monthNames;
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _showBirthDatePicker() async {
    final picked = await showNutrifyDatePicker(
      context,
      initialDate: _birthDate ?? DateTime(DateTime.now().year - 20),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.navy),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Text(AppStrings.bodyDataGoals, style: const TextStyle(fontSize: 18, color: AppColors.navy, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(AppStrings.personalInfo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: CustomInputField(label: AppStrings.heightBodyCm, initialValue: '175')),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomInputField(
                    label: AppStrings.birthDateLabel,
                    initialValue: _birthDate == null ? AppStrings.selectDate : _birthDateText(),
                    onTap: _showBirthDatePicker,
                    readOnly: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: CustomInputField(label: AppStrings.weightBodyKg, initialValue: '70')),
                const SizedBox(width: 16),
                Expanded(child: CustomInputField(label: '${AppStrings.target} ${AppStrings.weightBodyKg}', initialValue: '65')),
              ],
            ),
            const SizedBox(height: 30),
            Text(AppStrings.dailyActivity, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy)),
            const SizedBox(height: 15),
            ActivitySelectionTile(
              title: AppStrings.moderatelyActive,
              subtitle: AppStrings.moderatelyActiveSub,
              icon: Icons.fitness_center,
              isSelected: _selectedActivity == 'moderate',
              onTap: () => setState(() => _selectedActivity = 'moderate'),
            ),
            ActivitySelectionTile(
              title: AppStrings.highlyActive,
              subtitle: AppStrings.highlyActiveSub,
              icon: Icons.bolt,
              isSelected: _selectedActivity == 'highly',
              onTap: () => setState(() => _selectedActivity = 'highly'),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text(AppStrings.saveProfile, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 30),
          ],
        ),
      ),
    );
  }
}
