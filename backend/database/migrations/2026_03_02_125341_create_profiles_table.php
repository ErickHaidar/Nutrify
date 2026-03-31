<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
{
    Schema::create('profiles', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->onDelete('cascade');
    $table->integer('age');
    $table->integer('weight');
    $table->integer('height');
    $table->enum('gender', ['male', 'female']);
    $table->enum('goal', ['cutting', 'maintenance', 'bulking']);
    $table->enum('activity_level', ['sedentary', 'light', 'moderate', 'active', 'very_active']);
    $table->timestamps();
});
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('profiles');
    }
};
