"""Batch 4: Generate 800+ genuinely new foods to reach 5,000+."""
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

count = 0

# ============================================================
# 1. VEGETABLE DISHES — Tumis, Sayur, Sambal Goreng, Gulai
# ============================================================
veg_base = {
    "Bayam": (23, 2.5, 0.4, 3.5, 0.5, 70, 1.5),
    "Kangkung": (25, 2.3, 0.3, 4.0, 0.5, 60, 1.8),
    "Sawi Hijau": (20, 2.0, 0.3, 3.0, 1.0, 65, 1.5),
    "Sawi Putih": (18, 1.8, 0.2, 2.8, 1.0, 40, 1.2),
    "Kacang Panjang": (30, 2.5, 0.3, 5.5, 1.5, 4, 2.5),
    "Terong Ungu": (25, 1.0, 0.2, 5.0, 2.5, 2, 2.5),
    "Labu Siam": (22, 0.8, 0.1, 4.5, 2.0, 2, 2.0),
    "Daun Singkong": (50, 5.0, 0.8, 8.0, 0.5, 10, 3.5),
    "Pare": (19, 1.0, 0.2, 3.5, 0.5, 3, 2.5),
    "Buncis": (35, 2.0, 0.3, 7.0, 3.0, 6, 3.0),
    "Wortel": (41, 0.9, 0.2, 10, 4.5, 69, 2.8),
    "Kembang Kol": (25, 1.9, 0.3, 5.0, 2.0, 30, 2.5),
    "Brokoli": (34, 2.8, 0.4, 7.0, 1.7, 33, 2.6),
    "Jagung Muda": (35, 2.0, 0.5, 7.5, 3.0, 15, 2.2),
    "Kubis": (25, 1.3, 0.1, 5.5, 3.0, 18, 2.5),
    "Tauge": (30, 3.0, 0.2, 5.0, 2.0, 6, 1.5),
    "Daun Pepaya": (45, 4.5, 0.5, 7.0, 0.5, 4, 3.0),
    "Daun Ubi": (48, 4.0, 0.5, 8.0, 0.5, 8, 3.2),
    "Nangka Muda": (50, 2.0, 0.5, 10, 3.0, 5, 3.0),
    "Rebung": (32, 2.5, 0.3, 5.5, 0.5, 4, 2.5),
}

veg_methods = {
    "Tumis": (1.3, 1.5, 1.0, 1.0, 1.0),
    "Sayur Bening": (1.0, 1.0, 1.0, 1.0, 1.0),
    "Sayur Santan": (1.5, 0.9, 2.5, 1.1, 0.9),
    "Sayur Asam": (1.1, 1.0, 1.0, 1.0, 0.95),
    "Sayur Lodeh": (1.5, 1.0, 2.5, 1.2, 0.9),
    "Sambal Goreng": (1.6, 0.9, 3.0, 1.3, 0.9),
}

for vname, (cal, prot, fat, carbs, sug, sod, fib) in veg_base.items():
    for mname, (cm, pm, fm, cbm, fibm) in veg_methods.items():
        name = f"{mname} {vname}"
        if add(name,
               round(cal * cm, 1), round(prot * pm, 1), round(fat * fm, 1),
               round(carbs * cbm, 1), round(sug * 1.0, 1),
               round(sod * 1.0, 1), round(fib * fibm, 1),
               "base_food", "gen-batch4"):
            count += 1

print(f"Veg dishes: +{count - 0}")

# ============================================================
# 2. SEAFOOD — More fish species with cooking methods
# ============================================================
seafood = {
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
    "Ikan Sarden": (160, 18, 9.0, 0, 0, 200, 0),
    "Ikan Cakalang": (140, 23, 4.5, 0, 0, 48, 0),
    "Ikan Gabus": (90, 18, 1.0, 0, 0, 35, 0),
    "Ikan Belut": (160, 13, 12, 0, 0, 50, 0),
    "Ikan Manyung": (125, 18, 5.5, 0, 0, 55, 0),
    "Ikan Ekor Kuning": (110, 19, 3.0, 0, 0, 40, 0),
    "Ikan Teri Segar": (100, 18, 2.0, 0, 0, 400, 0),
    "Kepiting": (90, 17, 1.5, 0.5, 0, 290, 0),
    "Kerang Hijau": (80, 12, 2.0, 3.0, 0, 300, 0),
    "Kerang Dara": (75, 11, 1.5, 3.0, 0, 280, 0),
    "Rajungan": (85, 16, 1.2, 0.5, 0, 280, 0),
    "Keong Sawah": (70, 13, 0.8, 2.0, 0, 180, 0),
}

fish_m = {
    "Bakar": (1.15, 1.20, 1.05, 1.0, 0.95),
    "Goreng": (1.6, 3.0, 0.88, 1.1, 0.9),
    "Pepes": (1.1, 1.4, 1.0, 1.2, 0.95),
    "Asam Manis": (1.3, 1.0, 1.5, 1.4, 1.0),
    "Kecap": (1.3, 1.3, 0.95, 1.35, 0.9),
    "Kari": (1.35, 1.1, 1.8, 1.3, 1.0),
    "Acar Kuning": (1.25, 1.1, 1.3, 1.2, 1.0),
    "Asam Pedas": (1.2, 1.1, 1.2, 1.2, 1.0),
    "Kuah Kuning": (1.2, 1.1, 1.3, 1.2, 1.0),
}

sv = count
for fname, (cal, prot, fat, carbs, sug, sod, fib) in seafood.items():
    for mname, (cm, fm, pm, cbm, fibm) in fish_m.items():
        name = f"{fname} {mname}"
        if add(name,
               round(cal * cm, 1), round(prot * pm, 1), round(fat * fm, 1),
               round(carbs * cbm, 1), sug, round(sod * 1.0, 1), round(fib * fibm, 1),
               "base_food", "gen-batch4"):
            count += 1

print(f"Seafood: +{count - sv}")

# ============================================================
# 3. TAHU/TEMPE — More variant preparations
# ============================================================
tahu_tempe = {
    "Tahu Putih": (75, 8.0, 4.5, 2.0, 0.5, 7, 1.0),
    "Tahu Kuning": (85, 8.5, 5.5, 2.5, 0.5, 10, 1.2),
    "Tahu Sutra": (60, 5.0, 3.0, 2.0, 0.5, 5, 0.5),
    "Tempe Kedelai": (150, 14, 8.0, 10, 1.0, 6, 3.5),
    "Tempe Mendoan": (210, 10, 12, 18, 1.0, 180, 1.5),
}

