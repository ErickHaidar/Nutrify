<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Profile;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class ProfileController extends Controller
{
    // Menyimpan atau Update data fisik User
    public function store(Request $request)
    {
        $request->validate([
            'age' => 'required|integer|min:13|max:100',
            'weight' => 'required|integer|min:25|max:300',
            'height' => 'required|integer|min:100|max:250',
            'gender' => 'required|in:male,female',
            'activity_level' => 'required|in:sedentary,light,moderate,active,very_active',
            'goal' => 'required|in:cutting,maintenance,bulking',
            'target_weight' => 'nullable|integer|min:25|max:300', // Target berat badan
            'photo' => 'nullable|image|mimes:jpg,jpeg,png,webp|max:10240', // Opsional: max 10MB
        ]);

        // Ambil data profile tanpa photo
        $profileData = $request->only(['age', 'weight', 'height', 'gender', 'activity_level', 'goal', 'target_weight']);

        // Update atau buat profile
        $profile = Profile::updateOrCreate(
            ['user_id' => Auth::id()],
            $profileData
        );

        // Handle photo upload jika ada
        if ($request->hasFile('photo')) {
            // Hapus foto lama jika ada
            if ($profile->photo) {
                Storage::disk('public')->delete($profile->photo);
            }

            // Simpan foto baru
            $file = $request->file('photo');
            $extension = $file->getClientOriginalExtension();
            $filename = Auth::id() . '_' . time() . '.' . $extension;
            $path = $file->storeAs('profile-photos', $filename, 'public');

            // Update database dengan path foto
            $profile->update(['photo' => $path]);
        }

        return response()->json([
            'message' => 'Profile updated successfully',
            'data' => $profile
        ]);
    }

    // Upload dan update foto profil — PUT /api/profile/photo
    public function photo(Request $request)
    {
        // Validasi file yang diunggah
        $validator = Validator::make($request->all(), [
            'photo' => 'required|image|mimes:jpg,jpeg,png,webp|max:10240', // Maksimal 10 MB
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation Error',
                'errors' => $validator->errors()
            ], 422);
        }

        // Cari atau buat profile baru jika belum ada
        $profile = Profile::firstOrCreate(
            ['user_id' => Auth::id()],
            [
                'age' => 0,
                'weight' => 0,
                'height' => 0,
                'gender' => 'male',
                'goal' => 'maintenance',
                'activity_level' => 'sedentary',
                'photo' => null,
            ]
        );

        // Hapus foto lama jika ada
        if ($profile->photo) {
            Storage::disk('public')->delete($profile->photo);
        }

        // Simpan foto baru
        $file = $request->file('photo');
        $extension = $file->getClientOriginalExtension();
        $filename = Auth::id() . '_' . time() . '.' . $extension;

        $path = $file->storeAs('profile-photos', $filename, 'public');

        // Update database
        $profile->update([
            'photo' => $path
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Foto profil berhasil diperbarui.',
            'data' => [
                'photo_url' => 'https://nutrify-app.my.id/storage/' . $path
            ]
        ], 200);
    }

    // Mengambil data profile & Kalkulasi BMI serta TDEE
    public function show()
    {
        $user = User::with('profile')->find(Auth::id());

        if (!$user || !$user->profile) {
            return response()->json(['message' => 'Profile not found'], 404);
        }

        $profile = $user->profile;

        // 1. Kalkulasi BMI
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

        // 4. Penyesuaian Target Kalori
        $targetCalories = $tdee;
        if ($profile->goal == 'cutting') $targetCalories -= 500;
        if ($profile->goal == 'bulking') $targetCalories += 500;

        return response()->json([
            'status' => 'success',
            'user' => $user->name,
            'photo_url' => $profile->photo ? url('storage/' . $profile->photo) : null,
            'profile' => [
                'age' => $profile->age,
                'weight' => $profile->weight,
                'height' => $profile->height,
                'gender' => $profile->gender,
                'goal' => $profile->goal,
                'activity_level' => $profile->activity_level,
                'target_weight' => $profile->target_weight,
                'photo_url' => $profile->photo ? 'https://nutrify-app.my.id/storage/' . $profile->photo : null,
            ],
            'bmi' => round($bmiScore, 2),
            'bmi_status' => $this->getBmiStatus($bmiScore),
            'target_calories' => round($targetCalories),
            'maintenance_calories' => round($tdee),
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
