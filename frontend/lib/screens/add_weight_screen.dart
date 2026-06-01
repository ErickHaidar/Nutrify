import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrify/constants/colors.dart';
import 'package:nutrify/services/progress_api_service.dart';
import 'package:nutrify/di/service_locator.dart';
import 'package:nutrify/utils/locale/app_strings.dart';
import 'package:nutrify/widgets/nutrify_calendar_picker.dart';
import 'package:dio/dio.dart';
import 'package:nutrify/utils/dio/dio_error_util.dart';

class AddWeightScreen extends StatefulWidget {
  const AddWeightScreen({super.key});

  @override
  State<AddWeightScreen> createState() => AddWeightScreenState();
}

class AddWeightScreenState extends State<AddWeightScreen> {
  final ProgressApiService _apiService = getIt<ProgressApiService>();
  final _weightController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  String? _weightError;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _validateWeight(String value) {
    final w = double.tryParse(value);
    setState(() {
      if (value.isEmpty) {
        _weightError = null;
      } else if (w == null) {
        _weightError = 'Masukkan angka yang valid';
      } else if (w < 20) {
        _weightError = 'Minimal 20 kg';
      } else if (w > 500) {
        _weightError = 'Maksimal 500 kg';
      } else {
        _weightError = null;
      }
    });
  }

  Future<void> _saveWeight() async {
    final weight = double.tryParse(_weightController.text);
    if (weight == null || weight < 20 || weight > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan berat badan yang valid (20-500 kg)')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _apiService.storeWeight(
        weight: weight,
        date: _selectedDate,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berat badan berhasil dicatat'),
          backgroundColor: AppColors.navy,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      String message = 'Gagal menyimpan data. Coba lagi.';
      if (e is DioException) {
        message = DioExceptionUtil.handleError(e);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tambah Berat Badan',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Catat Berat Badan Harian',
              style: GoogleFonts.inter(
                color: AppColors.navy,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pantau progres berat badanmu setiap hari',
              style: GoogleFonts.inter(
                color: AppColors.navy.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Berat Badan',
              style: GoogleFonts.inter(
                color: AppColors.navy,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: _weightError != null ? Colors.red : AppColors.navy.withValues(alpha: 0.1),
                  width: _weightError != null ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(
                        color: _weightError != null ? Colors.red : AppColors.navy,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        hintText: '0.0',
                        hintStyle: TextStyle(
                          color: AppColors.navy.withValues(alpha: 0.25),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onChanged: _validateWeight,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(right: 20),
                    child: Text(
                      'kg',
                      style: GoogleFonts.inter(
                        color: AppColors.navy.withValues(alpha: 0.6),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_weightError != null)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  _weightError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 28),
            Text(
              'Tanggal',
              style: GoogleFonts.inter(
                color: AppColors.navy,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final picked = await showNutrifyDatePicker(
                  context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppColors.navy.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.navy, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      '${_selectedDate.day.toString().padLeft(2, '0')} ${AppStrings.monthNamesShort[_selectedDate.month - 1]} ${_selectedDate.year}',
                      style: GoogleFonts.inter(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _isSameDay(_selectedDate, DateTime.now())
                          ? 'Hari ini'
                          : _isSameDay(_selectedDate, DateTime.now().subtract(const Duration(days: 1)))
                              ? 'Kemarin'
                              : '',
                      style: GoogleFonts.inter(
                        color: AppColors.navy.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, color: AppColors.navy, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveWeight,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  disabledBackgroundColor: AppColors.navy.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
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
                    : const Text(
                        'Simpan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
