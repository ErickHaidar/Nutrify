"""Batch 10 Part 2: Target ~1,200 new foods."""
import pandas as pd
from config import FINAL_OUTPUT

df = pd.read_csv(FINAL_OUTPUT)
df["serving_size"] = df["serving_size"].fillna("1 porsi")
existing = set(df["name"].str.lower().str.strip())
new = []

def add(name, cal, prot, fat, carbs, sug, sod, fib, ft, src):
    key = name.lower().strip()
    if key in existing:
        return False
    existing.add(key)
    new.append({
        "name": name, "name_id": name, "serving_size": "1 porsi",
        "calories": cal, "protein_g": prot, "carbohydrate_g": carbs,
        "fat_g": fat, "sugar_g": sug, "sodium_mg": sod, "fiber_g": fib,
        "food_type": ft, "source": src,
    })
    return True

count = 0

# ================================================================
# 7. MORE REGIONAL DISHES — deeper dive per region
# ================================================================
regional2 = [
    # Sunda
    ("Nasi Timbel Ayam", 380, 20, 14, 44, 2, 450, 2.5, "local_indonesian"),
    ("Nasi Timbel Ikan", 360, 18, 12, 44, 2, 420, 2.5, "local_indonesian"),
    ("Nasi Timbel Tahu Tempe", 320, 14, 12, 42, 2, 400, 3.0, "local_indonesian"),
    ("Sambal Dadak", 25, 0.5, 2, 2, 0.5, 250, 0.5, "local_indonesian"),
    ("Sambal Hejo", 28, 0.5, 2.5, 2, 0.5, 280, 0.5, "local_indonesian"),
    ("Ikan Pesmol", 220, 18, 12, 10, 2, 400, 0.5, "local_indonesian"),
    ("Ayam Pesmol", 280, 24, 16, 10, 2, 400, 0.5, "local_indonesian"),
    ("Sayur Pakis Tumis", 80, 3, 4, 8, 1, 250, 3.0, "local_indonesian"),
    ("Lalab Mentah", 40, 2, 0.5, 8, 2, 20, 3.5, "local_indonesian"),
    # Betawi
    ("Soto Mie Betawi", 350, 14, 16, 38, 3, 650, 2.0, "local_indonesian"),
    ("Sayur Besan", 180, 8, 10, 16, 3, 350, 3.0, "local_indonesian"),
    ("Sambal Godog", 30, 0.5, 2, 3, 1, 250, 0.5, "local_indonesian"),
    ("Pindang Serani", 220, 18, 10, 14, 2, 450, 1.0, "local_indonesian"),
    ("Pindang Bandeng", 240, 18, 12, 14, 2, 480, 1.0, "local_indonesian"),
    # Jawa
    ("Gudeg Basah", 350, 10, 14, 46, 18, 400, 4.0, "local_indonesian"),
    ("Gudeg Kering", 320, 10, 10, 48, 16, 380, 4.0, "local_indonesian"),
    ("Nasi Gudeg Ayam", 420, 16, 16, 52, 18, 450, 4.0, "local_indonesian"),
    ("Nasi Gudeg Telur", 380, 14, 14, 50, 18, 420, 4.0, "local_indonesian"),
    ("Sambal Goreng Kentang Ati Ampela", 240, 12, 14, 16, 3, 450, 1.5, "local_indonesian"),
    ("Sambal Goreng Tahu Tempe", 210, 12, 14, 14, 2, 400, 2.0, "local_indonesian"),
    ("Sambal Goreng Krecek Tahu Tempe", 250, 14, 14, 18, 3, 550, 2.0, "local_indonesian"),
    ("Opor Ayam Kampung", 340, 22, 22, 12, 2, 430, 0.5, "local_indonesian"),
    ("Opor Telur", 240, 10, 18, 8, 2, 380, 0.3, "local_indonesian"),
    ("Opor Tahu Tempe", 260, 14, 16, 14, 3, 400, 2.5, "local_indonesian"),
    # Madura
    ("Sate Ayam Madura", 280, 22, 14, 12, 3, 450, 0.5, "local_indonesian"),
    ("Sate Sapi Madura", 300, 24, 16, 12, 3, 420, 0.5, "local_indonesian"),
    ("Sate Kambing Madura", 310, 22, 20, 10, 3, 420, 0.5, "local_indonesian"),
    ("Soto Madura", 340, 18, 16, 30, 3, 580, 2.0, "local_indonesian"),
    # Solo
    ("Nasi Liwet Solo Ayam", 430, 18, 18, 50, 2, 520, 2.0, "local_indonesian"),
    ("Sate Buntel Solo", 310, 24, 20, 10, 2, 420, 0.5, "local_indonesian"),
    ("Sate Kere Solo", 200, 14, 10, 14, 2, 300, 2.0, "local_indonesian"),
    ("Timlo Solo Komplit", 320, 16, 14, 34, 3, 550, 2.5, "local_indonesian"),
    ("Selat Solo Komplit", 350, 20, 18, 28, 6, 550, 3.0, "local_indonesian"),
    # Semarang
    ("Lumpia Semarang Basah", 200, 8, 10, 22, 3, 400, 2.0, "local_indonesian"),
    ("Lumpia Semarang Goreng", 220, 8, 12, 24, 3, 420, 1.5, "local_indonesian"),
    ("Tahu Gimbal Semarang", 320, 14, 16, 32, 4, 550, 2.5, "local_indonesian"),
    ("Soto Semarang Komplit", 350, 18, 14, 36, 3, 580, 2.5, "local_indonesian"),
    # Palembang
    ("Pempek Dos", 280, 8, 10, 40, 2, 600, 0.5, "local_indonesian"),
    ("Pempek Keriting", 300, 8, 12, 40, 2, 620, 0.5, "local_indonesian"),
    ("Tekwan Komplit", 380, 16, 12, 52, 3, 700, 2.0, "local_indonesian"),
    ("Model Ikan Palembang", 360, 16, 14, 42, 3, 680, 1.5, "local_indonesian"),
    ("Laksan Palembang", 340, 12, 14, 40, 3, 680, 1.5, "local_indonesian"),
    # Banjar
    ("Nasi Kuning Banjar Komplit", 430, 16, 18, 52, 2, 500, 2.5, "local_indonesian"),
    ("Soto Banjar Komplit", 350, 20, 14, 34, 3, 580, 2.5, "local_indonesian"),
    ("Ketupat Kandangan Komplit", 380, 16, 16, 44, 3, 550, 2.5, "local_indonesian"),
    # Makassar
    ("Coto Makassar Komplit", 400, 26, 22, 26, 3, 650, 2.5, "local_indonesian"),
    ("Konro Komplit", 400, 28, 24, 18, 3, 600, 1.5, "local_indonesian"),
    ("Pallubasa Komplit", 380, 24, 24, 24, 3, 600, 2.0, "local_indonesian"),
    ("Sop Saudara Komplit", 300, 18, 14, 28, 3, 550, 3.0, "local_indonesian"),
    # Manado
    ("Bubur Manado Komplit", 240, 10, 6, 38, 3, 450, 4.5, "local_indonesian"),
    ("Tinutuan Komplit", 240, 10, 6, 38, 3, 450, 4.5, "local_indonesian"),
    ("Ayam Woku Berem", 320, 28, 18, 10, 2, 500, 0.5, "local_indonesian"),
    ("Ikan Woku Berem", 240, 22, 14, 8, 2, 450, 0.5, "local_indonesian"),
    ("Ayam Rica-Rica Manado", 320, 28, 20, 10, 2, 500, 0.5, "local_indonesian"),
    ("Daging Rica-Rica", 330, 26, 20, 10, 2, 480, 0.5, "local_indonesian"),
    # Sumatra
    ("Sate Padang Komplit", 350, 24, 20, 18, 3, 550, 0.5, "local_indonesian"),
    ("Sate Padang Pariaman", 340, 24, 18, 18, 2, 520, 0.5, "local_indonesian"),
    ("Gulai Ayam Padang", 350, 24, 24, 10, 2, 480, 0.5, "local_indonesian"),
    ("Gulai Ikan Padang", 300, 20, 20, 10, 2, 450, 0.5, "local_indonesian"),
    ("Gulai Tahu Padang", 220, 10, 16, 12, 2, 400, 1.5, "local_indonesian"),
    ("Gulai Nangka Padang", 200, 6, 14, 14, 3, 380, 3.5, "local_indonesian"),
    ("Gulai Pakis Padang", 180, 5, 12, 12, 2, 350, 4.0, "local_indonesian"),
    ("Rendang Telur", 250, 12, 18, 10, 2, 400, 0.3, "local_indonesian"),
    ("Rendang Paru", 320, 24, 22, 8, 1, 450, 0, "local_indonesian"),
    ("Rendang Jengkol", 300, 12, 22, 18, 3, 400, 3.5, "local_indonesian"),
    ("Kalio Ayam", 320, 22, 22, 10, 2, 450, 0.5, "local_indonesian"),
    ("Kalio Daging", 340, 24, 24, 10, 2, 480, 0.5, "local_indonesian"),
]
sv = count
for name, cal, prot, fat, carbs, sug, sod, fib, ft in regional2:
    if add(name, cal, prot, fat, carbs, sug, sod, fib, ft, "gen-batch10"):
        count += 1
