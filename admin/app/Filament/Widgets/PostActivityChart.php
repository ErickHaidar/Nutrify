<?php

namespace App\Filament\Widgets;

use App\Models\Post;
use Filament\Widgets\ChartWidget;
use Illuminate\Support\Facades\DB;

class PostActivityChart extends ChartWidget
{
    protected ?string $heading = 'Aktivitas Post (30 Hari)';
    protected static ?int $sort = 5;

    protected function getType(): string
    {
        return 'bar';
    }

    protected function getData(): array
    {
        $data = Post::select(
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
                'label' => 'Post Baru',
                'data' => $data->pluck('count')->toArray(),
                'backgroundColor' => '#8b5cf6',
            ]],
        ];
    }
}
