<?php

namespace App\Console\Commands;

use App\Models\Food;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class ImportFoods extends Command
{
    protected $signature = 'foods:import
                            {--file= : Path to CSV file (default: dataset_pipeline/output/foods_id_clean.csv)}
                            {--dry-run : Preview without inserting}';

    protected $description = 'Import cleaned food dataset (CSV → foods table)';

    public function handle(): int
    {
        $csvPath = $this->option('file')
            ?? base_path('../dataset_pipeline/output/foods_id_clean.csv');

        if (!file_exists($csvPath)) {
            $this->error("CSV not found: $csvPath");
            return 1;
        }

        $this->info("Reading: $csvPath");

        $handle = fopen($csvPath, 'r');
        $headers = fgetcsv($handle);
        $this->info('Columns: ' . implode(', ', $headers));

        $inserted = 0;
        $skipped = 0;
        $errors = 0;
        $total = 0;

        // Get existing food names for dedup
        $existing = Food::pluck('name')->map(fn($n) => mb_strtolower(trim($n)))->toArray();
        $existingLookup = array_flip($existing);

        $batch = [];
        $batchSize = 100;

        while (($row = fgetcsv($handle)) !== false) {
            $total++;
            $data = array_combine($headers, $row);

            $name = trim($data['name_id'] ?? $data['name'] ?? '');
            if (empty($name)) {
                $skipped++;
                continue;
            }

            // Skip exact duplicates
            if (isset($existingLookup[mb_strtolower($name)])) {
                $skipped++;
                continue;
            }

            $food = [
                'name'          => $name,
                'serving_size'  => $data['serving_size'] ?? null,
                'calories'      => $this->toFloat($data['calories'] ?? 0),
                'protein'       => $this->toFloat($data['protein_g'] ?? 0),
                'carbohydrates' => $this->toFloat($data['carbohydrate_g'] ?? 0),
                'fat'           => $this->toFloat($data['fat_g'] ?? 0),
                'sugar'         => $this->toFloat($data['sugar_g'] ?? 0),
                'sodium'        => $this->toFloat($data['sodium_mg'] ?? 0),
                'fiber'         => $this->toFloat($data['fiber_g'] ?? 0),
                'food_type'     => $data['food_type'] ?? null,
                'source'        => $data['source'] ?? null,
                'created_at'    => now(),
                'updated_at'    => now(),
            ];

            if ($this->option('dry-run') && $inserted < 10) {
                $this->line("  [dry-run] {$name} | {$data['calories']} cal | {$data['food_type']}");
            }

            $batch[] = $food;
            $existingLookup[mb_strtolower($name)] = 1; // Track in-memory

            if (count($batch) >= $batchSize) {
                try {
                    Food::insert($batch);
                    $inserted += count($batch);
                } catch (\Exception $e) {
                    $this->error("Batch insert error: {$e->getMessage()}");
                    $errors += count($batch);
                }
                $batch = [];
            }
        }
        fclose($handle);

        // Final batch
        if (!empty($batch)) {
            try {
                Food::insert($batch);
                $inserted += count($batch);
            } catch (\Exception $e) {
                $this->error("Final batch error: {$e->getMessage()}");
                $errors += count($batch);
            }
        }

        $this->newLine();
        $this->info("Import complete:");
        $this->line("  Total in CSV: $total");
        $this->line("  Inserted: $inserted");
        $this->line("  Skipped (duplicates): $skipped");
        $this->line("  Errors: $errors");
        $this->line("  Total in DB: " . Food::count());

        return 0;
    }

    private function toFloat($val): float
    {
        if (empty($val) || $val === 'nan' || $val === 'NaN') {
            return 0.0;
        }
        return (float) $val;
    }
}
