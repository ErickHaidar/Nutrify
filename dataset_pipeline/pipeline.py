"""
Main dataset pipeline orchestration.

Flow:
1. Load existing CSVs (nilai-gizi.csv, nutrition.csv, makanan-lokal.csv)
2. Fetch from FatSecret API (OAuth 2.0)
3. Fetch from USDA FoodData Central
4. Download Kaggle datasets
5. Merge all sources → normalize schema
6. AI translate non-Indonesian names → Indonesian
7. AI deduplicate across languages
8. Rule-based classification (base_food, local_indonesian, etc.)
9. Nutrition validation
10. Export clean CSV
"""
import json
import os
import sys
import pandas as pd

from config import (
    ANTHROPIC_API_KEY, FINAL_OUTPUT, OUTPUT_DIR,
    FATSECRET_CLIENT_ID, FATSECRET_CLIENT_SECRET,
    USDA_API_KEY,
)

os.makedirs(OUTPUT_DIR, exist_ok=True)


def _needs_translation(row: pd.Series) -> bool:
    """Check if food name needs Indonesian translation."""
    name = str(row.get("name_id", "") or row.get("name", ""))
    if not name:
        return True

    # Already Indonesian? Check for Indonesian words/patterns
    id_markers = [
        # Common Indonesian food words
        "nasi", "ayam", "ikan", "telur", "tahu", "tempe", "susu",
        "goreng", "rebus", "bakar", "kukus", "sambal", "sayur",
        "kentang", "ubi", "pisang", "air", "kopi", "teh",
        "bubur", "soto", "rendang", "sate", "bakso", "gado",
        "mie", "kuah", "tumis", "cah ", "pepes", "opor", "gulai",
        "buncis", "jagung", "singkong", "daun", "kacang",
        "kangkung", "bayam", "wortel", "kol", "sawi", "tomat",
        "mentimun", "bihun", "ketan", "lontong", "ketupat",
        "semur", "balado", "rica", "lodeh", "asem", "urap",
        "daging", "udang", "cumi", "kepiting", "bandeng",
        "lele", "muja", "nila", "gurame", "bawal", "tongkol",
        "kembung", "teri", "cakalang", "tenggiri", "kakap",
        "kerupuk", "keripik", "kripik", "cireng", "cilok",
        "siomay", "batagor", "pempek", "geprek", "penyet",
        "manis", "asin", "pedas", "kecap", "terasi", "petis",
        "kemiri", "kunyit", "jahe", "laos", "serai", "salam",
        "kelapa", "santan", "kukus", "tim ", "pepes",
        # Indonesian verbs/descriptors common in food names
        "segar", "mentah", "matang", "kering", "basah", "iris",
        "cincang", "giling", "tumbuk", "parut", "potong",
        "bubuk", "cair", "kental", "encer", "padat",
        # Common Indonesian food prefixes/suffixes
        "berkuah", "bersantan", "berbumbu", "dikukus", "direbus",
        "panggang", "santan", "bumbu", "olahan", "masakan",
        "lauk", "sayuran", "buahan", "kue ", "roti ",
        "minuman", "makanan", "cemilan", "sarapan",
        # Generic Indonesian words in food
        "putih", "merah", "hijau", "kuning", "hitam",
    ]
    name_lower = name.lower()
    for p in id_markers:
        if p in name_lower:
            return False
    # If name has no spaces and is short, probably not Indonesian food
    # (e.g., "Apple", "Banana", "Rice")
    if " " not in name_lower and len(name_lower) <= 15:
        return True
    # If name contains common English food words not found in Indonesian
    en_only = ["boiled", "steamed", "grilled", "fried", "roasted",
               "baked", "sliced", "diced", "mashed", "whipped",
               "smoked", "pickled", "dried", "canned", "frozen",
               "fresh", "raw", "cooked", "braised", "broiled",
               "poached", "scrambled", "toasted", "breaded",
               "breakfast", "lunch", "dinner", "snack", "dessert"]
    for p in en_only:
        if p in name_lower:
            return True
    return False


def step1_load_csvs():
    """Step 1: Load existing CSV datasets."""
    print("\n" + "=" * 60)
    print("STEP 1: Loading existing CSVs")
    print("=" * 60)
    from fetchers.csv_loader import load_existing_csvs
    df = load_existing_csvs()
    print(f"  -> {len(df)} foods from CSVs")
    return df


