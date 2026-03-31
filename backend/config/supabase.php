<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Supabase Configuration
    |--------------------------------------------------------------------------
    |
    | Konfigurasi untuk integrasi dengan Supabase Auth.
    | Semua nilai diambil dari file .env.
    |
    | Cara mendapatkan nilai ini:
    |   1. Buka https://supabase.com/dashboard
    |   2. Pilih project → Settings → API
    |   3. Project URL      → SUPABASE_URL
    |   4. anon/public key  → SUPABASE_ANON_KEY
    |   5. Settings → JWT  → JWT Secret → SUPABASE_JWT_SECRET
    |
    */

    'url'        => env('SUPABASE_URL'),
    'anon_key'   => env('SUPABASE_ANON_KEY'),
    'jwt_secret' => env('SUPABASE_JWT_SECRET'),
];
