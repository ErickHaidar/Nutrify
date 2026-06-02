<x-filament-panels::page>
    <form wire:submit="save" class="max-w-2xl">
        {{ $this->form }}

        <div class="mt-6">
            <x-filament::button type="submit" color="success" icon="heroicon-o-check">
                Simpan Pengaturan
            </x-filament::button>
        </div>
    </form>
</x-filament-panels::page>
