<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ConversationResource\Pages;
use App\Models\Conversation;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteAction;
use Filament\Actions\DeleteBulkAction;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class ConversationResource extends Resource
{
    protected static ?string $model = Conversation::class;
    protected static string | \BackedEnum | null $navigationIcon = 'heroicon-o-chat-bubble-oval-left';
    protected static string | \UnitEnum | null $navigationGroup = 'Komunitas';
    protected static ?string $label = 'Percakapan';
    protected static ?string $pluralLabel = 'Percakapan';

    public static function table(Table $table): Table
    {
        return $table->columns([
            TextColumn::make('id')->label('ID')->sortable(),
            TextColumn::make('user1.name')->label('User 1')->searchable(),
            TextColumn::make('user2.name')->label('User 2')->searchable(),
            TextColumn::make('messages_count')->label('Pesan')->counts('messages')->sortable(),
            TextColumn::make('last_message_at')->label('Pesan Terakhir')->dateTime('d M Y H:i')->sortable(),
            TextColumn::make('created_at')->label('Dibuat')->dateTime('d M Y')->sortable(),
        ])
        ->actions([DeleteAction::make()])
        ->bulkActions([BulkActionGroup::make([DeleteBulkAction::make()])])
        ->defaultSort('last_message_at', 'desc');
    }

    public static function getRelations(): array { return []; }
    public static function getPages(): array
    {
        return ['index' => Pages\ListConversations::route('/')];
    }
}
