"""Generate large-scale Indonesian food dataset via systematic combinations.

Protein × cooking methods, vegetables × cooking methods, etc.
Standard nutrition adjustments based on cooking method.
"""
import pandas as pd
import json

# Nutrition multipliers for cooking methods (relative to raw/boiled)
# Format: (cal_mult, fat_mult, protein_mult, carb_mult, fiber_mult)
COOKING_METHODS = {
    "Rebus": (1.00, 1.00, 1.00, 1.00, 1.00),
    "Kukus": (1.05, 1.00, 1.02, 1.00, 1.05),
    "Bakar": (1.15, 1.20, 1.05, 1.00, 0.95),
    "Goreng": (1.80, 4.00, 0.85, 1.15, 0.90),
    "Tumis": (1.50, 3.00, 0.90, 1.10, 0.95),
    "Panggang": (1.20, 1.30, 1.08, 1.00, 0.95),
    "Pepes": (1.10, 1.10, 1.05, 1.00, 1.00),
    "Bacem": (1.30, 1.10, 0.90, 1.50, 0.90),
    "Balado": (1.40, 2.50, 0.92, 1.20, 1.00),
    "Rica-Rica": (1.35, 2.30, 0.93, 1.10, 1.05),
    "Kecap": (1.30, 1.40, 0.95, 1.40, 0.90),
    "Semur": (1.35, 1.80, 0.93, 1.30, 0.95),
    "Opor": (1.45, 3.00, 0.90, 1.10, 0.95),
    "Gulai": (1.50, 3.50, 0.88, 1.10, 1.00),
    "Kari": (1.45, 3.20, 0.90, 1.10, 1.05),
    "Asam Manis": (1.25, 1.50, 0.95, 1.20, 1.00),
    "Saus Tiram": (1.30, 1.60, 1.00, 1.15, 1.00),
    "Lada Hitam": (1.25, 1.80, 1.00, 1.05, 0.95),
    "Tepung Goreng": (2.00, 5.00, 0.80, 1.30, 0.85),
}

