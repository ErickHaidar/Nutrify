<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Mail\OtpMail;
use App\Models\Otp;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\RateLimiter;

class OtpController extends Controller
{
    /**
     * POST /api/auth/send-otp
     * Generate & kirim kode OTP 6 digit ke email.
     */
    public function send(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
        ]);

        $email = $request->email;

        // Rate limit: max 1 request per 60 detik per email
        $key = 'otp-send:' . $email;
        if (RateLimiter::tooManyAttempts($key, 1)) {
            $seconds = RateLimiter::availableIn($key);
            return response()->json([
                'message' => "Tunggu {$seconds} detik sebelum meminta OTP baru.",
            ], 429);
        }
        RateLimiter::hit($key, 60);

        // Hapus OTP lama yang belum diverifikasi untuk email ini
        Otp::where('email', $email)->whereNull('verified_at')->delete();

        // Generate 6-digit code
        $code = str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        // Simpan hash OTP
        Otp::create([
            'email' => $email,
            'code' => Hash::make($code),
            'expires_at' => now()->addMinutes(5),
        ]);

        // Kirim email
        Mail::to($email)->send(new OtpMail($code));

        return response()->json([
            'message' => 'Kode OTP berhasil dikirim ke ' . $email,
        ]);
    }

    /**
     * POST /api/auth/verify-otp
     * Verifikasi kode OTP.
     */
    public function verify(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'code'  => 'required|string|size:6',
        ]);

        $email = $request->email;
        $code  = $request->code;

        // Rate limit: max 5 percobaan per menit per email
        $key = 'otp-verify:' . $email;
        if (RateLimiter::tooManyAttempts($key, 5)) {
            $seconds = RateLimiter::availableIn($key);
            return response()->json([
                'message' => "Terlalu banyak percobaan. Tunggu {$seconds} detik.",
            ], 429);
        }
        RateLimiter::hit($key, 60);

        // Cari OTP yang belum diverifikasi dan belum expired
        $otp = Otp::where('email', $email)
            ->whereNull('verified_at')
            ->where('expires_at', '>', now())
            ->latest()
            ->first();

        if (!$otp) {
            return response()->json([
                'message' => 'Kode OTP tidak ditemukan atau sudah kadaluarsa. Silakan minta kode baru.',
            ], 400);
        }

        if (!Hash::check($code, $otp->code)) {
            return response()->json([
                'message' => 'Kode OTP salah. Silakan coba lagi.',
            ], 400);
        }

        // Tandai sebagai terverifikasi
        $otp->update(['verified_at' => now()]);

        return response()->json([
            'message' => 'Email berhasil diverifikasi.',
            'verified' => true,
        ]);
    }
}
