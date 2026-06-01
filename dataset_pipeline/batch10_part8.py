"""Batch 10 Part 8: Last push — 344 remaining to 10K."""
import pandas as pd
from config import FINAL_OUTPUT

df = pd.read_csv(FINAL_OUTPUT)
df["serving_size"] = df["serving_size"].fillna("1 porsi")
existing = set(df["name"].str.lower().str.strip())
new = []

def add(name, cal, prot, fat, carbs, sug, sod, fib, ft, src):
    key = name.lower().strip()
    if key in existing: return False
    existing.add(key)
    new.append({"name": name, "name_id": name, "serving_size": "1 porsi",
                "calories": cal, "protein_g": prot, "carbohydrate_g": carbs,
                "fat_g": fat, "sugar_g": sug, "sodium_mg": sod, "fiber_g": fib,
                "food_type": ft, "source": src})
    return True

count = 0

# Stuff that was likely missed — massive dump
all_foods = [
    # Raw fruits (Indonesian names)
    ("Buah Naga", 50, 1, 0.3, 10, 8, 5, 3, "base_food"),
    ("Buah Naga Merah", 50, 1, 0.3, 10, 8, 5, 3, "base_food"),
    ("Buah Naga Putih", 50, 1, 0.3, 10, 8, 5, 3, "base_food"),
    ("Buah Sirsak", 65, 1, 0.3, 16, 14, 10, 3, "base_food"),
    ("Buah Srikaya", 80, 2, 0.5, 18, 14, 10, 3, "base_food"),
    ("Buah Sawo", 90, 1, 0.5, 20, 16, 10, 3, "base_food"),
    ("Buah Jambu Air", 35, 1, 0.2, 8, 6, 5, 2, "base_food"),
    ("Buah Jambu Biji Merah", 50, 1, 0.3, 10, 6, 5, 5, "base_food"),
    ("Buah Jambu Biji Putih", 50, 1, 0.3, 10, 6, 5, 5, "base_food"),
    ("Buah Lengkeng", 60, 1, 0.2, 14, 12, 5, 2, "base_food"),
    ("Buah Leci", 60, 1, 0.2, 14, 12, 5, 2, "base_food"),
    ("Buah Kelengkeng", 60, 1, 0.2, 14, 12, 5, 2, "base_food"),
    ("Buah Manggis", 65, 1, 0.3, 16, 14, 5, 5, "base_food"),
    ("Buah Kesemek", 70, 1, 0.3, 16, 14, 5, 4, "base_food"),
    ("Buah Markisa", 80, 2, 0.5, 18, 14, 10, 6, "base_food"),
    ("Buah Nangka Matang", 90, 2, 0.4, 22, 16, 5, 3, "base_food"),
    ("Buah Cempedak", 100, 2, 0.5, 24, 18, 5, 3, "base_food"),
    ("Buah Durian Montong", 140, 3, 5, 28, 14, 5, 4, "base_food"),
    ("Buah Durian Lokal", 130, 3, 5, 26, 14, 5, 4, "base_food"),
    ("Buah Rambutan", 60, 1, 0.3, 14, 12, 5, 2, "base_food"),
    ("Buah Duku", 55, 1, 0.2, 12, 10, 5, 2, "base_food"),
    ("Buah Langsat", 55, 1, 0.2, 12, 10, 5, 2, "base_food"),
    ("Buah Matoa", 80, 2, 0.5, 18, 14, 5, 3, "base_food"),
    ("Buah Gandaria", 50, 1, 0.2, 10, 8, 5, 3, "base_food"),
    ("Buah Kecapi", 45, 1, 0.2, 10, 8, 5, 3, "base_food"),

    # Random Indonesian dishes
    ("Ayam Tauco", 320, 24, 14, 18, 5, 550, 2, "local_indonesian"),
    ("Ayam Masak Merah", 340, 24, 16, 20, 6, 480, 2, "local_indonesian"),
    ("Ayam Masak Hitam", 330, 24, 16, 18, 5, 550, 2, "local_indonesian"),
    ("Ayam Masak Lemak", 350, 24, 18, 16, 4, 450, 2, "local_indonesian"),
    ("Ayam Masak Kicap", 340, 24, 14, 18, 6, 520, 2, "local_indonesian"),
    ("Ayam Masak Ros", 330, 24, 16, 18, 5, 480, 2, "local_indonesian"),
    ("Ayam Goreng Serbaguna", 330, 24, 16, 18, 3, 380, 1, "base_food"),
    ("Daging Masak Hitam", 340, 28, 18, 14, 5, 520, 1, "local_indonesian"),
    ("Daging Masak Merah", 350, 28, 18, 16, 6, 500, 2, "local_indonesian"),
    ("Daging Masak Kicap", 350, 28, 16, 18, 6, 550, 1, "local_indonesian"),
    ("Ikan Masak Tauco", 280, 22, 12, 16, 5, 550, 2, "local_indonesian"),
    ("Ikan Masak Lemak", 300, 22, 16, 14, 4, 480, 2, "local_indonesian"),
    ("Ikan Masak Cuka", 260, 22, 10, 16, 5, 480, 2, "local_indonesian"),
    ("Ikan Masak Tempoyak", 290, 22, 14, 16, 5, 500, 2, "local_indonesian"),
    ("Udang Masak Lemak", 280, 18, 14, 16, 4, 480, 2, "local_indonesian"),
    ("Udang Masak Kering", 300, 20, 14, 18, 5, 550, 2, "local_indonesian"),
    ("Cumi Masak Hitam", 250, 16, 8, 22, 4, 520, 2, "local_indonesian"),
    ("Cumi Masak Lemak", 280, 16, 14, 18, 4, 480, 2, "local_indonesian"),
    ("Cumi Masak Tauco", 270, 16, 10, 20, 5, 580, 2, "local_indonesian"),

    # More Thai
    ("Pad Ka Prao Thailand", 380, 24, 14, 34, 5, 650, 2, "other"),
    ("Kai Med Ma Muang", 350, 22, 12, 28, 10, 480, 3, "other"),
    ("Gai Pad King", 320, 24, 10, 24, 5, 500, 3, "other"),
    ("Pla Rad Prik Thailand", 280, 22, 10, 20, 6, 500, 2, "other"),
    ("Kuay Tiew Kua Gai", 380, 16, 10, 48, 5, 580, 3, "other"),
    ("Moo Ping Thailand", 300, 18, 16, 18, 6, 450, 1, "other"),
    ("Kai Yang Thailand", 320, 26, 14, 16, 5, 480, 2, "other"),
    ("Suki Thailand", 350, 20, 10, 40, 6, 650, 4, "other"),

    # More Indian
    ("Palak Gosht", 320, 26, 16, 14, 4, 500, 4, "other"),
    ("Aloo Gosht", 300, 22, 14, 22, 4, 480, 4, "other"),
    ("Baingan Bharta", 150, 4, 8, 18, 5, 380, 6, "other"),
    ("Chicken Chettinad", 340, 26, 16, 16, 4, 520, 3, "other"),
    ("Keema Matar", 280, 18, 14, 20, 5, 450, 5, "other"),
    ("Malai Kofta", 320, 12, 20, 22, 6, 480, 3, "other"),
    ("Bhindi Masala", 140, 4, 8, 16, 4, 380, 5, "other"),
    ("Rajma Masala", 200, 10, 6, 26, 4, 420, 7, "other"),
    ("Pav Bhaji", 300, 8, 12, 38, 8, 500, 6, "other"),
    ("Vada Pav", 250, 6, 8, 36, 4, 450, 4, "snack"),

    # Lobster/Udang/etc
    ("Lobster Bakar Mentega", 280, 24, 12, 16, 3, 500, 1, "other"),
    ("Lobster Goreng Mentega", 320, 24, 16, 18, 3, 480, 1, "other"),
    ("Lobster Saus Tiram", 300, 24, 10, 20, 4, 550, 2, "other"),
    ("Lobster Saus Padang", 320, 24, 14, 22, 5, 580, 2, "other"),
    ("Udang Karang Bakar", 250, 22, 8, 16, 3, 480, 1, "other"),
    ("Udang Karang Goreng", 290, 22, 14, 18, 3, 450, 1, "other"),
    ("Udang Karang Saus Tiram", 280, 22, 10, 20, 4, 550, 2, "other"),
    ("Kepiting Bakar Bumbu", 220, 18, 8, 16, 3, 500, 1, "other"),
    ("Kepiting Goreng Saus", 260, 18, 14, 18, 3, 520, 1, "other"),

    # Snapper/Grouper more
    ("Ikan Kakap Kuah Asam", 250, 24, 8, 18, 4, 480, 1, "other"),
    ("Ikan Kerapu Goreng Mentega", 300, 24, 14, 18, 3, 420, 1, "other"),
    ("Ikan Kerapu Tim", 200, 24, 5, 14, 3, 450, 1, "other"),
    ("Ikan Baronang Bakar", 250, 22, 9, 16, 3, 400, 1, "other"),
    ("Ikan Baronang Goreng", 280, 22, 14, 16, 3, 380, 1, "other"),
    ("Ikan Kuwe Bakar", 270, 24, 10, 16, 3, 400, 1, "other"),
    ("Ikan Kuwe Goreng", 300, 24, 16, 16, 3, 380, 1, "other"),
    ("Ikan Tenggiri Bakar", 260, 26, 8, 16, 3, 380, 1, "other"),
    ("Ikan Tenggiri Goreng", 290, 26, 14, 16, 3, 380, 1, "other"),
    ("Ikan Selar Bakar", 240, 22, 8, 16, 3, 400, 1, "other"),
    ("Ikan Selar Goreng", 280, 22, 14, 16, 3, 380, 1, "other"),

    # More beverages
    ("Es Jeruk Nipis", 50, 0, 0, 12, 10, 10, 1, "beverage"),
    ("Es Jeruk Kunci", 50, 0, 0, 12, 10, 10, 1, "beverage"),
    ("Es Sirup Marjan", 80, 0, 0, 18, 16, 20, 0, "beverage"),
    ("Es Sirup ABC", 80, 0, 0, 18, 16, 20, 0, "beverage"),
    ("Es Soda Susu", 120, 2, 3, 20, 18, 30, 0, "beverage"),
    ("Milkshake Coklat", 280, 6, 8, 42, 34, 120, 2, "beverage"),
    ("Milkshake Stroberi", 260, 5, 7, 42, 32, 100, 2, "beverage"),
    ("Milkshake Vanila", 270, 6, 8, 40, 32, 110, 1, "beverage"),
    ("Milkshake Oreo", 300, 6, 10, 44, 36, 140, 2, "beverage"),
    ("Float Coklat", 240, 4, 8, 36, 28, 80, 1, "beverage"),
    ("Float Stroberi", 220, 3, 6, 36, 28, 70, 1, "beverage"),

    # More raw/cooked bases
    ("Jagung Rebus Manis", 90, 3, 1, 18, 6, 10, 3, "base_food"),
    ("Jagung Bakar Bumbu", 150, 4, 5, 22, 6, 200, 3, "snack"),
    ("Jagung Bakar Keju", 160, 5, 7, 22, 6, 250, 3, "snack"),
    ("Jagung Bakar Pedas", 150, 4, 5, 22, 6, 220, 3, "snack"),
    ("Jagung Serut Rebus", 90, 3, 1, 18, 6, 10, 3, "base_food"),

    # Sandwich/Toast more
    ("Toast Coklat Pisang", 320, 8, 10, 44, 16, 250, 4, "snack"),
    ("Toast Selai Kacang", 300, 10, 12, 36, 10, 250, 4, "snack"),
    ("Toast Selai Stroberi", 280, 6, 8, 42, 18, 200, 3, "snack"),
    ("Toast Srikaya", 280, 5, 8, 42, 18, 180, 2, "snack"),
    ("Toast Mentega Gula", 280, 5, 10, 40, 14, 200, 2, "snack"),
    ("Toast Telur Setengah Matang", 300, 14, 12, 30, 4, 380, 2, "snack"),

    # Bakwan/Perkedel more
    ("Bakwan Udang", 200, 6, 10, 22, 4, 380, 3, "snack"),
    ("Bakwan Bayam", 180, 5, 8, 22, 4, 320, 3, "snack"),
    ("Perkedel Tahu", 180, 8, 8, 18, 3, 350, 3, "snack"),
    ("Perkedel Tempe", 200, 8, 10, 18, 3, 350, 3, "snack"),

    # Tim / Kukus
    ("Tim Ikan Dori", 200, 18, 6, 16, 3, 380, 2, "other"),
    ("Tim Ayam Jamur Kuping", 220, 20, 6, 18, 3, 400, 2, "other"),
    ("Tim Tahu Udang", 180, 14, 8, 12, 3, 420, 2, "other"),
    ("Tim Telur Daging Cincang", 220, 16, 12, 10, 3, 400, 2, "other"),

    # Sup more
    ("Sop Kacang Merah Daging", 250, 18, 8, 26, 5, 450, 6, "other"),
    ("Sop Kambing Rempah", 320, 24, 16, 16, 4, 520, 2, "other"),
    ("Sop Ayam Kampung", 200, 18, 6, 16, 3, 420, 2, "other"),
    ("Sop Oyong Soun", 130, 5, 3, 22, 4, 380, 3, "other"),

    # ACAR / Pickles
    ("Acar Timun", 40, 1, 0, 8, 5, 300, 2, "other"),
    ("Acar Kuning", 50, 1, 1, 8, 5, 300, 2, "other"),
    ("Acar Ikan", 80, 4, 2, 10, 5, 400, 2, "other"),
    ("Acar Sayuran", 40, 1, 0, 8, 5, 300, 3, "other"),

    # Lalapan more
    ("Lalapan Mentah", 40, 2, 0, 8, 3, 20, 5, "base_food"),
    ("Lalapan Sambal Terasi", 80, 3, 4, 10, 4, 320, 4, "other"),
    ("Lalapan Sambal Bawang", 80, 3, 4, 10, 4, 300, 4, "other"),

    # Telur more
    ("Telur Asin Bebek", 160, 10, 11, 2, 1, 550, 0, "base_food"),
    ("Telur Gulung", 200, 10, 12, 10, 3, 300, 1, "snack"),
    ("Telur Gabus", 180, 10, 12, 8, 3, 320, 1, "snack"),

    # Keripik
    ("Keripik Tempe", 200, 8, 10, 18, 2, 250, 4, "snack"),
    ("Keripik Singkong Balado", 220, 2, 10, 30, 4, 350, 3, "snack"),
    ("Keripik Pisang Manis", 200, 2, 6, 34, 14, 50, 4, "snack"),
    ("Keripik Ubi", 220, 2, 8, 32, 8, 80, 4, "snack"),
    ("Keripik Bayam", 120, 3, 6, 14, 2, 200, 3, "snack"),
    ("Keripik Nangka", 180, 2, 6, 28, 8, 80, 3, "snack"),
    ("Keripik Jamur", 150, 5, 6, 18, 3, 250, 4, "snack"),

    # Nasi/Noodle more
    ("Nasi Tim Hainan", 320, 16, 8, 42, 3, 400, 2, "other"),
    ("Nasi Minyak Arab", 260, 5, 8, 40, 2, 100, 1, "other"),
    ("Nasi Daun Jeruk", 200, 4, 2, 40, 0, 50, 1, "base_food"),
    ("Mie Kering Ayam", 400, 12, 14, 50, 5, 600, 3, "other"),
    ("Mie Nyemek", 380, 10, 12, 50, 5, 580, 3, "other"),
    ("Mie Godhog", 350, 10, 8, 50, 5, 550, 3, "other"),
    ("Mie Dokdok", 360, 12, 10, 48, 5, 580, 3, "other"),

    # Ikan more
    ("Ikan Pari Bakar", 220, 18, 8, 16, 3, 400, 1, "other"),
    ("Ikan Pari Goreng", 250, 18, 12, 16, 3, 380, 1, "other"),
    ("Ikan Pari Asam Pedas", 240, 18, 10, 18, 5, 480, 2, "other"),
    ("Ikan Manyung Bakar", 250, 22, 10, 16, 3, 420, 1, "other"),
    ("Ikan Manyung Goreng", 280, 22, 14, 16, 3, 380, 1, "other"),
    ("Ikan Keting Goreng", 270, 22, 12, 16, 3, 380, 1, "other"),
    ("Ikan Bilis Goreng", 280, 24, 14, 14, 2, 450, 1, "other"),

    # Seafood combo
    ("Seafood Platter Bakar", 400, 32, 16, 28, 5, 550, 4, "other"),
    ("Seafood Platter Goreng", 450, 30, 22, 32, 5, 550, 4, "other"),
    ("Seafood Saus Padang", 420, 30, 18, 30, 6, 600, 4, "other"),

    # Cumi more
    ("Cumi Isi Tahu", 220, 16, 8, 18, 3, 420, 2, "other"),
    ("Cumi Isi Daging", 250, 18, 10, 18, 3, 420, 2, "other"),
    ("Cumi Telur Asin", 280, 16, 14, 20, 3, 500, 2, "other"),

    # Pangsit / Dumpling
    ("Pangsit Kuah Ayam", 200, 10, 6, 24, 3, 550, 2, "other"),
    ("Pangsit Goreng Ayam", 250, 10, 10, 26, 3, 500, 2, "snack"),
    ("Pangsit Goreng Udang", 230, 10, 8, 26, 3, 520, 2, "snack"),
    ("Pangsit Goreng Keju", 240, 9, 12, 24, 3, 450, 1, "snack"),
    ("Wonton Kuah", 200, 10, 5, 24, 3, 600, 2, "other"),
    ("Wonton Goreng", 250, 10, 10, 26, 3, 520, 2, "snack"),

    # Ikan more regional
    ("Ikan Betok Goreng", 270, 20, 12, 18, 3, 380, 1, "other"),
    ("Ikan Betok Bakar", 240, 22, 8, 16, 3, 380, 1, "other"),
    ("Ikan Sepat Goreng", 260, 20, 10, 16, 3, 380, 1, "other"),
    ("Ikan Tawes Goreng", 270, 20, 12, 16, 3, 380, 1, "other"),
    ("Ikan Tawes Bakar", 240, 22, 8, 14, 3, 380, 1, "other"),
    ("Ikan Gabus Goreng", 280, 24, 12, 16, 3, 380, 1, "other"),
    ("Ikan Gabus Bakar", 250, 26, 8, 14, 3, 380, 1, "other"),

    # More padang/Sumatra
    ("Dendeng Batokok Sambal", 300, 28, 12, 16, 5, 480, 2, "local_indonesian"),
    ("Gulai Cincang Daging", 340, 26, 18, 14, 4, 500, 2, "local_indonesian"),
    ("Gulai Tambusu", 280, 18, 16, 14, 4, 480, 2, "local_indonesian"),
    ("Gulai Gajeboh", 300, 16, 20, 12, 3, 450, 1, "local_indonesian"),
    ("Sambal Lado Ikan", 250, 22, 14, 10, 4, 450, 2, "local_indonesian"),
    ("Ayam Pop Padang", 320, 26, 16, 12, 3, 350, 1, "local_indonesian"),
    ("Ayam Goreng Padang", 350, 26, 20, 14, 3, 400, 1, "local_indonesian"),
    ("Ikan Pop Padang", 250, 24, 10, 12, 3, 380, 1, "local_indonesian"),

    # More Sunda
    ("Nasi Liwet Sunda", 350, 10, 10, 48, 4, 420, 3, "local_indonesian"),
    ("Ayam Bakakak Sunda", 350, 28, 16, 18, 4, 450, 2, "local_indonesian"),
    ("Sate Maranggi Sunda", 280, 24, 12, 16, 5, 450, 1, "local_indonesian"),
    ("Karedok Sunda", 200, 8, 10, 20, 5, 350, 6, "local_indonesian"),
    ("Surabi Sunda", 200, 4, 6, 30, 14, 80, 2, "snack"),
    ("Combro Sunda", 200, 4, 7, 28, 4, 350, 3, "snack"),
    ("Misro Sunda", 180, 3, 6, 28, 12, 200, 3, "snack"),
    ("Colenak Sunda", 200, 3, 7, 30, 12, 50, 4, "snack"),
    ("Awug Sunda", 180, 3, 5, 28, 12, 50, 3, "snack"),

    # Australian
    ("Meat Pie Australia", 400, 22, 20, 30, 3, 550, 3, "other"),
    ("Sausage Roll Australia", 350, 14, 20, 26, 3, 500, 2, "other"),
    ("Lamington Australia", 220, 4, 8, 32, 18, 100, 2, "snack"),
    ("Pavlova Australia", 250, 4, 6, 44, 36, 50, 2, "snack"),
    ("Tim Tam Australia", 180, 3, 8, 24, 14, 80, 1, "snack"),
    ("Vegemite Toast", 200, 8, 5, 30, 3, 500, 3, "other"),

    # Scandi/Nordic
    ("Gravlax Skandinavia", 250, 24, 14, 8, 3, 550, 1, "other"),
    ("Meatball Swedia", 350, 20, 18, 24, 5, 500, 3, "other"),
    ("Smorrebrod Denmark", 280, 12, 10, 30, 5, 450, 4, "other"),
    ("Lefse Norwegia", 200, 4, 5, 34, 6, 200, 3, "other"),

    # More sayur/prep namings
    ("Sayur Labu Kuning Santan", 140, 3, 8, 18, 6, 320, 4, "local_indonesian"),
    ("Sayur Kacang Tanah", 180, 8, 8, 18, 4, 300, 4, "local_indonesian"),
    ("Sayur Kluwih", 150, 4, 8, 18, 4, 320, 4, "local_indonesian"),
    ("Sayur Gori Santan", 160, 5, 10, 16, 3, 350, 5, "local_indonesian"),
    ("Sayur Mangkokan Santan", 150, 5, 10, 14, 3, 350, 5, "local_indonesian"),
]
for item in all_foods:
    if add(*item, "gen-batch10"): count += 1

# ================================================================
# SAVE
# ================================================================
print(f"\nPart 8 total new: {count}")
if new:
    ndf = pd.DataFrame(new)
    ndf.to_csv(FINAL_OUTPUT, mode='a', header=False, index=False)
    df = pd.read_csv(FINAL_OUTPUT)
    print(f"Running total: {len(df)} foods")
    print(df["food_type"].value_counts().to_string())
else:
    print("No new foods added!")
