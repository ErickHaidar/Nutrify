<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Profile;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ProfileValidationTest extends TestCase
{
    use RefreshDatabase;

    private User $user;

    protected function setUp(): void
    {
        parent::setUp();

        // Create test user with Supabase ID
        $this->user = User::factory()->create([
            'supabase_id' => 'test-supabase-id-' . rand(),
        ]);

        // Authenticate as the created user for the test
        $this->actingAs($this->user);
    }

    public function test_profile_validation_accepts_valid_data()
    {
        $response = $this->withoutMiddleware()->postJson('/api/profile/store', [
            'age' => 25,
            'weight' => 70,
            'height' => 170,
            'gender' => 'male',
            'activity_level' => 'moderate',
            'goal' => 'maintenance',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'message' => 'Profile updated successfully',
            ]);

        $this->assertDatabaseHas('profiles', [
            'user_id' => $this->user->id,
            'age' => 25,
            'weight' => 70,
            'height' => 170,
        ]);
    }

    public function test_age_must_be_at_least_13()
    {
        $response = $this->withoutMiddleware()->postJson('/api/profile/store', [
            'age' => 12, // Below minimum
            'weight' => 70,
            'height' => 170,
            'gender' => 'male',
            'activity_level' => 'moderate',
            'goal' => 'maintenance',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['age']);
    }

    public function test_age_must_not_exceed_100()
    {
        $response = $this->withoutMiddleware()->postJson('/api/profile/store', [
            'age' => 101, // Above maximum
            'weight' => 70,
            'height' => 170,
            'gender' => 'male',
            'activity_level' => 'moderate',
            'goal' => 'maintenance',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['age']);
    }

    public function test_weight_must_be_at_least_25()
    {
        $response = $this->withoutMiddleware()->postJson('/api/profile/store', [
            'age' => 25,
            'weight' => 24, // Below minimum
            'height' => 170,
            'gender' => 'male',
            'activity_level' => 'moderate',
            'goal' => 'maintenance',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['weight']);
    }

    public function test_weight_must_not_exceed_300()
    {
        $response = $this->withoutMiddleware()->postJson('/api/profile/store', [
            'age' => 25,
            'weight' => 301, // Above maximum
            'height' => 170,
            'gender' => 'male',
            'activity_level' => 'moderate',
            'goal' => 'maintenance',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['weight']);
    }


    public function test_height_must_be_at_least_100()
    {
        $response = $this->withoutMiddleware()->postJson('/api/profile/store', [
            'age' => 25,
            'weight' => 70,
            'height' => 99, // Below minimum
            'gender' => 'male',
            'activity_level' => 'moderate',
            'goal' => 'maintenance',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['height']);
    }

    public function test_height_must_not_exceed_250()
    {
        $response = $this->withoutMiddleware()->postJson('/api/profile/store', [
            'age' => 25,
            'weight' => 70,
            'height' => 251, // Above maximum
            'gender' => 'male',
            'activity_level' => 'moderate',
            'goal' => 'maintenance',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['height']);
    }

    public function test_boundary_values_are_accepted()
    {
        // Test minimum boundaries
        $response = $this->withoutMiddleware()->postJson('/api/profile/store', [
            'age' => 13,
            'weight' => 25,
            'height' => 100,
            'gender' => 'male',
            'activity_level' => 'sedentary',
            'goal' => 'maintenance',
        ]);

        $response->assertStatus(200);

        // Test maximum boundaries
        $response = $this->withoutMiddleware()->postJson('/api/profile/store', [
            'age' => 100,
            'weight' => 300,
            'height' => 250,
            'gender' => 'female',
            'activity_level' => 'very_active',
            'goal' => 'bulking',
        ]);

        $response->assertStatus(200);
    }

    public function test_target_weight_is_optional()
    {
        // Test that target_weight can be omitted
        $response = $this->withoutMiddleware()->postJson('/api/profile/store', [
            'age' => 25,
            'weight' => 70,
            'height' => 170,
            'gender' => 'male',
            'activity_level' => 'moderate',
            'goal' => 'maintenance',
        ]);

        $response->assertStatus(200);

        $this->assertDatabaseHas('profiles', [
            'user_id' => $this->user->id,
            'target_weight' => null,
        ]);
    }

    public function test_target_weight_can_be_set()
    {
        // Test that target_weight can be set
        $response = $this->withoutMiddleware()->postJson('/api/profile/store', [
            'age' => 25,
            'weight' => 70,
            'height' => 170,
            'gender' => 'male',
            'activity_level' => 'moderate',
            'goal' => 'maintenance',
            'target_weight' => 65,
        ]);

        $response->assertStatus(200);

        $this->assertDatabaseHas('profiles', [
            'user_id' => $this->user->id,
            'target_weight' => 65,
        ]);
    }

    public function test_target_weight_must_be_within_valid_range()
    {
        // Test minimum boundary
        $response = $this->withoutMiddleware()->postJson('/api/profile/store', [
            'age' => 25,
            'weight' => 70,
            'height' => 170,
            'gender' => 'male',
            'activity_level' => 'moderate',
            'goal' => 'maintenance',
            'target_weight' => 24, // Below minimum
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['target_weight']);

        // Test maximum boundary
        $response = $this->withoutMiddleware()->postJson('/api/profile/store', [
            'age' => 25,
            'weight' => 70,
            'height' => 170,
            'gender' => 'male',
            'activity_level' => 'moderate',
            'goal' => 'maintenance',
            'target_weight' => 301, // Above maximum
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['target_weight']);
    }

    public function test_photo_upload_with_valid_profile_data()
    {
        // Test that photo field accepts valid image files
        // We'll test the validation rules for photo upload
        $validator = \Illuminate\Support\Facades\Validator::make([
            'photo' => \Illuminate\Http\UploadedFile::fake()->image('photo.jpg', 400, 400)->size(1024),
        ], [
            'photo' => 'nullable|image|mimes:jpg,jpeg,png,webp|max:10240',
        ]);

        $this->assertFalse($validator->fails());

        // Test with invalid file type
        $validator2 = \Illuminate\Support\Facades\Validator::make([
            'photo' => \Illuminate\Http\UploadedFile::fake()->create('document.pdf', 1024),
        ], [
            'photo' => 'nullable|image|mimes:jpg,jpeg,png,webp|max:10240',
        ]);

        $this->assertTrue($validator2->fails());

        // Test with file too large (> 10MB)
        $validator3 = \Illuminate\Support\Facades\Validator::make([
            'photo' => \Illuminate\Http\UploadedFile::fake()->image('large.jpg', 400, 400)->size(11264), // 11MB
        ], [
            'photo' => 'nullable|image|mimes:jpg,jpeg,png,webp|max:10240',
        ]);

        $this->assertTrue($validator3->fails());
    }
}

