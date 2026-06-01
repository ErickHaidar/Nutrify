"""Batch 10 Part 4: International + Regional Deep Dive + Target 10,000."""
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
# 23. ITALIAN PASTA — 12 pastas × 15 sauces
# ================================================================
pasta_base = {
    "Spaghetti": (220, 8, 1.5, 43, 2, 5, 1.5),
    "Fettuccine": (230, 9, 2.0, 44, 2, 8, 1.5),
    "Penne": (225, 8, 1.5, 43, 2, 5, 1.5),
    "Fusilli": (225, 8, 1.5, 43, 2, 5, 1.5),
    "Linguine": (225, 8, 1.5, 43, 2, 5, 1.5),
    "Rigatoni": (230, 9, 2.0, 44, 2, 8, 1.5),
    "Tagliatelle": (230, 9, 2.0, 44, 2, 8, 1.5),
    "Ravioli": (260, 11, 8.0, 36, 3, 300, 2.0),
    "Tortellini": (270, 12, 9.0, 35, 3, 320, 2.0),
    "Lasagna": (280, 14, 10.0, 33, 4, 350, 2.0),
    "Makaroni": (220, 8, 1.5, 43, 2, 5, 1.5),
    "Spageti": (220, 8, 1.5, 43, 2, 5, 1.5),
}
pasta_sauce = {
    "Bolognese": (1.8, 1.8, 2.5, 1.2, 1.0, 2.0, 1.0),
    "Carbonara": (2.0, 1.5, 3.0, 1.1, 1.0, 2.0, 1.0),
    "Alfredo": (2.0, 1.3, 3.5, 1.1, 1.0, 1.8, 1.0),
    "Pesto": (1.6, 1.3, 2.5, 1.0, 0.9, 1.5, 1.0),
    "Marinara": (1.3, 1.3, 1.5, 1.0, 1.0, 1.5, 1.0),
    "Aglio Olio": (1.5, 1.0, 2.5, 1.0, 0.9, 1.2, 1.0),
    "Arrabiata": (1.3, 1.2, 1.5, 1.0, 1.0, 1.3, 1.0),
    "Primavera": (1.2, 1.2, 1.2, 1.0, 1.0, 1.2, 1.0),
    "Napoli": (1.3, 1.2, 1.5, 1.0, 1.0, 1.4, 1.0),
    "Funghi": (1.4, 1.3, 1.8, 1.1, 1.0, 1.5, 1.0),
    "Cacio Pepe": (1.6, 1.3, 2.5, 1.0, 0.9, 1.5, 1.0),
    "Amatriciana": (1.5, 1.4, 2.0, 1.1, 1.0, 1.6, 1.0),
    "Putanesca": (1.4, 1.4, 2.0, 1.1, 1.0, 1.8, 1.0),
    "Bechamel": (1.8, 1.2, 3.0, 1.1, 1.0, 1.8, 1.0),
    "Ricotta Bayam": (1.4, 1.4, 1.8, 1.0, 1.0, 1.5, 1.2),
}
for pname, (pc, pp, pf, pcb, ps, pso, pfb) in pasta_base.items():
    for sname, (smc, smp, smf, smcb, sms, smso, smfb) in pasta_sauce.items():
        name = f"{pname} {sname}"
        cal = round(pc * smc)
        prot = round(pp * smp, 1)
        fat = round(pf * smf, 1)
        carbs = round(pcb * smcb, 1)
        sug = round(ps * sms, 1)
        sod = round(pso * smso)
        fib = round(pfb * smfb, 1)
        if add(name, cal, prot, fat, carbs, sug, sod, fib, "other", "gen-batch10"):
            count += 1

