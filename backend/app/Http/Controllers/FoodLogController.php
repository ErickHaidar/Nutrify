<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\FoodLog;
use App\Services\NutritionService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;

class FoodLogController extends Controller
{
    protected $nutritionService;

    public function __construct(NutritionService $nutritionService)
    {
        $this->nutritionService = $nutritionService;
    }

    // POST /api/food-logs
    public function store(Request $request)
    {
        $validated = $request->validate([
            'food_id'            => 'required|exists:foods,id',
            'serving_multiplier' => 'required|numeric|min:0.1|max:100',
            'unit'               => 'nullable|string',
            'meal_time'          => 'required|in:Breakfast,Lunch,Dinner,Snack',
            'date'               => 'nullable|date_format:Y-m-d',
        ]);

        $userId = Auth::id();
        $date   = $validated['date'] ?? now()->toDateString();

        // Prevent duplicates for the same food in the same meal today
        $log = FoodLog::where('user_id', $userId)
            ->where('food_id', $validated['food_id'])
            ->where('meal_time', $validated['meal_time'])
            ->whereDate('created_at', $date)
            ->first();

        if ($log) {
            $log->update([
                'serving_multiplier' => $validated['serving_multiplier'],
                'unit'               => $validated['unit'] ?? $log->unit
            ]);
        } else {
            $validated['user_id'] = $userId;
            $validated['created_at'] = $date;
            $log = FoodLog::create($validated);
        }

        $log->load('food');
        $totalCalories = $log->food->calories * $log->serving_multiplier;

        return response()->json([
            'success' => true,
            'message' => 'Food logged successfully!',
            'data'    => [
                'log'               => $log,
                'calories_consumed' => $totalCalories,
            ],
        ], 201);
    }

    // GET /api/food-logs?date=YYYY-MM-DD
    public function index(Request $request)
    {
        $date   = $request->query('date', now()->toDateString());
        $userId = Auth::id();

        $logs = FoodLog::with('food')
            ->where('user_id', $userId)
            ->whereDate('created_at', $date)
            ->orderBy('created_at')
            ->get();

        return response()->json(['success' => true, 'date' => $date, 'data' => $logs]);
    }

    // GET /api/food-logs/summary?date=YYYY-MM-DD
    public function summary(Request $request)
    {
        $date   = $request->query('date', now()->toDateString());
        $userId = Auth::id();

        $logs = FoodLog::with('food')
            ->where('user_id', $userId)
            ->whereDate('created_at', $date)
            ->get();

        $byMeal = $logs->groupBy('meal_time')->map(function ($group) {
            return [
                'total_calories'      => round($group->sum(fn($l) => $l->food->calories      * $l->serving_multiplier), 2),
                'total_protein'       => round($group->sum(fn($l) => $l->food->protein       * $l->serving_multiplier), 2),
                'total_carbohydrates' => round($group->sum(fn($l) => $l->food->carbohydrates * $l->serving_multiplier), 2),
                'total_fat'           => round($group->sum(fn($l) => $l->food->fat           * $l->serving_multiplier), 2),
                'entries'             => $group->count(),
            ];
        });

        $totals = [
            'total_calories'      => round($logs->sum(fn($l) => $l->food->calories      * $l->serving_multiplier), 2),
            'total_protein'       => round($logs->sum(fn($l) => $l->food->protein       * $l->serving_multiplier), 2),
            'total_carbohydrates' => round($logs->sum(fn($l) => $l->food->carbohydrates * $l->serving_multiplier), 2),
            'total_fat'           => round($logs->sum(fn($l) => $l->food->fat           * $l->serving_multiplier), 2),
        ];

        // Get target calories from profile using NutritionService
        $user = User::with('profile')->find($userId);
        $targetCalories = 0;
        
        if ($user && $user->profile) {
            $p = $user->profile;
            
            if ($p->height > 0 && $p->weight > 0 && $p->age > 0) {
                $bmr = $this->nutritionService->calculateBmr($p->weight, $p->height, $p->age, $p->gender);
                $tdee = $this->nutritionService->calculateTdee($bmr, $p->activity_level);
                $targetCalories = round($this->nutritionService->calculateTargetCalories($tdee, $p->goal));
            }
        }

        return response()->json([
            'status' => 'success',
            'date' => $date,
            'by_meal' => $byMeal,
            'totals' => $totals,
            'target_calories' => $targetCalories
        ]);
    }

    // GET /api/food-logs/{id}
    public function show($id)
    {
        $log = FoodLog::with('food')->where('id', $id)->where('user_id', Auth::id())->first();

        if (!$log) {
            return response()->json(['success' => false, 'message' => 'Log not found'], 404);
        }

        return response()->json(['success' => true, 'data' => $log]);
    }

    // PUT /api/food-logs/{id}
    public function update(Request $request, $id)
    {
        $log = FoodLog::with('food')->where('id', $id)->where('user_id', Auth::id())->first();

        if (!$log) {
            return response()->json(['success' => false, 'message' => 'Log not found'], 404);
        }

        $validated = $request->validate([
            'serving_multiplier' => 'required|numeric|min:0.1|max:100',
            'unit'               => 'nullable|string',
            'meal_time'          => 'required|in:Breakfast,Lunch,Dinner,Snack',
        ]);

        $log->update($validated);
        $log->load('food');

        return response()->json([
            'success' => true,
            'message' => 'Log updated successfully',
            'data'    => $log
        ]);
    }

    // DELETE /api/food-logs/{id}
    public function destroy($id)
    {
        $log = FoodLog::where('id', $id)->where('user_id', Auth::id())->first();

        if (!$log) {
            return response()->json(['success' => false, 'message' => 'Log not found'], 404);
        }

        $log->delete();

        return response()->json(['success' => true, 'message' => 'Log deleted successfully']);
    }
}
