"""Batch 10: Massive generation targeting ~5,000 new foods for 10K total."""
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
# multiplier format: (cal, fat, protein, carb, fiber)

# ================================================================
# 1. PROTEIN x ALL METHODS (kambing, bebek, cumi, udang fokus)
# ================================================================
proteins_ext = {
    # Kambing — very underrepresented (37)
    "Daging Kambing": (155, 21, 7.5, 0, 0, 55, 0),
    "Daging Kambing Muda": (150, 20, 7.0, 0, 0, 50, 0),
    "Iga Kambing": (180, 18, 12, 0, 0, 50, 0),
    "Kaki Kambing": (170, 16, 11, 0, 0, 60, 0),
    # Bebek — underrepresented (37)
    "Dada Bebek": (140, 20, 6.0, 0, 0, 65, 0),
    "Paha Bebek": (160, 18, 9.0, 0, 0, 70, 0),
    "Bebek Utuh": (180, 17, 12, 0, 0, 75, 0),
    # Cumi/Udang — underrepresented (31, 45)
    "Cumi Segar": (85, 15, 1.2, 2.0, 0, 230, 0),
    "Udang Segar": (95, 19, 1.5, 0.5, 0, 140, 0),
    "Udang Galah": (90, 18, 1.2, 0.5, 0, 120, 0),
    "Udang Windu": (92, 18.5, 1.3, 0.5, 0, 130, 0),
    # Telur — more variants
    "Telur Puyuh": (145, 12, 10, 1.5, 0, 130, 0),
    "Telur Bebek": (185, 13, 14, 1.0, 0, 140, 0),
    "Telur Ayam Kampung": (150, 12, 10, 1.0, 0, 125, 0),
}

all_methods = {
    "Rebus": (1.0, 1.0, 1.0, 1.0, 1.0),
    "Bakar": (1.15, 1.20, 1.05, 1.0, 0.95),
    "Goreng": (1.8, 4.0, 0.85, 1.15, 0.9),
    "Kukus": (1.05, 1.0, 1.02, 1.0, 1.05),
    "Panggang": (1.2, 1.30, 1.08, 1.0, 0.95),
    "Bacem": (1.3, 1.10, 0.90, 1.50, 0.90),
    "Kecap": (1.3, 1.40, 0.95, 1.40, 0.90),
    "Semur": (1.35, 1.80, 0.93, 1.30, 0.95),
    "Rica-Rica": (1.35, 1.0, 1.8, 1.2, 0.95),
    "Woku": (1.3, 1.0, 1.5, 1.2, 0.95),
    "Bumbu Kuning": (1.2, 1.2, 1.0, 1.0, 1.0),
    "Bumbu Bali": (1.35, 1.20, 1.4, 1.2, 0.95),
    "Balado": (1.4, 1.0, 2.0, 1.2, 0.95),
    "Rendang": (1.6, 1.0, 3.0, 1.3, 0.85),
    "Gulai": (1.5, 0.9, 2.5, 1.1, 0.9),
    "Opor": (1.4, 0.9, 2.2, 1.1, 0.9),
    "Kari": (1.35, 1.1, 1.8, 1.3, 1.0),
    "Santan": (1.5, 0.9, 2.5, 1.1, 0.95),
    "Tauco": (1.25, 1.0, 1.3, 1.3, 1.0),
    "Asam Manis": (1.3, 1.0, 1.5, 1.4, 1.0),
    "Lada Hitam": (1.2, 1.0, 1.2, 1.1, 1.0),
    "Saus Tiram": (1.25, 1.0, 1.3, 1.2, 1.0),
    "Mentega": (1.4, 1.0, 2.5, 1.0, 1.0),
    "Teriyaki": (1.2, 1.0, 1.2, 1.3, 1.0),
    "Kuah Asam": (1.1, 1.0, 1.0, 1.2, 1.0),
    "Pindang": (1.15, 1.0, 1.0, 1.1, 1.0),
    "Bumbu Rujak": (1.3, 1.0, 1.5, 1.3, 1.0),
    "Cabe Ijo": (1.35, 1.0, 1.8, 1.1, 0.95),
    "Kremes": (1.8, 2.0, 1.0, 1.3, 0.9),
    "Sambal": (1.3, 1.0, 1.5, 1.2, 0.95),
}

