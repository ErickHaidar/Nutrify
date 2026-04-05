import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrify/constants/colors.dart';
import 'package:nutrify/services/food_api_service.dart';
import 'package:nutrify/services/food_log_api_service.dart';
import 'package:nutrify/utils/meal_type_mapper.dart';
import 'food_detail_screen.dart';

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
      debugPrint('Error loading meal logs: $e');
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
            color: NutrifyTheme.accentOrange,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, _isDirty),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: NutrifyTheme.accentOrange,
            ),
            offset: const Offset(0, 50),
            color: NutrifyTheme.darkCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            onSelected: (value) {
              setState(() => _currentMealType = value);
              _loadMealLogs();
            },
            itemBuilder: (context) =>
                ['Makan Pagi', 'Makan Siang', 'Makan Malam', 'Cemilan']
                    .map(
                      (choice) => PopupMenuItem<String>(
                        value: choice,
                        child: Text(
                          choice,
                          style: TextStyle(
                            color: choice == _currentMealType
                                ? NutrifyTheme.accentOrange
                                : Colors.white,
                            fontWeight: choice == _currentMealType
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Cari makanan...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
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
                      style: const TextStyle(
                        color: Colors.white54,
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
      floatingActionButton: _isSavingBatch
          ? const FloatingActionButton(
              onPressed: null,
              backgroundColor: Colors.grey,
              child: CircularProgressIndicator(color: Colors.white),
            )
          : (_draftSelections.isEmpty
              ? null
              : FloatingActionButton(
                  onPressed: _handleConfirmBatch,
                  backgroundColor: const Color(0xFFFFCC80),
                  child: const Icon(Icons.check, color: Color(0xFF2D2A4A)),
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
          color: NutrifyTheme.darkCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.restaurant, color: Color(0xFFFFCC80), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${food.calories.toStringAsFixed(0)} kcal · ${food.servingSize}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
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
                    backgroundColor: NutrifyTheme.darkCard,
                    title: const Text('Hapus Makanan',
                        style: TextStyle(color: Colors.white)),
                    content: const Text(
                        'Apakah Anda yakin ingin menghapus makanan ini dari riwayat?',
                        style: TextStyle(color: Colors.white70)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Batal',
                            style: TextStyle(color: Colors.white54)),
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
                  await _foodLogApi.deleteLog(logId);
                  _isDirty = true;
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
          activeColor: const Color(0xFFFFCC80),
          checkColor: NutrifyTheme.darkCard,
          side: const BorderSide(color: Colors.white38),
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
