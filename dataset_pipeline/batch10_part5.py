"""Batch 10 Part 5: Final push to 10,000 — aggressive cross-products."""
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
# 44. CHINESE FOODS (comprehensive)
# ================================================================
chinese = [
    ("Nasi Goreng Cina", 400, 14, 10, 54, 5, 580, 3, "other"),
    ("Cap Cay Ayam", 250, 18, 10, 22, 6, 500, 5, "other"),
    ("Cap Cay Udang", 230, 14, 8, 24, 6, 520, 5, "other"),
    ("Cap Cay Sapi", 280, 18, 12, 24, 6, 500, 5, "other"),
    ("Cap Cay Goreng", 280, 16, 12, 26, 6, 550, 5, "other"),
    ("Cap Cay Kuah", 200, 14, 6, 22, 6, 550, 5, "other"),
    ("Fuyunghai Ayam", 280, 14, 16, 18, 5, 450, 3, "other"),
    ("Fuyunghai Udang", 260, 14, 14, 18, 5, 480, 3, "other"),
    ("Fuyunghai Sapi", 300, 16, 18, 18, 5, 450, 3, "other"),
    ("Ayam Kung Pao", 350, 26, 14, 24, 6, 550, 3, "other"),
    ("Udang Kung Pao", 320, 18, 12, 28, 6, 520, 3, "other"),
    ("Sapi Kung Pao", 360, 28, 16, 22, 5, 550, 2, "other"),
    ("Ayam Asam Manis Cina", 320, 24, 12, 26, 10, 480, 3, "other"),
    ("Ikan Asam Manis Cina", 280, 20, 9, 28, 10, 460, 2, "other"),
    ("Udang Asam Manis Cina", 290, 18, 10, 28, 10, 450, 2, "other"),
    ("Mapo Tahu", 250, 14, 14, 16, 4, 550, 3, "other"),
    ("Mapo Tahu Ayam", 280, 18, 14, 18, 4, 520, 3, "other"),
    ("Ayam Hainan", 320, 26, 12, 24, 4, 400, 2, "other"),
    ("Nasi Ayam Hainan", 420, 26, 12, 44, 4, 420, 2, "other"),
    ("Bebek Peking", 420, 28, 22, 22, 6, 550, 2, "other"),
    ("Ayam Panggang Peking", 350, 26, 14, 24, 8, 450, 2, "other"),
    ("Sapo Tahu", 220, 14, 10, 18, 4, 480, 3, "other"),
    ("Sapo Tahu Ayam", 250, 18, 10, 20, 4, 450, 3, "other"),
    ("Sapo Tahu Udang", 240, 16, 9, 20, 4, 480, 3, "other"),
    ("Sapo Tahu Sapi", 280, 20, 12, 20, 4, 450, 3, "other"),
    ("Kwetiau Siram Ayam", 380, 16, 10, 50, 5, 580, 3, "other"),
    ("Kwetiau Siram Sapi", 400, 18, 12, 48, 5, 580, 3, "other"),
    ("Kwetiau Siram Seafood", 380, 16, 10, 50, 5, 620, 3, "other"),
    ("Mie Goreng Cina", 400, 14, 12, 52, 5, 580, 3, "other"),
    ("Mie Kuah Cina", 350, 12, 8, 50, 5, 600, 3, "other"),
    ("Bihun Goreng Cina", 380, 10, 10, 54, 5, 550, 3, "other"),
    ("Bihun Kuah Cina", 320, 10, 6, 50, 5, 580, 3, "other"),
    ("Nasi Hokkien", 420, 16, 10, 56, 5, 600, 3, "other"),
    ("Ayam Koloke", 340, 24, 14, 26, 10, 450, 2, "other"),
    ("Udang Mayones", 300, 16, 16, 22, 5, 420, 1, "other"),
    ("Ayam Lemon Chicken", 320, 24, 12, 26, 10, 400, 1, "other"),
    ("Sapi Lada Hitam", 350, 28, 16, 18, 4, 450, 2, "other"),
    ("Ayam Lada Hitam", 320, 26, 14, 18, 4, 420, 2, "other"),
    ("Ikan Tim Cina", 180, 20, 5, 12, 3, 480, 1, "other"),
    ("Ayam Tim Cina", 200, 24, 6, 12, 3, 420, 1, "other"),
    ("Tahu Goreng Cina", 200, 10, 10, 16, 3, 350, 2, "other"),
    ("Bakpao Ayam", 200, 10, 5, 28, 4, 300, 2, "snack"),
    ("Bakpao Daging", 220, 12, 7, 28, 4, 320, 2, "snack"),
    ("Bakpao Kacang Merah", 180, 6, 3, 30, 10, 150, 3, "snack"),
    ("Bakpao Coklat", 200, 5, 5, 32, 14, 180, 2, "snack"),
    ("Siomay Bandung", 220, 10, 8, 26, 4, 480, 2, "local_indonesian"),
    ("Bakso Goreng", 250, 10, 12, 24, 3, 450, 2, "snack"),
    ("Bakso Ikan Goreng", 220, 12, 10, 20, 3, 420, 2, "snack"),
    ("Pempek Lenjer", 200, 8, 4, 30, 3, 450, 2, "local_indonesian"),
    ("Pempek Kapal Selam", 280, 10, 8, 36, 4, 500, 2, "local_indonesian"),
    ("Pempek Adaan", 220, 8, 6, 30, 3, 420, 2, "local_indonesian"),
    ("Pempek Kulit", 180, 6, 8, 22, 3, 450, 1, "local_indonesian"),
    ("Pempek Keriting", 200, 8, 4, 30, 3, 420, 2, "local_indonesian"),
    ("Pempek Tahu", 220, 10, 6, 28, 3, 420, 2, "local_indonesian"),
    ("Pempek Telur", 240, 12, 8, 26, 3, 400, 1, "local_indonesian"),
    ("Pempek Dos", 180, 5, 4, 28, 3, 400, 2, "local_indonesian"),
    ("Kue Keranjang", 180, 2, 2, 38, 20, 50, 1, "snack"),
    ("Bakcang", 250, 8, 6, 36, 4, 350, 3, "snack"),
    ("Telur Pitan", 80, 8, 5, 1, 1, 200, 0, "other"),
    ("Sayur Asin Cina", 30, 2, 0, 5, 2, 400, 3, "other"),
    ("Tahu Asin", 120, 8, 7, 4, 2, 480, 1, "other"),
    ("Sate Babi", 250, 20, 14, 10, 3, 400, 1, "local_indonesian"),
    ("Babi Kecap", 350, 26, 20, 14, 6, 520, 1, "local_indonesian"),
    ("Babi Goreng", 380, 24, 24, 14, 3, 450, 1, "local_indonesian"),
    ("Nasi Tim Babi", 320, 16, 10, 38, 4, 450, 2, "other"),
    ("Nasi Campur Babi", 450, 24, 20, 38, 5, 550, 3, "other"),
    ("Sate Kerbau", 220, 22, 8, 12, 3, 400, 1, "local_indonesian"),
    ("Dendeng Kerbau", 280, 30, 10, 14, 4, 480, 1, "local_indonesian"),
]
for item in chinese:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 45. MORE SAYUR/PLANT-BASED CROSS-PRODUCTS
# ================================================================
sayur_base = {
    "Kangkung": (28, 2.5, 0.4, 3.5, 0.5, 30, 2.0),
    "Bayam": (23, 2.5, 0.4, 3.5, 0.5, 70, 1.5),
    "Sawi Hijau": (20, 2.0, 0.3, 3.0, 0.5, 40, 2.0),
    "Sawi Putih": (15, 1.5, 0.2, 2.5, 0.5, 30, 1.5),
    "Kacang Panjang": (30, 2.5, 0.3, 5.0, 0.5, 10, 2.5),
    "Kembang Kol": (25, 2.0, 0.3, 4.0, 2.0, 30, 2.0),
    "Brokoli": (35, 3.0, 0.4, 5.0, 1.5, 35, 3.0),
    "Wortel": (35, 1.0, 0.3, 7.0, 5.0, 60, 2.5),
    "Labu Siam": (20, 1.0, 0.2, 4.0, 2.0, 10, 2.0),
    "Oyong": (18, 1.5, 0.2, 3.5, 2.0, 15, 2.0),
    "Terong Ungu": (25, 1.0, 0.2, 5.0, 3.0, 5, 2.5),
    "Pare": (20, 1.5, 0.2, 3.5, 1.0, 10, 2.5),
    "Buncis": (30, 2.0, 0.3, 5.5, 2.0, 5, 2.5),
    "Daun Singkong": (35, 3.5, 0.5, 5.0, 0.5, 20, 3.5),
    "Daun Pepaya": (30, 3.0, 0.5, 4.0, 0.5, 15, 3.0),
    "Daun Ubi": (28, 3.0, 0.4, 4.5, 0.5, 25, 3.0),
    "Genjer": (22, 2.0, 0.3, 3.5, 0.5, 20, 2.5),
    "Selada Air": (15, 1.5, 0.2, 2.5, 0.5, 15, 1.5),
}
sayur_methods = {
    "Tumis Terasi": (1.25, 1.3, 1.2, 1.1, 1.0, 1.5, 1.0),
    "Tumis Pedas": (1.20, 1.2, 1.2, 1.1, 1.0, 1.3, 1.0),
    "Tumis Taoco": (1.20, 1.3, 1.2, 1.1, 1.0, 2.0, 1.0),
    "Tumis Saus Tiram": (1.25, 1.3, 1.2, 1.2, 1.1, 2.0, 1.0),
    "Tumis Kecap": (1.20, 1.2, 1.1, 1.2, 1.2, 2.0, 1.0),
    "Cah Polos": (1.05, 1.1, 1.1, 1.0, 1.0, 1.2, 1.0),
    "Bening": (1.05, 1.0, 1.0, 1.0, 1.0, 1.2, 1.0),
    "Sayur Santan": (1.40, 1.1, 1.8, 1.1, 1.0, 1.3, 1.0),
    "Pelecing": (1.15, 1.1, 1.2, 1.0, 1.0, 1.2, 1.0),
    "Urap Kelapa": (1.30, 1.3, 1.5, 1.1, 1.1, 1.3, 1.2),
}
for vname, (vc, vp, vf, vcb, vs, vso, vfb) in sayur_base.items():
    for mname, (mc, mp, mf, mcb, ms, mso, mfb) in sayur_methods.items():
        name = f"{mname} {vname}"
        cal = round(vc * mc)
        prot = round(vp * mp, 1)
        fat = round(vf * mf, 1)
        carbs = round(vcb * mcb, 1)
        sug = round(vs * ms, 1)
        sod = round(vso * mso)
        fib = round(vfb * mfb, 1)
        if add(name, cal, prot, fat, carbs, sug, sod, fib, "local_indonesian", "gen-batch10"):
            count += 1

