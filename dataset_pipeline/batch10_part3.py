"""Batch 10 Part 3: Aggressive systematic generation targeting ~2,000 new foods."""
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

# ================================================================
# CROSS-PRODUCT: Ingredients x Cooking Methods with Style variants
# ================================================================

# Proteins with ALL regional style suffixes
proteins_all = {
    "Dada Ayam": (120, 25, 2.5, 0, 0, 50, 0),
    "Paha Ayam": (145, 20, 7.0, 0, 0, 65, 0),
    "Daging Sapi": (180, 26, 8.0, 0, 0, 55, 0),
    "Daging Kambing": (155, 21, 7.5, 0, 0, 55, 0),
    "Ikan Nila": (115, 19, 4.0, 0, 0, 40, 0),
    "Ikan Lele": (140, 17, 7.5, 0, 0, 48, 0),
    "Ikan Gurame": (120, 18.5, 5.0, 0, 0, 42, 0),
    "Ikan Kembung": (130, 22, 5.0, 0, 0, 60, 0),
    "Ikan Bandeng": (140, 18, 7.0, 0, 0, 55, 0),
    "Ikan Patin": (150, 16, 9.0, 0, 0, 50, 0),
    "Udang": (95, 19, 1.5, 0.5, 0, 140, 0),
    "Cumi": (85, 15, 1.2, 2.0, 0, 230, 0),
    "Tahu": (75, 8.0, 4.5, 2.0, 0.5, 7, 1.0),
    "Tempe": (150, 14, 8.0, 10, 1.0, 6, 3.5),
    "Telur": (150, 12, 10, 1.0, 0, 125, 0),
    "Bebek": (160, 18, 9.0, 0, 0, 70, 0),
}

# Regional style suffixes
styles = {
    "Bumbu Merah": (1.3, 1.0, 1.5, 1.2, 1.0),
    "Bumbu Putih": (1.2, 1.0, 1.3, 1.1, 1.0),
    "Bumbu Opor": (1.4, 1.0, 2.2, 1.1, 0.95),
    "Bumbu Semur": (1.35, 1.0, 1.8, 1.3, 0.95),
    "Bumbu Teriyaki": (1.2, 1.0, 1.2, 1.3, 1.0),
    "Saus Inggris": (1.25, 1.0, 1.3, 1.3, 1.0),
    "Bumbu Kemiri": (1.3, 1.0, 1.8, 1.2, 1.0),
    "Bumbu Ketumbar": (1.2, 1.0, 1.3, 1.2, 1.0),
    "Bumbu Jahe": (1.15, 1.0, 1.1, 1.1, 1.0),
    "Bumbu Lengkuas": (1.2, 1.0, 1.3, 1.2, 1.0),
    "Bumbu Sereh": (1.15, 1.0, 1.1, 1.1, 1.0),
    "Bumbu Kunyit": (1.2, 1.0, 1.2, 1.1, 1.0),
    "Bumbu Pala": (1.2, 1.0, 1.3, 1.2, 1.0),
    "Bumbu Kayu Manis": (1.2, 1.0, 1.3, 1.3, 1.0),
    "Saus Asam Pedas": (1.25, 1.0, 1.2, 1.3, 1.0),
    "Saus Padang": (1.35, 1.0, 1.6, 1.3, 1.0),
    "Bumbu Rawon": (1.3, 1.0, 1.4, 1.3, 1.0),
    "Bumbu Gulai": (1.5, 1.0, 2.5, 1.1, 0.95),
    "Bumbu Rendang": (1.6, 1.0, 3.0, 1.3, 0.9),
}

sv = count
for pname, (cal, prot, fat, carbs, sug, sod, fib) in proteins_all.items():
    for sname, (cm, fm, pm, cbm, fibm) in styles.items():
        name = f"{pname} {sname}"
        if add(name, round(cal * cm, 1), round(prot * pm, 1), round(fat * fm, 1),
               round(carbs * cbm, 1), sug, round(sod * 1.05, 1), round(fib * fibm, 1),
               "base_food", "gen-batch10"):
            count += 1
print(f"16. Protein x Bumbu: +{count - sv}")