# Base proteins with their nutrition per 100g (cal, protein, fat, carbs, sugar, sodium, fiber)
PROTEINS = {
    # Ayam (chicken parts)
    "Dada Ayam": (120, 25.0, 2.5, 0.0, 0.0, 50, 0.0),
    "Paha Ayam": (145, 20.0, 7.0, 0.0, 0.0, 65, 0.0),
    "Sayap Ayam": (160, 18.0, 10.0, 0.0, 0.0, 55, 0.0),
    "Ayam Utuh": (150, 21.0, 7.0, 0.0, 0.0, 60, 0.0),
    "Hati Ayam": (135, 22.0, 5.0, 0.5, 0.0, 45, 0.0),
    "Ampela Ayam": (120, 24.0, 2.0, 0.5, 0.0, 50, 0.0),

    # Daging (meat)
    "Daging Sapi": (180, 26.0, 8.0, 0.0, 0.0, 55, 0.0),
    "Daging Sapi Giling": (220, 22.0, 14.0, 0.0, 0.0, 60, 0.0),
    "Daging Kambing": (170, 24.0, 7.5, 0.0, 0.0, 75, 0.0),
    "Iga Sapi": (230, 20.0, 16.0, 0.0, 0.0, 50, 0.0),
    "Lidah Sapi": (210, 18.0, 15.0, 0.0, 0.0, 55, 0.0),

    # Ikan (fish)
    "Ikan Mas": (125, 18.0, 5.5, 0.0, 0.0, 45, 0.0),
    "Ikan Nila": (115, 19.0, 4.0, 0.0, 0.0, 40, 0.0),
    "Ikan Lele": (140, 17.0, 7.5, 0.0, 0.0, 48, 0.0),
    "Ikan Gurame": (120, 18.5, 5.0, 0.0, 0.0, 42, 0.0),
    "Ikan Kembung": (150, 21.0, 7.0, 0.0, 0.0, 55, 0.0),
    "Ikan Tongkol": (155, 23.0, 6.5, 0.0, 0.0, 50, 0.0),
    "Ikan Bandeng": (140, 19.0, 6.8, 0.0, 0.0, 50, 0.0),
    "Ikan Kakap": (115, 20.0, 3.5, 0.0, 0.0, 38, 0.0),
    "Ikan Patin": (155, 17.0, 9.0, 0.0, 0.0, 52, 0.0),
    "Ikan Baronang": (130, 19.0, 5.5, 0.0, 0.0, 45, 0.0),
    "Ikan Bawal": (135, 18.5, 6.5, 0.0, 0.0, 48, 0.0),
    "Ikan Tuna": (130, 25.0, 3.0, 0.0, 0.0, 40, 0.0),
    "Ikan Salmon": (180, 20.0, 11.0, 0.0, 0.0, 50, 0.0),

    # Seafood
    "Udang": (95, 19.0, 1.5, 0.5, 0.0, 140, 0.0),
    "Cumi": (85, 15.0, 1.2, 2.0, 0.0, 230, 0.0),
    "Kepiting": (90, 18.0, 1.5, 0.5, 0.0, 280, 0.0),
    "Kerang": (80, 14.0, 1.0, 3.0, 0.0, 110, 0.0),

    # Tahu & Tempe (plant protein)
    "Tahu Putih": (75, 7.5, 4.5, 1.5, 0.3, 8, 0.5),
    "Tahu Kuning": (90, 10.0, 5.0, 2.0, 0.3, 10, 0.5),
    "Tempe": (170, 18.0, 8.0, 10.0, 0.3, 8, 2.0),

    # Telur
    "Telur Ayam": (155, 12.5, 10.5, 1.0, 1.0, 120, 0.0),
    "Telur Bebek": (180, 13.0, 14.0, 0.7, 0.5, 140, 0.0),
    "Telur Puyuh": (158, 13.0, 11.0, 0.4, 0.3, 125, 0.0),
}

# Vegetables per 100g (cal, protein, fat, carbs, sugar, sodium, fiber)
VEGETABLES = {
    "Bayam": (23, 2.5, 0.4, 3.5, 0.1, 65, 1.5),
    "Kangkung": (20, 2.0, 0.3, 3.5, 0.1, 55, 1.2),
    "Sawi Hijau": (22, 2.0, 0.3, 3.0, 0.1, 45, 1.2),
    "Sawi Putih": (18, 1.5, 0.2, 2.5, 0.1, 38, 1.0),
    "Brokoli": (32, 2.8, 0.4, 5.0, 0.1, 28, 2.5),
    "Kembang Kol": (22, 1.8, 0.2, 4.0, 0.1, 20, 2.0),
    "Wortel": (32, 0.8, 0.2, 6.5, 4.5, 55, 2.5),
    "Buncis": (28, 1.8, 0.2, 5.5, 1.5, 5, 2.0),
    "Kacang Panjang": (32, 2.5, 0.3, 5.5, 0.1, 5, 2.0),
    "Labu Siam": (18, 0.6, 0.1, 3.5, 1.8, 3, 1.5),
    "Terong Ungu": (22, 1.0, 0.2, 4.5, 0.1, 3, 2.0),
    "Pare": (18, 1.0, 0.2, 3.3, 0.1, 3, 1.8),
    "Kubis": (20, 1.5, 0.2, 3.5, 0.1, 15, 1.8),
    "Daun Singkong": (38, 3.5, 0.5, 6.0, 0.1, 10, 2.5),
    "Daun Pepaya": (32, 3.0, 0.5, 5.0, 0.1, 8, 2.0),
    "Tauge": (28, 2.5, 0.3, 4.0, 0.1, 8, 1.5),
    "Oyong": (16, 0.5, 0.1, 3.0, 0.1, 2, 1.8),
    "Jamur Tiram": (30, 3.0, 0.3, 4.5, 0.1, 5, 2.0),
    "Jamur Kancing": (25, 2.5, 0.2, 4.0, 0.1, 5, 1.8),
    "Jamur Kuping": (22, 1.0, 0.1, 4.5, 0.1, 3, 3.5),
    "Jagung Muda": (32, 2.0, 0.5, 6.5, 0.1, 5, 2.0),
    "Kapri": (38, 3.0, 0.3, 6.5, 0.5, 5, 2.5),
    "Kecipir": (35, 3.5, 0.3, 5.5, 0.2, 5, 2.0),
    "Rebung": (22, 2.0, 0.2, 3.5, 0.1, 5, 2.2),
    "Nangka Muda": (35, 2.0, 0.3, 7.5, 0.5, 5, 2.5),
    "Melinjo": (65, 5.0, 1.0, 12.0, 0.5, 5, 4.0),
    "Daun Kelor": (42, 5.5, 0.8, 4.5, 0.1, 12, 2.0),
    "Daun Katuk": (48, 5.0, 0.7, 6.5, 0.1, 10, 2.5),
    "Genjer": (24, 1.5, 0.3, 4.2, 0.1, 8, 1.2),
    "Seledri": (20, 0.8, 0.2, 3.5, 0.1, 80, 1.5),
}

