"""Batch 5: Final push to reach 5,000+ foods."""
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

# Indo-Chinese food
indochinese = [
    ("Capcay Kuah", 200, 8, 10, 22, 4, 500, 3.5),
    ("Capcay Goreng", 240, 8, 14, 24, 4, 550, 3.0),
    ("Fuyunghai", 280, 14, 16, 20, 4, 500, 1.5),
    ("Ayam Koloke", 320, 22, 16, 22, 10, 450, 0.5),
    ("Ayam Saus Inggris", 300, 24, 14, 18, 8, 500, 0.5),
    ("Sapi Lada Hitam", 320, 26, 16, 14, 2, 450, 0.5),
    ("Udang Saus Padang", 250, 18, 14, 14, 3, 550, 0.5),
    ("Cumi Saus Padang", 230, 15, 14, 12, 2, 550, 0.3),
    ("Kepiting Saus Padang", 280, 18, 16, 16, 3, 600, 0.5),
    ("Ayam Cah Jamur", 260, 22, 12, 14, 2, 400, 1.5),
    ("Sapi Cah Brokoli", 260, 24, 12, 14, 2, 400, 3.0),
    ("Udang Cah Brokoli", 200, 18, 8, 14, 2, 380, 2.5),
    ("Cah Kangkung Terasi", 100, 4, 6, 8, 2, 350, 2.0),
    ("Cah Tauge Polos", 80, 5, 3, 8, 2, 200, 2.0),
    ("Sapo Tahu", 200, 12, 10, 16, 3, 450, 1.5),
    ("Sapo Tahu Seafood", 220, 14, 12, 16, 3, 500, 1.5),
    ("Nasi Hainam", 380, 16, 12, 50, 2, 400, 1.0),
    ("Bubur Ayam Hainan", 320, 14, 10, 40, 2, 500, 1.5),
]
sv = count
for name, *nut in indochinese:
    if add(name, *nut, "local_indonesian", "gen-batch5"):
        count += 1
print(f"Indo-Chinese: +{count - sv}")

# Additional pepes/variants
pepes = [
    ("Pepes Ayam", 220, 22, 12, 8, 1, 300, 1.0),
    ("Pepes Ikan Mas", 180, 18, 8, 6, 1, 280, 0.5),
    ("Pepes Ikan Kembung", 190, 18, 10, 6, 1, 300, 0.5),
    ("Pepes Ikan Patin", 200, 16, 12, 8, 1, 280, 0.5),
    ("Pepes Ikan Nila", 180, 18, 8, 6, 1, 270, 0.5),
    ("Pepes Udang", 160, 16, 6, 8, 1, 320, 0.5),
    ("Pepes Cumi", 150, 14, 6, 8, 1, 350, 0.3),
    ("Pepes Telur", 140, 10, 8, 6, 1, 200, 0.3),
    ("Pepes Tahu Udang", 150, 10, 8, 8, 1, 300, 1.0),
    ("Bothok Tahu", 140, 8, 6, 12, 2, 200, 2.5),
    ("Bothok Tempe", 160, 12, 8, 12, 2, 200, 3.0),
    ("Bothok Lamtoro", 150, 10, 8, 12, 2, 200, 3.5),
]
sv = count
for name, *nut in pepes:
    if add(name, *nut, "local_indonesian", "gen-batch5"):
        count += 1
print(f"Pepes/Bothok: +{count - sv}")

# More sate variants
sate_more = [
    ("Sate Kambing Muda", 300, 22, 20, 10, 2, 400, 0.5),
    ("Sate Kelinci", 250, 24, 12, 8, 1, 350, 0.5),
    ("Sate Bebek", 280, 22, 16, 10, 2, 400, 0.3),
    ("Sate Kuda", 260, 24, 14, 8, 1, 380, 0.3),
    ("Sate Kerbau", 290, 24, 16, 8, 2, 400, 0.5),
    ("Sate Keong", 180, 14, 10, 10, 1, 300, 0.5),
    ("Sate Jamur", 150, 8, 8, 12, 2, 250, 2.0),
    ("Sate Telur Puyuh Bumbu Kecap", 190, 12, 12, 8, 3, 350, 0.3),
    ("Sate Goreng", 280, 22, 18, 10, 2, 450, 0.5),
    ("Sate Maranggi", 280, 24, 14, 12, 4, 420, 0.5),
    ("Sate Plecing", 270, 22, 16, 10, 2, 400, 0.5),
    ("Sate Susu", 240, 18, 16, 6, 1, 350, 0),
]
sv = count
for name, *nut in sate_more:
    if add(name, *nut, "local_indonesian", "gen-batch5"):
        count += 1
