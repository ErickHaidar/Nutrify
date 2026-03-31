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
        Schema::create('foods', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('serving_size')->nullable();   // e.g. "100g", "1 porsi"
            $table->float('calories')->default(0);        // energy_kcal
            $table->float('protein')->default(0);         // protein_g
            $table->float('carbohydrates')->default(0);   // carbohydrate_g
            $table->float('fat')->default(0);             // fat_g
            $table->float('sugar')->default(0);           // sugar_g
            $table->float('sodium')->default(0);          // sodium_mg
            $table->float('fiber')->default(0);           // fiber_g
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('foods');
    }
};
