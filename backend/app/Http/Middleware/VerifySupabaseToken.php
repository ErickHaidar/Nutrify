<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Auth;
use App\Models\User;
use Firebase\JWT\JWT;
use Firebase\JWT\JWK;

/**
 * Middleware untuk memverifikasi JWT token dari Supabase Auth.
 *
 * Project ini menggunakan ES256 (ECDSA P-256) — kunci publik diambil dari
 * JWKS endpoint Supabase dan di-cache selama 1 jam untuk efisiensi.
 *
 * Cara kerja:
 * 1. Flutter login via supabase_flutter → Supabase kembalikan JWT access token
 * 2. Flutter kirim token ke Laravel sebagai "Authorization: Bearer {token}"
 * 3. Middleware fetch JWKS dari Supabase (cached 1 jam), verifikasi signature
 * 4. Jika valid, user diidentifikasi dari supabase_id dan di-bind ke request
 *
 * Dependensi: composer require firebase/php-jwt
 */
class VerifySupabaseToken
{
    public function handle(Request $request, Closure $next): mixed
    {
        $token = $request->bearerToken();

        if (!$token) {
            Log::warning("DEBUG_AUTH: No bearer token found.");
            return response()->json(['message' => 'Token tidak ditemukan.'], 401);
        }

        try {
            $keySet = $this->getKeySet();
            $decoded = JWT::decode($token, $keySet);

            $supabaseId = $decoded->sub ?? null;
            $email      = $decoded->email ?? null;

            if (!$supabaseId) {
                return response()->json(['message' => 'Token tidak valid: sub claim tidak ditemukan.'], 401);
            }

            // Cari user berdasarkan supabase_id
            $user = User::where('supabase_id', $supabaseId)->first();

            if (!$user && $email) {
                // Cari by email jika by supabase_id tidak ketemu
                $user = User::where('email', $email)->first();
                
                if ($user) {
                    // Update user existing dengan supabase_id yang baru (Backlog ID 13 Fix)
                    $user->update(['supabase_id' => $supabaseId]);
                } else {
                    // Buat user baru jika benar-benar tidak ada
                    $user = User::create([
                        'email' => $email,
                        'supabase_id' => $supabaseId,
                        'name'        => $decoded->user_metadata->full_name
                                         ?? $decoded->user_metadata->name
                                         ?? $email,
                        'password'    => bcrypt(str()->random(32)),
                    ]);
                }
            }

            if (!$user) {
                return response()->json(['message' => 'User tidak ditemukan.'], 401);
            }

            // Bind user ke request agar Auth::user() dapat digunakan di controller
            $request->setUserResolver(fn () => $user);
            Auth::setUser($user);

        } catch (\Firebase\JWT\ExpiredException $e) {
            return response()->json(['message' => 'Token sudah kadaluarsa. Silakan login ulang.'], 401);
        } catch (\Firebase\JWT\SignatureInvalidException $e) {
            return response()->json(['message' => 'Signature token tidak valid.'], 401);
        } catch (\Exception $e) {
            Log::warning('Supabase JWT verification failed: ' . $e->getMessage());
            return response()->json(['message' => 'Token tidak valid.'], 401);
        }

        return $next($request);
    }

    /**
     * Ambil key set dari JWKS endpoint Supabase, di-cache 1 jam.
     * Mengembalikan array Key yang siap dipakai oleh JWT::decode().
     */
    private function getKeySet(): array
    {
        $jwksData = Cache::remember('supabase_jwks', 3600, function () {
            $url = config('supabase.url') . '/auth/v1/.well-known/jwks.json';
            $response = Http::withoutVerifying()->get($url);

            if (!$response->successful()) {
                throw new \RuntimeException('Gagal mengambil JWKS dari Supabase: HTTP ' . $response->status());
            }

            return $response->json();
        });

        return JWK::parseKeySet($jwksData);
    }
}
