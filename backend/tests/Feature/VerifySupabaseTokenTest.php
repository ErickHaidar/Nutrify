<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Cache;
use Tests\TestCase;
use Firebase\JWT\JWT;

class VerifySupabaseTokenTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        config(['supabase.url' => 'https://eilxtehpxdnwfxgdgtps.supabase.co']);
        Cache::forget('supabase_jwks');
    }

    /**
     * Test that the middleware fetches JWKS with SSL verification enabled.
     */
    public function test_jwks_request_is_made_with_ssl_verification()
    {
        $token = "fake.jwt.token";
        $capturedOptions = [];

        // 2. Mock the JWKS response and capture options
        Http::fake(function ($request, $options) use (&$capturedOptions) {
            if (str_contains($request->url(), '/auth/v1/.well-known/jwks.json')) {
                $capturedOptions = $options;
                return Http::response(['keys' => []], 200);
            }
        });

        // 3. Hit a route that uses the middleware
        $this->withToken($token)->getJson('/api/profile');

        // 4. Verify that the JWKS endpoint was requested
        $this->assertNotEmpty($capturedOptions, 'JWKS request was not made');

        // 5. Verify that SSL verification was NOT disabled
        $sslVerified = !isset($capturedOptions['verify']) || $capturedOptions['verify'] !== false;

        $this->assertTrue($sslVerified, 'SSL verification was disabled (withoutVerifying() was used)');
    }

}
