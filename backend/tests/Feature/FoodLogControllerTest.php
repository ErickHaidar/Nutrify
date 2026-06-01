<?php

namespace Tests\Feature;

use App\Models\Food;
use App\Models\FoodLog;
use App\Models\User;
use App\Models\Profile;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class FoodLogControllerTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_store_food_log()
    {
        $user = $this->createAuthenticatedUser();
        $food = Food::create([
            'name' => 'Nasi Goreng',
            'calories' => 250.0,
            'protein' => 8.0,
            'carbohydrates' => 35.0,
            'fat' => 9.0,
            'sugar' => 2.0,
            'sodium' => 500.0,
            'fiber' => 1.0,
            'serving_size' => '100g',
        ]);

        $response = $this->withoutMiddleware()->postJson('/api/food-logs', [
            'food_id' => $food->id,
            'serving_multiplier' => 1.5,
            'unit' => 'Gram(g)',
            'meal_time' => 'Breakfast',
            'date' => now()->toDateString(),
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'message' => 'Food logged successfully!',
            ]);

        $this->assertDatabaseHas('food_logs', [
            'user_id' => $user->id,
            'food_id' => $food->id,
            'serving_multiplier' => 1.5,
            'meal_time' => 'Breakfast',
        ]);
    }

    public function test_user_can_get_food_logs_index()
    {
        $user = $this->createAuthenticatedUser();
        $food = Food::create([
            'name' => 'Nasi Goreng',
            'calories' => 250.0,
            'protein' => 8.0,
            'carbohydrates' => 35.0,
            'fat' => 9.0,
            'sugar' => 2.0,
            'sodium' => 500.0,
            'fiber' => 1.0,
            'serving_size' => '100g',
        ]);

        $date = now()->toDateString();
        FoodLog::create([
            'user_id' => $user->id,
            'food_id' => $food->id,
            'serving_multiplier' => 1.0,
            'unit' => 'Gram(g)',
            'meal_time' => 'Breakfast',
            'created_at' => $date,
        ]);

        $response = $this->withoutMiddleware()->getJson("/api/food-logs?date={$date}");

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
            ])
            ->assertJsonCount(1, 'data');
    }

    public function test_user_can_get_summary()
    {
        $user = $this->createAuthenticatedUser();
        $food = Food::create([
            'name' => 'Nasi Goreng',
            'calories' => 250.0,
            'protein' => 8.0,
            'carbohydrates' => 35.0,
            'fat' => 9.0,
            'sugar' => 2.0,
            'sodium' => 500.0,
            'fiber' => 1.0,
            'serving_size' => '100g',
        ]);

        // Create user profile
        Profile::create([
            'user_id' => $user->id,
            'weight' => 70,
            'height' => 170,
            'age' => 25,
            'gender' => 'male',
            'activity_level' => 'active',
            'goal' => 'maintenance',
        ]);

        $date = now()->toDateString();
        FoodLog::create([
            'user_id' => $user->id,
            'food_id' => $food->id,
            'serving_multiplier' => 2.0,
            'unit' => 'Gram(g)',
            'meal_time' => 'Breakfast',
            'created_at' => $date,
        ]);

        $response = $this->withoutMiddleware()->getJson("/api/food-logs/summary?date={$date}");

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
            ]);
    }

    public function test_user_can_store_fallback_food_with_negative_id()
    {
        $user = $this->createAuthenticatedUser();

        // Send a request with food_id: -1 (Nasi Putih fallback)
        $response = $this->withoutMiddleware()->postJson('/api/food-logs', [
            'food_id' => -1,
            'serving_multiplier' => 1.0,
            'unit' => 'Gram(g)',
            'meal_time' => 'Breakfast',
            'date' => now()->toDateString(),
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'message' => 'Food logged successfully!',
            ]);

        // Assert that a food named 'Nasi Putih' was resolved or created
        $this->assertDatabaseHas('foods', [
            'name' => 'Nasi Putih',
        ]);

        $food = Food::where('name', 'Nasi Putih')->first();

        $this->assertDatabaseHas('food_logs', [
            'user_id' => $user->id,
            'food_id' => $food->id,
            'serving_multiplier' => 1.0,
            'meal_time' => 'Breakfast',
        ]);
    }
}
