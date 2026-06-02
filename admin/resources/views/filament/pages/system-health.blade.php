<x-filament-panels::page>
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        @foreach($this->status as $key => $item)
            <div class="p-4 bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700">
                <div class="flex items-center justify-between mb-2">
                    <h3 class="text-sm font-semibold uppercase tracking-wider text-gray-500 dark:text-gray-400">
                        {{ str_replace('_', ' ', $key) }}
                    </h3>
                    @if(isset($item['ok']))
                        <span class="px-2 py-0.5 text-xs rounded-full font-medium
                            {{ $item['ok'] ? 'bg-green-100 text-green-700 dark:bg-green-900 dark:text-green-300' : 'bg-red-100 text-red-700 dark:bg-red-900 dark:text-red-300' }}">
                            {{ $item['ok'] ? 'OK' : 'ERROR' }}
                        </span>
                    @endif
                </div>
                <p class="text-sm text-gray-700 dark:text-gray-300">
                    @if(isset($item['message']))
                        @if(is_array($item['message']))
                            {{ implode(', ', $item['message']) }}
                        @else
                            {{ $item['message'] }}
                        @endif
                    @elseif(is_array($item))
                        {{ json_encode($item) }}
                    @else
                        {{ $item }}
                    @endif
                </p>
                @if(isset($item['pending']))
                    <div class="mt-2 text-xs text-gray-500">
                        Pending: {{ $item['pending'] }} | Failed: {{ $item['failed'] }}
                    </div>
                @endif
                @if(isset($item['free']))
                    <div class="mt-2 text-xs text-gray-500">
                        Free: {{ $item['free'] }} / Total: {{ $item['total'] }}
                    </div>
                @endif
            </div>
        @endforeach
    </div>
</x-filament-panels::page>
