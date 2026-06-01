"""Batch 10 Part 7: Final push — 680 to 10K."""
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
# 77. TEMPE/TAHU/ONCOM × ALL COOKING STYLES (more depth)
# ================================================================
tt = {
    "Tahu Putih": (75, 8.0, 4.5, 2.0, 0.5, 7, 1.0),
    "Tahu Kuning": (80, 8.5, 5.0, 2.0, 0.5, 10, 1.0),
    "Tahu Sutra": (60, 6.0, 3.5, 2.0, 0.5, 5, 0.5),
    "Tahu Cina": (90, 9.0, 5.5, 2.0, 0.5, 8, 1.0),
    "Tempe Kedelai": (120, 12.0, 6.0, 8.0, 0.5, 5, 3.5),
    "Tempe Gembus": (80, 6.0, 3.5, 6.0, 0.5, 5, 3.0),
    "Tempe Bongkrek": (100, 8.0, 4.5, 7.0, 0.5, 5, 3.0),
    "Oncom Hitam": (90, 7.0, 4.5, 6.0, 0.5, 5, 3.0),
}
tt_styles = {
    "Bumbu Bali": (1.4, 1.1, 1.4, 1.2, 1.1, 1.5, 1.0),
    "Bumbu Kecap": (1.3, 1.1, 1.2, 1.2, 1.3, 2.0, 1.0),
    "Bumbu Taoco": (1.3, 1.2, 1.3, 1.1, 1.0, 2.5, 1.0),
    "Bumbu Asam": (1.2, 1.1, 1.2, 1.1, 1.0, 1.5, 1.0),
    "Bumbu Pedas": (1.3, 1.1, 1.3, 1.1, 1.0, 1.5, 1.0),
    "Bumbu Rendang": (1.5, 1.1, 1.8, 1.2, 1.0, 1.5, 1.0),
    "Bumbu Opor": (1.4, 1.1, 1.6, 1.1, 1.0, 1.3, 1.0),
    "Bumbu Semur": (1.3, 1.1, 1.3, 1.2, 1.3, 2.0, 1.0),
    "Bumbu Teriyaki": (1.3, 1.2, 1.2, 1.2, 1.2, 2.0, 1.0),
    "Bumbu Lada Hitam": (1.3, 1.2, 1.3, 1.1, 1.0, 1.8, 1.0),
    "Bumbu Mentega": (1.5, 1.1, 2.0, 1.1, 1.0, 1.3, 1.0),
    "Krispi": (1.6, 1.1, 2.5, 1.3, 1.0, 1.5, 1.0),
}
for tname, (tc, tp, tf, tcb, ts, tso, tfb) in tt.items():
    for sname, (sc, sp, sf, scb, ss, sso, sfb) in tt_styles.items():
        name = f"{tname} {sname}"
        cal = round(tc * sc)
        prot = round(tp * sp, 1)
        fat = round(tf * sf, 1)
        carbs = round(tcb * scb, 1)
        sug = round(ts * ss, 1)
        sod = round(tso * sso)
        fib = round(tfb * sfb, 1)
        if add(name, cal, prot, fat, carbs, sug, sod, fib, "local_indonesian", "gen-batch10"):
            count += 1

