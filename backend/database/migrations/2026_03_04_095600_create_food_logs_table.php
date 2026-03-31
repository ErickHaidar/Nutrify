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
    Schema::create('food_logs', function (Blueprint $table) {
        $table->id();
        $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
        $table->foreignId('food_id')->constrained('foods')->onDelete('cascade');

        $table->float('serving_multiplier')->default(1);
        $table->string('meal_time'); 
        $table->timestamps();
    });
}

    public function down(): void
    {
        Schema::dropIfExists('food_logs');
    }
};
