"""Batch 8: Generate 250+ foods to push past 5,000 after dedup."""
import pandas as pd
from config import FINAL_OUTPUT

df = pd.read_csv(FINAL_OUTPUT)
df['serving_size'] = df['serving_size'].fillna('1 porsi')
existing = set(df['name'].str.lower().str.strip())
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

# 1. Ikan × methods (more fish species, more methods)
ikan = {
    "Ikan Kembung": (130, 22, 5, 0, 0, 60, 0),
    "Ikan Bandeng": (140, 18, 7, 0, 0, 55, 0),
    "Ikan Patin": (150, 16, 9, 0, 0, 50, 0),
    "Ikan Tongkol": (145, 21, 6, 0, 0, 65, 0),
    "Ikan Kakap": (105, 19, 2.5, 0, 0, 45, 0),
    "Ikan Kerapu": (100, 18, 2, 0, 0, 40, 0),
    "Ikan Selar": (135, 20, 5.5, 0, 0, 58, 0),
    "Ikan Bawal": (125, 16, 6.5, 0, 0, 50, 0),
    "Ikan Tenggiri": (110, 22, 2, 0, 0, 42, 0),
    "Ikan Cakalang": (140, 23, 4.5, 0, 0, 48, 0),
}
met = {
    "Bumbu Kuning": (1.2, 1.2, 1.0, 1.0, 1.0),
    "Rica-Rica": (1.35, 1.0, 1.8, 1.2, 0.95),
    "Woku": (1.3, 1.0, 1.5, 1.2, 0.95),
    "Kuah Asam": (1.1, 1.0, 1.0, 1.2, 1.0),
    "Pindang": (1.15, 1.0, 1.0, 1.1, 1.0),
    "Tauco": (1.25, 1.0, 1.3, 1.3, 1.0),
}
sv = count
for iname, (cal, prot, fat, carbs, sug, sod, fib) in ikan.items():
    for mname, (cm, fm, pm, cbm, fibm) in met.items():
        if add(f"{iname} {mname}",
               round(cal * cm, 1), round(prot * pm, 1), round(fat * fm, 1),
               round(carbs * cbm, 1), sug, sod, round(fib * fibm, 1),
               "base_food", "gen-batch8"):
            count += 1
print(f"Ikan x methods: +{count - sv}")

# 2. Sayur x methods (more vegetable types)
sayur = {
    "Gambas": (20, 1, 0.2, 4, 1.5, 3, 1.5),
    "Oyong": (20, 1, 0.2, 4, 1.5, 3, 1.5),
    "Kecipir": (45, 4, 1, 6, 0.5, 4, 2.5),
    "Kelor": (65, 7, 1.5, 8, 0.5, 9, 4.0),
    "Genjer": (25, 2, 0.3, 4, 0.5, 20, 2.5),
    "Seledri": (20, 1, 0.3, 3, 1, 80, 1.5),
    "Daun Bawang": (30, 1.8, 0.3, 5, 1.5, 20, 2.0),
    "Daun Kemangi": (35, 4, 0.5, 5, 0.5, 4, 2.5),
    "Kucai": (28, 2.5, 0.4, 4, 0.5, 6, 2.0),
    "Selada Air": (18, 2, 0.2, 2.5, 0.5, 40, 1.2),
}
prep = {
    "Tumis": (1.3, 1.5, 1.0, 1.0, 1.0),
    "Rebus": (1.0, 1.0, 1.0, 1.0, 1.0),
    "Santan": (1.5, 0.9, 2.5, 1.1, 0.9),
    "Kuah Bening": (1.05, 1.0, 1.0, 1.0, 1.0),
}
sv = count
for sname, (cal, prot, fat, carbs, sug, sod, fib) in sayur.items():
    for pname, (cm, pm, fm, cbm, fibm) in prep.items():
        if add(f"{pname} {sname}",
               round(cal * cm, 1), round(prot * pm, 1), round(fat * fm, 1),
               round(carbs * cbm, 1), sug, round(sod * 1.0, 1),
               round(fib * fibm, 1),
               "base_food", "gen-batch8"):
            count += 1
print(f"Sayur x methods: +{count - sv}")