# ================================================================
# 78. ALL BASE INGREDIENTS × GORENG/BAKAR/KUKUS
# ================================================================
base_cook = {
    "Ayam": (180, 22, 10, 0, 0, 55, 0),
    "Daging Sapi": (180, 26, 8, 0, 0, 55, 0),
    "Ikan Mas": (130, 20, 5, 0, 0, 50, 0),
    "Ikan Nila": (125, 21, 4.5, 0, 0, 50, 0),
    "Ikan Lele": (140, 18, 7, 0, 0, 55, 0),
    "Ikan Patin": (150, 18, 8, 0, 0, 50, 0),
    "Ikan Mujair": (130, 20, 5, 0, 0, 50, 0),
    "Udang": (100, 20, 1.5, 1, 0, 150, 0),
    "Cumi": (80, 16, 1.0, 2, 0, 140, 0),
}
cook_methods = {
    "Goreng Crispy": (2.0, 1.1, 2.5, 1.5, 1.0, 1.5, 1.0),
    "Goreng Bumbu": (1.6, 1.1, 2.0, 1.3, 1.0, 1.5, 1.0),
    "Bakar Madu": (1.3, 1.1, 1.1, 1.2, 1.3, 1.5, 1.0),
    "Bakar Sambal": (1.3, 1.2, 1.2, 1.1, 1.0, 1.5, 1.0),
    "Kukus": (1.0, 1.1, 1.0, 1.0, 1.0, 1.0, 1.0),
    "Kukus Jahe": (1.05, 1.1, 1.0, 1.0, 1.0, 1.2, 1.0),
    "Kukus Bumbu": (1.1, 1.1, 1.1, 1.05, 1.0, 1.3, 1.0),
    "Rebus": (1.0, 1.05, 0.9, 1.0, 1.0, 1.0, 1.0),
    "Panggang Oven": (1.1, 1.1, 1.05, 1.0, 1.0, 1.2, 1.0),
}
for bname, (bc, bp, bf, bcb, bs, bso, bfb) in base_cook.items():
    for cname, (cc, cp, cf, ccb, cs, cso, cfb) in cook_methods.items():
        name = f"{bname} {cname}"
        cal = round(bc * cc)
        prot = round(bp * cp, 1)
        fat = round(bf * cf, 1)
        carbs = round(bcb * ccb, 1)
        sug = round(bs * cs, 1)
        sod = round(bso * cso)
        fib = round(bfb * cfb, 1)
        if add(name, cal, prot, fat, carbs, sug, sod, fib, "base_food", "gen-batch10"):
            count += 1

# ================================================================
# 79. KENTANG × METHODS
# ================================================================
potato_base = [
    ("Kentang Goreng Bumbu", 320, 4, 16, 40, 3, 300, 3, "snack"),
    ("Kentang Wedges", 300, 4, 14, 38, 3, 280, 4, "snack"),
    ("Kentang Panggang Keju", 280, 6, 12, 34, 4, 350, 4, "other"),
    ("Kentang Panggang Sour Cream", 260, 5, 10, 34, 4, 300, 4, "other"),
    ("Kentang Tumbuk", 200, 4, 8, 28, 3, 350, 3, "other"),
    ("Kentang Tumbuk Keju", 220, 6, 10, 28, 3, 380, 3, "other"),
    ("Kentang Saus Bolognese", 320, 8, 14, 38, 5, 450, 4, "other"),
    ("Kentang Goreng Saus Keju", 350, 6, 18, 40, 4, 400, 3, "other"),
    ("Perkedel Kentang Daging", 200, 10, 10, 18, 3, 350, 2, "snack"),
    ("Perkedel Kentang Kornet", 220, 10, 12, 18, 3, 380, 2, "snack"),
    ("Perkedel Kentang Ayam", 200, 12, 9, 18, 3, 350, 2, "snack"),
    ("Stik Kentang", 300, 4, 14, 38, 3, 300, 3, "snack"),
    ("Stik Kentang Keju", 320, 6, 16, 36, 3, 350, 3, "snack"),
    ("Croquette Kentang", 250, 8, 12, 26, 3, 350, 3, "snack"),
    ("Gratin Kentang", 300, 8, 16, 30, 5, 420, 4, "other"),
    ("Baked Potato Isi Daging", 350, 16, 14, 38, 5, 450, 5, "other"),
    ("Baked Potato Isi Tuna", 320, 16, 10, 38, 4, 450, 5, "other"),
    ("Baked Potato Isi Keju Brokoli", 300, 10, 12, 36, 5, 400, 6, "other"),
]
for item in potato_base:
    if add(*item, "gen-batch10"): count += 1

