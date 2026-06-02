<?php

namespace App\Filament\Resources;

use App\Filament\Resources\NotificationResource\Pages;
use App\Models\Notification;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class NotificationResource extends Resource
{
    protected static ?string $model = Notification::class;
    protected static string | \BackedEnum | null $navigationIcon = 'heroicon-o-bell';
    protected static string | \UnitEnum | null $navigationGroup = 'Sistem';
    protected static ?string $label = 'Notifikasi';
    protected static ?string $pluralLabel = 'Notifikasi';

    public static function table(Table $table): Table
    {
        return $table->columns([
            TextColumn::make('id')->label('ID')->sortable(),
            TextColumn::make('user.name')->label('User')->searchable(),
            TextColumn::make('type')->label('Tipe')->badge()->sortable(),
            TextColumn::make('title')->label('Judul')->searchable()->limit(30),
            TextColumn::make('body')->label('Isi')->limit(40),
            IconColumn::make('read_at')->label('Dibaca')->boolean(fn($state) => $state !== null),
            TextColumn::make('created_at')->label('Dibuat')->dateTime('d M Y H:i')->sortable(),
        ])
        ->filters([
            Tables\Filters\SelectFilter::make('type')->label('Tipe')->options([
                'like' => 'Like', 'comment' => 'Comment', 'reply' => 'Reply',
                'follow' => 'Follow', 'follow_request' => 'Follow Request',
                'post_hidden' => 'Post Hidden', 'message' => 'Message', 'comment_like' => 'Comment Like',
            ]),
            Tables\Filters\TernaryFilter::make('read_at')->label('Dibaca')->nullable(),
        ])
        ->actions([Tables\Actions\DeleteAction::make()])
        ->bulkActions([Tables\Actions\BulkActionGroup::make([Tables\Actions\DeleteBulkAction::make()])])
        ->defaultSort('created_at', 'desc');
    }

    public static function getRelations(): array { return []; }
    public static function getPages(): array
    {
        return ['index' => Pages\ListNotifications::route('/')];
    }
}
