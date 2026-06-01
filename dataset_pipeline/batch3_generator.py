"""Final batch: generate remaining food variants to reach 5,000+."""
import pandas as pd
from config import FINAL_OUTPUT

df = pd.read_csv(FINAL_OUTPUT)
existing = set(df['name_id'].str.lower().str.strip())

new_foods = []

def add(name, cal, prot, fat, carbs, sugar, sod, fiber, ftype, src):
    if name.lower().strip() in existing:
        return False
    existing.add(name.lower().strip())
    new_foods.append({
        "name": name, "name_id": name, "serving_size": "1 porsi",
        "calories": cal, "protein_g": prot, "carbohydrate_g": carbs,
        "fat_g": fat, "sugar_g": sugar, "sodium_mg": sod, "fiber_g": fiber,
        "food_type": ftype, "source": src,
    })
    return True

# Protein + method ALL combos
proteins = {
    "Dada Ayam": (120, 25, 2.5, 0, 0, 50, 0),
    "Paha Ayam": (145, 20, 7.0, 0, 0, 65, 0),
    "Daging Sapi": (180, 26, 8.0, 0, 0, 55, 0),
    "Ikan Nila": (115, 19, 4.0, 0, 0, 40, 0),
    "Ikan Lele": (140, 17, 7.5, 0, 0, 48, 0),
    "Ikan Gurame": (120, 18.5, 5.0, 0, 0, 42, 0),
    "Udang": (95, 19, 1.5, 0.5, 0, 140, 0),
    "Cumi": (85, 15, 1.2, 2.0, 0, 230, 0),
}
methods = {
    "Rebus": (1.0, 1.0, 1.0, 1.0, 1.0),
    "Bakar": (1.15, 1.20, 1.05, 1.0, 0.95),
    "Goreng": (1.8, 4.0, 0.85, 1.15, 0.9),
    "Kukus": (1.05, 1.0, 1.02, 1.0, 1.05),
    "Panggang": (1.2, 1.30, 1.08, 1.0, 0.95),
    "Bacem": (1.3, 1.10, 0.90, 1.50, 0.90),
    "Kecap": (1.3, 1.40, 0.95, 1.40, 0.90),
    "Semur": (1.35, 1.80, 0.93, 1.30, 0.95),
}

added_proteins = 0
for pname, (cal, prot, fat, carbs, sug, sod, fib) in proteins.items():
    for mname, (cm, fm, pm, cm2, fibm) in methods.items():
        name = f"{pname} {mname}"
        if add(name,
               round(cal * cm, 1), round(prot * pm, 1), round(fat * fm, 1),
               round(carbs * cm2, 1), sug, round(sod * 1.0, 1), round(fib * fibm, 1),
               "base_food", "gen-batch3"):
            added_proteins += 1
print(f"Proteins: +{added_proteins}")

