<?php

namespace App\Filament\Widgets;

use App\Models\Food;
use App\Models\FoodLog;
use App\Models\Post;
use App\Models\User;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class StatsOverview extends BaseWidget
{
    protected function getStats(): array
    {
        $totalUsers = User::count();
        $newUsersWeek = User::where('created_at', '>=', now()->subWeek())->count();
        $totalFoods = Food::count();
        $totalPosts = Post::count();
        $hiddenPosts = Post::where('is_hidden', true)->count();
        $foodLogsToday = FoodLog::whereDate('created_at', today())->count();

        return [
            Stat::make('Total Pengguna', $totalUsers)
                ->description("+{$newUsersWeek} minggu ini")
                ->descriptionIcon('heroicon-m-arrow-trending-up')
                ->color('success'),
            Stat::make('Total Makanan', $totalFoods)
                ->description('Database makanan')
                ->color('primary'),
            Stat::make('Total Post', $totalPosts)
                ->description("{$hiddenPosts} disembunyikan")
                ->descriptionIcon('heroicon-m-eye-slash')
                ->color($hiddenPosts > 0 ? 'warning' : 'success'),
            Stat::make('Food Log Hari Ini', $foodLogsToday)
                ->description(date('d F Y'))
                ->color('info'),
        ];
    }
}
