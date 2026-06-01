"""Batch 10 Part 6: Final push 10,000 — massive cross-products + gaps."""
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
# 61. AFRICAN FOODS
# ================================================================
african = [
    ("Nasi Jollof Afrika", 380, 10, 8, 58, 5, 450, 3, "other"),
    ("Nasi Pilau Afrika", 420, 14, 12, 54, 4, 480, 3, "other"),
    ("Bobotie Afrika", 380, 22, 14, 24, 8, 500, 3, "other"),
    ("Bunny Chow", 450, 20, 16, 48, 6, 550, 4, "other"),
    ("Piri Piri Ayam Afrika", 350, 28, 14, 18, 4, 500, 2, "other"),
    ("Fufu Afrika", 200, 3, 1, 44, 2, 150, 3, "other"),
    ("Egusi Soup Afrika", 250, 12, 14, 18, 4, 480, 5, "other"),
    ("Suya Daging Afrika", 320, 28, 14, 14, 4, 450, 2, "other"),
    ("Chapati Afrika", 200, 6, 3, 36, 2, 250, 3, "other"),
    ("Injera Ethiopia", 180, 5, 2, 36, 2, 200, 4, "other"),
    ("Doro Wat Ethiopia", 350, 26, 14, 20, 4, 480, 3, "other"),
    ("Tagine Maroko", 380, 24, 14, 28, 8, 500, 4, "other"),
    ("Couscous Maroko", 250, 8, 3, 42, 4, 300, 4, "other"),
    ("Harira Soup Maroko", 200, 10, 4, 28, 5, 480, 5, "other"),
]
for item in african:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 62. SOUTH AMERICAN FOODS
# ================================================================
south_america = [
    ("Feijoada Brasil", 450, 28, 18, 40, 4, 600, 8, "other"),
    ("Churrasco Brasil", 380, 32, 18, 14, 3, 400, 1, "other"),
    ("Moqueca Brasil", 300, 22, 14, 20, 5, 500, 3, "other"),
    ("Empanada Argentina", 250, 10, 12, 24, 3, 380, 2, "snack"),
    ("Asado Argentina", 420, 30, 20, 16, 3, 400, 1, "other"),
    ("Chimichurri Sapi", 320, 26, 14, 14, 3, 380, 1, "other"),
    ("Ceviche Peru", 150, 20, 3, 10, 3, 400, 2, "other"),
    ("Lomo Saltado Peru", 400, 26, 14, 36, 5, 580, 4, "other"),
    ("Aji Gallina Peru", 350, 22, 16, 24, 5, 450, 3, "other"),
    ("Arepas Kolombia", 280, 8, 8, 38, 4, 350, 4, "other"),
    ("Bandeja Paisa", 550, 32, 24, 44, 6, 650, 5, "other"),
    ("Cazuela Chili", 320, 22, 14, 24, 5, 500, 4, "other"),
]
for item in south_america:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 63. EUROPEAN FOODS (beyond Italian)
# ================================================================
european = [
    ("Paella Spanyol", 480, 24, 14, 56, 5, 550, 4, "other"),
    ("Tapas Spanyol", 380, 18, 16, 32, 5, 500, 4, "other"),
    ("Tortilla Spanyol", 280, 12, 12, 28, 4, 400, 3, "other"),
    ("Patatas Bravas", 250, 4, 12, 32, 3, 400, 4, "other"),
    ("Schnitzel Jerman", 420, 26, 18, 36, 3, 450, 2, "other"),
    ("Bratwurst Jerman", 380, 16, 24, 20, 3, 550, 1, "other"),
    ("Sauerkraut Jerman", 30, 2, 0, 5, 2, 500, 4, "other"),
    ("Currywurst Jerman", 420, 18, 26, 24, 6, 650, 3, "other"),
    ("Moules Frites Belgia", 380, 24, 14, 36, 4, 600, 4, "other"),
    ("Croque Monsieur", 350, 18, 16, 28, 4, 550, 2, "other"),
    ("Ratatouille Prancis", 120, 4, 5, 18, 7, 300, 5, "other"),
    ("Coq Au Vin", 380, 30, 16, 20, 5, 500, 3, "other"),
    ("Beef Bourguignon", 400, 28, 18, 24, 5, 520, 4, "other"),
    ("Fish Chips Inggris", 450, 22, 20, 42, 3, 500, 3, "other"),
    ("Shepherd Pie", 420, 22, 18, 38, 5, 550, 5, "other"),
    ("Bangers Mash", 450, 18, 22, 40, 5, 600, 4, "other"),
    ("Goulash Hongaria", 350, 26, 14, 24, 5, 500, 4, "other"),
    ("Pierogi Polandia", 300, 10, 8, 44, 4, 400, 3, "other"),
    ("Kielbasa Polandia", 380, 18, 24, 18, 3, 550, 1, "other"),
    ("Moussaka Yunani", 380, 20, 18, 30, 6, 500, 4, "other"),
    ("Souvlaki Yunani", 320, 24, 14, 22, 4, 480, 3, "other"),
    ("Tzatziki Yunani", 80, 4, 6, 4, 3, 200, 1, "other"),
    ("Gyros Yunani", 380, 24, 16, 30, 5, 550, 3, "other"),
    ("Falafel Plate", 320, 12, 10, 42, 5, 500, 7, "other"),
]
for item in european:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 64. AYAM BUMBU × BASE (40+ more)
# ================================================================
ayam_base = {
    "Ayam": (180, 22, 10, 0, 0, 55, 0),
    "Ayam Kampung": (160, 24, 6, 0, 0, 50, 0),
    "Ayam Pejantan": (170, 23, 7, 0, 0, 52, 0),
}
ayam_bumbu = {
    "Bumbu Kuning": (1.4, 1.1, 1.5, 1.2, 1.0, 1.5, 1.0),
    "Bumbu Laos": (1.3, 1.1, 1.3, 1.2, 1.0, 1.4, 1.0),
    "Bumbu Jahe": (1.2, 1.1, 1.2, 1.1, 1.0, 1.4, 1.0),
    "Bumbu Serai": (1.3, 1.1, 1.3, 1.1, 1.0, 1.5, 1.0),
    "Bumbu Kemangi": (1.2, 1.1, 1.2, 1.1, 1.0, 1.3, 1.2),
    "Bumbu Jeruk": (1.2, 1.1, 1.2, 1.1, 1.1, 1.3, 1.0),
    "Bumbu Ketumbar": (1.3, 1.1, 1.3, 1.2, 1.0, 1.4, 1.0),
    "Bumbu Kencur": (1.2, 1.1, 1.2, 1.2, 1.0, 1.4, 1.0),
    "Bumbu Kunyit": (1.2, 1.1, 1.2, 1.1, 1.0, 1.3, 1.0),
    "Bumbu Merica": (1.2, 1.2, 1.1, 1.1, 1.0, 1.3, 1.0),
    "Bumbu Pala": (1.2, 1.1, 1.2, 1.1, 1.0, 1.3, 1.0),
    "Bumbu Kayu Manis": (1.2, 1.1, 1.2, 1.1, 1.1, 1.3, 1.0),
    "Bumbu Cengkeh": (1.2, 1.1, 1.2, 1.1, 1.0, 1.3, 1.0),
    "Bumbu Andaliman": (1.2, 1.1, 1.2, 1.1, 1.0, 1.4, 1.0),
}
for aname, (ac, ap, af, acb, as_, aso, afb) in ayam_base.items():
    for bname, (bc, bp, bf, bcb, bs, bso, bfb) in ayam_bumbu.items():
        # Goreng variants
        name = f"{aname} Goreng {bname}"
        cal = round(ac * bc * 1.3)
        prot = round(ap * bp, 1)
        fat = round(af * bf * 1.3, 1)
        carbs = round(acb * bcb, 1)
        sug = round(as_ * bs, 1)
        sod = round(aso * bso)
        fib = round(afb * bfb, 1)
        if add(name, cal, prot, fat, carbs, sug, sod, fib, "base_food", "gen-batch10"):
            count += 1
        # Bakar variants
        name2 = f"{aname} Bakar {bname}"
        cal2 = round(ac * bc * 1.15)
        prot2 = round(ap * bp, 1)
        fat2 = round(af * bf * 1.1, 1)
        carbs2 = round(acb * bcb, 1)
        sug2 = round(as_ * bs, 1)
        sod2 = round(aso * bso)
        fib2 = round(afb * bfb, 1)
        if add(name2, cal2, prot2, fat2, carbs2, sug2, sod2, fib2, "base_food", "gen-batch10"):
            count += 1

