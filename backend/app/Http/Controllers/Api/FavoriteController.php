<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\UserFavorite;
use App\Models\Food;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class FavoriteController extends Controller
{
    public function index(Request $request)
    {
        $favorites = UserFavorite::where('user_id', Auth::id())
            ->with('food')
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        $data = $favorites->through(function ($fav) {
            return [
                'id' => $fav->id,
                'food' => $fav->food,
                'created_at' => $fav->created_at,
            ];
        });

        return response()->json(['success' => true, 'data' => $data]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'food_id' => 'required|exists:foods,id',
        ]);

        $userId = Auth::id();
        $foodId = $request->food_id;

        $exists = UserFavorite::where('user_id', $userId)
            ->where('food_id', $foodId)
            ->exists();

        if ($exists) {
            return response()->json([
                'success' => false,
                'message' => 'Makanan sudah ada di favorit.',
            ], 409);
        }

        $favorite = UserFavorite::create([
            'user_id' => $userId,
            'food_id' => $foodId,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Makanan ditambahkan ke favorit.',
            'data' => $favorite->load('food'),
        ], 201);
    }

    public function destroy($foodId)
    {
        $favorite = UserFavorite::where('user_id', Auth::id())
            ->where('food_id', $foodId)
            ->first();

        if (!$favorite) {
            return response()->json([
                'success' => false,
                'message' => 'Favorit tidak ditemukan.',
            ], 404);
        }

        $favorite->delete();

        return response()->json([
            'success' => true,
            'message' => 'Makanan dihapus dari favorit.',
        ]);
    }
}
