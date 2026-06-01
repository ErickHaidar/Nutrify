"""Batch 10 Part 9: FINAL — 176 remaining to 10K."""
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
    # KAMBING VARIANTS
    ("Kambing Guling", 400, 28, 24, 14, 3, 450, 1, "local_indonesian"),
    ("Kambing Bakar Kecap", 380, 28, 18, 16, 5, 480, 1, "local_indonesian"),
    ("Kambing Goreng Rempah", 420, 28, 24, 16, 3, 420, 1, "local_indonesian"),
    ("Tongseng Kambing Pedas", 340, 24, 18, 16, 4, 520, 3, "local_indonesian"),
    ("Sate Kambing Muda Empuk", 290, 24, 14, 14, 4, 420, 1, "local_indonesian"),
    ("Gulai Kambing Aceh", 360, 26, 20, 16, 4, 520, 2, "local_indonesian"),
    ("Kari Kambing Indonesia", 350, 24, 20, 16, 4, 500, 3, "local_indonesian"),
    ("Sop Kambing Betawi", 320, 24, 16, 16, 4, 520, 2, "local_indonesian"),

    # BEBEK VARIANTS
    ("Bebek Goreng Kremes", 420, 28, 24, 18, 3, 480, 1, "other"),
    ("Bebek Goreng Sambal Korek", 430, 28, 24, 18, 4, 500, 2, "other"),
    ("Bebek Bakar Sambal Matah", 400, 28, 20, 18, 4, 460, 2, "other"),
    ("Bebek Tim", 320, 26, 14, 16, 3, 450, 1, "other"),
    ("Bebek Asap", 350, 28, 16, 16, 3, 480, 1, "other"),
    ("Bebek Panggang Bumbu", 380, 28, 18, 16, 4, 450, 2, "other"),

    # AYAM MORE
    ("Ayam Kodok", 380, 28, 18, 20, 4, 480, 2, "other"),
    ("Ayam Asap", 300, 26, 12, 14, 3, 480, 1, "other"),
    ("Ayam Panggang Bumbu Kunyit", 300, 26, 12, 16, 3, 420, 1, "other"),
    ("Ayam Goreng Daun Jeruk", 330, 24, 16, 16, 3, 380, 1, "other"),
    ("Ayam Goreng Daun Salam", 330, 24, 16, 16, 3, 380, 1, "other"),
    ("Ayam Goreng Daun Pandan", 330, 24, 16, 16, 3, 380, 1, "other"),
    ("Ayam Goreng Daun Kemangi", 330, 24, 16, 16, 3, 380, 1, "other"),

    # IKAN MORE SPECIFIC
    ("Ikan Kembung Balado", 280, 24, 12, 16, 4, 450, 2, "local_indonesian"),
    ("Ikan Kembung Goreng Bumbu", 290, 24, 14, 16, 3, 400, 1, "local_indonesian"),
    ("Ikan Kembung Bakar Kecap", 270, 24, 10, 18, 5, 480, 1, "local_indonesian"),
    ("Ikan Tongkol Balado", 290, 24, 12, 18, 4, 450, 2, "local_indonesian"),
    ("Ikan Tongkol Goreng Bumbu", 300, 24, 14, 18, 3, 400, 1, "local_indonesian"),
    ("Ikan Tongkol Bakar Kecap", 280, 24, 10, 20, 5, 480, 1, "local_indonesian"),
    ("Ikan Cakalang Balado", 300, 26, 12, 18, 4, 450, 2, "local_indonesian"),
    ("Ikan Cakalang Bakar", 260, 28, 8, 16, 3, 400, 1, "local_indonesian"),

    # UDANG MORE
    ("Udang Bakar Kecap Manis", 250, 20, 8, 20, 5, 480, 1, "other"),
    ("Udang Goreng Kremes", 290, 20, 14, 18, 3, 380, 1, "other"),
    ("Udang Goreng Bawang", 280, 20, 12, 18, 3, 380, 1, "other"),

    # Soup/Soto MORE
    ("Soto Daging Madura", 300, 20, 10, 26, 4, 520, 3, "local_indonesian"),
    ("Soto Ayam Lamongan", 280, 18, 8, 26, 4, 500, 3, "local_indonesian"),
    ("Soto Ayam Surabaya", 280, 18, 8, 26, 4, 500, 3, "local_indonesian"),
    ("Soto Ayam Jakarta", 280, 18, 8, 26, 4, 500, 3, "local_indonesian"),
    ("Soto Ayam Bandung", 280, 18, 8, 26, 4, 500, 3, "local_indonesian"),

    # BAKSO VARIANTS
    ("Bakso Beranak", 300, 16, 12, 28, 4, 650, 3, "other"),
    ("Bakso Iga", 320, 20, 12, 28, 4, 600, 2, "other"),
    ("Bakso Tetelan", 300, 18, 12, 28, 4, 620, 2, "other"),
    ("Bakso Jumbo", 350, 20, 14, 30, 4, 650, 3, "other"),
    ("Bakso Super Komplit", 380, 22, 16, 32, 5, 680, 3, "other"),

    # NASI CAMPUR / WARUNG
    ("Nasi Ayam Goreng Lalapan", 400, 24, 16, 34, 4, 450, 3, "other"),
    ("Nasi Ayam Bakar Lalapan", 400, 24, 14, 36, 4, 450, 3, "other"),
    ("Nasi Lele Penyet", 370, 22, 14, 34, 4, 480, 4, "other"),
    ("Nasi Bebek Penyet", 420, 26, 18, 34, 4, 480, 3, "other"),
    ("Nasi Ayam Penyet Komplit", 380, 26, 16, 30, 4, 450, 3, "other"),

    # MIE MORE VARIANTS
    ("Mie Ayam Bakar", 420, 18, 12, 50, 5, 600, 3, "other"),
    ("Mie Ayam Pangsit Bakso", 440, 20, 14, 50, 5, 650, 3, "other"),
    ("Mie Ayam Ceker Komplit", 430, 20, 14, 48, 5, 620, 3, "other"),
    ("Mie Ayam Spesial Komplit", 450, 22, 14, 50, 5, 650, 3, "other"),

    # SAYUR MORE
    ("Cah Kangkung Polos", 80, 4, 3, 10, 2, 250, 3, "other"),
    ("Cah Bayam Polos", 70, 4, 2, 10, 2, 250, 3, "other"),
    ("Cah Sawi Polos", 70, 4, 2, 10, 2, 250, 3, "other"),
    ("Cah Kembang Kol Saus Tiram", 100, 5, 5, 12, 3, 350, 4, "other"),
    ("Cah Taoge Polos", 80, 5, 3, 10, 2, 200, 3, "other"),
    ("Sop Sayuran Komplit", 100, 5, 3, 14, 4, 450, 5, "other"),

    # SANDWICH & BURGER
    ("Burger Daging Sapi", 450, 26, 20, 36, 5, 580, 3, "other"),
    ("Burger Ayam Crispy", 420, 22, 18, 38, 5, 550, 3, "other"),
    ("Burger Salmon", 400, 22, 16, 36, 5, 500, 3, "other"),
    ("Sandwich Ham Keju", 320, 16, 14, 30, 4, 600, 3, "other"),
    ("Sandwich Roast Beef", 350, 22, 14, 30, 4, 520, 3, "other"),

    # JAPANESE MORE
    ("Katsudon Jepang", 600, 28, 18, 62, 6, 700, 2, "other"),
    ("Tendon Jepang", 550, 16, 18, 64, 5, 550, 3, "other"),
    ("Unadon Jepang", 580, 26, 16, 60, 8, 600, 2, "other"),
    ("Tekkadon Jepang", 520, 28, 14, 54, 5, 500, 3, "other"),
    ("Oyakodon Jepang", 480, 26, 12, 58, 5, 650, 2, "other"),
    ("Gyudon Jepang", 550, 24, 14, 68, 8, 700, 2, "other"),

    # KOREAN MORE
    ("Galbijjim Korea", 420, 28, 16, 32, 8, 650, 3, "other"),
    ("Jeyuk Bokkeum", 380, 24, 18, 24, 6, 600, 3, "other"),
    ("Dakdoritang Korea", 350, 26, 12, 26, 5, 600, 4, "other"),
    ("Haemul Pajeon", 300, 10, 12, 36, 5, 550, 3, "other"),
    ("Japchae Bap", 420, 14, 10, 60, 8, 580, 4, "other"),

    # THAI MORE
    ("Pad Thai Gai", 420, 18, 14, 52, 8, 650, 3, "other"),
    ("Gaeng Keow Wan", 320, 18, 18, 22, 6, 600, 3, "other"),
    ("Khao Pad Gai", 380, 16, 10, 50, 5, 550, 2, "other"),
    ("Tom Yum Gai Thailand", 140, 12, 5, 12, 4, 720, 2, "other"),

    # STREET FOOD MORE
    ("Tahu Bulat Kopong", 180, 8, 9, 16, 2, 350, 1, "snack"),
    ("Tahu Gunting", 220, 10, 9, 22, 5, 450, 3, "snack"),
    ("Cilok Kuah Kacang", 200, 6, 6, 30, 5, 450, 3, "snack"),
    ("Cilok Goang", 200, 6, 6, 30, 5, 480, 3, "snack"),
    ("Cireng Isi", 220, 5, 8, 30, 4, 380, 2, "snack"),
    ("Cireng Kuah Rujak", 220, 5, 8, 30, 5, 420, 3, "snack"),

    # SNACK MORE
    ("Sate Buah", 120, 2, 2, 24, 16, 50, 4, "snack"),
    ("Sosis Bakar Saus", 300, 10, 20, 20, 5, 520, 1, "snack"),
    ("Sosis Goreng Tepung", 320, 10, 22, 20, 4, 500, 1, "snack"),
    ("Bakso Bakar Saus", 230, 10, 8, 28, 5, 500, 2, "snack"),
    ("Bakso Goreng Tepung", 250, 10, 12, 26, 4, 480, 2, "snack"),

    # MORE BEVERAGE
    ("Jus Wortel Apel", 80, 1, 0, 18, 14, 30, 4, "beverage"),
    ("Jus Bayam Nanas", 70, 2, 0, 14, 10, 20, 4, "beverage"),
    ("Jus Seledri Madu", 60, 1, 0, 12, 10, 30, 3, "beverage"),
    ("Jus Bit Apel", 80, 1, 0, 18, 14, 30, 4, "beverage"),
    ("Smoothie Berry Campur", 150, 3, 3, 28, 18, 30, 5, "beverage"),
    ("Smoothie Alpukat Coklat", 220, 4, 10, 30, 14, 40, 5, "beverage"),
    ("Teh Tarik Kurang Manis", 100, 3, 3, 14, 8, 40, 0, "beverage"),
    ("Kopi Susu Aren", 140, 3, 5, 18, 14, 40, 0, "beverage"),
    ("Kopi Susu Kurma", 140, 3, 5, 20, 16, 40, 1, "beverage"),
    ("Kopi Aren Latte", 150, 3, 5, 22, 18, 40, 0, "beverage"),

    # LONTONG / KETUPAT MORE
    ("Lontong Cap Go Me", 380, 12, 12, 48, 6, 550, 4, "other"),
    ("Lontong Mie Surabaya", 380, 14, 10, 48, 5, 580, 4, "local_indonesian"),
    ("Ketupat Opor Ayam", 380, 18, 14, 38, 5, 480, 3, "local_indonesian"),
    ("Ketupat Gulai Daging", 400, 20, 18, 36, 5, 500, 3, "local_indonesian"),

    # GULAI / KARI MORE
    ("Gulai Nangka Muda Santan", 220, 4, 12, 24, 4, 400, 5, "local_indonesian"),
    ("Gulai Kacang Panjang", 180, 5, 10, 18, 4, 380, 4, "local_indonesian"),
    ("Gulai Terong Telunjuk", 170, 4, 10, 18, 4, 380, 4, "local_indonesian"),
    ("Gulai Daun Ubi", 180, 6, 12, 14, 3, 380, 4, "local_indonesian"),
    ("Kari Ayam Kampung", 320, 24, 18, 16, 4, 480, 3, "local_indonesian"),
    ("Kari Ikan Kembung", 260, 22, 14, 14, 4, 480, 2, "local_indonesian"),

    # MORE SAYUR/OSENG
    ("Oseng Tempe Kacang Panjang", 200, 12, 10, 16, 3, 350, 4, "local_indonesian"),
    ("Oseng Tahu Kecap", 180, 10, 8, 14, 5, 450, 3, "local_indonesian"),
    ("Oseng Tauge Tahu", 140, 8, 6, 14, 3, 300, 3, "local_indonesian"),
    ("Oseng Buncis Tempe", 160, 8, 7, 16, 3, 300, 4, "local_indonesian"),
    ("Oseng Jamur Saus Tiram", 120, 6, 5, 14, 3, 400, 4, "other"),
]
for item in items:
    if add(*item, "gen-batch10"): count += 1

print(f"\nPart 9 total new: {count}")
if new:
    ndf = pd.DataFrame(new)
    ndf.to_csv(FINAL_OUTPUT, mode='a', header=False, index=False)
    df = pd.read_csv(FINAL_OUTPUT)
    print(f"Running total: {len(df)} foods")
    print(df["food_type"].value_counts().to_string())
else:
    print("No new foods added!")