# ================================================================
# 80. UBI / SINGKONG / TALAS BASE
# ================================================================
ubi_ext = [
    ("Ubi Jalar Rebus", 100, 2, 0.3, 22, 5, 20, 4, "base_food"),
    ("Ubi Jalar Bakar", 120, 2, 0.5, 26, 6, 20, 4, "base_food"),
    ("Ubi Jalar Goreng", 220, 2, 8, 32, 8, 80, 4, "snack"),
    ("Ubi Ungu Rebus", 110, 2, 0.3, 24, 5, 20, 4, "base_food"),
    ("Ubi Ungu Kukus", 110, 2, 0.3, 24, 5, 20, 4, "base_food"),
    ("Ubi Ungu Goreng", 230, 2, 9, 34, 8, 80, 4, "snack"),
    ("Ubi Cilembu Bakar", 140, 2, 0.5, 30, 8, 20, 5, "snack"),
    ("Singkong Rebus", 120, 1, 0.3, 28, 3, 20, 3, "base_food"),
    ("Singkong Kukus", 120, 1, 0.3, 28, 3, 20, 3, "base_food"),
    ("Singkong Bakar", 140, 1, 0.5, 30, 4, 20, 3, "base_food"),
    ("Singkong Goreng Bumbu", 250, 3, 10, 36, 4, 150, 3, "snack"),
    ("Singkong Keju", 280, 3, 12, 36, 5, 200, 3, "snack"),
    ("Singkong Thailand", 280, 3, 12, 38, 16, 150, 3, "snack"),
    ("Talas Rebus", 110, 2, 0.3, 24, 3, 20, 3, "base_food"),
    ("Talas Goreng", 240, 2, 9, 34, 4, 100, 3, "snack"),
    ("Talas Goreng Bumbu", 250, 3, 10, 34, 4, 120, 3, "snack"),
    ("Talas Kukus", 110, 2, 0.3, 24, 3, 20, 3, "base_food"),
    ("Bola Ubi", 200, 3, 7, 30, 8, 80, 3, "snack"),
    ("Kue Timus", 180, 2, 5, 30, 12, 50, 4, "snack"),
    ("Kue Biji Salak", 180, 2, 5, 30, 14, 50, 4, "snack"),
]
for item in ubi_ext:
    if add(*item, "gen-batch10"): count += 1

# ================================================================
# 81. SAMBAL VARIANTS (as side dishes)
# ================================================================
sambal_list = [
    ("Sambal Terasi", 50, 2, 3, 5, 3, 350, 2, "other"),
    ("Sambal Bawang", 60, 2, 4, 5, 2, 300, 1, "other"),
    ("Sambal Tomat", 40, 1, 2, 6, 4, 250, 2, "other"),
    ("Sambal Ijo", 50, 2, 3, 5, 2, 300, 2, "other"),
    ("Sambal Matah", 60, 2, 4, 5, 2, 280, 2, "other"),
    ("Sambal Dabu-Dabu", 50, 2, 3, 5, 2, 300, 2, "other"),
    ("Sambal Colo-Colo", 50, 2, 3, 5, 2, 300, 2, "other"),
    ("Sambal Ganja", 60, 2, 4, 5, 3, 300, 2, "other"),
    ("Sambal Tempoyak", 60, 2, 4, 6, 3, 320, 2, "other"),
    ("Sambal Andaliman", 50, 2, 3, 5, 2, 300, 2, "other"),
    ("Sambal Embe", 70, 3, 5, 4, 2, 300, 1, "other"),
    ("Sambal Roa", 80, 5, 5, 4, 2, 350, 1, "other"),
    ("Sambal Cumi", 80, 6, 4, 6, 3, 400, 2, "other"),
    ("Sambal Udang", 80, 6, 4, 6, 3, 380, 2, "other"),
    ("Sambal Pete", 70, 3, 5, 6, 3, 300, 3, "other"),
    ("Sambal Jengkol", 90, 4, 5, 8, 3, 320, 3, "other"),
    ("Sambal Goreng Hati", 150, 10, 8, 10, 4, 400, 2, "other"),
    ("Sambal Goreng Kentang", 150, 4, 8, 16, 4, 350, 3, "other"),
    ("Sambal Goreng Tempe", 160, 8, 8, 12, 4, 380, 3, "other"),
    ("Sambal Goreng Tahu", 140, 8, 7, 10, 4, 380, 3, "other"),
    ("Sambal Goreng Campur", 160, 8, 8, 14, 4, 380, 3, "other"),
    ("Sambal Bajak", 60, 2, 4, 6, 4, 320, 2, "other"),
    ("Sambal Kecap", 40, 2, 0, 8, 6, 500, 1, "other"),
    ("Sambal Belacan", 50, 3, 3, 5, 2, 350, 1, "other"),
    ("Sambal Tumpang", 70, 3, 4, 6, 3, 350, 2, "other"),
]
for item in sambal_list:
    if add(*item, "gen-batch10"): count += 1

