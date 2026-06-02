<?php

namespace App\Filament\Widgets;

use App\Models\FoodLog;
use Filament\Widgets\ChartWidget;
use Illuminate\Support\Facades\DB;

class DailyActiveUsersChart extends ChartWidget
{
    protected ?string $heading = 'User Aktif Harian (7 Hari)';
    protected static ?int $sort = 2;

    protected function getType(): string
    {
        return 'line';
    }

    protected function getData(): array
    {
        $data = FoodLog::select(
            DB::raw("DATE(created_at) as date"),
            DB::raw("COUNT(DISTINCT user_id) as count")
        )
        ->where('created_at', '>=', now()->subDays(7))
        ->groupBy('date')
        ->orderBy('date')
        ->get();

        return [
            'labels' => $data->pluck('date')->map(fn($d) => date('d M', strtotime($d)))->toArray(),
            'datasets' => [[
                'label' => 'User Aktif',
                'data' => $data->pluck('count')->toArray(),
                'borderColor' => '#10b981',
                'backgroundColor' => 'rgba(16,185,129,0.1)',
            ]],
        ];
    }
}
