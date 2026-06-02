<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ProfileResource\Pages;
use App\Models\Profile;
use Filament\Actions\EditAction;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class ProfileResource extends Resource
{
    protected static ?string $model = Profile::class;
    protected static string | \BackedEnum | null $navigationIcon = 'heroicon-o-identification';
    protected static string | \UnitEnum | null $navigationGroup = 'User Management';
    protected static ?string $label = 'Profil';
    protected static ?string $pluralLabel = 'Profil';

    public static function form(Schema $schema): Schema
    {
        return $schema->schema([
            TextInput::make('age')->label('Usia')->numeric()->minValue(13)->maxValue(100),
            TextInput::make('weight')->label('Berat (kg)')->numeric()->minValue(25)->maxValue(300),
            TextInput::make('height')->label('Tinggi (cm)')->numeric()->minValue(100)->maxValue(250),
            Select::make('gender')->label('Gender')->options(['male' => 'Laki-laki', 'female' => 'Perempuan']),
            Select::make('goal')->label('Goal')->options([
                'cutting' => 'Cutting', 'maintenance' => 'Maintenance', 'bulking' => 'Bulking',
            ]),
            Select::make('activity_level')->label('Aktivitas')->options([
                'sedentary' => 'Sedentary', 'light' => 'Ringan', 'moderate' => 'Sedang',
                'active' => 'Aktif', 'very_active' => 'Sangat Aktif',
            ]),
            TextInput::make('target_weight')->label('Target Berat (kg)')->numeric(),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table->columns([
            TextColumn::make('id')->label('ID')->sortable(),
            TextColumn::make('user.name')->label('User')->searchable()->sortable(),
            TextColumn::make('age')->label('Usia')->sortable(),
            TextColumn::make('weight')->label('Berat')->suffix('kg'),
            TextColumn::make('height')->label('Tinggi')->suffix('cm'),
            TextColumn::make('gender')->label('Gender')->badge(),
            TextColumn::make('goal')->label('Goal')->badge()
                ->color(fn(string $state) => match ($state) {
                    'cutting' => 'danger', 'maintenance' => 'success', 'bulking' => 'warning',
                    default => 'gray',
                }),
            TextColumn::make('activity_level')->label('Aktivitas'),
        ])
        ->filters([
            Tables\Filters\SelectFilter::make('goal')->options([
                'cutting' => 'Cutting', 'maintenance' => 'Maintenance', 'bulking' => 'Bulking',
            ]),
            Tables\Filters\SelectFilter::make('gender')->options([
                'male' => 'Laki-laki', 'female' => 'Perempuan',
            ]),
        ])
        ->actions([EditAction::make()]);
    }

    public static function getRelations(): array { return []; }
    public static function getPages(): array
    {
        return [
            'index' => Pages\ListProfiles::route('/'),
            'edit' => Pages\EditProfile::route('/{record}/edit'),
        ];
    }
}
