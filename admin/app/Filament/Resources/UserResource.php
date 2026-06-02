<?php

namespace App\Filament\Resources;

use App\Filament\Resources\UserResource\Pages;
use App\Models\User;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteAction;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class UserResource extends Resource
{
    protected static ?string $model = User::class;
    protected static string | \BackedEnum | null $navigationIcon = 'heroicon-o-users';
    protected static string | \UnitEnum | null $navigationGroup = 'User Management';
    protected static ?string $label = 'Pengguna';
    protected static ?string $pluralLabel = 'Pengguna';

    public static function form(Schema $schema): Schema
    {
        return $schema->schema([
            TextInput::make('name')->label('Nama')->required()->maxLength(255),
            TextInput::make('email')->label('Email')->email()->required()->unique(ignoreRecord: true),
            TextInput::make('username')->label('Username')->unique(ignoreRecord: true),
            TextInput::make('password')->label('Password')->password()->revealable()
                ->dehydrateStateUsing(fn($state) => bcrypt($state))
                ->dehydrated(fn($state) => filled($state))
                ->required(fn(string $operation) => $operation === 'create'),
            Select::make('account_type')->label('Tipe Akun')->options([
                'public' => 'Public', 'private' => 'Private',
            ])->default('public'),
            TextInput::make('fcm_token')->label('FCM Token')->maxLength(255),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table->columns([
            TextColumn::make('id')->label('ID')->sortable(),
            TextColumn::make('name')->label('Nama')->searchable()->sortable(),
            TextColumn::make('email')->label('Email')->searchable()->sortable(),
            TextColumn::make('username')->label('Username')->searchable(),
            TextColumn::make('account_type')->label('Tipe Akun')->badge()
                ->color(fn(string $state) => $state === 'public' ? 'success' : 'warning'),
            TextColumn::make('created_at')->label('Terdaftar')->dateTime('d M Y')->sortable(),
            TextColumn::make('posts_count')->label('Post')->counts('posts')->sortable(),
            TextColumn::make('food_logs_count')->label('Food Log')->counts('foodLogs')->sortable(),
        ])
        ->filters([
            Tables\Filters\SelectFilter::make('account_type')->label('Tipe Akun')->options([
                'public' => 'Public', 'private' => 'Private',
            ]),
        ])
        ->actions([
            EditAction::make(),
            DeleteAction::make(),
        ])
        ->bulkActions([BulkActionGroup::make([DeleteBulkAction::make()])]);
    }

    public static function getRelations(): array { return []; }
    public static function getPages(): array
    {
        return [
            'index' => Pages\ListUsers::route('/'),
            'create' => Pages\CreateUser::route('/create'),
            'edit' => Pages\EditUser::route('/{record}/edit'),
        ];
    }
}