print(f"7. Regional 2: +{count - sv}")

# ================================================================
# 8. SOTO / SOP / SATE DEEP DIVE
# ================================================================
soto_sate = [
    ("Soto Daging Sapi", 340, 22, 14, 30, 3, 550, 2.0, "local_indonesian"),
    ("Soto Ayam Kuah Bening", 310, 18, 10, 34, 3, 500, 2.0, "local_indonesian"),
    ("Soto Ayam Kuah Kuning", 320, 18, 12, 34, 3, 520, 2.0, "local_indonesian"),
    ("Soto Ceker", 280, 16, 14, 26, 3, 500, 1.5, "local_indonesian"),
    ("Soto Babat", 300, 20, 16, 24, 3, 550, 1.0, "local_indonesian"),
    ("Soto Paru", 290, 22, 14, 22, 3, 520, 1.0, "local_indonesian"),
    ("Soto Sapi Kuah Santan", 370, 22, 22, 24, 3, 580, 2.0, "local_indonesian"),
    ("Sop Ayam Kampung Bening", 260, 22, 12, 14, 2, 400, 1.5, "local_indonesian"),
    ("Sop Ayam Kampung Sayur", 280, 24, 14, 18, 3, 450, 2.5, "local_indonesian"),
    ("Sop Iga Sapi Bening", 340, 24, 18, 20, 3, 450, 1.5, "local_indonesian"),
    ("Sop Iga Sapi Sayur", 360, 26, 20, 24, 3, 480, 2.5, "local_indonesian"),
    ("Sop Buntut Bening", 350, 24, 18, 22, 3, 480, 1.5, "local_indonesian"),
    ("Sop Buntut Sayur", 370, 26, 20, 26, 3, 500, 2.5, "local_indonesian"),
    ("Sop Kaki Kambing", 340, 22, 22, 14, 3, 500, 1.0, "local_indonesian"),
    ("Sop Daging Sapi Bening", 320, 26, 16, 18, 3, 450, 1.5, "local_indonesian"),
    ("Sop Daging Sapi Sayur", 340, 28, 18, 20, 3, 480, 2.5, "local_indonesian"),
    ("Sop Bakso Sapi", 280, 14, 12, 28, 3, 550, 1.5, "local_indonesian"),
    ("Sop Bakso Ayam", 260, 14, 10, 28, 3, 500, 1.5, "local_indonesian"),
    ("Sop Pangsit", 250, 10, 10, 30, 2, 550, 1.5, "local_indonesian"),
    ("Sate Ayam Bakar", 250, 22, 12, 12, 2, 400, 0.5, "local_indonesian"),
    ("Sate Sapi Bakar", 280, 24, 16, 10, 2, 400, 0.5, "local_indonesian"),
    ("Sate Kambing Bakar", 290, 22, 20, 10, 2, 400, 0.5, "local_indonesian"),
    ("Sate Udang Bakar", 180, 16, 8, 10, 1.5, 350, 0.3, "local_indonesian"),
    ("Sate Cumi Bakar", 170, 14, 8, 10, 1, 380, 0.3, "local_indonesian"),
    ("Sate Kerang Bakar", 180, 14, 8, 12, 2, 400, 0.5, "local_indonesian"),
    ("Sate Usus", 220, 18, 14, 8, 1, 300, 0, "local_indonesian"),
    ("Sate Jantung Ayam", 200, 20, 10, 6, 1, 250, 0, "local_indonesian"),
    ("Sate Ginjal", 220, 22, 12, 6, 1, 280, 0, "local_indonesian"),
    ("Sate Jeroan", 230, 20, 14, 8, 1, 300, 0, "local_indonesian"),
]
sv = count
for name, cal, prot, fat, carbs, sug, sod, fib, ft in soto_sate:
    if add(name, cal, prot, fat, carbs, sug, sod, fib, ft, "gen-batch10"):
        count += 1
