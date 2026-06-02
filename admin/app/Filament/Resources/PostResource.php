<?php

namespace App\Filament\Resources;

use App\Filament\Resources\PostResource\Pages;
use App\Models\Post;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class PostResource extends Resource
{
    protected static ?string $model = Post::class;
    protected static string | \BackedEnum | null $navigationIcon = 'heroicon-o-chat-bubble-left-right';
    protected static string | \UnitEnum | null $navigationGroup = 'Komunitas';
    protected static ?string $label = 'Post';
    protected static ?string $pluralLabel = 'Posts';

    public static function form(Schema $schema): Schema
    {
        return $schema->schema([
            Textarea::make('content')->label('Konten')->required()->maxLength(1000),
            Select::make('is_hidden')->label('Status')->options([
                false => 'Aktif', true => 'Disembunyikan',
            ])->default(false),
            Textarea::make('image_url')->label('URL Gambar'),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table->columns([
            TextColumn::make('id')->label('ID')->sortable(),
            TextColumn::make('user.name')->label('User')->searchable()->sortable(),
            TextColumn::make('content')->label('Konten')->limit(50)->searchable(),
            IconColumn::make('is_hidden')->label('Hidden')->boolean(),
            TextColumn::make('reports_count')->label('Reports')->sortable(),
            TextColumn::make('likes_count')->label('Likes')->counts('likes')->sortable(),
            TextColumn::make('comments_count')->label('Komen')->counts('comments')->sortable(),
            TextColumn::make('created_at')->label('Dibuat')->dateTime('d M Y H:i')->sortable(),
        ])
        ->filters([
            Tables\Filters\TernaryFilter::make('is_hidden')->label('Hidden'),
        ])
        ->actions([
            Tables\Actions\EditAction::make(),
            Tables\Actions\Action::make('toggle_hide')
                ->label(fn(Post $record) => $record->is_hidden ? 'Unhide' : 'Hide')
                ->action(fn(Post $record) => $record->update(['is_hidden' => !$record->is_hidden]))
                ->color(fn(Post $record) => $record->is_hidden ? 'success' : 'warning')
                ->icon(fn(Post $record) => $record->is_hidden ? 'heroicon-o-eye' : 'heroicon-o-eye-slash'),
            Tables\Actions\DeleteAction::make(),
        ])
        ->bulkActions([Tables\Actions\BulkActionGroup::make([Tables\Actions\DeleteBulkAction::make()])])
        ->defaultSort('created_at', 'desc');
    }

    public static function getRelations(): array { return []; }
    public static function getPages(): array
    {
        return [
            'index' => Pages\ListPosts::route('/'),
            'edit' => Pages\EditPost::route('/{record}/edit'),
        ];
    }
}
