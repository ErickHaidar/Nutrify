<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Food;
use Illuminate\Http\Request;

class FoodController extends Controller
{
    // GET /api/foods?search=&page=
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
}