print(f"8. Soto/Sop/Sate: +{count - sv}")

# ================================================================
# 9. AYAM — MORE DEEP COMBOS
# ================================================================
ayam_adv = [
    ("Ayam Goreng Serundeng", 350, 26, 20, 14, 6, 450, 2.5, "local_indonesian"),
    ("Ayam Goreng Ketumbar", 330, 24, 18, 12, 1.5, 400, 0.5, "local_indonesian"),
    ("Ayam Goreng Bawang", 340, 26, 20, 10, 1.5, 420, 0.3, "local_indonesian"),
    ("Ayam Goreng Laos", 340, 24, 20, 12, 2, 420, 1.0, "local_indonesian"),
    ("Ayam Goreng Kunyit", 330, 24, 18, 12, 2, 400, 0.8, "local_indonesian"),
    ("Ayam Goreng Jahe", 330, 24, 18, 12, 2, 400, 0.5, "local_indonesian"),
    ("Ayam Goreng Tepung Sajiku", 400, 24, 24, 18, 1.5, 550, 0.5, "local_indonesian"),
    ("Ayam Goreng Tepung Kentucky", 420, 22, 26, 20, 1.5, 600, 0.5, "local_indonesian"),
    ("Ayam Bakar Kecap Manis", 310, 24, 14, 18, 10, 500, 0.5, "local_indonesian"),
    ("Ayam Bakar Bumbu Pedas", 300, 24, 14, 14, 3, 480, 0.5, "local_indonesian"),
    ("Ayam Bakar Sereh", 290, 24, 12, 12, 2, 400, 0.5, "local_indonesian"),
    ("Ayam Bakar Jahe", 290, 24, 12, 12, 2, 400, 0.5, "local_indonesian"),
    ("Ayam Panggang Bumbu Rempah", 310, 26, 16, 12, 2, 420, 0.5, "local_indonesian"),
    ("Ayam Panggang Lemon", 290, 26, 14, 10, 1.5, 380, 0.3, "local_indonesian"),
    ("Ayam Panggang Herbal", 300, 26, 14, 12, 2, 400, 0.8, "local_indonesian"),
    ("Ayam Ungkep", 270, 24, 14, 12, 2, 380, 0.5, "local_indonesian"),
    ("Ayam Ungkep Goreng", 350, 24, 22, 14, 2, 430, 0.5, "local_indonesian"),
    ("Ayam Ungkep Bakar", 300, 24, 16, 12, 2, 400, 0.5, "local_indonesian"),
    ("Ayam Kecap Inggris", 300, 24, 14, 16, 6, 550, 0.5, "local_indonesian"),
    ("Ayam Goreng Saus Inggris", 320, 24, 16, 16, 6, 500, 0.5, "local_indonesian"),
    ("Ayam Cah Sayur", 250, 24, 12, 12, 3, 450, 3.0, "local_indonesian"),
    ("Ayam Cah Jamur Kuping", 260, 24, 12, 14, 2, 420, 2.5, "local_indonesian"),
    ("Ayam Cah Paprika", 270, 24, 14, 14, 3, 430, 1.5, "local_indonesian"),
    ("Ayam Cah Brokoli", 270, 26, 14, 14, 2, 450, 3.0, "local_indonesian"),
]
sv = count
for name, cal, prot, fat, carbs, sug, sod, fib, ft in ayam_adv:
    if add(name, cal, prot, fat, carbs, sug, sod, fib, ft, "gen-batch10"):
        count += 1