# ================================================================
# Ikan species x ALL mid-level methods
# ================================================================
ikan_species = {
    "Ikan Kembung": (130, 22, 5.0, 0, 0, 60, 0),
    "Ikan Bandeng": (140, 18, 7.0, 0, 0, 55, 0),
    "Ikan Patin": (150, 16, 9.0, 0, 0, 50, 0),
    "Ikan Tongkol": (145, 21, 6.0, 0, 0, 65, 0),
    "Ikan Kakap": (105, 19, 2.5, 0, 0, 45, 0),
    "Ikan Kerapu": (100, 18, 2.0, 0, 0, 40, 0),
    "Ikan Selar": (135, 20, 5.5, 0, 0, 58, 0),
    "Ikan Mas": (120, 17, 5.0, 0, 0, 55, 0),
    "Ikan Bawal": (125, 16, 6.5, 0, 0, 50, 0),
    "Ikan Tenggiri": (110, 22, 2.0, 0, 0, 42, 0),
    "Ikan Baronang": (108, 19, 2.8, 0, 0, 40, 0),
    "Ikan Tuna": (130, 24, 3.0, 0, 0, 50, 0),
    "Ikan Salmon": (180, 20, 10, 0, 0, 55, 0),
    "Ikan Cakalang": (140, 23, 4.5, 0, 0, 48, 0),
    "Ikan Gabus": (90, 18, 1.0, 0, 0, 35, 0),
    "Ikan Ekor Kuning": (110, 19, 3.0, 0, 0, 40, 0),
    "Ikan Sarden": (160, 18, 9.0, 0, 0, 200, 0),
}

ikan_methods = {
    "Bakar Kecap Manis": (1.2, 1.3, 1.2, 1.3, 0.95),
    "Bakar Bumbu Rujak": (1.25, 1.3, 1.1, 1.2, 0.95),
    "Bakar Jimbaran": (1.3, 1.4, 1.1, 1.2, 0.95),
    "Bakar Pedas Manis": (1.25, 1.2, 1.1, 1.3, 0.95),
    "Goreng Tepung Crispy": (1.8, 3.0, 0.85, 1.3, 0.85),
    "Goreng Bumbu Kuning": (1.6, 2.5, 0.88, 1.2, 0.9),
    "Goreng Bumbu Laos": (1.6, 2.5, 0.88, 1.2, 0.9),
    "Goreng Tepung Panir": (1.7, 3.0, 0.85, 1.3, 0.85),
    "Pepes Kemangi": (1.15, 1.3, 1.0, 1.2, 1.0),
    "Pepes Daun Pisang": (1.1, 1.2, 1.0, 1.2, 1.0),
    "Asam Pedas": (1.2, 1.0, 1.2, 1.3, 1.0),
    "Kuah Kuning": (1.25, 1.0, 1.5, 1.2, 1.0),
    "Kuah Asam": (1.1, 1.0, 1.0, 1.2, 1.0),
    "Kuah Santan": (1.4, 1.0, 2.3, 1.1, 0.95),
    "Pindang Serani": (1.2, 1.0, 1.1, 1.2, 1.0),
    "Pindang Asam": (1.15, 1.0, 1.0, 1.2, 1.0),
    "Bumbu Acar Kuning": (1.25, 1.0, 1.3, 1.3, 1.0),
    "Bumbu Tauco": (1.3, 1.0, 1.3, 1.3, 1.0),
    "Bumbu Gulai": (1.5, 1.0, 2.5, 1.1, 0.95),
    "Bumbu Kari": (1.4, 1.0, 1.8, 1.3, 1.0),
}

sv = count
for iname, (cal, prot, fat, carbs, sug, sod, fib) in ikan_species.items():
    for mname, (cm, fm, pm, cbm, fibm) in ikan_methods.items():
        name = f"{iname} {mname}"
        if add(name, round(cal * cm, 1), round(prot * pm, 1), round(fat * fm, 1),
               round(carbs * cbm, 1), sug, round(sod * 1.05, 1), round(fib * fibm, 1),
               "base_food", "gen-batch10"):
            count += 1
print(f"17. Ikan x methods: +{count - sv}")

