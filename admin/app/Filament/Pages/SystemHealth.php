<?php

namespace App\Filament\Pages;

use Filament\Pages\Page;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;

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
            'supabase_api' => $this->checkSupabase(),
            'php_version' => ['message' => PHP_VERSION],
            'laravel_version' => ['message' => app()->version()],
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
        try {
            $pending = DB::table('jobs')->count();
            $failed = DB::table('failed_jobs')->count();
            return [
                'ok' => $failed === 0,
                'pending' => $pending,
                'failed' => $failed,
                'message' => "Pending: {$pending}, Failed: {$failed}",
            ];
        } catch (\Exception $e) {
            return [
                'ok' => true,
                'pending' => 0,
                'failed' => 0,
                'message' => 'Queue tables not set up (not required)',
            ];
        }
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

    private function checkSupabase(): array
    {
        try {
            $url = config('database.connections.pgsql.host');
            $key = config('services.supabase.key');
            $response = Http::timeout(5)
                ->withHeaders(['apikey' => $key ?? '', 'Authorization' => 'Bearer ' . ($key ?? '')])
                ->get("https://{$url}/rest/v1/");
            $ok = $response->status() < 500;
            return ['ok' => $ok, 'message' => $ok ? 'Supabase API reachable' : 'Status: ' . $response->status()];
        } catch (\Exception $e) {
            return ['ok' => false, 'message' => 'Not configured or unreachable: ' . $e->getMessage()];
        }
    }

    private function checkStorage(): array
    {
        $free = disk_free_space(storage_path());
        $total = disk_total_space(storage_path());
        $freeMb = round($free / 1024 / 1024, 1);
        $totalMb = round($total / 1024 / 1024, 1);
        return [
            'ok' => true,
            'free' => $freeMb . ' MB',
            'total' => $totalMb . ' MB',
            'message' => "Free: {$freeMb} MB / Total: {$totalMb} MB",
        ];
    }
}