tt_methods = {
    "Tumis": (1.2, 1.4, 1.0, 1.0, 1.0),
    "Bacem": (1.3, 1.1, 3.0, 1.5, 0.9),
    "Santan": (1.5, 0.9, 2.5, 1.1, 0.95),
    "Kecap": (1.3, 1.0, 1.3, 1.4, 0.9),
    "Goreng Tepung": (1.8, 0.85, 4.0, 1.8, 0.8),
    "Balado": (1.4, 1.0, 2.0, 1.2, 0.95),
    "Rica-Rica": (1.35, 1.0, 1.8, 1.2, 0.95),
}

sv = count
for tname, (cal, prot, fat, carbs, sug, sod, fib) in tahu_tempe.items():
    for mname, (cm, pm, fm, cbm, fibm) in tt_methods.items():
        name = f"{tname} {mname}"
        if add(name,
               round(cal * cm, 1), round(prot * pm, 1), round(fat * fm, 1),
               round(carbs * cbm, 1), sug, round(sod * sod * 0.1 + sod, 1),
               round(fib * fibm, 1),
               "local_indonesian", "gen-batch4"):
            count += 1

print(f"Tahu/Tempe: +{count - sv}")

# ============================================================
# 4. SAMBAL VARIETIES
# ============================================================
sambals = [
    ("Sambal Terasi", 30, 0.5, 2.5, 2.5, 1.0, 300, 0.5),
    ("Sambal Bawang", 35, 0.5, 3.0, 2.0, 1.0, 250, 0.3),
    ("Sambal Tomat", 28, 0.5, 2.0, 3.0, 2.0, 200, 0.8),
    ("Sambal Ijo", 25, 0.5, 2.5, 2.0, 0.5, 280, 0.5),
    ("Sambal Matah", 45, 0.5, 4.5, 2.5, 0.5, 200, 0.8),
    ("Sambal Dabu-Dabu", 22, 0.3, 2.0, 1.5, 1.0, 250, 0.8),
    ("Sambal Kecap", 40, 0.5, 1.5, 6.0, 5.0, 600, 0.2),
    ("Sambal Petis", 45, 1.5, 2.5, 4.0, 2.0, 400, 0.3),
    ("Sambal Bajak", 55, 1.0, 4.0, 3.5, 1.5, 350, 0.5),
    ("Sambal Kemiri", 50, 1.0, 4.5, 2.5, 0.5, 200, 0.5),
    ("Sambal Pete", 40, 1.5, 3.0, 3.0, 1.0, 250, 1.5),
    ("Sambal Jengkol", 55, 2.0, 3.5, 4.0, 1.0, 280, 1.5),
    ("Sambal Tempoyak", 35, 0.8, 2.0, 4.0, 1.5, 150, 1.0),
    ("Sambal Mangga Muda", 30, 0.5, 1.5, 4.0, 2.5, 200, 1.2),
    ("Sambal Nanas", 30, 0.3, 1.0, 5.0, 3.0, 150, 1.0),
    ("Sambal Andaliman", 28, 0.5, 2.0, 2.5, 0.5, 200, 0.5),
    ("Sambal Kemangi", 22, 0.5, 2.0, 1.5, 0.5, 180, 0.8),
    ("Sambal Cumi", 65, 4.0, 3.5, 3.0, 1.0, 350, 0.3),
    ("Sambal Teri", 60, 5.0, 3.0, 3.0, 1.0, 500, 0.3),
    ("Sambal Goreng Ati", 80, 6.0, 5.0, 4.0, 1.5, 350, 0.5),
]

sv = count
for name, *nut in sambals:
    if add(name, *nut, "local_indonesian", "gen-batch4"):
        count += 1
print(f"Sambals: +{count - sv}")

# ============================================================
# 5. TRADITIONAL KUE / JAJANAN PASAR
# ============================================================
kue_trad = [
    ("Kue Lapis", 180, 3.0, 6.0, 28, 18, 120, 0.5),
    ("Kue Putu", 160, 3.0, 4.0, 28, 14, 80, 0.5),
    ("Kue Mangkok", 150, 2.5, 4.0, 26, 16, 100, 0.3),
    ("Kue Apem", 155, 2.5, 4.5, 26, 15, 110, 0.5),
    ("Kue Cucur", 200, 2.5, 8.0, 30, 18, 100, 0.3),
    ("Kue Nagasari", 170, 2.0, 5.0, 30, 14, 80, 1.0),
    ("Kue Talam", 175, 2.5, 5.5, 28, 16, 90, 0.5),
    ("Kue Onde-Onde", 210, 4.0, 10, 26, 8, 120, 1.0),
    ("Kue Dadar Gulung", 190, 3.0, 8.0, 26, 14, 80, 1.5),
    ("Kue Klepon", 185, 3.0, 7.0, 28, 14, 60, 1.0),
    ("Kue Serabi", 195, 3.5, 8.5, 27, 12, 150, 0.5),
    ("Kue Wajik", 220, 2.0, 7.0, 38, 28, 50, 0.5),
    ("Kue Koci", 180, 3.0, 7.0, 26, 14, 70, 1.0),
    ("Kue Pukis", 200, 5.0, 8.0, 30, 12, 150, 0.5),
    ("Kue Gemblong", 210, 3.0, 9.0, 30, 18, 100, 0.5),
    ("Kue Cenil", 190, 2.0, 8.0, 28, 16, 60, 0.3),
    ("Kue Lupis", 200, 3.0, 8.0, 30, 16, 50, 0.5),
    ("Kue Bika Ambon", 220, 4.0, 8.0, 32, 20, 120, 0.3),
    ("Kue Wingko", 200, 3.0, 7.0, 32, 18, 80, 0.5),
    ("Kue Lumpur Surga", 210, 4.0, 10, 26, 16, 100, 0.3),
    ("Kue Jongkong", 195, 3.0, 8.5, 27, 16, 70, 0.3),
    ("Kue Srikaya", 180, 4.0, 10, 22, 20, 60, 0.2),
    ("Kue Pandan", 175, 3.0, 7.0, 26, 18, 80, 0.3),
    ("Kue Ubi Ungu", 185, 2.0, 7.0, 28, 16, 50, 1.5),
    ("Kue Singkong", 190, 1.5, 8.0, 28, 14, 60, 1.5),
    ("Kue Cantik Manis", 195, 3.0, 8.5, 27, 16, 100, 0.3),
    ("Kue Sengkulun", 180, 2.0, 7.0, 26, 18, 70, 0.5),
    ("Kue Clorot", 160, 2.0, 6.0, 26, 18, 60, 0.3),
    ("Kue Pancong", 200, 4.0, 10, 26, 12, 120, 1.0),
    ("Kue Ape", 160, 3.0, 6.0, 25, 12, 100, 0.3),
    ("Kue Bugis", 200, 3.0, 8.0, 30, 14, 80, 1.5),
    ("Kue Lemper", 220, 5.0, 6.0, 32, 2, 200, 2.0),
    ("Kue Semar Mendem", 210, 4.0, 7.0, 30, 3, 180, 1.5),
    ("Kue Sus", 230, 5.0, 12, 26, 10, 150, 0.3),
    ("Kue Bolu Kukus", 200, 4.0, 7.0, 30, 18, 120, 0.3),
    ("Kue Putri Ayu", 195, 3.0, 8.5, 26, 16, 100, 0.5),
    ("Kue Putri Salju", 220, 4.0, 12, 25, 10, 100, 0.3),
    ("Kue Lidah Kucing", 230, 4.0, 13, 26, 10, 100, 0.3),
    ("Kue Nastar", 240, 4.0, 13, 28, 12, 80, 0.5),
    ("Kue Kastengel", 250, 6.0, 14, 24, 2, 200, 0.3),
    ("Kue Putri Selat", 210, 5.0, 10, 26, 14, 100, 0.3),
    ("Kue Semprit", 230, 3.0, 12, 28, 14, 100, 0.2),
    ("Kue Lidah Buaya", 190, 2.0, 8.0, 28, 14, 80, 0.5),
    ("Kue Gandus", 195, 3.0, 8.0, 27, 14, 100, 0.5),
    ("Kue Jadah", 180, 3.0, 5.0, 30, 8, 50, 0.5),
    ("Kue Mendut", 185, 3.0, 7.0, 28, 16, 80, 1.5),
    ("Kue Moho", 175, 2.5, 6.5, 27, 16, 90, 0.3),
    ("Kue Nopia", 190, 3.0, 8.0, 28, 14, 120, 0.3),
    ("Kue Pia", 220, 4.0, 10, 28, 14, 120, 1.0),
    ("Kue Pukis Coklat", 210, 5.0, 9.0, 30, 14, 150, 0.5),
]

