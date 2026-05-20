<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\FoodLog;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class ChatbotController extends Controller
{
    /**
     * Handle the chatbot message request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function message(Request $request)
    {
        $validated = $request->validate([
            'message' => 'required|string',
        ]);

        $userMessage = $validated['message'];
        $user = Auth::user();

        if (!$user) {
            return response()->json([
                'reply' => 'Unauthorized. Please log in first.',
                'navigate_to' => null
            ], 401);
        }

        // Fetch User's Profile
        $profile = $user->profile;

        // Fetch user's today's food logs
        $today = Carbon::today()->toDateString();
        $logs = FoodLog::with('food')
            ->where('user_id', $user->id)
            ->whereDate('created_at', $today)
            ->get();

        // Calculate today's calories/macros
        $totals = [
            'calories'      => round($logs->sum(fn($l) => $l->food->calories      * $l->serving_multiplier), 2),
            'protein'       => round($logs->sum(fn($l) => $l->food->protein       * $l->serving_multiplier), 2),
            'carbohydrates' => round($logs->sum(fn($l) => $l->food->carbohydrates * $l->serving_multiplier), 2),
            'fat'           => round($logs->sum(fn($l) => $l->food->fat           * $l->serving_multiplier), 2),
        ];

        // Format food logs list
        $foodDetails = $logs->map(function ($log) {
            return "- " . $log->food->name . " (" . $log->meal_time . "): " 
                . ($log->serving_multiplier * $log->food->calories) . " kcal (P: " 
                . ($log->serving_multiplier * $log->food->protein) . "g, C: " 
                . ($log->serving_multiplier * $log->food->carbohydrates) . "g, F: " 
                . ($log->serving_multiplier * $log->food->fat) . "g)";
        })->implode("\n");

        if (empty($foodDetails)) {
            $foodDetails = "Nothing logged yet";
        }

        $userName = $user->name ?? $user->username ?? 'User';
        $goal = 'Not set yet';
        $profileDetails = 'Not provided yet';

        if ($profile) {
            $goal = $profile->goal ?? 'Not set yet';
            $profileDetails = sprintf(
                "Age: %d years, Gender: %s, Weight: %s kg, Height: %s cm, Activity Level: %s, Target Weight: %s kg",
                $profile->age ?? 0,
                $profile->gender ?? 'unknown',
                $profile->weight ?? 'unknown',
                $profile->height ?? 'unknown',
                $profile->activity_level ?? 'unknown',
                $profile->target_weight ?? 'unknown'
            );
        }

        // Build the System Prompt with Strict Topic Boundaries
        $systemPrompt = "You are Nutrify AI, a specialized health, nutrition, and diet assistant for the Nutrify app. User name is {$userName}. Their goal is {$goal}. " .
            "Today they ate:\n{$foodDetails}\n" .
            "(Summary - Calories: {$totals['calories']} kcal, Protein: {$totals['protein']}g, Carbs: {$totals['carbohydrates']}g, Fat: {$totals['fat']}g).\n" .
            "User profile details: {$profileDetails}.\n" .
            "STRICT RULES FOR YOUR RESPONSE:\n" .
            "1. You MUST ONLY answer questions related to health, nutrition, diet, fitness, and the Nutrify app.\n" .
            "2. If the user asks about programming (like HTML), general knowledge, politics, or ANY topic outside of health and nutrition, you MUST politely refuse to answer and remind them that you are exclusively a nutrition assistant.\n" .
            "3. If they want to see their profile, history, or home, include a JSON block in your response exactly like {\"navigate_to\": \"profile\"}. Otherwise, just reply with helpful text.";

        $apiKey = env('GEMINI_API_KEY');
        if (empty($apiKey)) {
            Log::error('GEMINI_API_KEY is not set in environment.');
            return response()->json([
                'reply' => 'I apologize, but my AI system is currently unavailable. Please check the API configuration.',
                'navigate_to' => null
            ]);
        }

        $payload = [
            'contents' => [
                [
                    'parts' => [
                        ['text' => $userMessage]
                    ]
                ]
            ],
            'systemInstruction' => [
                'parts' => [
                    ['text' => $systemPrompt]
                ]
            ]
        ];

        try {
            $response = Http::post(
                "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=" . $apiKey,
                $payload
            );

            if (!$response->successful()) {
                Log::error('Gemini API call failed', [
                    'status' => $response->status(),
                    'body' => $response->body()
                ]);
                return response()->json([
                    'reply' => 'Sorry, I failed to process your request at this moment.',
                    'navigate_to' => null
                ], 500);
            }

            $geminiText = $response->json('candidates.0.content.parts.0.text') ?? '';

            if (empty($geminiText)) {
                return response()->json([
                    'reply' => 'I received an empty response. How can I help you?',
                    'navigate_to' => null
                ]);
            }

            // Extract navigate_to if it exists and clean the text
            $navigate_to = null;
            $reply = $geminiText;

            // Regex to match and extract navigate_to JSON block (e.g. {"navigate_to": "profile"}), potentially wrapped in backticks
            $pattern = '/(?:```(?:json)?\s*)?\{\s*"navigate_to"\s*:\s*"([^"]+)"\s*\}\s*(?:```)?/i';
            if (preg_match($pattern, $reply, $matches)) {
                $navigate_to = trim($matches[1]);
                $reply = preg_replace($pattern, '', $reply);
            }

            $reply = trim($reply);

            return response()->json([
                'reply' => $reply,
                'navigate_to' => $navigate_to
            ]);

        } catch (\Exception $e) {
            Log::error('Exception in ChatbotController', [
                'message' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            return response()->json([
                'reply' => 'An error occurred while communicating with the AI server.',
                'navigate_to' => null
            ], 500);
        }
    }
}
