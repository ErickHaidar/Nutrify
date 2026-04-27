import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrify/constants/colors.dart';
import 'package:nutrify/services/food_api_service.dart';
import 'package:nutrify/services/food_log_api_service.dart';
import 'package:nutrify/utils/meal_type_mapper.dart';
import 'food_detail_screen.dart';
import 'package:nutrify/constants/assets.dart';
import 'package:nutrify/di/service_locator.dart';
import 'package:nutrify/services/notification_service.dart';

class AddMealScreen extends StatefulWidget {
  final String mealType;
  final DateTime? date;

  const AddMealScreen({super.key, required this.mealType, this.date});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _searchController = TextEditingController();
  final _foodApi = FoodApiService();
  final _foodLogApi = FoodLogApiService();
  late String _currentMealType;
  Map<int, int> _initialLoggedIds = {}; // foodId -> logId at start
  Map<int, DraftSelection> _draftSelections = {}; // foodId -> draft info
  bool _isSavingBatch = false;

  List<FoodItem> _results = [];
  List<FoodLogEntry> _allLogsForMeal = []; // Add this to cache full entries
  bool _isSearching = false;
  Timer? _debounce;
  bool _isDirty = false; // Flag to indicate if something changed

  @override
  void initState() {
    super.initState();
    _currentMealType = widget.mealType;
    _loadMealLogs();
  }

  Future<void> _loadMealLogs() async {
    try {
      final logs = await _foodLogApi.getLogs(widget.date ?? DateTime.now());
      final currentMealApi = MealTypeMapper.toApi(_currentMealType);
      final filteredList =
          logs.where((l) => l.mealTime == currentMealApi).toList();

      if (mounted) {
        setState(() {
          _allLogsForMeal = filteredList; // Store the full entries
          _initialLoggedIds = {for (var l in filteredList) l.foodId: l.id};
          // Initialize draft with what's currently in DB
          _draftSelections = {
            for (var l in filteredList)
              l.foodId: DraftSelection(
                multiplier: l.servingMultiplier,
                unit: l.unit,
                logId: l.id,
              )
          };

          // If search is empty, show logged foods as results
          if (_searchController.text.isEmpty) {
            final Set<int> seenIds = {};
            _results = [];
            for (var l in filteredList) {
              if (l.food != null && !seenIds.contains(l.foodId)) {
                _results.add(l.food!);
                seenIds.add(l.foodId);
              }
            }
          }
        });
      }
    } catch (e) {
      // Error loading meal logs
    }
  }

  Future<void> _handleConfirmBatch() async {
    if (_isSavingBatch) return;
    setState(() => _isSavingBatch = true);

    final mealTimeApi = MealTypeMapper.toApi(_currentMealType);
    final date = widget.date ?? DateTime.now();

    try {
      final List<Future> operations = [];

      // 1. ADD or UPDATE items that are in draft
      _draftSelections.forEach((foodId, draft) {
        if (!_initialLoggedIds.containsKey(foodId)) {
          // NEW -> POST
          operations.add(_foodLogApi.logFood(
            foodId: foodId,
            servingMultiplier: draft.multiplier,
            mealTime: mealTimeApi,
            unit: draft.unit,
            date: date,
          ));
        } else {
          // Might be UPDATE if values changed
          final logId = _initialLoggedIds[foodId]!;
          final original = _allLogsForMeal.firstWhere((l) => l.id == logId);
          if (original.servingMultiplier != draft.multiplier ||
              original.unit != draft.unit) {
            operations.add(_foodLogApi.updateLog(
              logId,
              servingMultiplier: draft.multiplier,
              mealTime: mealTimeApi,
              unit: draft.unit,
            ));
          }
        }
      });

      // 2. DELETE items that were in DB but not in draft
      _initialLoggedIds.forEach((foodId, logId) {
        if (!_draftSelections.containsKey(foodId)) {
          operations.add(_foodLogApi.deleteLog(logId));
        }
      });

      if (operations.isNotEmpty) {
        await Future.wait(operations);
        _isDirty = true;
        
        // Reschedule notifications with updated menu
        await getIt<NotificationService>().scheduleMealReminders();
      }

      if (mounted) {
        Navigator.pop(context, _isDirty);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSavingBatch = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() {
        _isSearching = false;
      });
      _loadMealLogs(); // Restore logged foods list
      return;
    }
    _debounce = Timer(
      const Duration(milliseconds: 500),
      () => _search(value.trim()),
    );
  }

Future<void> _search(String query) async {
setState(() => _isSearching = true);
try {
final r = await _foodApi.searchFoods(query);
if (mounted) {
setState(() {
_results = r;
_isSearching = false;
});
}
} catch (_) {
if (mounted) {
setState(() {
_results = [];
_isSearching = false;
});
}
}
}