# ================================================================
# Vegetables x PREP styles (more systematic)
# ================================================================
all_veg = {
    # Leafy
    "Bayam": (23, 2.5, 0.4, 3.5, 0.5, 70, 1.5),
    "Kangkung": (25, 2.3, 0.3, 4.0, 0.5, 60, 1.8),
    "Sawi Hijau": (20, 2.0, 0.3, 3.0, 1.0, 65, 1.5),
    "Sawi Putih": (18, 1.8, 0.2, 2.8, 1.0, 40, 1.2),
    "Daun Singkong": (50, 5.0, 0.8, 8.0, 0.5, 10, 3.5),
    "Daun Pepaya": (45, 4.5, 0.5, 7.0, 0.5, 4, 3.0),
    "Daun Ubi": (48, 4.0, 0.5, 8.0, 0.5, 8, 3.2),
    "Daun Katuk": (55, 6.0, 1.0, 8.0, 0.5, 5, 4.0),
    "Daun Pakis": (34, 3.5, 0.5, 5.0, 0.5, 3, 3.5),
    "Daun Kemangi": (35, 4.0, 0.5, 5.0, 0.5, 4, 2.5),
    "Selada": (18, 2.0, 0.2, 2.5, 0.5, 40, 1.2),
    # Fruit veg
    "Terong Ungu": (25, 1.0, 0.2, 5.0, 2.5, 2, 2.5),
    "Terong Hijau": (22, 1.0, 0.2, 4.5, 2.0, 2, 2.0),
    "Labu Siam": (22, 0.8, 0.1, 4.5, 2.0, 2, 2.0),
    "Labu Kuning": (30, 1.0, 0.2, 7.0, 3.0, 2, 1.5),
    "Pare": (19, 1.0, 0.2, 3.5, 0.5, 3, 2.5),
    "Mentimun": (15, 0.6, 0.1, 3.0, 1.5, 2, 0.8),
    "Gambas": (20, 1.0, 0.2, 4.0, 1.5, 3, 1.5),
    # Pods/seeds
    "Kacang Panjang": (30, 2.5, 0.3, 5.5, 1.5, 4, 2.5),
    "Buncis": (35, 2.0, 0.3, 7.0, 3.0, 6, 3.0),
    "Kecipir": (45, 4.0, 1.0, 6.0, 0.5, 4, 2.5),
    "Tauge": (30, 3.0, 0.2, 5.0, 2.0, 6, 1.5),
    "Jagung Muda": (35, 2.0, 0.5, 7.5, 3.0, 15, 2.2),
    # Roots/tubers
    "Wortel": (41, 0.9, 0.2, 10, 4.5, 69, 2.8),
    "Rebung": (32, 2.5, 0.3, 5.5, 0.5, 4, 2.5),
    "Nangka Muda": (50, 2.0, 0.5, 10, 3.0, 5, 3.0),
    # Flowers
    "Kembang Kol": (25, 1.9, 0.3, 5.0, 2.0, 30, 2.5),
    "Brokoli": (34, 2.8, 0.4, 7.0, 1.7, 33, 2.6),
    "Bunga Pepaya": (40, 3.5, 0.5, 7.0, 0.5, 4, 3.5),
    "Jantung Pisang": (35, 2.5, 0.3, 7.0, 0.5, 5, 3.0),
}

veg_preps = {
    "Tumis Bawang Putih": (1.2, 1.3, 1.0, 1.0, 1.0),
    "Tumis Terasi": (1.28, 1.3, 1.0, 1.05, 1.0),
    "Tumis Cabai Merah": (1.25, 1.2, 1.1, 1.05, 1.0),
    "Tumis Cabai Hijau": (1.25, 1.2, 1.1, 1.05, 1.0),
    "Tumis Ebi": (1.3, 1.3, 1.2, 1.0, 1.0),
    "Tumis Saus Tiram": (1.25, 1.2, 1.3, 1.2, 1.0),
    "Sayur Bening": (1.0, 1.0, 1.0, 1.0, 1.0),
    "Sayur Bening Temu Kunci": (1.05, 1.0, 1.0, 1.0, 1.0),
    "Sayur Santan": (1.5, 1.0, 2.5, 1.1, 0.95),
    "Sayur Santan Kuning": (1.45, 1.0, 2.4, 1.15, 0.95),
    "Sayur Lodeh": (1.5, 1.0, 2.5, 1.2, 0.9),
    "Sayur Asam": (1.1, 1.0, 1.0, 1.1, 1.0),
    "Gulai": (1.5, 1.0, 2.5, 1.1, 0.9),
    "Oseng": (1.25, 1.1, 1.2, 1.1, 0.95),
    "Pecel": (1.1, 1.2, 1.5, 1.1, 1.0),
    "Urap": (1.15, 1.2, 1.5, 1.1, 1.0),
    "Bobor": (1.3, 1.0, 1.8, 1.1, 0.95),
    "Buntil": (1.25, 1.2, 1.5, 1.2, 1.0),
}

sv = count
for vname, (cal, prot, fat, carbs, sug, sod, fib) in all_veg.items():
    for pname, (cm, fm, pm, cbm, fibm) in veg_preps.items():
        name = f"{pname} {vname}"
        if add(name, round(cal * cm, 1), round(prot * pm, 1), round(fat * fm, 1),
               round(carbs * cbm, 1), sug, round(sod * 1.05, 1), round(fib * fibm, 1),
               "base_food", "gen-batch10"):
            count += 1
