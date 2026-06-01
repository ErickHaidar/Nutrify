<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Profile;
use App\Models\User;
use App\Services\NutritionService;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class ProfileController extends Controller
{
    protected $nutritionService;

    public function __construct(NutritionService $nutritionService)
    {
        $this->nutritionService = $nutritionService;
    }

    // Save or Update user's physical data
    public function store(Request $request)
    {
        $request->validate([
            'age' => 'required|integer|min:13|max:100',
            'weight' => 'required|integer|min:25|max:300',
            'height' => 'required|integer|min:100|max:250',
            'gender' => 'required|in:male,female',
            'activity_level' => 'required|in:sedentary,light,moderate,active,very_active',
            'goal' => 'required|in:cutting,maintenance,bulking',
            'target_weight' => 'nullable|integer|min:25|max:300', // Target body weight
            'photo' => 'nullable|image|mimes:jpg,jpeg,png,webp|max:10240', // Optional: max 10MB
            'fcm_token' => 'nullable|string', // FCM token for push notifications
        ]);

        // Get profile data without photo
        $profileData = $request->only(['age', 'weight', 'height', 'gender', 'activity_level', 'goal', 'target_weight']);

        // Update or create profile
        $profile = Profile::updateOrCreate(
            ['user_id' => Auth::id()],
            $profileData
        );

        // Record weight in history log (updateOrCreate cegah duplikat per hari)
        if (isset($profileData['weight'])) {
            \App\Models\WeightLog::updateOrCreate(
                [
                    'user_id' => Auth::id(),
                    'created_at' => Carbon::now()->format('Y-m-d'),
                ],
                [
                    'weight' => $profileData['weight'],
                ]
            );
        }

        // Handle photo upload if any
        if ($request->hasFile('photo')) {
            // Delete old photo if exists
            if ($profile->photo) {
                Storage::disk('public')->delete($profile->photo);
            }

            // Save new photo
            $file = $request->file('photo');
            $extension = $file->getClientOriginalExtension();
            $filename = Auth::id() . '_' . str_replace('.', '', microtime(true)) . '.' . $extension;
            $path = $file->storeAs('profile-photos', $filename, 'public');

            // Update database with photo path
            $profile->update(['photo' => $path]);
        }

        // Handle FCM token update if any
        if ($request->has('fcm_token')) {
            $user = User::find(Auth::id());
            if ($user) {
                $user->update(['fcm_token' => $request->fcm_token]);
            }
        }

        return response()->json([
            'message' => 'Profile updated successfully',
            'data' => $profile
        ]);
    }

    // Upload and update profile photo — PUT /api/profile/photo
    public function photo(Request $request)
    {
        // Validate uploaded file
        $validator = Validator::make($request->all(), [
            'photo' => 'required|image|mimes:jpg,jpeg,png,webp|max:10240', // Maximum 10 MB
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation Error',
                'errors' => $validator->errors()
            ], 422);
        }

        // Find or create profile if not exists
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

        // Delete old photo if exists
        if ($profile->photo) {
            Storage::disk('public')->delete($profile->photo);
        }

        // Save new photo
        $file = $request->file('photo');
        $extension = $file->getClientOriginalExtension();
        $filename = Auth::id() . '_' . str_replace('.', '', microtime(true)) . '.' . $extension;

        $path = $file->storeAs('profile-photos', $filename, 'public');

        // Update database
        $profile->update([
            'photo' => $path
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Profile photo updated successfully.',
            'data' => [
                'photo_url' => url('storage/' . $path)
            ]
        ], 200);
    }

    // Get profile data & calculate BMI and TDEE
    public function show()
    {
        $user = User::with('profile')->find(Auth::id());

        if (!$user || !$user->profile) {
            return response()->json(['message' => 'Profile not found'], 404);
        }

        $profile = $user->profile;

        // 1. BMI Calculation
        $bmiScore = $this->nutritionService->calculateBmi($profile->weight, $profile->height);

        // 2. BMR Calculation (Mifflin-St Jeor)
        $bmr = $this->nutritionService->calculateBmr($profile->weight, $profile->height, $profile->age, $profile->gender);

        // 3. Activity Factor for TDEE
        $tdee = $this->nutritionService->calculateTdee($bmr, $profile->activity_level);

        // 4. Target Calories Adjustment
        $targetCalories = $this->nutritionService->calculateTargetCalories($tdee, $profile->goal);

        // 5. Macronutrient Recommendations
        $macros = $this->nutritionService->calculateMacros($targetCalories, $profile->weight, $profile->goal);

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
                'photo_url' => $profile->photo ? url('storage/' . $profile->photo) : null,
            ],
            'bmi' => round($bmiScore, 2),
            'bmi_status' => $this->nutritionService->getBmiStatus($bmiScore),
            'target_calories' => round($targetCalories),
            'maintenance_calories' => round($tdee),
            'macronutrients' => $macros,
            'physical_data' => [
                'age' => $profile->age,
                'weight' => $profile->weight . ' kg',
                'height' => $profile->height . ' cm',
                'bmi_score' => round($bmiScore, 2),
                'bmi_status' => $this->nutritionService->getBmiStatus($bmiScore),
            ],
            'nutrition_plan' => [
                'maintenance_calories' => round($tdee) . ' kcal',
                'daily_target_calories' => round($targetCalories) . ' kcal',
                'goal' => $profile->goal,
                'macronutrients' => $macros,
            ]
        ]);
    }

    // Update FCM token for push notifications
    public function updateFcmToken(Request $request)
    {
        $request->validate([
            'fcm_token' => 'required|string',
        ]);

        $user = User::find(Auth::id());
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User not found',
            ], 404);
        }

        $user->update(['fcm_token' => $request->fcm_token]);

        return response()->json([
            'success' => true,
            'message' => 'FCM token updated successfully',
            'fcm_token' => $user->fcm_token,
        ]);
    }
}