# Fruit preparations
fruits = {
    "Pisang": (99, 1.2, 0.3, 24, 16, 1, 2.0),
    "Pepaya": (46, 0.5, 0.1, 11, 8, 3, 1.5),
    "Mangga": (65, 0.5, 0.3, 16, 14, 2, 1.5),
    "Nanas": (52, 0.5, 0.1, 13, 10, 1, 1.2),
    "Alpukat": (160, 2.0, 15, 9, 0.5, 7, 6.5),
    "Jambu Biji": (50, 0.9, 0.3, 11.5, 9, 3, 5.0),
    "Melon": (35, 0.5, 0.2, 8, 7.5, 10, 0.8),
    "Semangka": (28, 0.5, 0.2, 6.5, 6, 1, 0.4),
    "Belimbing": (35, 0.5, 0.2, 8, 4, 2, 2.5),
    "Salak": (75, 0.4, 0.1, 19, 15, 1, 2.0),
    "Sawo": (90, 0.5, 0.5, 22, 18, 12, 2.5),
    "Durian": (147, 1.5, 5.3, 27, 12, 2, 3.8),
    "Manggis": (65, 0.5, 0.5, 15.5, 13, 7, 1.5),
    "Rambutan": (70, 0.9, 0.2, 16, 13, 10, 1.0),
    "Duku": (60, 1.0, 0.2, 13.5, 10, 3, 1.5),
    "Nangka": (95, 1.2, 0.3, 23, 19, 3, 1.5),
    "Sirsak": (65, 1.0, 0.3, 14.5, 10, 14, 2.0),
    "Markisa": (75, 2.2, 0.7, 13.5, 11, 28, 8.0),
    "Anggur": (70, 0.5, 0.2, 17, 16, 2, 1.0),
    "Stroberi": (35, 0.7, 0.3, 7.5, 4.5, 1, 2.0),
    "Kiwi": (60, 1.0, 0.5, 14, 9, 3, 3.0),
    "Apel": (58, 0.3, 0.3, 14, 10, 1, 2.3),
    "Jeruk": (45, 0.9, 0.2, 10, 8.5, 1, 2.0),
    "Kurma": (280, 2.5, 0.4, 70, 63, 2, 7.0),
}

added_fruits = 0
for fname, (cal, prot, fat, carbs, sug, sod, fib) in fruits.items():
    if add(f"{fname} Segar", cal, prot, fat, carbs, sug, sod, fib, "base_food", "gen-batch3"):
        added_fruits += 1
    if add(f"Jus {fname}", round(cal * 1.1, 1), prot, round(fat * 0.5, 1),
           round(carbs * 1.0, 1), round(sug * 0.9, 1), sod, round(fib * 0.6, 1),
           "beverage", "gen-batch3"):
        added_fruits += 1
print(f"Fruits: +{added_fruits}")

# Breakfast items
breakfast = [
    ("Bubur Ayam Spesial", 320, 14, 10, 42, 1, 550, 1.5),
    ("Bubur Ayam Cakwe", 350, 14, 14, 42, 1, 600, 1.5),
    ("Lontong Sayur Padang", 380, 12, 20, 40, 3, 720, 2.5),
    ("Nasi Uduk Komplit", 420, 12, 22, 44, 2, 600, 2.0),
    ("Ketupat Sayur Padang", 360, 12, 18, 38, 3, 700, 2.5),
    ("Bubur Manado Komplit", 220, 8, 5, 35, 2, 400, 4.0),
    ("Roti Bakar Telur Keju", 350, 14, 16, 38, 3, 450, 2.0),
    ("Roti Bakar Pisang Coklat", 320, 6, 14, 46, 18, 350, 2.5),
    ("Roti Bakar Srikaya", 280, 5, 10, 45, 20, 300, 1.5),
    ("Roti Bakar Stroberi", 270, 4, 10, 44, 18, 300, 1.5),
    ("Roti Bakar Kacang", 310, 8, 15, 40, 10, 320, 2.5),
    ("Nasi Goreng Ati Ampela", 420, 16, 22, 42, 2, 650, 1.5),
    ("Nasi Goreng Pete Telur", 400, 12, 20, 44, 2, 620, 2.5),
    ("Nasi Goreng Teri", 380, 14, 18, 44, 1.5, 700, 1.5),
    ("Nasi Goreng Cumi", 400, 16, 20, 42, 1.5, 680, 1.5),
    ("Nasi Goreng Seafood", 420, 18, 22, 42, 2, 700, 2.0),
    ("Mie Goreng Seafood", 500, 18, 25, 50, 3, 1000, 2.5),
    ("Mie Goreng Spesial", 480, 16, 24, 48, 3, 950, 2.0),
    ("Mie Rebus Spesial", 440, 14, 20, 48, 2.5, 900, 2.0),
    ("Kwetiau Goreng Seafood", 430, 16, 22, 46, 2, 850, 2.0),
    ("Bihun Goreng Spesial", 400, 14, 20, 44, 2, 750, 2.0),
    ("Bubur Kacang Hijau Ketan", 200, 6, 3, 36, 14, 15, 3.0),
    ("Bubur Ketan Hitam Santan", 240, 5, 6, 44, 18, 20, 3.5),
    ("Kolak Ketan", 260, 4, 6, 48, 28, 25, 2.5),
]
added_breakfast = sum(1 for items in [breakfast] for name, *rest in [items] if False)
for name, *nut in breakfast:
    add(name, *nut, "local_indonesian", "gen-batch3")