print(f"18. Vegetables x prep: +{count - sv}")

# ================================================================
# Tahu/Tempe/Oncon x ALL prep styles
# ================================================================
tt_items = {
    "Tahu Putih": (75, 8.0, 4.5, 2.0, 0.5, 7, 1.0),
    "Tahu Kuning": (85, 8.5, 5.5, 2.5, 0.5, 10, 1.2),
    "Tahu Sutra": (60, 5.0, 3.0, 2.0, 0.5, 5, 0.5),
    "Tahu Cina": (70, 7.0, 4.0, 2.0, 0.5, 5, 0.8),
    "Tahu Jepang": (65, 6.0, 3.5, 2.0, 0.5, 5, 0.5),
    "Tahu Kulit": (80, 9.0, 5.0, 2.5, 0.5, 10, 1.2),
    "Tempe Kedelai": (150, 14, 8.0, 10, 1.0, 6, 3.5),
    "Tempe Semangit": (155, 15, 8.5, 10, 1.0, 8, 4.0),
    "Tempe Gembus": (90, 8.0, 4.0, 8.0, 0.5, 5, 3.0),
    "Oncom": (120, 8.0, 6.0, 10, 1.0, 100, 3.0),
}

tt_preps = {
    "Tumis": (1.25, 1.2, 1.2, 1.1, 1.0),
    "Tumis Pete": (1.3, 1.2, 1.3, 1.1, 1.2),
    "Tumis Kangkung": (1.25, 1.1, 1.2, 1.1, 1.1),
    "Tumis Tauge": (1.25, 1.2, 1.2, 1.1, 1.1),
    "Tumis Cabai Ijo": (1.3, 1.1, 1.4, 1.1, 1.0),
    "Tumis Cabai Merah": (1.3, 1.1, 1.5, 1.1, 1.0),
    "Goreng": (1.5, 0.9, 3.0, 1.3, 0.9),
    "Goreng Tepung": (1.7, 0.85, 3.5, 1.5, 0.85),
    "Goreng Bumbu": (1.55, 0.9, 3.2, 1.3, 0.9),
    "Bakar": (1.15, 1.05, 1.2, 1.1, 0.95),
    "Bakar Kecap": (1.25, 1.0, 1.3, 1.3, 0.95),
    "Bakar Bumbu": (1.3, 1.0, 1.5, 1.2, 0.95),
    "Bacem": (1.3, 1.1, 0.9, 1.5, 0.9),
    "Bacem Manis": (1.35, 1.1, 0.9, 1.6, 0.9),
    "Kecap": (1.3, 1.0, 1.4, 1.4, 0.9),
    "Kecap Pedas": (1.35, 1.0, 1.5, 1.45, 0.9),
    "Kuah Santan": (1.5, 0.9, 2.5, 1.1, 0.95),
    "Kuah Kuning": (1.3, 1.0, 1.5, 1.1, 0.95),
    "Asam Manis": (1.3, 1.0, 1.5, 1.4, 1.0),
    "Saus Tiram": (1.25, 1.0, 1.3, 1.2, 1.0),
    "Lada Hitam": (1.2, 1.0, 1.2, 1.1, 1.0),
    "Balado": (1.4, 1.0, 2.0, 1.2, 0.95),
    "Cabe Ijo": (1.35, 1.0, 1.8, 1.1, 0.95),
    "Sambal": (1.3, 1.0, 1.5, 1.2, 0.95),
}

sv = count
for tname, (cal, prot, fat, carbs, sug, sod, fib) in tt_items.items():
    for pname, (cm, fm, pm, cbm, fibm) in tt_preps.items():
        name = f"{tname} {pname}"
        if add(name, round(cal * cm, 1), round(prot * pm, 1), round(fat * fm, 1),
               round(carbs * cbm, 1), sug, round(sod * 1.05, 1), round(fib * fibm, 1),
               "local_indonesian", "gen-batch10"):
            count += 1
print(f"19. Tahu/Tempe x prep: +{count - sv}")