# ================================================================
# 82. MORE BEVERAGE/WEDANG VARIANTS
# ================================================================
wedang_ext = [
    ("Wedang Angsle", 180, 3, 5, 28, 16, 40, 2, "beverage"),
    ("Wedang Tape", 150, 2, 3, 28, 14, 30, 2, "beverage"),
    ("Wedang Sambel", 60, 1, 2, 10, 8, 20, 1, "beverage"),
    ("Wedang Pokak", 60, 1, 2, 10, 8, 20, 1, "beverage"),
    ("Wedang Cemoe", 70, 1, 2, 12, 10, 20, 1, "beverage"),
    ("Saraba", 60, 1, 2, 10, 8, 20, 1, "beverage"),
    ("Bir Pletok", 80, 1, 1, 16, 12, 20, 1, "beverage"),
    ("Ginger Ale Lokal", 80, 0, 0, 18, 16, 20, 0, "beverage"),
    ("Sari Jahe Jeruk", 70, 0, 0, 16, 14, 10, 1, "beverage"),
    ("Sari Jahe Madu", 80, 0, 0, 18, 16, 10, 0, "beverage"),
    ("Es Kuwut", 120, 1, 2, 24, 18, 30, 3, "beverage"),
    ("Es Daluman", 100, 1, 2, 20, 16, 30, 2, "beverage"),
    ("Es Aneka Buah", 150, 2, 3, 28, 20, 30, 4, "beverage"),
    ("Es Lidah Buaya", 100, 1, 1, 22, 18, 20, 3, "beverage"),
    ("Es Mangga Kweni", 130, 2, 1, 28, 24, 10, 3, "beverage"),
]
for item in wedang_ext:
    if add(*item, "gen-batch10"): count += 1

# ================================================================
# 83. ROTI / BREAD VARIANTS (more)
# ================================================================
roti_ext = [
    ("Roti Sobek Coklat", 280, 8, 10, 38, 14, 250, 3, "snack"),
    ("Roti Sobek Keju", 280, 8, 10, 36, 10, 280, 2, "snack"),
    ("Roti Sobek Pandan", 260, 7, 8, 38, 12, 220, 2, "snack"),
    ("Roti Sobek Stroberi", 260, 7, 8, 38, 14, 220, 2, "snack"),
    ("Roti Unyil Coklat", 150, 4, 5, 22, 8, 150, 2, "snack"),
    ("Roti Unyil Keju", 150, 4, 5, 20, 6, 180, 2, "snack"),
    ("Roti Unyil Abon", 160, 5, 5, 22, 6, 200, 2, "snack"),
    ("Roti Unyil Sosis", 170, 6, 7, 22, 6, 250, 2, "snack"),
    ("Roti Boy Coklat", 280, 8, 12, 34, 14, 200, 2, "snack"),
    ("Roti Boy Keju", 280, 8, 12, 34, 10, 250, 2, "snack"),
    ("Roti Bluder", 220, 6, 8, 30, 10, 200, 2, "snack"),
    ("Roti Gambang", 200, 5, 6, 30, 10, 150, 3, "snack"),
    ("Roti Sisir", 200, 5, 5, 32, 8, 200, 2, "snack"),
    ("Roti Buaya", 220, 6, 8, 30, 8, 200, 2, "snack"),
    ("Roti Isi Daging", 280, 12, 10, 34, 5, 350, 3, "snack"),
    ("Roti Isi Ayam", 260, 12, 8, 34, 5, 320, 3, "snack"),
    ("Roti Isi Coklat", 250, 6, 8, 36, 14, 200, 2, "snack"),
    ("Roti Isi Keju", 250, 8, 10, 32, 8, 250, 2, "snack"),
    ("Roti Isi Kacang", 240, 8, 10, 32, 10, 200, 3, "snack"),
    ("Roti Isi Pisang", 240, 6, 7, 36, 12, 180, 3, "snack"),
    ("Roti Isi Srikaya", 230, 5, 6, 38, 16, 180, 2, "snack"),
    ("Roti Maryam", 280, 7, 10, 38, 4, 300, 2, "snack"),
    ("Roti Tawar Panggang Keju", 260, 8, 10, 32, 4, 350, 2, "snack"),
    ("Roti Tawar Panggang Coklat", 250, 6, 8, 36, 12, 250, 2, "snack"),
    ("Donat Kentang", 280, 6, 12, 36, 10, 200, 2, "snack"),
    ("Donat Gula Halus", 260, 6, 10, 34, 10, 180, 2, "snack"),
    ("Donat Coklat", 280, 6, 12, 36, 14, 200, 2, "snack"),
    ("Donat Keju", 280, 7, 12, 34, 8, 250, 2, "snack"),
    ("Donat Matcha", 270, 6, 11, 36, 12, 180, 2, "snack"),
    ("Donat Tiramisu", 280, 6, 12, 36, 14, 190, 2, "snack"),
    ("Bagel Keju", 260, 10, 6, 38, 4, 350, 2, "snack"),
    ("Bagel Wijen", 250, 10, 5, 38, 3, 320, 3, "snack"),
    ("Cinnamon Roll", 300, 6, 10, 44, 18, 250, 3, "snack"),
    ("Croissant Almond", 320, 7, 18, 30, 8, 250, 3, "snack"),
    ("Croissant Coklat", 310, 6, 18, 30, 10, 220, 3, "snack"),
    ("Croissant Keju", 310, 8, 20, 28, 4, 300, 2, "snack"),
    ("Danish Pastry", 280, 5, 14, 32, 12, 220, 2, "snack"),
    ("Puff Pastry Ayam", 280, 10, 14, 26, 3, 350, 2, "snack"),
]
for item in roti_ext:
    if add(*item, "gen-batch10"): count += 1