print(f"Sate variants: +{count - sv}")

# More lauk pauk (side dishes for rice)
lauk = [
    ("Telur Balado", 180, 10, 14, 6, 3, 350, 0.3),
    ("Telur Sambal", 170, 10, 12, 6, 3, 350, 0.3),
    ("Telur Bumbu Bali", 190, 10, 14, 8, 4, 400, 0.3),
    ("Telur Semur", 180, 10, 12, 10, 6, 450, 0.3),
    ("Telur Kecap", 180, 10, 12, 10, 6, 500, 0.3),
    ("Telur Dadar Iris", 160, 12, 12, 2, 1, 200, 0),
    ("Telur Puyuh Kecap", 150, 10, 10, 6, 3, 400, 0.2),
    ("Tahu Goreng Bumbu Kuning", 160, 8, 10, 12, 1, 300, 1.0),
    ("Tahu Goreng Balado", 170, 8, 12, 10, 2, 350, 1.0),
    ("Tempe Goreng Lengkuas", 190, 12, 12, 12, 1, 250, 3.0),
    ("Terong Balado", 120, 2, 8, 12, 4, 300, 2.5),
    ("Terong Goreng Tepung", 180, 3, 12, 16, 3, 250, 2.0),
    ("Terong Kecap", 130, 2, 8, 14, 6, 400, 2.5),
    ("Ikan Asin Goreng", 250, 18, 16, 8, 0.5, 1200, 0),
    ("Ikan Asin Sambal", 260, 18, 18, 10, 2, 1200, 0.3),
    ("Telur Asin", 180, 10, 14, 2, 0.5, 500, 0),
    ("Tahu Telur", 280, 14, 16, 22, 3, 500, 1.5),
    ("Tahu Campur Surabaya", 350, 16, 16, 34, 3, 650, 2.5),
]
sv = count
for name, *nut in lauk:
    if add(name, *nut, "local_indonesian", "gen-batch5"):
        count += 1
print(f"Lauk: +{count - sv}")

# More seafood extended
seafood_ext = [
    ("Cumi Goreng Tepung", 280, 14, 16, 20, 1, 400, 0.3),
    ("Cumi Bakar", 180, 16, 8, 8, 1, 350, 0),
    ("Cumi Saus Tiram", 200, 16, 10, 12, 3, 500, 0.3),
    ("Cumi Goreng Mentega", 260, 14, 16, 14, 2, 400, 0.3),
    ("Udang Goreng Tepung", 250, 16, 14, 18, 1, 380, 0.5),
    ("Udang Bakar", 160, 20, 6, 6, 1, 280, 0),
    ("Udang Saus Tiram", 180, 18, 8, 12, 3, 480, 0.3),
    ("Kerang Rebus", 120, 14, 3, 6, 1, 350, 0),
    ("Kerang Saus Padang", 170, 14, 10, 10, 2, 500, 0.5),
    ("Kerang Goreng Tepung", 200, 12, 14, 12, 1, 400, 0.3),
    ("Kepiting Goreng", 220, 18, 14, 8, 1, 400, 0),
    ("Kepiting Rebus", 180, 18, 8, 6, 1, 380, 0),
    ("Lobster Bakar", 160, 22, 4, 6, 1, 350, 0),
    ("Rajungan Saus Tiram", 170, 16, 8, 10, 2, 450, 0.3),
    ("Gurame Asam Manis", 220, 16, 10, 16, 8, 400, 0.5),
    ("Nila Goreng Sambal", 200, 18, 12, 8, 2, 380, 0.5),
]
sv = count
for name, *nut in seafood_ext:
    if add(name, *nut, "base_food", "gen-batch5"):
        count += 1
print(f"Seafood ext: +{count - sv}")