print(f"9. Ayam advanced: +{count - sv}")

# ================================================================
# 10. SEAFOOD — MORE FISH SPECIES WITH MORE METHODS
# ================================================================
seafood_adv = [
    ("Ikan Kembung Bakar Rica", 200, 22, 10, 6, 1, 400, 0.3, "base_food"),
    ("Ikan Bandeng Bakar", 220, 18, 12, 8, 1, 380, 0.3, "base_food"),
    ("Ikan Patin Bakar", 230, 16, 14, 6, 1, 350, 0.3, "base_food"),
    ("Ikan Tongkol Bakar", 240, 20, 12, 8, 1, 420, 0.3, "base_food"),
    ("Ikan Kakap Goreng Tepung", 250, 18, 14, 14, 1, 350, 0.5, "base_food"),
    ("Ikan Kerapu Goreng Tepung", 240, 16, 12, 14, 1, 330, 0.5, "base_food"),
    ("Ikan Bawal Goreng Tepung", 260, 14, 16, 14, 1, 350, 0.5, "base_food"),
    ("Ikan Cakalang Goreng", 260, 22, 16, 8, 1, 380, 0, "base_food"),
    ("Ikan Tenggiri Goreng", 240, 22, 12, 8, 1, 350, 0, "base_food"),
    ("Ikan Baronang Goreng", 220, 18, 12, 8, 1, 330, 0, "base_food"),
    ("Ikan Ekor Kuning Goreng", 220, 18, 10, 8, 1, 330, 0, "base_food"),
    ("Ikan Selar Bakar", 210, 20, 12, 6, 1, 380, 0.3, "base_food"),
    ("Ikan Salmon Goreng", 280, 20, 16, 10, 1, 350, 0, "base_food"),
    ("Ikan Tuna Goreng", 240, 24, 10, 8, 1, 350, 0, "base_food"),
    ("Ikan Sarden Goreng", 260, 18, 16, 8, 1, 500, 0, "base_food"),
    ("Ikan Gabus Goreng", 200, 18, 8, 6, 1, 300, 0, "base_food"),
    ("Ikan Belut Goreng", 280, 14, 20, 10, 1, 350, 0.3, "base_food"),
    ("Ikan Manyung Goreng", 230, 18, 14, 8, 1, 380, 0, "base_food"),
    ("Kepiting Saus Tiram", 200, 18, 10, 12, 2, 480, 0.3, "base_food"),
    ("Kepiting Lada Hitam", 190, 18, 8, 10, 1, 400, 0.3, "base_food"),
    ("Kerang Hijau Rebus", 100, 14, 3, 6, 1, 300, 0, "base_food"),
    ("Kerang Dara Rebus", 95, 13, 2.5, 6, 1, 280, 0, "base_food"),
    ("Kerang Saus Tiram", 160, 14, 8, 10, 2, 480, 0.3, "base_food"),
    ("Rajungan Goreng Tepung", 220, 16, 14, 12, 1, 380, 0.3, "base_food"),
    ("Keong Sawah Rebus", 80, 14, 2, 4, 1, 250, 0, "base_food"),
    ("Keong Sawah Goreng", 150, 14, 8, 6, 1, 300, 0, "base_food"),
    ("Ikan Teri Goreng Tepung", 220, 18, 12, 14, 1, 500, 0.5, "base_food"),
    ("Ikan Teri Balado", 200, 18, 12, 8, 2, 550, 0.5, "base_food"),
    ("Ikan Teri Kacang", 250, 20, 16, 12, 3, 500, 2.0, "base_food"),
    ("Ikan Asin Jambal Goreng", 270, 20, 18, 8, 0.5, 1100, 0, "base_food"),
]
sv = count
for name, cal, prot, fat, carbs, sug, sod, fib, ft in seafood_adv:
    if add(name, cal, prot, fat, carbs, sug, sod, fib, ft, "gen-batch10"):
        count += 1