sv = count
for pname, (cal, prot, fat, carbs, sug, sod, fib) in proteins_ext.items():
    for mname, (cm, fm, pm, cbm, fibm) in all_methods.items():
        if mname in ["Kremes"] and "Ayam" not in pname:
            continue  # Kremes mostly for chicken
        if mname in ["Teriyaki"] and ("Ikan" in pname or "Bebek" in pname or "Kambing" in pname):
            continue
        if add(f"{pname} {mname}",
               round(cal * cm, 1), round(prot * pm, 1), round(fat * fm, 1),
               round(carbs * cbm, 1), sug, round(sod * 1.05, 1),
               round(fib * fibm, 1),
               "base_food", "gen-batch10"):
            count += 1
print(f"1. Protein x methods: +{count - sv}")

# ================================================================
# 2. REGIONAL — ALL PROVINCE DISHES
# ================================================================
regional_ext = [
    # Aceh
    ("Kuah Sie Itek", 280, 18, 16, 14, 2, 450, 1.5, "local_indonesian"),
    ("Sigeup Ureung", 320, 22, 18, 16, 3, 500, 1.5, "local_indonesian"),
    ("Asam Keueung", 200, 14, 8, 16, 2, 380, 2.0, "local_indonesian"),
    ("Gule Masam Keueung", 260, 18, 14, 14, 2, 420, 1.5, "local_indonesian"),
    # Sumut
    ("Soto Medan", 340, 16, 16, 32, 3, 550, 2.0, "local_indonesian"),
    ("Bihun Bebek Medan", 380, 16, 14, 46, 3, 600, 2.0, "local_indonesian"),
    ("Lontong Sayur Medan", 360, 12, 18, 40, 3, 650, 2.5, "local_indonesian"),
    ("Tau Kua Heci", 280, 14, 14, 24, 3, 550, 2.0, "local_indonesian"),
    ("Mie Sop Medan", 380, 14, 16, 44, 3, 650, 2.0, "local_indonesian"),
    # Sumbar
    ("Asam Padeh Daging", 280, 24, 14, 14, 2, 500, 1.0, "local_indonesian"),
    ("Gulai Tauco", 300, 18, 20, 12, 2, 550, 1.5, "local_indonesian"),
    ("Gulai Cancang", 320, 22, 22, 10, 2, 480, 1.0, "local_indonesian"),
    ("Sambalado Tanak", 180, 10, 12, 10, 2, 400, 1.5, "local_indonesian"),
    ("Dendeng Batokok", 300, 28, 14, 8, 2, 550, 0.5, "local_indonesian"),
    ("Dendeng Lambok", 310, 28, 16, 8, 2, 550, 0.5, "local_indonesian"),
    ("Ikan Bakar Padang", 200, 20, 12, 6, 1, 400, 0.3, "local_indonesian"),
    # Riau
    ("Gulai Ikan Patin Asam Pedas", 250, 16, 14, 14, 2, 480, 1.0, "local_indonesian"),
    ("Bubur Asyura", 220, 6, 4, 38, 14, 100, 3.0, "local_indonesian"),
    ("Roti Jala Kuah Durian", 300, 5, 12, 44, 28, 150, 1.5, "local_indonesian"),
    # Jambi
    ("Gulai Tempoyak Ikan Patin", 260, 16, 16, 14, 2, 450, 1.0, "local_indonesian"),
    ("Nasi Gemuk Jambi", 380, 10, 14, 50, 2, 400, 2.0, "local_indonesian"),
    ("Daging Masak Hitam", 320, 24, 18, 12, 2, 500, 0.5, "local_indonesian"),
    # Sumsel/Bengkulu
    ("Pempek Lenggang", 300, 8, 14, 36, 2, 650, 0.5, "local_indonesian"),
    ("Burgo", 280, 6, 14, 34, 3, 600, 1.0, "local_indonesian"),
    ("Laksan", 320, 10, 14, 38, 3, 650, 1.0, "local_indonesian"),
    ("Celimpungan", 300, 10, 14, 34, 3, 600, 1.0, "local_indonesian"),
    ("Pindang Patin", 200, 18, 10, 10, 2, 450, 0.5, "local_indonesian"),
    ("Pindang Baung", 220, 18, 12, 10, 2, 450, 0.5, "local_indonesian"),
    ("Pindang Tulang", 250, 20, 14, 10, 2, 480, 0.3, "local_indonesian"),
    ("Brengkes Ikan", 200, 18, 10, 10, 2, 400, 1.0, "local_indonesian"),
    # Lampung
    ("Seruit", 220, 18, 12, 10, 2, 380, 1.5, "local_indonesian"),
    ("Gulai Taboh", 260, 16, 14, 16, 3, 400, 2.5, "local_indonesian"),
    ("Umbu Khas Lampung", 280, 20, 16, 14, 3, 450, 1.5, "local_indonesian"),
    # Jakarta/Betawi
    ("Asinan Betawi", 120, 4, 4, 18, 8, 400, 4.0, "local_indonesian"),
    ("Gabus Pucung", 220, 18, 12, 10, 2, 450, 0.5, "local_indonesian"),
    ("Pecak Gurame", 240, 18, 12, 14, 3, 400, 1.0, "local_indonesian"),
    ("Pecak Bandeng", 250, 18, 14, 12, 3, 420, 1.0, "local_indonesian"),
    ("Soto Betawi Susu", 380, 22, 24, 18, 3, 600, 1.5, "local_indonesian"),
    ("Toge Goreng", 250, 10, 14, 22, 4, 500, 3.0, "local_indonesian"),
    # Jabar
    ("Mie Kocok", 380, 16, 14, 46, 3, 700, 2.0, "local_indonesian"),
    ("Batagor Kuah", 280, 12, 14, 26, 3, 600, 2.0, "local_indonesian"),
    ("Cuanki", 250, 10, 12, 26, 3, 550, 1.5, "local_indonesian"),
    ("Seblak Kering", 300, 8, 14, 36, 2, 700, 1.5, "local_indonesian"),
    ("Surabi Kuah", 220, 4, 10, 30, 14, 200, 1.0, "local_indonesian"),
    ("Surabi Oncom", 210, 6, 10, 26, 6, 250, 2.0, "local_indonesian"),
    ("Karedok Kemangi", 180, 8, 8, 20, 4, 280, 4.5, "local_indonesian"),
    ("Lotong", 200, 6, 10, 22, 4, 300, 3.5, "local_indonesian"),
    # Jateng/Jogja
    ("Sate Kere", 200, 14, 10, 14, 2, 300, 2.0, "local_indonesian"),
    ("Gudeg Manggar Muda", 300, 8, 12, 40, 16, 350, 4.0, "local_indonesian"),
    ("Sambal Tumpang", 120, 8, 6, 10, 2, 300, 1.5, "local_indonesian"),
    ("Nasi Gandul", 380, 18, 16, 42, 3, 500, 2.0, "local_indonesian"),
    ("Nasi Pindang", 360, 20, 14, 40, 2, 480, 1.5, "local_indonesian"),
    ("Tahu Gimbal", 320, 14, 16, 32, 4, 550, 2.5, "local_indonesian"),
    ("Tahu Petis", 280, 12, 14, 28, 4, 600, 2.0, "local_indonesian"),
    ("Lontong Tahu", 340, 14, 14, 40, 4, 550, 2.5, "local_indonesian"),
    # Jatim
    ("Lontong Mie", 360, 12, 14, 46, 3, 600, 2.0, "local_indonesian"),
    ("Rujak Soto", 320, 14, 14, 34, 4, 550, 3.0, "local_indonesian"),
    ("Tahu Telur Lor", 350, 16, 18, 32, 4, 600, 2.0, "local_indonesian"),
    ("Sego Tempong", 380, 14, 14, 50, 3, 500, 3.5, "local_indonesian"),
    ("Sego Sambel", 360, 10, 12, 52, 4, 400, 3.0, "local_indonesian"),
    # Bali
    ("Sate Kablet", 260, 22, 16, 10, 1.5, 400, 0.5, "local_indonesian"),
    ("Jaje Abug", 200, 4, 8, 28, 18, 80, 1.0, "local_indonesian"),
    ("Tipat Cantok", 260, 10, 12, 30, 4, 400, 4.0, "local_indonesian"),
    ("Jukut Ares Mebase", 180, 8, 10, 16, 2, 380, 3.5, "local_indonesian"),
    # NTB
    ("Sate Tanjung", 280, 24, 16, 10, 2, 420, 0.5, "local_indonesian"),
    ("Ares Khas Lombok", 180, 8, 10, 16, 2, 380, 3.5, "local_indonesian"),
    ("Beberuk Terong", 80, 2, 4, 10, 3, 250, 3.0, "local_indonesian"),
    ("Sate Pusut Lombok", 250, 20, 14, 10, 1.5, 400, 0.5, "local_indonesian"),
    # NTT
    ("Sei Daging", 280, 24, 14, 10, 2, 500, 0.3, "local_indonesian"),
    ("Sei Ayam", 260, 22, 12, 10, 2, 450, 0.3, "local_indonesian"),
    ("Sei Ikan", 220, 20, 8, 8, 1, 400, 0.3, "local_indonesian"),
    ("Jagung Bose", 250, 6, 8, 40, 4, 200, 4.0, "local_indonesian"),
    ("Katemak", 180, 8, 6, 24, 3, 250, 3.5, "local_indonesian"),
    # Kalimantan
    ("Soto Banjar Ayam", 330, 18, 14, 32, 3, 550, 2.0, "local_indonesian"),
    ("Nasi Kuning Banjar Komplit", 420, 14, 18, 50, 2, 480, 2.5, "local_indonesian"),
    ("Hinangan Hati Batang Pisang", 150, 5, 8, 16, 2, 300, 3.0, "local_indonesian"),
    # Sulawesi
    ("Jalangkote", 220, 6, 12, 24, 2, 350, 1.5, "local_indonesian"),
    ("Pisang Epe", 200, 2, 6, 36, 24, 50, 2.5, "local_indonesian"),
    ("Es Pallu Butung", 220, 3, 6, 40, 30, 60, 2.5, "local_indonesian"),
    ("Binte Biluhuta", 200, 10, 6, 28, 2, 400, 3.5, "local_indonesian"),
    ("Sate Gorontalo", 280, 24, 16, 10, 2, 420, 0.5, "local_indonesian"),
    ("Ikan Bakar Gorontalo", 200, 20, 12, 6, 1, 380, 0.3, "local_indonesian"),
    # Papua/Maluku
    ("Ikan Kuah Kuning Maluku", 220, 18, 10, 14, 2, 450, 1.0, "local_indonesian"),
    ("Ikan Kuah Pala Banda", 200, 16, 10, 12, 2, 400, 1.0, "local_indonesian"),
    ("Nasi Lapola", 350, 10, 10, 54, 2, 300, 2.0, "local_indonesian"),
]
sv = count
for item in regional_ext:
    name = item[0]
    nut = item[1:-1]  # nutrition: cal,prot,fat,carbs,sug,sod,fib
    ftype = item[-1]  # food_type
    if add(name, *nut, ftype, "gen-batch10"):
        count += 1
