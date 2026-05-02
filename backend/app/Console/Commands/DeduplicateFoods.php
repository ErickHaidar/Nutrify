<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class DeduplicateFoods extends Command
{
    protected $signature = 'food:deduplicate';

    protected $description = 'Remove duplicate food entries by name (case-insensitive), keeping the first occurrence';

    public function handle(): int
    {
        $this->info('Checking for duplicate foods...');

        $duplicates = DB::table('foods')
            ->selectRaw('LOWER(name) as lower_name, COUNT(*) as count')
            ->groupByRaw('LOWER(name)')
            ->havingRaw('COUNT(*) > 1')
            ->get();

        if ($duplicates->isEmpty()) {
            $this->info('No duplicates found!');
            return self::SUCCESS;
        }

        $this->warn("Found {$duplicates->count()} groups of duplicates:");
        $this->newLine();

        $totalToDelete = 0;
        foreach ($duplicates as $dup) {
            $this->line("  - \"{$dup->lower_name}\" ({$dup->count} copies)");
            $totalToDelete += $dup->count - 1;
        }

        if (!$this->confirm("Delete {$totalToDelete} duplicate entries?", true)) {
            $this->info('Aborted.');
            return self::SUCCESS;
        }

        $deleted = 0;
        foreach ($duplicates as $dup) {
            $ids = DB::table('foods')
                ->whereRaw('LOWER(name) = ?', [$dup->lower_name])
                ->orderBy('id')
                ->pluck('id');

            $keepId = $ids->first();
            $deleteIds = $ids->skip(1)->toArray();

            if (!empty($deleteIds)) {
                DB::table('foods')->whereIn('id', $deleteIds)->delete();
                $deleted += count($deleteIds);
            }
        }

        $this->info("Done! Deleted {$deleted} duplicate entries.");
        return self::SUCCESS;
    }
}