# ================================================================
# 84. TAPE / FERMENTED SWEETS
# ================================================================
tape_items = [
    ("Tape Singkong", 120, 1, 0.3, 28, 10, 10, 2, "snack"),
    ("Tape Singkong Goreng", 200, 3, 8, 30, 12, 50, 2, "snack"),
    ("Tape Ketan", 150, 2, 0.5, 34, 12, 10, 2, "snack"),
    ("Tape Ketan Hijau", 150, 2, 0.5, 34, 12, 10, 2, "snack"),
    ("Tape Uli", 180, 3, 2, 36, 12, 20, 3, "snack"),
    ("Tape Bakar", 160, 2, 1, 34, 14, 10, 3, "snack"),
    ("Proll Tape", 200, 4, 7, 30, 14, 100, 2, "snack"),
    ("Bolu Tape Panggang", 220, 5, 8, 32, 14, 120, 2, "snack"),
    ("Kolak Tape", 200, 2, 6, 34, 16, 50, 3, "other"),
    ("Es Tape", 150, 2, 3, 28, 14, 30, 2, "other"),
    ("Rujak Tape", 160, 2, 3, 30, 14, 30, 2, "snack"),
]
for item in tape_items:
    if add(*item, "gen-batch10"): count += 1

# ================================================================
# 85. MARTABAK VARIANTS (more specific)
# ================================================================
martabak_ext = [
    ("Martabak Telur Ayam", 300, 14, 16, 26, 4, 500, 2, "snack"),
    ("Martabak Telur Sapi", 320, 16, 18, 24, 4, 500, 2, "snack"),
    ("Martabak Telur Spesial", 340, 18, 18, 26, 4, 520, 2, "snack"),
    ("Martabak Manis Coklat Kacang", 340, 8, 16, 38, 18, 220, 3, "snack"),
    ("Martabak Manis Coklat Keju", 350, 9, 18, 38, 16, 270, 2, "snack"),
    ("Martabak Manis Kacang Keju", 350, 10, 18, 36, 14, 250, 3, "snack"),
    ("Martabak Manis Oreo", 340, 7, 16, 40, 20, 220, 2, "snack"),
    ("Martabak Manis Ovomaltine", 340, 8, 16, 40, 20, 220, 2, "snack"),
    ("Martabak Manis Nutella", 360, 8, 18, 42, 22, 220, 2, "snack"),
    ("Martabak Manis Green Tea", 330, 7, 14, 40, 18, 200, 2, "snack"),
    ("Martabak Manis Red Velvet", 340, 8, 16, 40, 20, 220, 2, "snack"),
    ("Martabak Manis Capucino", 330, 7, 15, 40, 18, 200, 2, "snack"),
]
for item in martabak_ext:
    if add(*item, "gen-batch10"): count += 1