def step2_fetch_apis():
    """Step 2: Fetch from external APIs."""
    print("\n" + "=" * 60)
    print("STEP 2: Fetching from external APIs")
    print("=" * 60)

    all_foods = []

    # FatSecret
    if FATSECRET_CLIENT_ID:
        print("\n  [FatSecret API]")
        from fetchers.fatsecret_fetcher import fetch_fatsecret
        foods = fetch_fatsecret(FATSECRET_CLIENT_ID, FATSECRET_CLIENT_SECRET)
        all_foods.extend(foods)
        print(f"  -> {len(foods)} foods from FatSecret")
    else:
        print("\n  [FatSecret] Skipped (no credentials)")

    # USDA
    print("\n  [USDA FoodData Central]")
    from fetchers.usda_fetcher import fetch_usda
    usda_foods = fetch_usda(USDA_API_KEY)
    all_foods.extend(usda_foods)
    print(f"  -> {len(usda_foods)} foods from USDA")

    # Kaggle
    print("\n  [Kaggle Datasets]")
    from fetchers.kaggle_fetcher import fetch_kaggle_datasets
    kaggle_foods = fetch_kaggle_datasets()
    all_foods.extend(kaggle_foods)
    print(f"  -> {len(kaggle_foods)} foods from Kaggle")

    # Open Food Facts
    print("\n  [Open Food Facts]")
    from fetchers.openfoodfacts_fetcher import fetch_openfoodfacts
    off_foods = fetch_openfoodfacts()
    all_foods.extend(off_foods)
    print(f"  -> {len(off_foods)} foods from Open Food Facts")

    columns = [
        "name", "name_id", "serving_size", "calories",
        "protein_g", "carbohydrate_g", "fat_g", "sugar_g",
        "sodium_mg", "fiber_g", "food_type", "source",
    ]
    df = pd.DataFrame(all_foods, columns=columns) if all_foods else pd.DataFrame(columns=columns)
    print(f"\n  Total from APIs: {len(df)} foods")
    return df


def step3_merge(df_csv: pd.DataFrame, df_api: pd.DataFrame) -> pd.DataFrame:
    """Step 3: Merge CSV and API data."""
    print("\n" + "=" * 60)
    print("STEP 3: Merging all sources")
    print("=" * 60)

    if df_csv.empty and df_api.empty:
        print("  ERROR: No data from any source!")
        sys.exit(1)

    merged = pd.concat([df_csv, df_api], ignore_index=True)

    # Fill empty name_id with name
    merged["name_id"] = merged.apply(
        lambda r: r["name"] if pd.isna(r["name_id"]) or str(r["name_id"]).strip() == "" else r["name_id"],
        axis=1,
    )

    # Drop rows without name
    merged = merged[merged["name"].notna() & (merged["name"] != "")]

    # Drop exact duplicates on name
    before = len(merged)
    merged = merged.drop_duplicates(subset=["name"], keep="first")
    print(f"  Removed {before - len(merged)} exact name duplicates")
    print(f"  -> {len(merged)} unique foods after merge")
    return merged


def step4_translate(df: pd.DataFrame) -> pd.DataFrame:
    """Step 4: AI translate non-Indonesian names."""
    print("\n" + "=" * 60)
    print("STEP 4: Translating to Indonesian")
    print("=" * 60)

    from ai_processor import translate_foods

    # Identify foods needing translation
    needs_trans = df[df.apply(_needs_translation, axis=1)]
    already_id = df[~df.apply(_needs_translation, axis=1)]

    print(f"  Need translation: {len(needs_trans)} foods")
    print(f"  Already Indonesian: {len(already_id)} foods")

    if len(needs_trans) > 0:
        foods_list = needs_trans.to_dict("records")
        translated = translate_foods(foods_list)
        translated_df = pd.DataFrame(translated)
        result = pd.concat([already_id, translated_df], ignore_index=True)
    else:
        result = already_id

    print(f"  -> {len(result)} foods after translation")
    return result


def step5_deduplicate(df: pd.DataFrame) -> pd.DataFrame:
    """Step 5: AI cross-language deduplication."""
    print("\n" + "=" * 60)
    print("STEP 5: Cross-language deduplication")
    print("=" * 60)

    from ai_processor import deduplicate_cross_language

    before = len(df)
    foods_list = df.to_dict("records")
    deduped = deduplicate_cross_language(foods_list)
    result = pd.DataFrame(deduped)

    print(f"  Removed {before - len(result)} duplicates")
    print(f"  -> {len(result)} foods after dedup")
    return result


def step6_classify(df: pd.DataFrame) -> pd.DataFrame:
    """Step 6: Classify food types."""
    print("\n" + "=" * 60)
    print("STEP 6: Classifying food types")
    print("=" * 60)

    from ai_processor import classify_food_type

    df["food_type"] = df["name_id"].apply(
        lambda n: classify_food_type(str(n)) if pd.notna(n) else "other"
    )

    counts = df["food_type"].value_counts()
    for ft, c in counts.items():
        print(f"  {ft}: {c}")

    print(f"  -> {len(df)} foods classified")
    return df


