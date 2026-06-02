<?php

namespace App\Filament\Pages;

use Filament\Pages\Page;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Queue;

class SystemHealth extends Page
{
    protected static string | \BackedEnum | null $navigationIcon = 'heroicon-o-server';
    protected static string | \UnitEnum | null $navigationGroup = 'Sistem';
    protected static ?string $title = 'System Health';
    protected static ?string $slug = 'system';
    protected string $view = 'filament.pages.system-health';

    public array $status = [];

    public function mount(): void
    {
        $this->status = [
            'database' => $this->checkDatabase(),
            'queue' => $this->checkQueue(),
            'cache' => $this->checkCache(),
            'php_version' => PHP_VERSION,
            'laravel_version' => app()->version(),
            'storage' => $this->checkStorage(),
        ];
    }

    private function checkDatabase(): array
    {
        try {
            DB::connection()->getPdo();
            return ['ok' => true, 'message' => 'Connected — ' . DB::connection()->getDatabaseName()];
        } catch (\Exception $e) {
            return ['ok' => false, 'message' => $e->getMessage()];
        }
    }

    private function checkQueue(): array
    {
        $pending = DB::table('jobs')->count();
        $failed = DB::table('failed_jobs')->count();
        return [
            'ok' => $failed === 0,
            'pending' => $pending,
            'failed' => $failed,
            'message' => "Pending: {$pending}, Failed: {$failed}",
        ];
    }

    private function checkCache(): array
    {
        try {
            Cache::put('health_check', 'ok', 10);
            $val = Cache::get('health_check');
            return ['ok' => $val === 'ok', 'message' => 'Cache write/read OK'];
        } catch (\Exception $e) {
            return ['ok' => false, 'message' => $e->getMessage()];
        }
    }

    private function checkStorage(): array
    {
        $free = disk_free_space(storage_path());
        $total = disk_total_space(storage_path());
        return [
            'ok' => true,
            'free' => round($free / 1024 / 1024, 1) . ' MB',
            'total' => round($total / 1024 / 1024, 1) . ' MB',
        ];
    }
}