# Carb sources with nutrition
CARBS = {
    "Nasi Putih": (180, 3.0, 0.3, 39.0, 0.1, 2, 0.5),
    "Nasi Merah": (178, 3.5, 0.9, 37.0, 0.2, 3, 1.2),
    "Nasi Ketan": (190, 3.8, 0.4, 40.0, 0.1, 5, 0.8),
    "Bubur Nasi": (70, 1.2, 0.2, 15.0, 0.0, 2, 0.2),
    "Kentang": (87, 2.0, 0.1, 19.0, 0.8, 6, 2.0),
    "Ubi Jalar": (100, 1.8, 0.2, 23.0, 5.5, 10, 2.5),
    "Singkong": (155, 1.2, 0.3, 36.0, 1.5, 14, 1.8),
    "Talas": (120, 1.5, 0.2, 27.0, 0.5, 10, 3.0),
    "Jagung": (140, 4.5, 1.5, 30.0, 3.0, 1, 3.0),
    "Mie Basah": (280, 7.0, 2.0, 55.0, 1.0, 500, 1.0),
    "Mie Kering": (340, 10.0, 1.5, 72.0, 1.5, 600, 2.0),
    "Bihun": (350, 6.0, 0.5, 80.0, 0.0, 10, 0.5),
    "Kwetiau": (300, 5.0, 1.0, 68.0, 0.0, 15, 0.5),
    "Soun": (340, 2.0, 0.0, 82.0, 0.0, 8, 0.3),
    "Roti Tawar": (265, 8.0, 3.2, 49.0, 4.5, 500, 2.5),
    "Makaroni": (350, 12.0, 1.5, 72.0, 2.0, 5, 2.5),
}


def apply_cooking(nutrition, method):
    """Apply cooking method multipliers to nutrition values."""
    cal, prot, fat, carbs, sugar, sodium, fiber = nutrition
    mult = COOKING_METHODS[method]
    return (
        round(cal * mult[0], 1),
        round(prot * mult[2], 1),
        round(fat * mult[1], 1),
        round(carbs * mult[3], 1),
        round(sugar, 1),
        round(sodium * 1.0),
        round(fiber * mult[4], 1),
    )


