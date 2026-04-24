import 'package:flutter/material.dart';
import '../widgets/nutrify_calendar_picker.dart';
import '../widgets/custom_input.dart';
import '../widgets/activity_tile.dart';
import 'package:nutrify/constants/colors.dart';

class BodyDataScreen extends StatefulWidget {
  const BodyDataScreen({super.key});
  @override
  State<BodyDataScreen> createState() => _BodyDataScreenState();
}

class _BodyDataScreenState extends State<BodyDataScreen> {
  DateTime? _birthDate;
  String _selectedActivity = 'moderate'; // matched with state logic if any

  String _birthDateText() {
    if (_birthDate == null) return 'Pilih tanggal lahir';
    final d = _birthDate!;
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
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
        title: const Text('Data Tubuh dan Target', style: TextStyle(fontSize: 18, color: AppColors.navy, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text('Informasi Personal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy)),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(child: CustomInputField(label: 'Tinggi Badan (cm)', initialValue: '175')),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomInputField(
                    label: 'Tanggal Lahir',
                    initialValue: _birthDate == null ? 'Pilih' : _birthDateText(),
                    onTap: _showBirthDatePicker,
                    readOnly: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(child: CustomInputField(label: 'Berat Badan Saat Ini (kg)', initialValue: '70')),
                const SizedBox(width: 16),
                Expanded(child: CustomInputField(label: 'Target Berat Badan (kg)', initialValue: '65')),
              ],
            ),
            const SizedBox(height: 30),
            const Text('Aktivitas Harian', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy)),
            const SizedBox(height: 15),
            ActivitySelectionTile(
              title: 'Moderately Active',
              subtitle: '3-5 hari olahraga/minggu',
              icon: Icons.fitness_center,
              isSelected: _selectedActivity == 'moderate',
              onTap: () => setState(() => _selectedActivity = 'moderate'),
            ),
            ActivitySelectionTile(
              title: 'Highly Active',
              subtitle: '6-7 hari olahraga intensif',
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
                child: const Text('Simpan Profil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 30),
          ],
        ),
      ),
    );
  }
}
