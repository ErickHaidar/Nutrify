<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class NutritionSeeder extends Seeder
{
    /**
     * Seed the foods table from nutrition.csv.
     */
    public function run(): void
    {
        // Path ke file CSV baru di dalam folder docs
        $csvPath = base_path('../docs/nutrition.csv');

        // Fallback jika ditaruh di root
        if (!file_exists($csvPath)) {
            $csvPath = base_path('../nutrition.csv');
        }

        if (!file_exists($csvPath)) {
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

        // Map header column names to their indices (case-insensitive & trimmed)
        $colIndex = array_flip(array_map('trim', $header));

        $now = now();
        $inserted = 0;
        $skipped = 0;

        // Ambil semua nama makanan yang sudah ada di database (lowercase) untuk pencocokan cepat
        $existingFoods = DB::table('foods')
            ->pluck('name')
            ->map(fn($name) => strtolower(trim($name)))
            ->flip()
            ->toArray();

        $batch = [];

        while (($row = fgetcsv($handle)) !== false) {
            // Pastikan baris memiliki kolom yang cukup
            if (count($row) < 5) {
                continue;
            }

            $name = isset($colIndex['name']) ? trim($row[$colIndex['name']]) : '';
            if ($name === '') {
                continue;
            }

            // Cek apakah makanan sudah terdaftar di database (case-insensitive)
            $lowercaseName = strtolower($name);
            if (isset($existingFoods[$lowercaseName])) {
                $skipped++;
                continue;
            }

            // Tambahkan ke daftar existing agar tidak duplikat di dalam file CSV itu sendiri
            $existingFoods[$lowercaseName] = true;

            $batch[] = [
                'name'          => $name,
                'serving_size'  => '100 g', // Default serving size karena data gizi biasanya per 100g
                'calories'      => $this->parseFloat($row[$colIndex['calories']] ?? '0'),
                'protein'       => $this->parseFloat($row[$colIndex['proteins']] ?? '0'),
                'carbohydrates' => $this->parseFloat($row[$colIndex['carbohydrate']] ?? '0'),
                'fat'           => $this->parseFloat($row[$colIndex['fat']] ?? '0'),
                'sugar'         => 0.0, // Tidak ada kolom sugar di nutrition.csv, di-set default 0
                'sodium'        => 0.0, // Tidak ada kolom sodium di nutrition.csv, di-set default 0
                'fiber'         => 0.0, // Tidak ada kolom fiber di nutrition.csv, di-set default 0
                'created_at'    => $now,
                'updated_at'    => $now,
            ];

            // Bulk-insert setiap 200 data
            if (count($batch) >= 200) {
                DB::table('foods')->insert($batch);
                $inserted += count($batch);
                $batch = [];
            }
        }

        // Sisa batch
        if (count($batch) > 0) {
            DB::table('foods')->insert($batch);
            $inserted += count($batch);
        }

        fclose($handle);

        $this->command->info("NutritionSeeder: Berhasil menambahkan {$inserted} makanan baru. {$skipped} makanan dilewati karena duplikat.");
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
