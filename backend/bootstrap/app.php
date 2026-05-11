<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->alias([
            'verified'      => \App\Http\Middleware\EnsureEmailIsVerified::class,
            'supabase.auth' => \App\Http\Middleware\VerifySupabaseToken::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        // Mask database errors so public users never see raw SQL/stack traces
        $exceptions->render(function (\Illuminate\Database\QueryException $e, $request) {
            \Illuminate\Support\Facades\Log::error('Database QueryException: ' . $e->getMessage(), [
                'sql' => $e->getSql(),
                'bindings' => $e->getBindings(),
                'trace' => $e->getTraceAsString(),
            ]);

            if ($request->expectsJson() || $request->is('api/*')) {
                return response()->json([
                    'success' => false,
                    'message' => 'Terjadi kesalahan pada server. Silakan coba lagi nanti.',
                ], 500);
            }
        });

        $exceptions->render(function (\PDOException $e, $request) {
            \Illuminate\Support\Facades\Log::error('PDOException: ' . $e->getMessage(), [
                'trace' => $e->getTraceAsString(),
            ]);

            if ($request->expectsJson() || $request->is('api/*')) {
                return response()->json([
                    'success' => false,
                    'message' => 'Terjadi kesalahan pada server. Silakan coba lagi nanti.',
                ], 500);
            }
        });
    })->create();