# More breakfast/brunch items
breakfast_ext = [
    ("Bubur Ayam Spesial Komplit", 400, 18, 16, 48, 3, 650, 2.0),
    ("Nasi Uduk Betawi", 420, 12, 20, 48, 3, 500, 2.0),
    ("Nasi Uduk Telur", 400, 14, 18, 46, 3, 500, 2.0),
    ("Nasi Uduk Ayam Goreng", 450, 20, 22, 46, 3, 550, 2.0),
    ("Nasi Uduk Tempe Goreng", 380, 14, 18, 42, 3, 450, 2.5),
    ("Ketupat Sayur Betawi", 370, 12, 18, 40, 4, 600, 3.0),
    ("Lontong Sayur Betawi", 380, 12, 18, 42, 4, 600, 3.0),
    ("Lontong Kari", 370, 12, 18, 40, 3, 550, 2.0),
    ("Lontong Opor", 380, 14, 20, 38, 3, 500, 1.5),
    ("Lontong Gulai Pakis", 350, 10, 16, 42, 3, 550, 3.0),
    ("Bubur Manado Sayur", 220, 8, 5, 36, 3, 400, 4.5),
]
sv = count
for name, *nut in breakfast_ext:
    if add(name, *nut, "local_indonesian", "gen-batch5"):
        count += 1
print(f"Breakfast ext: +{count - sv}")

# More beverages/traditional drinks
bev_ext = [
    ("Es Cendol Dawet", 180, 2, 4, 34, 24, 50, 0.5),
    ("Es Cincau Santan", 160, 1, 4, 30, 24, 40, 1.5),
    ("Es Kopyor", 140, 1, 4, 26, 20, 40, 1.5),
    ("Es Siwalan", 130, 1, 3, 26, 20, 40, 1.5),
    ("Es Laksamana Mengamuk", 200, 3, 5, 36, 28, 60, 1.0),
    ("Es Shanghai", 220, 3, 6, 38, 28, 60, 1.0),
    ("Es Bola Durian", 280, 4, 12, 40, 28, 40, 2.0),
    ("Jus Sirsak", 70, 1, 0.3, 16, 12, 15, 2.5),
    ("Jus Terong Belanda", 60, 1, 0.3, 14, 10, 10, 2.0),
    ("Jus Kedondong", 55, 0.5, 0.2, 13, 8, 5, 2.0),
    ("Jus Bit", 45, 1.5, 0.2, 9, 7, 70, 2.5),
    ("Jus Seledri", 25, 0.5, 0.1, 5, 2, 30, 1.5),
    ("Jus Mentimun", 20, 0.5, 0.1, 4, 2, 5, 0.5),
    ("Es Jeruk Sonkit", 50, 0.3, 0.1, 12, 4, 2, 0.5),
    ("Es Teh Madu", 70, 0.2, 0.1, 18, 16, 5, 0),
    ("Es Teh Melati Madu", 70, 0.2, 0.1, 18, 16, 5, 0),
]
sv = count
for name, *nut in bev_ext:
    if add(name, *nut, "beverage", "gen-batch5"):
        count += 1
print(f"Beverages ext: +{count - sv}")

