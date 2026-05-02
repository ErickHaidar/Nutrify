<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Food;
use App\Models\FoodLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class FoodController extends Controller
{
    public function index(Request $request)
    {
        $query = Food::query();

        if ($request->filled('search')) {
            $search = $request->query('search');
            $query->where('name', 'ilike', "%{$search}%");
        }

        $foods = $query->orderBy('name')->paginate(20);

        return response()->json(['success' => true, 'data' => $foods]);
    }

    public function recommendations(Request $request)
    {
        $limit = $request->query('limit', 10);
        $userId = Auth::id();

        $topFoodIds = FoodLog::where('user_id', $userId)
            ->selectRaw('food_id, COUNT(*) as total')
            ->groupBy('food_id')
            ->orderByDesc('total')
            ->limit($limit)
            ->pluck('food_id');

        if ($topFoodIds->isEmpty()) {
            return response()->json([
                'success' => true,
                'data' => [],
                'message' => 'Belum ada riwayat makanan.',
            ]);
        }

        $foods = Food::whereIn('id', $topFoodIds)
            ->get()
            ->sortBy(fn($food) => $topFoodIds->search($food->id))
            ->values();

        return response()->json(['success' => true, 'data' => $foods]);
    }
}