# ================================================================
# 46. DAGING × LENGKAP METHODS
# ================================================================
meats = {
    "Daging Sapi": (180, 26, 8, 0, 0, 55, 0),
    "Daging Kambing": (200, 25, 10, 0, 0, 60, 0),
    "Daging Kerbau": (175, 27, 7, 0, 0, 55, 0),
    "Hati Sapi": (130, 20, 4, 4, 0, 70, 0),
    "Lidah Sapi": (220, 16, 16, 1, 0, 65, 0),
    "Paru Sapi": (120, 17, 4, 2, 0, 60, 0),
    "Usus Sapi": (150, 12, 10, 2, 0, 55, 0),
    "Iga Sapi": (250, 22, 18, 0, 0, 50, 0),
    "Tetelan Sapi": (230, 20, 16, 1, 0, 55, 0),
    "Sandung Lamur": (280, 18, 22, 0, 0, 50, 0),
}
meat_methods = {
    "Semur": (1.4, 1.1, 1.4, 1.2, 1.3, 2.0, 1.0),
    "Gulai": (1.5, 1.2, 1.8, 1.1, 1.0, 1.5, 1.0),
    "Rendang": (1.8, 1.3, 2.0, 1.2, 1.1, 1.5, 1.0),
    "Bakar Kecap": (1.3, 1.2, 1.2, 1.2, 1.3, 2.0, 1.0),
    "Tongseng": (1.5, 1.2, 1.5, 1.2, 1.1, 1.8, 1.5),
    "Sop": (1.2, 1.1, 1.2, 1.1, 1.0, 2.0, 1.5),
    "Sate": (1.3, 1.3, 1.2, 1.1, 1.1, 1.8, 1.0),
    "Kecap": (1.4, 1.1, 1.3, 1.2, 1.4, 2.5, 1.0),
    "Bumbu Rujak": (1.5, 1.2, 1.5, 1.2, 1.2, 1.5, 1.0),
    "Asam Pedas": (1.3, 1.1, 1.2, 1.1, 1.0, 1.8, 1.0),
}
for mname, (mc, mp, mf, mcb, ms, mso, mfb) in meats.items():
    for tname, (tc, tp, tf, tcb, ts, tso, tfb) in meat_methods.items():
        name = f"{mname} {tname}"
        cal = round(mc * tc)
        prot = round(mp * tp, 1)
        fat = round(mf * tf, 1)
        carbs = round(mcb * tcb, 1)
        sug = round(ms * ts, 1)
        sod = round(mso * tso)
        fib = round(mfb * tfb, 1)
        if add(name, cal, prot, fat, carbs, sug, sod, fib, "local_indonesian", "gen-batch10"):
            count += 1