# ================================================================
# 65. IKAN × ALL 34 PROVINCE STYLES
# ================================================================
fish_base_items = {
    "Ikan Mas": (130, 20, 5, 0, 0, 50, 0),
    "Ikan Lele": (140, 18, 7, 0, 0, 55, 0),
    "Ikan Gabus": (120, 23, 3, 0, 0, 50, 0),
    "Ikan Bawal": (145, 20, 7, 0, 0, 50, 0),
    "Ikan Bandeng": (150, 22, 6, 0, 0, 55, 0),
}
fish_styles = {
    "Bumbu Acar": (1.25, 1.1, 1.25, 1.2, 1.1, 1.5, 1.0),
    "Bumbu Tomat": (1.20, 1.1, 1.2, 1.2, 1.1, 1.4, 1.0),
    "Bumbu Rujak": (1.30, 1.1, 1.3, 1.2, 1.1, 1.4, 1.0),
    "Bumbu Woku": (1.25, 1.15, 1.25, 1.15, 1.0, 1.5, 1.2),
    "Bumbu Rica": (1.30, 1.15, 1.3, 1.1, 1.0, 1.5, 1.0),
    "Kuah Pindang": (1.15, 1.1, 1.1, 1.1, 1.0, 1.8, 1.0),
    "Bumbu Sarden": (1.30, 1.1, 1.4, 1.2, 1.1, 2.0, 1.0),
    "Bumbu Colo-Colo": (1.15, 1.1, 1.2, 1.1, 1.0, 1.4, 1.0),
    "Bumbu Dabu-Dabu": (1.15, 1.1, 1.2, 1.1, 1.0, 1.4, 1.0),
    "Kuah Pliek U": (1.20, 1.1, 1.3, 1.1, 1.0, 1.5, 1.0),
    "Bumbu Tempoyak": (1.25, 1.1, 1.3, 1.15, 1.0, 1.6, 1.0),
    "Kuah Laksa": (1.30, 1.15, 1.5, 1.2, 1.0, 1.6, 1.0),
    "Bumbu Serundeng": (1.30, 1.2, 1.5, 1.2, 1.1, 1.4, 1.2),
    "Bumbu Panggang": (1.15, 1.1, 1.1, 1.1, 1.0, 1.4, 1.0),
}
for fname, (fc, fp, ff, fcb, fs, fso, ffb) in fish_base_items.items():
    for sname, (sc, sp, sf, scb, ss, sso, sfb) in fish_styles.items():
        name = f"{fname} {sname}"
        cal = round(fc * sc)
        prot = round(fp * sp, 1)
        fat = round(ff * sf, 1)
        carbs = round(fcb * scb, 1)
        sug = round(fs * ss, 1)
        sod = round(fso * sso)
        fib = round(ffb * sfb, 1)
        if add(name, cal, prot, fat, carbs, sug, sod, fib, "local_indonesian", "gen-batch10"):
            count += 1

