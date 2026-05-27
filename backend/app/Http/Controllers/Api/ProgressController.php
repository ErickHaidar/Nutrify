<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\FoodLog;
use App\Models\Profile;
use Illuminate\Support\Facades\Auth;
use Carbon\Carbon;

class ProgressController extends Controller
{
    public function calories(Request $request)
    {
        $userId = Auth::id();
        
        // Get last 7 days of calories using whereDate for database timezone safety
        $logs = FoodLog::with('food')
            ->where('user_id', $userId)
            ->whereDate('created_at', '>=', Carbon::now()->subDays(6)->toDateString())
            ->get();
            
        $grouped = $logs->groupBy(function($date) {
            return Carbon::parse($date->created_at)->format('Y-m-d');
        });
        
        $data = [];
        
        // Fill last 7 days
        for ($i = 6; $i >= 0; $i--) {
            $dateStr = Carbon::now()->subDays($i)->format('Y-m-d');
            $dayLogs = $grouped->get($dateStr, collect());
            
            $totalCalories = $dayLogs->sum(function($log) {
                return $log->food ? ($log->food->calories * $log->serving_multiplier) : 0;
            });
            
            $data[] = [
                'date' => $dateStr,
                'calories' => round($totalCalories, 2)
            ];
        }
        
        return response()->json([
            'success' => true,
            'data' => $data
        ]);
    }
    
    public function weight(Request $request)
    {
        $userId = Auth::id();
        
        // Fetch weight logs for the last 7 days (wrap in try-catch for production safety)
        try {
            $logs = \App\Models\WeightLog::where('user_id', $userId)
                ->whereDate('created_at', '>=', Carbon::now()->subDays(6)->toDateString())
                ->orderBy('created_at', 'asc')
                ->get();
        } catch (\Exception $e) {
            $logs = collect();
        }

        // Fallback: If no weight logs exist for the user at all, create one from their current profile weight
        if ($logs->isEmpty()) {
            $profile = Profile::where('user_id', $userId)->first();
            if ($profile && $profile->weight > 0) {
                try {
                    $initialLog = \App\Models\WeightLog::create([
                        'user_id' => $userId,
                        'weight' => $profile->weight,
                        'created_at' => Carbon::now(),
                    ]);
                    $logs = collect([$initialLog]);
                } catch (\Exception $e) {
                    // Ignore if insert fails due to missing table
                }
            }
        }
        
        $grouped = $logs->groupBy(function($date) {
            return Carbon::parse($date->created_at)->format('Y-m-d');
        });
        
        $data = [];
        
        // Find the last known weight before the 7 days window (as a baseline)
        $lastKnownWeight = null;
        try {
            $baselineLog = \App\Models\WeightLog::where('user_id', $userId)
                ->whereDate('created_at', '<', Carbon::now()->subDays(6)->toDateString())
                ->orderBy('created_at', 'desc')
                ->first();
            if ($baselineLog) {
                $lastKnownWeight = $baselineLog->weight;
            }
        } catch (\Exception $e) {
            // Table doesn't exist
        }
        
        if ($lastKnownWeight === null) {
            $profile = Profile::where('user_id', $userId)->first();
            if ($profile) {
                $lastKnownWeight = $profile->weight;
            }
        }
        
        // Fill last 7 days
        for ($i = 6; $i >= 0; $i--) {
            $dateStr = Carbon::now()->subDays($i)->format('Y-m-d');
            $dayLogs = $grouped->get($dateStr, collect());
            
            if ($dayLogs->isNotEmpty()) {
                $lastKnownWeight = $dayLogs->last()->weight;
                $data[] = [
                    'date' => $dateStr,
                    'weight' => round($lastKnownWeight, 1)
                ];
            } else if ($lastKnownWeight !== null) {
                $data[] = [
                    'date' => $dateStr,
                    'weight' => round($lastKnownWeight, 1)
                ];
            }
        }
        
        return response()->json([
            'success' => true,
            'data' => $data
        ]);
    }
}
