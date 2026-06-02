<?php

namespace App\Filament\Pages;

use App\Filament\Widgets\DailyActiveUsersChart;
use App\Filament\Widgets\FoodLogActivityChart;
use App\Filament\Widgets\NewRegistrationsChart;
use App\Filament\Widgets\PostActivityChart;
use App\Filament\Widgets\StatsOverview;

class Dashboard extends \Filament\Pages\Dashboard
{
    public function getWidgets(): array
    {
        return [
            StatsOverview::class,
            DailyActiveUsersChart::class,
            NewRegistrationsChart::class,
            FoodLogActivityChart::class,
            PostActivityChart::class,
        ];
    }
}