# 3. Tahu/Tempe extended
sv = count
tt = [
    ("Tempe Bumbu Kuning", 170, 14, 10, 12, 1, 250, 3.0),
    ("Tempe Goreng Tepung Crispy", 250, 12, 16, 20, 1, 280, 2.0),
    ("Tempe Bakar", 180, 14, 10, 12, 1, 200, 3.0),
    ("Tempe Saus Tiram", 190, 14, 10, 14, 2, 450, 3.0),
    ("Tempe Lada Hitam", 190, 14, 10, 12, 1, 350, 3.0),
    ("Tempe Asam Manis", 180, 12, 10, 16, 6, 380, 3.0),
    ("Tahu Bakar Kecap", 150, 8, 8, 14, 4, 450, 1.0),
    ("Tahu Bakar Sambal", 160, 8, 10, 12, 2, 400, 1.0),
    ("Tahu Saus Tiram", 160, 8, 10, 14, 2, 500, 1.0),
    ("Tahu Lada Hitam", 160, 8, 10, 12, 1, 400, 1.0),
    ("Tahu Kukus Isi", 140, 10, 6, 12, 2, 300, 1.5),
    ("Tahu Goreng Sambal Kecap", 220, 10, 14, 18, 4, 550, 1.0),
    ("Tahu Goreng Bumbu Bawang", 200, 10, 14, 14, 1, 350, 0.5),
    ("Tahu Krispi", 240, 8, 16, 18, 1, 350, 0.5),
    ("Tahu Cabai Garam", 220, 10, 16, 12, 1, 380, 0.5),
    ("Tahu Asam Manis", 170, 8, 10, 16, 6, 400, 1.0),
    ("Tempe Cabai Garam", 240, 12, 16, 14, 1, 350, 2.5),
    ("Tempe Kukus", 160, 14, 8, 10, 1, 100, 3.0),
    ("Tempe Bumbu Bali", 210, 14, 12, 14, 4, 400, 3.0),
    ("Tempe Semur", 200, 12, 10, 18, 8, 500, 3.0),
]
for name, *nut in tt:
    if add(name, *nut, "local_indonesian", "gen-batch8"):
        count += 1
print(f"Tahu/Tempe ext: +{count - sv}")

# 4. Snacks
sv = count
snacks = [
    ("Bakpia Kacang Hijau", 120, 3, 4, 20, 8, 50, 1.0),
    ("Bakpia Coklat", 140, 3, 6, 22, 12, 60, 1.0),
    ("Bakpia Keju", 150, 4, 7, 20, 8, 80, 0.5),
    ("Yangko", 160, 2, 4, 30, 22, 30, 0.3),
    ("Geplak", 180, 2, 6, 32, 28, 30, 0.5),
    ("Amplang", 250, 8, 14, 24, 2, 400, 0.3),
    ("Kerupuk Ikan", 120, 6, 2, 20, 1, 300, 0),
    ("Kerupuk Udang", 130, 5, 3, 20, 1, 350, 0),
    ("Kerupuk Kulit", 150, 8, 6, 16, 1, 250, 0),
    ("Emping Melinjo", 130, 4, 6, 18, 1, 100, 0.5),
    ("Rengginang", 180, 3, 6, 30, 2, 200, 0.5),
    ("Intip", 160, 3, 4, 30, 1, 150, 0.3),
    ("Peyek Kacang", 200, 6, 14, 14, 1, 250, 1.0),
    ("Peyek Teri", 210, 8, 14, 14, 1, 400, 0.5),
    ("Peyek Udang", 200, 8, 12, 14, 1, 400, 0.3),
    ("Rempeyek Bayam", 180, 4, 12, 16, 1, 250, 1.5),
    ("Sale Pisang", 180, 1, 6, 32, 28, 50, 1.5),
    ("Keripik Pisang", 200, 1, 8, 32, 14, 100, 1.5),
    ("Keripik Singkong", 190, 1, 8, 30, 2, 200, 1.0),
    ("Keripik Tempe", 220, 14, 14, 12, 1, 250, 2.5),
    ("Keripik Kentang", 250, 3, 14, 28, 1, 300, 1.5),
    ("Keripik Ubi", 240, 1, 10, 34, 16, 150, 2.5),
    ("Keripik Bayam", 150, 0.5, 8, 16, 0.5, 200, 1.5),
    ("Kacang Telur", 280, 10, 18, 20, 4, 200, 2.0),
    ("Kacang Bawang", 280, 10, 18, 18, 3, 180, 2.5),
    ("Kacang Atom", 290, 10, 20, 18, 3, 250, 2.0),
    ("Bipang", 220, 4, 8, 34, 22, 80, 1.5),
    ("Madumongso", 220, 2, 8, 38, 28, 40, 1.0),
    ("Dodol Garut", 250, 2, 8, 44, 30, 50, 0.5),
    ("Dodol Betawi", 260, 2, 10, 42, 28, 60, 0.5),
]
for name, *nut in snacks:
    if add(name, *nut, "snack", "gen-batch8"):
        count += 1
