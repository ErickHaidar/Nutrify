<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class CleanFoods extends Command
{
    protected $signature = 'food:clean {--dry-run : Preview changes without executing}';
    protected $description = 'Hapus item non-makanan dari dataset dan standardisasi nama';

    // Pola nama yang HARUS dihapus (bumbu, saus, bahan masak mentah, item tidak relevan)
    private array $removePatterns = [
        // Bumbu & saus masak (bukan makanan yang dimakan langsung)
        '/\bbumbu\b/i',
        '/\broyco\b/i',
        '/\bmasako\b/i',
        '/\bmaggi\b/i',
        '/\bajinomoto\b/i',
        '/\bmicin\b/i',
        '/\bvetsin\b/i',
        '/\bpenyedap\b/i',
        '/\bkaldu bubuk\b/i',

        // Bumbu dapur segar/kering (bukan hidangan)
        '/^kunyit[,.\s]/i',
        '/^jahe[,.\s]/i',
        '/^lengkuas[,.\s]/i',
        '/^kencur[,.\s]/i',
        '/^serai[,.\s]/i',
        '/^daun salam/i',
        '/^daun jeruk/i',
        '/^daun pandan/i',
        '/^daun kunyit/i',
        '/^ketumbar[,.\s]/i',
        '/^jinten[,.\s]/i',
        '/^pala[,.\s]/i',
        '/^cengkeh[,.\s]/i',
        '/^kayu manis/i',
        '/^kapulaga[,.\s]/i',
        '/^bunga lawang/i',
        '/^asam jawa/i',
        '/^asam kandis/i',
        '/^cabai bubuk/i',
        '/^lada bubuk/i',
        '/^merica bubuk/i',

        // Saus & kecap (bahan masakan, bukan makanan)
        '/^kecap (asin|manis|ikan|inggris)/i',
        '/^saus (tiram|teriyaki|bbq|barbeque|char siu|hoisin|sambal|tomat|pedas)/i',
        '/^saus char siu/i',

        // Bahan masak murni (bukan hidangan siap makan)
        '/^tepung (terigu|beras|ketan|tapioka|sagu|maizena|panir|roti|gandum)/i',
        '/^gula (pasir|merah|aren|kelapa|jawa|bubuk|halus)/i',
        '/^garam dapur/i',
        '/^minyak (goreng|sayur|kelapa|zaitun|wijen|jagung)/i',
        '/^santan (kental|encer|kelapa)/i',
        '/^terasi/i',
        '/^ebi[,.\s]/i',
        '/^petis/i',

        // Item aneh / tidak jelas
        '/^nasi gemuk/i',
        '/^nasi goreng bumbu/i',
        '/^bubuk (kari|kayu manis|pala|ketumbar)/i',
        '/^esens/i',
        '/^pewarna/i',
    ];

    // Koreksi nama (typo, singkatan aneh → nama benar)
    private array $nameCorrections = [
        'air putih' => 'Air Putih',
        'air mineral' => 'Air Mineral',
        'nasi putih' => 'Nasi Putih',
        'nasi goreng' => 'Nasi Goreng',
        'nasi uduk' => 'Nasi Uduk',
        'nasi kuning' => 'Nasi Kuning',
        'mie goreng' => 'Mie Goreng',
        'mie rebus' => 'Mie Rebus',
        'roti tawar' => 'Roti Tawar',
        'roti gandum' => 'Roti Gandum',
        'telur dadar' => 'Telur Dadar',
        'telur rebus' => 'Telur Rebus',
        'telur goreng' => 'Telur Goreng (Ceplok)',
        'ayam goreng' => 'Ayam Goreng',
        'ayam bakar' => 'Ayam Bakar',
        'ikan goreng' => 'Ikan Goreng',
        'ikan bakar' => 'Ikan Bakar',
        'tempe goreng' => 'Tempe Goreng',
        'tahu goreng' => 'Tahu Goreng',
        'pisang goreng' => 'Pisang Goreng',
        'singkong goreng' => 'Singkong Goreng',
    ];

    public function handle(): int
    {
        $dryRun = $this->option('dry-run');

        if ($dryRun) {
            $this->warn('=== DRY RUN MODE — tidak ada perubahan disimpan ===');
            $this->newLine();
        }

        // 1. Hapus item non-makanan
        $this->info('1. Mencari item non-makanan...');
        $removedCount = 0;
        $removedNames = [];

        foreach ($this->removePatterns as $pattern) {
            $items = DB::table('foods')
                ->where('name', 'REGEXP', $pattern)
                ->get();

            foreach ($items as $item) {
                $removedNames[] = $item->name;
                if (!$dryRun) {
                    DB::table('foods')->where('id', $item->id)->delete();
                }
                $removedCount++;
            }
        }

        $this->comment("  Ditemukan {$removedCount} item tidak relevan:");
        foreach (array_slice($removedNames, 0, 30) as $name) {
            $this->line("    ✕ {$name}");
        }
        if (count($removedNames) > 30) {
            $this->line("    ... dan " . (count($removedNames) - 30) . " lainnya");
        }

        // 2. Standardisasi nama
        $this->info('2. Standardisasi nama makanan...');
        $fixedCount = 0;

        foreach ($this->nameCorrections as $wrong => $correct) {
            $updated = DB::table('foods')
                ->where('name', $wrong)
                ->update(['name' => $correct]);

            if ($updated > 0) {
                $this->line("    ✓ '{$wrong}' → '{$correct}'");
                $fixedCount += $updated;
            }
        }

        $this->comment("  {$fixedCount} nama distandardisasi.");

        // 3. Ringkasan
        $this->newLine();
        $totalFoods = DB::table('foods')->count();
        $this->info("Ringkasan dataset setelah pembersihan:");
        $this->line("  Total item: {$totalFoods}");
        $this->line("  Dihapus: {$removedCount}");
        $this->line("  Nama diperbaiki: {$fixedCount}");

        if ($dryRun) {
            $this->warn('DRY RUN — jalankan `php artisan food:clean` untuk eksekusi.');
        }

        return self::SUCCESS;
    }
}