# ================================================================
# 86. PUDING / AGAR VARIANTS
# ================================================================
puding_ext = [
    ("Puding Susu", 160, 5, 6, 22, 16, 80, 1, "snack"),
    ("Puding Karamel", 180, 5, 7, 24, 18, 90, 1, "snack"),
    ("Puding Lumut", 170, 5, 6, 24, 16, 80, 2, "snack"),
    ("Puding Busa", 150, 4, 5, 22, 14, 70, 1, "snack"),
    ("Puding Tape", 180, 4, 6, 28, 16, 80, 2, "snack"),
    ("Puding Alpukat", 170, 4, 8, 24, 14, 70, 3, "snack"),
    ("Puding Mangga", 160, 4, 6, 24, 16, 60, 2, "snack"),
    ("Puding Stroberi", 150, 4, 5, 24, 16, 60, 2, "snack"),
    ("Puding Coklat Vla", 200, 6, 9, 26, 18, 120, 2, "snack"),
    ("Puding Zebra", 180, 5, 7, 24, 16, 100, 2, "snack"),
    ("Puding Kopi", 160, 5, 6, 22, 16, 80, 1, "snack"),
    ("Puding Taro", 160, 4, 6, 24, 16, 80, 2, "snack"),
    ("Agar-Agar Santan", 120, 3, 5, 18, 14, 50, 2, "snack"),
    ("Agar-Agar Gula Merah", 120, 2, 3, 22, 18, 40, 2, "snack"),
    ("Agar-Agar Buah", 100, 2, 2, 20, 16, 40, 2, "snack"),
    ("Srikaya", 180, 4, 6, 28, 18, 80, 2, "snack"),
]
for item in puding_ext:
    if add(*item, "gen-batch10"): count += 1

# ================================================================
# 87. MORE IKAN GORENG/BAKAR/PEPES named
# ================================================================
fish_named = [
    ("Ikan Gurame Goreng Sambal Mangga", 320, 22, 16, 20, 4, 400, 2, "local_indonesian"),
    ("Ikan Gurame Goreng Sambal Kecap", 320, 22, 16, 22, 6, 500, 2, "local_indonesian"),
    ("Ikan Nila Goreng Seruit", 300, 22, 12, 22, 4, 420, 2, "local_indonesian"),
    ("Ikan Bawal Goreng Sambal Tomat", 310, 22, 12, 22, 5, 430, 2, "local_indonesian"),
    ("Ikan Kembung Bakar Sambal Dabu", 270, 24, 10, 18, 4, 420, 1, "local_indonesian"),
    ("Ikan Bandeng Bakar Sambal Kecap", 290, 24, 12, 20, 5, 500, 1, "local_indonesian"),
    ("Ikan Bandeng Goreng Lengkuas", 310, 24, 16, 18, 3, 380, 1, "local_indonesian"),
    ("Ikan Patin Goreng Kremes", 300, 18, 16, 20, 3, 350, 1, "local_indonesian"),
    ("Ikan Lele Goreng Sambal Bawang", 280, 22, 14, 18, 4, 380, 2, "local_indonesian"),
    ("Ikan Mujair Goreng Sambal Ijo", 280, 24, 12, 18, 4, 400, 2, "local_indonesian"),
    ("Ikan Kerapu Goreng Asam Manis", 300, 24, 14, 22, 8, 420, 1, "local_indonesian"),
    ("Ikan Kakap Goreng Sambal Matah", 290, 24, 12, 20, 4, 400, 1, "local_indonesian"),
    ("Ikan Kembung Goreng Bumbu Kuning", 280, 24, 14, 18, 4, 400, 1, "local_indonesian"),
    ("Ikan Tongkol Goreng Balado", 300, 24, 14, 18, 5, 450, 2, "local_indonesian"),
    ("Ikan Cakalang Goreng Rica-Rica", 310, 28, 14, 18, 4, 480, 2, "local_indonesian"),
    ("Pepes Ikan Kembung Bumbu Kuning", 230, 22, 10, 14, 3, 380, 2, "local_indonesian"),
    ("Pepes Ikan Mas Bumbu Kuning", 240, 22, 10, 14, 3, 380, 2, "local_indonesian"),
    ("Pepes Ikan Nila Kemangi", 240, 24, 8, 14, 3, 380, 2, "local_indonesian"),
]
for item in fish_named:
    if add(*item, "gen-batch10"): count += 1