# ================================================================
# MORE SNACKS (systematic)
# ================================================================
snacks_sys = [
    # Roti variants
    ("Roti Tawar Isi Telur", 280, 10, 10, 36, 3, 350, 1.5, "snack"),
    ("Roti Tawar Isi Daging", 300, 14, 12, 34, 3, 400, 1.5, "snack"),
    ("Roti Tawar Isi Ayam", 290, 14, 10, 34, 3, 380, 1.5, "snack"),
    ("Roti Tawar Isi Ikan", 270, 12, 8, 34, 3, 350, 1.5, "snack"),
    ("Roti Tawar Isi Sosis", 320, 12, 16, 34, 4, 500, 1.0, "snack"),
    ("Roti Tawar Isi Kornet", 310, 12, 14, 34, 4, 500, 1.0, "snack"),
    ("Roti Tawar Isi Selai", 260, 4, 8, 44, 18, 250, 1.0, "snack"),
    ("Roti Tawar Isi Coklat", 280, 5, 10, 44, 20, 280, 1.5, "snack"),
    ("Roti Tawar Isi Keju", 280, 8, 14, 34, 3, 400, 0.5, "snack"),
    ("Roti Tawar Isi Pisang Coklat", 300, 5, 12, 46, 20, 280, 2.0, "snack"),
    # Bolu variants
    ("Bolu Kukus Coklat", 190, 4, 7, 28, 16, 100, 0.5, "snack"),
    ("Bolu Kukus Pandan", 180, 4, 6, 28, 16, 100, 0.3, "snack"),
    ("Bolu Kukus Stroberi", 180, 4, 6, 28, 16, 100, 0.3, "snack"),
    ("Bolu Kukus Vanilla", 180, 4, 6, 28, 16, 100, 0.3, "snack"),
    ("Bolu Kukus Keju", 200, 5, 8, 28, 14, 150, 0.5, "snack"),
    ("Bolu Kukus Coklat Keju", 210, 5, 9, 28, 16, 150, 0.5, "snack"),
    ("Bolu Panggang Coklat", 220, 5, 10, 28, 16, 120, 0.5, "snack"),
    ("Bolu Panggang Pandan", 210, 5, 8, 28, 16, 120, 0.3, "snack"),
    ("Bolu Panggang Vanilla", 210, 5, 8, 28, 16, 120, 0.3, "snack"),
    ("Bolu Panggang Stroberi", 210, 5, 8, 28, 16, 120, 0.3, "snack"),
    # Jajanan pasar continued
    ("Kue Satu", 150, 3, 4, 26, 18, 60, 0.5, "snack"),
    ("Kue Bangkit", 180, 3, 6, 30, 14, 80, 0.3, "snack"),
    ("Kue Akar Kelapa", 200, 3, 10, 28, 14, 80, 0.5, "snack"),
    ("Kue Ku", 190, 4, 6, 30, 16, 100, 1.0, "snack"),
    ("Kue Ku Hijau", 190, 4, 6, 30, 16, 100, 1.0, "snack"),
    ("Kue Ku Merah", 190, 4, 6, 30, 16, 100, 1.0, "snack"),
    ("Kue Tok", 170, 3, 6, 28, 16, 80, 0.5, "snack"),
    ("Kue Jongkong Surabaya", 195, 3, 8.5, 27, 16, 70, 0.3, "snack"),
    ("Kue Jongkong Pandan", 195, 3, 8.5, 27, 16, 70, 0.3, "snack"),
    ("Kue Gemblong Ketan", 210, 3, 9, 30, 18, 100, 0.5, "snack"),
    ("Kue Gemblong Singkong", 200, 2, 8, 30, 16, 80, 1.0, "snack"),
    ("Kue Lapis Gula Merah", 185, 3, 6, 30, 20, 100, 0.3, "snack"),
    ("Kue Lapis Pandan", 180, 3, 6, 28, 18, 120, 0.5, "snack"),
    # Gorengan more
    ("Tahu Isi Udang", 220, 10, 12, 18, 2, 380, 0.5, "snack"),
    ("Tahu Isi Jamur", 190, 6, 10, 20, 2, 350, 2.0, "snack"),
    ("Bala-Bala Sayur", 180, 3, 10, 22, 3, 300, 2.5, "snack"),
    ("Bala-Bala Jagung", 190, 3, 10, 24, 4, 250, 2.5, "snack"),
    ("Gehu Pedas", 210, 8, 12, 20, 2, 350, 2.0, "snack"),
    ("Pisang Goreng Wijen", 240, 2, 12, 32, 16, 100, 2.0, "snack"),
    ("Pisang Goreng Tepung Beras", 230, 2, 10, 34, 16, 80, 2.0, "snack"),
    ("Pisang Goreng Tepung Panir", 260, 3, 14, 32, 16, 120, 1.5, "snack"),
    ("Ubi Goreng Tepung", 240, 1.5, 12, 34, 14, 100, 3.0, "snack"),
    ("Singkong Goreng Bumbu", 250, 1.5, 14, 30, 2, 200, 2.5, "snack"),
    ("Sukun Goreng Tepung", 220, 1.5, 12, 28, 8, 120, 2.5, "snack"),
    ("Tempe Mendoan Tepung", 230, 12, 14, 18, 1.5, 200, 2.0, "snack"),
    ("Martabak Telur Daging", 370, 16, 24, 26, 2, 580, 1.0, "snack"),
    ("Martabak Telur Ayam", 360, 16, 24, 26, 2, 570, 1.0, "snack"),
]
sv = count
for name, cal, prot, fat, carbs, sug, sod, fib, ft in snacks_sys:
    if add(name, cal, prot, fat, carbs, sug, sod, fib, ft, "gen-batch10"):
        count += 1
