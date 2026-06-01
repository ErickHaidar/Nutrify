<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\FoodLog;
use App\Models\Profile;
use App\Models\User;
use App\Models\WeightLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Carbon\Carbon;

class ProgressController extends Controller
{
    public function calories(Request $request)
    {
        $userId = Auth::id();
        $range = $request->query('range', '7d');

        $days = match ($range) {
            '30d' => 30,
            default => 7,
        };

        $logs = FoodLog::with('food')
            ->where('user_id', $userId)
            ->whereDate('created_at', '>=', Carbon::now()->subDays($days - 1)->toDateString())
            ->get();

        $grouped = $logs->groupBy(function ($date) {
            return Carbon::parse($date->created_at)->format('Y-m-d');
        });

        $profile = Profile::where('user_id', $userId)->first();
        $target = $profile ? $profile->target_calories : null;

        $data = [];
        for ($i = $days - 1; $i >= 0; $i--) {
            $dateStr = Carbon::now()->subDays($i)->format('Y-m-d');
            $dayLogs = $grouped->get($dateStr, collect());

            $totalCalories = $dayLogs->sum(function ($log) {
                return $log->food ? ($log->food->calories * $log->serving_multiplier) : 0;
            });

            $data[] = [
                'date' => $dateStr,
                'calories' => round($totalCalories, 2),
            ];
        }

        return response()->json([
            'success' => true,
            'data' => $data,
            'target' => $target,
        ]);
    }

    public function weight(Request $request)
    {
        $userId = Auth::id();
        $range = $request->query('range', '7d');

        $days = match ($range) {
            '30d' => 30,
            default => 7,
        };

        $user = User::find($userId);
        $userCreatedAt = $user ? $user->created_at->startOfDay() : Carbon::now()->subDays($days - 1)->startOfDay();
        $windowStart = Carbon::now()->subDays($days - 1)->startOfDay();

        // Jangan tampilkan data sebelum user terdaftar
        $startDate = $userCreatedAt->gt($windowStart) ? $userCreatedAt->copy() : $windowStart->copy();

        // Ambil semua weight log dari startDate
        $logs = WeightLog::where('user_id', $userId)
            ->whereDate('created_at', '>=', $startDate->toDateString())
            ->orderBy('created_at', 'asc')
            ->get();

        // Tidak ada log sama sekali → return kosong (jangan fabricate dari profil)
        if ($logs->isEmpty()) {
            return response()->json([
                'success' => true,
                'data' => [],
            ]);
        }

        $grouped = $logs->groupBy(function ($log) {
            return Carbon::parse($log->created_at)->format('Y-m-d');
        });

        // Forward-fill hanya mulai dari log pertama yang benar-benar ada
        $firstLogDate = Carbon::parse($logs->first()->created_at)->startOfDay();
        $lastKnownWeight = null;

        $data = [];
        $current = $startDate->copy();
        $end = Carbon::now()->startOfDay();

        while ($current->lte($end)) {
            $dateStr = $current->format('Y-m-d');
            $dayLogs = $grouped->get($dateStr, collect());

            if ($dayLogs->isNotEmpty()) {
                $lastKnownWeight = $dayLogs->last()->weight;
            }

            // Hanya isi data mulai dari log pertama yang ada
            if ($lastKnownWeight !== null && $current->gte($firstLogDate)) {
                $data[] = [
                    'date' => $dateStr,
                    'weight' => round((float) $lastKnownWeight, 1),
                ];
            }

            $current->addDay();
        }

        return response()->json([
            'success' => true,
            'data' => $data,
        ]);
    }

    public function storeWeight(Request $request)
    {
        $request->validate([
            'weight' => 'required|numeric|min:20|max:500',
            'date' => 'nullable|date|before_or_equal:today',
        ], [
            'weight.required' => 'Berat badan wajib diisi.',
            'weight.numeric' => 'Berat badan harus berupa angka.',
            'weight.min' => 'Berat badan minimal 20 kg.',
            'weight.max' => 'Berat badan maksimal 500 kg.',
            'date.before_or_equal' => 'Tanggal tidak boleh di masa depan.',
        ]);

        $userId = Auth::id();
        $date = $request->input('date') ? Carbon::parse($request->input('date')) : Carbon::now();

        // Update or create weight log for the given date
        $log = WeightLog::updateOrCreate(
            [
                'user_id' => $userId,
                'created_at' => $date->format('Y-m-d'),
            ],
            [
                'weight' => $request->input('weight'),
            ]
        );

        // Also update profile weight if it's today
        if ($date->isToday()) {
            $profile = Profile::where('user_id', $userId)->first();
            if ($profile) {
                $profile->update(['weight' => $request->input('weight')]);
            }
        }

        return response()->json([
            'success' => true,
            'message' => 'Berat badan berhasil dicatat.',
            'data' => [
                'id' => $log->id,
                'weight' => round((float) $log->weight, 1),
                'date' => $log->created_at->format('Y-m-d'),
            ],
        ], 201);
    }
}
