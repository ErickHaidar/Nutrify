<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\FoodLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;

class FoodLogController extends Controller
{
    // POST /api/food-logs
    public function store(Request $request)
    {
        $validated = $request->validate([
            'food_id'            => 'required|exists:foods,id',
            'serving_multiplier' => 'required|numeric|min:0.1',
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
            'message' => 'Makanan berhasil dicatat!',
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

        // Tambahkan target kalori dari profile (ID 13)
        $user = User::with('profile')->find($userId);
        $targetCalories = 0;
        
        $user = User::with('profile')->find($userId);
        $targetCalories = 0;
        
        if ($user && $user->profile) {
            $p = $user->profile;
            
            if ($p->height > 0 && $p->weight > 0 && $p->age > 0) {
                if ($p->gender == 'male') {
                    $bmr = (10 * $p->weight) + (6.25 * $p->height) - (5 * $p->age) + 5;
                } else {
                    $bmr = (10 * $p->weight) + (6.25 * $p->height) - (5 * $p->age) - 161;
                }
                $factors = ['sedentary' => 1.2, 'light' => 1.375, 'moderate' => 1.55, 'active' => 1.725, 'very_active' => 1.9];
                $tdee = $bmr * ($factors[$p->activity_level] ?? 1.2);
                $targetCalories = $tdee;
                if ($p->goal == 'cutting') $targetCalories -= 500;
                if ($p->goal == 'bulking') $targetCalories += 500;
                $targetCalories = round($targetCalories);
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
            return response()->json(['success' => false, 'message' => 'Log tidak ditemukan'], 404);
        }

        return response()->json(['success' => true, 'data' => $log]);
    }

    // PUT /api/food-logs/{id}
    public function update(Request $request, $id)
    {
        $log = FoodLog::where('id', $id)->where('user_id', Auth::id())->first();

        if (!$log) {
            return response()->json(['success' => false, 'message' => 'Log tidak ditemukan'], 404);
        }

        $validated = $request->validate([
            'serving_multiplier' => 'required|numeric|min:0.1',
            'unit'               => 'nullable|string',
            'meal_time'          => 'required|in:Breakfast,Lunch,Dinner,Snack',
        ]);

        $log->update($validated);
        $log->load('food');

        return response()->json([
            'success' => true,
            'message' => 'Log berhasil diperbarui',
            'data'    => $log
        ]);
    }

    // DELETE /api/food-logs/{id}
    public function destroy($id)
    {
        $log = FoodLog::where('id', $id)->where('user_id', Auth::id())->first();

        if (!$log) {
            return response()->json(['success' => false, 'message' => 'Log tidak ditemukan'], 404);
        }

        $log->delete();

        return response()->json(['success' => true, 'message' => 'Log berhasil dihapus']);
    }
}