print(f"Snacks: +{count - sv}")

# 5. Beverages
sv = count
bevs = [
    ("Es Kacang Hijau Manis", 180, 5, 3, 34, 24, 30, 2.5),
    ("Es Tape Ketan", 200, 2, 4, 40, 28, 30, 1.0),
    ("Es Kolak Durian", 280, 4, 10, 44, 30, 40, 2.5),
    ("Es Kolak Pisang", 260, 3, 8, 46, 30, 30, 2.5),
    ("Es Kolak Ubi", 250, 2, 8, 44, 28, 30, 3.0),
    ("Es Kolak Labu", 240, 2, 8, 42, 24, 30, 3.5),
    ("Setup Roti Tawar", 280, 5, 8, 48, 28, 150, 1.5),
    ("Puding Roti Tawar", 270, 6, 8, 44, 26, 150, 1.5),
    ("Sop Buah", 180, 1, 2, 40, 32, 30, 2.5),
    ("Es Buah Campur", 180, 1, 2, 40, 30, 30, 2.5),
    ("Es Ximilu", 200, 2, 4, 40, 32, 40, 2.0),
    ("Es Kacang Polong", 160, 5, 3, 30, 22, 30, 3.0),
    ("Es Delima", 120, 0.5, 1, 28, 24, 20, 1.0),
    ("Es Kelapa Gula Aren", 160, 1, 3, 34, 28, 40, 2.5),
    ("Sekoteng Jahe", 150, 3, 4, 26, 20, 40, 0.5),
    ("Bajigur Susu", 140, 3, 5, 22, 18, 40, 0.5),
    ("Bandrek Susu", 120, 2, 4, 20, 16, 40, 0.5),
    ("Kopi Jahe", 30, 0.5, 0.5, 6, 3, 10, 0.3),
    ("Teh Telur Madu", 130, 3, 4, 20, 16, 50, 0),
    ("Susu Madu Jahe", 140, 4, 4, 20, 16, 40, 0.3),
    ("Jamu Beras Kencur Telur", 100, 4, 4, 14, 8, 15, 0.5),
    ("Jamu Uyup-Uyup", 70, 2, 2, 14, 6, 10, 0.5),
    ("Jamu Cabe Puyang", 45, 0.5, 0.5, 10, 4, 5, 0.5),
    ("Jamu Kudu Laos", 50, 0.5, 0.3, 12, 4, 5, 0.5),
]
for name, *nut in bevs:
    if add(name, *nut, "beverage", "gen-batch8"):
        count += 1
print(f"Beverages: +{count - sv}")

# 6. Desserts
sv = count
desserts = [
    ("Puding Coklat", 200, 4, 8, 30, 24, 100, 0.5),
    ("Puding Santan", 190, 3, 10, 24, 20, 80, 0.3),
    ("Puding Tape", 180, 2, 5, 32, 22, 60, 0.5),
    ("Puding Kelapa Muda", 160, 2, 5, 28, 22, 50, 0.5),
    ("Puding Jagung", 170, 3, 6, 28, 20, 60, 0.5),
    ("Puding Alpukat", 180, 2, 10, 22, 18, 40, 3.5),
    ("Puding Mangga", 160, 2, 5, 28, 22, 40, 1.0),
    ("Puding Nangka", 170, 2, 5, 30, 22, 40, 1.0),
    ("Agar-Agar Santan", 100, 1, 5, 14, 10, 30, 0),
    ("Agar-Agar Coklat", 120, 2, 4, 20, 16, 40, 0.5),
    ("Jelly Buah", 100, 1, 1, 24, 20, 20, 0.5),
    ("Jelly Yogurt", 90, 2, 2, 18, 14, 40, 0),
    ("Es Krim Kelapa Muda", 180, 2, 10, 22, 18, 50, 1.0),
    ("Es Krim Kacang Merah", 180, 5, 8, 24, 18, 50, 2.5),
]
for name, *nut in desserts:
    if add(name, *nut, "snack", "gen-batch8"):
        count += 1