print(f"10. Seafood advanced: +{count - sv}")

# ================================================================
# 11. DAGING/KAMBING/BEBEK VARIANTS
# ================================================================
daging_adv = [
    ("Daging Sapi Lada Hitam Saus", 330, 26, 18, 14, 2, 480, 0.5, "base_food"),
    ("Daging Sapi Tumis Brokoli", 280, 26, 14, 14, 2, 420, 3.0, "base_food"),
    ("Daging Sapi Tumis Paprika", 290, 26, 16, 12, 3, 430, 1.5, "base_food"),
    ("Daging Sapi Cah Jamur", 280, 26, 14, 12, 2, 420, 2.0, "base_food"),
    ("Daging Sapi Tumis Buncis", 290, 26, 16, 14, 3, 430, 3.0, "base_food"),
    ("Daging Sapi Goreng Bawang", 350, 24, 24, 10, 1.5, 400, 0.3, "base_food"),
    ("Daging Sapi Goreng Lengkuas", 360, 24, 26, 10, 2, 420, 1.0, "base_food"),
    ("Daging Kambing Goreng", 330, 22, 24, 8, 1, 350, 0, "base_food"),
    ("Daging Kambing Kecap", 300, 22, 16, 16, 6, 500, 0, "base_food"),
    ("Daging Kambing Bumbu Bali", 310, 22, 18, 14, 4, 450, 0, "base_food"),
    ("Kambing Guling", 350, 24, 24, 8, 2, 420, 0, "base_food"),
    ("Bebek Goreng Bumbu", 350, 20, 24, 12, 2, 450, 0.5, "local_indonesian"),
    ("Bebek Goreng Kremes", 380, 20, 28, 14, 2, 480, 0.5, "local_indonesian"),
    ("Bebek Bakar", 280, 22, 16, 10, 2, 420, 0.3, "local_indonesian"),
    ("Bebek Bakar Madu", 300, 22, 16, 14, 8, 420, 0.3, "local_indonesian"),
    ("Bebek Panggang", 290, 22, 18, 10, 2, 400, 0.3, "local_indonesian"),
    ("Bebek Bumbu Rica", 310, 24, 18, 10, 2, 450, 0.5, "local_indonesian"),
    ("Bebek Bumbu Woku", 300, 24, 18, 10, 2, 430, 0.5, "local_indonesian"),
    ("Bebek Opor", 340, 20, 24, 12, 2, 420, 0.5, "local_indonesian"),
    ("Bebek Gulai", 350, 20, 26, 10, 2, 450, 0.5, "local_indonesian"),
]
sv = count
for name, cal, prot, fat, carbs, sug, sod, fib, ft in daging_adv:
    if add(name, cal, prot, fat, carbs, sug, sod, fib, ft, "gen-batch10"):
        count += 1
