<?php

namespace Tests;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\TestCase as BaseTestCase;

abstract class TestCase extends BaseTestCase
{
    use RefreshDatabase;

    /**
     * Create a test user with supabase_id and authenticate.
     */
    protected function createAuthenticatedUser(array $attributes = []): User
    {
        $user = User::factory()->create(array_merge([
            'supabase_id' => 'test-supabase-' . uniqid(),
        ], $attributes));

        $this->actingAs($user);

        return $user;
    }
}