print(f"20. Snacks systematic: +{count - sv}")

# ================================================================
# BEVERAGES — MORE SYSTEMATIC
# ================================================================
bevs_sys = [
    ("Es Sirup Cocopandan", 100, 0, 0, 26, 24, 10, 0, "beverage"),
    ("Es Sirup Markisa", 100, 0, 0, 26, 24, 10, 0, "beverage"),
    ("Es Sirup Melon", 100, 0, 0, 26, 24, 10, 0, "beverage"),
    ("Es Sirup Frambozen", 100, 0, 0, 26, 24, 10, 0, "beverage"),
    ("Es Sirup Leci", 100, 0, 0, 26, 24, 10, 0, "beverage"),
    ("Es Campur Medan", 260, 4, 8, 44, 30, 80, 1.5, "beverage"),
    ("Es Campur Bandung", 260, 4, 8, 44, 30, 80, 1.5, "beverage"),
    ("Es Teler Bandung", 280, 4, 10, 44, 30, 80, 1.5, "beverage"),
    ("Es Teler Pontianak", 280, 4, 10, 44, 30, 80, 1.5, "beverage"),
    ("Es Doger Bandung", 250, 4, 8, 40, 32, 80, 0.5, "beverage"),
    ("Es Doger Jakarta", 250, 4, 8, 40, 32, 80, 0.5, "beverage"),
    ("Es Goyobod Bandung", 200, 3, 5, 36, 28, 60, 1.0, "beverage"),
    ("Es Oyen Bandung", 220, 3, 6, 38, 28, 60, 1.0, "beverage"),
    ("Es Selendang Mayang Jakarta", 180, 3, 4, 34, 24, 50, 0.5, "beverage"),
    # Kopi variants
    ("Kopi Hitam Panas", 5, 0.3, 0, 1, 0, 5, 0, "beverage"),
    ("Kopi Hitam Dingin", 5, 0.3, 0, 1, 0, 5, 0, "beverage"),
    ("Kopi Susu Panas", 80, 2, 3, 12, 8, 30, 0, "beverage"),
    ("Kopi Susu Dingin", 80, 2, 3, 12, 8, 30, 0, "beverage"),
    ("Kopi Gula Aren Panas", 60, 0.5, 0.5, 14, 12, 10, 0, "beverage"),
    ("Kopi Gula Aren Dingin", 60, 0.5, 0.5, 14, 12, 10, 0, "beverage"),
    # Teh variants
    ("Teh Manis Panas", 50, 0.2, 0, 14, 12, 5, 0, "beverage"),
    ("Teh Tawar Panas", 2, 0.1, 0, 0.5, 0, 5, 0, "beverage"),
    ("Teh Tawar Dingin", 2, 0.1, 0, 0.5, 0, 5, 0, "beverage"),
    # Coklat
    ("Coklat Panas", 180, 4, 6, 28, 22, 60, 1.0, "beverage"),
    ("Coklat Dingin", 180, 4, 6, 28, 22, 60, 1.0, "beverage"),
    # Functional drinks
    ("Air Kelapa Murni", 20, 0.3, 0.1, 4.5, 2, 105, 0.5, "beverage"),
    ("Air Lemon Hangat", 10, 0.1, 0, 2, 0.5, 1, 0.3, "beverage"),
    ("Air Lemon Dingin", 10, 0.1, 0, 2, 0.5, 1, 0.3, "beverage"),
    ("Air Jeruk Nipis Hangat", 10, 0.1, 0, 2, 0.5, 1, 0.3, "beverage"),
    ("Air Jahe Merah", 15, 0.2, 0.1, 3, 1, 5, 0.3, "beverage"),
    ("Wedang Jeruk", 40, 0.3, 0.1, 10, 5, 5, 0.5, "beverage"),
]
sv = count
for name, cal, prot, fat, carbs, sug, sod, fib, ft in bevs_sys:
    if add(name, cal, prot, fat, carbs, sug, sod, fib, ft, "gen-batch10"):
        count += 1