# ================================================================
# 24. JAPANESE FOODS
# ================================================================
japanese_dishes = [
    ("Nasi Kari Jepang", 520, 18, 14, 72, 8, 650, 3, "other"),
    ("Katsu Kari Jepang", 650, 28, 22, 78, 10, 750, 3, "other"),
    ("Miso Sup Tahu", 85, 7, 3, 8, 3, 700, 2, "other"),
    ("Miso Sup Salmon", 120, 12, 5, 6, 2, 720, 1, "other"),
    ("Miso Sup Jamur", 70, 5, 2, 8, 3, 680, 2, "other"),
    ("Miso Sup Wakame", 60, 4, 2, 7, 2, 690, 2, "other"),
    ("Miso Sup Sayuran", 65, 4, 2, 8, 3, 680, 2, "other"),
    ("Chicken Katsu Jepang", 480, 25, 18, 52, 5, 550, 2, "other"),
    ("Chicken Teriyaki Bowl", 520, 28, 12, 65, 10, 700, 2, "other"),
    ("Beef Teriyaki Bowl", 580, 30, 15, 65, 10, 720, 2, "other"),
    ("Salmon Teriyaki Bowl", 550, 32, 16, 58, 9, 680, 2, "other"),
    ("Tori Karaage Jepang", 420, 24, 18, 40, 3, 500, 1, "other"),
    ("Ebi Furai Jepang", 380, 16, 14, 44, 4, 480, 2, "other"),
    ("Okonomiyaki", 350, 12, 14, 42, 7, 600, 2, "other"),
    ("Takoyaki Jepang", 280, 10, 12, 32, 4, 500, 2, "other"),
    ("Yakisoba Jepang", 420, 14, 12, 58, 6, 650, 3, "other"),
    ("Yaki Udon", 440, 13, 10, 65, 5, 620, 2, "other"),
    ("Udon Kuah Jepang", 320, 10, 3, 58, 4, 700, 2, "other"),
    ("Soba Dingin Jepang", 280, 12, 2, 50, 3, 550, 2, "other"),
    ("Soba Kuah Panas", 300, 13, 3, 52, 3, 600, 2, "other"),
    ("Tempura Campur", 350, 8, 16, 42, 4, 400, 2, "other"),
    ("Tempura Udang", 320, 10, 14, 38, 3, 380, 1, "other"),
    ("Tempura Sayuran", 250, 5, 12, 32, 4, 350, 3, "other"),
    ("Omelet Nasi Jepang", 380, 14, 12, 50, 4, 450, 1, "other"),
    ("Nasi Onigiri Salmon", 220, 8, 3, 38, 2, 350, 1, "other"),
    ("Nasi Onigiri Tuna Mayo", 230, 10, 5, 36, 2, 400, 1, "other"),
    ("Nasi Onigiri Ayam Teriyaki", 240, 9, 4, 38, 3, 420, 1, "other"),
    ("Chicken Katsu Kari", 620, 28, 22, 68, 8, 720, 3, "other"),
    ("Sukiyaki Daging Jepang", 450, 28, 18, 38, 10, 800, 3, "other"),
    ("Shabu-shabu Jepang", 320, 26, 12, 22, 6, 600, 2, "other"),
    ("Gyudon Jepang", 550, 24, 14, 68, 8, 700, 2, "other"),
    ("Oyakodon Jepang", 480, 26, 12, 58, 5, 650, 2, "other"),
    ("Katsudon Jepang", 600, 28, 18, 62, 6, 700, 2, "other"),
    ("Chirashi Sushi", 420, 22, 10, 55, 6, 500, 2, "other"),
    ("Inari Sushi", 180, 6, 3, 32, 5, 350, 1, "other"),
    ("Tamago Sushi", 160, 8, 4, 22, 4, 300, 1, "other"),
    ("California Roll", 350, 12, 8, 52, 6, 400, 2, "other"),
    ("Dragon Roll", 400, 14, 10, 55, 7, 450, 2, "other"),
    ("Spicy Tuna Roll", 380, 18, 9, 50, 5, 480, 2, "other"),
    ("Philadelphia Roll", 380, 14, 12, 48, 6, 420, 2, "other"),
    ("Rainbow Roll", 400, 16, 10, 54, 6, 430, 2, "other"),
    ("Nasi Katsu Don", 580, 26, 16, 64, 6, 680, 2, "other"),
    ("Ayam Nanban Jepang", 440, 26, 16, 42, 8, 580, 2, "other"),
    ("Ikan Bakar Jepang Shioyaki", 280, 24, 8, 25, 3, 450, 1, "other"),
    ("Nimono Sayuran", 120, 5, 3, 18, 6, 400, 3, "other"),
    ("Chawanmushi Jepang", 130, 8, 6, 10, 3, 450, 1, "other"),
    ("Agedashi Tofu", 200, 10, 10, 16, 3, 500, 2, "other"),
    ("Gyoza Jepang", 280, 12, 12, 28, 3, 500, 2, "other"),
    ("Edamame Rebus", 120, 11, 5, 9, 2, 300, 5, "other"),
]
for item in japanese_dishes:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 25. KOREAN FOODS
# ================================================================
korean_dishes = [
    ("Bibimbap Korea", 520, 22, 14, 68, 8, 650, 4, "other"),
    ("Bulgogi Sapi Korea", 420, 26, 16, 38, 10, 700, 2, "other"),
    ("Korean Fried Chicken", 480, 28, 22, 38, 6, 600, 1, "other"),
    ("Tteokbokki Korea", 320, 6, 5, 58, 10, 650, 2, "other"),
    ("Japchae Korea", 350, 8, 8, 55, 8, 550, 3, "other"),
    ("Kimchi Jjigae", 220, 12, 10, 18, 5, 800, 3, "other"),
    ("Sundubu Jjigae", 250, 14, 12, 18, 4, 750, 2, "other"),
    ("Doenjang Jjigae", 200, 12, 8, 16, 4, 780, 3, "other"),
    ("Samgyeopsal Korea", 550, 22, 38, 18, 3, 650, 1, "other"),
    ("Dakgalbi Korea", 420, 28, 14, 38, 8, 700, 2, "other"),
    ("Samgyetang Korea", 350, 28, 12, 28, 4, 500, 2, "other"),
    ("Jajangmyeon Korea", 480, 14, 12, 68, 8, 700, 3, "other"),
    ("Naengmyeon Korea", 320, 12, 4, 52, 6, 650, 2, "other"),
    ("Kimbap Korea", 320, 10, 6, 50, 5, 450, 3, "other"),
    ("Pajeon Korea", 280, 8, 10, 36, 4, 500, 2, "other"),
    ("Kimchi Jeon", 250, 6, 9, 34, 4, 550, 3, "other"),
    ("Hotteok Korea", 220, 4, 6, 36, 12, 250, 1, "snack"),
    ("Bungeoppang Korea", 200, 5, 5, 32, 10, 200, 1, "snack"),
    ("Tteok Galbi Korea", 380, 24, 14, 34, 8, 650, 2, "other"),
    ("Jokbal Korea", 450, 32, 28, 12, 2, 700, 0, "other"),
    ("Bossam Korea", 420, 30, 24, 14, 3, 650, 2, "other"),
    ("Yukhoe Korea", 280, 28, 14, 6, 2, 400, 0, "other"),
    ("Kongnamul Guk", 80, 6, 2, 10, 3, 450, 3, "other"),
    ("Miyeok Guk Korea", 70, 4, 2, 10, 3, 400, 2, "other"),
    ("Gimbap Tuna", 340, 12, 7, 50, 5, 480, 3, "other"),
    ("Gimbap Bulgogi", 360, 14, 8, 50, 5, 500, 3, "other"),
    ("Gimbap Sayuran", 280, 7, 4, 50, 5, 400, 4, "other"),
    ("Dakgangjeong Korea", 440, 26, 18, 38, 8, 580, 1, "other"),
    ("Budae Jjigae", 480, 22, 20, 44, 6, 850, 3, "other"),
    ("Gyeran Jjim", 120, 8, 7, 5, 2, 350, 0, "other"),
]
for item in korean_dishes:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 26. THAI FOODS
# ================================================================
thai_dishes = [
    ("Pad Thai Ayam", 420, 18, 14, 52, 8, 650, 3, "other"),
    ("Pad Thai Udang", 400, 16, 12, 52, 8, 680, 3, "other"),
    ("Tom Yum Goong", 150, 14, 5, 12, 4, 750, 2, "other"),
    ("Tom Yum Gai", 140, 12, 5, 12, 4, 720, 2, "other"),
    ("Tom Kha Gai", 220, 16, 14, 10, 4, 650, 2, "other"),
    ("Kari Hijau Thailand", 320, 18, 18, 22, 6, 600, 3, "other"),
    ("Kari Merah Thailand", 340, 20, 20, 20, 5, 620, 3, "other"),
    ("Kari Kuning Thailand", 330, 18, 18, 24, 6, 600, 3, "other"),
    ("Kari Massaman", 380, 22, 20, 26, 7, 650, 3, "other"),
    ("Kari Panang Thailand", 350, 20, 22, 18, 5, 620, 2, "other"),
    ("Som Tam Thailand", 120, 4, 4, 18, 8, 500, 3, "other"),
    ("Pad Krapow Gai", 380, 24, 14, 34, 5, 650, 2, "other"),
    ("Pad See Ew", 400, 14, 10, 56, 8, 650, 3, "other"),
    ("Pad Kee Mao", 420, 16, 12, 54, 7, 680, 3, "other"),
    ("Khao Pad Thailand", 380, 12, 10, 54, 5, 550, 2, "other"),
    ("Khao Man Gai Thailand", 420, 22, 12, 48, 4, 500, 1, "other"),
    ("Nasi Mangga Thailand", 350, 5, 7, 64, 20, 250, 3, "other"),
    ("Ayam Sate Thailand", 280, 24, 12, 16, 5, 500, 1, "other"),
    ("Papaya Salad Thailand", 110, 3, 3, 18, 8, 480, 4, "other"),
    ("Larb Gai Thailand", 180, 22, 8, 6, 3, 450, 2, "other"),
    ("Yum Woon Sen", 200, 8, 5, 28, 6, 550, 2, "other"),
    ("Tod Man Pla", 180, 12, 8, 14, 3, 500, 1, "other"),
    ("Pla Rad Prik", 280, 22, 10, 22, 8, 550, 2, "other"),
    ("Khao Soi Thailand", 420, 18, 18, 42, 6, 650, 3, "other"),
    ("Gaeng Daeng", 320, 18, 18, 20, 5, 600, 3, "other"),
    ("Kuay Tiew Thailand", 350, 14, 8, 48, 5, 650, 2, "other"),
    ("Miang Kham", 120, 5, 4, 16, 6, 350, 3, "snack"),
    ("Kai Jeow Thailand", 220, 12, 14, 8, 3, 400, 1, "other"),
    ("Nam Tok Thailand", 200, 22, 8, 8, 4, 500, 2, "other"),
    ("Gaeng Som Thailand", 150, 10, 4, 16, 6, 600, 3, "other"),
]
for item in thai_dishes:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 27. INDIAN FOODS
# ================================================================
indian_dishes = [
    ("Nasi Biryani Ayam", 480, 22, 14, 58, 6, 600, 3, "other"),
    ("Nasi Biryani Kambing", 520, 26, 18, 56, 6, 650, 3, "other"),
    ("Nasi Biryani Sayuran", 400, 12, 10, 58, 6, 550, 4, "other"),
    ("Roti Naan", 260, 8, 6, 42, 3, 350, 2, "other"),
    ("Roti Chapati", 200, 6, 3, 36, 2, 250, 3, "other"),
    ("Roti Paratha", 300, 7, 10, 42, 3, 350, 2, "other"),
    ("Roti Prata", 320, 8, 12, 40, 3, 380, 2, "other"),
    ("Roti Canai", 310, 8, 11, 40, 3, 360, 2, "other"),
    ("Kari Ayam India", 320, 22, 16, 18, 5, 550, 3, "other"),
    ("Kari Kambing India", 350, 24, 18, 16, 5, 580, 2, "other"),
    ("Kari Sayuran India", 180, 6, 8, 20, 6, 450, 5, "other"),
    ("Kari Ikan India", 250, 20, 10, 16, 4, 520, 2, "other"),
    ("Tandoori Ayam", 280, 28, 12, 10, 3, 500, 1, "other"),
    ("Ayam Mentega India", 380, 24, 18, 22, 6, 550, 2, "other"),
    ("Ayam Tikka Masala", 340, 26, 14, 18, 5, 520, 2, "other"),
    ("Palak Paneer", 250, 14, 16, 12, 4, 450, 3, "other"),
    ("Palak Ayam", 260, 22, 12, 14, 3, 480, 3, "other"),
    ("Paneer Makhani", 300, 14, 20, 14, 5, 480, 2, "other"),
    ("Dal Makhani", 220, 10, 10, 22, 3, 400, 6, "other"),
    ("Dal Tadka", 180, 9, 6, 20, 3, 380, 5, "other"),
    ("Chana Masala", 200, 8, 6, 26, 4, 450, 6, "other"),
    ("Aloo Gobi", 160, 4, 6, 22, 5, 400, 5, "other"),
    ("Aloo Matar", 180, 5, 6, 24, 5, 420, 5, "other"),
    ("Samosha Sayuran", 200, 5, 8, 26, 3, 350, 3, "snack"),
    ("Samosha Daging", 250, 10, 12, 24, 3, 400, 2, "snack"),
    ("Pakora Sayuran", 180, 5, 8, 22, 3, 350, 3, "snack"),
    ("Dahi Puri", 150, 5, 5, 20, 4, 300, 2, "snack"),
    ("Pani Puri", 130, 4, 3, 22, 4, 350, 2, "snack"),
    ("Vindaloo Ayam", 340, 26, 16, 16, 4, 600, 2, "other"),
    ("Korma Ayam", 360, 22, 20, 18, 5, 520, 2, "other"),
    ("Saag Ayam", 260, 24, 12, 12, 3, 480, 3, "other"),
    ("Nasi Jeera", 220, 5, 4, 40, 2, 300, 2, "other"),
    ("Nasi Lemon", 210, 5, 3, 38, 3, 280, 2, "other"),
    ("Nasi Kelapa India", 260, 6, 7, 40, 3, 320, 2, "other"),
    ("Kulfi India", 180, 5, 8, 22, 16, 80, 0, "snack"),
    ("Gulab Jamun", 250, 4, 8, 38, 22, 100, 1, "snack"),
    ("Rasmalai", 200, 6, 8, 24, 18, 90, 0, "snack"),
    ("Jalebi India", 220, 3, 7, 36, 20, 60, 0, "snack"),
    ("Lassi Manis", 180, 6, 5, 26, 22, 80, 0, "beverage"),
    ("Lassi Asin", 120, 6, 5, 10, 8, 300, 0, "beverage"),
    ("Mango Lassi", 220, 6, 6, 32, 26, 80, 1, "beverage"),
]
for item in indian_dishes:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 28. MIDDLE EASTERN
# ================================================================
middle_east = [
    ("Nasi Kebuli Ayam", 450, 22, 14, 52, 5, 550, 2, "local_indonesian"),
    ("Nasi Kebuli Kambing", 500, 26, 18, 50, 5, 580, 2, "local_indonesian"),
    ("Nasi Mandhi Ayam", 460, 24, 12, 54, 4, 500, 2, "local_indonesian"),
    ("Nasi Mandhi Kambing", 510, 28, 16, 52, 4, 530, 2, "local_indonesian"),
    ("Nasi Bukhari", 440, 20, 14, 52, 5, 520, 2, "local_indonesian"),
    ("Kebab Sapi", 320, 22, 14, 22, 4, 500, 2, "other"),
    ("Kebab Ayam", 280, 24, 10, 20, 4, 480, 2, "other"),
    ("Kebab Kambing", 350, 24, 16, 20, 4, 520, 2, "other"),
    ("Kofta Kebab", 300, 20, 14, 20, 4, 500, 2, "other"),
    ("Shawarma Ayam", 380, 22, 14, 36, 5, 550, 3, "other"),
    ("Shawarma Sapi", 420, 24, 16, 34, 5, 580, 3, "other"),
    ("Falafel", 250, 8, 10, 30, 4, 400, 5, "other"),
    ("Hummus", 160, 8, 9, 14, 2, 350, 4, "other"),
    ("Hummus Daging", 220, 14, 12, 14, 2, 400, 4, "other"),
    ("Baba Ganoush", 120, 3, 7, 12, 4, 300, 4, "other"),
    ("Tabbouleh", 100, 3, 5, 14, 3, 250, 4, "other"),
    ("Fattoush", 130, 4, 6, 16, 4, 300, 4, "other"),
    ("Mutabbal", 110, 3, 7, 10, 3, 280, 4, "other"),
    ("Shish Tawook", 280, 26, 10, 18, 3, 480, 1, "other"),
    ("Nasi Bukhari Ayam", 440, 22, 12, 52, 5, 500, 2, "local_indonesian"),
]
for item in middle_east:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 29. MEXICAN FOODS
# ================================================================
mexican = [
    ("Taco Sapi Meksiko", 220, 14, 10, 18, 2, 400, 3, "other"),
    ("Taco Ayam Meksiko", 200, 16, 8, 16, 2, 380, 2, "other"),
    ("Taco Ikan", 180, 14, 6, 18, 2, 350, 2, "other"),
    ("Burito Sapi", 450, 24, 16, 44, 4, 650, 4, "other"),
    ("Burito Ayam", 420, 26, 12, 42, 4, 620, 4, "other"),
    ("Quesadilla Ayam", 350, 18, 16, 30, 3, 500, 2, "other"),
    ("Quesadilla Sapi", 380, 20, 18, 30, 3, 520, 2, "other"),
    ("Nachos Meksiko", 400, 10, 18, 44, 4, 550, 4, "snack"),
    ("Enchilada Ayam", 350, 20, 14, 32, 4, 580, 3, "other"),
    ("Enchilada Sapi", 380, 22, 16, 32, 4, 600, 3, "other"),
    ("Fajitas Ayam", 300, 24, 12, 22, 4, 480, 3, "other"),
    ("Fajitas Sapi", 340, 26, 14, 22, 4, 500, 3, "other"),
    ("Chili Con Carne", 320, 22, 14, 24, 5, 550, 5, "other"),
    ("Chili Con Carne Ayam", 280, 24, 10, 22, 5, 520, 5, "other"),
    ("Tamale Meksiko", 250, 8, 10, 30, 3, 400, 3, "other"),
    ("Churros Meksiko", 220, 3, 10, 28, 10, 150, 1, "snack"),
    ("Salsa Meksiko", 40, 2, 0, 8, 4, 300, 2, "other"),
    ("Guacamole Meksiko", 160, 2, 14, 8, 2, 250, 5, "other"),
    ("Elote Meksiko", 180, 5, 8, 22, 4, 300, 3, "snack"),
]
for item in mexican:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 30. MORE INDONESIAN REGIONAL — deep provinces
# ================================================================
indonesian_regional2 = [
    # Aceh
    ("Mie Aceh Goreng", 420, 14, 12, 54, 6, 600, 3, "local_indonesian"),
    ("Mie Aceh Kuah", 380, 14, 10, 50, 6, 580, 3, "local_indonesian"),
    ("Ayam Tangkap Aceh", 320, 24, 14, 18, 4, 500, 2, "local_indonesian"),
    ("Sate Matang Aceh", 250, 20, 10, 14, 3, 450, 1, "local_indonesian"),
    ("Kuah Pliek U Aceh", 180, 8, 10, 14, 4, 450, 3, "local_indonesian"),
    ("Gulai Kambing Aceh", 350, 24, 18, 16, 4, 550, 2, "local_indonesian"),
    ("Ikan Kayu Aceh", 200, 24, 5, 10, 2, 500, 1, "local_indonesian"),
    ("Sambal Ganja Aceh", 80, 3, 5, 8, 3, 350, 2, "local_indonesian"),
    ("Kopi Sanger Aceh", 120, 3, 4, 16, 10, 30, 0, "beverage"),

    # Medan / Sumut
    ("Bihun Bebek Medan", 380, 16, 12, 44, 4, 550, 3, "local_indonesian"),
    ("Lontong Sayur Medan", 320, 8, 10, 44, 6, 500, 4, "local_indonesian"),
    ("Mie Tiong Sim Medan", 350, 12, 10, 48, 5, 580, 2, "local_indonesian"),
    ("Nasi Gurih Medan", 350, 10, 10, 50, 4, 450, 2, "local_indonesian"),
    ("Pecel Lele Medan", 320, 18, 14, 26, 3, 500, 2, "local_indonesian"),
    ("Sate Padang Medan", 280, 18, 12, 20, 4, 500, 2, "local_indonesian"),
    ("Bika Ambon Medan", 200, 4, 6, 30, 14, 150, 1, "snack"),
    ("Lapis Legit Medan", 250, 5, 12, 28, 18, 100, 1, "snack"),
    ("Martabak Medan", 350, 10, 16, 38, 14, 300, 2, "snack"),

    # Palembang
    ("Burgo Palembang", 280, 6, 6, 44, 4, 450, 2, "local_indonesian"),
    ("Celimpungan Palembang", 300, 10, 8, 42, 4, 500, 2, "local_indonesian"),
    ("Laksan Palembang", 280, 8, 8, 40, 4, 480, 2, "local_indonesian"),
    ("Lenggang Palembang", 250, 8, 10, 30, 4, 400, 2, "local_indonesian"),
    ("Mie Celor Palembang", 350, 12, 12, 44, 5, 550, 2, "local_indonesian"),
    ("Pindang Patin Palembang", 200, 18, 8, 12, 3, 480, 1, "local_indonesian"),
    ("Pindang Iga Palembang", 250, 18, 10, 16, 3, 500, 1, "local_indonesian"),
    ("Tekwan Palembang", 220, 12, 4, 30, 3, 500, 2, "local_indonesian"),

    # Kalimantan
    ("Soto Banjar Kalimantan", 250, 14, 10, 24, 4, 500, 3, "local_indonesian"),
    ("Ketupat Kandangan", 300, 8, 8, 44, 4, 450, 3, "local_indonesian"),
    ("Nasi Kuning Banjar", 350, 10, 10, 48, 5, 450, 2, "local_indonesian"),
    ("Ikan Baung Bakar", 220, 20, 8, 14, 2, 400, 1, "local_indonesian"),
    ("Ayam Masak Habang", 320, 24, 14, 18, 6, 500, 2, "local_indonesian"),
    ("Gulai Asam Pedas Banjar", 280, 18, 12, 20, 5, 520, 2, "local_indonesian"),
    ("Amplang Kalimantan", 150, 6, 6, 18, 2, 350, 1, "snack"),
    ("Sate Banjar", 250, 20, 10, 16, 4, 480, 2, "local_indonesian"),

    # Pontianak
    ("Bubur Pedas Pontianak", 200, 8, 5, 28, 4, 450, 4, "local_indonesian"),
    ("Chai Kwe Pontianak", 180, 6, 6, 24, 3, 400, 2, "local_indonesian"),
    ("Sotong Pangkong", 150, 10, 4, 18, 3, 380, 1, "snack"),
    ("Kwe Cap Pontianak", 280, 10, 8, 36, 4, 500, 3, "local_indonesian"),

    # Makassar
    ("Sop Saudara Makassar", 280, 16, 10, 26, 4, 500, 3, "local_indonesian"),
    ("Ikan Palumara", 200, 20, 8, 12, 3, 450, 1, "local_indonesian"),
    ("Ayam Palekko", 320, 24, 14, 18, 5, 500, 2, "local_indonesian"),
    ("Nasu Palekko", 350, 22, 16, 22, 4, 520, 2, "local_indonesian"),
    ("Barongko Pisang", 180, 4, 5, 28, 14, 80, 2, "snack"),
    ("Pisang Epe Makassar", 200, 3, 5, 34, 16, 100, 3, "snack"),
    ("Buras Makassar", 280, 8, 8, 38, 3, 350, 3, "local_indonesian"),
    ("Kapurung Makassar", 200, 6, 4, 32, 3, 400, 4, "local_indonesian"),

    # Sulawesi Utara
    ("Bubur Manado", 220, 6, 4, 36, 4, 400, 5, "local_indonesian"),
    ("Ikan Woku Manado", 250, 22, 10, 14, 3, 480, 2, "local_indonesian"),
    ("Ayam Woku", 320, 26, 14, 16, 4, 500, 2, "local_indonesian"),
    ("Daging Woku", 350, 28, 16, 16, 3, 520, 2, "local_indonesian"),
    ("Nasi Bungkus Manado", 350, 12, 8, 52, 4, 450, 3, "local_indonesian"),

    # NTT / Flores
    ("Sei Sapi NTT", 320, 28, 10, 22, 4, 550, 1, "local_indonesian"),
    ("Sei Ayam NTT", 280, 26, 8, 20, 4, 520, 1, "local_indonesian"),
    ("Nasi Jagung NTT", 280, 6, 4, 52, 3, 300, 4, "local_indonesian"),
    ("Jagung Katemak NTT", 250, 8, 6, 40, 4, 350, 5, "local_indonesian"),
    ("Katemak NTT", 200, 8, 6, 28, 4, 380, 5, "local_indonesian"),

    # Papua
    ("Papeda Papua", 200, 2, 1, 44, 1, 200, 2, "local_indonesian"),
    ("Ikan Kuah Kuning Papua", 220, 22, 8, 14, 3, 480, 1, "local_indonesian"),
    ("Ayam Lada Hitam Papua", 320, 26, 14, 18, 4, 500, 2, "local_indonesian"),
    ("Sate Rusa Papua", 250, 24, 8, 16, 3, 450, 1, "local_indonesian"),
    ("Udang Selingkuh Papua", 200, 18, 5, 18, 3, 400, 1, "local_indonesian"),
]
for item in indonesian_regional2:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 31. MORE SOUP / STEW / SOTO VARIANTS
# ================================================================
soup_ext = [
    ("Sop Merah Surabaya", 280, 16, 10, 26, 5, 550, 3, "local_indonesian"),
    ("Sop Konro Makassar", 320, 24, 14, 18, 3, 520, 2, "local_indonesian"),
    ("Sop Iga Sapi", 300, 22, 12, 20, 4, 500, 2, "local_indonesian"),
    ("Sop Buntut", 350, 28, 16, 18, 3, 520, 1, "local_indonesian"),
    ("Sop Kaki Kambing", 280, 20, 14, 16, 3, 550, 1, "local_indonesian"),
    ("Sop Kepala Ikan", 250, 22, 10, 14, 3, 500, 1, "local_indonesian"),
    ("Sop Asparagus Kepiting", 180, 14, 6, 16, 4, 480, 3, "other"),
    ("Sop Kimlo", 220, 14, 8, 20, 5, 550, 3, "other"),
    ("Sop Ayam Jahe", 180, 18, 6, 14, 4, 450, 2, "other"),
    ("Sop Udang Tomat", 150, 14, 4, 14, 5, 480, 2, "other"),
    ("Sop Ayam Makaroni", 220, 16, 6, 24, 4, 450, 2, "other"),
    ("Sop Ayam Sosis", 250, 18, 10, 20, 4, 550, 2, "other"),
    ("Sop Ayam Jagung", 200, 16, 5, 22, 5, 420, 3, "other"),
    ("Sop Oyong Bihun", 150, 6, 3, 24, 4, 400, 3, "other"),
    ("Sop Kambing Rempah", 300, 24, 14, 16, 3, 500, 2, "local_indonesian"),
    ("Sop Ceker Ayam", 200, 16, 8, 16, 3, 450, 1, "other"),
    ("Sop Sayuran Bakso", 180, 8, 5, 24, 5, 550, 4, "other"),
    ("Sop Tahu Putih", 150, 8, 6, 16, 3, 400, 3, "other"),
    ("Soto Padang", 280, 16, 10, 26, 4, 520, 3, "local_indonesian"),
    ("Soto Kudus", 260, 16, 8, 26, 4, 500, 3, "local_indonesian"),
    ("Soto Sokaraja", 270, 14, 10, 26, 4, 510, 3, "local_indonesian"),
    ("Soto Semarang", 280, 16, 10, 26, 4, 520, 3, "local_indonesian"),
    ("Soto Medan", 290, 16, 10, 28, 5, 530, 3, "local_indonesian"),
    ("Soto Pontianak", 270, 16, 8, 28, 5, 510, 3, "local_indonesian"),
    ("Soto Taichan", 300, 18, 10, 28, 4, 550, 2, "local_indonesian"),
    ("Soto Ayam Kampung", 260, 18, 8, 24, 4, 480, 3, "local_indonesian"),
    ("Gulai Ikan Karang", 250, 20, 12, 14, 3, 480, 2, "local_indonesian"),
    ("Gulai Udang", 260, 18, 12, 18, 4, 520, 2, "local_indonesian"),
    ("Gulai Sapi", 320, 24, 18, 14, 4, 520, 2, "local_indonesian"),
    ("Gulai Limpa", 250, 20, 14, 10, 3, 480, 2, "local_indonesian"),
    ("Gulai Hati Sapi", 240, 22, 12, 10, 3, 450, 2, "local_indonesian"),
    ("Gulai Otak Sapi", 280, 14, 18, 10, 2, 400, 0, "local_indonesian"),
    ("Gulai Paru Sapi", 220, 18, 12, 8, 2, 420, 1, "local_indonesian"),
    ("Sup Labu Kuning", 120, 4, 3, 20, 6, 350, 4, "other"),
    ("Sup Bawang Bombay", 100, 3, 3, 16, 5, 300, 3, "other"),
    ("Sup Tomat Segar", 80, 3, 2, 14, 6, 350, 3, "other"),
]
for item in soup_ext:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 32. EGG DISHES
# ================================================================
egg_dishes = [
    ("Telur Balado", 180, 10, 12, 8, 4, 400, 1, "local_indonesian"),
    ("Telur Ceplok", 150, 8, 10, 4, 2, 200, 0, "base_food"),
    ("Telur Dadar", 180, 10, 12, 6, 2, 250, 0, "base_food"),
    ("Telur Dadar Padang", 250, 14, 16, 10, 3, 400, 1, "local_indonesian"),
    ("Telur Mata Sapi", 140, 8, 9, 3, 2, 180, 0, "base_food"),
    ("Telur Orak-arik", 160, 10, 10, 5, 3, 220, 1, "base_food"),
    ("Telur Rebus", 70, 6, 5, 1, 1, 60, 0, "base_food"),
    ("Telur Sambal", 180, 10, 12, 8, 4, 400, 1, "local_indonesian"),
    ("Telur Bumbu Bali", 190, 10, 12, 10, 5, 420, 1, "local_indonesian"),
    ("Telur Kecap", 170, 10, 10, 9, 5, 450, 1, "local_indonesian"),
    ("Telur Puyuh Balado", 160, 9, 10, 7, 4, 380, 1, "local_indonesian"),
    ("Telur Puyuh Kecap", 150, 9, 8, 8, 5, 420, 1, "local_indonesian"),
    ("Telur Asin", 150, 10, 10, 2, 1, 500, 0, "base_food"),
    ("Telur Asin Pedas", 180, 11, 12, 6, 3, 550, 1, "other"),
    ("Telur Gulai", 200, 10, 14, 10, 4, 450, 1, "local_indonesian"),
    ("Telur Petis", 170, 10, 10, 10, 5, 500, 1, "local_indonesian"),
    ("Telur Rendang", 220, 12, 14, 12, 5, 480, 1, "local_indonesian"),
    ("Telur Sambal Goreng", 180, 10, 12, 8, 4, 400, 2, "local_indonesian"),
    ("Frittata Sayuran", 200, 12, 12, 10, 3, 350, 2, "other"),
    ("Omelet Keju", 220, 14, 16, 4, 2, 300, 0, "other"),
    ("Omelet Jamur", 180, 12, 12, 6, 3, 280, 1, "other"),
    ("Omelet Sayuran", 170, 10, 10, 8, 4, 300, 2, "other"),
    ("Omelet Daging", 240, 18, 14, 6, 2, 350, 1, "other"),
    ("Omelet Kentang", 220, 10, 12, 18, 3, 320, 2, "other"),
    ("Telur Kukus Jepang", 130, 8, 6, 10, 3, 450, 1, "other"),
    ("Telur Bumbu Opor", 190, 10, 12, 10, 4, 430, 1, "local_indonesian"),
    ("Telur Kuah Santan", 200, 10, 14, 10, 4, 420, 1, "local_indonesian"),
    ("Martabak Telur", 320, 14, 16, 26, 4, 500, 2, "snack"),
    ("Telur Masak Semur", 180, 10, 10, 10, 6, 480, 1, "local_indonesian"),
    ("Telur Bacem", 160, 9, 8, 12, 6, 400, 1, "local_indonesian"),
]
for item in egg_dishes:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 33. FRUIT-BASED DISHES & SALADS
# ================================================================
fruit_dishes = [
    ("Salad Buah Segar", 150, 3, 4, 26, 18, 50, 4, "other"),
    ("Salad Buah Yogurt", 180, 5, 5, 28, 20, 60, 4, "other"),
    ("Salad Buah Mayo", 220, 4, 10, 28, 20, 70, 4, "other"),
    ("Rujak Buah", 120, 2, 2, 24, 16, 100, 4, "local_indonesian"),
    ("Rujak Cingur", 250, 10, 10, 28, 8, 450, 4, "local_indonesian"),
    ("Rujak Kuah Pindang", 180, 8, 4, 26, 10, 400, 4, "local_indonesian"),
    ("Rujak Manis", 140, 2, 2, 28, 18, 80, 3, "local_indonesian"),
    ("Rujak Serut", 130, 2, 2, 26, 16, 90, 4, "local_indonesian"),
    ("Rujak Shanghai", 150, 3, 3, 28, 14, 100, 3, "snack"),
    ("Rujak Soto", 300, 12, 10, 36, 8, 550, 4, "local_indonesian"),
    ("Asinan Betawi", 100, 2, 2, 18, 8, 400, 4, "local_indonesian"),
    ("Asinan Bogor", 110, 3, 2, 20, 8, 420, 4, "local_indonesian"),
    ("Asinan Buah", 120, 2, 2, 24, 14, 300, 4, "local_indonesian"),
    ("Asinan Sayur", 80, 2, 2, 14, 6, 450, 5, "local_indonesian"),
    ("Manisan Mangga", 120, 1, 0, 28, 24, 50, 2, "snack"),
    ("Manisan Kedondong", 100, 1, 0, 24, 20, 50, 2, "snack"),
    ("Manisan Salak", 110, 1, 0, 26, 22, 40, 2, "snack"),
    ("Manisan Kolang Kaling", 80, 0, 0, 20, 16, 30, 3, "snack"),
    ("Pisang Goreng Crispy", 250, 3, 12, 32, 10, 150, 2, "snack"),
    ("Pisang Bakar Coklat", 220, 4, 7, 36, 16, 80, 3, "snack"),
    ("Pisang Bakar Keju", 240, 5, 9, 34, 14, 120, 2, "snack"),
    ("Pisang Molen", 220, 4, 10, 28, 8, 120, 2, "snack"),
    ("Pisang Aroma", 200, 3, 8, 28, 10, 100, 2, "snack"),
    ("Pisang Rai", 180, 3, 6, 28, 10, 80, 3, "snack"),
    ("Pisang Siam", 200, 3, 7, 30, 12, 90, 3, "snack"),
    ("Kolak Pisang", 220, 3, 8, 32, 16, 80, 3, "other"),
    ("Kolak Labu", 180, 2, 6, 28, 14, 60, 3, "other"),
    ("Kolak Ubi", 200, 2, 6, 32, 14, 70, 3, "other"),
    ("Kolak Singkong", 200, 2, 6, 32, 14, 70, 3, "other"),
    ("Kolak Nangka", 180, 2, 5, 30, 16, 60, 3, "other"),
    ("Setup Nanas", 100, 1, 0, 22, 18, 20, 3, "other"),
    ("Setup Pepaya", 90, 1, 0, 20, 16, 20, 3, "other"),
]
for item in fruit_dishes:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 34. MORE RICE VARIANTS
# ================================================================
rice_ext = [
    ("Nasi Bakar Ayam", 350, 14, 10, 46, 3, 400, 3, "local_indonesian"),
    ("Nasi Bakar Teri", 320, 12, 8, 46, 3, 480, 3, "local_indonesian"),
    ("Nasi Bakar Peda", 330, 14, 10, 44, 3, 500, 3, "local_indonesian"),
    ("Nasi Bakar Jamur", 300, 8, 8, 46, 3, 380, 4, "local_indonesian"),
    ("Nasi Bakar Tuna", 340, 16, 10, 44, 3, 450, 3, "local_indonesian"),
    ("Nasi Bakar Udang", 340, 14, 10, 44, 3, 450, 3, "local_indonesian"),
    ("Nasi Bakar Daging", 360, 18, 12, 42, 3, 420, 3, "local_indonesian"),
    ("Nasi Tim Ayam", 300, 16, 8, 38, 3, 400, 2, "local_indonesian"),
    ("Nasi Tim Ayam Jamur", 320, 18, 9, 38, 3, 420, 2, "local_indonesian"),
    ("Nasi Tim Telur", 280, 12, 8, 36, 3, 380, 1, "local_indonesian"),
    ("Nasi Tim Daging", 330, 18, 10, 36, 3, 420, 2, "local_indonesian"),
    ("Nasi Hainan", 320, 16, 8, 42, 3, 380, 2, "other"),
    ("Nasi Briyani", 450, 20, 14, 54, 5, 550, 3, "other"),
    ("Nasi Arab", 420, 18, 12, 52, 4, 500, 3, "other"),
    ("Nasi Kapau", 400, 16, 10, 54, 4, 480, 3, "local_indonesian"),
    ("Nasi Rames", 420, 18, 12, 52, 5, 550, 4, "local_indonesian"),
    ("Nasi Campur Bali", 450, 20, 14, 52, 5, 550, 4, "local_indonesian"),
    ("Nasi Campur Manado", 460, 22, 16, 48, 5, 580, 5, "local_indonesian"),
    ("Nasi Campur Surabaya", 430, 20, 14, 50, 5, 550, 4, "local_indonesian"),
    ("Nasi Campur Medan", 440, 20, 14, 50, 5, 560, 4, "local_indonesian"),
    ("Nasi Lengko", 320, 10, 8, 48, 4, 400, 5, "local_indonesian"),
    ("Nasi Timbel", 320, 10, 6, 50, 3, 350, 4, "local_indonesian"),
    ("Nasi Tumpeng Mini", 400, 14, 10, 54, 5, 450, 4, "local_indonesian"),
    ("Nasi Jamblang", 350, 10, 8, 52, 4, 420, 4, "local_indonesian"),
    ("Nasi Tiwul", 280, 4, 2, 58, 3, 200, 6, "local_indonesian"),
    ("Nasi Jagung", 250, 5, 3, 48, 3, 250, 5, "local_indonesian"),
    ("Nasi Sela", 300, 5, 2, 60, 4, 200, 5, "local_indonesian"),
]
for item in rice_ext:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 35. MORE NOODLE / PASTA (ASIAN + WESTERN)
# ================================================================
noodle_ext = [
    ("Mie Kocok Bandung", 350, 14, 10, 44, 5, 580, 3, "local_indonesian"),
    ("Mie Kangkung", 320, 10, 8, 46, 5, 550, 4, "local_indonesian"),
    ("Mie Tek Tek", 380, 12, 10, 52, 6, 580, 3, "local_indonesian"),
    ("Mie Gacoan", 380, 12, 10, 50, 6, 600, 3, "local_indonesian"),
    ("Mie Ayam Bakso", 420, 16, 12, 52, 5, 650, 3, "local_indonesian"),
    ("Mie Ayam Ceker", 400, 18, 12, 48, 5, 620, 3, "local_indonesian"),
    ("Mie Ayam Pangsit", 420, 16, 12, 52, 5, 600, 3, "local_indonesian"),
    ("Mie Ayam Jamur", 380, 14, 10, 50, 5, 580, 4, "local_indonesian"),
    ("Mie Ayam Komplit", 450, 18, 14, 52, 5, 680, 3, "local_indonesian"),
    ("Mie Titi Makassar", 400, 14, 12, 50, 5, 580, 3, "local_indonesian"),
    ("Mie Pangsit Kuah", 350, 12, 10, 48, 4, 600, 2, "other"),
    ("Mie Kuah Daging", 380, 16, 10, 48, 5, 580, 3, "other"),
    ("Mie Kuah Seafood", 360, 14, 8, 50, 5, 620, 3, "other"),
    ("Mie Goreng Seafood", 420, 14, 14, 52, 5, 650, 3, "other"),
    ("Mie Goreng Spesial", 450, 16, 16, 52, 5, 680, 3, "other"),
    ("Bihun Goreng Spesial", 380, 10, 12, 52, 5, 580, 3, "other"),
    ("Bihun Kuah Spesial", 320, 10, 6, 50, 5, 600, 3, "other"),
    ("Kwetiau Goreng Spesial", 420, 12, 14, 54, 5, 620, 3, "other"),
    ("Kwetiau Kuah Spesial", 360, 12, 8, 52, 5, 600, 3, "other"),
    ("Soun Goreng", 320, 5, 8, 54, 4, 500, 3, "other"),
    ("Soun Kuah", 260, 5, 4, 48, 4, 550, 3, "other"),
    ("Makaroni Schotel", 350, 14, 16, 36, 5, 450, 2, "other"),
    ("Lasagna Daging", 420, 22, 18, 38, 5, 550, 3, "other"),
    ("Lasagna Ayam Bayam", 380, 20, 16, 36, 5, 520, 3, "other"),
    ("Lasagna Sayuran", 320, 14, 14, 34, 5, 480, 4, "other"),
    ("Ravioli Daging Saus Tomat", 350, 18, 14, 36, 5, 500, 3, "other"),
    ("Ravioli Bayam Ricotta", 320, 14, 12, 36, 5, 450, 3, "other"),
    ("Fettuccine Carbonara", 450, 18, 22, 44, 3, 550, 2, "other"),
    ("Fettuccine Salmon", 420, 22, 16, 42, 3, 480, 2, "other"),
    ("Penne Arrabiata Pedas", 320, 10, 8, 46, 5, 450, 3, "other"),
    ("Fusilli Salad Italia", 280, 10, 10, 36, 4, 350, 3, "other"),
    ("Spageti Aglio Olio Udang", 380, 16, 14, 44, 3, 450, 2, "other"),
    ("Spageti Pesto Ayam", 420, 22, 16, 42, 3, 480, 2, "other"),
    ("Spageti Meatball", 400, 20, 14, 44, 5, 550, 3, "other"),
    ("Makaroni Keju Panggang", 320, 12, 14, 34, 4, 400, 2, "other"),
]
for item in noodle_ext:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 36. MORE DESSERTS & SWEETS
# ================================================================
desserts = [
    ("Es Campur", 200, 3, 4, 36, 22, 60, 3, "other"),
    ("Es Teler", 220, 3, 6, 38, 24, 70, 3, "other"),
    ("Es Doger", 200, 3, 6, 32, 20, 60, 2, "other"),
    ("Es Kacang Merah", 180, 5, 3, 32, 18, 50, 5, "other"),
    ("Es Kacang Hijau", 200, 6, 4, 34, 16, 50, 4, "other"),
    ("Es Pisang Ijo", 250, 4, 6, 42, 22, 80, 3, "other"),
    ("Es Palu Butung", 220, 3, 5, 38, 20, 60, 3, "other"),
    ("Es Puter", 180, 3, 5, 28, 18, 50, 1, "snack"),
    ("Es Lilin", 120, 1, 1, 24, 20, 20, 0, "snack"),
    ("Es Mambo", 100, 1, 0, 22, 20, 20, 0, "snack"),
    ("Es Gabus", 110, 2, 2, 20, 16, 30, 1, "snack"),
    ("Es Krim Santan", 200, 3, 10, 24, 16, 50, 1, "snack"),
    ("Kue Lapis", 180, 3, 8, 24, 14, 100, 2, "snack"),
    ("Kue Cucur", 200, 3, 8, 28, 14, 80, 2, "snack"),
    ("Kue Talam", 180, 4, 7, 24, 12, 90, 2, "snack"),
    ("Kue Mangkok", 160, 3, 5, 24, 12, 80, 2, "snack"),
    ("Kue Bugis", 200, 4, 8, 26, 12, 80, 2, "snack"),
    ("Kue Lemper", 220, 6, 8, 28, 5, 150, 2, "snack"),
    ("Kue Semar Mendem", 200, 5, 7, 28, 5, 140, 2, "snack"),
    ("Kue Lontar", 180, 4, 7, 24, 10, 100, 2, "snack"),
    ("Kue Pukis", 190, 5, 7, 26, 12, 120, 1, "snack"),
    ("Kue Cubit", 180, 5, 6, 26, 12, 100, 1, "snack"),
    ("Kue Putu", 180, 4, 6, 26, 12, 80, 2, "snack"),
    ("Kue Lumpur", 200, 4, 8, 26, 12, 100, 1, "snack"),
    ("Kue Lumpur Surga", 220, 5, 10, 26, 14, 100, 1, "snack"),
    ("Klepon", 160, 3, 5, 26, 12, 60, 3, "snack"),
    ("Onde-onde", 200, 4, 8, 26, 10, 80, 2, "snack"),
    ("Dadar Gulung", 180, 4, 7, 24, 12, 70, 2, "snack"),
    ("Kue Nagasari", 170, 3, 6, 26, 12, 60, 2, "snack"),
    ("Lupis", 200, 3, 7, 30, 10, 50, 3, "snack"),
    ("Bubur Sumsum", 180, 4, 8, 22, 10, 60, 1, "other"),
    ("Bubur Candil", 200, 3, 5, 34, 18, 50, 3, "other"),
    ("Bubur Pulut Hitam", 220, 5, 6, 36, 14, 50, 4, "other"),
    ("Bubur Mutiara", 180, 2, 4, 32, 18, 40, 2, "other"),
    ("Lemper Ayam", 250, 8, 9, 30, 5, 180, 2, "snack"),
    ("Lemper Daging", 260, 10, 10, 28, 4, 200, 2, "snack"),
    ("Pastel Basah", 200, 6, 9, 22, 4, 250, 2, "snack"),
    ("Pastel Kering", 220, 7, 12, 20, 3, 280, 1, "snack"),
    ("Bolu Tape", 200, 4, 7, 28, 14, 120, 2, "snack"),
    ("Bolu Gula Merah", 210, 4, 8, 28, 16, 100, 1, "snack"),
    ("Brownies Kukus", 280, 5, 12, 36, 20, 150, 2, "snack"),
    ("Brownies Panggang", 300, 6, 14, 34, 18, 160, 2, "snack"),
    ("Puding Coklat", 180, 5, 8, 22, 16, 100, 1, "snack"),
    ("Puding Buah", 150, 4, 6, 20, 14, 80, 2, "snack"),
    ("Puding Santan", 180, 4, 8, 22, 14, 80, 1, "snack"),
    ("Puding Roti", 220, 6, 8, 28, 16, 150, 2, "snack"),
    ("Setup Roti", 200, 5, 7, 28, 14, 130, 2, "snack"),
]
for item in desserts:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 37. MORE BEVERAGES
# ================================================================
bevs_ext = [
    ("Es Teh Manis", 70, 0, 0, 16, 16, 10, 0, "beverage"),
    ("Es Teh Tawar", 5, 0, 0, 1, 0, 5, 0, "beverage"),
    ("Teh Tarik", 120, 3, 4, 16, 12, 40, 0, "beverage"),
    ("Teh Susu", 100, 3, 4, 12, 10, 40, 0, "beverage"),
    ("Teh Lemon Madu", 80, 0, 0, 18, 16, 10, 0, "beverage"),
    ("Teh Jahe", 40, 0, 0, 8, 6, 10, 0, "beverage"),
    ("Teh Sereh", 30, 0, 0, 6, 4, 5, 0, "beverage"),
    ("Teh Rosella", 40, 0, 0, 8, 6, 10, 0, "beverage"),
    ("Teh Herbal", 20, 0, 0, 4, 2, 5, 0, "beverage"),
    ("Wedang Jahe", 60, 0, 0, 12, 10, 10, 0, "beverage"),
    ("Wedang Ronde", 150, 3, 4, 24, 14, 30, 2, "beverage"),
    ("Wedang Uwuh", 40, 0, 0, 8, 6, 10, 0, "beverage"),
    ("Wedang Secang", 40, 0, 0, 8, 6, 10, 0, "beverage"),
    ("Sekoteng", 150, 4, 4, 24, 14, 30, 2, "beverage"),
    ("Bandrek", 70, 1, 2, 10, 8, 10, 0, "beverage"),
    ("Bajigur", 90, 2, 3, 14, 10, 20, 1, "beverage"),
    ("Cendol", 180, 3, 6, 28, 18, 50, 2, "beverage"),
    ("Es Cincau", 100, 1, 2, 20, 16, 30, 2, "beverage"),
    ("Es Dawet", 160, 3, 5, 24, 18, 40, 1, "beverage"),
    ("Es Kelapa Muda", 120, 1, 1, 24, 18, 60, 3, "beverage"),
    ("Es Kelapa Kopyor", 150, 2, 3, 26, 18, 50, 3, "beverage"),
    ("Jus Alpukat", 180, 3, 10, 22, 8, 10, 5, "beverage"),
    ("Jus Apel", 110, 1, 0, 24, 20, 10, 2, "beverage"),
    ("Jus Belimbing", 80, 1, 0, 18, 14, 10, 3, "beverage"),
    ("Jus Jambu", 100, 1, 0, 22, 18, 10, 4, "beverage"),
    ("Jus Mangga", 130, 1, 0, 28, 24, 10, 2, "beverage"),
    ("Jus Nanas", 100, 1, 0, 22, 18, 10, 2, "beverage"),
    ("Jus Pepaya", 90, 1, 0, 20, 16, 10, 3, "beverage"),
    ("Jus Sirsak", 100, 1, 0, 22, 18, 10, 2, "beverage"),
    ("Jus Stroberi", 80, 1, 0, 18, 14, 10, 3, "beverage"),
    ("Jus Semangka", 70, 1, 0, 16, 12, 5, 2, "beverage"),
    ("Jus Melon", 80, 1, 0, 18, 14, 10, 2, "beverage"),
    ("Jus Tomat", 60, 2, 0, 12, 8, 20, 3, "beverage"),
    ("Jus Wortel", 70, 2, 0, 14, 10, 30, 4, "beverage"),
    ("Smoothie Pisang", 180, 4, 3, 32, 18, 40, 4, "beverage"),
    ("Smoothie Stroberi", 150, 3, 3, 26, 16, 30, 3, "beverage"),
    ("Smoothie Mangga", 170, 3, 3, 30, 22, 30, 3, "beverage"),
    ("Smoothie Hijau", 120, 3, 2, 22, 12, 40, 5, "beverage"),
    ("Es Kopi Susu", 130, 3, 5, 16, 12, 40, 0, "beverage"),
    ("Kopi Moka Latte", 150, 4, 6, 18, 14, 50, 0, "beverage"),
    ("Kopi Karamel Latte", 160, 4, 6, 20, 16, 50, 0, "beverage"),
    ("Kopi Vanilla Latte", 150, 4, 6, 18, 14, 45, 0, "beverage"),
    ("Matcha Latte", 140, 4, 5, 18, 14, 40, 0, "beverage"),
    ("Red Velvet Latte", 160, 4, 6, 22, 18, 45, 0, "beverage"),
    ("Taro Latte", 150, 3, 5, 22, 16, 40, 1, "beverage"),
    ("Susu Kedelai", 100, 8, 4, 8, 4, 30, 2, "beverage"),
    ("Susu Almond", 80, 2, 3, 8, 4, 30, 1, "beverage"),
    ("Susu Oat", 90, 2, 3, 12, 6, 30, 2, "beverage"),
]
for item in bevs_ext:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 38. PROTEIN BOWL / HEALTHY / DIET
# ================================================================
healthy_bowls = [
    ("Salad Ayam Panggang", 280, 28, 10, 18, 5, 350, 5, "other"),
    ("Salad Tuna", 240, 22, 8, 16, 4, 380, 5, "other"),
    ("Salad Telur", 220, 14, 12, 12, 4, 300, 4, "other"),
    ("Salad Alpukat", 260, 5, 18, 20, 4, 200, 8, "other"),
    ("Salad Greek", 200, 10, 14, 10, 5, 400, 4, "other"),
    ("Salad Caesar Ayam", 300, 24, 14, 16, 4, 450, 4, "other"),
    ("Salad Nicoise", 280, 18, 12, 20, 4, 450, 5, "other"),
    ("Salad Bayam Alpukat", 220, 6, 16, 14, 4, 250, 7, "other"),
    ("Salad Quinoa", 250, 8, 8, 32, 5, 200, 6, "other"),
    ("Bowl Ayam Teriyaki", 450, 30, 10, 52, 8, 600, 4, "other"),
    ("Bowl Salmon Panggang", 420, 28, 14, 38, 4, 450, 5, "other"),
    ("Bowl Daging Rendang", 480, 30, 16, 42, 5, 550, 4, "other"),
    ("Bowl Tuna Mentah", 380, 26, 10, 40, 5, 480, 5, "other"),
    ("Bowl Tempe Pedas", 350, 18, 14, 36, 5, 400, 8, "other"),
    ("Bowl Tahu Tumis", 300, 16, 12, 32, 5, 420, 6, "other"),
    ("Bowl Sayuran Kukus", 200, 8, 4, 32, 6, 300, 8, "other"),
    ("Wrap Ayam Caesar", 320, 22, 10, 32, 4, 500, 4, "other"),
    ("Wrap Tuna Mayo", 300, 18, 12, 28, 3, 480, 3, "other"),
    ("Wrap Falafel", 280, 10, 10, 34, 4, 450, 6, "other"),
    ("Wrap Daging Bulgogi", 360, 26, 12, 32, 6, 550, 4, "other"),
    ("Toast Alpukat Telur", 320, 14, 14, 30, 4, 350, 5, "other"),
    ("Toast Tuna Leleh", 300, 18, 10, 30, 3, 420, 3, "other"),
    ("Toast Ayam Mayo", 310, 20, 10, 30, 4, 450, 3, "other"),
    ("Toast Jamur Keju", 260, 10, 10, 28, 3, 380, 3, "other"),
    ("Granola Bowl", 280, 8, 10, 38, 14, 80, 6, "other"),
    ("Acai Bowl", 250, 5, 8, 40, 20, 50, 8, "other"),
    ("Smoothie Bowl", 280, 8, 8, 42, 22, 60, 6, "other"),
    ("Oatmeal Bowl", 220, 8, 6, 32, 6, 50, 6, "other"),
    ("Chia Pudding", 180, 6, 8, 20, 6, 40, 8, "other"),
    ("Greek Yogurt Parfait", 200, 12, 6, 22, 14, 60, 2, "other"),
    ("Sup Krim Jamur", 180, 5, 10, 16, 4, 400, 3, "other"),
    ("Sup Krim Ayam", 220, 12, 12, 16, 3, 450, 2, "other"),
    ("Sup Krim Brokoli", 160, 6, 8, 16, 4, 420, 4, "other"),
    ("Sup Krim Kentang", 200, 5, 8, 26, 4, 380, 3, "other"),
    ("Sup Krim Bayam", 140, 6, 7, 14, 3, 400, 4, "other"),
    ("Sup Lentil", 200, 10, 4, 28, 4, 380, 8, "other"),
    ("Sup Kacang Merah", 220, 10, 4, 32, 5, 400, 8, "other"),
    ("Sup Kacang Hijau", 180, 8, 3, 28, 4, 350, 7, "other"),
    ("Sup Asparagus", 120, 5, 4, 16, 4, 350, 4, "other"),
]
for item in healthy_bowls:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 39. MORE SNACKS / STREET FOOD
# ================================================================
snacks_ext = [
    ("Sate Usus", 150, 8, 8, 10, 3, 350, 1, "snack"),
    ("Sate Kulit Ayam", 200, 6, 14, 8, 2, 300, 0, "snack"),
    ("Sate Ampela", 160, 14, 6, 8, 2, 280, 1, "snack"),
    ("Sate Hati Ayam", 170, 16, 6, 8, 2, 300, 0, "snack"),
    ("Sate Ati Ampela", 165, 15, 6, 8, 2, 290, 0, "snack"),
    ("Sate Kerang", 140, 12, 4, 12, 3, 350, 1, "snack"),
    ("Sate Torpedo", 180, 10, 10, 10, 3, 320, 1, "snack"),
    ("Sosis Bakar", 280, 10, 18, 18, 4, 500, 1, "snack"),
    ("Sosis Goreng", 300, 10, 20, 18, 4, 520, 1, "snack"),
    ("Sempol Ayam", 200, 8, 10, 18, 3, 400, 2, "snack"),
    ("Cilok", 180, 5, 5, 28, 4, 400, 2, "snack"),
    ("Cireng", 200, 3, 6, 32, 4, 350, 2, "snack"),
    ("Cimol", 180, 4, 6, 26, 4, 380, 2, "snack"),
    ("Combro", 200, 4, 7, 28, 4, 350, 3, "snack"),
    ("Misro", 180, 3, 6, 28, 12, 200, 3, "snack"),
    ("Tahu Walik", 180, 8, 8, 18, 3, 350, 2, "snack"),
    ("Tahu Isi", 200, 8, 9, 20, 4, 400, 3, "snack"),
    ("Tahu Gejrot", 150, 6, 6, 16, 5, 450, 3, "snack"),
    ("Tahu Bulat", 180, 8, 8, 18, 2, 350, 1, "snack"),
    ("Tahu Mercon", 200, 8, 9, 20, 4, 420, 2, "snack"),
    ("Tahu Lada Garam", 190, 8, 9, 18, 2, 380, 2, "snack"),
    ("Tempe Mendoan", 180, 8, 9, 16, 3, 300, 3, "snack"),
    ("Tempe Kemul", 200, 8, 10, 18, 3, 320, 3, "snack"),
    ("Pisang Coklat", 250, 4, 10, 34, 14, 100, 3, "snack"),
    ("Batagor", 250, 10, 10, 28, 4, 500, 3, "snack"),
    ("Siomay", 220, 10, 8, 26, 4, 480, 2, "snack"),
    ("Pempek Panggang", 220, 10, 6, 28, 3, 450, 2, "snack"),
    ("Otak-otak Bakar", 180, 10, 6, 20, 3, 400, 2, "snack"),
    ("Kentang Goreng", 300, 4, 14, 38, 2, 250, 3, "snack"),
    ("Ubi Goreng", 250, 2, 8, 40, 8, 100, 4, "snack"),
    ("Singkong Goreng", 250, 2, 8, 40, 4, 150, 3, "snack"),
    ("Sukun Goreng", 200, 3, 6, 32, 4, 120, 4, "snack"),
    ("Bakwan Sayur", 180, 4, 8, 22, 4, 350, 3, "snack"),
    ("Bakwan Jagung", 200, 5, 9, 24, 4, 320, 3, "snack"),
    ("Perkedel Jagung", 200, 5, 9, 24, 4, 320, 3, "snack"),
    ("Tahu Petis", 180, 8, 7, 20, 4, 450, 3, "snack"),
    ("Tahu Campur", 250, 12, 10, 24, 5, 480, 4, "snack"),
    ("Lumpia Goreng", 180, 6, 8, 20, 4, 300, 3, "snack"),
    ("Lumpia Basah", 160, 6, 6, 20, 4, 350, 3, "snack"),
    ("Lumpia Semarang", 200, 8, 8, 22, 5, 380, 3, "snack"),
    ("Risoles", 180, 5, 8, 22, 4, 280, 2, "snack"),
    ("Tahu Bakso", 200, 10, 9, 18, 3, 420, 2, "snack"),
    ("Dimsum Ayam", 200, 10, 8, 20, 3, 400, 2, "snack"),
    ("Dimsum Udang", 180, 10, 6, 20, 3, 420, 2, "snack"),
    ("Hakau Udang", 160, 8, 5, 20, 3, 380, 2, "snack"),
    ("Siomay Goreng", 220, 10, 10, 24, 4, 450, 2, "snack"),
    ("Molen Pisang Coklat", 250, 4, 10, 34, 14, 120, 2, "snack"),
    ("Kroket Kentang", 220, 6, 10, 26, 4, 350, 2, "snack"),
    ("Kroket Daging", 250, 10, 12, 24, 4, 380, 2, "snack"),
    ("Bola Bola Daging", 250, 12, 12, 22, 3, 400, 2, "snack"),
    ("Bola Bola Kentang", 220, 5, 10, 26, 3, 350, 2, "snack"),
]
for item in snacks_ext:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 40. MORE INTERNATIONAL / FUSION
# ================================================================
international_ext = [
    ("Nasi Lemak Malaysia", 420, 14, 16, 48, 5, 500, 3, "other"),
    ("Nasi Kandar", 480, 22, 18, 50, 5, 580, 3, "other"),
    ("Char Kway Teow", 400, 12, 14, 50, 6, 600, 3, "other"),
    ("Hokkien Mee", 420, 16, 10, 56, 6, 650, 3, "other"),
    ("Laksa Singapura", 380, 14, 16, 42, 5, 600, 3, "other"),
    ("Ayam Rendang Malaysia", 380, 26, 16, 22, 5, 520, 2, "other"),
    ("Nasi Briyani Malaysia", 460, 22, 14, 54, 5, 550, 3, "other"),
    ("Roti Canai Malaysia", 310, 8, 10, 40, 3, 360, 2, "other"),
    ("Murtabak Malaysia", 400, 16, 18, 38, 5, 550, 3, "other"),
    ("Pho Vietnam", 320, 16, 6, 44, 4, 650, 3, "other"),
    ("Bun Cha Vietnam", 350, 22, 10, 36, 6, 550, 3, "other"),
    ("Banh Mi Vietnam", 320, 14, 8, 42, 5, 500, 3, "other"),
    ("Goi Cuon Vietnam", 150, 10, 3, 20, 3, 350, 3, "other"),
    ("Cha Gio Vietnam", 220, 8, 10, 24, 4, 380, 2, "other"),
    ("Com Tam Vietnam", 380, 18, 8, 52, 4, 480, 3, "other"),
    ("Bun Bo Hue", 350, 20, 8, 42, 4, 650, 3, "other"),
    ("Khao Pad Thailand", 380, 14, 10, 52, 5, 550, 2, "other"),
    ("Khao Soi Thailand", 420, 18, 18, 42, 6, 650, 3, "other"),
    ("Pad Krapow Thailand", 380, 24, 14, 34, 5, 650, 2, "other"),
    ("Gado-Gado Betawi", 280, 10, 12, 30, 8, 450, 6, "local_indonesian"),
    ("Pecel Madiun", 300, 10, 10, 36, 6, 400, 6, "local_indonesian"),
    ("Pecel Solo", 300, 10, 10, 36, 6, 400, 6, "local_indonesian"),
    ("Pecel Kediri", 300, 10, 10, 36, 6, 400, 6, "local_indonesian"),
    ("Pecel Tulungagung", 300, 10, 10, 36, 6, 400, 6, "local_indonesian"),
    ("Karedok", 200, 8, 10, 20, 5, 350, 6, "local_indonesian"),
    ("Lotis", 150, 4, 4, 24, 12, 100, 5, "snack"),
    ("Trancam", 120, 4, 6, 14, 4, 300, 5, "local_indonesian"),
    ("Urap", 180, 6, 8, 20, 5, 350, 5, "local_indonesian"),
    ("Lalapan Ayam", 350, 24, 14, 24, 4, 400, 5, "local_indonesian"),
    ("Lalapan Bebek", 400, 26, 18, 22, 4, 450, 4, "local_indonesian"),
    ("Lalapan Lele", 320, 20, 12, 26, 4, 420, 5, "local_indonesian"),
    ("Lalapan Ikan Nila", 300, 22, 10, 24, 4, 400, 4, "local_indonesian"),
    ("Lalapan Ayam Kampung", 330, 26, 12, 24, 4, 380, 4, "local_indonesian"),
    ("Lalapan Tempe", 280, 12, 12, 28, 5, 380, 7, "local_indonesian"),
    ("Ayam Panggang Madu", 320, 26, 12, 22, 8, 400, 1, "other"),
    ("Ayam Panggang Kecap", 300, 26, 10, 20, 6, 500, 1, "other"),
    ("Ayam Panggang Bumbu", 310, 26, 12, 18, 5, 480, 2, "other"),
    ("Ayam Panggang Santan", 330, 26, 14, 18, 4, 450, 2, "other"),
    ("Ayam Panggang Lada Hitam", 320, 28, 12, 18, 4, 420, 1, "other"),
    ("Bebek Panggang Madu", 380, 28, 18, 20, 6, 420, 1, "other"),
    ("Ikan Bakar Jimbaran", 250, 22, 8, 18, 4, 420, 1, "local_indonesian"),
    ("Udang Jimbaran", 220, 18, 8, 18, 4, 450, 1, "local_indonesian"),
    ("Cumi Jimbaran", 200, 16, 6, 18, 4, 420, 1, "local_indonesian"),
    ("Kerang Jimbaran", 180, 14, 5, 20, 4, 480, 1, "local_indonesian"),
    ("Sate Plecing", 220, 18, 8, 16, 4, 420, 2, "local_indonesian"),
    ("Plecing Kangkung", 120, 5, 5, 14, 4, 350, 4, "local_indonesian"),
    ("Sambal Plecing", 60, 3, 4, 6, 3, 300, 2, "local_indonesian"),
    ("Bebek Betutu", 400, 30, 20, 18, 4, 500, 2, "local_indonesian"),
    ("Ayam Betutu", 380, 30, 18, 16, 4, 480, 2, "local_indonesian"),
    ("Babi Guling", 450, 28, 28, 16, 3, 450, 1, "local_indonesian"),
    ("Ayam Taliwang", 350, 28, 16, 16, 4, 500, 2, "local_indonesian"),
    ("Ikan Bakar Taliwang", 250, 22, 9, 16, 4, 480, 1, "local_indonesian"),
    ("Sate Bulayak", 280, 20, 10, 20, 4, 450, 2, "local_indonesian"),
    ("Ayam Bubur Bali", 350, 22, 12, 32, 5, 480, 3, "local_indonesian"),
]
for item in international_ext:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 41. MORE VARIETY: PROTEIN × METHODS (target ~300)
# ================================================================
protein_flat = [
    ("Daging Sapi Lada Hitam", 350, 28, 16, 18, 4, 420, 1, "other"),
    ("Daging Sapi Saus Tiram", 340, 28, 14, 20, 5, 500, 2, "other"),
    ("Daging Sapi Cabe Hijau", 330, 26, 16, 18, 4, 450, 2, "local_indonesian"),
    ("Daging Sapi Saus Inggris", 320, 28, 14, 16, 4, 480, 1, "other"),
    ("Daging Sapi Teriyaki", 330, 28, 12, 20, 8, 550, 1, "other"),
    ("Daging Sapi Saus Bulgogi", 340, 28, 14, 22, 6, 500, 1, "other"),
    ("Ayam Fillet Saus Lemon", 280, 26, 10, 18, 5, 350, 1, "other"),
    ("Ayam Fillet Saus Jamur", 300, 26, 12, 20, 4, 420, 2, "other"),
    ("Ayam Fillet Saus Teriyaki", 310, 26, 10, 22, 8, 520, 1, "other"),
    ("Ayam Fillet Panggang", 260, 28, 8, 14, 3, 300, 0, "base_food"),
    ("Ayam Goreng Saus Padang", 350, 26, 18, 18, 4, 500, 2, "local_indonesian"),
    ("Ayam Saus Asam Manis", 320, 24, 14, 22, 8, 450, 2, "other"),
    ("Ayam Goreng Mentega", 340, 24, 18, 18, 5, 400, 1, "other"),
    ("Ayam Goreng Saus Inggris", 330, 24, 16, 18, 5, 450, 1, "other"),
    ("Ikan Dori Asam Manis", 280, 18, 10, 26, 8, 420, 2, "other"),
    ("Ikan Dori Saus Padang", 300, 18, 12, 24, 5, 480, 2, "other"),
    ("Ikan Dori Goreng Tepung", 320, 16, 14, 28, 3, 350, 1, "other"),
    ("Ikan Dori Saus Lemon", 280, 18, 10, 24, 5, 380, 1, "other"),
    ("Ikan Dori Bakar", 250, 20, 8, 20, 3, 350, 1, "other"),
    ("Ikan Dori Saus Tiram", 290, 18, 10, 26, 5, 480, 2, "other"),
    ("Udang Saus Mentega", 300, 18, 16, 20, 4, 450, 1, "other"),
    ("Udang Saus Padang", 310, 18, 14, 22, 5, 500, 2, "local_indonesian"),
    ("Udang Goreng Tepung", 320, 16, 16, 24, 3, 380, 1, "other"),
    ("Udang Asam Manis", 280, 18, 10, 26, 8, 420, 2, "other"),
    ("Udang Cabe Garam", 290, 18, 14, 20, 3, 450, 2, "other"),
    ("Udang Saus Tiram", 300, 18, 10, 26, 5, 500, 2, "other"),
    ("Cumi Saus Mentega", 280, 16, 14, 20, 4, 420, 1, "other"),
    ("Cumi Goreng Tepung", 300, 14, 16, 22, 3, 350, 1, "other"),
    ("Cumi Asam Manis", 260, 16, 8, 24, 8, 400, 2, "other"),
    ("Cumi Cabe Garam", 270, 16, 12, 20, 3, 430, 2, "other"),
    ("Cumi Saus Padang", 290, 16, 12, 24, 5, 480, 2, "local_indonesian"),
    ("Cumi Bakar Saus Kecap", 270, 16, 10, 22, 6, 460, 1, "other"),
    ("Tuna Goreng", 280, 24, 12, 18, 3, 350, 1, "other"),
    ("Tuna Bakar", 250, 26, 8, 16, 2, 350, 1, "other"),
    ("Tuna Kuah Kuning", 260, 24, 10, 18, 4, 450, 2, "local_indonesian"),
    ("Tongkol Balado", 280, 22, 12, 18, 4, 480, 2, "local_indonesian"),
    ("Tongkol Goreng", 300, 20, 14, 20, 3, 380, 1, "other"),
    ("Tongkol Kuah Asam", 240, 22, 8, 18, 4, 450, 2, "local_indonesian"),
    ("Kakap Saus Asam Manis", 270, 22, 8, 24, 8, 420, 2, "other"),
    ("Kakap Goreng Tepung", 300, 20, 12, 24, 3, 350, 1, "other"),
    ("Kakap Bakar Sambal", 260, 24, 8, 20, 4, 400, 1, "local_indonesian"),
    ("Salmon Saus Lemon", 320, 26, 16, 16, 4, 350, 1, "other"),
    ("Salmon Goreng", 340, 24, 18, 16, 3, 300, 1, "other"),
    ("Salmon Panggang Bumbu", 310, 28, 14, 16, 3, 350, 1, "other"),
    ("Patin Goreng", 290, 18, 14, 20, 3, 320, 1, "other"),
    ("Patin Bakar Kecap", 270, 20, 10, 22, 6, 420, 1, "other"),
    ("Patin Saus Asam Pedas", 260, 20, 8, 22, 5, 460, 2, "other"),
    ("Mujair Goreng", 280, 20, 12, 18, 3, 300, 1, "other"),
    ("Mujair Bakar", 250, 22, 8, 18, 3, 320, 1, "other"),
    ("Nila Bakar Sambal", 260, 24, 8, 20, 4, 420, 1, "local_indonesian"),
    ("Nila Goreng Krispi", 300, 22, 14, 20, 3, 350, 1, "other"),
    ("Gurame Asam Manis", 290, 20, 10, 26, 8, 420, 2, "other"),
    ("Gurame Goreng Lengkuas", 320, 22, 16, 20, 3, 380, 1, "other"),
    ("Bawal Bakar Madu", 280, 22, 9, 24, 8, 380, 1, "other"),
    ("Bawal Goreng Tepung", 320, 20, 16, 22, 3, 350, 1, "other"),
    ("Kerapu Goreng", 280, 24, 10, 18, 3, 320, 1, "other"),
    ("Kerapu Saus Tiram", 300, 24, 10, 22, 5, 480, 2, "other"),
    ("Bandeng Presto", 280, 22, 14, 14, 2, 350, 1, "local_indonesian"),
    ("Bandeng Bakar Bumbu", 270, 22, 10, 18, 4, 400, 1, "local_indonesian"),
]
for item in protein_flat:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 42. SANDWICH & BURGER VARIANTS
# ================================================================
sandwiches = [
    ("Burger Sapi Keju", 480, 28, 22, 38, 6, 600, 2, "other"),
    ("Burger Ayam Keju", 450, 26, 18, 38, 5, 580, 2, "other"),
    ("Burger Ikan Fillet", 400, 18, 16, 40, 5, 550, 2, "other"),
    ("Burger Tempe", 350, 14, 14, 38, 5, 480, 5, "other"),
    ("Burger Telur", 380, 18, 16, 36, 5, 500, 2, "other"),
    ("Cheeseburger Ganda", 580, 36, 30, 36, 5, 700, 2, "other"),
    ("Mini Burger", 320, 16, 14, 28, 4, 450, 2, "other"),
    ("Sandwich Telur Mayo", 320, 14, 14, 30, 5, 450, 3, "other"),
    ("Sandwich Daging Asap", 350, 18, 14, 32, 5, 600, 3, "other"),
    ("Sandwich Tuna Mayo", 320, 18, 12, 30, 4, 480, 3, "other"),
    ("Sandwich Ayam Panggang", 340, 24, 10, 32, 4, 450, 3, "other"),
    ("Club Sandwich", 420, 22, 16, 38, 5, 650, 4, "other"),
    ("Sandwich Sayuran", 250, 8, 8, 34, 5, 400, 5, "other"),
    ("Panini Ayam Pesto", 380, 24, 14, 34, 4, 500, 3, "other"),
    ("Panini Daging Keju", 420, 26, 18, 32, 4, 550, 2, "other"),
    ("Bagel Salmon", 350, 18, 12, 38, 4, 500, 3, "other"),
    ("Bagel Telur Keju", 340, 16, 14, 34, 4, 480, 2, "other"),
    ("Croissant Isi Ayam", 380, 18, 18, 32, 5, 500, 2, "other"),
    ("Croissant Isi Telur", 350, 14, 20, 28, 4, 420, 2, "other"),
    ("Croissant Isi Daging", 400, 20, 22, 28, 4, 520, 2, "other"),
    ("Hotdog Sosis", 350, 12, 18, 32, 5, 600, 2, "other"),
    ("Hotdog Sosis Keju", 380, 14, 20, 32, 5, 650, 2, "other"),
    ("Corn Dog", 300, 8, 14, 32, 5, 500, 2, "snack"),
    ("Roti Lapis Daging", 350, 18, 14, 34, 4, 500, 3, "other"),
    ("Roti Lapis Ayam", 330, 20, 12, 32, 4, 480, 3, "other"),
    ("Roti Bakar Coklat Keju", 300, 8, 12, 38, 14, 250, 2, "snack"),
    ("Roti Bakar Stroberi", 260, 6, 8, 38, 14, 200, 2, "snack"),
    ("Roti Bakar Kacang", 280, 8, 10, 36, 12, 220, 3, "snack"),
]
for item in sandwiches:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# 43. BREAKFAST / PORRIDGE EXT
# ================================================================
breakfast_ext = [
    ("Bubur Ayam Komplit", 350, 18, 10, 40, 4, 550, 3, "local_indonesian"),
    ("Bubur Ayam Cakwe", 320, 14, 10, 38, 4, 500, 2, "local_indonesian"),
    ("Bubur Ayam Ati Ampela", 340, 18, 10, 38, 4, 520, 2, "local_indonesian"),
    ("Bubur Sumsum Gula Merah", 200, 3, 8, 28, 14, 50, 1, "other"),
    ("Bubur Sagu", 180, 2, 3, 34, 14, 30, 2, "other"),
    ("Bubur Tepung Beras", 160, 2, 2, 32, 8, 20, 1, "other"),
    ("Bubur Ikan", 220, 14, 5, 28, 3, 450, 2, "other"),
    ("Bubur Daging", 280, 16, 8, 30, 3, 480, 2, "other"),
    ("Bubur Ketan Hitam", 220, 5, 6, 36, 14, 50, 4, "other"),
    ("Bubur Sagu Mutiara", 180, 2, 4, 32, 16, 30, 1, "other"),
    ("Lontong Sayur Medan", 320, 8, 10, 44, 6, 500, 4, "local_indonesian"),
    ("Lontong Sayur Betawi", 350, 10, 12, 42, 6, 520, 5, "local_indonesian"),
    ("Lontong Cap Gomeh", 380, 12, 12, 48, 6, 550, 4, "other"),
    ("Lontong Balap", 300, 8, 8, 44, 4, 480, 4, "local_indonesian"),
    ("Lontong Kikil", 350, 14, 12, 40, 4, 500, 3, "local_indonesian"),
    ("Nasi Uduk Komplit", 420, 14, 14, 52, 4, 550, 4, "local_indonesian"),
    ("Nasi Uduk Betawi", 400, 12, 12, 54, 4, 520, 4, "local_indonesian"),
    ("Nasi Kuning Komplit", 420, 14, 14, 52, 5, 550, 4, "local_indonesian"),
    ("Nasi Kuning Ayam", 400, 18, 12, 48, 4, 500, 3, "local_indonesian"),
    ("Nasi Kuning Telur", 380, 12, 10, 50, 4, 450, 3, "local_indonesian"),
    ("Nasi Kuning Manado", 420, 16, 14, 50, 5, 520, 4, "local_indonesian"),
    ("Ketupat Sayur Padang", 380, 10, 12, 50, 6, 520, 5, "local_indonesian"),
    ("Ketupat Sayur Betawi", 400, 12, 14, 50, 6, 550, 5, "local_indonesian"),
    ("Ketupat Sayur Banjar", 380, 10, 12, 50, 6, 500, 5, "local_indonesian"),
    ("Burgo", 280, 6, 6, 44, 4, 450, 2, "local_indonesian"),
    ("Martabak Manis Coklat", 320, 8, 14, 38, 16, 200, 2, "snack"),
    ("Martabak Manis Keju", 340, 10, 16, 36, 14, 250, 2, "snack"),
    ("Martabak Manis Kacang", 330, 10, 16, 36, 14, 220, 3, "snack"),
    ("Martabak Manis Campur", 350, 10, 18, 36, 16, 250, 2, "snack"),
    ("Martabak Mini", 250, 6, 10, 30, 12, 180, 2, "snack"),
    ("Pancake Madu", 260, 6, 8, 38, 14, 250, 2, "other"),
    ("Pancake Coklat", 280, 6, 10, 38, 16, 250, 2, "other"),
    ("Pancake Buah", 250, 6, 6, 40, 16, 200, 3, "other"),
    ("Waffle Coklat", 300, 7, 12, 38, 16, 280, 2, "other"),
    ("Waffle Es Krim", 350, 7, 16, 42, 20, 280, 2, "snack"),
    ("Waffle Stroberi", 280, 6, 10, 40, 18, 250, 3, "snack"),
    ("French Toast", 280, 8, 10, 36, 10, 300, 2, "other"),
    ("French Toast Kayu Manis", 290, 8, 10, 38, 12, 300, 2, "other"),
    ("Scrambled Egg Toast", 300, 16, 14, 26, 4, 400, 2, "other"),
    ("Baked Beans Toast", 280, 10, 6, 40, 6, 450, 6, "other"),
    ("Sereal Susu", 220, 8, 5, 34, 10, 150, 3, "other"),
    ("Overnight Oats", 200, 8, 6, 28, 6, 50, 6, "other"),
    ("Bubur Kacang Ijo", 200, 8, 3, 32, 10, 50, 5, "other"),
    ("Bubur Ketan Hitam Santan", 250, 5, 8, 38, 14, 40, 4, "other"),
    ("Kolak Biji Salak", 220, 3, 6, 36, 16, 50, 3, "other"),
]
for item in breakfast_ext:
    name = item[0]; nut = item[1:-1]; ft = item[-1]
    if add(name, *nut, ft, "gen-batch10"): count += 1

# ================================================================
# SAVE
# ================================================================
print(f"\nPart 4 total new: {count}")
if new:
    ndf = pd.DataFrame(new)
    ndf.to_csv(FINAL_OUTPUT, mode='a', header=False, index=False)
    df = pd.read_csv(FINAL_OUTPUT)
    print(f"Running total: {len(df)} foods")
    print(df["food_type"].value_counts().to_string())
else:
    print("No new foods added!")