print(f"11. Daging/Bebek: +{count - sv}")

# ================================================================
# 12. NASI VARIANTS + LAUK COMBOS
# ================================================================
nasi_ext = [
    ("Nasi Putih Telur Mata Sapi", 300, 10, 8, 46, 1, 100, 1.0, "local_indonesian"),
    ("Nasi Putih Telur Dadar", 320, 12, 12, 46, 1.5, 300, 0.5, "local_indonesian"),
    ("Nasi Putih Ayam Goreng", 450, 26, 20, 46, 1.5, 400, 0.5, "local_indonesian"),
    ("Nasi Putih Ayam Bakar", 400, 24, 14, 46, 2, 400, 0.5, "local_indonesian"),
    ("Nasi Putih Ikan Goreng", 400, 20, 16, 46, 1.5, 380, 0.5, "local_indonesian"),
    ("Nasi Putih Tahu Goreng", 350, 12, 14, 46, 1.5, 250, 1.0, "local_indonesian"),
    ("Nasi Putih Tempe Goreng", 380, 16, 16, 46, 1.5, 250, 2.5, "local_indonesian"),
    ("Nasi Putih Telur Balado", 320, 12, 14, 48, 3, 350, 0.5, "local_indonesian"),
    ("Nasi Putih Ayam Kecap", 420, 26, 16, 50, 5, 600, 0.5, "local_indonesian"),
    ("Nasi Putih Ayam Bumbu Bali", 430, 26, 18, 48, 3, 500, 0.5, "local_indonesian"),
    ("Nasi Merah Ayam Bakar", 400, 24, 12, 56, 2, 350, 3.0, "local_indonesian"),
    ("Nasi Merah Ikan Bakar", 380, 20, 10, 56, 2, 320, 3.0, "local_indonesian"),
    ("Nasi Merah Tahu Goreng", 350, 12, 14, 50, 2, 200, 3.5, "local_indonesian"),
    ("Nasi Merah Tempe Goreng", 380, 16, 16, 50, 2, 200, 5.0, "local_indonesian"),
]
sv = count
for name, cal, prot, fat, carbs, sug, sod, fib, ft in nasi_ext:
    if add(name, cal, prot, fat, carbs, sug, sod, fib, ft, "gen-batch10"):
        count += 1
print(f"12. Nasi variants: +{count - sv}")

# ================================================================
# 13. SAYUR — EVEN MORE COMBOS
# ================================================================
sayur_ext2 = [
    ("Oseng Tempe Kacang Panjang", 180, 12, 10, 16, 3, 250, 3.5, "local_indonesian"),
    ("Oseng Tahu Kacang Panjang", 160, 8, 10, 14, 3, 250, 3.0, "local_indonesian"),
    ("Oseng Tempe Buncis", 180, 12, 10, 16, 3, 250, 3.5, "local_indonesian"),
    ("Oseng Tahu Buncis", 160, 8, 10, 14, 3, 250, 3.0, "local_indonesian"),
    ("Oseng Tempe Tauge", 170, 12, 10, 14, 3, 250, 3.0, "local_indonesian"),
    ("Oseng Tahu Tauge", 150, 8, 10, 12, 3, 250, 2.5, "local_indonesian"),
    ("Oseng Kacang Panjang Tauge", 100, 5, 4, 14, 3, 150, 3.5, "local_indonesian"),
    ("Oseng Kangkung Tempe", 120, 8, 6, 12, 2, 250, 3.0, "local_indonesian"),
    ("Oseng Kangkung Tahu", 100, 6, 6, 10, 2, 250, 2.5, "local_indonesian"),
    ("Oseng Bayam Tahu", 90, 6, 4, 10, 2, 250, 2.5, "local_indonesian"),
    ("Oseng Sawi Tahu", 80, 5, 4, 10, 2, 250, 2.5, "local_indonesian"),
    ("Tumis Jamur Tiram", 100, 4, 5, 10, 2, 250, 3.0, "base_food"),
    ("Tumis Jamur Kancing", 90, 4, 5, 8, 2, 250, 2.5, "base_food"),
    ("Tumis Jamur Kuping", 80, 3, 4, 10, 2, 250, 3.0, "base_food"),
    ("Tumis Jamur Merang", 85, 3.5, 4.5, 9, 2, 250, 3.0, "base_food"),
    ("Tumis Jamur Shitake", 95, 4, 5, 10, 2, 250, 3.0, "base_food"),
    ("Tumis Jamur Enoki", 80, 3, 4, 8, 2, 200, 2.5, "base_food"),
    ("Sayur Bening Sawi Putih", 30, 2, 0.5, 6, 2, 200, 2.0, "base_food"),
    ("Sayur Bening Kacang Panjang", 40, 3, 0.5, 8, 2, 150, 3.0, "base_food"),
    ("Sayur Bening Daun Katuk", 50, 5, 1, 8, 2, 150, 3.5, "base_food"),
    ("Sayur Bening Sawi Hijau", 30, 2, 0.5, 5, 2, 180, 2.5, "base_food"),
    ("Sayur Bening Kubis", 35, 2, 0.5, 7, 3, 180, 3.0, "base_food"),
    ("Sayur Bening Brokoli", 40, 3, 1, 7, 2, 200, 3.0, "base_food"),
    ("Sayur Bening Wortel Kentang", 50, 3, 1, 10, 3, 200, 3.5, "base_food"),
    ("Sayur Asam Kampung", 100, 4, 3, 16, 3, 350, 3.5, "local_indonesian"),
    ("Sayur Asam Betawi", 110, 5, 4, 16, 3, 380, 3.5, "local_indonesian"),
    ("Sayur Asam Segar", 90, 3, 2, 14, 3, 300, 3.5, "base_food"),
    ("Sayur Lodeh Jakarta", 200, 8, 14, 18, 4, 450, 3.5, "local_indonesian"),
    ("Sayur Lodeh Sunda", 190, 8, 12, 18, 4, 420, 3.5, "local_indonesian"),
    ("Sayur Lodeh Jawa", 190, 8, 12, 18, 4, 430, 3.5, "local_indonesian"),
]
sv = count
for name, cal, prot, fat, carbs, sug, sod, fib, ft in sayur_ext2:
    if add(name, cal, prot, fat, carbs, sug, sod, fib, ft, "gen-batch10"):
        count += 1