print(f"21. Beverages systematic: +{count - sv}")

# ================================================================
# MASSIVE REGIONAL DISH DUMP
# ================================================================
regional_massive = [
    ("Lontong Opor Ayam", 380, 16, 20, 38, 3, 500, 1.5, "local_indonesian"),
    ("Lontong Opor Telur", 350, 14, 18, 38, 3, 480, 1.5, "local_indonesian"),
    ("Lontong Kari Ayam", 370, 16, 18, 38, 3, 520, 1.5, "local_indonesian"),
    ("Lontong Kari Kambing", 390, 18, 22, 36, 3, 550, 2.0, "local_indonesian"),
    ("Lontong Gulai Pakis", 350, 10, 16, 42, 3, 550, 3.5, "local_indonesian"),
    ("Lontong Gulai Nangka", 360, 10, 18, 40, 3, 530, 4.0, "local_indonesian"),
    ("Lontong Pecel", 340, 12, 14, 44, 4, 420, 5.5, "local_indonesian"),
    ("Lontong Gado-Gado", 360, 14, 16, 44, 6, 450, 5.5, "local_indonesian"),
    ("Nasi Uduk Betawi Komplit", 450, 14, 22, 48, 3, 550, 2.5, "local_indonesian"),
    ("Nasi Uduk Jakarta", 440, 14, 22, 48, 3, 550, 2.5, "local_indonesian"),
    ("Nasi Uduk Kuning", 430, 12, 20, 50, 2, 500, 2.0, "local_indonesian"),
    ("Bubur Ayam Cirebon Spesial", 340, 16, 12, 42, 2, 580, 2.0, "local_indonesian"),
    ("Bubur Ayam Semarang", 330, 14, 12, 42, 2, 550, 2.0, "local_indonesian"),
    ("Bubur Ayam Surabaya", 330, 14, 12, 42, 2, 560, 2.0, "local_indonesian"),
    ("Mie Celor Palembang", 460, 14, 20, 52, 3, 650, 1.5, "local_indonesian"),
    ("Mie Kocok Bandung Komplit", 400, 18, 16, 46, 3, 720, 2.5, "local_indonesian"),
    ("Mie Yamin Asin", 450, 16, 16, 56, 4, 700, 1.5, "local_indonesian"),
    ("Mie Yamin Manis", 460, 16, 16, 58, 6, 720, 1.5, "local_indonesian"),
    ("Gado-Gado Jakarta", 320, 14, 16, 34, 6, 400, 5.5, "local_indonesian"),
    ("Gado-Gado Bandung", 310, 14, 14, 32, 5, 380, 5.5, "local_indonesian"),
    ("Pecel Madiun Komplit", 300, 14, 16, 30, 4, 380, 5.5, "local_indonesian"),
    ("Pecel Ponorogo", 290, 14, 14, 28, 4, 350, 5.5, "local_indonesian"),
    ("Pecel Kediri", 290, 14, 14, 28, 4, 350, 5.5, "local_indonesian"),
    ("Pecel Tulungagung", 290, 14, 14, 28, 4, 350, 5.5, "local_indonesian"),
    ("Sate Ayam Ponorogo", 270, 22, 14, 12, 3, 450, 0.5, "local_indonesian"),
    ("Sate Kerang Surabaya", 200, 16, 10, 14, 2, 480, 0.5, "local_indonesian"),
    ("Rawon Surabaya", 350, 24, 18, 26, 3, 600, 2.0, "local_indonesian"),
    ("Rawon Malang", 340, 24, 18, 26, 3, 580, 2.0, "local_indonesian"),
    ("Rawon Nguling", 340, 24, 18, 26, 3, 580, 2.0, "local_indonesian"),
    ("Tahu Campur Lamongan", 360, 18, 18, 34, 4, 700, 3.0, "local_indonesian"),
    ("Tahu Campur Malang", 350, 16, 16, 34, 4, 680, 3.0, "local_indonesian"),
    ("Tahu Tek Surabaya", 340, 16, 16, 34, 4, 600, 2.5, "local_indonesian"),
    ("Tahu Tek Lamongan", 330, 14, 14, 34, 4, 580, 2.5, "local_indonesian"),
    ("Rujak Cingur Surabaya", 240, 12, 12, 24, 6, 450, 3.5, "local_indonesian"),
    ("Rujak Cingur Malang", 230, 12, 12, 24, 6, 430, 3.5, "local_indonesian"),
    ("Coto Makassar Ayam", 350, 22, 18, 26, 3, 580, 2.0, "local_indonesian"),
    ("Coto Makassar Sapi", 380, 24, 20, 24, 3, 600, 2.0, "local_indonesian"),
    ("Konro Bakar", 350, 26, 22, 14, 3, 520, 1.0, "local_indonesian"),
    ("Konro Kuah", 380, 26, 22, 16, 3, 550, 1.0, "local_indonesian"),
    ("Nasi Kuning Makassar", 420, 14, 18, 50, 2, 480, 2.0, "local_indonesian"),
    ("Sop Konro Makassar", 380, 26, 22, 16, 3, 550, 1.0, "local_indonesian"),
    ("Ayam Betutu Bali Komplit", 360, 30, 20, 14, 3, 550, 1.5, "local_indonesian"),
    ("Ayam Betutu Kuah Bali", 340, 28, 18, 14, 3, 520, 2.0, "local_indonesian"),
    ("Sate Lilit Bali", 280, 24, 14, 12, 2, 450, 1.0, "local_indonesian"),
    ("Sate Lilit Ikan", 240, 20, 12, 12, 2, 420, 1.0, "local_indonesian"),
    ("Lawar Kacang", 200, 14, 10, 14, 3, 400, 4.0, "local_indonesian"),
    ("Lawar Nangka", 180, 8, 10, 18, 3, 380, 4.5, "local_indonesian"),
    ("Lawar Klungah", 190, 10, 10, 16, 3, 380, 4.0, "local_indonesian"),
    ("Tipat Cantok Bali", 280, 12, 14, 30, 4, 450, 4.0, "local_indonesian"),
    ("Pelecing Kangkung Lombok", 100, 5, 5, 10, 2, 380, 3.5, "local_indonesian"),
    ("Ayam Taliwang Lombok", 320, 28, 20, 8, 2, 550, 0.5, "local_indonesian"),
    ("Ayam Rarang", 310, 28, 18, 8, 2, 500, 0.5, "local_indonesian"),
    ("Sate Rembiga Lombok", 300, 24, 18, 10, 2, 480, 0.5, "local_indonesian"),
    ("Sate Bulayak Lombok", 280, 20, 16, 18, 2, 450, 0.5, "local_indonesian"),
    ("Jagung Titi", 180, 4, 6, 30, 3, 150, 4.0, "local_indonesian"),
    ("Sei Babi", 300, 22, 18, 8, 2, 520, 0.3, "local_indonesian"),
    ("Sei Sapi", 280, 24, 14, 10, 2, 500, 0.3, "local_indonesian"),
    ("Ikan Kuah Asam Manado", 220, 18, 10, 14, 2, 430, 2.0, "local_indonesian"),
    ("Ayam Isi Di Buluh", 320, 28, 18, 10, 2, 500, 1.0, "local_indonesian"),
    ("Sambal Roa", 60, 5, 4, 3, 1, 350, 0.3, "local_indonesian"),
    ("Sambal Cakalang Manado", 180, 20, 10, 4, 1, 500, 0.5, "local_indonesian"),
    ("Mie Cakalang Manado", 420, 22, 18, 48, 3, 800, 1.5, "local_indonesian"),
    ("Pisang Gaplek", 200, 2, 6, 36, 18, 50, 3.0, "local_indonesian"),
    ("Sagu Lempeng", 180, 1, 4, 36, 8, 20, 0.5, "local_indonesian"),
    ("Lapa-Lapa", 220, 4, 6, 38, 8, 150, 1.5, "local_indonesian"),
    ("Sinonggi", 200, 1, 0.5, 48, 2, 30, 1.5, "local_indonesian"),
]

sv = count
for name, cal, prot, fat, carbs, sug, sod, fib, ft in regional_massive:
    if add(name, cal, prot, fat, carbs, sug, sod, fib, ft, "gen-batch10"):
        count += 1
print(f"22. Regional massive: +{count - sv}")

print(f"\nPart 3 total new: {count}")

# Merge
df_new = pd.DataFrame(new)
df_all = pd.concat([df, df_new], ignore_index=True)
df_all.to_csv(FINAL_OUTPUT, index=False)
print(f"Running total: {len(df_all)} foods")
print(df_all["food_type"].value_counts())
