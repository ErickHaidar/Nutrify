<?php

namespace Tests\Feature;

use App\Models\Profile;
use App\Models\Food;
use App\Models\FoodLog;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

class ChatbotControllerTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        // Set up dummy GEMINI_API_KEY for testing
        putenv('GEMINI_API_KEY=test-key');
    }

    public function test_chatbot_message_validation_fails_without_message()
    {
        $user = $this->createAuthenticatedUser();

        $response = $this->withoutMiddleware()->postJson('/api/chatbot/message', []);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['message']);
    }

    public function test_chatbot_returns_successful_reply_and_extracts_navigate_to()
    {
        $user = $this->createAuthenticatedUser();

        // Create profile
        Profile::create([
            'user_id' => $user->id,
            'age' => 25,
            'weight' => 70,
            'height' => 170,
            'gender' => 'male',
            'activity_level' => 'moderate',
            'goal' => 'cutting',
        ]);

        // Create food and log it
        $food = Food::create([
            'name' => 'Ayam Bakar',
            'serving_size' => 100,
            'calories' => 200,
            'protein' => 20,
            'carbohydrates' => 5,
            'fat' => 10,
        ]);

        FoodLog::create([
            'user_id' => $user->id,
            'food_id' => $food->id,
            'serving_multiplier' => 1.5,
            'meal_time' => 'Lunch',
            'created_at' => Carbon::today()->toDateString(),
        ]);

        // Mock Gemini generateContent API
        Http::fake([
            'https://generativelanguage.googleapis.com/*' => Http::response([
                'candidates' => [
                    [
                        'content' => [
                            'parts' => [
                                [
                                    'text' => "Here is your profile! {\"navigate_to\": \"profile\"}"
                                ]
                            ]
                        ]
                    ]
                ]
            ], 200)
        ]);

        $response = $this->withoutMiddleware()->postJson('/api/chatbot/message', [
            'message' => 'show my profile'
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'reply' => 'Here is your profile!',
                'navigate_to' => 'profile'
            ]);
    }

    public function test_chatbot_returns_reply_with_null_navigate_to()
    {
        $user = $this->createAuthenticatedUser();

        // Mock Gemini generateContent API
        Http::fake([
            'https://generativelanguage.googleapis.com/*' => Http::response([
                'candidates' => [
                    [
                        'content' => [
                            'parts' => [
                                [
                                    'text' => "You should drink more water and stay hydrated."
                                ]
                            ]
                        ]
                    ]
                ]
            ], 200)
        ]);

        $response = $this->withoutMiddleware()->postJson('/api/chatbot/message', [
            'message' => 'how to stay healthy?'
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'reply' => 'You should drink more water and stay hydrated.',
                'navigate_to' => null
            ]);
    }
}