print(f"Desserts: +{count - sv}")

# 7. Nasi variants
sv = count
nasiplus = [
    ("Nasi Gemuk Ayam", 420, 16, 16, 52, 2, 450, 2.0),
    ("Nasi Gemuk Ikan", 400, 16, 14, 52, 2, 420, 2.0),
    ("Nasi Kebuli Ayam", 450, 18, 18, 52, 2, 500, 2.0),
    ("Nasi Kebuli Kambing", 480, 20, 22, 48, 2, 520, 2.0),
    ("Nasi Mandhi Ayam", 440, 18, 16, 54, 2, 480, 2.0),
    ("Nasi Briyani Ayam", 460, 20, 18, 52, 3, 520, 2.0),
    ("Nasi Briyani Kambing", 490, 22, 22, 48, 3, 540, 2.0),
    ("Nasi Briyani Sayur", 380, 12, 14, 50, 3, 450, 3.0),
    ("Nasi Minyak", 380, 8, 14, 54, 1, 300, 1.0),
    ("Nasi Minyak Ayam", 420, 16, 16, 52, 2, 400, 1.5),
    ("Nasi Arab", 400, 12, 14, 54, 1, 400, 1.5),
    ("Nasi Arab Kambing", 460, 22, 20, 48, 2, 480, 2.0),
    ("Nasi Lemak", 400, 12, 18, 48, 3, 450, 2.0),
    ("Nasi Lemak Ayam", 440, 18, 20, 46, 3, 500, 2.0),
    ("Nasi Sambal Goreng", 420, 14, 16, 52, 4, 500, 2.5),
    ("Nasi Tahu Telur", 400, 16, 16, 48, 4, 550, 2.5),
]
for name, *nut in nasiplus:
    if add(name, *nut, "local_indonesian", "gen-batch8"):
        count += 1
print(f"Nasi variants: +{count - sv}")

# 8. More lauk
sv = count
lauk2 = [
    ("Ayam Bumbu Rujak", 310, 24, 18, 14, 6, 450, 0.5),
    ("Ayam Bumbu Kuning", 280, 24, 14, 12, 2, 420, 0.5),
    ("Ayam Bumbu Bali", 320, 24, 18, 14, 4, 480, 0.5),
    ("Ayam Rica-Rica", 300, 26, 18, 10, 2, 450, 0.5),
    ("Ayam Woku Khas Manado", 310, 26, 18, 10, 2, 480, 0.5),
    ("Ayam Tauco", 300, 24, 16, 14, 2, 500, 0.5),
    ("Ayam Garang Asem", 270, 24, 14, 12, 3, 450, 1.0),
    ("Ayam Kuah Santan", 330, 24, 20, 12, 2, 430, 0.5),
    ("Sapi Bumbu Kuning", 310, 26, 16, 12, 2, 450, 0.5),
    ("Sapi Rica-Rica", 320, 26, 18, 10, 2, 480, 0.5),
    ("Sapi Tauco", 310, 26, 16, 14, 2, 520, 0.5),
    ("Ikan Goreng Bumbu Kuning", 200, 18, 12, 6, 1, 380, 0),
    ("Ikan Goreng Bumbu Laos", 210, 18, 14, 6, 1, 400, 0),
    ("Ikan Goreng Bumbu Ketumbar", 200, 18, 12, 6, 1, 380, 0),
    ("Ikan Goreng Tepung Panir", 250, 18, 16, 14, 1, 400, 0.5),
    ("Udang Goreng Mentega", 250, 18, 16, 10, 1, 380, 0.5),
    ("Cumi Goreng Mentega", 260, 14, 18, 12, 1, 400, 0.3),
    ("Sapi Goreng Mentega", 330, 26, 22, 10, 1, 350, 0),
    ("Ayam Goreng Mentega", 320, 24, 20, 10, 1, 400, 0.3),
    ("Telur Goreng Mentega", 200, 10, 16, 4, 0.5, 200, 0),
]
for name, *nut in lauk2:
    if add(name, *nut, "local_indonesian", "gen-batch8"):
        count += 1
