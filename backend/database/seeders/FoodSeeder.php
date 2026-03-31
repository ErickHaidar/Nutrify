<?php
// database/seeders/FoodSeeder.php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class FoodSeeder extends Seeder
{
    /**
     * Seed the foods table from nilai-gizi.csv.
     */
    public function run(): void
    {
        $csvPath = base_path('../nilai-gizi.csv');

        if (! file_exists($csvPath)) {
            $this->command->error("CSV not found at: {$csvPath}");
            return;
        }

        $handle = fopen($csvPath, 'r');
        if ($handle === false) {
            $this->command->error("Cannot open CSV file.");
            return;
        }

        // Read header row
        $header = fgetcsv($handle);
        if ($header === false) {
            fclose($handle);
            return;
        }

        // Map header column names to their indices
        $colIndex = array_flip(array_map('trim', $header));

        $batch  = [];
        $count  = 0;
        $now    = now();

        while (($row = fgetcsv($handle)) !== false) {
            // Skip empty rows
            if (count($row) < 8) {
                continue;
            }

            $batch[] = [
                'name'          => trim($row[$colIndex['name']] ?? ''),
                'serving_size'  => trim($row[$colIndex['serving_size']] ?? ''),
                'calories'      => $this->parseFloat($row[$colIndex['energy_kcal']] ?? '0'),
                'protein'       => $this->parseFloat($row[$colIndex['protein_g']] ?? '0'),
                'carbohydrates' => $this->parseFloat($row[$colIndex['carbohydrate_g']] ?? '0'),
                'fat'           => $this->parseFloat($row[$colIndex['fat_g']] ?? '0'),
                'sugar'         => $this->parseFloat($row[$colIndex['sugar_g']] ?? '0'),
                'sodium'        => $this->parseFloat($row[$colIndex['sodium_mg']] ?? '0'),
                'fiber'         => $this->parseFloat($row[$colIndex['fiber_g']] ?? '0'),
                'created_at'    => $now,
                'updated_at'    => $now,
            ];

            // Bulk-insert every 200 rows to stay within query-size limits
            if (count($batch) >= 200) {
                DB::table('foods')->insert($batch);
                $count += count($batch);
                $batch = [];
            }
        }

        // Insert remaining rows
        if (count($batch) > 0) {
            DB::table('foods')->insert($batch);
            $count += count($batch);
        }

        fclose($handle);

        $this->command->info("Seeded {$count} foods from nilai-gizi.csv");
    }

    /**
     * Parse a locale-agnostic float. Handles "20.30 g" → 20.30 and "1,5" → 1.5.
     */
    private function parseFloat(string $raw): float
    {
        $cleaned = preg_replace('/[^\d.,\-]/', '', trim($raw));
        $cleaned = str_replace(',', '.', $cleaned);

        return (float) $cleaned;
    }
}