print(f"2. Regional dishes: +{count - sv}")

# ================================================================
# 3. SAYUR x BUMBU (more vegetable×flavor combos)
# ================================================================
sayur_adv = {
    "Jantung Pisang": (35, 2.5, 0.3, 7, 0.5, 5, 3.0),
    "Bunga Pepaya": (40, 3.5, 0.5, 7, 0.5, 4, 3.5),
    "Bunga Turi": (38, 3, 0.4, 7, 0.5, 4, 3.0),
    "Daun Pakis": (34, 3.5, 0.5, 5, 0.5, 3, 3.5),
    "Daun Katuk": (55, 6, 1.0, 8, 0.5, 5, 4.0),
    "Daun Mangkokan": (45, 4, 0.8, 7, 0.5, 5, 3.5),
    "Daun Talas": (50, 4.5, 0.8, 8, 0.5, 6, 3.5),
    "Daun Gedi": (40, 4, 0.5, 7, 0.5, 5, 3.5),
    "Bunga Kol": (30, 2, 0.3, 6, 2, 30, 3.0),
    "Labu Kuning": (30, 1, 0.2, 7, 3, 2, 1.5),
    "Labu Air": (25, 0.8, 0.1, 5.5, 2, 2, 1.5),
    "Pepaya Muda": (28, 1, 0.2, 6, 2, 3, 2.0),
    "Jagung Putren": (35, 3, 0.5, 7, 3, 5, 2.5),
    "Cabe Hijau Besar": (30, 1.5, 0.3, 5.5, 3, 5, 2.0),
    "Cabe Merah Besar": (35, 1.5, 0.5, 6, 4, 5, 2.5),
    "Terong Hijau": (22, 1, 0.2, 4.5, 2, 2, 2.0),
    "Terong Pipit": (28, 1.2, 0.3, 5, 2, 2, 2.5),
}

