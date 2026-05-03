<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('username')->nullable()->unique()->after('name');
            $table->string('avatar')->nullable()->after('email');
            $table->string('fcm_token')->nullable()->after('password');
            $table->enum('account_type', ['public', 'private'])->default('public')->after('fcm_token');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['username', 'avatar', 'fcm_token', 'account_type']);
        });
    }
};