# ================================================================
# 66. TUMIS / OLAHAN SAYUR MASSIVE
# ================================================================
veg = {
    "Kangkung": (28, 2.5, 0.4, 3.5, 0.5, 30, 2.0),
    "Bayam": (23, 2.5, 0.4, 3.5, 0.5, 70, 1.5),
    "Kacang Panjang": (30, 2.5, 0.3, 5.0, 0.5, 10, 2.5),
    "Taoge": (25, 3.0, 0.3, 4.0, 0.5, 15, 1.5),
    "Jamur Tiram": (30, 3.0, 0.3, 3.5, 1.0, 20, 2.5),
    "Jamur Kuping": (28, 2.5, 0.2, 4.0, 1.0, 15, 3.0),
    "Jamur Merang": (25, 2.5, 0.2, 3.5, 1.0, 15, 2.5),
    "Jamur Kancing": (30, 3.0, 0.3, 3.0, 1.5, 20, 2.0),
    "Jagung Muda": (35, 2.0, 0.5, 6.0, 2.0, 10, 2.5),
    "Kapri": (40, 3.5, 0.3, 6.5, 2.5, 5, 3.5),
    "Kembang Kol": (25, 2.0, 0.3, 4.0, 2.0, 30, 2.0),
    "Terong Hijau": (25, 1.0, 0.2, 5.0, 3.0, 5, 2.5),
    "Rebung": (30, 3.0, 0.4, 4.5, 1.0, 15, 3.0),
    "Pepaya Muda": (25, 1.5, 0.2, 5.0, 2.0, 10, 2.0),
    "Nangka Muda": (40, 2.5, 0.4, 8.0, 2.0, 15, 3.0),
    "Jantung Pisang": (30, 2.0, 0.3, 5.5, 1.0, 15, 3.5),
    "Daun Mangkokan": (28, 2.5, 0.3, 4.0, 0.5, 20, 2.5),
    "Kelor": (30, 3.5, 0.5, 4.0, 0.5, 15, 3.0),
}
veg_cook = {
    "Tumis Bawang Merah": (1.15, 1.1, 1.15, 1.05, 1.0, 1.2, 1.0),
    "Tumis Bawang Bombay": (1.15, 1.1, 1.15, 1.05, 1.1, 1.2, 1.0),
    "Tumis Jahe": (1.1, 1.1, 1.1, 1.05, 1.0, 1.2, 1.0),
    "Tumis Lengkuas": (1.1, 1.1, 1.1, 1.05, 1.0, 1.2, 1.0),
    "Tumis Cabai Rawit": (1.2, 1.1, 1.2, 1.05, 1.0, 1.3, 1.0),
    "Tumis Ebi Kering": (1.2, 1.2, 1.2, 1.1, 1.0, 1.5, 1.0),
    "Tumis Udang Rebon": (1.2, 1.2, 1.2, 1.1, 1.0, 1.6, 1.0),
    "Tumis Daging Cincang": (1.3, 1.3, 1.3, 1.1, 1.0, 1.4, 1.0),
    "Sayur Bening": (1.02, 1.0, 1.0, 1.0, 1.0, 1.2, 1.0),
    "Sayur Asem": (1.05, 1.0, 1.0, 1.05, 1.0, 1.3, 1.0),
    "Sayur Lodeh": (1.3, 1.1, 1.6, 1.1, 1.0, 1.3, 1.0),
    "Oseng Bawang Putih": (1.15, 1.1, 1.15, 1.05, 1.0, 1.2, 1.0),
}
for vname, (vc, vp, vf, vcb, vs, vso, vfb) in veg.items():
    for cname, (cc, cp, cf, ccb, cs, cso, cfb) in veg_cook.items():
        name = f"{cname} {vname}"
        cal = round(vc * cc)
        prot = round(vp * cp, 1)
        fat = round(vf * cf, 1)
        carbs = round(vcb * ccb, 1)
        sug = round(vs * cs, 1)
        sod = round(vso * cso)
        fib = round(vfb * cfb, 1)
        ft = "local_indonesian" if cname in ("Sayur Bening", "Sayur Asem", "Sayur Lodeh") else "other"
        if add(name, cal, prot, fat, carbs, sug, sod, fib, ft, "gen-batch10"):
            count += 1

