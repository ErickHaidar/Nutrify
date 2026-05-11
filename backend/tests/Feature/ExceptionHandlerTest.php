<?php

namespace Tests\Feature;

use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Route;
use PDOException;
use Tests\TestCase;

class ExceptionHandlerTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test that QueryException returns a generic JSON error.
     */
    public function test_query_exception_returns_generic_json_error(): void
    {
        Route::get('/test-query-exception', function () {
            throw new QueryException(
                'pgsql',
                'SELECT * FROM non_existent_table',
                [],
                new \Exception('relation "non_existent_table" does not exist')
            );
        })->middleware('api');

        $response = $this->getJson('/test-query-exception');

        $response->assertStatus(500)
            ->assertJson([
                'success' => false,
                'message' => 'Terjadi kesalahan pada server. Silakan coba lagi nanti.',
            ]);

        $response->assertDontSee('SELECT');
        $response->assertDontSee('non_existent_table');
    }

    /**
     * Test that PDOException returns a generic JSON error.
     */
    public function test_pdo_exception_returns_generic_json_error(): void
    {
        Route::get('/test-pdo-exception', function () {
            throw new PDOException('SQLSTATE[HY000] [2002] Connection refused');
        })->middleware('api');

        $response = $this->getJson('/test-pdo-exception');

        $response->assertStatus(500)
            ->assertJson([
                'success' => false,
                'message' => 'Terjadi kesalahan pada server. Silakan coba lagi nanti.',
            ]);

        $response->assertDontSee('SQLSTATE');
        $response->assertDontSee('Connection refused');
    }

    /**
     * Test that database errors hide SQL details.
     */
    public function test_database_error_hides_sql_details(): void
    {
        $sql = 'SELECT * FROM secret_table WHERE password = ?';
        $bindings = ['hunter2'];

        Route::get('/test-sql-masking', function () use ($sql, $bindings) {
            throw new QueryException(
                'pgsql',
                $sql,
                $bindings,
                new \Exception('test')
            );
        })->middleware('api');

        $response = $this->getJson('/test-sql-masking');

        $response->assertStatus(500)
            ->assertJson([
                'success' => false,
                'message' => 'Terjadi kesalahan pada server. Silakan coba lagi nanti.',
            ]);

        $response->assertDontSee('secret_table');
        $response->assertDontSee('hunter2');
        $response->assertDontSee('password');
    }
}
