<?php

namespace App\Filament\Resources;

use App\Filament\Resources\WeightLogResource\Pages;
use App\Models\WeightLog;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteAction;
use Filament\Actions\DeleteBulkAction;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class WeightLogResource extends Resource
{
    protected static ?string $model = WeightLog::class;
    protected static string | \BackedEnum | null $navigationIcon = 'heroicon-o-scale';
    protected static string | \UnitEnum | null $navigationGroup = 'Database Makanan';
    protected static ?string $label = 'Weight Log';
    protected static ?string $pluralLabel = 'Weight Logs';

    public static function table(Table $table): Table
    {
        return $table->columns([
            TextColumn::make('id')->label('ID')->sortable(),
            TextColumn::make('user.name')->label('User')->searchable()->sortable(),
            TextColumn::make('weight')->label('Berat (kg)')->sortable(),
            TextColumn::make('created_at')->label('Tanggal')->date('d M Y')->sortable(),
        ])
        ->actions([DeleteAction::make()])
        ->bulkActions([BulkActionGroup::make([DeleteBulkAction::make()])])
        ->defaultSort('created_at', 'desc');
    }

    public static function getRelations(): array { return []; }
    public static function getPages(): array
    {
        return ['index' => Pages\ListWeightLogs::route('/')];
    }
}