sayur_methods = {
    "Tumis Bawang Putih": (1.2, 1.3, 1.0, 1.0, 1.0),
    "Tumis Terasi": (1.3, 1.2, 1.0, 1.05, 1.0),
    "Tumis Ebi": (1.3, 1.3, 1.2, 1.0, 1.0),
    "Tumis Cabai Hijau": (1.25, 1.2, 1.0, 1.05, 1.0),
    "Sayur Bening Temu Kunci": (1.05, 1.0, 1.0, 1.0, 1.0),
    "Sayur Santan Kuning": (1.45, 0.9, 2.4, 1.15, 0.95),
    "Sayur Lodeh Putih": (1.4, 0.95, 2.3, 1.1, 0.9),
    "Gulai": (1.5, 0.9, 2.5, 1.1, 0.9),
    "Oseng": (1.25, 1.1, 1.2, 1.1, 0.95),
    "Pecel": (1.1, 1.2, 1.5, 1.1, 1.0),
}

sv = count
for sname, (cal, prot, fat, carbs, sug, sod, fib) in sayur_adv.items():
    for mname, (cm, fm, pm, cbm, fibm) in sayur_methods.items():
        if add(f"{mname} {sname}",
               round(cal * cm, 1), round(prot * pm, 1), round(fat * fm, 1),
               round(carbs * cbm, 1), round(sug * 1.0, 1),
               round(sod * 1.05, 1), round(fib * fibm, 1),
               "base_food", "gen-batch10"):
            count += 1
