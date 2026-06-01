"""Generate comprehensive Indonesian food data programmatically.

Standard nutrition values from Indonesian food composition tables (TKPI).
Fills gaps that APIs and CSVs miss — base foods, local dishes, student foods.
"""
import pandas as pd


# Standard nutrition per 100g for common base ingredients
# Source: Tabel Komposisi Pangan Indonesia (TKPI)
BASE_INGREDIENTS = {
    # Grains (per 100g raw)
    "Nasi Putih": (180, 3.0, 39.0, 0.3, 0.1, 2, 0.5),
    "Nasi Merah": (178, 3.5, 37.0, 0.9, 0.2, 3, 1.2),
    "Nasi Ketan": (190, 3.8, 40.0, 0.4, 0.1, 5, 0.8),
    "Nasi Jagung": (160, 3.0, 33.0, 1.0, 0.5, 3, 1.5),
    "Bubur Nasi": (70, 1.2, 15.0, 0.2, 0.0, 2, 0.2),
    "Beras Ketan Putih": (360, 7.0, 79.0, 0.7, 0.2, 5, 1.0),
    "Beras Ketan Hitam": (356, 8.0, 74.0, 1.5, 0.3, 7, 2.0),
    "Jagung Kuning Rebus": (140, 4.5, 30.0, 1.5, 3.0, 1, 3.0),
    "Jagung Manis Rebus": (120, 3.5, 25.0, 1.2, 4.0, 1, 2.5),

    # Root vegetables (per 100g)
    "Kentang Rebus": (87, 2.0, 19.0, 0.1, 0.8, 6, 2.0),
    "Kentang Kukus": (90, 2.0, 20.0, 0.1, 0.8, 6, 2.0),
    "Kentang Goreng": (312, 3.4, 41.0, 15.0, 0.3, 210, 3.8),
    "Ubi Jalar Rebus": (100, 1.8, 23.0, 0.2, 5.5, 10, 2.5),
    "Ubi Jalar Goreng": (220, 2.0, 38.0, 8.0, 7.0, 50, 3.0),
    "Ubi Jalar Kukus": (115, 1.5, 27.0, 0.2, 6.0, 12, 2.8),
    "Ubi Kayu Rebus": (155, 1.2, 36.0, 0.3, 1.5, 14, 1.8),
    "Ubi Kayu Goreng": (280, 1.5, 50.0, 9.0, 2.0, 30, 2.0),
    "Singkong Rebus": (155, 1.2, 36.0, 0.3, 1.5, 14, 1.8),
    "Singkong Goreng": (280, 1.5, 50.0, 9.0, 2.0, 30, 2.0),
    "Talas Rebus": (120, 1.5, 27.0, 0.2, 0.5, 10, 3.0),
    "Sukun Rebus": (110, 1.0, 27.0, 0.3, 11.0, 2, 4.9),
    "Sukun Goreng": (230, 1.5, 42.0, 7.0, 12.0, 30, 5.0),

    # Protein — Tahu & Tempe (per 100g)
    "Tahu Putih Goreng": (271, 13.0, 8.0, 22.0, 0.5, 15, 1.0),
    "Tahu Putih Rebus": (80, 8.0, 2.0, 4.8, 0.3, 10, 0.5),
    "Tahu Kuning Goreng": (290, 14.0, 7.0, 23.0, 0.5, 18, 1.2),
    "Tahu Sutra": (55, 5.0, 2.0, 2.7, 0.3, 5, 0.2),
    "Tahu Kulit Goreng": (300, 12.0, 10.0, 24.0, 0.5, 20, 1.5),
    "Tempe Goreng": (335, 20.0, 11.0, 24.0, 0.5, 12, 2.5),
    "Tempe Rebus": (180, 18.0, 10.0, 8.0, 0.3, 8, 2.0),
    "Tempe Bacem": (220, 16.0, 25.0, 9.0, 10.0, 300, 2.5),
    "Tempe Mendoan": (310, 15.0, 20.0, 21.0, 1.0, 150, 2.0),
    "Oncom Goreng": (250, 10.0, 15.0, 18.0, 0.5, 50, 2.0),

    # Protein — Telur (per item/100g)
    "Telur Ayam Rebus": (155, 12.6, 1.1, 10.6, 1.1, 124, 0.0),
    "Telur Ayam Ceplok": (200, 13.0, 1.0, 15.0, 0.5, 200, 0.0),
    "Telur Ayam Dadar": (220, 14.0, 2.0, 17.0, 1.0, 250, 0.0),
    "Telur Ayam Orak-Arik": (210, 13.5, 2.0, 16.0, 1.0, 230, 0.0),
    "Telur Bebek Rebus": (185, 12.8, 0.7, 13.8, 0.5, 140, 0.0),
    "Telur Puyuh Rebus": (160, 13.0, 0.4, 11.2, 0.3, 130, 0.0),
    "Telur Asin": (190, 12.0, 1.0, 14.0, 0.3, 800, 0.0),

    # Protein — Ayam (per 100g cooked)
    "Dada Ayam Rebus": (165, 31.0, 0.0, 3.6, 0.0, 65, 0.0),
    "Dada Ayam Bakar": (180, 32.0, 0.0, 5.0, 0.0, 70, 0.0),
    "Dada Ayam Goreng": (240, 28.0, 5.0, 12.0, 0.0, 200, 0.0),
    "Paha Ayam Rebus": (175, 26.0, 0.0, 7.5, 0.0, 80, 0.0),
    "Paha Ayam Bakar": (195, 27.0, 0.5, 9.0, 0.0, 90, 0.0),
    "Paha Ayam Goreng": (255, 24.0, 6.0, 15.0, 0.0, 220, 0.0),
    "Sayap Ayam Goreng": (260, 22.0, 7.0, 16.0, 0.0, 250, 0.0),
    "Ayam Utuh Rebus": (170, 28.0, 0.0, 6.0, 0.0, 70, 0.0),
    "Ayam Utuh Bakar": (190, 29.0, 0.0, 8.0, 0.0, 80, 0.0),
    "Ayam Utuh Goreng": (250, 26.0, 5.0, 14.0, 0.0, 210, 0.0),
    "Hati Ayam Rebus": (170, 25.0, 1.0, 6.5, 0.0, 50, 0.0),
    "Ampela Ayam Rebus": (150, 28.0, 0.5, 3.5, 0.0, 55, 0.0),

    # Protein — Daging Sapi (per 100g cooked)
    "Daging Sapi Rebus": (200, 28.0, 0.0, 9.0, 0.0, 55, 0.0),
    "Daging Sapi Goreng": (260, 25.0, 2.0, 16.0, 0.0, 150, 0.0),
    "Daging Sapi Panggang": (220, 27.0, 0.0, 11.0, 0.0, 60, 0.0),
    "Daging Sapi Cincang Rebus": (220, 25.0, 0.0, 12.0, 0.0, 60, 0.0),

    # Protein — Daging Kambing (per 100g cooked)
    "Daging Kambing Rebus": (175, 26.0, 0.0, 7.5, 0.0, 80, 0.0),
    "Daging Kambing Bakar": (195, 27.0, 0.0, 9.0, 0.0, 90, 0.0),
    "Daging Kambing Goreng": (250, 24.0, 2.0, 15.0, 0.0, 180, 0.0),

    # Protein — Ikan (per 100g cooked)
    "Ikan Mas Rebus": (140, 20.0, 0.0, 6.0, 0.0, 50, 0.0),
    "Ikan Mas Goreng": (220, 18.0, 3.0, 15.0, 0.0, 150, 0.0),
    "Ikan Nila Rebus": (130, 20.0, 0.0, 5.0, 0.0, 45, 0.0),
    "Ikan Nila Goreng": (210, 18.0, 3.0, 14.0, 0.0, 140, 0.0),
    "Ikan Lele Rebus": (150, 18.0, 0.0, 8.0, 0.0, 50, 0.0),
    "Ikan Lele Goreng": (230, 16.0, 4.0, 16.0, 0.0, 160, 0.0),
    "Ikan Gurame Rebus": (135, 19.0, 0.0, 6.3, 0.0, 48, 0.0),
    "Ikan Gurame Goreng": (215, 17.0, 3.0, 15.0, 0.0, 145, 0.0),
    "Ikan Kembung Rebus": (165, 22.0, 0.0, 8.0, 0.0, 60, 0.0),
    "Ikan Kembung Goreng": (240, 20.0, 3.0, 16.0, 0.0, 170, 0.0),
    "Ikan Tongkol Rebus": (170, 25.0, 0.0, 7.0, 0.0, 55, 0.0),
    "Ikan Tongkol Goreng": (245, 22.0, 3.0, 15.0, 0.0, 165, 0.0),
    "Ikan Kembung Bakar": (180, 23.0, 0.0, 9.0, 0.0, 65, 0.0),
    "Ikan Bandeng Rebus": (155, 20.0, 0.0, 7.5, 0.0, 55, 0.0),
    "Ikan Bandeng Goreng": (235, 18.0, 3.0, 16.0, 0.0, 155, 0.0),
    "Ikan Kakap Rebus": (130, 21.0, 0.0, 4.5, 0.0, 40, 0.0),
    "Ikan Kakap Goreng": (210, 19.0, 3.0, 13.0, 0.0, 140, 0.0),
    "Ikan Patin Rebus": (160, 18.0, 0.0, 9.0, 0.0, 55, 0.0),
    "Ikan Patin Goreng": (240, 16.0, 3.0, 17.0, 0.0, 160, 0.0),

    # Seafood
    "Udang Rebus": (100, 20.0, 0.5, 1.5, 0.0, 150, 0.0),
    "Udang Goreng": (220, 18.0, 8.0, 14.0, 0.0, 300, 0.0),
    "Cumi Rebus": (90, 16.0, 2.0, 1.5, 0.0, 250, 0.0),
    "Cumi Goreng": (210, 15.0, 8.0, 14.0, 0.0, 400, 0.0),

    # Sayuran (per 100g)
    "Bayam Rebus": (30, 2.5, 4.0, 0.5, 0.0, 70, 1.5),
    "Kangkung Rebus": (28, 2.0, 4.0, 0.4, 0.0, 60, 1.3),
    "Sawi Hijau Rebus": (25, 2.0, 3.0, 0.3, 0.0, 50, 1.2),
    "Sawi Putih Rebus": (20, 1.5, 3.0, 0.2, 0.0, 40, 1.0),
    "Brokoli Rebus": (35, 3.0, 5.0, 0.4, 0.0, 30, 2.5),
    "Brokoli Kukus": (38, 3.2, 5.5, 0.5, 0.0, 32, 2.8),
    "Wortel Rebus": (35, 0.8, 7.0, 0.3, 4.5, 60, 2.5),
    "Buncis Rebus": (30, 1.8, 5.5, 0.2, 1.5, 5, 2.0),
    "Kacang Panjang Rebus": (35, 2.5, 6.0, 0.3, 0.0, 5, 2.0),
    "Labu Siam Rebus": (20, 0.6, 4.0, 0.1, 1.8, 3, 1.5),
    "Terong Ungu Rebus": (25, 1.0, 5.0, 0.2, 0.0, 3, 2.0),
    "Pare Rebus": (20, 1.0, 3.5, 0.2, 0.0, 3, 1.8),
    "Kubis Rebus": (22, 1.5, 4.0, 0.2, 0.0, 15, 1.8),
    "Kembang Kol Rebus": (25, 2.0, 4.0, 0.2, 0.0, 20, 2.0),
    "Daun Singkong Rebus": (40, 3.5, 6.5, 0.5, 0.0, 10, 2.5),
    "Daun Pepaya Rebus": (35, 3.0, 5.5, 0.5, 0.0, 8, 2.0),
    "Daun Katuk Rebus": (50, 5.0, 7.0, 0.8, 0.0, 12, 2.5),
    "Daun Kelor Rebus": (45, 5.5, 5.0, 1.0, 0.0, 15, 2.0),
    "Tauge Rebus": (30, 2.5, 4.5, 0.5, 0.0, 8, 1.5),
    "Jagung Muda Rebus": (35, 2.0, 7.0, 0.5, 0.0, 5, 2.0),
    "Oyong Rebus": (18, 0.5, 3.5, 0.1, 0.0, 2, 1.8),

    # Buah-buahan (per 100g fresh)
    "Pisang Ambon": (99, 1.2, 24.0, 0.3, 16.0, 1, 2.0),
    "Pisang Raja": (120, 1.2, 30.0, 0.3, 18.0, 1, 2.5),
    "Pisang Kepok": (105, 1.0, 26.0, 0.3, 17.0, 1, 2.2),
    "Pisang Mas": (110, 1.3, 27.0, 0.3, 18.0, 1, 2.3),
    "Pisang Susu": (95, 1.0, 23.0, 0.2, 15.0, 1, 1.8),
    "Pepaya": (46, 0.5, 11.0, 0.1, 8.0, 3, 1.5),
    "Mangga Harum Manis": (65, 0.5, 16.0, 0.3, 14.0, 2, 1.5),
    "Mangga Muda": (55, 0.8, 13.0, 0.2, 1.0, 3, 1.8),
    "Jeruk Manis": (45, 0.9, 10.0, 0.2, 8.5, 1, 2.0),
    "Jeruk Nipis": (35, 0.5, 8.0, 0.2, 1.5, 2, 2.5),
    "Apel Merah": (58, 0.3, 14.0, 0.3, 10.0, 1, 2.3),
    "Apel Hijau": (55, 0.3, 13.0, 0.2, 10.0, 1, 2.2),
    "Semangka": (28, 0.5, 6.5, 0.2, 6.0, 1, 0.4),
    "Melon": (35, 0.5, 8.0, 0.2, 7.5, 10, 0.8),
    "Nanas": (52, 0.5, 13.0, 0.1, 10.0, 1, 1.2),
    "Alpukat": (160, 2.0, 9.0, 15.0, 0.5, 7, 6.5),
    "Jambu Biji": (50, 0.9, 11.5, 0.3, 9.0, 3, 5.0),
    "Jambu Air": (35, 0.5, 8.0, 0.2, 7.0, 8, 1.5),
    "Belimbing": (35, 0.5, 8.0, 0.2, 4.0, 2, 2.5),
    "Salak": (75, 0.4, 19.0, 0.1, 15.0, 1, 2.0),
    "Sawo": (90, 0.5, 22.0, 0.5, 18.0, 12, 2.5),
    "Durian": (147, 1.5, 27.0, 5.3, 12.0, 2, 3.8),
    "Manggis": (65, 0.5, 15.5, 0.5, 13.0, 7, 1.5),
    "Rambutan": (70, 0.9, 16.0, 0.2, 13.0, 10, 1.0),
    "Duku": (60, 1.0, 13.5, 0.2, 10.0, 3, 1.5),
    "Nangka": (95, 1.2, 23.0, 0.3, 19.0, 3, 1.5),
    "Sirsak": (65, 1.0, 14.5, 0.3, 10.0, 14, 2.0),
    "Markisa": (75, 2.2, 13.5, 0.7, 11.0, 28, 8.0),
    "Anggur": (70, 0.5, 17.0, 0.2, 16.0, 2, 1.0),
    "Stroberi": (35, 0.7, 7.5, 0.3, 4.5, 1, 2.0),
    "Kiwi": (60, 1.0, 14.0, 0.5, 9.0, 3, 3.0),
    "Kelapa Muda": (25, 0.2, 3.7, 0.2, 2.5, 105, 0.5),
    "Kelapa Tua": (360, 3.5, 15.0, 33.5, 6.0, 20, 9.0),
    "Kurma": (280, 2.5, 70.0, 0.4, 63.0, 2, 7.0),
    "Sukun": (110, 1.0, 27.0, 0.3, 11.0, 2, 4.9),

    # Kacang-kacangan
    "Kacang Tanah Rebus": (360, 16.0, 14.0, 28.0, 0.5, 5, 5.0),
    "Kacang Tanah Goreng": (570, 25.0, 20.0, 45.0, 4.0, 320, 7.0),
    "Kacang Hijau Rebus": (115, 8.0, 20.0, 0.5, 1.5, 6, 4.0),
    "Kacang Merah Rebus": (120, 8.5, 20.5, 0.5, 0.5, 5, 6.5),
    "Kacang Kedelai Rebus": (175, 17.0, 10.0, 9.0, 0.5, 2, 6.0),
    "Edamame Rebus": (120, 11.0, 9.0, 5.5, 2.0, 6, 5.0),

    # Minuman (per serving)
    "Susu Sapi Segar": (60, 3.2, 4.8, 3.2, 4.8, 40, 0.0),
    "Susu Kedelai": (45, 3.5, 4.5, 1.5, 3.0, 15, 0.5),
    "Susu Almond": (25, 0.5, 3.0, 1.5, 2.0, 60, 0.3),
    "Kopi Hitam": (3, 0.2, 0.5, 0.0, 0.0, 3, 0.0),
    "Kopi Susu": (80, 2.5, 10.0, 3.5, 8.0, 35, 0.0),
    "Teh Manis": (50, 0.0, 12.0, 0.0, 12.0, 5, 0.0),
    "Teh Tawar": (2, 0.0, 0.5, 0.0, 0.0, 0, 0.0),
    "Es Jeruk": (60, 0.3, 14.0, 0.1, 12.0, 5, 0.2),
    "Jus Alpukat": (180, 2.0, 18.0, 12.0, 10.0, 15, 3.0),
    "Jus Mangga": (90, 0.5, 22.0, 0.3, 20.0, 3, 1.0),
    "Jus Jambu": (75, 0.8, 18.0, 0.3, 15.0, 5, 3.5),
    "Jus Sirsak": (85, 0.8, 20.0, 0.3, 16.0, 10, 2.0),
    "Es Teh Manis": (60, 0.0, 15.0, 0.0, 15.0, 5, 0.0),
    "Es Kelapa Muda": (45, 0.3, 8.0, 0.3, 6.0, 120, 1.0),
    "Yogurt Plain": (60, 5.0, 7.0, 1.5, 7.0, 60, 0.0),
    "Air Kelapa": (20, 0.2, 3.7, 0.2, 2.5, 105, 0.5),

    # Roti & Serealia
    "Roti Tawar": (265, 8.0, 49.0, 3.2, 4.5, 500, 2.5),
    "Roti Gandum": (250, 9.0, 44.0, 3.0, 3.5, 440, 5.5),
    "Bubur Ayam": (150, 8.0, 20.0, 5.0, 0.5, 300, 0.5),
    "Bubur Kacang Hijau": (130, 5.0, 22.0, 2.0, 10.0, 10, 2.5),
    "Mie Instan Rebus": (400, 8.0, 52.0, 17.0, 3.0, 1800, 2.0),
    "Mie Instan Goreng": (430, 9.0, 50.0, 22.0, 4.0, 1900, 2.5),
    "Bihun Rebus": (110, 1.5, 26.0, 0.2, 0.0, 5, 0.5),
    "Kwetiau Rebus": (125, 2.0, 28.0, 0.5, 0.0, 10, 0.5),
    "Soun Rebus": (85, 0.5, 20.0, 0.0, 0.0, 3, 0.3),
}