# More snacks/small bites
snack_ext = [
    ("Donat Kentang", 250, 4, 12, 32, 10, 200, 1.0),
    ("Donat Gula", 240, 4, 10, 34, 14, 180, 0.5),
    ("Donat Coklat", 260, 4, 12, 34, 16, 200, 1.0),
    ("Odading", 230, 4, 10, 32, 14, 180, 0.5),
    ("Kue Gemblong", 210, 3, 9, 30, 18, 100, 0.5),
    ("Klepon Ubi", 190, 3, 7, 30, 14, 60, 1.5),
    ("Onde-Onde Wijen", 210, 4, 10, 26, 8, 120, 1.0),
    ("Lapis Legit", 280, 5, 16, 30, 24, 120, 0.3),
    ("Bolu Gulung", 250, 5, 12, 32, 20, 120, 0.3),
    ("Bolu Kukus Mekar", 180, 4, 6, 28, 16, 100, 0.3),
    ("Brownies Kukus", 280, 5, 14, 34, 24, 150, 1.0),
    ("Lemper Spesial", 240, 8, 8, 34, 2, 280, 2.5),
    ("Arem-Arem", 250, 6, 6, 42, 2, 250, 2.5),
    ("Pastel Tutup", 260, 8, 14, 26, 4, 400, 1.5),
    ("Risol Mayo", 220, 6, 12, 24, 3, 350, 1.0),
    ("Risol Isi Ragout", 210, 6, 10, 24, 3, 350, 1.0),
    ("Tahu Bakso", 220, 12, 12, 16, 2, 400, 1.0),
    ("Bakso Goreng", 250, 12, 14, 22, 2, 450, 0.5),
    ("Bakso Ikan Goreng", 240, 14, 12, 22, 2, 450, 0.3),
    ("Bakso Udang Goreng", 230, 14, 10, 22, 2, 480, 0.3),
    ("Pempek Pistel", 280, 8, 12, 36, 2, 600, 0.5),
    ("Pempek Telur Kecil", 300, 10, 14, 36, 2, 650, 0.5),
    ("Otak-Otak Panggang", 180, 10, 8, 16, 2, 400, 0.5),
    ("Sosis Bakar", 250, 12, 18, 14, 2, 550, 0.3),
    ("Sempol", 200, 8, 10, 20, 2, 400, 0.5),
    ("Tahu Walik", 200, 8, 10, 20, 2, 380, 1.0),
]
sv = count
for name, *nut in snack_ext:
    if add(name, *nut, "snack", "gen-batch5"):
        count += 1
print(f"Snacks ext: +{count - sv}")

# More gulai/kari
gulai = [
    ("Gulai Ayam", 340, 22, 22, 10, 2, 450, 0.5),
    ("Gulai Sapi", 350, 24, 24, 10, 2, 480, 0.5),
    ("Gulai Ikan", 280, 18, 18, 10, 2, 450, 0.5),
    ("Gulai Udang", 250, 18, 16, 8, 2, 500, 0.3),
    ("Gulai Cumi", 240, 15, 16, 8, 2, 480, 0.3),
    ("Gulai Tunjang", 320, 20, 24, 6, 1, 400, 0),
    ("Gulai Otak Sapi", 280, 16, 22, 6, 1, 350, 0),
    ("Gulai Nangka Muda", 180, 5, 14, 12, 2, 350, 3.0),
    ("Gulai Pakis", 160, 4, 12, 10, 2, 300, 3.5),
    ("Gulai Daun Ubi", 170, 5, 12, 12, 2, 300, 3.5),
    ("Gulai Rebung", 140, 4, 10, 12, 2, 300, 3.0),
    ("Gulai Labu", 130, 3, 10, 10, 3, 250, 2.5),
    ("Kari Ayam", 340, 24, 22, 12, 3, 480, 1.5),
    ("Kari Kambing", 360, 24, 24, 12, 3, 500, 1.5),
    ("Kari Sapi", 350, 26, 22, 12, 3, 480, 1.0),
    ("Kari Ikan", 280, 20, 18, 10, 2, 450, 1.0),
    ("Kari Udang", 250, 18, 16, 10, 2, 500, 0.5),
    ("Kari Telur", 200, 10, 14, 8, 3, 400, 0.5),
    ("Kari Tahu", 180, 8, 12, 10, 2, 380, 1.5),
    ("Kari Sayur", 140, 5, 10, 10, 3, 350, 3.5),
]
sv = count
for name, *nut in gulai:
    if add(name, *nut, "local_indonesian", "gen-batch5"):
        count += 1
print(f"Gulai/Kari: +{count - sv}")

# Merge and save
df_new = pd.DataFrame(new_foods)
df_combined = pd.concat([df, df_new], ignore_index=True)
df_combined.to_csv(FINAL_OUTPUT, index=False)

print(f"\nBatch 5 generated: {len(new_foods)} new foods")
print(f"Final total: {len(df_combined)} foods")
print(f"  Base: {(df_combined['food_type'] == 'base_food').sum()}")
print(f"  Local Indonesian: {(df_combined['food_type'] == 'local_indonesian').sum()}")
print(f"  Beverages: {(df_combined['food_type'] == 'beverage').sum()}")
print(f"  Snacks: {(df_combined['food_type'] == 'snack').sum()}")
print(f"  Other: {(df_combined['food_type'] == 'other').sum()}")
