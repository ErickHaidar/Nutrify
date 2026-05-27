// File: app/Exceptions/Handler.php
<?php

namespace App\Exceptions;

use Illuminate\Foundation\Exceptions\Handler as ExceptionHandler;
use Throwable;
use Symfony\Component\HttpFoundation\Response;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class Handler extends ExceptionHandler
{
    /**
     * A list of the exception types that are not reported.
     *
     * @var array<int, class-string<Throwable>>
     */
    protected $dontReport = [
        // Add exception classes you don't want to report here
    ];

    /**
     * A list of the inputs that are never flashed for validation exceptions.
     *
     * @var array<int, string>
     */
    protected $dontFlash = [
        'current_password',
        'password',
        'password_confirmation',
    ];

    /**
     * Register the exception handling callbacks for the application.
     */
    public function register(): void
    {
        $this->reportable(function (Throwable $e) {
            // You can send the exception to an external monitoring service here
        });
    }

    /**
     * Render an exception into an HTTP response.
     */
    public function render($request, Throwable $exception): Response
    {
        // If the request expects JSON (API), return a friendly JSON response
        if ($request->expectsJson()) {
            $status = $this->isHttpException($exception) ? $exception->getStatusCode() : 500;
            $friendlyMessage = $this->toFriendlyMessage($exception);
            return response()->json([
                'message' => $friendlyMessage,
            ], $status);
        }

        // For web requests, fall back to the default Laravel rendering (which respects APP_DEBUG)
        return parent::render($request, $exception);
    }

    /**
     * Convert a technical exception into a user‑friendly Indonesian message.
     */
    private function toFriendlyMessage(Throwable $e): string
    {
        $msg = $e->getMessage();
        $lower = strtolower($msg);
        // Authentication / Token issues
        if (str_contains($lower, 'token') && str_contains($lower, 'expired')) {
            return 'Sesi Anda telah berakhir. Silakan masuk kembali.';
        }
        if (str_contains($lower, 'unauthenticated')) {
            return 'Anda tidak memiliki akses. Silakan masuk terlebih dahulu.';
        }
        // Validation errors – Laravel throws ValidationException which contains a messages array.
        if ($e instanceof \Illuminate\Validation\ValidationException) {
            return 'Data yang Anda masukkan tidak valid. Silakan periksa kembali.';
        }
        // Database / server errors
        if (str_contains($lower, 'sql') || str_contains($lower, 'database')) {
            return 'Terjadi kesalahan pada server. Tim kami sedang menanganinya.';
        }
        // Rate limit / too many requests
        if (str_contains($lower, 'too many requests') || str_contains($lower, 'rate limit')) {
            return 'Terlalu banyak permintaan. Silakan tunggu beberapa saat.';
        }
        // Generic fallback – hide technical codes
        return 'Terjadi kesalahan pada sistem. Silakan coba lagi nanti.';
    }
}

?>