# Common Indonesian dishes (per porsi/serving)
LOCAL_DISHES = {
    # Nasi olahan
    "Nasi Goreng": (360, 10.0, 45.0, 15.0, 2.0, 600, 1.5),
    "Nasi Goreng Spesial": (420, 14.0, 48.0, 18.0, 2.5, 750, 1.5),
    "Nasi Goreng Kampung": (330, 9.0, 42.0, 14.0, 2.0, 550, 1.5),
    "Nasi Goreng Seafood": (380, 12.0, 43.0, 16.0, 2.0, 650, 1.8),
    "Nasi Goreng Pete": (350, 9.5, 44.0, 15.0, 2.0, 600, 2.0),
    "Nasi Uduk": (320, 7.0, 42.0, 14.0, 1.5, 500, 1.0),
    "Nasi Kuning": (310, 8.5, 42.0, 12.5, 1.5, 450, 1.2),
    "Nasi Liwet": (340, 9.0, 43.0, 14.0, 1.5, 550, 1.5),
    "Nasi Timbel": (275, 7.0, 40.0, 9.0, 0.5, 350, 2.0),
    "Nasi Pecel": (380, 12.0, 42.0, 18.0, 5.0, 600, 4.0),
    "Nasi Campur": (450, 15.0, 50.0, 20.0, 3.0, 800, 3.0),
    "Nasi Padang": (520, 18.0, 50.0, 28.0, 3.0, 1000, 3.0),
    "Nasi Rames": (480, 16.0, 52.0, 24.0, 3.0, 900, 3.0),

    # Lontong & Ketupat
    "Lontong Sayur": (350, 10.0, 38.0, 18.0, 3.0, 700, 2.5),
    "Ketupat Sayur": (340, 9.5, 38.0, 17.5, 3.0, 680, 2.5),

    # Ayam olahan
    "Ayam Bakar Kecap": (280, 28.0, 8.0, 15.0, 6.0, 550, 0.5),
    "Ayam Bakar Taliwang": (320, 30.0, 5.0, 20.0, 2.0, 700, 1.0),
    "Ayam Geprek": (380, 26.0, 20.0, 22.0, 1.0, 800, 1.5),
    "Ayam Penyet": (370, 27.0, 18.0, 21.0, 1.0, 750, 1.5),
    "Ayam Rica-Rica": (300, 29.0, 5.0, 18.0, 2.0, 600, 1.5),
    "Ayam Balado": (290, 28.0, 6.0, 17.0, 3.0, 550, 1.5),
    "Ayam Goreng Tepung": (350, 22.0, 18.0, 22.0, 1.0, 700, 1.0),
    "Ayam Goreng Kremes": (330, 23.0, 16.0, 20.0, 1.0, 650, 1.0),
    "Ayam Kalasan": (310, 28.0, 10.0, 17.0, 8.0, 500, 1.0),
    "Ayam Betutu": (300, 29.0, 6.0, 18.0, 2.0, 550, 1.5),
    "Ayam Opor": (320, 27.0, 8.0, 20.0, 2.0, 500, 1.0),
    "Ayam Gulai": (330, 27.0, 7.0, 21.0, 2.0, 550, 1.0),
    "Ayam Semur": (300, 28.0, 12.0, 14.0, 8.0, 650, 1.0),
    "Ayam Kecap": (290, 28.0, 10.0, 14.0, 9.0, 600, 0.5),
    "Ayam Woku": (310, 29.0, 5.0, 19.0, 2.0, 600, 1.5),

    # Ikan olahan
    "Ikan Bakar Kecap": (220, 22.0, 3.0, 13.0, 2.0, 450, 0.5),
    "Ikan Asam Manis": (200, 20.0, 8.0, 10.0, 5.0, 400, 0.5),
    "Ikan Pesmol": (210, 21.0, 4.0, 12.0, 2.0, 400, 0.5),
    "Pepes Ikan": (180, 22.0, 2.0, 9.0, 1.0, 350, 1.0),
    "Pindang Ikan": (170, 21.0, 3.0, 8.0, 1.0, 500, 0.5),

    # Soto & Sup
    "Soto Ayam": (280, 15.0, 25.0, 13.0, 2.0, 700, 2.0),
    "Soto Daging": (300, 18.0, 24.0, 16.0, 2.0, 750, 2.0),
    "Soto Betawi": (420, 20.0, 28.0, 25.0, 3.0, 800, 2.0),
    "Soto Padang": (290, 16.0, 24.0, 14.0, 2.0, 720, 2.0),
    "Soto Lamongan": (285, 15.5, 25.0, 13.5, 2.0, 710, 2.0),
    "Soto Madura": (310, 17.0, 26.0, 15.0, 2.0, 740, 2.0),
    "Soto Kudus": (280, 15.0, 25.0, 13.0, 2.0, 700, 2.0),
    "Soto Sokaraja": (330, 15.0, 30.0, 15.0, 3.0, 750, 3.0),
    "Soto Banjar": (295, 16.0, 24.0, 14.5, 2.0, 730, 2.0),
    "Coto Makassar": (350, 20.0, 26.0, 18.0, 2.0, 800, 2.5),
    "Rawon": (320, 20.0, 25.0, 16.0, 2.0, 700, 2.5),
    "Sop Buntut": (380, 22.0, 20.0, 24.0, 2.0, 600, 2.0),
    "Sop Iga Sapi": (350, 20.0, 18.0, 22.0, 2.0, 550, 1.5),
    "Sop Ayam": (200, 16.0, 12.0, 10.0, 1.5, 400, 1.5),
    "Bakso Sapi": (280, 14.0, 30.0, 12.0, 2.0, 900, 1.5),
    "Bakso Malang": (320, 16.0, 32.0, 14.0, 2.5, 1000, 2.0),
    "Bakso Bakar": (310, 15.0, 28.0, 16.0, 3.0, 850, 1.5),

    # Mie
    "Mie Ayam": (400, 14.0, 48.0, 17.0, 3.0, 900, 2.0),
    "Mie Ayam Bakso": (450, 16.0, 50.0, 19.0, 3.0, 1100, 2.0),
    "Mie Ayam Pangsit": (430, 15.0, 49.0, 18.0, 3.0, 1050, 2.0),
    "Mie Goreng": (420, 12.0, 48.0, 20.0, 3.0, 1000, 2.0),
    "Mie Rebus": (380, 11.0, 46.0, 17.0, 2.5, 900, 1.8),
    "Mie Aceh": (450, 16.0, 45.0, 22.0, 3.0, 1000, 2.5),
    "Mie Kocok": (370, 15.0, 40.0, 16.0, 2.0, 850, 1.5),
    "Bihun Goreng": (350, 8.0, 42.0, 16.0, 2.0, 700, 1.5),
    "Kwetiau Goreng": (380, 10.0, 44.0, 18.0, 2.0, 800, 1.5),
    "Ifumie Goreng": (400, 12.0, 42.0, 20.0, 2.0, 850, 1.8),

    # Sate
    "Sate Ayam": (250, 20.0, 8.0, 15.0, 4.0, 400, 1.0),
    "Sate Kambing": (280, 22.0, 6.0, 18.0, 3.0, 450, 0.5),
    "Sate Sapi": (270, 24.0, 6.0, 16.0, 3.0, 420, 0.5),
    "Sate Padang": (300, 20.0, 10.0, 18.0, 3.0, 500, 1.5),
    "Sate Madura": (255, 21.0, 7.0, 15.5, 3.5, 410, 1.0),
    "Sate Lilit": (240, 19.0, 5.0, 16.0, 2.0, 380, 1.0),

    # Rendang & Gulai
    "Rendang Sapi": (380, 26.0, 8.0, 28.0, 3.0, 600, 1.5),
    "Gulai Kambing": (350, 22.0, 5.0, 27.0, 2.0, 550, 1.0),
    "Gulai Ayam": (330, 24.0, 5.0, 24.0, 2.0, 520, 1.0),
    "Gulai Ikan": (280, 20.0, 3.0, 20.0, 1.5, 480, 0.5),
    "Gulai Otak": (290, 15.0, 5.0, 23.0, 1.5, 450, 0.5),
    "Gulai Nangka": (250, 5.0, 15.0, 20.0, 3.0, 400, 3.0),

    # Sambal & Lalapan
    "Sambal Terasi": (80, 2.0, 8.0, 5.0, 3.0, 500, 1.5),
    "Sambal Bawang": (70, 1.5, 7.0, 4.5, 3.0, 450, 1.0),
    "Sambal Matah": (65, 1.0, 4.0, 5.0, 1.5, 350, 1.0),
    "Sambal Ijo": (75, 1.5, 6.0, 5.5, 2.0, 400, 2.0),
    "Sambal Kecap": (60, 1.0, 10.0, 2.0, 7.0, 600, 0.5),
    "Lalapan Mentah": (25, 1.0, 5.0, 0.3, 2.0, 10, 2.5),

    # Gorengan
    "Tahu Isi Goreng": (200, 8.0, 15.0, 12.0, 1.0, 250, 1.5),
    "Pisang Goreng": (180, 1.5, 30.0, 7.0, 10.0, 50, 1.5),
    "Singkong Goreng": (200, 1.0, 36.0, 7.0, 2.0, 50, 1.5),
    "Bakwan Sayur": (180, 3.0, 20.0, 10.0, 2.0, 300, 1.5),
    "Tempe Goreng Tepung": (220, 10.0, 15.0, 14.0, 1.0, 200, 1.5),
    "Risoles": (200, 5.0, 22.0, 10.0, 2.0, 250, 1.0),
    "Pastel Goreng": (220, 6.0, 24.0, 12.0, 2.0, 280, 1.0),
    "Lumpia Goreng": (190, 7.0, 20.0, 10.0, 2.0, 300, 1.5),
    "Martabak Telur": (350, 15.0, 30.0, 20.0, 2.0, 700, 1.5),
    "Martabak Manis": (400, 8.0, 55.0, 18.0, 25.0, 300, 1.0),

    # Jajanan Pasar
    "Klepon": (150, 2.0, 32.0, 2.0, 15.0, 30, 1.0),
    "Onde-Onde": (180, 3.0, 30.0, 6.0, 10.0, 50, 1.5),
    "Lemper": (200, 6.0, 28.0, 8.0, 1.0, 200, 1.5),
    "Arem-Arem": (190, 5.0, 30.0, 6.0, 1.0, 180, 2.0),
    "Serabi": (170, 3.0, 30.0, 4.0, 10.0, 150, 0.5),
    "Lapis Legit": (350, 5.0, 40.0, 20.0, 30.0, 100, 0.5),
    "Dadar Gulung": (180, 3.0, 28.0, 8.0, 12.0, 80, 1.5),
    "Bolu Kukus": (200, 4.0, 35.0, 6.0, 18.0, 150, 0.5),
    "Cucur": (220, 2.0, 38.0, 8.0, 15.0, 50, 0.5),
    "Getuk Lindri": (180, 1.5, 40.0, 2.0, 15.0, 30, 1.5),
    "Nagasari": (160, 2.0, 32.0, 3.0, 12.0, 40, 1.0),
    "Putu Ayu": (170, 3.0, 28.0, 6.0, 15.0, 100, 1.0),

    # Minuman tradisional
    "Es Cendol": (250, 2.0, 50.0, 6.0, 30.0, 50, 0.5),
    "Es Dawet": (240, 2.0, 48.0, 6.0, 28.0, 45, 0.5),
    "Es Campur": (280, 3.0, 55.0, 7.0, 35.0, 60, 1.5),
    "Es Teler": (300, 3.0, 50.0, 12.0, 30.0, 55, 2.5),
    "Es Buah": (200, 1.0, 40.0, 2.0, 30.0, 20, 2.0),
    "Es Kacang Merah": (250, 5.0, 45.0, 5.0, 30.0, 30, 3.0),
    "Bajigur": (180, 2.0, 28.0, 6.0, 20.0, 30, 0.5),
    "Bandrek": (120, 1.0, 25.0, 1.0, 18.0, 15, 1.0),
    "Wedang Jahe": (80, 0.5, 18.0, 0.5, 14.0, 10, 0.5),
    "Sekoteng": (160, 3.0, 30.0, 3.0, 22.0, 25, 1.0),

    # Bubur manis / kolak
    "Bubur Sumsum": (220, 2.0, 38.0, 8.0, 15.0, 50, 0.5),
    "Kolak Pisang": (250, 2.0, 45.0, 8.0, 28.0, 30, 2.0),
    "Kolak Ubi": (240, 1.5, 43.0, 8.0, 26.0, 25, 2.5),
    "Bubur Candil": (280, 2.0, 55.0, 6.0, 35.0, 40, 1.0),

    # Lain-lain
    "Pempek Kapal Selam": (350, 12.0, 48.0, 14.0, 5.0, 900, 1.0),
    "Siomay": (250, 12.0, 25.0, 12.0, 3.0, 700, 1.5),
    "Batagor": (300, 14.0, 30.0, 15.0, 3.0, 800, 1.5),
    "Gado-Gado": (350, 14.0, 30.0, 20.0, 6.0, 500, 5.0),
    "Ketoprak": (320, 12.0, 38.0, 14.0, 5.0, 450, 4.0),
    "Pecel": (300, 10.0, 30.0, 16.0, 4.0, 400, 4.5),
    "Karedok": (200, 8.0, 15.0, 14.0, 3.0, 300, 3.5),
    "Asinan Betawi": (150, 3.0, 20.0, 7.0, 8.0, 500, 2.5),
    "Tahu Gejrot": (180, 6.0, 18.0, 10.0, 5.0, 400, 1.5),
    "Rujak Buah": (150, 1.5, 30.0, 3.0, 20.0, 100, 3.0),
    "Rujak Cingur": (250, 10.0, 25.0, 12.0, 5.0, 450, 3.0),
    "Nasi Jamblang": (450, 14.0, 55.0, 20.0, 3.0, 800, 3.0),
    "Nasi Krawu": (440, 14.0, 55.0, 19.0, 3.0, 780, 3.0),
}