sv = count
for name, *nut in kue_trad:
    if add(name, *nut, "snack", "gen-batch4"):
        count += 1
print(f"Traditional kue: +{count - sv}")

# ============================================================
# 6. REGIONAL INDONESIAN DISHES (more specific)
# ============================================================
regional = [
    # Jawa Tengah / Jogja
    ("Gudeg Komplit", 380, 10, 16, 48, 18, 400, 4.0),
    ("Sate Klathak", 280, 22, 16, 12, 1.0, 350, 0.5),
    ("Mangut Lele", 280, 18, 16, 16, 2.0, 450, 1.0),
    ("Oseng Mercon", 320, 22, 20, 12, 2.0, 550, 1.0),
    ("Tengkleng", 350, 22, 22, 14, 3.0, 500, 1.5),
    ("Soto Sokaraja", 330, 16, 14, 34, 3.0, 600, 2.5),
    ("Nasi Liwet Solo", 420, 14, 16, 54, 2.0, 500, 2.0),
    ("Sate Buntel", 300, 24, 18, 10, 2.0, 400, 0.5),
    ("Tongseng", 380, 22, 20, 28, 4.0, 550, 2.0),
    ("Selat Solo", 300, 18, 14, 26, 6.0, 500, 2.5),
    # Jawa Timur
    ("Rawon", 320, 24, 14, 24, 2.0, 550, 1.5),
    ("Lontong Balap", 360, 12, 14, 44, 3.0, 500, 2.5),
    ("Sate Kerang", 200, 16, 8.0, 14, 2.0, 450, 0.5),
    ("Rujak Cingur", 220, 10, 10, 24, 6.0, 400, 3.5),
    ("Tahu Campur", 350, 16, 16, 34, 3.0, 650, 2.5),
    ("Tahu Tek", 320, 14, 14, 34, 4.0, 550, 2.0),
    ("Nasi Krawu", 380, 14, 14, 50, 2.0, 450, 1.5),
    ("Soto Lamongan", 340, 18, 14, 34, 3.0, 600, 2.0),
    ("Pecel Madiun", 280, 12, 14, 28, 4.0, 350, 5.0),
    ("Sate Madura", 320, 26, 18, 10, 3.0, 450, 0.5),
    # Sumatera
    ("Mie Aceh Goreng", 480, 16, 24, 48, 4.0, 950, 2.5),
    ("Mie Aceh Rebus", 440, 16, 20, 48, 4.0, 900, 2.5),
    ("Kuah Beulangong", 300, 16, 14, 28, 3.0, 550, 2.5),
    ("Sate Matang", 280, 22, 16, 10, 1.0, 400, 0.5),
    ("Gulai Kambing", 350, 22, 25, 10, 2.0, 500, 1.5),
    ("Gulai Itik", 330, 20, 24, 8.0, 1.5, 480, 1.0),
    ("Gulai Kepala Ikan", 280, 18, 20, 6.0, 1.0, 450, 0.5),
    ("Ikan Asam Padeh", 240, 18, 12, 14, 2.0, 500, 1.0),
    ("Dendeng Balado", 320, 28, 18, 8.0, 3.0, 600, 0.5),
    ("Ayam Pop", 280, 24, 16, 6.0, 1.0, 400, 0.3),
    ("Sambal Lado Mudo", 40, 0.5, 3.5, 2.5, 0.5, 300, 0.5),
    ("Sambal Lado Merah", 38, 0.5, 3.0, 2.5, 1.0, 280, 0.5),
    ("Lontong Gulai", 380, 12, 18, 42, 3.0, 600, 2.5),
    ("Sate Padang", 330, 22, 18, 16, 2.0, 500, 0.5),
    ("Bubur Kampiun", 280, 8.0, 12, 36, 22, 150, 2.0),
    ("Laksa Medan", 350, 12, 16, 38, 3.0, 700, 1.5),
    # Kalimantan
    ("Soto Banjar", 320, 18, 14, 30, 3.0, 550, 2.0),
    ("Ketupat Kandangan", 360, 14, 14, 44, 3.0, 500, 2.0),
    ("Nasi Kuning Banjar", 400, 12, 16, 50, 2.0, 450, 2.0),
    ("Gangan Asam", 180, 14, 8.0, 14, 2.0, 400, 2.0),
    ("Sate Payau", 260, 24, 14, 8.0, 2.0, 400, 0.5),
    ("Juhu Singkah", 180, 12, 8.0, 16, 2.0, 350, 3.0),
    # Sulawesi
    ("Coto Makassar", 380, 24, 20, 24, 3.0, 600, 2.0),
    ("Pallubasa", 360, 22, 22, 22, 2.0, 550, 1.5),
    ("Konro", 380, 26, 22, 16, 3.0, 550, 1.0),
    ("Sop Saudara", 280, 16, 12, 26, 2.0, 500, 2.5),
    ("Mie Titi", 480, 16, 22, 52, 3.0, 850, 2.0),
    ("Pisang Ijo", 280, 4.0, 10, 44, 28, 80, 2.0),
    ("Es Palu Butung", 220, 3.0, 6.0, 40, 30, 60, 2.5),
    ("Bubur Manado", 220, 8.0, 5.0, 35, 2.0, 400, 4.0),
    ("Tinutuan", 220, 8.0, 5.0, 35, 2.0, 400, 4.0),
    ("Ikan Bakar Rica", 180, 18, 10, 6.0, 1.0, 450, 0.3),
    ("Ayam Woku", 300, 26, 18, 8.0, 2.0, 480, 0.5),
    # Bali / NTB / NTT
    ("Ayam Betutu", 320, 28, 18, 10, 2.0, 500, 1.0),
    ("Sate Lilit", 260, 22, 14, 10, 1.5, 420, 0.5),
    ("Lawar Bali", 200, 14, 12, 10, 2.0, 380, 3.0),
    ("Jukut Ares", 160, 8.0, 8.0, 14, 2.0, 350, 3.0),
    ("Nasi Campur Bali", 420, 18, 18, 46, 3.0, 550, 2.5),
    ("Sate Pusut", 250, 20, 14, 10, 1.5, 400, 0.5),
    ("Sate Rembiga", 280, 24, 16, 10, 2.0, 450, 0.5),
    ("Pelecing Kangkung", 80, 4.0, 4.0, 8.0, 2.0, 350, 3.0),
    ("Sate Bulayak", 260, 18, 14, 18, 2.0, 420, 0.5),
    ("Ayam Taliwang", 300, 26, 18, 6.0, 2.0, 500, 0.3),
    ("Bebalung", 280, 18, 16, 14, 2.0, 450, 1.5),
    # Papua / Maluku
    ("Papeda", 200, 1.0, 0.5, 48, 0.5, 30, 0.5),
    ("Ikan Kuah Kuning", 200, 18, 8.0, 14, 2.0, 480, 1.0),
    ("Sate Ulat Sagu", 180, 12, 10, 10, 1.0, 200, 0.5),
    ("Ikan Asar", 160, 22, 6.0, 4.0, 0.5, 350, 0),
    ("Nasi Jaha", 320, 6.0, 10, 50, 2.0, 300, 1.5),
    ("Colo-Colo", 15, 0.3, 0.5, 2.5, 1.0, 250, 0.8),
    ("Sambal Cakalang", 180, 20, 10, 4.0, 1.0, 500, 0.5),
    ("Gohu Ikan", 150, 18, 5.0, 6.0, 1.5, 350, 1.0),
    ("Kohu-Kohu", 120, 8.0, 5.0, 12, 3.0, 300, 3.0),
    ("Ikan Woku Belanga", 220, 20, 12, 6.0, 2.0, 450, 0.5),
]