# ================================================================
# 88. PORRIDGE / CREAM SOUP INTERNATIONAL
# ================================================================
cream_soup = [
    ("Cream of Mushroom Soup", 160, 4, 10, 14, 3, 480, 2, "other"),
    ("Cream of Chicken Soup", 180, 10, 10, 14, 3, 500, 1, "other"),
    ("Cream of Celery Soup", 120, 3, 8, 12, 4, 450, 3, "other"),
    ("Cream of Asparagus Soup", 130, 4, 7, 14, 3, 420, 4, "other"),
    ("Cream of Corn Soup", 160, 4, 7, 22, 6, 400, 4, "other"),
    ("Cream of Cauliflower Soup", 120, 4, 7, 12, 4, 400, 4, "other"),
    ("Cream of Pumpkin Soup", 140, 3, 6, 20, 6, 380, 5, "other"),
    ("Cream of Spinach Soup", 110, 5, 6, 10, 3, 420, 5, "other"),
    ("Cream of Tomato Soup", 120, 4, 6, 14, 8, 450, 4, "other"),
    ("Butternut Squash Soup", 150, 4, 5, 24, 8, 400, 5, "other"),
    ("Sweet Potato Soup", 160, 4, 5, 26, 8, 380, 5, "other"),
]
for item in cream_soup:
    if add(*item, "gen-batch10"): count += 1

# ================================================================
# 89. NASI GORENG / MIE GORENG MORE SPECIFIC
# ================================================================
nasi_goreng_ext = [
    ("Nasi Goreng Jawa", 360, 10, 12, 46, 4, 500, 3, "local_indonesian"),
    ("Nasi Goreng Sunda", 360, 10, 12, 46, 4, 480, 3, "local_indonesian"),
    ("Nasi Goreng Padang", 380, 12, 14, 46, 4, 520, 3, "local_indonesian"),
    ("Nasi Goreng Aceh", 380, 14, 14, 46, 4, 550, 3, "local_indonesian"),
    ("Nasi Goreng Bali", 370, 12, 14, 46, 4, 520, 3, "local_indonesian"),
    ("Nasi Goreng Manado", 380, 14, 14, 46, 4, 550, 3, "local_indonesian"),
    ("Nasi Goreng Makassar", 380, 14, 14, 46, 4, 530, 3, "local_indonesian"),
    ("Nasi Goreng Surabaya", 370, 12, 14, 46, 4, 520, 3, "local_indonesian"),
    ("Nasi Goreng Semarang", 370, 12, 14, 46, 4, 500, 3, "local_indonesian"),
    ("Nasi Goreng Yogya", 370, 12, 14, 46, 4, 500, 3, "local_indonesian"),
    ("Mie Goreng Jawa", 400, 12, 14, 48, 5, 580, 3, "local_indonesian"),
    ("Mie Goreng Sunda", 400, 12, 14, 48, 5, 560, 3, "local_indonesian"),
    ("Mie Goreng Aceh", 420, 14, 14, 50, 5, 600, 3, "local_indonesian"),
    ("Mie Goreng Bali", 410, 14, 14, 48, 5, 600, 3, "local_indonesian"),
    ("Mie Goreng Medan", 410, 14, 14, 50, 5, 580, 3, "local_indonesian"),
    ("Mie Goreng Palembang", 420, 14, 14, 50, 5, 600, 3, "local_indonesian"),
    ("Bihun Goreng Jawa", 350, 8, 10, 50, 5, 520, 3, "local_indonesian"),
    ("Bihun Goreng Singapore", 380, 10, 12, 50, 5, 550, 3, "other"),
    ("Kwetiau Goreng Aceh", 420, 14, 14, 52, 5, 600, 3, "local_indonesian"),
    ("Kwetiau Goreng Spesial", 440, 16, 16, 52, 5, 620, 3, "other"),
]
for item in nasi_goreng_ext:
    if add(*item, "gen-batch10"): count += 1