def step7_validate(df: pd.DataFrame) -> pd.DataFrame:
    """Step 7: Validate nutrition data."""
    print("\n" + "=" * 60)
    print("STEP 7: Validating nutrition data")
    print("=" * 60)

    from ai_processor import validate_nutrition

    df["is_valid"] = df.apply(validate_nutrition, axis=1)
    valid = df[df["is_valid"]].copy()
    invalid = df[~df["is_valid"]]

    print(f"  Valid: {len(valid)} foods")
    print(f"  Invalid (filtered): {len(invalid)} foods")
    if len(invalid) > 0:
        print(f"  Invalid examples: {invalid['name'].head(5).tolist()}")

    valid = valid.drop(columns=["is_valid"])
    print(f"  -> {len(valid)} valid foods")
    return valid


def step8_export(df: pd.DataFrame):
    """Step 8: Export final clean CSV."""
    print("\n" + "=" * 60)
    print("STEP 8: Exporting final dataset")
    print("=" * 60)

    # Sort by food_type priority
    priority_order = {
        "base_food": 0,
        "local_indonesian": 1,
        "beverage": 2,
        "snack": 3,
        "other": 4,
    }
    df["_sort"] = df["food_type"].map(priority_order).fillna(5)
    df = df.sort_values(["_sort", "name_id"]).drop(columns=["_sort"])

    # Final columns for output
    output_cols = [
        "name_id", "name", "serving_size", "calories",
        "protein_g", "carbohydrate_g", "fat_g", "sugar_g",
        "sodium_mg", "fiber_g", "food_type", "source",
    ]

    df[output_cols].to_csv(FINAL_OUTPUT, index=False)
    print(f"  Exported {len(df)} foods to: {FINAL_OUTPUT}")

    # Also export JSON for Laravel import
    json_path = FINAL_OUTPUT.replace(".csv", ".json")
    df[output_cols].to_json(json_path, orient="records", force_ascii=False, indent=2)
    print(f"  Exported JSON to: {json_path}")

    # Summary
    print(f"\n{'=' * 60}")
    print(f"PIPELINE COMPLETE")
    print(f"{'=' * 60}")
    print(f"Total foods: {len(df)}")
    print(f"Base foods: {len(df[df['food_type'] == 'base_food'])}")
    print(f"Local Indonesian: {len(df[df['food_type'] == 'local_indonesian'])}")
    print(f"Beverages: {len(df[df['food_type'] == 'beverage'])}")
    print(f"Snacks: {len(df[df['food_type'] == 'snack'])}")
    print(f"Other: {len(df[df['food_type'] == 'other'])}")

    # Nutrition coverage
    has_cal = (df["calories"] > 0).sum()
    has_protein = (df["protein_g"] > 0).sum()
    has_carbs = (df["carbohydrate_g"] > 0).sum()
    has_fat = (df["fat_g"] > 0).sum()
    print(f"\nNutrition coverage:")
    print(f"  Calories: {has_cal}/{len(df)} ({100*has_cal//max(1,len(df))}%)")
    print(f"  Protein: {has_protein}/{len(df)} ({100*has_protein//max(1,len(df))}%)")
    print(f"  Carbs: {has_carbs}/{len(df)} ({100*has_carbs//max(1,len(df))}%)")
    print(f"  Fat: {has_fat}/{len(df)} ({100*has_fat//max(1,len(df))}%)")


def run_pipeline(skip_translate: bool = False, skip_dedup: bool = False,
                 skip_apis: bool = False):
    """Run the full pipeline."""
    print("=" * 60)
    print("NUTRIFY FOOD DATASET PIPELINE")
    print("=" * 60)

    # Step 1: Load CSVs
    df_csv = step1_load_csvs()

    # Step 2: Fetch APIs
    if not skip_apis:
        df_api = step2_fetch_apis()
    else:
        print("\n  [APIs] Skipped")
        df_api = None

    # Step 3: Merge
    if df_api is not None and not df_api.empty:
        df = step3_merge(df_csv, df_api)
    else:
        df = df_csv
        print(f"\n  -> Using CSV data only: {len(df)} foods")

    # Step 4: Translate
    if not skip_translate:
        df = step4_translate(df)
    else:
        print("\n  [TRANSLATE] Skipped")

    # Step 5: Deduplicate
    if not skip_dedup:
        df = step5_deduplicate(df)
    else:
        print("\n  [DEDUP] Skipped")

    # Step 6: Classify
    df = step6_classify(df)

    # Step 7: Validate
    df = step7_validate(df)

    # Step 8: Export
    step8_export(df)

    return df


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Nutrify Food Dataset Pipeline")
    parser.add_argument("--skip-apis", action="store_true",
                        help="Skip external API fetching")
    parser.add_argument("--skip-translate", action="store_true",
                        help="Skip AI translation step")
    parser.add_argument("--skip-dedup", action="store_true",
                        help="Skip AI deduplication step")
    args = parser.parse_args()
    run_pipeline(skip_translate=args.skip_translate, skip_dedup=args.skip_dedup,
                 skip_apis=args.skip_apis)