print(f"3. Sayur x methods: +{count - sv}")

# ================================================================
# 4. TAHU/TEMPE/ONCOM x ALL METHODS
# ================================================================
tt_adv = {
    "Oncom": (120, 8, 6, 10, 1, 100, 3.0),
    "Oncom Merah": (125, 8.5, 6, 10, 1, 100, 3.0),
    "Oncom Hitam": (120, 8, 6, 10, 1, 100, 3.0),
    "Tahu Cina": (70, 7, 4, 2, 0.5, 5, 0.8),
    "Tahu Jepang": (65, 6, 3.5, 2, 0.5, 5, 0.5),
    "Tahu Kulit": (80, 9, 5, 2.5, 0.5, 10, 1.2),
    "Tahu Goreng": (110, 9, 7, 4, 0.5, 15, 1.0),
    "Tempe Semangit": (155, 15, 8.5, 10, 1, 8, 4.0),
    "Tempe Daun Jati": (155, 15, 8, 10, 1, 8, 3.5),
    "Tempe Gembus": (90, 8, 4, 8, 0.5, 5, 3.0),
}
tt_methods_adv = {
    "Tumis Pete": (1.3, 1.2, 1.3, 1.1, 1.2),
    "Tumis Kangkung": (1.25, 1.1, 1.2, 1.1, 1.1),
    "Tumis Cabai Ijo": (1.3, 1.1, 1.4, 1.1, 1.0),
    "Goreng Bawang": (1.5, 0.9, 3.0, 1.3, 0.9),
    "Goreng Lengkuas": (1.55, 0.9, 3.2, 1.3, 0.9),
    "Goreng Ketumbar": (1.5, 0.9, 3.0, 1.25, 0.9),
    "Goreng Kunyit": (1.5, 0.9, 3.0, 1.25, 0.9),
    "Bakar Kecap": (1.25, 1.1, 1.3, 1.3, 0.95),
    "Bakar Sambal": (1.3, 1.1, 1.5, 1.2, 0.95),
    "Bacem Manis": (1.35, 1.1, 0.9, 1.6, 0.9),
    "Kecap Pedas": (1.35, 1.0, 1.4, 1.5, 0.9),
    "Kuah Santan": (1.5, 0.9, 2.5, 1.1, 0.95),
    "Kuah Kuning": (1.3, 1.0, 1.5, 1.1, 0.95),
    "Asam Manis": (1.3, 1.0, 1.5, 1.4, 1.0),
    "Lada Hitam": (1.2, 1.0, 1.2, 1.1, 1.0),
    "Saus Tiram": (1.25, 1.0, 1.3, 1.2, 1.0),
}
sv = count
for tname, (cal, prot, fat, carbs, sug, sod, fib) in tt_adv.items():
    for mname, (cm, fm, pm, cbm, fibm) in tt_methods_adv.items():
        if add(f"{tname} {mname}",
               round(cal * cm, 1), round(prot * pm, 1), round(fat * fm, 1),
               round(carbs * cbm, 1), sug, round(sod * 1.05, 1),
               round(fib * fibm, 1),
               "local_indonesian", "gen-batch10"):
            count += 1
print(f"4. Tahu/Tempe x methods: +{count - sv}")

