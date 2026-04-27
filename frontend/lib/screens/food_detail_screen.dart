// lib/screens/food_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrify/constants/colors.dart';
import 'package:nutrify/utils/meal_type_mapper.dart';
import 'package:nutrify/services/food_api_service.dart';
import 'package:nutrify/services/food_log_api_service.dart';
import 'package:nutrify/di/service_locator.dart';
import 'package:nutrify/services/notification_service.dart';

class FoodDetailScreen extends StatefulWidget {
  final FoodItem? food;
  final FoodLogEntry? logEntry;
  final String mealType;
  final DateTime? date;
  final bool batchMode; // Add this line

  const FoodDetailScreen({
    super.key,
    this.food,
    this.logEntry,
    this.date,
    required this.mealType,
    this.batchMode = false, // Add this line
  }) : assert(food != null || logEntry != null, 'Either food or logEntry must be provided');

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  final _amountController = TextEditingController();
  final _foodLogApi = FoodLogApiService();
  
  String _selectedUnit = 'Gram(g)'; // 'Gram(g)', 'Buah', 'Porsi'
  bool _isSaving = false;

  late String _foodName;
  late double _baseCalories;
  late double _baseProtein;
  late double _baseCarbos;
  late double _baseFat;

  @override
  void initState() {
    super.initState();
    if (widget.logEntry != null) {
      final log = widget.logEntry!;
      _foodName = log.foodName;
      // We need the base values (per 100g or per serving). 
      // Since FoodLogEntry stores calculated totals, we reverse it if needed.
      // But for simplicity, if we have logEntry, we assume the multiplier was for 'portion'.
      _baseCalories = log.calories / log.servingMultiplier;
      _baseProtein = log.protein / log.servingMultiplier;
      _baseCarbos = log.carbohydrates / log.servingMultiplier;
      _baseFat = log.fat / log.servingMultiplier;
      
      _amountController.text = log.servingMultiplier.toStringAsFixed(0);
      _selectedUnit = log.unit;
    } else {
      final f = widget.food!;
      _foodName = f.name;
      _baseCalories = f.calories;
      _baseProtein = f.protein;
      _baseCarbos = f.carbohydrates;
      _baseFat = f.fat;
      
      _amountController.text = '100';
      _selectedUnit = 'Gram(g)';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _currentAmount => double.tryParse(_amountController.text) ?? 0;

  double get _multiplier {
    if (_selectedUnit == 'Gram(g)') {
      return _currentAmount / 100.0;
    }
    return _currentAmount; // For Buah or Porsi
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    // Map meal type from Indonesian to English for backend compatibility
    String mealTimeMapped = MealTypeMapper.toApi(widget.mealType);

    try {
      if (widget.batchMode) {
        // If in batchMode, return the data instead of saving to API
        if (mounted) {
          Navigator.pop(context, {
            'multiplier': _multiplier,
            'unit': _selectedUnit,
          });
        }
        return;
      }

      if (widget.logEntry != null) {
        await _foodLogApi.updateLog(
          widget.logEntry!.id,
          servingMultiplier: _multiplier,
          mealTime: mealTimeMapped,
          unit: _selectedUnit,
        );
      } else {
        await _foodLogApi.logFood(
          foodId: widget.food!.id,
          servingMultiplier: _multiplier,
          mealTime: mealTimeMapped,
          unit: _selectedUnit,
          date: widget.date,
        );
      }
      
      // Reschedule notifications with updated menu
      await getIt<NotificationService>().scheduleMealReminders();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NutrifyTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.navy),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _foodName,
          style: GoogleFonts.montserrat(
            color: AppColors.navy, // Navy from new palette
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Input Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.peach,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  // Weight Input
                  Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.scale_outlined, color: AppColors.navy),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: AppColors.navy, fontSize: 18),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Unit Selection
                  Row(
                    children: [
                      Expanded(child: _buildUnitButton('Gram(g)')),
                      const SizedBox(width: 8),
                      Expanded(child: _buildUnitButton('Buah')),
                      const SizedBox(width: 8),
                      Expanded(child: _buildUnitButton('Porsi')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Info Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.peach,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informasi Gizi',
                    style: GoogleFonts.montserrat(
                      color: AppColors.navy,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildNutritionRow('Ukuran', '${_currentAmount.toStringAsFixed(0)} $_selectedUnit'),
                  _buildNutritionRow('Kalori', '${(_baseCalories * _multiplier).toStringAsFixed(0)} kkal'),
                  _buildNutritionRow('Protein', '${(_baseProtein * _multiplier).toStringAsFixed(2)}g'),
                  _buildNutritionRow('Karbo', '${(_baseCarbos * _multiplier).toStringAsFixed(2)}g'),
                  _buildNutritionRow('Lemak Total', '${(_baseFat * _multiplier).toStringAsFixed(2)}g'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Simpan Button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        widget.logEntry != null ? 'Edit' : 'Simpan',
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitButton(String unit) {
    bool isSelected = _selectedUnit == unit;
    return GestureDetector(
      onTap: () => setState(() => _selectedUnit = unit),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.navy : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? null : Border.all(color: AppColors.navy.withOpacity(0.2)),
        ),
        child: Center(
          child: Text(
            unit,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.navy,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.navy.withOpacity(0.7), fontSize: 16)),
          Text(value, style: const TextStyle(color: AppColors.navy, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
