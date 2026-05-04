<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Food;
use App\Models\UserFavorite;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class FavoriteControllerTest extends TestCase
{
    use RefreshDatabase;

    /**
     * 1. test_user_can_add_favorite
     */
    public function test_user_can_add_favorite()
    {
        $user = $this->createAuthenticatedUser();
        
        $food = Food::create([
            'name' => 'Nasi Goreng Test',
            'calories' => 250.0,
            'protein' => 8.0,
            'carbohydrates' => 35.0,
            'fat' => 9.0,
            'sugar' => 2.0,
            'sodium' => 500.0,
            'fiber' => 1.0,
            'serving_size' => '100g',
        ]);

        $response = $this->withoutMiddleware()->postJson('/api/food/favorites', [
            'food_id' => $food->id,
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'message' => 'Makanan ditambahkan ke favorit.',
            ]);

        $this->assertDatabaseHas('user_favorites', [
            'user_id' => $user->id,
            'food_id' => $food->id,
        ]);
    }

    /**
     * 2. test_duplicate_favorite_returns_409
     */
    public function test_duplicate_favorite_returns_409()
    {
        $user = $this->createAuthenticatedUser();
        
        $food = Food::create([
            'name' => 'Nasi Goreng Test',
            'calories' => 250.0,
            'protein' => 8.0,
            'carbohydrates' => 35.0,
            'fat' => 9.0,
            'sugar' => 2.0,
            'sodium' => 500.0,
            'fiber' => 1.0,
            'serving_size' => '100g',
        ]);

        UserFavorite::create([
            'user_id' => $user->id,
            'food_id' => $food->id,
        ]);

        $response = $this->withoutMiddleware()->postJson('/api/food/favorites', [
            'food_id' => $food->id,
        ]);

        $response->assertStatus(409)
            ->assertJson([
                'success' => false,
                'message' => 'Makanan sudah ada di favorit.',
            ]);
    }

    /**
     * 3. test_user_can_remove_favorite
     */
    public function test_user_can_remove_favorite()
    {
        $user = $this->createAuthenticatedUser();
        
        $food = Food::create([
            'name' => 'Nasi Goreng Test',
            'calories' => 250.0,
            'protein' => 8.0,
            'carbohydrates' => 35.0,
            'fat' => 9.0,
            'sugar' => 2.0,
            'sodium' => 500.0,
            'fiber' => 1.0,
            'serving_size' => '100g',
        ]);

        UserFavorite::create([
            'user_id' => $user->id,
            'food_id' => $food->id,
        ]);

        $response = $this->withoutMiddleware()->deleteJson("/api/food/favorites/{$food->id}");

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'Makanan dihapus dari favorit.',
            ]);

        $this->assertDatabaseMissing('user_favorites', [
            'user_id' => $user->id,
            'food_id' => $food->id,
        ]);
    }

    /**
     * 4. test_remove_nonexistent_favorite_returns_404
     */
    public function test_remove_nonexistent_favorite_returns_404()
    {
        $this->createAuthenticatedUser();

        $response = $this->withoutMiddleware()->deleteJson("/api/food/favorites/9999");

        $response->assertStatus(404)
            ->assertJson([
                'success' => false,
                'message' => 'Favorit tidak ditemukan.',
            ]);
    }

    /**
     * 5. test_favorites_list_returns_paginated_data
     */
    public function test_favorites_list_returns_paginated_data()
    {
        $user = $this->createAuthenticatedUser();
        
        $food = Food::create([
            'name' => 'Nasi Goreng Test',
            'calories' => 250.0,
            'protein' => 8.0,
            'carbohydrates' => 35.0,
            'fat' => 9.0,
            'sugar' => 2.0,
            'sodium' => 500.0,
            'fiber' => 1.0,
            'serving_size' => '100g',
        ]);

        UserFavorite::create([
            'user_id' => $user->id,
            'food_id' => $food->id,
        ]);

        $response = $this->withoutMiddleware()->getJson('/api/food/favorites');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'data' => [
                    'data' => [
                        '*' => [
                            'id',
                            'food',
                            'created_at',
                        ]
                    ],
                    'current_page',
                    'last_page',
                    'total',
                ]
            ]);
    }
}
