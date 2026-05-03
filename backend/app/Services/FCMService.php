<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class FCMService
{
    /**
     * Kirim FCM Push Notification
     *
     * @param string $token FCM token device user
     * @param string $title Judul notifikasi
     * @param string $body Isi notifikasi
     * @param array $data Data tambahan (optional)
     * @return bool
     */
    public function sendNotification($token, $title, $body, $data = [])
    {
        // Kalau token kosong, skip
        if (empty($token)) {
            return false;
        }

        // Baca Firebase credentials
        $credentialsPath = storage_path('app/firebase-credentials.json.json');

        if (!file_exists($credentialsPath)) {
            Log::error('Firebase credentials not found', ['path' => $credentialsPath]);
            return false;
        }

        $credentials = json_decode(file_get_contents($credentialsPath), true);

        // Get OAuth 2.0 access token
        $accessToken = $this->getAccessToken($credentials);

        if (!$accessToken) {
            Log::error('Failed to get Firebase access token');
            return false;
        }

        // FCM endpoint
        $fcmEndpoint = 'https://fcm.googleapis.com/v1/projects/' . $credentials['project_id'] . '/messages:send';

        // Payload notifikasi
        $message = [
            'message' => [
                'token' => $token,
                'notification' => [
                    'title' => $title,
                    'body' => $body,
                ],
                'data' => $data,
            ],
        ];

        // Kirim request ke FCM
        try {
            $response = Http::withToken($accessToken)
                ->post($fcmEndpoint, $message);

            if ($response->successful()) {
                Log::info('FCM notification sent successfully', [
                    'title' => $title,
                    'token' => substr($token, 0, 20) . '...',
                ]);
                return true;
            } else {
                Log::error('FCM notification failed', [
                    'status' => $response->status(),
                    'body' => $response->body(),
                ]);
                return false;
            }
        } catch (\Exception $e) {
            Log::error('FCM notification error', [
                'message' => $e->getMessage(),
            ]);
            return false;
        }
    }

    /**
     * Get OAuth 2.0 Access Token dari Firebase
     */
    private function getAccessToken($credentials)
    {
        $endpoint = 'https://oauth2.googleapis.com/token';

        $data = [
            'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
            'assertion' => $this->generateJWT($credentials),
        ];

        try {
            $response = Http::asForm()->post($endpoint, $data);

            if ($response->successful()) {
                $body = $response->json();
                return $body['access_token'] ?? null;
            }

            return null;
        } catch (\Exception $e) {
            Log::error('Failed to get Firebase access token', [
                'message' => $e->getMessage(),
            ]);
            return null;
        }
    }

    /**
     * Generate JWT untuk Firebase
     */
    private function generateJWT($credentials)
    {
        $header = [
            'alg' => 'RS256',
            'typ' => 'JWT',
        ];

        $now = time();
        $payload = [
            'iss' => $credentials['client_email'],
            'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
            'aud' => 'https://oauth2.googleapis.com/token',
            'iat' => $now,
            'exp' => $now + 3600, // 1 hour
        ];

        // Encode header dan payload
        $headerEncoded = $this->base64UrlEncode(json_encode($header));
        $payloadEncoded = $this->base64UrlEncode(json_encode($payload));

        // Create signature
        $signatureInput = $headerEncoded . '.' . $payloadEncoded;

        // Load private key
        $privateKey = $credentials['private_key'];

        openssl_sign(
            $signatureInput,
            $signature,
            $privateKey,
            OPENSSL_ALGO_SHA256
        );

        $signatureEncoded = $this->base64UrlEncode($signature);

        return $headerEncoded . '.' . $payloadEncoded . '.' . $signatureEncoded;
    }

    /**
     * Base64 URL Encode
     */
    private function base64UrlEncode($data)
    {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }
}