# ================================================================
# 5. SNACK / JAJANAN PASAR MASSIVE
# ================================================================
snacks_massive = [
    # Kue basah
    ("Kue Lapis Surabaya", 200, 4, 10, 30, 20, 100, 0.3),
    ("Kue Lapis Beras", 180, 3, 6, 28, 18, 120, 0.5),
    ("Kue Lapis Kanji", 170, 2, 6, 28, 18, 80, 0.3),
    ("Kue Lapis Tepung", 175, 3, 6, 28, 18, 100, 0.3),
    ("Kue Bolu Pandan", 220, 5, 10, 28, 18, 120, 0.3),
    ("Kue Bolu Tape", 230, 5, 10, 30, 20, 120, 0.5),
    ("Kue Bolu Pisang", 240, 5, 10, 32, 22, 120, 0.8),
    ("Kue Bolu Ketan", 250, 5, 12, 30, 18, 120, 0.5),
    ("Kue Mangkok Gula Merah", 160, 3, 4, 28, 18, 100, 0.5),
    ("Kue Mangkok Pandan", 155, 3, 4, 26, 16, 100, 0.3),
    ("Kue Apem Gula Merah", 160, 3, 5, 28, 16, 110, 0.5),
    ("Kue Apem Pandan", 150, 3, 4.5, 26, 15, 100, 0.5),
    ("Kue Putu Ayu", 170, 3, 7, 26, 16, 100, 1.0),
    ("Kue Putu Bambu", 160, 3, 4, 28, 14, 80, 0.5),
    ("Kue Putu Gula Merah", 165, 3, 4, 28, 16, 80, 0.5),
    ("Kue Cucur Gula Merah", 210, 3, 8, 32, 20, 100, 0.5),
    ("Kue Cucur Pandan", 200, 3, 8, 30, 18, 100, 0.3),
    ("Kue Nagasari Pisang", 180, 2, 5, 32, 16, 80, 1.0),
    ("Kue Nagasari Nangka", 175, 2, 5, 30, 14, 80, 1.0),
    ("Kue Talam Pandan", 180, 3, 6, 28, 16, 90, 0.5),
    ("Kue Talam Ubi", 190, 2, 6, 30, 16, 80, 1.0),
    ("Kue Talam Jagung", 185, 3, 6, 28, 14, 90, 1.0),
    ("Kue Talam Ketan", 200, 3, 7, 30, 16, 80, 0.5),
    # Kue kering
    ("Kue Sagu Keju", 240, 4, 14, 26, 10, 150, 0.3),
    ("Kue Coklat Kacang", 250, 5, 14, 28, 16, 100, 1.0),
    ("Kue Kopi Susu", 230, 4, 12, 28, 16, 100, 0.3),
    ("Kue Jahe", 220, 3, 10, 30, 16, 80, 0.5),
    ("Kue Kelapa", 230, 3, 12, 28, 16, 80, 1.0),
    ("Kue Kacang Mete", 260, 6, 14, 28, 14, 100, 1.0),
    ("Kue Wijen", 240, 4, 12, 28, 14, 100, 0.5),
    # Gorengan
    ("Tahu Isi Sayur", 210, 8, 12, 20, 2, 350, 1.5),
    ("Tahu Isi Daging", 240, 12, 14, 18, 2, 380, 1.0),
    ("Tahu Isi Ayam", 230, 12, 12, 18, 2, 370, 1.0),
    ("Lumpia Basah", 180, 6, 8, 22, 2, 380, 2.0),
    ("Lumpia Semarang", 200, 8, 10, 22, 2, 400, 1.5),
    ("Lumpia Rebung", 170, 4, 8, 22, 2, 350, 2.5),
    ("Risol Isi Sayur", 170, 4, 8, 22, 2, 300, 1.5),
    ("Risol Isi Ayam", 200, 8, 10, 22, 2, 350, 1.0),
    ("Risol Isi Sosis", 210, 8, 12, 22, 2, 380, 1.0),
    ("Risol Isi Keju", 220, 6, 14, 22, 2, 350, 0.5),
    ("Pastel Isi Ayam", 210, 8, 10, 24, 2, 320, 1.0),
    ("Pastel Isi Daging", 220, 8, 12, 24, 2, 330, 1.0),
    ("Pastel Isi Sayur", 190, 5, 10, 24, 2, 300, 1.5),
    ("Pastel Isi Telur", 200, 8, 10, 24, 2, 320, 1.0),
    ("Kroket Isi Ragout", 240, 8, 12, 26, 3, 320, 1.5),
    ("Kroket Isi Ayam", 240, 10, 12, 26, 3, 320, 1.5),
    ("Kroket Isi Daging", 250, 10, 14, 26, 3, 330, 1.0),
    # Jajanan tradisional
    ("Dodol Ketan", 260, 2, 8, 46, 32, 60, 0.5),
    ("Dodol Pisang", 240, 2, 6, 44, 30, 50, 1.0),
    ("Dodol Ubi", 230, 1.5, 6, 42, 28, 40, 1.5),
    ("Dodol Nangka", 250, 2, 6, 46, 32, 50, 0.8),
    ("Dodol Coklat", 270, 3, 10, 44, 30, 70, 0.5),
    ("Wajik Ubi", 220, 2, 6, 40, 28, 50, 1.5),
    ("Wajik Ketan", 230, 2, 7, 40, 28, 50, 0.5),
    ("Wajik Durian", 250, 2, 8, 42, 30, 50, 1.0),
    ("Gemblong Ketan", 220, 3, 10, 32, 20, 100, 0.5),
    ("Gemblong Singkong", 200, 2, 8, 30, 18, 80, 1.0),
    ("Gemblong Ubi", 210, 2, 8, 32, 18, 80, 1.5),
    ("Lopis Ketan", 210, 3, 8, 32, 16, 50, 0.5),
    ("Lopis Singkong", 200, 2, 8, 30, 14, 50, 0.5),
    ("Cenil Pelangi", 195, 2, 8, 28, 16, 60, 0.3),
    ("Cenil Gula Merah", 200, 2, 8, 30, 18, 60, 0.3),
    ("Cenil Kelapa", 190, 2, 8, 28, 14, 60, 0.5),
    # Keripik
    ("Keripik Apel", 180, 0.5, 6, 32, 24, 50, 2.0),
    ("Keripik Nangka", 200, 1, 8, 30, 18, 80, 2.0),
    ("Keripik Salak", 190, 0.5, 7, 28, 16, 60, 2.0),
    ("Keripik Sukun", 200, 1.5, 8, 30, 10, 100, 2.5),
    ("Keripik Gadung", 220, 1, 10, 28, 2, 120, 1.5),
    ("Keripik Bawang", 240, 4, 14, 26, 2, 300, 1.0),
    ("Keripik Jamur", 180, 3, 10, 20, 1, 200, 2.5),
    ("Keripik Belut", 260, 18, 14, 16, 1, 350, 0.3),
    # Modern snacks
    ("Donat Isi Coklat", 280, 5, 14, 34, 16, 200, 1.0),
    ("Donat Isi Kacang", 270, 5, 14, 34, 14, 180, 1.5),
    ("Donat Isi Keju", 280, 6, 16, 32, 10, 250, 0.5),
    ("Donat Isi Stroberi", 260, 4, 12, 34, 16, 150, 0.5),
    ("Donat Isi Blueberry", 260, 4, 12, 34, 16, 150, 0.5),
    ("Donat Isi Nanas", 260, 4, 12, 34, 16, 150, 0.5),
    ("Pukis Coklat Keju", 220, 5, 10, 30, 14, 150, 0.5),
    ("Pukis Stroberi", 200, 4, 8, 30, 14, 120, 0.3),
    ("Pukis Blueberry", 200, 4, 8, 30, 14, 120, 0.3),
    ("Pukis Kacang", 210, 5, 9, 30, 12, 130, 1.0),
    ("Pukis Keju", 220, 5, 10, 28, 12, 180, 0.5),
    ("Roti Bakar Coklat Keju", 350, 8, 16, 44, 20, 350, 1.5),
    ("Roti Bakar Kacang Coklat", 340, 8, 16, 42, 18, 320, 2.0),
    ("Roti Bakar Mentega Gula", 300, 6, 14, 40, 18, 280, 1.0),
    ("Roti Bakar Susu", 290, 7, 12, 40, 16, 300, 1.0),
    ("Roti Bakar Durian", 320, 6, 14, 44, 26, 280, 1.5),
    ("Roti Goreng", 300, 6, 16, 34, 8, 280, 1.0),
    ("Roti Goreng Coklat", 320, 6, 18, 36, 14, 280, 1.0),
    ("Roti Goreng Keju", 330, 8, 20, 32, 6, 320, 0.5),
]
sv = count
for name, cal, prot, fat, carbs, sug, sod, fib in snacks_massive:
    if add(name, cal, prot, fat, carbs, sug, sod, fib, "snack", "gen-batch10"):
        count += 1
