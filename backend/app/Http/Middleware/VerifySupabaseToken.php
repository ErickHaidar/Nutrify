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
 * Middleware to verify JWT token from Supabase Auth.
 *
 * This project uses ES256 (ECDSA P-256) — the public key is retrieved from
 * the Supabase JWKS endpoint and cached for 1 hour for efficiency.
 *
 * Workflow:
 * 1. Flutter login via supabase_flutter → Supabase returns JWT access token
 * 2. Flutter sends token to Laravel as "Authorization: Bearer {token}"
 * 3. Middleware fetches JWKS from Supabase (cached 1 hour), verifies signature
 * 4. If valid, the user is identified from supabase_id and bound to the request
 *
 * Dependency: composer require firebase/php-jwt
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
                return response()->json(['message' => 'Invalid token: sub claim not found.'], 401);
            }

            // Find user based on supabase_id
            $user = User::where('supabase_id', $supabaseId)->first();

            if (!$user && $email) {
                // Find by email if by supabase_id not found
                $user = User::where('email', $email)->first();
                
                if ($user) {
                    // Update existing user with new supabase_id
                    $user->update(['supabase_id' => $supabaseId]);
                } else {
                    // Create new user if they truly don't exist
                    $user = User::create([
                        'email' => $email,
                        'supabase_id' => $supabaseId,
                        'name'        => $decoded->user_metadata->full_name
                                         ?? $decoded->user_metadata->name
                                         ?? $email,
                        'password'    => bcrypt(str()->random(32)),
                    ]);

                    // Auto-create empty profile for new user
                    \App\Models\Profile::create([
                        'user_id' => $user->id,
                        'age' => 0,
                        'weight' => 0,
                        'height' => 0,
                        'gender' => 'male',
                        'goal' => 'maintenance',
                        'activity_level' => 'sedentary',
                    ]);
                }
            }

            if (!$user) {
                return response()->json(['message' => 'User not found.'], 401);
            }

            // Bind user to request so Auth::user() can be used in controllers
            $request->setUserResolver(fn () => $user);
            Auth::setUser($user);

        } catch (\Firebase\JWT\ExpiredException $e) {
            return response()->json(['message' => 'Sesi telah berakhir. Silakan login kembali.'], 401);
        } catch (\Firebase\JWT\SignatureInvalidException $e) {
            return response()->json(['message' => 'Token tidak valid. Silakan login kembali.'], 401);
        } catch (\Exception $e) {
            Log::warning('Supabase JWT verification failed: ' . $e->getMessage());
            return response()->json(['message' => 'Autentikasi gagal. Silakan login kembali.'], 401);
        }

        return $next($request);
    }

    /**
     * Get key set from Supabase JWKS endpoint, cached for 1 hour.
     * Returns a Key array ready to be used by JWT::decode().
     */
    private function getKeySet(): array
    {
        $jwksData = Cache::remember('supabase_jwks', 3600, function () {
            $url = config('supabase.url') . '/auth/v1/.well-known/jwks.json';
            $response = Http::get($url);



            if (!$response->successful()) {
                throw new \RuntimeException('Failed to fetch JWKS from Supabase: HTTP ' . $response->status());
            }

            return $response->json();
        });

        return JWK::parseKeySet($jwksData);
    }
}