print(f"13. Sayur ext 2: +{count - sv}")

# ================================================================
# 14. MIE / PASTA / NOODLE VARIANTS
# ================================================================
mie_ext = [
    ("Mie Ayam Pangsit", 460, 16, 16, 56, 3, 700, 2.0, "local_indonesian"),
    ("Mie Ayam Ceker Komplit", 460, 18, 16, 56, 3, 700, 2.0, "local_indonesian"),
    ("Mie Ayam Bakso Komplit", 470, 18, 18, 54, 3, 750, 2.0, "local_indonesian"),
    ("Mie Ayam Spesial Komplit", 480, 20, 18, 56, 3, 720, 2.0, "local_indonesian"),
    ("Mie Goreng Telur", 500, 16, 24, 52, 4, 900, 2.0, "local_indonesian"),
    ("Mie Goreng Ayam", 500, 18, 24, 50, 3, 850, 1.5, "local_indonesian"),
    ("Mie Goreng Sapi", 510, 20, 24, 50, 3, 850, 1.5, "local_indonesian"),
    ("Mie Goreng Udang", 490, 18, 22, 50, 3, 880, 1.0, "local_indonesian"),
    ("Mie Goreng Sayur", 440, 10, 20, 52, 3, 750, 3.5, "local_indonesian"),
    ("Mie Rebus Telur", 450, 14, 18, 52, 3, 800, 1.5, "local_indonesian"),
    ("Mie Rebus Ayam", 450, 16, 18, 50, 3, 750, 1.5, "local_indonesian"),
    ("Mie Rebus Sapi", 460, 18, 18, 50, 3, 750, 1.5, "local_indonesian"),
    ("Mie Rebus Sayur", 400, 8, 14, 52, 3, 650, 3.5, "local_indonesian"),
    ("Kwetiau Goreng Telur", 480, 12, 22, 52, 3, 850, 1.5, "local_indonesian"),
    ("Kwetiau Goreng Sapi", 500, 18, 24, 50, 3, 880, 1.5, "local_indonesian"),
    ("Bihun Goreng Telur", 420, 10, 18, 50, 2, 700, 1.5, "local_indonesian"),
    ("Bihun Goreng Ayam", 440, 14, 18, 50, 2, 720, 1.5, "local_indonesian"),
    ("Bihun Rebus Ayam", 380, 12, 14, 50, 2, 650, 1.5, "local_indonesian"),
    ("Soun Goreng", 380, 6, 16, 50, 2, 600, 1.0, "local_indonesian"),
    ("Soun Rebus", 320, 4, 10, 50, 2, 550, 1.0, "local_indonesian"),
]
sv = count
for name, cal, prot, fat, carbs, sug, sod, fib, ft in mie_ext:
    if add(name, cal, prot, fat, carbs, sug, sod, fib, ft, "gen-batch10"):
        count += 1
