<?php

namespace App\Filament\Resources;

use App\Filament\Resources\FoodLogResource\Pages;
use App\Models\FoodLog;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteAction;
use Filament\Actions\DeleteBulkAction;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class FoodLogResource extends Resource
{
    protected static ?string $model = FoodLog::class;
    protected static string | \BackedEnum | null $navigationIcon = 'heroicon-o-clipboard-document-list';
    protected static string | \UnitEnum | null $navigationGroup = 'Database Makanan';
    protected static ?string $label = 'Food Log';
    protected static ?string $pluralLabel = 'Food Logs';

    public static function table(Table $table): Table
    {
        return $table->columns([
            TextColumn::make('id')->label('ID')->sortable(),
            TextColumn::make('user.name')->label('User')->searchable()->sortable(),
            TextColumn::make('food.name')->label('Makanan')->searchable()->sortable(),
            TextColumn::make('meal_time')->label('Waktu Makan')->badge()->sortable(),
            TextColumn::make('serving_multiplier')->label('Porsi')->numeric(1),
            TextColumn::make('unit')->label('Unit'),
            TextColumn::make('created_at')->label('Tanggal')->dateTime('d M Y H:i')->sortable(),
        ])
        ->filters([
            Tables\Filters\SelectFilter::make('meal_time')->label('Waktu Makan')->options([
                'Breakfast' => 'Sarapan', 'Lunch' => 'Makan Siang',
                'Dinner' => 'Makan Malam', 'Snack' => 'Camilan',
            ]),
        ])
        ->actions([DeleteAction::make()])
        ->bulkActions([BulkActionGroup::make([DeleteBulkAction::make()])])
        ->defaultSort('created_at', 'desc');
    }

    public static function getRelations(): array { return []; }
    public static function getPages(): array
    {
        return ['index' => Pages\ListFoodLogs::route('/')];
    }
}
