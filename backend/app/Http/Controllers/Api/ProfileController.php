<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Profile;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ProfileController extends Controller
{
    // Menyimpan atau Update data fisik User (ID 7)
    public function store(Request $request)
    {
        $request->validate([
            'age' => 'required|integer',
            'weight' => 'required|numeric',
            'height' => 'required|numeric',
            'gender' => 'required|in:male,female',
            'activity_level' => 'required|in:sedentary,light,moderate,active,very_active',
            'goal' => 'required|in:cutting,maintenance,bulking',
        ]);

        // Simpan atau update berdasarkan user yang sedang login
        $profile = Profile::updateOrCreate(
            ['user_id' => Auth::id()],
            $request->all()
        );

        return response()->json([
            'message' => 'Profile updated successfully',
            'data' => $profile
        ]);
    }

    // Mengambil data profile & Kalkulasi BMI serta TDEE (ID 13)
    public function show()
    {
        // Ambil data user yang sedang login beserta profilenya
        $user = User::with('profile')->find(Auth::id());

        if (!$user || !$user->profile) {
            return response()->json(['message' => 'Profile not found'], 404);
        }

        $profile = $user->profile;

        // 1. Kalkulasi BMI: weight / (height/100)^2
        $heightInMeter = $profile->height / 100;
        $bmiScore = $profile->weight / ($heightInMeter * $heightInMeter);

        // 2. Kalkulasi BMR (Mifflin-St Jeor)
        if ($profile->gender == 'male') {
            $bmr = (10 * $profile->weight) + (6.25 * $profile->height) - (5 * $profile->age) + 5;
        } else {
            $bmr = (10 * $profile->weight) + (6.25 * $profile->height) - (5 * $profile->age) - 161;
        }

        // 3. Faktor Aktivitas untuk TDEE
        $factors = [
            'sedentary' => 1.2,
            'light' => 1.375,
            'moderate' => 1.55,
            'active' => 1.725,
            'very_active' => 1.9
        ];
        $tdee = $bmr * ($factors[$profile->activity_level] ?? 1.2);

        // 4. Penyesuaian Target Kalori berdasarkan Goal
        $targetCalories = $tdee;
        if ($profile->goal == 'cutting') $targetCalories -= 500;
        if ($profile->goal == 'bulking') $targetCalories += 500;

        return response()->json([
            'status' => 'success',
            'user' => $user->name,
            // Raw profile data for editing
            'profile' => [
                'age' => $profile->age,
                'weight' => $profile->weight,
                'height' => $profile->height,
                'gender' => $profile->gender,
                'goal' => $profile->goal,
                'activity_level' => $profile->activity_level,
            ],
            'bmi' => round($bmiScore, 2),
            'bmi_status' => $this->getBmiStatus($bmiScore),
            'target_calories' => round($targetCalories),
            'maintenance_calories' => round($tdee),
            // Legacy display fields
            'physical_data' => [
                'age' => $profile->age,
                'weight' => $profile->weight . ' kg',
                'height' => $profile->height . ' cm',
                'bmi_score' => round($bmiScore, 2),
                'bmi_status' => $this->getBmiStatus($bmiScore),
            ],
            'nutrition_plan' => [
                'maintenance_calories' => round($tdee) . ' kcal',
                'daily_target_calories' => round($targetCalories) . ' kcal',
                'goal' => $profile->goal
            ]
        ]);
    }

    // Helper untuk menentukan status BMI
    private function getBmiStatus($bmi)
    {
        if ($bmi < 18.5) return 'Underweight';
        if ($bmi < 25) return 'Normal';
        if ($bmi < 30) return 'Overweight';
        return 'Obese';
    }
}
