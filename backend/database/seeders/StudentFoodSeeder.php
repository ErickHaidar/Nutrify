<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class StudentFoodSeeder extends Seeder
{
    public function run(): void
    {
        $now = now();

        $foods = [
            // ===== NASI & LAUK =====
            ['name' => 'Nasi Putih', 'serving_size' => '1 porsi (150g)', 'calories' => 195, 'protein' => 4.0, 'carbohydrates' => 42.0, 'fat' => 0.5, 'sugar' => 0.0, 'sodium' => 5, 'fiber' => 0.5],
            ['name' => 'Nasi Merah', 'serving_size' => '1 porsi (150g)', 'calories' => 165, 'protein' => 3.5, 'carbohydrates' => 36.0, 'fat' => 1.2, 'sugar' => 0.0, 'sodium' => 8, 'fiber' => 2.5],
            ['name' => 'Nasi Uduk', 'serving_size' => '1 porsi (200g)', 'calories' => 338, 'protein' => 6.2, 'carbohydrates' => 48.5, 'fat' => 13.2, 'sugar' => 1.8, 'sodium' => 380, 'fiber' => 0.8],
            ['name' => 'Nasi Goreng Kampung', 'serving_size' => '1 porsi (250g)', 'calories' => 398, 'protein' => 10.2, 'carbohydrates' => 52.4, 'fat' => 16.8, 'sugar' => 4.1, 'sodium' => 720, 'fiber' => 1.5],
            ['name' => 'Nasi Goreng Telur', 'serving_size' => '1 porsi (250g)', 'calories' => 420, 'protein' => 12.5, 'carbohydrates' => 50.0, 'fat' => 18.5, 'sugar' => 3.8, 'sodium' => 750, 'fiber' => 1.2],
            ['name' => 'Nasi Padang Sederhana', 'serving_size' => '1 porsi (300g)', 'calories' => 520, 'protein' => 18.0, 'carbohydrates' => 58.0, 'fat' => 24.0, 'sugar' => 2.5, 'sodium' => 850, 'fiber' => 2.0],
            ['name' => 'Nasi Pecel', 'serving_size' => '1 porsi (250g)', 'calories' => 345, 'protein' => 12.5, 'carbohydrates' => 42.0, 'fat' => 14.5, 'sugar' => 3.2, 'sodium' => 480, 'fiber' => 5.0],
            ['name' => 'Nasi Kuning', 'serving_size' => '1 porsi (200g)', 'calories' => 310, 'protein' => 7.5, 'carbohydrates' => 45.0, 'fat' => 11.2, 'sugar' => 1.5, 'sodium' => 420, 'fiber' => 1.0],
            ['name' => 'Nasi Liwet', 'serving_size' => '1 porsi (200g)', 'calories' => 325, 'protein' => 8.0, 'carbohydrates' => 44.0, 'fat' => 12.5, 'sugar' => 1.2, 'sodium' => 480, 'fiber' => 1.2],

            // ===== AYAM =====
            ['name' => 'Ayam Goreng Tepung', 'serving_size' => '1 potong (120g)', 'calories' => 320, 'protein' => 22.0, 'carbohydrates' => 14.0, 'fat' => 19.0, 'sugar' => 0.5, 'sodium' => 520, 'fiber' => 0.5],
            ['name' => 'Ayam Bakar Kecap', 'serving_size' => '1 potong (120g)', 'calories' => 265, 'protein' => 24.0, 'carbohydrates' => 8.0, 'fat' => 15.0, 'sugar' => 4.0, 'sodium' => 580, 'fiber' => 0.3],
            ['name' => 'Ayam Geprek', 'serving_size' => '1 porsi (150g)', 'calories' => 365, 'protein' => 28.5, 'carbohydrates' => 12.8, 'fat' => 23.1, 'sugar' => 2.4, 'sodium' => 550, 'fiber' => 0.7],
            ['name' => 'Ayam Penyet', 'serving_size' => '1 porsi (180g)', 'calories' => 385, 'protein' => 26.0, 'carbohydrates' => 18.0, 'fat' => 24.0, 'sugar' => 2.0, 'sodium' => 600, 'fiber' => 1.0],
            ['name' => 'Ayam Goreng Kremes', 'serving_size' => '1 porsi (150g)', 'calories' => 410, 'protein' => 24.0, 'carbohydrates' => 18.0, 'fat' => 26.0, 'sugar' => 1.5, 'sodium' => 550, 'fiber' => 0.5],
            ['name' => 'Ayam Pop', 'serving_size' => '1 porsi (150g)', 'calories' => 265, 'protein' => 28.5, 'carbohydrates' => 2.8, 'fat' => 16.2, 'sugar' => 0.8, 'sodium' => 420, 'fiber' => 0.3],
            ['name' => 'Sayap Ayam Goreng', 'serving_size' => '3 potong (120g)', 'calories' => 340, 'protein' => 20.0, 'carbohydrates' => 10.0, 'fat' => 24.0, 'sugar' => 1.0, 'sodium' => 480, 'fiber' => 0.2],
            ['name' => 'Sate Ayam', 'serving_size' => '10 tusuk (150g)', 'calories' => 310, 'protein' => 32.5, 'carbohydrates' => 8.4, 'fat' => 16.2, 'sugar' => 5.6, 'sodium' => 520, 'fiber' => 0.6],
            ['name' => 'Ayam Rica-Rica', 'serving_size' => '1 porsi (150g)', 'calories' => 295, 'protein' => 26.0, 'carbohydrates' => 5.0, 'fat' => 18.5, 'sugar' => 2.0, 'sodium' => 550, 'fiber' => 0.8],

            // ===== IKAN & SEAFOOD =====
            ['name' => 'Ikan Lele Goreng', 'serving_size' => '1 ekor (100g)', 'calories' => 245, 'protein' => 20.0, 'carbohydrates' => 8.0, 'fat' => 14.5, 'sugar' => 0.5, 'sodium' => 320, 'fiber' => 0.3],
            ['name' => 'Ikan Nila Goreng', 'serving_size' => '1 ekor (120g)', 'calories' => 235, 'protein' => 28.0, 'carbohydrates' => 8.0, 'fat' => 10.5, 'sugar' => 0.3, 'sodium' => 300, 'fiber' => 0.2],
            ['name' => 'Ikan Tongkol Goreng', 'serving_size' => '1 potong (100g)', 'calories' => 210, 'protein' => 25.0, 'carbohydrates' => 2.0, 'fat' => 11.5, 'sugar' => 0.2, 'sodium' => 350, 'fiber' => 0.0],
            ['name' => 'Pecel Lele', 'serving_size' => '1 porsi (250g)', 'calories' => 395, 'protein' => 22.8, 'carbohydrates' => 38.4, 'fat' => 18.5, 'sugar' => 1.2, 'sodium' => 520, 'fiber' => 1.5],
            ['name' => 'Udang Goreng Tepung', 'serving_size' => '6 ekor (100g)', 'calories' => 265, 'protein' => 14.0, 'carbohydrates' => 18.0, 'fat' => 15.0, 'sugar' => 0.5, 'sodium' => 480, 'fiber' => 0.5],
            ['name' => 'Cumi Goreng Tepung', 'serving_size' => '1 porsi (100g)', 'calories' => 275, 'protein' => 12.0, 'carbohydrates' => 20.0, 'fat' => 16.0, 'sugar' => 1.0, 'sodium' => 450, 'fiber' => 0.5],
            ['name' => 'Pepes Ikan', 'serving_size' => '1 porsi (120g)', 'calories' => 185, 'protein' => 22.0, 'carbohydrates' => 5.0, 'fat' => 8.0, 'sugar' => 1.5, 'sodium' => 380, 'fiber' => 1.0],

            // ===== MIE, BAKSO & SOTO =====
            ['name' => 'Mie Ayam', 'serving_size' => '1 mangkuk (350g)', 'calories' => 385, 'protein' => 14.5, 'carbohydrates' => 48.0, 'fat' => 15.0, 'sugar' => 2.5, 'sodium' => 780, 'fiber' => 1.5],
            ['name' => 'Mie Ayam Bakso', 'serving_size' => '1 mangkuk (400g)', 'calories' => 420, 'protein' => 18.0, 'carbohydrates' => 50.0, 'fat' => 16.5, 'sugar' => 2.8, 'sodium' => 850, 'fiber' => 1.8],
            ['name' => 'Bakso Urat', 'serving_size' => '1 mangkuk (300g)', 'calories' => 275, 'protein' => 18.5, 'carbohydrates' => 22.1, 'fat' => 12.8, 'sugar' => 1.8, 'sodium' => 620, 'fiber' => 0.9],
            ['name' => 'Bakso Biasa', 'serving_size' => '1 mangkuk (300g)', 'calories' => 245, 'protein' => 14.0, 'carbohydrates' => 24.0, 'fat' => 10.5, 'sugar' => 1.5, 'sodium' => 580, 'fiber' => 0.8],
            ['name' => 'Soto Ayam', 'serving_size' => '1 mangkuk (350g)', 'calories' => 285, 'protein' => 20.0, 'carbohydrates' => 22.0, 'fat' => 12.5, 'sugar' => 2.0, 'sodium' => 650, 'fiber' => 1.2],
            ['name' => 'Soto Daging', 'serving_size' => '1 mangkuk (350g)', 'calories' => 320, 'protein' => 22.0, 'carbohydrates' => 20.0, 'fat' => 16.0, 'sugar' => 1.8, 'sodium' => 680, 'fiber' => 1.0],
            ['name' => 'Mie Goreng Instan', 'serving_size' => '1 bungkus (80g)', 'calories' => 370, 'protein' => 8.0, 'carbohydrates' => 48.0, 'fat' => 16.0, 'sugar' => 3.0, 'sodium' => 900, 'fiber' => 1.0],
            ['name' => 'Mie Rebus Instan', 'serving_size' => '1 bungkus (80g)', 'calories' => 350, 'protein' => 7.5, 'carbohydrates' => 46.0, 'fat' => 15.0, 'sugar' => 2.5, 'sodium' => 880, 'fiber' => 0.8],
            ['name' => 'Indomie Goreng', 'serving_size' => '1 bungkus (80g)', 'calories' => 380, 'protein' => 8.0, 'carbohydrates' => 49.0, 'fat' => 17.0, 'sugar' => 3.2, 'sodium' => 920, 'fiber' => 1.0],

            // ===== SARAPAN =====
            ['name' => 'Bubur Ayam', 'serving_size' => '1 mangkuk (300g)', 'calories' => 298, 'protein' => 12.5, 'carbohydrates' => 42.8, 'fat' => 8.5, 'sugar' => 2.8, 'sodium' => 480, 'fiber' => 1.2],
            ['name' => 'Lontong Sayur', 'serving_size' => '1 porsi (250g)', 'calories' => 245, 'protein' => 8.4, 'carbohydrates' => 38.2, 'fat' => 8.5, 'sugar' => 4.2, 'sodium' => 350, 'fiber' => 2.5],
            ['name' => 'Ketoprak', 'serving_size' => '1 porsi (250g)', 'calories' => 312, 'protein' => 15.8, 'carbohydrates' => 28.4, 'fat' => 16.2, 'sugar' => 8.5, 'sodium' => 460, 'fiber' => 3.8],
            ['name' => 'Nasi Kuning Komplit', 'serving_size' => '1 porsi (250g)', 'calories' => 398, 'protein' => 12.0, 'carbohydrates' => 45.0, 'fat' => 18.5, 'sugar' => 2.5, 'sodium' => 580, 'fiber' => 1.5],
            ['name' => 'Roti Bakar Coklat Keju', 'serving_size' => '2 lembar (120g)', 'calories' => 345, 'protein' => 10.0, 'carbohydrates' => 42.0, 'fat' => 15.0, 'sugar' => 14.0, 'sodium' => 320, 'fiber' => 1.5],

            // ===== JAJANAN & GORENGAN =====
            ['name' => 'Pisang Goreng', 'serving_size' => '3 buah (120g)', 'calories' => 240, 'protein' => 2.5, 'carbohydrates' => 35.0, 'fat' => 10.5, 'sugar' => 12.0, 'sodium' => 80, 'fiber' => 2.5],
            ['name' => 'Tahu Isi', 'serving_size' => '3 buah (150g)', 'calories' => 245, 'protein' => 10.0, 'carbohydrates' => 22.0, 'fat' => 13.0, 'sugar' => 1.5, 'sodium' => 320, 'fiber' => 1.8],
            ['name' => 'Tempe Goreng', 'serving_size' => '3 potong (100g)', 'calories' => 225, 'protein' => 12.0, 'carbohydrates' => 10.0, 'fat' => 15.0, 'sugar' => 0.5, 'sodium' => 200, 'fiber' => 2.0],
            ['name' => 'Bakwan Sayur', 'serving_size' => '3 buah (120g)', 'calories' => 210, 'protein' => 4.0, 'carbohydrates' => 24.0, 'fat' => 11.0, 'sugar' => 2.0, 'sodium' => 350, 'fiber' => 2.0],
            ['name' => 'Risol Mayo', 'serving_size' => '3 buah (120g)', 'calories' => 265, 'protein' => 6.0, 'carbohydrates' => 28.0, 'fat' => 14.0, 'sugar' => 2.5, 'sodium' => 380, 'fiber' => 1.5],
            ['name' => 'Martabak Telur', 'serving_size' => '1 porsi (150g)', 'calories' => 380, 'protein' => 14.0, 'carbohydrates' => 30.0, 'fat' => 22.0, 'sugar' => 2.5, 'sodium' => 650, 'fiber' => 1.2],
            ['name' => 'Martabak Manis Coklat Kacang', 'serving_size' => '2 potong (120g)', 'calories' => 325, 'protein' => 7.0, 'carbohydrates' => 45.0, 'fat' => 14.0, 'sugar' => 22.0, 'sodium' => 180, 'fiber' => 1.5],
            ['name' => 'Cilok', 'serving_size' => '10 buah (150g)', 'calories' => 210, 'protein' => 5.0, 'carbohydrates' => 28.0, 'fat' => 8.5, 'sugar' => 1.0, 'sodium' => 350, 'fiber' => 0.5],
            ['name' => 'Batagor', 'serving_size' => '1 porsi (120g)', 'calories' => 265, 'protein' => 10.0, 'carbohydrates' => 20.0, 'fat' => 16.0, 'sugar' => 2.0, 'sodium' => 480, 'fiber' => 1.5],
            ['name' => 'Siomay', 'serving_size' => '1 porsi (120g)', 'calories' => 235, 'protein' => 8.5, 'carbohydrates' => 22.0, 'fat' => 12.5, 'sugar' => 3.0, 'sodium' => 520, 'fiber' => 1.2],
            ['name' => 'Pempek', 'serving_size' => '5 buah (150g)', 'calories' => 285, 'protein' => 15.2, 'carbohydrates' => 28.4, 'fat' => 13.8, 'sugar' => 1.5, 'sodium' => 580, 'fiber' => 0.5],
            ['name' => 'Otak-Otak Goreng', 'serving_size' => '3 buah (100g)', 'calories' => 190, 'protein' => 8.0, 'carbohydrates' => 14.0, 'fat' => 11.0, 'sugar' => 1.5, 'sodium' => 450, 'fiber' => 0.5],
            ['name' => 'Onde-Onde', 'serving_size' => '3 buah (100g)', 'calories' => 245, 'protein' => 5.0, 'carbohydrates' => 32.0, 'fat' => 10.0, 'sugar' => 10.0, 'sodium' => 120, 'fiber' => 1.8],

            // ===== MINUMAN =====
            ['name' => 'Es Teh Manis', 'serving_size' => '1 gelas (350ml)', 'calories' => 110, 'protein' => 0.0, 'carbohydrates' => 28.0, 'fat' => 0.0, 'sugar' => 28.0, 'sodium' => 5, 'fiber' => 0.0],
            ['name' => 'Es Jeruk', 'serving_size' => '1 gelas (350ml)', 'calories' => 120, 'protein' => 0.5, 'carbohydrates' => 30.0, 'fat' => 0.0, 'sugar' => 22.0, 'sodium' => 5, 'fiber' => 0.3],
            ['name' => 'Kopi Hitam Tubruk', 'serving_size' => '1 cangkir (200ml)', 'calories' => 5, 'protein' => 0.3, 'carbohydrates' => 0.1, 'fat' => 0.0, 'sugar' => 0.0, 'sodium' => 2, 'fiber' => 0.0],
            ['name' => 'Kopi Susu', 'serving_size' => '1 gelas (250ml)', 'calories' => 145, 'protein' => 3.5, 'carbohydrates' => 14.0, 'fat' => 8.0, 'sugar' => 12.0, 'sodium' => 60, 'fiber' => 0.0],
            ['name' => 'Es Cendol', 'serving_size' => '1 gelas (300ml)', 'calories' => 185, 'protein' => 2.0, 'carbohydrates' => 38.0, 'fat' => 3.5, 'sugar' => 28.0, 'sodium' => 50, 'fiber' => 0.5],
            ['name' => 'Es Campur', 'serving_size' => '1 mangkuk (350g)', 'calories' => 245, 'protein' => 3.0, 'carbohydrates' => 52.0, 'fat' => 4.0, 'sugar' => 38.0, 'sodium' => 40, 'fiber' => 2.0],
            ['name' => 'Jus Alpukat', 'serving_size' => '1 gelas (300ml)', 'calories' => 265, 'protein' => 3.5, 'carbohydrates' => 28.0, 'fat' => 16.0, 'sugar' => 22.0, 'sodium' => 20, 'fiber' => 4.0],
            ['name' => 'Jus Mangga', 'serving_size' => '1 gelas (300ml)', 'calories' => 180, 'protein' => 1.5, 'carbohydrates' => 42.0, 'fat' => 0.8, 'sugar' => 38.0, 'sodium' => 12, 'fiber' => 2.0],
            ['name' => 'Jus Melon', 'serving_size' => '1 gelas (300ml)', 'calories' => 120, 'protein' => 1.0, 'carbohydrates' => 28.0, 'fat' => 0.3, 'sugar' => 24.0, 'sodium' => 15, 'fiber' => 1.5],
            ['name' => 'Susu Kedelai', 'serving_size' => '1 gelas (250ml)', 'calories' => 130, 'protein' => 8.0, 'carbohydrates' => 12.0, 'fat' => 5.0, 'sugar' => 8.0, 'sodium' => 40, 'fiber' => 1.0],

            // ===== CAMILAN & SNACK =====
            ['name' => 'Keripik Singkong', 'serving_size' => '1 bungkus kecil (50g)', 'calories' => 210, 'protein' => 0.5, 'carbohydrates' => 28.0, 'fat' => 10.0, 'sugar' => 1.0, 'sodium' => 180, 'fiber' => 1.5],
            ['name' => 'Keripik Tempe', 'serving_size' => '1 bungkus (50g)', 'calories' => 195, 'protein' => 8.0, 'carbohydrates' => 10.0, 'fat' => 13.0, 'sugar' => 0.5, 'sodium' => 250, 'fiber' => 2.0],
            ['name' => 'Kacang Goreng', 'serving_size' => '1 genggam (30g)', 'calories' => 170, 'protein' => 7.0, 'carbohydrates' => 5.0, 'fat' => 14.0, 'sugar' => 1.0, 'sodium' => 120, 'fiber' => 2.5],
            ['name' => 'Biskuit Regal', 'serving_size' => '5 keping (30g)', 'calories' => 140, 'protein' => 2.0, 'carbohydrates' => 20.0, 'fat' => 5.0, 'sugar' => 5.0, 'sodium' => 90, 'fiber' => 0.5],
            ['name' => 'Roti Tawar', 'serving_size' => '2 lembar (60g)', 'calories' => 160, 'protein' => 5.0, 'carbohydrates' => 30.0, 'fat' => 2.0, 'sugar' => 2.5, 'sodium' => 220, 'fiber' => 1.5],
            ['name' => 'Roti Coklat', 'serving_size' => '1 buah (50g)', 'calories' => 185, 'protein' => 4.5, 'carbohydrates' => 28.0, 'fat' => 6.0, 'sugar' => 10.0, 'sodium' => 180, 'fiber' => 1.2],
            ['name' => 'Donat Gula', 'serving_size' => '1 buah (50g)', 'calories' => 195, 'protein' => 3.5, 'carbohydrates' => 28.0, 'fat' => 8.0, 'sugar' => 12.0, 'sodium' => 150, 'fiber' => 0.8],
            ['name' => 'Kue Cubit', 'serving_size' => '10 buah (80g)', 'calories' => 210, 'protein' => 5.0, 'carbohydrates' => 30.0, 'fat' => 8.0, 'sugar' => 14.0, 'sodium' => 120, 'fiber' => 0.5],
            ['name' => 'Kue Lumpur', 'serving_size' => '2 buah (80g)', 'calories' => 185, 'protein' => 4.0, 'carbohydrates' => 25.0, 'fat' => 8.0, 'sugar' => 14.0, 'sodium' => 150, 'fiber' => 0.5],
            ['name' => 'Lemper Ayam', 'serving_size' => '2 buah (100g)', 'calories' => 220, 'protein' => 8.0, 'carbohydrates' => 28.0, 'fat' => 9.0, 'sugar' => 1.5, 'sodium' => 280, 'fiber' => 1.5],
            ['name' => 'Arem-Arem', 'serving_size' => '2 buah (120g)', 'calories' => 235, 'protein' => 6.5, 'carbohydrates' => 32.0, 'fat' => 9.0, 'sugar' => 1.8, 'sodium' => 320, 'fiber' => 2.0],
            ['name' => 'Pastel', 'serving_size' => '2 buah (100g)', 'calories' => 245, 'protein' => 7.0, 'carbohydrates' => 24.0, 'fat' => 13.5, 'sugar' => 2.0, 'sodium' => 350, 'fiber' => 1.5],

            // ===== SAYUR & LAUK NABATI =====
            ['name' => 'Tahu Goreng', 'serving_size' => '3 potong (120g)', 'calories' => 210, 'protein' => 12.0, 'carbohydrates' => 8.0, 'fat' => 14.0, 'sugar' => 0.5, 'sodium' => 250, 'fiber' => 1.5],
            ['name' => 'Tempe Bacem', 'serving_size' => '3 potong (100g)', 'calories' => 185, 'protein' => 10.0, 'carbohydrates' => 12.0, 'fat' => 10.5, 'sugar' => 6.0, 'sodium' => 320, 'fiber' => 2.5],
            ['name' => 'Tempe Orek', 'serving_size' => '1 porsi (100g)', 'calories' => 245, 'protein' => 11.0, 'carbohydrates' => 14.0, 'fat' => 16.0, 'sugar' => 5.0, 'sodium' => 380, 'fiber' => 2.0],
            ['name' => 'Sayur Asem', 'serving_size' => '1 mangkuk (250g)', 'calories' => 95, 'protein' => 3.0, 'carbohydrates' => 18.0, 'fat' => 2.0, 'sugar' => 3.0, 'sodium' => 350, 'fiber' => 4.0],
            ['name' => 'Sayur Lodeh', 'serving_size' => '1 mangkuk (250g)', 'calories' => 155, 'protein' => 6.0, 'carbohydrates' => 14.0, 'fat' => 8.5, 'sugar' => 3.5, 'sodium' => 420, 'fiber' => 3.5],
            ['name' => 'Cah Kangkung', 'serving_size' => '1 porsi (150g)', 'calories' => 95, 'protein' => 3.5, 'carbohydrates' => 8.0, 'fat' => 5.5, 'sugar' => 1.5, 'sodium' => 280, 'fiber' => 2.5],
            ['name' => 'Tumis Tauge', 'serving_size' => '1 porsi (120g)', 'calories' => 85, 'protein' => 4.0, 'carbohydrates' => 8.0, 'fat' => 4.0, 'sugar' => 2.0, 'sodium' => 250, 'fiber' => 2.0],
            ['name' => 'Gado-Gado', 'serving_size' => '1 porsi (250g)', 'calories' => 298, 'protein' => 14.2, 'carbohydrates' => 24.5, 'fat' => 17.8, 'sugar' => 6.2, 'sodium' => 480, 'fiber' => 4.5],
            ['name' => 'Urap Sayur', 'serving_size' => '1 porsi (150g)', 'calories' => 165, 'protein' => 6.5, 'carbohydrates' => 14.0, 'fat' => 10.0, 'sugar' => 3.0, 'sodium' => 320, 'fiber' => 4.0],

            // ===== MAKANAN CEPAT SAJI =====
            ['name' => 'Nasi Ayam KFC', 'serving_size' => '1 paket (250g)', 'calories' => 525, 'protein' => 28.0, 'carbohydrates' => 48.0, 'fat' => 24.0, 'sugar' => 2.0, 'sodium' => 850, 'fiber' => 1.5],
            ['name' => 'Burger Ayam', 'serving_size' => '1 buah (180g)', 'calories' => 410, 'protein' => 22.0, 'carbohydrates' => 38.0, 'fat' => 18.5, 'sugar' => 5.0, 'sodium' => 750, 'fiber' => 2.0],
            ['name' => 'French Fries Besar', 'serving_size' => '1 porsi (150g)', 'calories' => 365, 'protein' => 4.0, 'carbohydrates' => 48.0, 'fat' => 17.0, 'sugar' => 0.5, 'sodium' => 280, 'fiber' => 4.0],
            ['name' => 'Nasi Ayam McD', 'serving_size' => '1 paket (250g)', 'calories' => 510, 'protein' => 26.0, 'carbohydrates' => 50.0, 'fat' => 22.0, 'sugar' => 2.5, 'sodium' => 820, 'fiber' => 1.5],
            ['name' => 'Pizza Slice', 'serving_size' => '1 slice (120g)', 'calories' => 285, 'protein' => 12.0, 'carbohydrates' => 32.0, 'fat' => 12.0, 'sugar' => 3.5, 'sodium' => 580, 'fiber' => 1.5],

            // ===== MAKANAN KHAS DAERAH POPULER =====
            ['name' => 'Rendang Daging', 'serving_size' => '1 porsi (120g)', 'calories' => 325, 'protein' => 24.0, 'carbohydrates' => 5.5, 'fat' => 24.0, 'sugar' => 2.5, 'sodium' => 520, 'fiber' => 0.5],
            ['name' => 'Gudeg Jogja', 'serving_size' => '1 porsi (200g)', 'calories' => 320, 'protein' => 12.4, 'carbohydrates' => 42.8, 'fat' => 13.2, 'sugar' => 18.5, 'sodium' => 420, 'fiber' => 3.2],
            ['name' => 'Rawon', 'serving_size' => '1 mangkuk (300g)', 'calories' => 285, 'protein' => 24.8, 'carbohydrates' => 10.2, 'fat' => 17.5, 'sugar' => 2.1, 'sodium' => 490, 'fiber' => 1.3],
            ['name' => 'Soto Betawi', 'serving_size' => '1 mangkuk (350g)', 'calories' => 385, 'protein' => 22.1, 'carbohydrates' => 14.6, 'fat' => 28.3, 'sugar' => 3.2, 'sodium' => 680, 'fiber' => 1.1],

            // ===== BUAH-BUAHAN =====
            ['name' => 'Pisang Ambon', 'serving_size' => '1 buah (100g)', 'calories' => 105, 'protein' => 1.2, 'carbohydrates' => 24.0, 'fat' => 0.3, 'sugar' => 14.0, 'sodium' => 1, 'fiber' => 2.5],
            ['name' => 'Pepaya', 'serving_size' => '1 potong (150g)', 'calories' => 65, 'protein' => 0.7, 'carbohydrates' => 15.0, 'fat' => 0.2, 'sugar' => 10.0, 'sodium' => 5, 'fiber' => 2.5],
            ['name' => 'Semangka', 'serving_size' => '1 potong (200g)', 'calories' => 60, 'protein' => 1.2, 'carbohydrates' => 14.0, 'fat' => 0.3, 'sugar' => 12.0, 'sodium' => 2, 'fiber' => 0.8],
            ['name' => 'Salak', 'serving_size' => '3 buah (100g)', 'calories' => 82, 'protein' => 0.5, 'carbohydrates' => 21.0, 'fat' => 0.2, 'sugar' => 15.0, 'sodium' => 2, 'fiber' => 2.5],
            ['name' => 'Mangga Harum Manis', 'serving_size' => '1 buah (200g)', 'calories' => 130, 'protein' => 1.0, 'carbohydrates' => 32.0, 'fat' => 0.5, 'sugar' => 28.0, 'sodium' => 3, 'fiber' => 3.0],
            ['name' => 'Apel', 'serving_size' => '1 buah (150g)', 'calories' => 80, 'protein' => 0.5, 'carbohydrates' => 20.0, 'fat' => 0.3, 'sugar' => 16.0, 'sodium' => 1, 'fiber' => 3.5],
            ['name' => 'Jeruk Medan', 'serving_size' => '2 buah (150g)', 'calories' => 70, 'protein' => 1.5, 'carbohydrates' => 16.0, 'fat' => 0.2, 'sugar' => 12.0, 'sodium' => 2, 'fiber' => 3.0],
            ['name' => 'Buah Naga', 'serving_size' => '1/2 buah (150g)', 'calories' => 75, 'protein' => 1.5, 'carbohydrates' => 15.0, 'fat' => 0.5, 'sugar' => 10.0, 'sodium' => 8, 'fiber' => 2.5],
            ['name' => 'Melon', 'serving_size' => '1 potong (200g)', 'calories' => 68, 'protein' => 1.2, 'carbohydrates' => 16.0, 'fat' => 0.3, 'sugar' => 14.0, 'sodium' => 18, 'fiber' => 1.5],

            // ===== MAKANAN RINGAN KAMPUS =====
            ['name' => 'Sosis Goreng', 'serving_size' => '2 buah (60g)', 'calories' => 180, 'protein' => 7.0, 'carbohydrates' => 5.0, 'fat' => 14.0, 'sugar' => 1.5, 'sodium' => 480, 'fiber' => 0.0],
            ['name' => 'Nugget Ayam', 'serving_size' => '5 buah (80g)', 'calories' => 195, 'protein' => 9.0, 'carbohydrates' => 12.0, 'fat' => 12.0, 'sugar' => 2.0, 'sodium' => 420, 'fiber' => 0.5],
            ['name' => 'Sosis Bakar', 'serving_size' => '2 buah (60g)', 'calories' => 165, 'protein' => 6.5, 'carbohydrates' => 4.0, 'fat' => 13.0, 'sugar' => 1.0, 'sodium' => 450, 'fiber' => 0.0],
            ['name' => 'Jagung Rebus', 'serving_size' => '1 bonggol (150g)', 'calories' => 145, 'protein' => 4.5, 'carbohydrates' => 30.0, 'fat' => 1.5, 'sugar' => 5.0, 'sodium' => 15, 'fiber' => 4.0],
            ['name' => 'Ubi Goreng', 'serving_size' => '1 potong (100g)', 'calories' => 175, 'protein' => 1.5, 'carbohydrates' => 32.0, 'fat' => 5.0, 'sugar' => 8.0, 'sodium' => 20, 'fiber' => 3.0],
            ['name' => 'Singkong Rebus', 'serving_size' => '1 potong (100g)', 'calories' => 155, 'protein' => 1.0, 'carbohydrates' => 38.0, 'fat' => 0.3, 'sugar' => 2.5, 'sodium' => 10, 'fiber' => 2.5],
            ['name' => 'Telur Dadar', 'serving_size' => '2 butir (120g)', 'calories' => 195, 'protein' => 14.0, 'carbohydrates' => 1.0, 'fat' => 15.0, 'sugar' => 0.5, 'sodium' => 200, 'fiber' => 0.0],
            ['name' => 'Telur Rebus', 'serving_size' => '2 butir (100g)', 'calories' => 155, 'protein' => 12.5, 'carbohydrates' => 1.0, 'fat' => 10.5, 'sugar' => 0.5, 'sodium' => 140, 'fiber' => 0.0],
            ['name' => 'Omelet Sayur', 'serving_size' => '1 porsi (120g)', 'calories' => 175, 'protein' => 11.0, 'carbohydrates' => 5.0, 'fat' => 12.5, 'sugar' => 2.0, 'sodium' => 250, 'fiber' => 1.0],

            // ===== MAKANAN DIET/SEHAT =====
            ['name' => 'Salad Sayur', 'serving_size' => '1 porsi (200g)', 'calories' => 125, 'protein' => 4.5, 'carbohydrates' => 12.0, 'fat' => 7.0, 'sugar' => 3.0, 'sodium' => 180, 'fiber' => 4.5],
            ['name' => 'Salad Buah', 'serving_size' => '1 porsi (250g)', 'calories' => 155, 'protein' => 2.5, 'carbohydrates' => 30.0, 'fat' => 3.5, 'sugar' => 22.0, 'sodium' => 20, 'fiber' => 3.5],
            ['name' => 'Oatmeal', 'serving_size' => '1 mangkuk (200g)', 'calories' => 185, 'protein' => 6.0, 'carbohydrates' => 32.0, 'fat' => 4.0, 'sugar' => 2.0, 'sodium' => 10, 'fiber' => 5.0],
            ['name' => 'Granola', 'serving_size' => '1/2 cangkir (50g)', 'calories' => 225, 'protein' => 5.0, 'carbohydrates' => 32.0, 'fat' => 9.0, 'sugar' => 10.0, 'sodium' => 45, 'fiber' => 4.0],
            ['name' => 'Smoothie Bowl', 'serving_size' => '1 mangkuk (300g)', 'calories' => 275, 'protein' => 8.0, 'carbohydrates' => 45.0, 'fat' => 8.0, 'sugar' => 28.0, 'sodium' => 50, 'fiber' => 5.0],
            ['name' => 'Greek Yogurt', 'serving_size' => '1 cup (150g)', 'calories' => 130, 'protein' => 15.0, 'carbohydrates' => 8.0, 'fat' => 4.0, 'sugar' => 5.0, 'sodium' => 60, 'fiber' => 0.0],

            // ===== MAKANAN PEDAS / SAMBAL =====
            ['name' => 'Ayam Sambal Matah', 'serving_size' => '1 porsi (150g)', 'calories' => 310, 'protein' => 26.0, 'carbohydrates' => 4.0, 'fat' => 21.0, 'sugar' => 1.5, 'sodium' => 480, 'fiber' => 0.8],
            ['name' => 'Sambal Goreng Kentang', 'serving_size' => '1 porsi (100g)', 'calories' => 195, 'protein' => 3.0, 'carbohydrates' => 22.0, 'fat' => 10.5, 'sugar' => 3.0, 'sodium' => 320, 'fiber' => 2.0],
            ['name' => 'Telur Balado', 'serving_size' => '2 butir (150g)', 'calories' => 215, 'protein' => 13.0, 'carbohydrates' => 8.0, 'fat' => 14.5, 'sugar' => 3.0, 'sodium' => 380, 'fiber' => 0.5],
            ['name' => 'Dendeng Balado', 'serving_size' => '1 porsi (100g)', 'calories' => 285, 'protein' => 32.8, 'carbohydrates' => 4.2, 'fat' => 16.5, 'sugar' => 2.1, 'sodium' => 620, 'fiber' => 0.4],

            // ===== TAMBAHAN =====
            ['name' => 'Bubur Kacang Hijau', 'serving_size' => '1 mangkuk (250g)', 'calories' => 235, 'protein' => 8.5, 'carbohydrates' => 42.0, 'fat' => 4.0, 'sugar' => 18.0, 'sodium' => 30, 'fiber' => 3.5],
            ['name' => 'Kolak Pisang', 'serving_size' => '1 mangkuk (250g)', 'calories' => 265, 'protein' => 2.5, 'carbohydrates' => 52.0, 'fat' => 6.0, 'sugar' => 32.0, 'sodium' => 25, 'fiber' => 2.0],
            ['name' => 'Bubur Sumsum', 'serving_size' => '1 mangkuk (200g)', 'calories' => 245, 'protein' => 3.0, 'carbohydrates' => 38.0, 'fat' => 8.5, 'sugar' => 18.0, 'sodium' => 35, 'fiber' => 0.5],
            ['name' => 'Kue Lapis', 'serving_size' => '3 potong (80g)', 'calories' => 165, 'protein' => 2.5, 'carbohydrates' => 28.0, 'fat' => 5.0, 'sugar' => 16.0, 'sodium' => 80, 'fiber' => 1.0],
            ['name' => 'Lupis Ketan', 'serving_size' => '3 buah (100g)', 'calories' => 195, 'protein' => 2.5, 'carbohydrates' => 35.0, 'fat' => 5.5, 'sugar' => 12.0, 'sodium' => 40, 'fiber' => 1.0],
            ['name' => 'Nagasari', 'serving_size' => '2 buah (100g)', 'calories' => 185, 'protein' => 3.0, 'carbohydrates' => 32.0, 'fat' => 5.0, 'sugar' => 10.0, 'sodium' => 30, 'fiber' => 1.5],
            ['name' => 'Lontong Opor Ayam', 'serving_size' => '1 porsi (300g)', 'calories' => 385, 'protein' => 18.0, 'carbohydrates' => 35.0, 'fat' => 20.0, 'sugar' => 3.5, 'sodium' => 580, 'fiber' => 2.0],
        ];

        $count = 0;
        $batch = [];

        foreach ($foods as $food) {
            // Skip if already exists (case-insensitive check)
            $exists = DB::table('foods')
                ->whereRaw('LOWER(name) = ?', [strtolower($food['name'])])
                ->exists();

            if ($exists) {
                continue;
            }

            $batch[] = array_merge($food, [
                'created_at' => $now,
                'updated_at' => $now,
            ]);

            if (count($batch) >= 50) {
                DB::table('foods')->insert($batch);
                $count += count($batch);
                $batch = [];
            }
        }

        if (count($batch) > 0) {
            DB::table('foods')->insert($batch);
            $count += count($batch);
        }

        echo "Seeded {$count} new student foods.\n";
    }
}