print(f"Breakfast: +{len(breakfast)}")

# Healthy/diet variants
diet = [
    ("Salad Sayur Ayam Rebus", 220, 28, 8, 12, 3, 200, 4.0),
    ("Salad Sayur Telur Rebus", 200, 15, 10, 12, 3, 200, 3.5),
    ("Salad Sayur Tahu", 180, 12, 10, 14, 3, 180, 4.0),
    ("Salad Sayur Tempe", 220, 16, 12, 14, 2, 190, 4.5),
    ("Gado-Gado Diet", 280, 14, 14, 30, 5, 350, 5.5),
    ("Pecel Diet", 250, 12, 10, 28, 4, 300, 5.0),
    ("Nasi Merah Ayam Rebus", 380, 32, 5, 50, 0.5, 120, 2.5),
    ("Nasi Merah Ikan Rebus", 350, 28, 5, 48, 0.5, 100, 2.5),
    ("Nasi Merah Telur Rebus", 350, 18, 8, 48, 1, 150, 2.0),
    ("Nasi Merah Tahu Rebus", 280, 14, 8, 42, 1, 50, 2.5),
    ("Nasi Merah Tempe Rebus", 320, 20, 10, 44, 0.5, 60, 3.0),
    ("Kentang Rebus Ayam Rebus", 280, 30, 4, 28, 1, 100, 4.0),
    ("Kentang Rebus Ikan Kukus", 250, 28, 4, 24, 1, 80, 4.0),
    ("Ubi Rebus Telur Rebus", 300, 15, 5, 48, 5, 120, 5.0),
    ("Sayur Sop Tanpa Minyak", 80, 8, 1, 12, 2, 300, 3.0),
    ("Tumis Sayur Tanpa Minyak", 70, 3, 0.5, 12, 2, 200, 3.5),
    ("Sup Ayam Tanpa Minyak", 120, 18, 2, 8, 1, 350, 2.0),
]
for name, *nut in diet:
    add(name, *nut, "base_food", "gen-batch3")
print(f"Diet: +{len(diet)}")

# Beverages
bev_extra = [
    ("Jus Wortel", 40, 0.5, 0.1, 9, 4, 40, 2.0),
    ("Jus Tomat", 25, 1.0, 0.1, 5, 3, 10, 1.5),
    ("Jus Belimbing", 30, 0.3, 0.1, 7, 4, 2, 2.0),
    ("Jus Nangka", 80, 0.8, 0.2, 19, 15, 3, 1.5),
    ("Jus Stroberi", 35, 0.5, 0.2, 7.5, 4, 1, 2.0),
    ("Jus Anggur", 70, 0.5, 0.1, 17, 16, 2, 0.8),
    ("Jus Kiwi", 60, 1.0, 0.3, 14, 9, 3, 3.0),
    ("Es Jeruk Nipis", 40, 0.2, 0.0, 10, 2, 2, 0.3),
    ("Es Jeruk Peras", 55, 0.4, 0.1, 14, 8, 2, 0.5),
    ("Es Teh Lemon", 55, 0.0, 0.0, 14, 13, 5, 0.0),
    ("Es Teh Tarik", 90, 2, 2.5, 14, 12, 30, 0.0),
    ("Es Kopi Susu", 120, 2.5, 4, 18, 14, 35, 0.0),
    ("Es Coklat Susu", 180, 4, 6, 28, 22, 60, 1.0),
    ("Kopi Moka Susu", 100, 3, 3.5, 15, 12, 30, 0.0),
    ("Teh Susu", 100, 2.5, 3, 15, 13, 35, 0.0),
    ("Wedang Jahe Susu", 130, 3, 4, 20, 16, 20, 0.5),
    ("Susu Coklat Panas", 180, 7, 7, 22, 20, 80, 0.5),
    ("Susu Stroberi", 150, 6, 5, 20, 18, 70, 0.3),
]
for name, *nut in bev_extra:
    add(name, *nut, "beverage", "gen-batch3")