sv = count
for name, *nut in regional:
    if add(name, *nut, "local_indonesian", "gen-batch4"):
        count += 1
print(f"Regional dishes: +{count - sv}")

# ============================================================
# 7. SOTO / SOUP VARIANTS
# ============================================================
soto_soup = [
    ("Soto Betawi", 380, 20, 22, 24, 3.0, 600, 2.0),
    ("Soto Kudus", 330, 18, 14, 32, 3.0, 550, 2.0),
    ("Soto Semarang", 340, 18, 14, 34, 3.0, 550, 2.0),
    ("Soto Bandung", 320, 18, 12, 32, 3.0, 500, 2.5),
    ("Soto Padang", 350, 18, 16, 32, 3.0, 600, 2.0),
    ("Soto Banten", 330, 18, 14, 32, 3.0, 550, 2.0),
    ("Soto Ayam Kuah Santan", 360, 18, 18, 30, 3.0, 550, 2.0),
    ("Soto Tangkar", 370, 22, 20, 24, 3.0, 550, 1.5),
    ("Sop Buntut", 380, 22, 20, 26, 3.0, 500, 2.0),
    ("Sop Iga Sapi", 360, 24, 20, 18, 3.0, 450, 1.5),
    ("Sop Konro", 380, 26, 22, 16, 3.0, 550, 1.0),
    ("Sop Kambing", 350, 24, 22, 14, 3.0, 500, 1.0),
    ("Sop Ayam Kampung", 280, 22, 14, 14, 2.0, 400, 1.5),
    ("Sop Telur Puyuh", 180, 12, 10, 10, 2.0, 350, 1.5),
    ("Sop Jamur", 100, 4.0, 3.0, 14, 3.0, 350, 2.5),
    ("Sop Asparagus", 90, 4.0, 3.0, 12, 2.0, 350, 2.5),
    ("Sop Oyong", 80, 3.0, 2.0, 12, 2.0, 300, 2.5),
    ("Sop Ceker Ayam", 250, 16, 14, 14, 2.0, 450, 1.5),
    ("Sop Kepiting", 180, 16, 8.0, 12, 2.0, 500, 1.0),
    ("Tekwan", 350, 14, 10, 50, 2.0, 650, 1.5),
    ("Pempek Kapal Selam", 380, 12, 16, 46, 3.0, 700, 1.0),
    ("Pempek Lenjer", 320, 8.0, 12, 44, 2.0, 650, 0.5),
    ("Pempek Adaan", 350, 10, 16, 42, 2.0, 700, 0.5),
    ("Pempek Kulit", 280, 6.0, 14, 34, 2.0, 600, 0.5),
    ("Model Ikan", 340, 14, 14, 40, 3.0, 650, 1.0),
]

sv = count
for name, *nut in soto_soup:
    if add(name, *nut, "local_indonesian", "gen-batch4"):
        count += 1
print(f"Soto/Soup: +{count - sv}")

# ============================================================
# 8. MORE RICE/NASI VARIANTS
# ============================================================
nasi = [
    ("Nasi Kebuli", 420, 14, 16, 54, 2.0, 500, 1.5),
    ("Nasi Briyani", 430, 16, 16, 54, 2.0, 500, 1.5),
    ("Nasi Mandhi", 410, 14, 14, 56, 1.5, 480, 1.5),
    ("Nasi Bakar Ayam", 400, 18, 16, 48, 2.0, 500, 2.0),
    ("Nasi Bakar Peda", 380, 16, 14, 48, 2.0, 600, 1.5),
    ("Nasi Bakar Teri", 370, 16, 12, 48, 2.0, 650, 1.5),
    ("Nasi Bakar Cumi", 390, 16, 14, 48, 2.0, 550, 1.5),
    ("Nasi Bakar Ati Ampela", 400, 18, 18, 44, 2.0, 550, 1.5),
    ("Nasi Tim Ayam", 380, 22, 12, 46, 2.0, 450, 1.5),
    ("Nasi Tim Ikan", 360, 20, 10, 44, 2.0, 420, 1.5),
    ("Nasi Kucing", 200, 4.0, 4.0, 36, 1.0, 150, 1.0),
    ("Nasi Jinggo", 250, 8.0, 8.0, 38, 2.0, 300, 1.5),
    ("Nasi Megono", 350, 10, 12, 48, 2.0, 400, 3.5),
    ("Nasi Lengko", 320, 10, 10, 46, 3.0, 350, 3.5),
    ("Nasi Tutug Oncom", 350, 12, 12, 48, 2.0, 350, 2.0),
    ("Nasi Gemuk", 380, 12, 14, 50, 2.0, 400, 1.5),
    ("Nasi Kapau", 400, 14, 16, 50, 2.0, 500, 2.5),
    ("Nasi Ayam Penyet", 420, 24, 18, 42, 2.0, 450, 1.5),
    ("Nasi Ikan Penyet", 400, 22, 16, 42, 2.0, 420, 1.5),
    ("Nasi Bebek", 440, 22, 22, 42, 2.0, 450, 1.0),
]