print(f"Lauk ext: +{count - sv}")

# 9. More food items to reach 5,000
sv = count
misc = [
    ("Sambal Goreng Krecek Tahu", 220, 10, 14, 16, 3, 500, 2.0),
    ("Sambal Goreng Tempe Teri", 230, 14, 14, 16, 2, 600, 2.5),
    ("Sambal Goreng Kentang Tempe", 210, 10, 14, 16, 2, 400, 2.0),
    ("Sayur Bening Bayam Jagung", 50, 3, 1, 10, 2, 200, 3.0),
    ("Sayur Bening Bayam Labu", 45, 2.5, 1, 8, 2, 180, 3.0),
    ("Sayur Bening Gambas", 40, 2, 1, 8, 2, 150, 2.5),
    ("Sayur Bening Oyong", 40, 2, 1, 8, 2, 150, 2.5),
    ("Sayur Asam Pepaya Muda", 90, 3, 2, 14, 3, 300, 3.5),
    ("Sayur Asam Nangka Muda", 100, 4, 3, 16, 3, 350, 4.0),
    ("Sayur Lodeh Klaten", 190, 8, 12, 18, 4, 400, 3.5),
    ("Sayur Lodeh Ndeso", 180, 8, 10, 18, 4, 380, 3.5),
    ("Sayur Bobor Bayam", 110, 5, 6, 12, 2, 250, 3.0),
    ("Sayur Bobor Kangkung", 100, 5, 6, 12, 2, 250, 3.0),
    ("Sayur Bobor Daun Singkong", 120, 6, 6, 14, 2, 250, 3.5),
    ("Sayur Bobor Labu", 100, 4, 6, 10, 2, 220, 3.0),
    ("Sayur Menir", 80, 3, 3, 12, 2, 200, 3.0),
    ("Orak-Arik Telur", 200, 10, 14, 8, 2, 250, 0.5),
    ("Orak-Arik Tempe", 190, 12, 10, 14, 2, 250, 3.0),
    ("Orak-Arik Tahu", 170, 8, 10, 14, 2, 250, 1.5),
    ("Orak-Arik Bayam", 150, 8, 10, 10, 2, 250, 3.0),
    ("Buntil Daun Talas", 160, 10, 8, 14, 2, 300, 3.0),
    ("Buntil Daun Pepaya", 150, 8, 8, 14, 2, 280, 3.5),
    ("Brongkos", 220, 12, 10, 22, 3, 400, 3.5),
    ("Gudeg Manggar", 300, 8, 12, 40, 16, 350, 4.0),
    ("Garang Asem", 220, 18, 12, 12, 3, 450, 1.5),
    ("Timlo Solo", 280, 14, 10, 32, 3, 500, 2.0),
    ("Sop Manten", 260, 12, 10, 30, 3, 450, 2.5),
    ("Trancam", 100, 5, 4, 12, 3, 200, 3.5),
    ("Kulupan", 90, 4, 3, 12, 3, 200, 3.5),
    ("Urap-Urap", 140, 6, 8, 14, 3, 250, 4.0),
]
for name, *nut in misc:
    if add(name, *nut, "local_indonesian", "gen-batch8"):
        count += 1
print(f"Misc: +{count - sv}")

# Merge and save
df_new = pd.DataFrame(new)
df_all = pd.concat([df, df_new], ignore_index=True)
df_all.to_csv(FINAL_OUTPUT, index=False)

print(f"\nBatch 8 generated: {len(new)} new foods")
print(f"Final total: {len(df_all)} foods")
print(df_all["food_type"].value_counts())
