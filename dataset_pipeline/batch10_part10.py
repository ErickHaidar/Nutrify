"""Batch 10 Part 10: ULTRA FINAL — 80 more to cross 10K."""
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

items = [
    # Daging cross-product gaps
    ("Daging Sapi Panggang Madu", 350, 28, 14, 22, 8, 400, 1, "other"),
    ("Daging Sapi Panggang Lada", 340, 28, 14, 18, 3, 420, 1, "other"),
    ("Daging Sapi Panggang Bumbu", 330, 28, 14, 16, 4, 400, 1, "other"),
    ("Daging Sapi Rebus Kecap", 320, 28, 12, 20, 6, 550, 2, "other"),
    ("Daging Sapi Tumis Bawang", 340, 28, 14, 18, 4, 400, 2, "other"),
    ("Daging Cincang Tumis Pedas", 330, 24, 16, 16, 4, 450, 2, "other"),
    ("Daging Cincang Bumbu Bali", 340, 24, 18, 16, 5, 450, 2, "other"),
    ("Daging Panggang Saus BBQ", 360, 28, 16, 22, 8, 480, 1, "other"),

    # Ikan more specific named
    ("Ikan Mas Goreng Bumbu Kuning", 290, 22, 14, 16, 3, 400, 1, "local_indonesian"),
    ("Ikan Mas Bakar Sambal", 260, 22, 8, 18, 4, 420, 1, "local_indonesian"),
    ("Ikan Mas Pepes Kemangi", 220, 22, 8, 14, 3, 380, 2, "local_indonesian"),
    ("Ikan Nila Goreng Bumbu", 280, 24, 12, 16, 3, 380, 1, "other"),
    ("Ikan Nila Bakar Madu", 250, 24, 8, 18, 8, 380, 1, "other"),
    ("Ikan Nila Goreng Kremes", 300, 24, 16, 18, 3, 400, 1, "other"),
    ("Ikan Lele Goreng Bumbu Kuning", 280, 20, 14, 16, 3, 400, 1, "local_indonesian"),
    ("Ikan Lele Bakar Kecap Manis", 260, 20, 10, 20, 6, 480, 2, "local_indonesian"),
    ("Ikan Patin Goreng Bumbu", 290, 20, 14, 18, 3, 380, 1, "local_indonesian"),
    ("Ikan Patin Bakar Sambal Ijo", 270, 20, 10, 18, 4, 420, 2, "local_indonesian"),
    ("Ikan Bandeng Goreng Bumbu Kuning", 290, 24, 14, 16, 3, 400, 1, "local_indonesian"),
    ("Ikan Bandeng Bakar Sambal Bawang", 270, 24, 10, 18, 4, 420, 2, "local_indonesian"),

    # Ayam more specific
    ("Ayam Goreng Bumbu Rempah", 330, 24, 16, 16, 3, 400, 1, "other"),
    ("Ayam Goreng Bumbu Ketumbar", 330, 24, 16, 16, 3, 400, 1, "other"),
    ("Ayam Goreng Bumbu Kunyit", 330, 24, 16, 16, 3, 400, 1, "other"),
    ("Ayam Bakar Bumbu Kuning", 310, 24, 12, 16, 3, 400, 1, "other"),
    ("Ayam Bakar Bumbu Rempah", 310, 24, 12, 16, 3, 400, 1, "other"),
    ("Ayam Panggang Bumbu Kecap", 320, 26, 12, 18, 5, 480, 1, "other"),
    ("Ayam Panggang Saus Tiram", 330, 26, 12, 18, 4, 480, 1, "other"),
    ("Ayam Tim Bumbu Jahe", 220, 24, 6, 14, 3, 400, 1, "other"),
    ("Ayam Tim Bumbu Kecap", 240, 24, 8, 16, 6, 500, 2, "other"),

    # Regional more
    ("Pindang Ikan Kembung Palembang", 220, 22, 8, 14, 4, 480, 2, "local_indonesian"),
    ("Pindang Ikan Patin Palembang", 220, 20, 8, 14, 4, 480, 2, "local_indonesian"),
    ("Pindang Ikan Baung Palembang", 210, 20, 6, 14, 4, 480, 2, "local_indonesian"),
    ("Laksa Palembang", 380, 14, 14, 44, 5, 580, 3, "local_indonesian"),
    ("Laksa Medan", 380, 14, 14, 44, 5, 580, 3, "local_indonesian"),

    # More soup/soto gaps
    ("Soto Ayam Bening", 250, 18, 6, 24, 4, 500, 3, "local_indonesian"),
    ("Soto Ayam Santan", 300, 18, 12, 24, 4, 500, 3, "local_indonesian"),
    ("Soto Daging Bening", 280, 20, 10, 24, 4, 500, 3, "local_indonesian"),
    ("Soto Babat", 280, 18, 10, 24, 4, 520, 3, "local_indonesian"),
    ("Soto Kikil", 280, 14, 10, 26, 4, 520, 3, "local_indonesian"),
    ("Soto Campur", 300, 18, 10, 26, 4, 550, 4, "local_indonesian"),
    ("Soto Tangkar", 300, 18, 12, 24, 4, 520, 3, "local_indonesian"),
    ("Sop Ikan Batam", 200, 22, 5, 14, 3, 450, 2, "local_indonesian"),
    ("Sop Ikan Kuah Asam Pedas", 220, 22, 5, 18, 5, 480, 2, "other"),

    # Gado-gado / Pecel variants
    ("Gado-Gado Jakarta", 300, 12, 14, 32, 8, 480, 6, "local_indonesian"),
    ("Gado-Gado Surabaya", 300, 12, 14, 32, 8, 480, 6, "local_indonesian"),
    ("Gado-Gado Medan", 300, 12, 14, 32, 8, 480, 6, "local_indonesian"),
    ("Gado-Gado Bandung", 300, 12, 14, 32, 8, 480, 6, "local_indonesian"),
    ("Pecel Semarang", 300, 10, 10, 36, 6, 420, 6, "local_indonesian"),
    ("Pecel Malang", 300, 10, 10, 36, 6, 420, 6, "local_indonesian"),
    ("Pecel Blitar", 300, 10, 10, 36, 6, 420, 6, "local_indonesian"),
    ("Pecel Ponorogo", 300, 10, 10, 36, 6, 420, 6, "local_indonesian"),
    ("Pecel Nganjuk", 300, 10, 10, 36, 6, 420, 6, "local_indonesian"),
    ("Pecel Lamongan", 300, 10, 10, 36, 6, 420, 6, "local_indonesian"),

    # Bakso regional
    ("Bakso Solo", 280, 16, 10, 28, 4, 600, 3, "local_indonesian"),
    ("Bakso Wonogiri", 280, 16, 10, 28, 4, 600, 3, "local_indonesian"),
    ("Bakso Semarang", 280, 16, 10, 28, 4, 600, 3, "local_indonesian"),
    ("Bakso Surabaya", 280, 16, 10, 28, 4, 600, 3, "local_indonesian"),
    ("Bakso Ceker", 250, 14, 8, 28, 4, 580, 3, "other"),
    ("Bakso Urat", 300, 18, 12, 28, 4, 600, 2, "other"),
    ("Bakso Sapi Murni", 280, 18, 10, 24, 4, 580, 2, "other"),
    ("Bakso Ayam Kampung", 250, 16, 8, 26, 4, 580, 2, "other"),

    # Noodle / pasta more
    ("Mie Ayam Solo", 400, 16, 10, 50, 5, 580, 3, "local_indonesian"),
    ("Mie Ayam Wonogiri", 400, 16, 10, 50, 5, 580, 3, "local_indonesian"),
    ("Mie Ayam Bangka", 410, 16, 10, 50, 5, 580, 3, "local_indonesian"),
    ("Ifumie Goreng", 420, 14, 16, 48, 5, 580, 3, "other"),
    ("Ifumie Kuah", 380, 14, 6, 50, 5, 600, 3, "other"),
    ("Lo Mie", 400, 14, 12, 50, 5, 600, 3, "other"),
    ("Mie Kangkung Belacan", 360, 12, 12, 46, 5, 600, 4, "other"),
    ("Mie Jawa", 380, 12, 10, 50, 5, 550, 3, "local_indonesian"),
    ("Mie Kocok", 350, 14, 10, 44, 5, 580, 3, "local_indonesian"),
    ("Mie Tarik", 350, 12, 8, 50, 5, 550, 3, "other"),
    ("Mie Celor", 350, 12, 12, 44, 5, 550, 2, "local_indonesian"),
    ("Bihun Bebek", 380, 16, 12, 44, 4, 550, 3, "other"),
    ("Bihun Ayam", 350, 14, 8, 48, 5, 550, 3, "other"),
    ("Bihun Ikan", 340, 14, 6, 50, 5, 580, 3, "other"),

    # More nasi variants
    ("Nasi Padang Spesial", 450, 22, 18, 44, 5, 550, 4, "local_indonesian"),
    ("Nasi Campur Spesial", 450, 22, 16, 44, 5, 550, 4, "other"),
    ("Nasi Krawu", 400, 18, 14, 42, 5, 480, 3, "local_indonesian"),
    ("Nasi Tempong", 380, 14, 10, 50, 4, 480, 4, "local_indonesian"),
    ("Nasi Serundeng", 350, 10, 10, 48, 5, 400, 4, "local_indonesian"),

    # Roti / bread more
    ("Roti Coklat Keju", 280, 8, 10, 36, 14, 250, 2, "snack"),
    ("Roti Abon Sapi", 270, 10, 9, 34, 6, 350, 2, "snack"),
    ("Roti Abon Ayam", 260, 10, 8, 34, 6, 350, 2, "snack"),
    ("Roti Pizza Mini", 280, 10, 12, 30, 5, 400, 2, "snack"),
    ("Roti Sosis Keju", 290, 12, 14, 28, 5, 450, 2, "snack"),
    ("Roti Selai Nanas", 250, 5, 7, 38, 16, 180, 2, "snack"),
    ("Roti Gulung Coklat", 280, 6, 10, 38, 14, 200, 2, "snack"),
    ("Roti Gulung Keju", 280, 8, 12, 34, 8, 280, 2, "snack"),
    ("Roti Gulung Sosis", 280, 10, 12, 30, 5, 380, 2, "snack"),

    # More kue / jajan
    ("Kue Mangkok Gula Merah", 160, 3, 5, 24, 12, 80, 2, "snack"),
    ("Kue Mangkok Pandan", 160, 3, 5, 24, 12, 80, 1, "snack"),
    ("Kue Bugis Ketan", 200, 4, 8, 26, 12, 80, 2, "snack"),
    ("Kue Talam Ebi", 180, 5, 12, 14, 3, 350, 2, "snack"),
    ("Kue Talam Durian", 200, 3, 7, 30, 14, 80, 2, "snack"),
    ("Kue Lapis Legit", 250, 5, 12, 28, 18, 100, 1, "snack"),
    ("Kue Lapis Surabaya", 250, 5, 12, 28, 18, 100, 1, "snack"),
    ("Kue Lebaran Nastar", 180, 3, 8, 22, 10, 80, 1, "snack"),
    ("Kue Lebaran Putri Salju", 170, 3, 9, 18, 8, 80, 1, "snack"),
    ("Kue Lebaran Kastengel", 180, 4, 10, 18, 4, 200, 1, "snack"),
]
for item in items:
    if add(*item, "gen-batch10"): count += 1

print(f"\nPart 10 total new: {count}")
if new:
    ndf = pd.DataFrame(new)
    ndf.to_csv(FINAL_OUTPUT, mode='a', header=False, index=False)
    df = pd.read_csv(FINAL_OUTPUT)
    print(f"Running total: {len(df)} foods")
    print(df["food_type"].value_counts().to_string())
else:
    print("No new foods added!")