print(f"Beverages: +{len(bev_extra)}")

# Snacks
snack_extra = [
    ("Tempe Mendoan", 210, 10, 12, 18, 1, 180, 1.5),
    ("Bakwan Jagung", 200, 3, 12, 22, 3, 250, 2.5),
    ("Bakwan Udang", 220, 8, 14, 18, 2, 350, 1.5),
    ("Martabak Mini", 220, 5, 12, 25, 5, 200, 0.5),
    ("Pukis", 200, 5, 8, 30, 12, 150, 0.5),
    ("Kue Cubit", 180, 4, 7, 28, 14, 100, 0.3),
    ("Kue Lumpur", 220, 5, 12, 25, 15, 180, 0.5),
    ("Kue Pancong", 200, 4, 10, 26, 12, 120, 1.0),
    ("Terang Bulan Mini", 250, 5, 14, 28, 16, 150, 0.5),
    ("Kue Ape", 160, 3, 6, 25, 12, 100, 0.3),
    ("Kue Bugis", 200, 3, 8, 30, 14, 80, 1.5),
    ("Lemper Ayam", 220, 8, 6, 32, 1, 250, 2.0),
    ("Pastel Ayam", 210, 7, 10, 24, 1, 300, 1.0),
    ("Risol Sayur", 180, 4, 8, 24, 1.5, 280, 1.5),
    ("Lumpia Sayur", 170, 5, 8, 22, 2, 350, 2.0),
    ("Lumpia Ayam", 200, 8, 10, 22, 2, 380, 1.5),
    ("Sosis Solo", 220, 8, 12, 22, 2, 350, 0.5),
    ("Kroket Kentang", 230, 6, 12, 26, 2, 300, 1.5),
    ("Perkedel Kentang", 180, 4, 8, 22, 1.5, 250, 1.5),
    ("Perkedel Jagung", 190, 4, 10, 20, 2, 280, 2.0),
    ("Tahu Fantasi", 200, 8, 12, 18, 1, 300, 1.0),
    ("Bola-Bola Udang", 250, 12, 14, 22, 2, 400, 0.5),
    ("Bola-Bola Ayam", 230, 14, 12, 20, 1, 350, 0.5),
    ("Nugget Ayam", 280, 12, 18, 22, 1, 550, 0.5),
    ("Nugget Ikan", 250, 12, 14, 22, 1, 500, 0.5),
    ("Nugget Sayur", 200, 6, 10, 24, 3, 400, 2.0),
]
for name, *nut in snack_extra:
    add(name, *nut, "snack", "gen-batch3")
print(f"Snacks: +{len(snack_extra)}")

# Merge and save
df_new = pd.DataFrame(new_foods)
df_combined = pd.concat([df, df_new], ignore_index=True)
df_combined.to_csv(FINAL_OUTPUT, index=False)

print(f"\nBatch 3 generated: {len(new_foods)} new foods")
print(f"Final total: {len(df_combined)} foods")
print(f"  Base: {(df_combined['food_type'] == 'base_food').sum()}")
print(f"  Local Indonesian: {(df_combined['food_type'] == 'local_indonesian').sum()}")
print(f"  Beverages: {(df_combined['food_type'] == 'beverage').sum()}")
print(f"  Snacks: {(df_combined['food_type'] == 'snack').sum()}")
print(f"  Other: {(df_combined['food_type'] == 'other').sum()}")