sv = count
for name, *nut in nasi:
    if add(name, *nut, "local_indonesian", "gen-batch4"):
        count += 1
print(f"Nasi variants: +{count - sv}")

# ============================================================
# 9. MORE GORENGAN / FRIED SNACKS
# ============================================================
gorengan = [
    ("Combro", 200, 3.0, 10, 24, 2.0, 250, 2.0),
    ("Misro", 220, 2.5, 12, 26, 16, 200, 2.0),
    ("Cireng", 180, 2.0, 8.0, 26, 1.0, 250, 0.5),
    ("Cimol", 170, 2.0, 7.0, 26, 1.0, 230, 0.3),
    ("Cilok", 190, 4.0, 8.0, 26, 2.0, 350, 0.5),
    ("Cilung", 180, 3.0, 8.0, 26, 2.0, 300, 0.3),
    ("Batagor", 250, 12, 14, 22, 2.0, 500, 1.5),
    ("Siomay Bandung", 220, 10, 12, 20, 2.0, 500, 1.5),
    ("Otak-Otak Goreng", 200, 12, 10, 16, 2.0, 450, 0.5),
    ("Pisang Goreng Crispy", 250, 2.0, 12, 34, 16, 100, 2.0),
    ("Pisang Goreng Coklat Keju", 350, 5.0, 18, 42, 22, 200, 2.0),
    ("Pisang Goreng Madu", 280, 2.5, 14, 36, 20, 80, 2.0),
    ("Tahu Goreng Isi", 230, 8.0, 14, 18, 2.0, 350, 1.5),
    ("Tempe Goreng Tepung", 240, 12, 14, 18, 2.0, 280, 2.0),
    ("Bala-Bala", 180, 3.0, 10, 22, 3.0, 300, 2.5),
    ("Gehu", 200, 8.0, 10, 20, 2.0, 300, 1.5),
    ("Tahu Isi", 220, 8.0, 12, 20, 2.0, 320, 1.5),
    ("Ote-Ote", 190, 4.0, 10, 22, 3.0, 300, 2.0),
    ("Jemblem", 200, 3.0, 10, 26, 2.0, 250, 2.0),
    ("Singkong Goreng", 230, 1.5, 12, 30, 2.0, 150, 2.5),
    ("Ubi Goreng", 220, 1.5, 10, 32, 14, 100, 3.0),
    ("Sukun Goreng", 200, 1.5, 10, 28, 8.0, 120, 2.5),
    ("Pisang Molen", 250, 3.0, 14, 30, 12, 120, 1.5),
    ("Martabak Telur", 350, 14, 22, 26, 2.0, 550, 1.0),
    ("Martabak Telur Spesial", 400, 18, 26, 26, 2.0, 600, 1.0),
]

sv = count
for name, *nut in gorengan:
    if add(name, *nut, "snack", "gen-batch4"):
        count += 1
print(f"Gorengan: +{count - sv}")

# ============================================================
# 10. MORE BEVERAGES
# ============================================================
beverages = [
    ("Es Selendang Mayang", 180, 3.0, 4.0, 34, 24, 50, 0.5),
    ("Es Goyobod", 200, 3.0, 5.0, 36, 28, 60, 1.0),
    ("Es Dawet", 180, 2.0, 4.0, 34, 24, 50, 0.5),
    ("Es Cincau Hijau", 120, 0.5, 1.0, 28, 22, 30, 1.5),
    ("Es Cincau Hitam", 120, 0.5, 1.0, 28, 22, 30, 1.5),
    ("Es Oyen", 220, 3.0, 6.0, 38, 28, 60, 1.0),
    ("Es Doger", 250, 4.0, 8.0, 40, 32, 80, 0.5),
    ("Es Campur", 260, 4.0, 8.0, 44, 30, 80, 1.5),
    ("Es Teler", 280, 4.0, 10, 44, 30, 80, 1.5),
    ("Es Kacang Merah", 200, 5.0, 4.0, 36, 26, 40, 3.0),
    ("Es Kacang Hijau", 180, 5.0, 3.0, 34, 24, 30, 2.5),
    ("Es Blewah", 100, 0.5, 0.5, 24, 20, 30, 1.0),
    ("Es Timun", 60, 0.5, 0.2, 14, 10, 30, 0.5),
    ("Es Alpukat Kocok", 220, 3.0, 14, 22, 16, 20, 5.0),
    ("Es Kelapa Muda", 120, 1.0, 2.0, 24, 18, 40, 2.5),
    ("Es Kelapa Jeruk", 100, 1.0, 1.0, 22, 18, 30, 2.0),
    ("Es Kelapa Sirup", 150, 1.0, 2.0, 32, 28, 40, 2.5),
    ("Es Soda Gembira", 120, 1.0, 1.0, 26, 24, 30, 0),
    ("Es Kuwut", 100, 0.5, 0.5, 24, 20, 30, 1.5),
    ("Es Lidah Buaya", 80, 0.5, 0.3, 20, 18, 20, 1.0),
    ("Es Semangka Merah", 40, 0.5, 0.2, 10, 8, 5, 0.5),
    ("Es Melon Serut", 50, 0.5, 0.2, 12, 10, 15, 0.8),
    ("Wedang Ronde", 220, 5.0, 6.0, 36, 22, 50, 1.5),
    ("Wedang Uwuh", 30, 0.2, 0.1, 7, 2.0, 5, 0.5),
    ("Wedang Secang", 25, 0.2, 0.1, 6, 2.0, 5, 0.5),
    ("Wedang Sereh", 15, 0.2, 0.1, 3, 1.0, 5, 0.3),
    ("Wedang Asem", 40, 0.3, 0.2, 10, 8, 10, 0.5),
    ("Bandrek", 100, 1.0, 2.0, 20, 16, 30, 0.5),
    ("Bajigur", 120, 2.0, 3.0, 22, 18, 30, 0.5),
    ("Sekoteng", 150, 3.0, 4.0, 26, 20, 40, 0.5),
    ("Ronde Jahe", 200, 5.0, 5.0, 34, 22, 50, 1.5),
    ("Kopi Tubruk", 10, 0.3, 0.1, 1.5, 0, 5, 0),
    ("Kopi Aceh", 15, 0.5, 0.2, 2.0, 0.5, 10, 0),
    ("Kopi Toraja", 12, 0.3, 0.1, 1.5, 0, 5, 0),
    ("Kopi Luwak", 15, 0.5, 0.2, 1.5, 0, 5, 0),
    ("Teh Talua", 120, 3.0, 4.0, 18, 14, 50, 0),
    ("Teh Poci", 5, 0.1, 0, 1.0, 0, 5, 0),
    ("Teh Melati", 5, 0.1, 0, 1.0, 0, 5, 0),
    ("Teh Rosella", 10, 0.2, 0.1, 2.0, 1.0, 5, 0.5),
    ("Sari Kacang Hijau", 120, 5.0, 2.0, 20, 14, 30, 2.0),
    ("Sari Kedelai", 80, 7.0, 3.5, 6.0, 2.0, 30, 1.0),
    ("Susu Jahe", 130, 4.0, 4.0, 18, 14, 40, 0.3),
    ("Susu Kunyit", 120, 4.0, 4.0, 16, 12, 40, 0.3),
    ("Susu Temulawak", 110, 3.5, 3.5, 16, 12, 35, 0.3),
    ("Jamu Beras Kencur", 60, 0.5, 0.5, 14, 8, 10, 0.5),
    ("Jamu Kunyit Asam", 50, 0.5, 0.3, 12, 6, 10, 0.5),
    ("Jamu Temulawak", 55, 0.5, 0.5, 12, 6, 10, 0.8),
    ("Jamu Pahitan", 30, 0.3, 0.2, 6, 1, 5, 0.5),
]