def generate_foods() -> list[dict]:
    """Generate comprehensive food data."""
    foods = []

    # Base ingredients
    for name, (cal, prot, carb, fat, sugar, sodium, fiber) in BASE_INGREDIENTS.items():
        foods.append({
            "name": name,
            "name_id": name,
            "serving_size": "100 g",
            "calories": cal,
            "protein_g": prot,
            "carbohydrate_g": carb,
            "fat_g": fat,
            "sugar_g": sugar,
            "sodium_mg": sodium,
            "fiber_g": fiber,
            "food_type": "base_food",
            "source": "generated",
        })

    # Local Indonesian dishes
    for name, (cal, prot, carb, fat, sugar, sodium, fiber) in LOCAL_DISHES.items():
        foods.append({
            "name": name,
            "name_id": name,
            "serving_size": "1 porsi",
            "calories": cal,
            "protein_g": prot,
            "carbohydrate_g": carb,
            "fat_g": fat,
            "sugar_g": sugar,
            "sodium_mg": sodium,
            "fiber_g": fiber,
            "food_type": "local_indonesian",
            "source": "generated",
        })

    print(f"Generated {len(foods)} foods ({len(BASE_INGREDIENTS)} base, {len(LOCAL_DISHES)} local)")
    return foods


if __name__ == "__main__":
    df = pd.DataFrame(generate_foods())
    df.to_csv("output/generated_foods.csv", index=False)
    print(f"Saved {len(df)} to output/generated_foods.csv")
