<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class LocalFoodSeeder extends Seeder
{
    public function run(): void
    {
        $csvPath = base_path('../makanan-lokal.csv');

        if (!file_exists($csvPath)) {
            $this->command->error("CSV not found at: {$csvPath}");
            return;
        }

        $handle = fopen($csvPath, 'r');
        if ($handle === false) {
            $this->command->error("Cannot open CSV file.");
            return;
        }

        $header = fgetcsv($handle);
        if ($header === false) {
            fclose($handle);
            return;
        }

        $colIndex = array_flip(array_map('trim', $header));
        $now = now();

        $inserted = 0;
        $skipped = 0;

        while (($row = fgetcsv($handle)) !== false) {
            if (count($row) < 8) {
                continue;
            }

            $name = trim($row[$colIndex['name']] ?? '');
            if ($name === '') {
                continue;
            }

            $exists = DB::table('foods')
                ->whereRaw('LOWER(name) = ?', [strtolower($name)])
                ->exists();

            if ($exists) {
                $skipped++;
                continue;
            }

            DB::table('foods')->insert([
                'name'          => $name,
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
            ]);

            $inserted++;
        }

        fclose($handle);

        $this->command->info("LocalFoodSeeder: Inserted {$inserted} new foods, skipped {$skipped} duplicates.");
    }

    private function parseFloat(string $raw): float
    {
        $cleaned = preg_replace('/[^\d.,\-]/', '', trim($raw));
        $cleaned = str_replace(',', '.', $cleaned);
        return (float) $cleaned;
    }
}