sv = count
for name, *nut in beverages:
    if add(name, *nut, "beverage", "gen-batch4"):
        count += 1
print(f"Beverages: +{count - sv}")

# ============================================================
# 11. MORE PORRIDGE/BUBUR
# ============================================================
bubur = [
    ("Bubur Sumsum", 200, 3.0, 8.0, 30, 18, 80, 0.5),
    ("Bubur Candil", 220, 3.0, 8.0, 34, 22, 50, 1.0),
    ("Bubur Mutiara", 180, 1.0, 4.0, 36, 22, 30, 0.5),
    ("Bubur Sagu", 160, 0.5, 2.0, 36, 18, 20, 0.3),
    ("Bubur Gunting", 190, 3.0, 7.0, 30, 20, 50, 0.8),
    ("Bubur Pulut Hitam", 240, 5.0, 6.0, 44, 18, 20, 3.5),
    ("Bubur Ketan Hitam", 240, 5.0, 6.0, 44, 18, 20, 3.5),
    ("Bubur Jagung Manis", 180, 3.0, 4.0, 34, 14, 40, 2.5),
    ("Bubur Ubi Ungu", 200, 2.0, 4.0, 40, 18, 30, 3.0),
    ("Bubur Labu Kuning", 160, 2.0, 3.0, 32, 14, 30, 3.5),
    ("Bubur Pisang", 190, 2.0, 4.0, 38, 22, 30, 2.5),
    ("Bubur Kacang Hijau Durian", 260, 7.0, 6.0, 44, 24, 20, 4.0),
    ("Bubur Sagu Mutiara", 170, 1.0, 4.0, 34, 20, 20, 0.3),
    ("Bubur Pacar Cina", 180, 2.0, 6.0, 32, 22, 40, 0.5),
    ("Bubur Tepung Beras", 160, 2.0, 4.0, 30, 14, 30, 0.3),
    ("Bubur Ayam Jakarta", 340, 14, 12, 42, 2.0, 580, 1.5),
    ("Bubur Ayam Bandung", 330, 14, 12, 42, 2.0, 550, 2.0),
    ("Bubur Ayam Sukabumi", 330, 14, 12, 42, 2.0, 550, 2.0),
    ("Bubur Ayam Cirebon", 330, 14, 12, 42, 2.0, 560, 2.0),
]

sv = count
for name, *nut in bubur:
    if add(name, *nut, "local_indonesian", "gen-batch4"):
        count += 1
print(f"Bubur: +{count - sv}")

# ============================================================
# 12. AYAM / CHICKEN SPECIAL DISHES
# ============================================================
ayam = [
    ("Ayam Bakar Madu", 320, 26, 16, 14, 12, 400, 0.3),
    ("Ayam Bakar Kalasan", 300, 24, 14, 14, 10, 380, 0.5),
    ("Ayam Goreng Lengkuas", 350, 26, 20, 10, 1.5, 420, 0.5),
    ("Ayam Goreng Kremes", 380, 26, 22, 14, 1.5, 450, 0.5),
    ("Ayam Goreng Tepung Crispy", 400, 24, 24, 18, 1.5, 550, 0.5),
    ("Ayam Goreng Kalasan", 350, 24, 20, 12, 10, 400, 0.5),
    ("Ayam Bakar Taliwang", 300, 26, 18, 6.0, 2.0, 500, 0.3),
    ("Ayam Bakar Bumbu Rujak", 320, 24, 18, 12, 4.0, 450, 0.5),
    ("Ayam Betutu Kuah", 320, 28, 16, 12, 2.0, 500, 1.5),
    ("Ayam Bacem", 300, 22, 14, 20, 10, 400, 0.5),
    ("Ayam Semur", 310, 24, 14, 16, 8.0, 500, 0.5),
    ("Ayam Opor", 340, 24, 22, 12, 2.0, 420, 0.5),
    ("Ayam Rendang", 380, 26, 26, 10, 2.0, 500, 0.5),
    ("Ayam Gulai", 340, 24, 22, 10, 2.0, 450, 0.5),
    ("Ayam Asam Manis", 310, 24, 14, 16, 8.0, 400, 0.3),
    ("Ayam Lada Hitam", 320, 26, 16, 14, 2.0, 450, 0.5),
    ("Ayam Mentega", 350, 24, 22, 12, 2.0, 400, 0.3),
    ("Ayam Saus Tiram", 310, 24, 16, 14, 2.0, 500, 0.3),
    ("Ayam Teriyaki", 300, 24, 14, 16, 8.0, 600, 0.3),
    ("Ayam Kung Pao", 320, 26, 16, 14, 4.0, 550, 0.5),
    ("Ayam Kecap Pedas", 310, 24, 14, 16, 6.0, 520, 0.5),
    ("Ayam Tangkap", 300, 24, 16, 10, 1.0, 400, 0.5),
    ("Ayam Kodok", 350, 26, 22, 12, 2.0, 480, 0.5),
    ("Ayam Panggang Oven", 300, 26, 16, 8.0, 1.0, 350, 0.3),
    ("Ayam Geprek Sambal Bawang", 380, 28, 20, 18, 2.0, 450, 1.0),
    ("Ayam Geprek Keju", 420, 30, 24, 18, 2.0, 500, 1.0),
    ("Ayam Geprek Sambal Matah", 370, 28, 22, 18, 2.0, 420, 1.0),
    ("Ayam Cabe Ijo", 340, 26, 20, 10, 2.0, 450, 0.5),
    ("Ayam Serundeng", 330, 26, 18, 14, 5.0, 420, 2.0),
    ("Ayam Gembrot", 280, 22, 14, 16, 3.0, 380, 1.5),
]

