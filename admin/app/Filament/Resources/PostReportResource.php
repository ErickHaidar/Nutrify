<?php

namespace App\Filament\Resources;

use App\Filament\Resources\PostReportResource\Pages;
use App\Models\PostReport;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class PostReportResource extends Resource
{
    protected static ?string $model = PostReport::class;
    protected static string | \BackedEnum | null $navigationIcon = 'heroicon-o-flag';
    protected static string | \UnitEnum | null $navigationGroup = 'Komunitas';
    protected static ?string $label = 'Laporan Post';
    protected static ?string $pluralLabel = 'Laporan Post';

    public static function table(Table $table): Table
    {
        return $table->columns([
            TextColumn::make('id')->label('ID')->sortable(),
            TextColumn::make('post.id')->label('Post ID')->sortable(),
            TextColumn::make('post.content')->label('Post')->limit(40),
            TextColumn::make('user.name')->label('Pelapor')->searchable(),
            TextColumn::make('category')->label('Kategori')->badge()
                ->color(fn(string $state) => match ($state) {
                    'spam' => 'gray', 'inappropriate' => 'danger', 'sara' => 'warning',
                    default => 'gray',
                }),
            TextColumn::make('note')->label('Catatan')->limit(30),
            TextColumn::make('created_at')->label('Dilaporkan')->dateTime('d M Y H:i')->sortable(),
        ])
        ->filters([
            Tables\Filters\SelectFilter::make('category')->label('Kategori')->options([
                'spam' => 'Spam', 'inappropriate' => 'Inappropriate', 'sara' => 'SARA',
            ]),
        ])
        ->actions([
            Tables\Actions\Action::make('hide_post')
                ->label('Sembunyikan Post')
                ->icon('heroicon-o-eye-slash')
                ->color('warning')
                ->action(fn(PostReport $record) => $record->post->update(['is_hidden' => true])),
            Tables\Actions\DeleteAction::make()->label('Hapus Laporan'),
        ])
        ->bulkActions([Tables\Actions\BulkActionGroup::make([Tables\Actions\DeleteBulkAction::make()])])
        ->defaultSort('created_at', 'desc');
    }

    public static function getRelations(): array { return []; }
    public static function getPages(): array
    {
        return ['index' => Pages\ListPostReports::route('/')];
    }
}