# ================================================================
# 90. FINAL: ANY REMAINING GAPS (bulk)
# ================================================================
gaps = [
    ("Daging Sapi Asam Manis", 340, 26, 14, 22, 8, 450, 2, "other"),
    ("Daging Sapi Bakar", 320, 28, 12, 18, 3, 400, 1, "other"),
    ("Daging Sapi Goreng", 350, 26, 18, 16, 3, 400, 1, "other"),
    ("Daging Sapi Kuah", 280, 24, 12, 16, 3, 500, 2, "other"),
    ("Daging Sapi Tumis", 330, 26, 14, 18, 4, 480, 2, "other"),
    ("Daging Kambing Bakar", 320, 26, 14, 14, 3, 420, 1, "other"),
    ("Daging Kambing Goreng", 350, 24, 18, 14, 3, 420, 1, "other"),
    ("Daging Kambing Semur", 340, 26, 16, 16, 4, 480, 2, "other"),
    ("Daging Kambing Kecap", 340, 26, 14, 18, 6, 520, 2, "other"),
    ("Daging Kambing Sate", 280, 24, 12, 14, 4, 400, 1, "other"),
    ("Bebek Goreng Rempah", 400, 28, 22, 18, 3, 450, 1, "other"),
    ("Bebek Bakar Kecap", 380, 28, 18, 20, 6, 480, 1, "other"),
    ("Bebek Opor", 380, 26, 20, 18, 4, 450, 2, "other"),
    ("Bebek Gulai", 370, 26, 22, 14, 4, 480, 2, "other"),
    ("Bebek Kalio", 390, 26, 22, 16, 4, 450, 2, "other"),
    ("Bebek Rica-Rica", 380, 28, 20, 16, 4, 500, 2, "other"),
    ("Bebek Woku", 370, 28, 20, 14, 4, 480, 2, "other"),
    ("Sapi Cincang Tumis", 320, 24, 16, 14, 4, 420, 2, "other"),
    ("Sapi Cincang Semur", 340, 24, 18, 16, 5, 480, 2, "other"),
    ("Sapi Cincang Kecap", 340, 24, 16, 18, 6, 520, 2, "other"),
    ("Kikil Goreng", 280, 14, 18, 12, 3, 400, 0, "other"),
    ("Kikil Bakar", 250, 14, 14, 12, 3, 380, 0, "other"),
    ("Kikil Kecap", 280, 14, 16, 14, 6, 480, 0, "other"),
    ("Kikil Bumbu", 260, 14, 15, 14, 4, 450, 1, "other"),
    ("Babat Goreng", 250, 16, 14, 10, 3, 380, 1, "other"),
    ("Babat Bakar", 230, 16, 10, 10, 3, 380, 1, "other"),
    ("Babat Tumis", 240, 16, 12, 12, 4, 420, 2, "other"),
    ("Babat Kecap", 280, 16, 14, 14, 6, 500, 2, "other"),
    ("Rujak Buah Segar", 120, 2, 2, 24, 16, 100, 4, "other"),
    ("Rujak Timun", 80, 2, 2, 14, 10, 300, 3, "other"),
    ("Rujak Mangga", 100, 2, 2, 20, 14, 100, 3, "other"),
    ("Rujak Bengkuang", 80, 2, 2, 14, 10, 80, 4, "other"),
    ("Rujak Nanas", 90, 1, 1, 20, 14, 60, 3, "other"),
]
for item in gaps:
    if add(*item, "gen-batch10"): count += 1

# ================================================================
# SAVE
# ================================================================
print(f"\nPart 7 total new: {count}")
if new:
    ndf = pd.DataFrame(new)
    ndf.to_csv(FINAL_OUTPUT, mode='a', header=False, index=False)
    df = pd.read_csv(FINAL_OUTPUT)
    print(f"Running total: {len(df)} foods")
    print(df["food_type"].value_counts().to_string())
else:
    print("No new foods added!")