print(f"5. Snacks: +{count - sv}")

# ================================================================
# 6. BEVERAGES MASSIVE
# ================================================================
bevs_massive = [
    # Es variants
    ("Es Kacang Hijau Durian", 220, 5, 4, 40, 28, 30, 3.0),
    ("Es Kacang Merah Santan", 210, 5, 4, 38, 26, 40, 3.5),
    ("Es Pisang Ijo Sirup", 280, 4, 10, 44, 28, 80, 2.0),
    ("Es Tape Singkong", 180, 2, 3, 36, 22, 30, 1.0),
    ("Es Tape Ketan Hitam", 200, 3, 4, 38, 24, 30, 1.5),
    ("Es Kelapa Muda Sirup", 140, 1, 2, 30, 24, 40, 2.5),
    ("Es Kelapa Muda Jeruk", 120, 1, 1.5, 26, 20, 30, 2.5),
    ("Es Kelapa Muda Nata", 130, 1, 2, 28, 24, 30, 1.0),
    ("Es Cincau Gula Aren", 140, 0.5, 1, 32, 26, 30, 1.5),
    ("Es Cincau Susu", 150, 2, 3, 28, 24, 40, 1.5),
    ("Es Cendol Nangka", 200, 2, 4, 38, 28, 50, 1.0),
    ("Es Cendol Durian", 240, 3, 6, 44, 32, 50, 1.5),
    ("Es Cendol Ketan", 210, 3, 5, 38, 26, 50, 1.0),
    # Jus buah tropical
    ("Jus Blewah", 50, 0.5, 0.2, 12, 10, 15, 1.0),
    ("Jus Timun Suri", 40, 0.5, 0.1, 9, 7, 10, 0.8),
    ("Jus Kelengkeng", 70, 1, 0.2, 17, 15, 5, 1.0),
    ("Jus Lengkeng", 70, 1, 0.2, 17, 15, 5, 1.0),
    ("Jus Rambai", 55, 0.5, 0.2, 13, 10, 5, 1.5),
    ("Jus Cempedak", 90, 1.5, 0.5, 20, 15, 8, 2.0),
    ("Jus Sukun", 80, 1, 0.3, 18, 8, 10, 2.5),
    ("Jus Jambu Air", 45, 0.5, 0.2, 10, 7, 3, 1.5),
    ("Jus Bengkuang", 40, 1, 0.1, 9, 2, 5, 2.0),
    # Susu & variants
    ("Susu Kurma", 150, 5, 5, 22, 18, 60, 1.0),
    ("Susu Almond", 60, 2, 3, 6, 2, 40, 0.5),
    ("Susu Kacang Mede", 70, 3, 4, 7, 2, 35, 0.5),
    ("Susu Wijen", 80, 3, 4.5, 7, 2, 30, 0.5),
    # Wedang
    ("Wedang Tape", 120, 2, 1, 26, 16, 20, 0.5),
    ("Wedang Gulo Kacang", 180, 5, 6, 28, 22, 50, 2.0),
    ("Wedang Kacang Tanah", 180, 6, 8, 24, 16, 40, 2.0),
    ("Wedang Blimbing Wuluh", 30, 0.3, 0.1, 7, 2, 5, 0.5),
    # Jamu
    ("Jamu Sawan", 35, 0.5, 0.3, 8, 2, 5, 0.5),
    ("Jamu Loloh", 40, 0.5, 0.3, 10, 3, 5, 1.0),
    ("Jamu Rapet", 30, 0.3, 0.2, 6, 1, 5, 0.5),
    ("Jamu Lempuyang", 35, 0.5, 0.3, 8, 2, 5, 0.5),
    ("Jamu Bangle", 40, 0.5, 0.3, 9, 3, 5, 0.8),
    # Modern drinks
    ("Es Kopi Susu Gula Aren", 150, 3, 5, 22, 16, 35, 0),
    ("Es Kopi Coklat", 140, 2, 5, 22, 16, 40, 0.5),
    ("Es Kopi Karamel", 160, 2, 6, 24, 18, 40, 0),
    ("Es Kopi Pandan", 130, 2, 4, 20, 14, 30, 0),
    ("Es Coklat Rempah", 180, 4, 8, 26, 20, 60, 1.0),
    ("Es Matcha Latte", 120, 3, 4, 18, 14, 40, 0),
    ("Es Thai Tea", 160, 2, 5, 26, 22, 40, 0),
    ("Es Green Tea Latte", 110, 3, 3.5, 16, 14, 35, 0),
    ("Es Taro Latte", 130, 3, 4, 20, 16, 40, 0.5),
    ("Es Red Velvet", 160, 3, 5, 24, 20, 45, 0.5),
    ("Es Hazelnut Latte", 140, 3, 5, 20, 16, 35, 0),
    ("Es Caramel Macchiato", 150, 3, 5, 22, 18, 40, 0.3),
]
sv = count
for name, cal, prot, fat, carbs, sug, sod, fib in bevs_massive:
    if add(name, cal, prot, fat, carbs, sug, sod, fib, "beverage", "gen-batch10"):
        count += 1
print(f"6. Beverages: +{count - sv}")

print(f"\nTotal new so far: {count}")

# Merge + save intermediate
df_new = pd.DataFrame(new)
df_all = pd.concat([df, df_new], ignore_index=True)
df_all.to_csv(FINAL_OUTPUT, index=False)
print(f"Saved: {len(df_all)} foods")