def generate_all() -> list[dict]:
    foods = []
    seen = set()

    def add(name, serving, cal, prot, fat, carbs, sugar, sodium, fiber, food_type, source):
        key = name.lower().strip()
        if key in seen:
            return
        seen.add(key)
        foods.append({
            "name": name, "name_id": name, "serving_size": serving,
            "calories": cal, "protein_g": prot, "carbohydrate_g": carbs,
            "fat_g": fat, "sugar_g": sugar, "sodium_mg": sodium,
            "fiber_g": fiber, "food_type": food_type, "source": source,
        })

    # Generate protein × cooking methods
    for protein_name, nut in PROTEINS.items():
        for method_name, _ in COOKING_METHODS.items():
            # Skip inappropriate combos
            if method_name in ("Tumis",) and protein_name.startswith("Ikan"):
                continue  # Tumis ikan is unusual
            cooked = apply_cooking(nut, method_name)
            name = f"{protein_name} {method_name}"
            add(name, "100 g", *cooked, "base_food", "generated-v2")

    print(f"  Proteins × methods: {len(foods)} foods")

    # Generate vegetables × cooking methods
    veg_count_before = len(foods)
    for veg_name, nut in VEGETABLES.items():
        # Plain/raw
        add(f"{veg_name} Segar", "100 g", *nut, "base_food", "generated-v2")
        # Rebus & Tumis (most common)
        for method in ("Rebus", "Tumis", "Kukus"):
            cooked = apply_cooking(nut, method)
            add(f"{veg_name} {method}", "100 g", *cooked, "base_food", "generated-v2")

        # Soups
        soup_methods = ["Bening", "Santan", "Kuning"]
        base_nut = apply_cooking(nut, "Rebus")
        for sm in soup_methods:
            fat_add = 5.0 if sm == "Santan" else (3.0 if sm == "Kuning" else 0.5)
            cal_add = fat_add * 9
            add(f"Sayur {veg_name} {sm}", "1 mangkok",
                round(base_nut[0] + cal_add, 1), base_nut[1], round(base_nut[2] + fat_add, 1),
                base_nut[3], base_nut[4], base_nut[5], base_nut[6],
                "local_indonesian", "generated-v2")

    print(f"  Vegetables: {len(foods) - veg_count_before} foods")

    # Generate carbs
    carb_count_before = len(foods)
    for carb_name, nut in CARBS.items():
        # Plain
        add(f"{carb_name}", "100 g", *nut, "base_food", "generated-v2")
        # Fried version
        if carb_name.startswith(("Nasi", "Mie", "Kwetiau", "Bihun")):
            fried = apply_cooking(nut, "Goreng")
            base_name = carb_name.split()[0]
            add(f"{carb_name} Goreng", "1 porsi", *fried, "local_indonesian", "generated-v2")
        # Tim/Kukus
        if carb_name.startswith("Nasi"):
            add(f"{carb_name} Tim", "1 porsi",
                round(nut[0]*0.85, 1), nut[1], nut[2], nut[3], nut[4], nut[5], nut[6],
                "base_food", "generated-v2")

    print(f"  Carbs: {len(foods) - carb_count_before} foods")

    # Generate common combo dishes (lauk + nasi)
    combo_count_before = len(foods)
    popular_combos = [
        ("Nasi Putih", "Ayam Goreng", 550, 28, 20, 55, 2, 500, 1.5),
        ("Nasi Putih", "Ayam Bakar", 500, 30, 16, 50, 2, 400, 1.5),
        ("Nasi Putih", "Ikan Goreng", 480, 22, 18, 52, 1, 350, 1.0),
        ("Nasi Putih", "Ikan Bakar", 450, 24, 14, 50, 1, 300, 1.0),
        ("Nasi Putih", "Telur Dadar", 420, 16, 18, 48, 1.5, 350, 0.8),
        ("Nasi Putih", "Tahu Goreng", 380, 12, 18, 48, 1, 250, 1.5),
        ("Nasi Putih", "Tempe Goreng", 400, 15, 19, 48, 1, 250, 2.0),
        ("Nasi Putih", "Ayam Kecap", 500, 29, 17, 52, 7, 600, 1.0),
        ("Nasi Putih", "Ayam Balado", 490, 28, 18, 50, 3, 550, 1.5),
        ("Nasi Putih", "Ayam Penyet", 550, 27, 23, 52, 2, 700, 2.0),
    ]
    for carb, lauk, cal, prot, fat, carbs, sugar, sodium, fiber in popular_combos:
        add(f"{carb} + {lauk}", "1 porsi", cal, prot, fat, carbs, sugar, sodium, fiber,
            "local_indonesian", "generated-v2")

    print(f"  Combos: {len(foods) - combo_count_before} foods")

    # Generate student/common food items
    student_count_before = len(foods)
    student_foods = [
        ("Indomie Goreng Telur", 550, 14, 25, 58, 3, 1400, 2.0),
        ("Indomie Rebus Telur", 500, 14, 20, 55, 3, 1300, 2.0),
        ("Nasi Telur Ceplok Kecap", 380, 14, 15, 45, 5, 500, 0.8),
        ("Nasi Tahu Goreng Sambal", 350, 10, 16, 45, 2, 400, 1.5),
        ("Nasi Tempe Goreng Sambal", 370, 14, 18, 45, 2, 400, 2.0),
        ("Nasi Telur Dadar Sayur", 400, 16, 17, 46, 2, 450, 1.5),
        ("Roti Bakar Coklat", 300, 6, 12, 45, 18, 350, 2.0),
        ("Roti Bakar Keju", 320, 10, 15, 40, 5, 400, 1.5),
        ("Roti Bakar Coklat Keju", 380, 10, 18, 48, 16, 380, 1.5),
        ("Bubur Ayam Komplit", 250, 12, 8, 35, 1, 500, 1.5),
        ("Nasi Kuning Komplit", 450, 15, 20, 50, 3, 600, 2.5),
        ("Lontong Sayur Komplit", 400, 12, 18, 48, 4, 700, 3.0),
        ("Nasi Pecel Komplit", 420, 14, 20, 48, 5, 550, 5.0),
        ("Nasi Campur Sederhana", 480, 16, 22, 52, 3, 750, 3.0),
        ("Nasi Goreng Telur", 420, 12, 18, 50, 2, 650, 1.5),
        ("Nasi Goreng Ayam", 460, 16, 20, 50, 2, 700, 1.5),
        ("Mie Goreng Telur", 480, 14, 22, 55, 3, 1000, 2.0),
        ("Mie Goreng Ayam", 500, 18, 24, 52, 3, 1050, 2.0),
        ("Mie Rebus Telur", 440, 13, 19, 52, 2.5, 950, 1.8),
        ("Nasi Ayam Suwir Sambal", 420, 24, 16, 48, 2, 550, 1.5),
        ("Nasi Ikan Suwir Sambal", 400, 20, 15, 48, 2, 500, 1.5),
        ("Telur Dadar Sayur", 180, 14, 12, 5, 2, 280, 1.5),
        ("Omelet Mie", 350, 12, 18, 35, 2, 600, 1.0),
        ("Telur Balado", 160, 12, 11, 5, 2, 350, 0.5),
        ("Kentang Balado", 180, 3, 10, 22, 3, 350, 2.5),
        ("Kentang Kecap", 170, 3, 8, 24, 5, 400, 2.5),
    ]
    for name, cal, prot, fat, carbs, sugar, sodium, fiber in student_foods:
        add(name, "1 porsi", cal, prot, fat, carbs, sugar, sodium, fiber,
            "local_indonesian", "generated-v2")

    print(f"  Student foods: {len(foods) - student_count_before} foods")

    return foods


if __name__ == "__main__":
    import os
    foods = generate_all()
    df = pd.DataFrame(foods)
    out = os.path.join(os.path.dirname(__file__), "output", "generated_foods_v2.csv")
    df.to_csv(out, index=False)
    print(f"\nTotal generated: {len(foods)} foods")
    print(f"Saved to {out}")