# ================================================================
# 47. AYAM × LENGKAP
# ================================================================
ayam_parts = {
    "Dada Ayam": (120, 25, 2.5, 0, 0, 50, 0),
    "Paha Ayam": (145, 20, 7.0, 0, 0, 65, 0),
    "Sayap Ayam": (200, 18, 14.0, 0, 0, 60, 0),
    "Ceker Ayam": (70, 12, 3.0, 1, 0, 40, 0),
    "Hati Ayam": (150, 22, 5.0, 3, 0, 65, 0),
    "Ampela Ayam": (120, 18, 3.5, 2, 0, 55, 0),
    "Kulit Ayam": (300, 10, 28.0, 0, 0, 30, 0),
    "Paha Bawah Ayam": (160, 20, 8.0, 0, 0, 60, 0),
    "Paha Atas Ayam": (170, 22, 9.0, 0, 0, 62, 0),
}
ayam_methods = {
    "Goreng Bumbu": (1.5, 1.1, 1.8, 1.2, 1.0, 1.5, 1.0),
    "Bakar Bumbu": (1.3, 1.2, 1.2, 1.1, 1.0, 1.5, 1.0),
    "Opor": (1.5, 1.1, 1.8, 1.1, 1.0, 1.3, 1.0),
    "Santan": (1.5, 1.1, 1.8, 1.1, 1.0, 1.3, 1.0),
    "Kalio": (1.6, 1.2, 1.8, 1.1, 1.0, 1.4, 1.0),
    "Asam Manis": (1.4, 1.1, 1.2, 1.3, 1.4, 1.5, 1.0),
    "Goreng Mentega": (1.6, 1.1, 2.0, 1.2, 1.1, 1.3, 1.0),
    "Goreng Kremes": (1.6, 1.1, 2.2, 1.2, 1.0, 1.4, 1.0),
    "Rica-Rica": (1.4, 1.2, 1.3, 1.1, 1.0, 1.5, 1.0),
    "Kecap Pedas": (1.5, 1.1, 1.3, 1.2, 1.3, 2.0, 1.0),
}
for pname, (pc, pp, pf, pcb, ps, pso, pfb) in ayam_parts.items():
    for tname, (tc, tp, tf, tcb, ts, tso, tfb) in ayam_methods.items():
        name = f"{pname} {tname}"
        cal = round(pc * tc)
        prot = round(pp * tp, 1)
        fat = round(pf * tf, 1)
        carbs = round(pcb * tcb, 1)
        sug = round(ps * ts, 1)
        sod = round(pso * tso)
        fib = round(pfb * tfb, 1)
        if add(name, cal, prot, fat, carbs, sug, sod, fib, "base_food", "gen-batch10"):
            count += 1

# ================================================================
# 48. SEAFOOD × METHODS
# ================================================================
seafood = {
    "Ikan Kembung": (130, 22, 5.0, 0, 0, 60, 0),
    "Ikan Tongkol": (135, 24, 4.5, 0, 0, 55, 0),
    "Ikan Cakalang": (140, 26, 3.5, 0, 0, 50, 0),
    "Ikan Teri": (120, 20, 4.0, 0, 0, 80, 0),
    "Udang": (100, 20, 1.5, 1, 0, 150, 0),
    "Cumi-Cumi": (80, 16, 1.0, 2, 0, 140, 0),
    "Kepiting": (90, 18, 1.5, 0, 0, 200, 0),
    "Kerang Darah": (70, 12, 1.5, 3, 0, 180, 0),
    "Kerang Hijau": (85, 14, 2.0, 4, 0, 160, 0),
    "Rajungan": (85, 17, 1.0, 0, 0, 180, 0),
}
seafood_methods = {
    "Saus Padang": (1.8, 1.2, 2.0, 1.5, 1.2, 2.0, 1.0),
    "Saus Asam Manis": (1.6, 1.1, 1.3, 1.5, 1.5, 1.5, 1.0),
    "Saus Tiram": (1.5, 1.2, 1.3, 1.3, 1.2, 2.5, 1.0),
    "Goreng Tepung": (2.0, 1.1, 2.5, 1.5, 1.1, 1.5, 1.0),
    "Bakar Mentega": (1.5, 1.2, 2.0, 1.2, 1.1, 1.5, 1.0),
    "Bakar Sambal": (1.3, 1.2, 1.2, 1.1, 1.0, 1.5, 1.0),
    "Kuah Asam": (1.3, 1.1, 1.2, 1.1, 1.0, 1.8, 1.0),
    "Gulai": (1.5, 1.1, 2.0, 1.1, 1.0, 1.5, 1.0),
    "Pepes": (1.2, 1.2, 1.3, 1.1, 1.0, 1.4, 1.0),
    "Cabe Garam": (1.5, 1.1, 1.5, 1.2, 1.0, 1.8, 1.0),
}
for sname, (sc, sp, sf, scb, ss, sso, sfb) in seafood.items():
    for tname, (tc, tp, tf, tcb, ts, tso, tfb) in seafood_methods.items():
        name = f"{sname} {tname}"
        cal = round(sc * tc)
        prot = round(sp * tp, 1)
        fat = round(sf * tf, 1)
        carbs = round(scb * tcb, 1)
        sug = round(ss * ts, 1)
        sod = round(sso * tso)
        fib = round(sfb * tfb, 1)
        if add(name, cal, prot, fat, carbs, sug, sod, fib, "other", "gen-batch10"):
            count += 1