  void _showTutorialDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF4A446F), // Muted Indigo from Card Panduan.png
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Panduan Menambah Makanan',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildTutorialStep(
                '1. ',
                'Cari Makanan',
                ' : Ketik menu makanan atau minuman anda.',
                null,
                'assets/images/Gambar Search (1).png',
                customImageWidth: 90,
              ),
              _buildTutorialStep(
                '2. ',
                'Tambah cepat',
                ' : Centang kotak checklist di kanan.',
                '(Menggunakan porsi template standar, tidak mengedit)',
                'assets/images/Tambah Cepat (2).png',
                customImageWidth: 95,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'Atau',
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFFFFD1A4),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildTutorialStep(
                '2. ',
                'Atur Manual',
                ' : Klik area tengah kotak makanan.',
                '(Sesuaikan takaran porsi (gram/buah) sebelum simpan)',
                'assets/images/Atur Manual (2).png',
                customImageWidth: 95,
              ),
              _buildTutorialStep(
                '3. ',
                'Simpan',
                ' : Ketuk tombol ceklish disebelah pojok kanan bawah untuk simpan.\\n(Untuk Mencatat Kalori Anda)',
                null,
                'assets/images/Simpan.png',
                customImageWidth: 60,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD1A4), // Light Peach from Mengerti.png
                    foregroundColor: const Color(0xFF2D3154), // Dark Navy text from Mengerti.png
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: Text('Mengerti',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTutorialStep(String number, String title, String description, String? subtitle, String imagePath, {double? customImageWidth}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Illustration Box - transparent background, fixed size to prevent overflow
          SizedBox(
            width: 110,
            height: 70,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  imagePath,
                  width: customImageWidth ?? 110,
                  height: 70,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Text Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(
                        text: number,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: title,
                        style: const TextStyle(
                          color: Color(0xFFFFD1A4), // Peach title
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(text: description),
                    ],
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: GoogleFonts.montserrat(
                      color: const Color(0xFFA09CB5), // Muted color for subtitles
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NutrifyTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Tambah $_currentMealType',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.navy),
          onPressed: () => Navigator.pop(context, _isDirty),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.info_outline,
              color: AppColors.navy,
            ),
            onPressed: _showTutorialDialog,
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
        children: [
          // Search bar (styled with new palette)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // White background for search bar
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: const TextStyle(color: AppColors.navy),
                decoration: InputDecoration(
                  hintText: 'Cari makanan...',
                  hintStyle: const TextStyle(color: Colors.black38),
                  prefixIcon: const Icon(Icons.search, color: AppColors.navy),
                  suffixIcon: _isSearching
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),

          // Results list
          Expanded(
            child: (_results.isEmpty && !_isSearching)
                ? Center(
                    child: Text(
                      _searchController.text.isEmpty
                          ? 'Belum ada makanan yang ditambahkan'
                          : 'Tidak ada hasil ditemukan',
                      style: TextStyle(
                        color: AppColors.navy.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 80),
                    itemCount: _results.length,
                    itemBuilder: (_, i) => _buildFoodTile(_results[i]),
                  ),
          ),
        ],
      ),
    ),
      floatingActionButton: _isSavingBatch
          ? const FloatingActionButton(
              onPressed: null,
              backgroundColor: Colors.grey,
              child: CircularProgressIndicator(color: Colors.white),
            )
          : (_draftSelections.isEmpty
              ? null
              : FloatingActionButton.large(
                  onPressed: _handleConfirmBatch,
                  // Dark Navy FAB with white checkmark
                  backgroundColor: AppColors.navy,
                  child: const Icon(Icons.check, color: Colors.white),
                )),
    );
  }

  Widget _buildFoodTile(FoodItem food) {
    DraftSelection? currentDraft = _draftSelections[food.id];
    FoodLogEntry? existingLog =
        _allLogsForMeal.where((l) => l.foodId == food.id).firstOrNull;

    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodDetailScreen(
              food: existingLog == null ? food : null,
              logEntry: existingLog,
              mealType: _currentMealType,
              date: widget.date ?? DateTime.now(),
              batchMode: true,
            ),
          ),
        );

        if (result is Map<String, dynamic>) {
          setState(() {
            _draftSelections[food.id] = DraftSelection(
              multiplier: result['multiplier'] as double,
              unit: result['unit'] as String,
              logId: currentDraft?.logId,
            );
          });
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.peach,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.restaurant, color: AppColors.navy, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${food.calories.toStringAsFixed(0)} kcal · ${food.servingSize}',
                    style: TextStyle(color: AppColors.navy.withOpacity(0.6), fontSize: 12),
                  ),
                ],
              ),
            ),
            Transform.scale(
              scale: 0.9,
              child: _buildTrailingWidget(food),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailingWidget(FoodItem food) {
    final isSelected = _draftSelections.containsKey(food.id);
    final isInitiallyLogged = _initialLoggedIds.containsKey(food.id);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Show Trash Icon only for existing items to allow immediate delete
        if (isInitiallyLogged)
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: Colors.redAccent, size: 20),
            onPressed: () async {
              final logId = _initialLoggedIds[food.id];
              if (logId != null) {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppColors.cream,
                    title: const Text('Hapus Makanan', style: TextStyle(color: AppColors.navy)),
                    content: Text(
                        'Apakah Anda yakin ingin menghapus makanan ini dari riwayat?', style: TextStyle(color: AppColors.navy.withOpacity(0.7))),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text('Batal',
                            style: TextStyle(color: AppColors.navy.withOpacity(0.5))),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Hapus',
                            style: TextStyle(color: Colors.redAccent)),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await _foodLogApi.deleteLog(logId!);
                  _isDirty = true;
                  await getIt<NotificationService>().scheduleMealReminders();
                  _loadMealLogs();
                }
              }
            },
          ),
        // Always show checkbox for batch selection
        Checkbox(
          value: isSelected,
          onChanged: (val) {
            setState(() {
              if (val == true) {
                final existingLog = _allLogsForMeal
                    .where((l) => l.foodId == food.id)
                    .firstOrNull;
                _draftSelections[food.id] = DraftSelection(
                  multiplier: existingLog?.servingMultiplier ?? 1.0,
                  unit: existingLog?.unit ?? 'Gram(g)',
                  logId: existingLog?.id,
                );
              } else {
                _draftSelections.remove(food.id);
              }
            });
          },
          // Custom checkbox style to match new palette
          fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return AppColors.navy; // Navy fill when selected
            }
            return AppColors.peach; // Peach background when not selected
          }),
          side: BorderSide(color: AppColors.navy),
          checkColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

class DraftSelection {
  final double multiplier;
  final String unit;
  final int? logId;

  DraftSelection({
    required this.multiplier,
    required this.unit,
    this.logId,
  });
}