# ================================================================
# 67. FAST FOOD / MODERN INDONESIAN
# ================================================================
fast_food = [
    ("Ayam Geprek Keju", 400, 26, 18, 30, 4, 500, 2, "other"),
    ("Ayam Geprek Mozarela", 420, 28, 20, 30, 4, 520, 2, "other"),
    ("Ayam Geprek Sambal Ijo", 380, 26, 16, 28, 4, 480, 2, "other"),
    ("Ayam Geprek Sambal Bawang", 370, 26, 16, 28, 4, 470, 2, "other"),
    ("Ayam Geprek Sambal Matah", 380, 26, 16, 28, 4, 460, 2, "other"),
    ("Ayam Geprek Sambal Tomat", 370, 26, 16, 28, 4, 480, 2, "other"),
    ("Ayam Geprek Pedas Gila", 390, 26, 16, 30, 4, 500, 2, "other"),
    ("Ayam Penyet Sambal Bawang", 350, 26, 16, 22, 3, 450, 2, "local_indonesian"),
    ("Ayam Penyet Sambal Tomat", 350, 26, 16, 22, 3, 450, 2, "local_indonesian"),
    ("Ayam Penyet Sambal Belacan", 360, 26, 16, 22, 4, 470, 2, "local_indonesian"),
    ("Ayam Penyet Kemangi", 350, 26, 16, 22, 3, 450, 2, "local_indonesian"),
    ("Ayam Penyet Sederhana", 340, 26, 16, 22, 3, 440, 2, "local_indonesian"),
    ("Indomie Goreng Telur", 450, 14, 18, 52, 6, 800, 2, "other"),
    ("Indomie Goreng Keju", 460, 14, 20, 50, 5, 780, 2, "other"),
    ("Indomie Goreng Kornet", 470, 16, 20, 52, 5, 850, 2, "other"),
    ("Indomie Rebus Telur", 420, 14, 14, 52, 6, 800, 2, "other"),
    ("Indomie Rebus Komplit", 450, 16, 16, 52, 6, 850, 3, "other"),
    ("Mie Instan Kari Ayam", 400, 10, 16, 48, 5, 750, 2, "other"),
    ("Mie Instan Soto", 380, 10, 14, 46, 5, 780, 2, "other"),
    ("Nasi Telur Ceplok Kecap", 320, 14, 10, 40, 3, 450, 1, "other"),
    ("Nasi Telur Dadar Sambal", 350, 14, 14, 40, 3, 450, 1, "other"),
    ("Nasi Ayam Suwir Pedas", 380, 22, 10, 44, 4, 480, 2, "other"),
    ("Nasi Kornet Pedas", 380, 14, 14, 44, 3, 500, 2, "other"),
    ("Nasi Sarden Kaleng", 350, 14, 12, 44, 4, 550, 3, "other"),
    ("Roti Tawar Telur Dadar", 300, 14, 12, 30, 4, 400, 2, "other"),
    ("Roti Tawar Kornet", 320, 14, 14, 30, 4, 480, 2, "other"),
    ("Roti Tawar Keju Leleh", 300, 12, 14, 30, 4, 400, 2, "other"),
    ("Bubur Instan Ayam", 150, 6, 2, 24, 3, 500, 2, "other"),
]
for item in fast_food:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 68. MORE INDONESIAN SOUPS / BERKUAH
# ================================================================
soups_id = [
    ("Sayur Bayam Jagung", 80, 4, 2, 14, 3, 300, 4, "local_indonesian"),
    ("Sayur Bayam Labu", 80, 4, 2, 14, 3, 300, 4, "local_indonesian"),
    ("Sayur Asem Jakarta", 90, 3, 1, 18, 4, 350, 5, "local_indonesian"),
    ("Sayur Asem Sunda", 90, 3, 1, 18, 4, 350, 5, "local_indonesian"),
    ("Sayur Asem Jawa", 90, 3, 1, 18, 4, 350, 5, "local_indonesian"),
    ("Sayur Lodeh Padang", 150, 5, 10, 14, 4, 350, 4, "local_indonesian"),
    ("Sayur Lodeh Jawa", 150, 5, 10, 14, 4, 350, 4, "local_indonesian"),
    ("Sayur Lodeh Betawi", 160, 5, 10, 16, 5, 380, 4, "local_indonesian"),
    ("Sayur Nangka Muda", 120, 4, 6, 16, 4, 300, 4, "local_indonesian"),
    ("Sayur Daun Singkong Santan", 150, 6, 10, 14, 3, 350, 4, "local_indonesian"),
    ("Sayur Pepaya Muda", 100, 3, 4, 14, 4, 300, 4, "local_indonesian"),
    ("Sayur Rebung Santan", 130, 4, 8, 14, 3, 320, 4, "local_indonesian"),
    ("Sayur Pakis Santan", 140, 5, 8, 14, 3, 320, 4, "local_indonesian"),
    ("Sayur Jantung Pisang", 120, 4, 6, 14, 3, 300, 5, "local_indonesian"),
    ("Sayur Kacang Merah", 150, 7, 3, 22, 4, 250, 6, "local_indonesian"),
    ("Sayur Buncis Santan", 140, 5, 8, 14, 4, 320, 4, "local_indonesian"),
    ("Sop Bakso Sapi", 250, 12, 8, 28, 4, 600, 3, "other"),
    ("Sop Bakso Ikan", 220, 10, 6, 28, 4, 580, 3, "other"),
    ("Sop Bakso Ayam", 240, 14, 7, 28, 4, 580, 3, "other"),
    ("Sop Pangsit Kuah", 200, 10, 6, 24, 3, 580, 2, "other"),
    ("Sop Ceker Rempah", 180, 14, 8, 14, 3, 450, 1, "other"),
]
for item in soups_id:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 69. NASI CAMPUR / RAMESAN DEEP (Javanese warung)
# ================================================================
nasi_rames = [
    ("Nasi Pecel Lele", 350, 18, 12, 38, 4, 480, 4, "local_indonesian"),
    ("Nasi Pecel Ayam", 360, 20, 12, 38, 4, 480, 4, "local_indonesian"),
    ("Nasi Pecel Tahu Tempe", 320, 12, 10, 42, 4, 450, 6, "local_indonesian"),
    ("Nasi Ayam Goreng Kremes", 420, 26, 18, 36, 3, 420, 2, "other"),
    ("Nasi Bebek Goreng Sambal", 450, 28, 22, 34, 3, 480, 3, "other"),
    ("Nasi Empal Goreng", 400, 24, 14, 40, 4, 480, 2, "local_indonesian"),
    ("Nasi Paru Goreng", 380, 20, 16, 38, 3, 450, 2, "local_indonesian"),
    ("Nasi Limpa Goreng", 370, 22, 14, 36, 3, 450, 1, "local_indonesian"),
    ("Nasi Babat Goreng", 380, 18, 16, 38, 3, 480, 2, "local_indonesian"),
    ("Nasi Usus Goreng", 360, 16, 15, 38, 3, 480, 2, "local_indonesian"),
    ("Nasi Rempah Ayam", 380, 22, 14, 38, 4, 480, 3, "local_indonesian"),
    ("Nasi Bistik Sapi", 420, 26, 14, 40, 4, 520, 3, "other"),
    ("Nasi Bistik Ayam", 400, 24, 12, 40, 4, 500, 3, "other"),
    ("Nasi Cumi Hitam", 380, 18, 12, 42, 4, 500, 3, "local_indonesian"),
    ("Nasi Telur Balado Pete", 350, 16, 14, 40, 4, 480, 4, "local_indonesian"),
    ("Nasi Ayam Bakar Kecap", 400, 26, 12, 40, 5, 500, 2, "other"),
    ("Nasi Ikan Bakar Kecap", 380, 22, 10, 42, 5, 480, 2, "other"),
    ("Nasi Lele Bakar Sambal", 370, 22, 12, 40, 4, 480, 2, "local_indonesian"),
    ("Nasi Ayam Geprek Sambal", 400, 26, 16, 34, 4, 480, 2, "other"),
    ("Nasi Ayam Geprek Mozzarella", 420, 28, 18, 34, 4, 500, 2, "other"),
    ("Nasi Ayam Cabe Ijo", 380, 24, 14, 38, 4, 450, 2, "local_indonesian"),
    ("Nasi Ayam Kecap Manis", 370, 24, 10, 40, 6, 500, 2, "other"),
    ("Nasi Ikan Goreng Sambal Dabu", 370, 22, 12, 40, 4, 480, 2, "local_indonesian"),
    ("Nasi Ikan Goreng Sambal Bawang", 370, 22, 12, 40, 4, 470, 2, "local_indonesian"),
    ("Nasi Udang Goreng Sambal", 380, 20, 14, 40, 4, 500, 2, "other"),
    ("Nasi Cumi Sambal", 360, 18, 12, 42, 4, 500, 2, "other"),
    ("Nasi Tuna Sambal Matah", 370, 24, 12, 38, 4, 450, 2, "other"),
]
for item in nasi_rames:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 70. KIDS/ANAK FOODS
# ================================================================
kids = [
    ("Nasi Tim Ayam Wortel", 250, 14, 6, 32, 3, 350, 3, "other"),
    ("Nasi Tim Ikan Brokoli", 240, 14, 5, 32, 3, 350, 3, "other"),
    ("Nasi Tim Telur Puyuh", 230, 12, 6, 30, 3, 320, 2, "other"),
    ("Bubur Tim Saring Daging", 180, 12, 4, 22, 2, 300, 2, "other"),
    ("Bubur Tim Saring Ayam", 180, 12, 4, 22, 2, 300, 2, "other"),
    ("Bubur Tim Saring Ikan", 170, 12, 3, 22, 2, 300, 2, "other"),
    ("Bubur Susu Beras Merah", 150, 5, 3, 24, 6, 30, 3, "other"),
    ("Tim Telur Wortel", 120, 8, 5, 8, 3, 200, 2, "other"),
    ("Tim Ayam Tahu", 200, 16, 8, 16, 3, 300, 2, "other"),
    ("Maklor", 200, 8, 10, 20, 3, 350, 2, "snack"),
    ("Sosis Solo", 250, 12, 14, 18, 3, 400, 2, "snack"),
    ("Bola Daging Ayam", 200, 14, 8, 18, 3, 350, 2, "other"),
    ("Nagets Ayam Homemade", 220, 14, 10, 18, 3, 350, 2, "other"),
    ("Nagets Ikan Homemade", 200, 12, 8, 18, 3, 350, 2, "other"),
    ("Nagets Tempe", 200, 10, 10, 18, 3, 320, 3, "other"),
    ("Schotel Makaroni Anak", 300, 12, 14, 30, 4, 400, 2, "other"),
    ("Perkedel Kentang Anak", 150, 4, 8, 16, 3, 250, 2, "snack"),
    ("Bitterballen", 200, 8, 10, 18, 3, 350, 2, "snack"),
    ("Fish Finger Goreng", 220, 12, 10, 20, 2, 350, 2, "other"),
    ("Telur Puyuh Goreng", 150, 10, 10, 6, 2, 180, 1, "snack"),
]
for item in kids:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 71. BUBUR / PORRIDGE VERIASI LENGKAP
# ================================================================
bubur_ext = [
    ("Bubur Manado Komplit", 280, 8, 5, 44, 4, 450, 5, "local_indonesian"),
    ("Bubur Ayam Spesial", 350, 18, 10, 40, 4, 550, 3, "other"),
    ("Bubur Ayam Cakwe Komplit", 350, 16, 10, 42, 4, 550, 3, "other"),
    ("Bubur Ayam Kacang Kedelai", 340, 16, 10, 40, 4, 520, 4, "other"),
    ("Bubur Ikan Asin", 220, 12, 4, 30, 3, 600, 2, "other"),
    ("Bubur Kacang Ijo Gula Merah", 220, 8, 3, 34, 14, 40, 5, "other"),
    ("Bubur Kacang Tanah", 230, 8, 6, 32, 10, 50, 5, "other"),
    ("Bubur Kacang Merah Santan", 220, 8, 6, 34, 10, 50, 6, "other"),
    ("Bubur Sagu Rangi", 180, 2, 3, 34, 14, 30, 2, "other"),
    ("Bubur Tepung Hunkwe", 160, 2, 2, 32, 12, 20, 1, "other"),
    ("Bubur Candil Santan", 220, 4, 6, 36, 18, 50, 3, "other"),
    ("Bubur Mutiara Manis", 200, 3, 5, 34, 18, 40, 2, "other"),
    ("Bubur Mutiara Santan", 220, 4, 7, 34, 16, 50, 2, "other"),
]
for item in bubur_ext:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 72. MORE SNACK / KUE BASAH / JAJANAN PASAR
# ================================================================
jajan_pasar2 = [
    ("Kue Lopis Ketan", 200, 3, 6, 30, 10, 50, 3, "snack"),
    ("Kue Cente Manis", 180, 2, 5, 30, 18, 40, 2, "snack"),
    ("Kue Lapis Kanji", 170, 3, 6, 24, 12, 80, 1, "snack"),
    ("Kue Lapis Beras", 180, 3, 7, 24, 12, 80, 1, "snack"),
    ("Kue Pepe", 180, 3, 6, 26, 12, 80, 2, "snack"),
    ("Kue Ongol-Ongol", 170, 2, 5, 28, 14, 50, 2, "snack"),
    ("Kue Apem Gula Merah", 160, 3, 4, 28, 14, 80, 2, "snack"),
    ("Kue Apem Tape", 170, 3, 5, 28, 12, 80, 2, "snack"),
    ("Kue Apem Kukus", 160, 3, 4, 28, 14, 80, 2, "snack"),
    ("Kue Putu Ayu", 180, 4, 7, 24, 12, 80, 2, "snack"),
    ("Kue Putu Mayang", 190, 4, 7, 26, 14, 60, 2, "snack"),
    ("Kue Serabi Kuah Gula", 200, 4, 6, 30, 14, 80, 2, "snack"),
    ("Kue Serabi Kinca", 210, 4, 7, 30, 16, 80, 2, "snack"),
    ("Kue Serabi Coklat", 220, 4, 8, 32, 16, 100, 2, "snack"),
    ("Kue Serabi Keju", 220, 5, 9, 30, 12, 120, 2, "snack"),
    ("Kue Pancong", 200, 4, 8, 26, 10, 80, 2, "snack"),
    ("Kue Cucur Gula Merah", 200, 3, 8, 28, 14, 80, 2, "snack"),
    ("Kue Cucur Pandan", 200, 3, 8, 28, 14, 80, 1, "snack"),
    ("Kue Cucur Gula Putih", 200, 3, 8, 28, 14, 70, 1, "snack"),
    ("Kue Kucur", 200, 3, 8, 28, 14, 80, 2, "snack"),
    ("Bolu Pisang Kukus", 200, 4, 7, 28, 12, 120, 2, "snack"),
    ("Bolu Ketan Item", 200, 5, 6, 30, 14, 100, 2, "snack"),
    ("Bolu Pandan Kukus", 190, 4, 7, 26, 12, 120, 2, "snack"),
    ("Kue Sagu", 160, 2, 4, 28, 10, 60, 1, "snack"),
    ("Kue Kastengel", 180, 4, 10, 18, 4, 200, 1, "snack"),
    ("Kue Nastar", 180, 3, 8, 22, 10, 100, 2, "snack"),
    ("Kue Lidah Kucing", 160, 3, 8, 18, 8, 80, 1, "snack"),
    ("Kue Putri Salju", 170, 3, 9, 18, 8, 80, 1, "snack"),
    ("Kue Bangkit", 150, 2, 5, 22, 8, 60, 1, "snack"),
    ("Kue Kembang Goyang", 160, 3, 6, 22, 8, 70, 1, "snack"),
    ("Kue Akar Kelapa", 160, 3, 6, 22, 8, 60, 1, "snack"),
    ("Kue Semprit", 170, 3, 8, 20, 8, 80, 1, "snack"),
    ("Kue Tambang", 160, 3, 6, 22, 8, 60, 1, "snack"),
    ("Rengginang", 150, 2, 4, 26, 2, 200, 1, "snack"),
    ("Opak Singkong", 140, 1, 3, 28, 2, 150, 2, "snack"),
    ("Ladu", 180, 4, 6, 26, 12, 50, 3, "snack"),
    ("Wajik", 200, 3, 5, 34, 16, 50, 2, "snack"),
    ("Dodol Garut", 180, 2, 4, 32, 18, 40, 1, "snack"),
    ("Dodol Betawi", 180, 2, 4, 32, 18, 40, 1, "snack"),
    ("Jenang", 180, 2, 4, 32, 16, 40, 2, "snack"),
    ("Gemblong", 200, 3, 7, 30, 12, 80, 2, "snack"),
    ("Gendar", 150, 3, 2, 30, 4, 100, 3, "snack"),
    ("Cenil", 180, 2, 4, 30, 12, 50, 2, "snack"),
    ("Getuk Lindri", 180, 2, 4, 34, 14, 50, 3, "snack"),
    ("Getuk Goreng", 200, 3, 6, 34, 14, 50, 3, "snack"),
    ("Gethuk", 180, 2, 4, 34, 14, 50, 3, "snack"),
]
for item in jajan_pasar2:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 73. CARIBBEAN FOODS
# ================================================================
caribbean = [
    ("Jerk Chicken Karibia", 350, 28, 14, 18, 5, 500, 2, "other"),
    ("Jerk Pork Karibia", 380, 26, 18, 18, 5, 520, 2, "other"),
    ("Jerk Fish Karibia", 280, 24, 10, 18, 4, 480, 2, "other"),
    ("Rice Peas Karibia", 280, 8, 4, 48, 4, 350, 5, "other"),
    ("Ackee Saltfish", 300, 18, 14, 24, 4, 550, 3, "other"),
    ("Curry Goat Karibia", 380, 26, 18, 20, 5, 520, 3, "other"),
    ("Roti Curry Karibia", 350, 14, 12, 40, 5, 500, 3, "other"),
    ("Callaloo Karibia", 120, 5, 4, 18, 4, 400, 5, "other"),
    ("Doubles Karibia", 280, 10, 8, 38, 4, 480, 4, "other"),
]
for item in caribbean:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 74. RICE CAKES / LONTONG / KETUPAT VARIANTS
# ================================================================
rice_cakes = [
    ("Ketupat Sayur Nangka", 350, 10, 12, 44, 5, 500, 5, "local_indonesian"),
    ("Lontong Kari Ayam", 380, 16, 14, 42, 5, 520, 4, "local_indonesian"),
    ("Lontong Kari Daging", 400, 18, 16, 40, 5, 520, 3, "local_indonesian"),
    ("Lontong Gulai Nangka", 320, 8, 12, 40, 5, 450, 5, "local_indonesian"),
    ("Lontong Gulai Pakis", 300, 8, 12, 38, 4, 450, 5, "local_indonesian"),
    ("Lontong Gulai Tahu", 320, 10, 14, 36, 5, 450, 4, "local_indonesian"),
    ("Lontong Opor Ayam", 360, 16, 14, 38, 5, 480, 3, "local_indonesian"),
    ("Lontong Sambal Goreng", 350, 10, 12, 42, 6, 500, 5, "local_indonesian"),
    ("Lontong Mie", 350, 12, 10, 46, 5, 550, 4, "local_indonesian"),
]
for item in rice_cakes:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 75. BALINESE & LOMBOK SPECIFIC
# ================================================================
bali_lombok = [
    ("Ayam Pelalah Bali", 300, 26, 14, 14, 4, 450, 2, "local_indonesian"),
    ("Lawar Ayam Bali", 200, 16, 8, 14, 4, 350, 4, "local_indonesian"),
    ("Lawar Sapi Bali", 220, 18, 10, 12, 4, 380, 4, "local_indonesian"),
    ("Lawar Kacang Bali", 180, 8, 8, 18, 4, 320, 5, "local_indonesian"),
    ("Tipat Cantok Bali", 280, 10, 8, 36, 5, 450, 5, "local_indonesian"),
    ("Sate Languan Bali", 240, 18, 8, 20, 4, 400, 2, "local_indonesian"),
    ("Urutan Bali", 250, 14, 16, 14, 3, 450, 1, "local_indonesian"),
    ("Komoh Bali", 280, 20, 14, 16, 4, 480, 3, "local_indonesian"),
    ("Pelecing Ayam Lombok", 320, 26, 14, 18, 4, 480, 2, "local_indonesian"),
    ("Ayam Rarang Lombok", 320, 26, 14, 18, 4, 500, 2, "local_indonesian"),
    ("Bebalung Lombok", 280, 18, 14, 18, 4, 480, 3, "local_indonesian"),
    ("Sate Pusut Lombok", 250, 20, 10, 16, 4, 420, 2, "local_indonesian"),
    ("Ares Lombok", 200, 14, 8, 16, 4, 450, 3, "local_indonesian"),
    ("Nasi Balap Puyung", 350, 12, 8, 50, 4, 450, 4, "local_indonesian"),
    ("Sate Tanjung", 280, 22, 12, 16, 4, 430, 2, "local_indonesian"),
]
for item in bali_lombok:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 76. DIET / HEALTHY / KETO INSPIRED
# ================================================================
diet_foods = [
    ("Ayam Panggang Herbal", 260, 30, 10, 8, 2, 300, 1, "other"),
    ("Ikan Kukus Lemon", 180, 24, 5, 8, 2, 300, 1, "other"),
    ("Tumis Tahu Brokoli", 200, 14, 10, 16, 4, 350, 5, "other"),
    ("Tumis Tempe Kacang Panjang", 220, 14, 10, 18, 4, 350, 5, "other"),
    ("Sup Ayam Jahe Sehat", 150, 18, 4, 10, 3, 380, 2, "other"),
    ("Sup Ikan Kuah Bening", 140, 20, 3, 8, 2, 400, 2, "other"),
    ("Ca Brokoli Bawang Putih", 100, 5, 4, 14, 3, 250, 4, "other"),
    ("Ca Kembang Kol Saus Tiram", 100, 4, 4, 14, 3, 350, 4, "other"),
    ("Telur Rebus Salad Sayur", 180, 14, 10, 10, 4, 300, 5, "other"),
    ("Tahu Kukus Saus Jahe", 160, 12, 8, 10, 3, 380, 3, "other"),
    ("Pepes Tahu Jamur Sehat", 150, 10, 6, 14, 3, 320, 4, "other"),
    ("Pepes Ikan Kembung Sehat", 180, 22, 6, 10, 2, 350, 2, "other"),
    ("Smoothie Bowl Hijau", 250, 8, 8, 36, 16, 60, 8, "other"),
    ("Protein Bowl Ayam Quinoa", 420, 35, 12, 38, 4, 400, 6, "other"),
    ("Protein Bowl Tuna Edamame", 380, 32, 10, 32, 4, 480, 6, "other"),
    ("Cauliflower Rice Bowl", 250, 5, 8, 38, 4, 300, 6, "other"),
    ("Zucchini Noodle Pesto", 200, 6, 14, 14, 4, 300, 4, "other"),
]
for item in diet_foods:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# SAVE
# ================================================================
print(f"\nPart 6 total new: {count}")
if new:
    ndf = pd.DataFrame(new)
    ndf.to_csv(FINAL_OUTPUT, mode='a', header=False, index=False)
    df = pd.read_csv(FINAL_OUTPUT)
    print(f"Running total: {len(df)} foods")
    print(df["food_type"].value_counts().to_string())
else:
    print("No new foods added!")
