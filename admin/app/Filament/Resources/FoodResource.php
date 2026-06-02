<?php

namespace App\Filament\Resources;

use App\Filament\Resources\FoodResource\Pages;
use App\Models\Food;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class FoodResource extends Resource
{
    protected static ?string $model = Food::class;
    protected static string | \BackedEnum | null $navigationIcon = 'heroicon-o-cube';
    protected static string | \UnitEnum | null $navigationGroup = 'Database Makanan';
    protected static ?string $label = 'Makanan';
    protected static ?string $pluralLabel = 'Makanan';

    public static function form(Schema $schema): Schema
    {
        return $schema->schema([
            TextInput::make('name')->label('Nama Makanan')->required()->maxLength(255),
            TextInput::make('serving_size')->label('Ukuran Saji')->maxLength(50),
            Select::make('food_type')->label('Kategori')->options([
                'makanan_pokok' => 'Makanan Pokok',
                'lauk_pauk' => 'Lauk Pauk',
                'sayuran' => 'Sayuran',
                'buah' => 'Buah',
                'minuman' => 'Minuman',
                'camilan' => 'Camilan',
                'bumbu' => 'Bumbu',
            ]),
            TextInput::make('calories')->label('Kalori (kkal)')->numeric()->step(0.1)->default(0),
            TextInput::make('protein')->label('Protein (g)')->numeric()->step(0.1)->default(0),
            TextInput::make('carbohydrates')->label('Karbohidrat (g)')->numeric()->step(0.1)->default(0),
            TextInput::make('fat')->label('Lemak (g)')->numeric()->step(0.1)->default(0),
            TextInput::make('sugar')->label('Gula (g)')->numeric()->step(0.1)->default(0),
            TextInput::make('sodium')->label('Sodium (mg)')->numeric()->step(0.1)->default(0),
            TextInput::make('fiber')->label('Serat (g)')->numeric()->step(0.1)->default(0),
            TextInput::make('source')->label('Sumber Data')->maxLength(100),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table->columns([
            TextColumn::make('id')->label('ID')->sortable(),
            TextColumn::make('name')->label('Nama')->searchable()->sortable(),
            TextColumn::make('food_type')->label('Kategori')->badge()->sortable(),
            TextColumn::make('serving_size')->label('Sajian'),
            TextColumn::make('calories')->label('Kalori')->numeric(1)->sortable(),
            TextColumn::make('protein')->label('Protein')->numeric(1),
            TextColumn::make('fat')->label('Lemak')->numeric(1),
            TextColumn::make('carbohydrates')->label('Karbo')->numeric(1),
        ])
        ->filters([
            Tables\Filters\SelectFilter::make('food_type')->label('Kategori')->options([
                'makanan_pokok' => 'Makanan Pokok',
                'lauk_pauk' => 'Lauk Pauk',
                'sayuran' => 'Sayuran',
                'buah' => 'Buah',
                'minuman' => 'Minuman',
                'camilan' => 'Camilan',
                'bumbu' => 'Bumbu',
            ]),
        ])
        ->actions([
            Tables\Actions\EditAction::make(),
            Tables\Actions\DeleteAction::make(),
        ])
        ->bulkActions([Tables\Actions\BulkActionGroup::make([Tables\Actions\DeleteBulkAction::make()])]);
    }

    public static function getRelations(): array { return []; }
    public static function getPages(): array
    {
        return [
            'index' => Pages\ListFoods::route('/'),
            'create' => Pages\CreateFood::route('/create'),
            'edit' => Pages\EditFood::route('/{record}/edit'),
        ];
    }
}
