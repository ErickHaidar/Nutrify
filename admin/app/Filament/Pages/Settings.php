<?php

namespace App\Filament\Pages;

use App\Models\Setting;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Concerns\InteractsWithForms;
use Filament\Forms\Contracts\HasForms;
use Filament\Notifications\Notification;
use Filament\Pages\Page;
use Filament\Schemas\Schema;

class Settings extends Page implements HasForms
{
    use InteractsWithForms;

    protected static string | \BackedEnum | null $navigationIcon = 'heroicon-o-cog';
    protected static string | \UnitEnum | null $navigationGroup = 'Sistem';
    protected static ?string $title = 'Pengaturan';
    protected static ?string $slug = 'settings';
    protected string $view = 'filament.pages.settings';

    public ?array $data = [];

    public function mount(): void
    {
        $this->form->fill([
            'banned_words' => Setting::get('banned_words', ''),
            'report_threshold' => Setting::get('report_threshold', '3'),
            'otp_expiry' => Setting::get('otp_expiry', '5'),
            'fcm_server_key' => Setting::get('fcm_server_key', ''),
        ]);
    }

    public function form(Schema $schema): Schema
    {
        return $schema->schema([
            Textarea::make('banned_words')
                ->label('Kata Terlarang')
                ->helperText('Pisahkan dengan koma. Post dengan kata ini akan auto-flagged.')
                ->rows(3),
            TextInput::make('report_threshold')
                ->label('Batas Report (Auto-hide)')
                ->numeric()
                ->minValue(1)
                ->default(3)
                ->helperText('Post otomatis disembunyikan jika jumlah report mencapai nilai ini.'),
            TextInput::make('otp_expiry')
                ->label('OTP Expiry (menit)')
                ->numeric()
                ->minValue(1)
                ->default(5),
            TextInput::make('fcm_server_key')
                ->label('FCM Server Key')
                ->password()
                ->revealable()
                ->helperText('Firebase Cloud Messaging server key untuk push notification.'),
        ])
        ->statePath('data');
    }

    public function save(): void
    {
        $data = $this->form->getState();

        foreach ($data as $key => $value) {
            Setting::set($key, $value);
        }

        Notification::make()
            ->title('Pengaturan disimpan')
            ->success()
            ->send();
    }
}
