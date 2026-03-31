<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Tambahkan kolom supabase_id ke tabel users.
     * Diperlukan agar Laravel dapat mengidentifikasi user berdasarkan UUID Supabase Auth.
     */
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('supabase_id')->nullable()->unique()->after('id');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn('supabase_id');
        });
    }
};