print(f"14. Mie/Noodles: +{count - sv}")

# ================================================================
# 15. DIET / HEALTHY
# ================================================================
diet_ext = [
    ("Salad Buah Segar", 120, 1, 2, 28, 22, 20, 3.0, "base_food"),
    ("Salad Buah Yogurt", 140, 3, 3, 28, 22, 40, 3.0, "base_food"),
    ("Salad Buah Madu", 130, 1, 2, 30, 26, 20, 3.0, "base_food"),
    ("Salad Sayur Dressing Lemon", 80, 3, 2, 12, 3, 150, 4.0, "base_food"),
    ("Salad Sayur Dressing Yogurt", 100, 5, 3, 14, 4, 180, 4.0, "base_food"),
    ("Salad Sayur Dressing Minyak Zaitun", 90, 3, 5, 12, 3, 150, 4.0, "base_food"),
    ("Salad Sayur Dressing Balsamic", 80, 3, 3, 12, 3, 150, 4.0, "base_food"),
    ("Smoothie Pisang Stroberi", 120, 3, 2, 24, 16, 30, 2.5, "beverage"),
    ("Smoothie Pisang Coklat", 160, 4, 4, 28, 18, 40, 2.5, "beverage"),
    ("Smoothie Pisang Alpukat", 180, 3, 10, 22, 12, 30, 5.0, "beverage"),
    ("Smoothie Mangga Yogurt", 120, 3, 2, 24, 20, 40, 1.5, "beverage"),
    ("Smoothie Nanas Mint", 70, 1, 0.5, 16, 12, 10, 1.5, "beverage"),
    ("Smoothie Pepaya Jeruk", 80, 1, 0.5, 20, 14, 15, 2.5, "beverage"),
    ("Smoothie Alpukat Coklat", 200, 4, 12, 22, 14, 40, 5.5, "beverage"),
    ("Smoothie Stroberi Yogurt", 100, 3, 2, 18, 14, 40, 2.0, "beverage"),
    ("Smoothie Berry Mix", 90, 2, 1, 18, 14, 20, 3.0, "beverage"),
    ("Smoothie Sayur Hijau", 60, 3, 1, 10, 3, 100, 3.5, "beverage"),
    ("Oatmeal Pisang", 220, 6, 5, 40, 10, 50, 4.0, "base_food"),
    ("Oatmeal Stroberi", 200, 5, 5, 36, 8, 50, 4.5, "base_food"),
    ("Oatmeal Blueberry", 200, 5, 5, 36, 8, 50, 4.5, "base_food"),
    ("Oatmeal Coklat", 240, 7, 7, 38, 10, 60, 4.0, "base_food"),
    ("Oatmeal Kurma", 260, 7, 5, 46, 22, 50, 5.5, "base_food"),
    ("Granola Yogurt", 250, 8, 10, 34, 16, 60, 4.0, "base_food"),
    ("Granola Susu", 260, 8, 10, 36, 18, 60, 4.0, "base_food"),
    ("Roti Gandum Telur Rebus", 280, 14, 10, 34, 3, 350, 3.5, "base_food"),
    ("Roti Gandum Alpukat", 250, 5, 12, 32, 3, 250, 5.5, "base_food"),
    ("Roti Gandum Selai Kacang", 280, 10, 14, 32, 6, 250, 3.5, "base_food"),
    ("Roti Gandum Ikan Tuna", 260, 18, 8, 32, 3, 400, 3.0, "base_food"),
    ("Sup Ayam Sayur Diet", 150, 20, 3, 12, 3, 350, 3.5, "base_food"),
    ("Sup Ikan Diet", 140, 20, 3, 10, 2, 320, 2.5, "base_food"),
    ("Sup Tahu Diet", 100, 10, 4, 10, 2, 300, 2.0, "base_food"),
    ("Sup Jamur Diet", 80, 4, 2, 10, 2, 280, 3.0, "base_food"),
]
sv = count
for name, cal, prot, fat, carbs, sug, sod, fib, ft in diet_ext:
    if add(name, cal, prot, fat, carbs, sug, sod, fib, ft, "gen-batch10"):
        count += 1
print(f"15. Diet/Healthy: +{count - sv}")

# Merge and save
df_new = pd.DataFrame(new)
df_all = pd.concat([df, df_new], ignore_index=True)
df_all.to_csv(FINAL_OUTPUT, index=False)

print(f"\nBatch 10 Part 2 generated: {len(new)} new foods")
print(f"Running total: {len(df_all)} foods")
print(df_all["food_type"].value_counts())
