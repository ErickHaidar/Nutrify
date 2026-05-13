<?php

namespace Tests\Feature\Middleware;

use App\Http\Middleware\VerifySupabaseToken;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Cache;
use Tests\TestCase;
use Firebase\JWT\JWT;
use Firebase\JWT\JWK;

class VerifySupabaseTokenTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        config(['supabase.url' => 'https://example.supabase.co']);
    }

    public function test_it_returns_401_if_no_token_provided()
    {
        $middleware = new VerifySupabaseToken();
        $request = Request::create('/api/test', 'GET');
        
        $response = $middleware->handle($request, function () {});

        $this->assertEquals(401, $response->getStatusCode());
        $this->assertStringContainsString('Token tidak ditemukan', $response->getContent());
    }

    public function test_it_verifies_ssl_properly()
    {
        $content = file_get_contents(app_path('Http/Middleware/VerifySupabaseToken.php'));
        $this->assertStringNotContainsString('Http::withoutVerifying()', $content);
        $this->assertStringContainsString('Http::get($url)', $content);
    }
}
