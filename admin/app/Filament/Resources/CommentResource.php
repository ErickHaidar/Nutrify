<?php

namespace App\Filament\Resources;

use App\Filament\Resources\CommentResource\Pages;
use App\Models\Comment;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteAction;
use Filament\Actions\DeleteBulkAction;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class CommentResource extends Resource
{
    protected static ?string $model = Comment::class;
    protected static string | \BackedEnum | null $navigationIcon = 'heroicon-o-chat-bubble-left';
    protected static string | \UnitEnum | null $navigationGroup = 'Komunitas';
    protected static ?string $label = 'Komentar';
    protected static ?string $pluralLabel = 'Komentar';

    public static function table(Table $table): Table
    {
        return $table->columns([
            TextColumn::make('id')->label('ID')->sortable(),
            TextColumn::make('user.name')->label('User')->searchable()->sortable(),
            TextColumn::make('post.id')->label('Post ID')->sortable(),
            TextColumn::make('content')->label('Konten')->limit(50)->searchable(),
            TextColumn::make('created_at')->label('Dibuat')->dateTime('d M Y H:i')->sortable(),
        ])
        ->actions([DeleteAction::make()])
        ->bulkActions([BulkActionGroup::make([DeleteBulkAction::make()])])
        ->defaultSort('created_at', 'desc');
    }

    public static function getRelations(): array { return []; }
    public static function getPages(): array
    {
        return ['index' => Pages\ListComments::route('/')];
    }
}
