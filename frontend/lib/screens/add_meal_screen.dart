import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/services/food_api_service.dart';
import 'package:boilerplate/services/food_log_api_service.dart';
import 'package:boilerplate/utils/meal_type_mapper.dart';
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
  Map<int, int> _loggedFoodIds = {}; // foodId -> logId

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
      final filteredList = logs.where((l) => l.mealTime == currentMealApi).toList();
      
      if (mounted) {
        setState(() {
          _allLogsForMeal = filteredList; // Store the full entries
          _loggedFoodIds = {for (var l in filteredList) l.foodId: l.id};
          
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
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // This callback is invoked when the system back button is pressed.
        // If didPop is true, the pop action has been handled by the system.
        // If result is null, it means Navigator.pop was not called with a result.
        // In this case, if _isDirty is true, we should signal a refresh to the previous screen.
        // However, since we explicitly call Navigator.pop(context, _isDirty) in the leading button,
        // this specific block might not be strictly necessary for our use case,
        // but it's good practice for system back button handling.
      },
      child: Scaffold(
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
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                      itemCount: _results.length,
                      itemBuilder: (_, i) => _buildFoodTile(_results[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodTile(FoodItem food) {
    return InkWell(
      onTap: () async {
        final isLogged = _loggedFoodIds.containsKey(food.id);
        
        if (isLogged) {
          // If already logged, tapping allows edit
          // Use cached log entry to avoid extra API call if possible
          final entry = _allLogsForMeal.firstWhere(
            (l) => l.foodId == food.id,
            orElse: () => FoodLogEntry(
              id: _loggedFoodIds[food.id]!,
              foodId: food.id,
              foodName: food.name,
              servingSize: food.servingSize,
              calories: food.calories,
              protein: food.protein,
              carbohydrates: food.carbohydrates,
              fat: food.fat,
              servingMultiplier: 1.0,
              mealTime: MealTypeMapper.toApi(_currentMealType),
              food: food,
            ),
          );
          
          if (!mounted) return;
          
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FoodDetailScreen(
                logEntry: entry,
                mealType: _currentMealType,
                date: widget.date ?? DateTime.now(),
              ),
            ),
          );
          setState(() => _isDirty = true); // Mark as dirty after edit
          _loadMealLogs(); // Always refresh after returning
        } else {
          // If not logged, tapping opens detail to add
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FoodDetailScreen(
                food: food,
                mealType: _currentMealType,
                date: widget.date ?? DateTime.now(),
              ),
            ),
          );
          if (result == true) {
            if (mounted) {
              setState(() {
                _isDirty = true; // Mark as dirty after add
              });
              _loadMealLogs();
            }
          }
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
              child: Checkbox(
                value: _loggedFoodIds.containsKey(food.id),
                onChanged: (val) async {
                  if (val == false) {
                    // Uncheck -> Delete
                    final logId = _loggedFoodIds[food.id];
                    if (logId != null) {
                      await _foodLogApi.deleteLog(logId);
                      setState(() => _isDirty = true);
                      _loadMealLogs();
                    }
                  } else {
                    // Check -> Open Detail to add
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FoodDetailScreen(
                          food: food,
                          mealType: _currentMealType,
                          date: widget.date ?? DateTime.now(),
                        ),
                      ),
                    );
                    if (result == true) {
                      _loadMealLogs();
                    }
                  }
                },
                activeColor: const Color(0xFFFFCC80),
                checkColor: NutrifyTheme.darkCard,
                side: const BorderSide(color: Colors.white38),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