sv = count
for name, *nut in ayam:
    if add(name, *nut, "local_indonesian", "gen-batch4"):
        count += 1
print(f"Ayam dishes: +{count - sv}")

# ============================================================
# 13. PASTA/MIE EXTENDED
# ============================================================
mie_more = [
    ("Mie Goreng Jawa", 480, 14, 22, 54, 4.0, 800, 2.0),
    ("Mie Goreng Aceh", 500, 16, 24, 52, 4.0, 850, 2.5),
    ("Mie Rebus Jawa", 450, 14, 18, 52, 4.0, 750, 2.0),
    ("Mie Godog", 460, 14, 20, 50, 3.0, 750, 2.0),
    ("Mie Yamin", 450, 16, 16, 56, 4.0, 700, 1.5),
    ("Mie Kocok Bandung", 440, 16, 18, 50, 3.0, 700, 2.0),
    ("Mie Celor", 460, 14, 20, 52, 3.0, 650, 1.5),
    ("Mie Kangkung", 420, 12, 16, 54, 3.0, 700, 2.5),
    ("Mie Ayam Jamur", 430, 14, 14, 56, 3.0, 650, 2.0),
    ("Mie Ayam Bakso", 450, 16, 16, 54, 3.0, 700, 2.0),
    ("Mie Ayam Ceker", 440, 16, 14, 56, 3.0, 650, 1.5),
    ("Kwetiau Siram", 420, 14, 18, 48, 3.0, 750, 1.5),
    ("Bihun Goreng", 400, 10, 16, 50, 2.0, 650, 2.0),
    ("Bihun Rebus", 350, 8.0, 12, 50, 2.0, 650, 1.5),
    ("Lomie", 450, 14, 18, 54, 3.0, 700, 2.0),
    ("I Fu Mie", 480, 16, 22, 52, 3.0, 750, 1.5),
    ("Pangsit Kuah", 280, 12, 14, 28, 2.0, 600, 1.0),
    ("Wonton Goreng", 300, 10, 16, 28, 2.0, 500, 0.5),
    ("Pangsit Goreng Isi Ayam", 320, 12, 18, 28, 2.0, 550, 0.5),
    ("Pangsit Goreng Isi Udang", 310, 12, 16, 28, 2.0, 550, 0.5),
]

sv = count
for name, *nut in mie_more:
    if add(name, *nut, "local_indonesian", "gen-batch4"):
        count += 1
print(f"Mie/Noodles: +{count - sv}")

# ============================================================
# 14. VEGETARIAN / SIDE DISHES
# ============================================================
veg_side = [
    ("Pepes Tahu", 120, 8.0, 6.0, 8.0, 1.0, 250, 1.5),
    ("Pepes Tempe", 160, 12, 8.0, 12, 2.0, 250, 3.0),
    ("Pepes Jamur", 80, 4.0, 4.0, 8.0, 1.0, 200, 2.5),
    ("Pepes Oncom", 140, 10, 8.0, 10, 1.0, 250, 2.5),
    ("Botok Tahu Tempe", 150, 10, 8.0, 12, 2.0, 250, 2.5),
    ("Botok Ikan Teri", 160, 12, 8.0, 12, 2.0, 350, 2.0),
    ("Botok Udang", 150, 12, 8.0, 10, 2.0, 300, 2.0),
    ("Botok Mlanding", 130, 8.0, 6.0, 14, 2.0, 200, 3.0),
    ("Sayur Bobor", 120, 5.0, 6.0, 14, 2.0, 250, 3.0),
    ("Sayur Buntil", 150, 10, 8.0, 12, 2.0, 300, 2.5),
    ("Sayur Urap", 140, 6.0, 8.0, 14, 3.0, 250, 4.0),
    ("Sayur Gudangan", 130, 5.0, 6.0, 14, 3.0, 200, 3.5),
    ("Sayur Pecel", 120, 5.0, 6.0, 14, 3.0, 200, 4.0),
    ("Gado-Gado Betawi", 320, 14, 16, 34, 6.0, 400, 5.0),
    ("Gado-Gado Solo", 300, 14, 14, 32, 5.0, 380, 5.0),
    ("Gado-Gado Surabaya", 310, 14, 16, 32, 5.0, 400, 5.0),
    ("Karedok", 200, 10, 10, 22, 4.0, 300, 4.5),
    ("Asinan Sayur", 100, 3.0, 3.0, 16, 6.0, 350, 3.5),
    ("Asinan Buah", 120, 1.0, 2.0, 26, 18, 200, 2.5),
    ("Rujak Buah", 140, 1.0, 2.0, 30, 22, 150, 3.0),
    ("Rujak Serut", 130, 1.0, 2.0, 28, 20, 150, 3.0),
    ("Rujak Petis", 180, 4.0, 5.0, 30, 18, 350, 3.0),
    ("Rujak Kuah Pindang", 150, 8.0, 4.0, 22, 16, 300, 2.5),
    ("Perkedel Tahu", 160, 6.0, 8.0, 16, 1.5, 250, 1.5),
    ("Perkedel Tempe", 180, 8.0, 10, 16, 1.5, 200, 2.5),
    ("Tumis Jamur", 90, 3.5, 5.0, 8.0, 2.0, 250, 2.5),
    ("Tumis Labu Siam", 80, 2.0, 4.0, 10, 3.0, 200, 2.5),
    ("Tumis Pare", 80, 2.0, 4.0, 8.0, 2.0, 200, 2.5),
    ("Tumis Tauge Tahu", 120, 8.0, 6.0, 10, 3.0, 250, 2.0),
    ("Tumis Kangkung Terasi", 100, 4.0, 6.0, 8.0, 2.0, 350, 2.0),
]

sv = count
for name, *nut in veg_side:
    if add(name, *nut, "local_indonesian", "gen-batch4"):
        count += 1
print(f"Veg/Side dishes: +{count - sv}")