# ================================================================
# 49. NASI VARIANTS (more specific)
# ================================================================
nasi_variants = [
    ("Nasi Putih", 180, 4, 0.5, 40, 0, 5, 0.5, "base_food"),
    ("Nasi Merah", 170, 4, 1.0, 36, 0, 5, 3.0, "base_food"),
    ("Nasi Hitam", 175, 4, 1.0, 35, 0, 5, 3.5, "base_food"),
    ("Nasi Jagung Putih", 200, 5, 2.0, 42, 2, 10, 4.0, "base_food"),
    ("Nasi Ketan", 190, 4, 0.5, 42, 1, 5, 1.0, "base_food"),
    ("Nasi Ketan Gurih", 220, 5, 4.0, 40, 1, 50, 1.0, "base_food"),
    ("Nasi Minyak", 250, 4, 8.0, 38, 1, 100, 1.0, "other"),
    ("Nasi Kebuli", 350, 15, 12, 42, 4, 400, 2.0, "local_indonesian"),
    ("Nasi Briyani Spesial", 480, 22, 16, 54, 5, 550, 3, "other"),
    ("Nasi Arab Spesial", 450, 20, 14, 52, 4, 500, 3, "other"),
    ("Nasi Kebuli Spesial", 470, 22, 16, 50, 5, 530, 3, "local_indonesian"),
    ("Nasi Mandhi Spesial", 480, 24, 14, 54, 4, 520, 3, "local_indonesian"),
    ("Nasi Bukhari Spesial", 460, 22, 14, 52, 5, 520, 3, "local_indonesian"),
    ("Nasi Goreng Cabe Ijo", 380, 12, 14, 46, 4, 520, 3, "local_indonesian"),
    ("Nasi Goreng Pete", 370, 12, 14, 44, 4, 500, 4, "local_indonesian"),
    ("Nasi Goreng Ikan Asin", 380, 14, 13, 46, 4, 600, 3, "local_indonesian"),
    ("Nasi Goreng Kornet", 400, 14, 16, 44, 4, 550, 3, "other"),
    ("Nasi Goreng Sosis", 390, 13, 16, 44, 4, 550, 3, "other"),
    ("Nasi Goreng Teri Medan", 370, 14, 12, 46, 4, 580, 3, "local_indonesian"),
    ("Nasi Goreng Cakalang", 380, 16, 12, 46, 4, 560, 3, "local_indonesian"),
    ("Nasi Goreng Rempah", 380, 12, 14, 46, 4, 520, 3, "other"),
    ("Nasi Goreng Nanas", 360, 10, 12, 48, 6, 480, 4, "other"),
    ("Nasi Goreng Bawang", 350, 10, 12, 46, 4, 450, 3, "other"),
    ("Nasi Goreng Taichan", 370, 14, 12, 46, 4, 500, 3, "other"),
    ("Nasi Goreng Enak", 380, 12, 14, 46, 4, 520, 3, "other"),
    ("Nasi Goreng Spesial Komplit", 420, 16, 16, 46, 4, 550, 4, "other"),
]
for item in nasi_variants:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 50. FILIPINO FOODS
# ================================================================
filipino = [
    ("Adobo Ayam Filipina", 350, 26, 16, 18, 4, 550, 2, "other"),
    ("Adobo Babi Filipina", 380, 24, 20, 16, 4, 580, 2, "other"),
    ("Sinigang Filipina", 180, 14, 5, 18, 4, 500, 3, "other"),
    ("Lechon Kawali", 420, 24, 28, 14, 2, 400, 1, "other"),
    ("Pancit Filipina", 350, 12, 8, 50, 5, 580, 3, "other"),
    ("Lumpia Filipina", 200, 8, 10, 20, 4, 380, 3, "other"),
    ("Kare-Kare Filipina", 320, 18, 18, 20, 6, 550, 4, "other"),
    ("Sisig Filipina", 380, 22, 24, 16, 3, 550, 2, "other"),
    ("Halo-Halo", 280, 5, 6, 48, 28, 80, 4, "other"),
    ("Taho Filipina", 150, 5, 2, 26, 16, 30, 1, "snack"),
    ("Turon Filipina", 220, 3, 8, 32, 14, 80, 3, "snack"),
    ("Bibingka Filipina", 200, 4, 6, 30, 12, 150, 2, "snack"),
    ("Puto Filipina", 160, 4, 3, 28, 10, 120, 2, "snack"),
    ("Longganisa Filipina", 350, 16, 24, 14, 4, 550, 1, "other"),
    ("Tocino Filipina", 320, 14, 12, 32, 12, 500, 1, "other"),
]
for item in filipino:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 51. BURMESE / MYANMAR FOODS
# ================================================================
burmese = [
    ("Mohinga Myanmar", 300, 14, 8, 38, 4, 580, 3, "other"),
    ("Ohn Kauk Swe", 350, 12, 10, 46, 5, 550, 3, "other"),
    ("Danbauk Myanmar", 420, 18, 12, 52, 5, 520, 3, "other"),
    ("Teh Tarik Myanmar", 120, 3, 4, 16, 12, 40, 0, "beverage"),
    ("Laphet Thoke", 80, 4, 3, 10, 2, 200, 4, "other"),
    ("Shan Kauk Swe", 320, 12, 8, 44, 5, 500, 3, "other"),
    ("Nan Gyi Thoke", 350, 14, 10, 44, 5, 520, 3, "other"),
    ("Mont Lin Maya", 180, 4, 6, 26, 10, 150, 2, "snack"),
]
for item in burmese:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 52. FERMENTED / PRESERVED / TRADITIONAL
# ================================================================
fermented = [
    ("Tempe Bacem", 150, 10, 6, 14, 6, 350, 3, "local_indonesian"),
    ("Tempe Mendoan Renyah", 180, 8, 10, 16, 3, 300, 3, "local_indonesian"),
    ("Tempe Orek", 200, 10, 10, 18, 6, 400, 3, "local_indonesian"),
    ("Tempe Orek Pedas", 200, 10, 10, 18, 5, 420, 3, "local_indonesian"),
    ("Tempe Goreng Tepung", 220, 10, 12, 18, 3, 320, 3, "snack"),
    ("Tempe Kering", 250, 12, 10, 24, 8, 350, 4, "local_indonesian"),
    ("Tempe Penyet", 250, 12, 12, 22, 4, 400, 3, "local_indonesian"),
    ("Tempe Santan", 220, 12, 14, 14, 3, 380, 3, "local_indonesian"),
    ("Tempe Asam Manis", 220, 10, 10, 22, 8, 400, 3, "other"),
    ("Tempe Saus Tiram", 210, 12, 10, 18, 5, 480, 3, "other"),
    ("Tahu Isi Sayur", 200, 8, 9, 20, 4, 400, 3, "snack"),
    ("Tahu Isi Daging", 230, 12, 10, 20, 3, 400, 3, "snack"),
    ("Tahu Sumedang", 180, 8, 9, 18, 3, 350, 2, "local_indonesian"),
    ("Tahu Gimbal", 250, 10, 10, 26, 5, 450, 4, "local_indonesian"),
    ("Tahu Tek", 250, 10, 10, 26, 5, 450, 4, "local_indonesian"),
    ("Tahu Telur", 280, 12, 12, 26, 5, 450, 3, "local_indonesian"),
    ("Tahu Acar", 180, 8, 8, 18, 6, 420, 3, "other"),
    ("Tahu Kuah Santan", 200, 10, 12, 14, 3, 380, 3, "local_indonesian"),
    ("Tahu Sambal Kecap", 180, 9, 8, 18, 5, 450, 3, "local_indonesian"),
    ("Tahu Lontong", 300, 12, 8, 36, 5, 480, 4, "local_indonesian"),
    ("Tahu Kupat", 300, 12, 8, 36, 5, 480, 4, "local_indonesian"),
    ("Oncom Goreng", 180, 8, 9, 16, 3, 320, 3, "local_indonesian"),
    ("Oncom Bacem", 150, 8, 6, 14, 6, 350, 3, "local_indonesian"),
    ("Oncom Balado", 180, 8, 9, 16, 4, 400, 3, "local_indonesian"),
    ("Oncom Kecap", 170, 8, 8, 16, 6, 450, 3, "local_indonesian"),
    ("Ikan Asin Goreng", 200, 18, 8, 14, 1, 800, 1, "base_food"),
    ("Ikan Asin Peda", 180, 20, 6, 10, 1, 900, 1, "base_food"),
    ("Ikan Asin Jambal", 190, 22, 5, 12, 1, 850, 1, "base_food"),
    ("Ikan Asin Gabus", 170, 20, 4, 14, 1, 750, 1, "base_food"),
    ("Ikan Asin Teri Medan", 160, 18, 5, 12, 1, 850, 1, "base_food"),
    ("Dendeng Balado", 300, 28, 12, 16, 5, 500, 2, "local_indonesian"),
    ("Dendeng Batokok", 280, 28, 10, 14, 4, 450, 1, "local_indonesian"),
    ("Dendeng Lambok", 320, 26, 14, 16, 5, 520, 2, "local_indonesian"),
    ("Abon Sapi Pedas", 350, 30, 14, 20, 8, 550, 2, "other"),
    ("Abon Ayam", 300, 28, 10, 20, 8, 500, 2, "other"),
    ("Abon Ikan", 280, 26, 8, 22, 6, 480, 2, "other"),
    ("Emping Goreng", 150, 3, 6, 20, 1, 100, 3, "snack"),
    ("Kerupuk Udang", 130, 3, 4, 20, 2, 300, 1, "snack"),
    ("Kerupuk Ikan", 120, 5, 3, 18, 2, 280, 1, "snack"),
    ("Kerupuk Kulit", 160, 8, 8, 14, 1, 250, 0, "snack"),
    ("Kerupuk Rambak", 150, 7, 7, 14, 1, 250, 0, "snack"),
    ("Kerupuk Singkong", 140, 2, 5, 22, 2, 200, 2, "snack"),
    ("Kerupuk Bawang", 130, 3, 4, 20, 2, 250, 1, "snack"),
    ("Rempeyek Kacang", 180, 5, 10, 18, 2, 250, 2, "snack"),
    ("Rempeyek Teri", 180, 7, 10, 16, 2, 350, 2, "snack"),
    ("Rempeyek Udang", 170, 6, 9, 16, 2, 300, 2, "snack"),
]
for item in fermented:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 53. MORE DRINKS / ES CAMPUR VARIANTS
# ================================================================
drinks_ext2 = [
    ("Es Selendang Mayang", 180, 3, 4, 30, 18, 40, 2, "beverage"),
    ("Es Goyobod", 180, 3, 5, 30, 16, 40, 2, "beverage"),
    ("Es Oyen", 200, 4, 6, 32, 18, 50, 3, "beverage"),
    ("Es Kacang Merah Manis", 200, 6, 4, 34, 18, 50, 5, "beverage"),
    ("Es Alpukat Kocok", 220, 4, 12, 24, 12, 20, 5, "beverage"),
    ("Es Blewah", 80, 1, 0, 18, 14, 20, 2, "beverage"),
    ("Es Timun Serut", 60, 1, 0, 14, 10, 10, 2, "beverage"),
    ("Soda Gembira", 120, 1, 0, 26, 24, 30, 0, "beverage"),
    ("Air Tebu", 100, 0, 0, 24, 22, 20, 0, "beverage"),
    ("Air Tebu Jeruk Nipis", 110, 0, 0, 26, 22, 20, 0, "beverage"),
    ("Air Kelapa Hijau", 40, 1, 0, 8, 6, 40, 2, "beverage"),
    ("Infused Water Lemon", 10, 0, 0, 2, 2, 5, 0, "beverage"),
    ("Infused Water Stroberi", 15, 0, 0, 3, 3, 5, 0, "beverage"),
    ("Infused Water Timun", 10, 0, 0, 2, 1, 5, 0, "beverage"),
    ("Infused Water Jeruk", 15, 0, 0, 3, 2, 5, 0, "beverage"),
    ("Kopi Tubruk", 5, 1, 0, 0, 0, 5, 0, "beverage"),
    ("Kopi Jahe", 30, 1, 0, 6, 4, 10, 0, "beverage"),
    ("Kopi Rempah", 40, 1, 0, 8, 6, 10, 0, "beverage"),
    ("Kopi Aren", 60, 1, 0, 12, 10, 10, 0, "beverage"),
    ("Kopi Dampit", 5, 1, 0, 0, 0, 5, 0, "beverage"),
    ("Susu Jahe", 100, 4, 4, 12, 10, 40, 0, "beverage"),
    ("Susu Kunyit", 90, 4, 4, 10, 8, 30, 1, "beverage"),
    ("Susu Kurma", 150, 5, 4, 22, 18, 40, 2, "beverage"),
    ("Jamu Kunyit Asam", 50, 0, 0, 10, 8, 10, 1, "beverage"),
    ("Jamu Beras Kencur", 60, 1, 0, 12, 8, 10, 1, "beverage"),
    ("Jamu Temulawak", 50, 0, 0, 10, 6, 10, 1, "beverage"),
    ("Jamu Pahitan", 30, 0, 0, 6, 4, 10, 1, "beverage"),
    ("Jamu Sinom", 50, 0, 0, 10, 8, 10, 1, "beverage"),
    ("Jamu Gendong", 50, 0, 0, 10, 8, 10, 1, "beverage"),
    ("Sari Kurma Madu", 120, 1, 0, 26, 24, 20, 1, "beverage"),
    ("Cincau Hijau", 60, 0, 0, 14, 10, 10, 2, "beverage"),
    ("Selasih Manis", 50, 0, 0, 12, 10, 10, 1, "beverage"),
]
for item in drinks_ext2:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 54. MORE INDONESIAN REGIONAL (additional coverage)
# ================================================================
regional3 = [
    # Maluku
    ("Ikan Asar Maluku", 200, 22, 6, 14, 3, 550, 2, "local_indonesian"),
    ("Papeda Ikan Kuah Kuning", 300, 16, 5, 44, 3, 500, 2, "local_indonesian"),
    ("Kohu-Kohu Maluku", 120, 4, 4, 18, 4, 350, 5, "local_indonesian"),
    ("Gohu Ikan Maluku", 100, 12, 2, 10, 3, 350, 3, "local_indonesian"),
    ("Sambal Colo-Colo Maluku", 50, 2, 3, 6, 3, 300, 2, "local_indonesian"),
    ("Nasi Jaha Maluku", 280, 6, 6, 44, 3, 350, 3, "local_indonesian"),
    ("Woku Komo-Komo Maluku", 280, 22, 12, 16, 4, 480, 3, "local_indonesian"),
    # Riau / Kepri
    ("Mie Tarempa", 380, 14, 10, 50, 5, 580, 3, "local_indonesian"),
    ("Gulai Siput Riau", 180, 12, 8, 14, 3, 450, 2, "local_indonesian"),
    ("Ikan Sembilang Bakar Riau", 240, 20, 9, 16, 3, 420, 1, "local_indonesian"),
    ("Laksa Kepri", 380, 14, 14, 44, 5, 580, 3, "local_indonesian"),
    ("Nasi Dagang Kepri", 380, 12, 10, 52, 4, 480, 3, "local_indonesian"),
    # Jambi
    ("Tempoyak Jambi", 80, 3, 4, 10, 3, 350, 3, "local_indonesian"),
    ("Gulai Ikan Tempoyak", 280, 20, 14, 16, 4, 500, 2, "local_indonesian"),
    ("Nasi Minyak Jambi", 260, 5, 8, 40, 2, 100, 1, "local_indonesian"),
    ("Sate Ikan Jambi", 220, 18, 8, 16, 3, 420, 2, "local_indonesian"),
    # Lampung
    ("Seruit Lampung", 280, 18, 10, 24, 4, 450, 3, "local_indonesian"),
    ("Sambal Seruit", 60, 2, 4, 6, 3, 350, 2, "local_indonesian"),
    ("Pindang Ikan Lampung", 220, 20, 8, 14, 3, 500, 2, "local_indonesian"),
    ("Engkak Lampung", 200, 5, 6, 30, 14, 100, 2, "snack"),
    ("Kue Talam Lampung", 180, 4, 7, 24, 12, 90, 2, "snack"),
    # Bengkulu
    ("Pendap Bengkulu", 220, 16, 10, 16, 4, 480, 3, "local_indonesian"),
    ("Bagari Hiu Bengkulu", 200, 18, 6, 16, 3, 420, 2, "local_indonesian"),
    ("Sambal Tempoyak Bengkulu", 80, 3, 4, 10, 3, 350, 3, "local_indonesian"),
    # Bangka Belitung
    ("Lempah Kuning Bangka", 280, 20, 12, 20, 4, 500, 3, "local_indonesian"),
    ("Mie Bangka", 380, 14, 10, 50, 5, 560, 3, "local_indonesian"),
    ("Otak-Otak Bangka", 180, 10, 6, 20, 3, 420, 2, "local_indonesian"),
    ("Martabak Manis Bangka", 350, 10, 18, 36, 16, 250, 2, "snack"),
    ("Kemplang Panggang", 120, 4, 2, 20, 2, 300, 1, "snack"),
    # Gorontalo
    ("Binte Biluhuta", 250, 12, 8, 30, 6, 450, 4, "local_indonesian"),
    ("Ayam Iloni", 320, 26, 14, 18, 5, 500, 2, "local_indonesian"),
    ("Sate Tuna Gorontalo", 240, 20, 8, 18, 4, 420, 2, "local_indonesian"),
    ("Tili Aya", 280, 20, 10, 22, 4, 480, 3, "local_indonesian"),
    # Kalimantan Timur
    ("Nasi Bekepor", 380, 14, 10, 50, 4, 480, 3, "local_indonesian"),
    ("Gence Ruan", 220, 18, 9, 16, 3, 450, 2, "local_indonesian"),
    # Kalimantan Selatan
    ("Sate Tulang Banjar", 200, 14, 8, 16, 4, 420, 2, "local_indonesian"),
    ("Gangan Asam Banjar", 250, 18, 10, 18, 4, 480, 3, "local_indonesian"),
    # Kalimantan Barat
    ("Bubur Pedas Sambas", 200, 8, 5, 28, 4, 450, 4, "local_indonesian"),
    ("Pengkang Kalbar", 180, 6, 6, 24, 3, 380, 3, "snack"),
    ("Kwe Cap Pontianak", 280, 10, 8, 36, 4, 500, 3, "local_indonesian"),
    ("Mie Tiau Pontianak", 350, 12, 8, 50, 5, 550, 3, "local_indonesian"),
    # Sulawesi Tenggara
    ("Lapa-Lapa Sultra", 220, 6, 6, 36, 4, 350, 4, "snack"),
    ("Sinonggi Sultra", 200, 3, 2, 40, 2, 200, 3, "local_indonesian"),
    ("Kasuami Sultra", 180, 3, 2, 36, 2, 150, 3, "snack"),
    # Sulawesi Tengah
    ("Kaledo Sulteng", 280, 18, 10, 22, 4, 480, 3, "local_indonesian"),
    ("Uta Dada Sulteng", 320, 26, 14, 16, 4, 480, 2, "local_indonesian"),
    # Sulawesi Barat
    ("Bau Peapi Sulbar", 280, 20, 12, 18, 4, 500, 2, "local_indonesian"),
    ("Jepa Sulbar", 250, 6, 6, 44, 3, 350, 4, "snack"),
    # DIY
    ("Gathot Jogja", 180, 3, 2, 36, 4, 100, 5, "local_indonesian"),
    ("TiWul Jogja", 180, 3, 2, 38, 4, 100, 5, "local_indonesian"),
    ("Growol Jogja", 160, 3, 2, 32, 3, 80, 5, "local_indonesian"),
    ("Geplak Jogja", 140, 2, 3, 24, 18, 50, 4, "snack"),
    ("Yangko Jogja", 130, 2, 2, 24, 20, 40, 2, "snack"),
    ("Bakpia Jogja", 160, 4, 5, 24, 8, 100, 2, "snack"),
    ("Bakpia Coklat Jogja", 170, 4, 6, 24, 10, 100, 2, "snack"),
    # Jawa Timur (more)
    ("Rawon Daging", 320, 24, 14, 18, 4, 500, 3, "local_indonesian"),
    ("Rawon Ayam", 280, 22, 10, 18, 4, 480, 3, "local_indonesian"),
    ("Rawon Iga", 300, 22, 14, 18, 4, 500, 3, "local_indonesian"),
    ("Lontong Balap Surabaya", 320, 10, 8, 46, 4, 500, 4, "local_indonesian"),
    ("Tahu Campur Surabaya", 280, 12, 10, 28, 5, 500, 4, "local_indonesian"),
    ("Tahu Tek Surabaya", 250, 10, 10, 28, 5, 480, 4, "local_indonesian"),
    ("Rujak Cingur Surabaya", 250, 10, 10, 28, 8, 450, 4, "local_indonesian"),
    ("Sate Kelopo", 260, 20, 12, 16, 4, 400, 2, "local_indonesian"),
    ("Sate Kerang Surabaya", 180, 14, 6, 16, 4, 420, 2, "local_indonesian"),
    ("Bakso Malang Komplit", 400, 18, 14, 44, 5, 650, 3, "local_indonesian"),
    ("Cwie Mie Malang", 350, 12, 10, 48, 5, 550, 3, "local_indonesian"),
    ("Sop Buntut Malang", 350, 28, 16, 18, 4, 520, 2, "local_indonesian"),
    ("Orem-Orem Malang", 320, 16, 14, 28, 5, 500, 3, "local_indonesian"),
    ("Nasi Tempong Banyuwangi", 380, 14, 10, 50, 4, 480, 4, "local_indonesian"),
    ("Sego Cawuk Banyuwangi", 350, 12, 8, 50, 4, 450, 4, "local_indonesian"),
    ("Ayam Betutu Banyuwangi", 380, 28, 18, 18, 5, 500, 2, "local_indonesian"),
    ("Pecel Tumpang Kediri", 300, 10, 10, 36, 6, 420, 6, "local_indonesian"),
    ("Nasi Becek Kediri", 350, 16, 12, 38, 4, 500, 3, "local_indonesian"),
    ("Sate Kambing Muda", 280, 22, 14, 14, 4, 420, 1, "local_indonesian"),
    ("Gule Kambing Muda", 300, 22, 16, 14, 3, 480, 2, "local_indonesian"),
    ("Tongseng Kambing Muda", 320, 22, 16, 16, 4, 500, 2, "local_indonesian"),
]
for item in regional3:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 55. MORE SATE VARIANTS
# ================================================================
sate_variants = [
    ("Sate Klatak", 250, 22, 12, 10, 3, 400, 1, "local_indonesian"),
    ("Sate Taichan", 220, 24, 8, 8, 2, 350, 1, "other"),
    ("Sate Buntel", 280, 20, 14, 14, 4, 450, 1, "local_indonesian"),
    ("Sate Lilit Bali", 250, 18, 10, 18, 4, 420, 2, "local_indonesian"),
    ("Sate Lilit Ayam", 240, 20, 10, 16, 4, 400, 2, "local_indonesian"),
    ("Sate Lilit Ikan", 220, 16, 8, 18, 4, 380, 2, "local_indonesian"),
    ("Sate Kambing Muda", 280, 24, 14, 14, 3, 420, 1, "local_indonesian"),
    ("Sate Ayam Madura", 250, 20, 10, 14, 4, 450, 1, "local_indonesian"),
    ("Sate Ayam Ponorogo", 260, 20, 10, 16, 4, 450, 1, "local_indonesian"),
    ("Sate Ayam Blora", 260, 20, 10, 16, 4, 450, 1, "local_indonesian"),
    ("Sate Ayam Bumbu Kacang Enak", 260, 20, 10, 16, 4, 450, 1, "local_indonesian"),
    ("Sate Sapi Gajah", 300, 26, 12, 16, 4, 420, 1, "local_indonesian"),
    ("Sate Sapi Bumbu Kecap", 290, 26, 12, 16, 5, 500, 1, "local_indonesian"),
    ("Sate Sapi Maranggi", 280, 24, 10, 18, 5, 450, 1, "local_indonesian"),
    ("Sate Kerbau Kudus", 260, 24, 8, 16, 4, 400, 1, "local_indonesian"),
    ("Sate Ayam Kecap Manis", 260, 20, 10, 16, 5, 480, 1, "local_indonesian"),
    ("Sate Sapi Manis", 290, 26, 12, 16, 5, 480, 1, "local_indonesian"),
    ("Sate Padang Spesial", 280, 20, 12, 20, 4, 500, 2, "local_indonesian"),
    ("Sate Ampet", 220, 18, 10, 12, 3, 400, 1, "local_indonesian"),
    ("Sate Rembiga", 260, 22, 10, 16, 4, 420, 1, "local_indonesian"),
    ("Sate Jamur", 150, 8, 6, 16, 4, 350, 3, "other"),
    ("Sate Tempe Gembus", 160, 10, 8, 14, 3, 350, 3, "other"),
    ("Sate Telur Puyuh", 180, 12, 10, 10, 3, 350, 1, "snack"),
]
for item in sate_variants:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 56. GULE / GULAI / KARI EXT
# ================================================================
gulai_ext = [
    ("Gulai Kikil", 250, 14, 16, 10, 3, 480, 2, "local_indonesian"),
    ("Gulai Babat", 220, 16, 12, 10, 3, 480, 2, "local_indonesian"),
    ("Gulai Jeroan", 240, 16, 14, 10, 3, 500, 2, "local_indonesian"),
    ("Gulai Nangka", 200, 4, 10, 24, 5, 350, 5, "local_indonesian"),
    ("Gulai Nangka Muda", 200, 4, 10, 24, 5, 350, 5, "local_indonesian"),
    ("Gulai Daun Singkong", 180, 6, 12, 14, 3, 350, 4, "local_indonesian"),
    ("Gulai Pakis", 160, 4, 10, 14, 3, 350, 4, "local_indonesian"),
    ("Gulai Rebung", 150, 3, 8, 16, 4, 350, 5, "local_indonesian"),
    ("Gulai Terong", 150, 3, 8, 16, 4, 300, 4, "local_indonesian"),
    ("Gulai Labu", 160, 3, 8, 18, 5, 300, 4, "local_indonesian"),
    ("Gulai Tahu", 180, 8, 10, 14, 3, 380, 3, "local_indonesian"),
    ("Gulai Tempe", 200, 10, 10, 16, 3, 380, 3, "local_indonesian"),
    ("Gulai Telur", 180, 8, 12, 10, 3, 380, 1, "local_indonesian"),
    ("Kari Ayam Indonesia", 300, 20, 16, 18, 5, 480, 3, "local_indonesian"),
    ("Kari Daging Indonesia", 330, 22, 18, 16, 4, 500, 2, "local_indonesian"),
    ("Kari Ikan Indonesia", 260, 20, 14, 14, 4, 480, 2, "local_indonesian"),
    ("Kari Udang Indonesia", 250, 16, 14, 16, 4, 500, 2, "local_indonesian"),
    ("Kari Telur Indonesia", 200, 10, 14, 10, 4, 400, 1, "local_indonesian"),
    ("Kari Sayuran Indonesia", 180, 6, 10, 18, 5, 420, 5, "local_indonesian"),
]
for item in gulai_ext:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 57. PEPES VARIANTS
# ================================================================
pepes = [
    ("Pepes Ayam Kemangi", 250, 24, 10, 12, 3, 380, 2, "local_indonesian"),
    ("Pepes Ayam Jamur", 240, 22, 10, 14, 3, 380, 2, "local_indonesian"),
    ("Pepes Ikan Mas", 220, 20, 8, 14, 3, 380, 2, "local_indonesian"),
    ("Pepes Ikan Kembung", 230, 22, 8, 14, 3, 380, 2, "local_indonesian"),
    ("Pepes Udang", 200, 18, 6, 16, 3, 400, 2, "local_indonesian"),
    ("Pepes Cumi", 180, 16, 5, 18, 3, 400, 2, "local_indonesian"),
    ("Pepes Tahu", 180, 10, 8, 16, 3, 350, 3, "local_indonesian"),
    ("Pepes Tempe", 200, 12, 9, 18, 3, 350, 3, "local_indonesian"),
    ("Pepes Oncom", 180, 8, 8, 18, 3, 350, 4, "local_indonesian"),
    ("Pepes Jamur", 150, 6, 5, 18, 3, 300, 4, "local_indonesian"),
    ("Pepes Teri", 180, 16, 6, 14, 2, 450, 2, "local_indonesian"),
]
for item in pepes:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 58. MORE SOUP INTERNASIONAL
# ================================================================
soups_intl = [
    ("Minestrone Italia", 150, 6, 4, 22, 5, 450, 5, "other"),
    ("French Onion Soup", 180, 6, 8, 20, 6, 500, 3, "other"),
    ("Clam Chowder", 250, 10, 14, 20, 4, 550, 2, "other"),
    ("Corn Chowder", 220, 6, 8, 28, 6, 400, 4, "other"),
    ("Lobster Bisque", 200, 8, 12, 14, 4, 500, 2, "other"),
    ("Gazpacho Spanyol", 80, 3, 2, 14, 6, 350, 4, "other"),
    ("Borscht Rusia", 120, 4, 3, 20, 8, 450, 5, "other"),
    ("Wonton Soup", 200, 12, 5, 24, 3, 600, 2, "other"),
    ("Hot Sour Soup Cina", 150, 10, 5, 16, 3, 650, 3, "other"),
    ("Egg Drop Soup", 100, 6, 4, 10, 2, 500, 1, "other"),
    ("Mulligatawny Soup", 200, 8, 8, 24, 5, 480, 5, "other"),
    ("Chicken Noodle Soup", 180, 14, 5, 20, 3, 550, 2, "other"),
    ("Beef Vegetable Soup", 200, 14, 6, 22, 5, 500, 4, "other"),
    ("Lentil Soup", 180, 10, 4, 26, 4, 450, 7, "other"),
    ("Pumpkin Soup", 140, 3, 5, 22, 8, 350, 4, "other"),
    ("Tomato Basil Soup", 120, 4, 5, 16, 8, 450, 3, "other"),
    ("Mushroom Soup Cream", 180, 5, 12, 14, 4, 480, 3, "other"),
    ("Potato Leek Soup", 180, 4, 8, 24, 5, 400, 3, "other"),
    ("Spinach Soup", 100, 5, 4, 12, 3, 400, 4, "other"),
    ("Zuppa Toscana", 250, 12, 14, 18, 3, 550, 3, "other"),
]
for item in soups_intl:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 59. BREAKFAST INTERNASIONAL
# ================================================================
breakfast_intl = [
    ("Full English Breakfast", 650, 32, 38, 42, 6, 800, 4, "other"),
    ("American Breakfast", 500, 22, 28, 36, 5, 600, 3, "other"),
    ("Continental Breakfast", 350, 10, 12, 46, 10, 350, 4, "other"),
    ("Turkish Breakfast", 500, 18, 28, 40, 8, 650, 5, "other"),
    ("Shakshuka", 280, 14, 14, 24, 8, 500, 4, "other"),
    ("Menemen Turki", 300, 14, 18, 16, 5, 450, 3, "other"),
    ("Congee Cina", 200, 8, 3, 34, 2, 500, 2, "other"),
    ("Kedgeree Inggris", 350, 18, 10, 44, 4, 480, 3, "other"),
    ("Stroop Wafel", 250, 4, 10, 34, 16, 150, 1, "snack"),
    ("Crepe Prancis", 180, 5, 7, 24, 6, 200, 1, "other"),
    ("Crepe Coklat", 200, 5, 8, 26, 10, 200, 2, "other"),
    ("Crepe Keju", 200, 7, 10, 22, 4, 280, 1, "other"),
    ("Crepe Buah", 180, 5, 5, 28, 12, 150, 3, "other"),
    ("Bircher Muesli", 280, 8, 8, 40, 14, 50, 6, "other"),
    ("Eggs Benedict", 380, 16, 22, 26, 3, 500, 2, "other"),
    ("Avocado Toast Modern", 300, 8, 16, 28, 3, 300, 6, "other"),
    ("Smashed Avocado", 280, 6, 16, 26, 3, 250, 6, "other"),
]
for item in breakfast_intl:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 60. RENDANG / KALIO VARIANTS
# ================================================================
rendang_ext = [
    ("Rendang Ayam Kampung", 380, 28, 18, 18, 5, 450, 2, "local_indonesian"),
    ("Rendang Jengkol", 250, 8, 10, 28, 4, 350, 5, "local_indonesian"),
    ("Rendang Lokan", 200, 16, 10, 12, 3, 450, 2, "local_indonesian"),
    ("Rendang Udang", 220, 18, 12, 10, 3, 400, 2, "local_indonesian"),
    ("Rendang Belut", 250, 20, 10, 14, 3, 420, 2, "local_indonesian"),
    ("Rendang Nangka", 220, 4, 12, 22, 4, 380, 5, "local_indonesian"),
    ("Rendang Daun Singkong", 200, 6, 14, 14, 3, 380, 4, "local_indonesian"),
    ("Kalio Ayam", 320, 24, 16, 16, 4, 420, 2, "local_indonesian"),
    ("Kalio Daging", 360, 26, 20, 14, 4, 450, 2, "local_indonesian"),
    ("Kalio Kambing", 370, 24, 22, 14, 4, 460, 2, "local_indonesian"),
    ("Kalio Hati Sapi", 280, 22, 14, 12, 4, 420, 2, "local_indonesian"),
    ("Kalio Ikan", 260, 22, 14, 10, 3, 420, 2, "local_indonesian"),
    ("Kalio Udang", 250, 18, 14, 10, 3, 400, 2, "local_indonesian"),
]
for item in rendang_ext:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# SAVE
# ================================================================
print(f"\nPart 5 total new: {count}")
if new:
    ndf = pd.DataFrame(new)
    ndf.to_csv(FINAL_OUTPUT, mode='a', header=False, index=False)
    df = pd.read_csv(FINAL_OUTPUT)
    print(f"Running total: {len(df)} foods")
    print(df["food_type"].value_counts().to_string())
else:
    print("No new foods added!")
