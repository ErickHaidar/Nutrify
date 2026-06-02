<?php

namespace App\Filament\Widgets;

use App\Models\FoodLog;
use Filament\Widgets\ChartWidget;
use Illuminate\Support\Facades\DB;

class FoodLogActivityChart extends ChartWidget
{
    protected ?string $heading = 'Aktivitas Food Log (30 Hari)';
    protected static ?int $sort = 4;

    protected function getType(): string
    {
        return 'line';
    }

    protected function getData(): array
    {
        $data = FoodLog::select(
            DB::raw("DATE(created_at) as date"),
            DB::raw("COUNT(*) as count")
        )
        ->where('created_at', '>=', now()->subDays(30))
        ->groupBy('date')
        ->orderBy('date')
        ->get();

        return [
            'labels' => $data->pluck('date')->map(fn($d) => date('d M', strtotime($d)))->toArray(),
            'datasets' => [[
                'label' => 'Food Log',
                'data' => $data->pluck('count')->toArray(),
                'borderColor' => '#f59e0b',
                'backgroundColor' => 'rgba(245,158,11,0.1)',
            ]],
        ];
    }
}