# ============================================================
# 15. DAGING / MEAT MORE
# ============================================================
daging = [
    ("Daging Rendang", 380, 26, 26, 10, 2.0, 500, 0.5),
    ("Daging Empal", 320, 26, 16, 14, 8.0, 450, 0.5),
    ("Daging Semur", 320, 24, 16, 16, 8.0, 550, 0.5),
    ("Daging Bumbu Bali", 330, 26, 18, 12, 4.0, 500, 0.5),
    ("Daging Cabe Ijo", 340, 26, 20, 10, 2.0, 450, 0.5),
    ("Daging Teriyaki", 310, 26, 16, 14, 8.0, 600, 0.3),
    ("Daging Lada Hitam", 320, 26, 16, 14, 2.0, 450, 0.5),
    ("Daging Kari", 330, 24, 18, 14, 2.0, 480, 1.0),
    ("Daging Gulai", 340, 24, 22, 10, 2.0, 450, 0.5),
    ("Kikil Goreng", 280, 20, 18, 10, 1.0, 300, 0),
    ("Kikil Kecap", 260, 20, 14, 14, 4.0, 500, 0),
    ("Kikil Balado", 270, 20, 16, 10, 2.0, 400, 0),
    ("Paru Goreng", 300, 22, 18, 10, 1.0, 350, 0),
    ("Paru Balado", 310, 22, 20, 10, 2.0, 400, 0),
    ("Jeroan Goreng", 320, 22, 22, 8.0, 1.0, 350, 0),
    ("Hati Ayam Goreng", 220, 20, 14, 4.0, 0.5, 150, 0),
    ("Hati Sapi Goreng", 240, 24, 14, 4.0, 0.5, 180, 0),
    ("Ampela Goreng", 220, 22, 12, 4.0, 0.5, 150, 0),
    ("Ati Ampela Kecap", 230, 22, 14, 6.0, 2.0, 400, 0),
    ("Usus Goreng", 280, 18, 20, 6.0, 0.5, 250, 0),
    ("Babat Goreng", 270, 20, 18, 6.0, 0.5, 250, 0),
    ("Babat Kecap", 260, 20, 14, 12, 4.0, 480, 0),
    ("Sate Sapi", 280, 24, 16, 10, 2.0, 400, 0.5),
    ("Sate Kambing", 300, 22, 20, 10, 2.0, 400, 0.5),
    ("Sate Ayam Bumbu Kacang", 260, 22, 14, 12, 3.0, 450, 0.5),
    ("Sate Ayam Bumbu Kecap", 250, 22, 12, 14, 6.0, 550, 0.5),
    ("Sate Taichan", 200, 24, 8.0, 8.0, 1.0, 250, 0.3),
    ("Sate Kulit Ayam", 250, 14, 18, 8.0, 1.0, 200, 0),
    ("Sate Telur Puyuh", 180, 12, 12, 6.0, 1.0, 250, 0.3),
    ("Sate Ampela", 200, 20, 12, 4.0, 1.0, 250, 0),
]

sv = count
for name, *nut in daging:
    if add(name, *nut, "local_indonesian", "gen-batch4"):
        count += 1
print(f"Meat dishes: +{count - sv}")

# ============================================================
# 16. MODERN / FUSION / STREET FOOD
# ============================================================
modern = [
    ("Seblak Basah", 350, 10, 16, 40, 3.0, 800, 1.5),
    ("Seblak Kuah Pedas", 380, 12, 18, 42, 3.0, 850, 1.5),
    ("Indomie Goreng Telur", 500, 14, 26, 50, 4.0, 1000, 1.5),
    ("Indomie Rebus Telur", 450, 14, 22, 48, 4.0, 950, 1.5),
    ("Nasi Gila", 420, 18, 20, 42, 3.0, 600, 2.0),
    ("Nasi Goreng Mawut", 450, 14, 20, 52, 3.0, 800, 2.0),
    ("Nasi Goreng Hijau", 400, 14, 16, 48, 2.0, 600, 2.0),
    ("Nasi Goreng Tom Yam", 400, 16, 18, 44, 3.0, 650, 1.5),
    ("Nasi Goreng Sambal Matah", 380, 14, 14, 48, 2.0, 550, 1.5),
    ("Nasi Goreng Keju", 420, 16, 20, 44, 2.0, 600, 1.5),
    ("Burger Ayam", 350, 18, 16, 34, 4.0, 550, 1.5),
    ("Burger Sapi", 400, 22, 20, 34, 4.0, 550, 1.5),
    ("Burger Tempe", 300, 14, 14, 32, 4.0, 400, 3.5),
    ("Pizza Sosis", 300, 12, 14, 32, 3.0, 600, 1.5),
    ("Roti Bakar Coklat", 280, 6.0, 12, 40, 18, 300, 1.5),
    ("Roti John", 380, 14, 18, 38, 4.0, 500, 1.5),
    ("Roti Maryam", 250, 5.0, 10, 36, 6.0, 250, 1.0),
    ("Roti Cane", 260, 6.0, 10, 36, 4.0, 300, 1.0),
    ("Roti Gambang", 240, 5.0, 8.0, 36, 14, 200, 1.5),
    ("Roti Buaya", 260, 6.0, 10, 36, 14, 250, 1.0),
    ("Naan Bread", 280, 8.0, 10, 38, 2.0, 350, 1.5),
    ("Pita Bread", 250, 8.0, 6.0, 40, 2.0, 300, 1.5),
    ("Takoyaki", 220, 8.0, 10, 24, 2.0, 400, 0.5),
    ("Okonomiyaki", 280, 10, 14, 28, 4.0, 500, 2.0),
    ("Sushi Roll", 200, 12, 4.0, 30, 4.0, 350, 1.0),
    ("Kimbab", 220, 10, 6.0, 32, 4.0, 400, 2.0),
    ("Dimsum Ayam", 180, 10, 8.0, 18, 2.0, 400, 0.5),
    ("Hakau Udang", 160, 8.0, 6.0, 20, 2.0, 350, 0.5),
    ("Bapao Ayam", 220, 8.0, 6.0, 34, 6.0, 250, 1.0),
    ("Bapao Kacang Merah", 200, 6.0, 4.0, 36, 10, 180, 2.0),
    ("Bapao Coklat", 220, 5.0, 6.0, 38, 14, 200, 1.0),
]

sv = count
for name, *nut in modern:
    if add(name, *nut, "local_indonesian", "gen-batch4"):
        count += 1
print(f"Modern/Fusion: +{count - sv}")

# Merge and save
df_new = pd.DataFrame(new_foods)
df_combined = pd.concat([df, df_new], ignore_index=True)
df_combined.to_csv(FINAL_OUTPUT, index=False)

print(f"\nBatch 4 generated: {len(new_foods)} new foods")
print(f"Final total: {len(df_combined)} foods")
print(f"  Base: {(df_combined['food_type'] == 'base_food').sum()}")
print(f"  Local Indonesian: {(df_combined['food_type'] == 'local_indonesian').sum()}")
print(f"  Beverages: {(df_combined['food_type'] == 'beverage').sum()}")
print(f"  Snacks: {(df_combined['food_type'] == 'snack').sum()}")
print(f"  Other: {(df_combined['food_type'] == 'other').sum()}")
