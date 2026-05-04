<?php

namespace Tests\Feature;

use App\Models\Food;
use App\Models\FoodLog;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class FoodControllerTest extends TestCase
{
    use RefreshDatabase;

    public function test_food_search_returns_paginated_results()
    {
        $this->createAuthenticatedUser();

        Food::create([
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

        Food::create([
            'name' => 'Ayam Bakar',
            'calories' => 200.0,
            'protein' => 25.0,
            'carbohydrates' => 0.0,
            'fat' => 12.0,
            'sugar' => 0.0,
            'sodium' => 400.0,
            'fiber' => 0.0,
            'serving_size' => '100g',
        ]);

        $response = $this->withoutMiddleware()->getJson('/api/foods?search=nasi');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
            ])
            ->assertJsonCount(1, 'data.data');
        
        $response->assertJsonPath('data.data.0.name', 'Nasi Goreng');
    }

    public function test_food_search_is_case_insensitive()
    {
        $this->createAuthenticatedUser();

        Food::create([
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

        // Test with uppercase
        $response = $this->withoutMiddleware()->getJson('/api/foods?search=NASI');
        $response->assertStatus(200)->assertJsonCount(1, 'data.data');

        // Test with lowercase
        $response = $this->withoutMiddleware()->getJson('/api/foods?search=nasi');
        $response->assertStatus(200)->assertJsonCount(1, 'data.data');
    }

    public function test_food_recommendations_returns_empty_for_new_user()
    {
        $this->createAuthenticatedUser();

        $response = $this->withoutMiddleware()->getJson('/api/food/recommendations');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [],
                'message' => 'Belum ada riwayat makanan.'
            ]);
    }

    public function test_food_recommendations_returns_top_foods_by_frequency()
    {
        $user = $this->createAuthenticatedUser();

        $food1 = Food::create([
            'name' => 'Food A',
            'calories' => 100,
            'protein' => 10,
            'carbohydrates' => 10,
            'fat' => 10,
            'sugar' => 0,
            'sodium' => 0,
            'fiber' => 0,
            'serving_size' => '100g',
        ]);

        $food2 = Food::create([
            'name' => 'Food B',
            'calories' => 200,
            'protein' => 20,
            'carbohydrates' => 20,
            'fat' => 20,
            'sugar' => 0,
            'sodium' => 0,
            'fiber' => 0,
            'serving_size' => '100g',
        ]);

        // Log Food B 3 times, Food A 1 time
        FoodLog::create([
            'user_id' => $user->id,
            'food_id' => $food2->id,
            'serving_multiplier' => 1,
            'unit' => 'g',
            'meal_time' => 'Lunch',
        ]);
        FoodLog::create([
            'user_id' => $user->id,
            'food_id' => $food2->id,
            'serving_multiplier' => 1,
            'unit' => 'g',
            'meal_time' => 'Dinner',
        ]);
        FoodLog::create([
            'user_id' => $user->id,
            'food_id' => $food2->id,
            'serving_multiplier' => 1,
            'unit' => 'g',
            'meal_time' => 'Breakfast',
        ]);
        FoodLog::create([
            'user_id' => $user->id,
            'food_id' => $food1->id,
            'serving_multiplier' => 1,
            'unit' => 'g',
            'meal_time' => 'Lunch',
        ]);

        $response = $this->withoutMiddleware()->getJson('/api/food/recommendations');

        $response->assertStatus(200)
            ->assertJsonCount(2, 'data');
        
        // Food B should be first
        $response->assertJsonPath('data.0.id', $food2->id);
        $response->assertJsonPath('data.1.id', $food1->id);
    }

    public function test_food_recommendations_respects_limit_parameter()
    {
        $user = $this->createAuthenticatedUser();

        for ($i = 1; $i <= 5; $i++) {
            $food = Food::create([
                'name' => "Food $i",
                'calories' => 100,
                'protein' => 10,
                'carbohydrates' => 10,
                'fat' => 10,
                'sugar' => 0,
                'sodium' => 0,
                'fiber' => 0,
                'serving_size' => '100g',
            ]);

            FoodLog::create([
                'user_id' => $user->id,
                'food_id' => $food->id,
                'serving_multiplier' => 1,
                'unit' => 'g',
                'meal_time' => 'Lunch',
            ]);
        }

        $response = $this->withoutMiddleware()->getJson('/api/food/recommendations?limit=3');

        $response->assertStatus(200)
            ->assertJsonCount(3, 'data');
    }
}
