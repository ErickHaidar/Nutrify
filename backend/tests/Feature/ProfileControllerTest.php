<?php

namespace Tests\Feature;

use App\Models\Profile;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ProfileControllerTest extends TestCase
{
    use RefreshDatabase;

    public function test_profile_store_creates_profile_successfully()
    {
        $user = $this->createAuthenticatedUser();

        $data = [
            'age' => 25,
            'weight' => 70,
            'height' => 170,
            'gender' => 'male',
            'activity_level' => 'moderate',
            'goal' => 'maintenance',
        ];

        $response = $this->withoutMiddleware()->postJson('/api/profile/store', $data);

        $response->assertStatus(200)
            ->assertJson([
                'message' => 'Profile updated successfully'
            ]);

        $this->assertDatabaseHas('profiles', [
            'user_id' => $user->id,
            'age' => 25,
            'weight' => 70,
            'height' => 170,
        ]);
    }

    public function test_profile_show_returns_bmi_and_tdee()
    {
        $user = $this->createAuthenticatedUser();
        
        Profile::create([
            'user_id' => $user->id,
            'age' => 25,
            'weight' => 70,
            'height' => 170,
            'gender' => 'male',
            'activity_level' => 'moderate',
            'goal' => 'maintenance',
        ]);

        $response = $this->withoutMiddleware()->getJson('/api/profile');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'status',
                'bmi',
                'target_calories',
                'macronutrients' => [
                    'protein',
                    'carbohydrates',
                    'fat'
                ]
            ]);
    }

    public function test_profile_show_returns_404_without_profile()
    {
        $this->createAuthenticatedUser();

        $response = $this->withoutMiddleware()->getJson('/api/profile');

        $response->assertStatus(404)
            ->assertJson(['message' => 'Profile not found']);
    }

    public function test_profile_store_validates_required_fields()
    {
        $this->createAuthenticatedUser();

        $response = $this->withoutMiddleware()->postJson('/api/profile/store', []);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['age', 'weight', 'height', 'gender', 'activity_level', 'goal']);
    }

    public function test_profile_bmi_calculation_is_correct()
    {
        $user = $this->createAuthenticatedUser();
        
        $weight = 70;
        $height = 170;
        $expectedBmi = round($weight / (($height / 100) ** 2), 2);

        Profile::create([
            'user_id' => $user->id,
            'age' => 25,
            'weight' => $weight,
            'height' => $height,
            'gender' => 'male',
            'activity_level' => 'moderate',
            'goal' => 'maintenance',
        ]);

        $response = $this->withoutMiddleware()->getJson('/api/profile');

        $response->assertStatus(200)
            ->assertJson([
                'bmi' => $expectedBmi
            ]);
    }

    public function test_profile_tdee_cutting_reduces_500_calories()
    {
        $user = $this->createAuthenticatedUser();
        
        // Let's use specific values to check calculation
        // Male: (10 * weight) + (6.25 * height) - (5 * age) + 5
        // Weight: 70, Height: 170, Age: 25
        // BMR = (10 * 70) + (6.25 * 170) - (5 * 25) + 5
        // BMR = 700 + 1062.5 - 125 + 5 = 1642.5
        // Activity Moderate: 1.55
        // TDEE = 1642.5 * 1.55 = 2545.875
        // Goal Cutting: TDEE - 500 = 2045.875 -> round = 2046
        
        Profile::create([
            'user_id' => $user->id,
            'age' => 25,
            'weight' => 70,
            'height' => 170,
            'gender' => 'male',
            'activity_level' => 'moderate',
            'goal' => 'cutting',
        ]);

        $response = $this->withoutMiddleware()->getJson('/api/profile');

        $response->assertStatus(200)
            ->assertJson([
                'target_calories' => 2046
            ]);
    }
}
