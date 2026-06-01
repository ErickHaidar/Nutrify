"""Kaggle dataset downloader for food nutrition datasets."""
import os
import requests
import zipfile
import io
import pandas as pd
from config import OUTPUT_DIR


# Public Kaggle dataset URLs (direct download via raw GitHub or Kaggle public API)
KAGGLE_DATASETS = [
    {
        "name": "nutrition-facts-for-common-foods",
        "url": "https://raw.githubusercontent.com/iridagraphy/nutrition-facts-dataset/main/nutrition_facts.csv",
        "columns": {"name": "name", "calories": "calories"},
    },
]


def fetch_kaggle_datasets() -> list[dict]:
    """Download and parse Kaggle food datasets."""
    foods = []

    for ds in KAGGLE_DATASETS:
        try:
            print(f"  Kaggle: fetching {ds['name']}...")
            resp = requests.get(ds["url"], timeout=30)
            resp.raise_for_status()
            df = pd.read_csv(io.StringIO(resp.text))
            print(f"  Kaggle {ds['name']}: {len(df)} rows, columns: {list(df.columns)}")

            for _, row in df.iterrows():
                name = str(row.get("name", row.get("food", row.get("item", "")))).strip()
                if not name or name == "nan":
                    continue

                food = {
                    "name": name,
                    "name_id": "",
                    "serving_size": str(row.get("serving_size", row.get("serving", ""))).strip(),
                    "calories": float(row.get("calories", row.get("energy_kcal", 0)) or 0),
                    "protein_g": float(row.get("protein", row.get("protein_g", 0)) or 0),
                    "carbohydrate_g": float(row.get("carbohydrate", row.get("carbs", row.get("carbohydrate_g", 0))) or 0),
                    "fat_g": float(row.get("fat", row.get("total_fat", row.get("fat_g", 0))) or 0),
                    "sugar_g": float(row.get("sugar", row.get("sugars", row.get("sugar_g", 0))) or 0),
                    "sodium_mg": float(row.get("sodium", row.get("sodium_mg", 0)) or 0),
                    "fiber_g": float(row.get("fiber", row.get("fiber_g", 0)) or 0),
                    "food_type": "",
                    "source": f"kaggle:{ds['name']}",
                }
                if food["calories"] > 0:
                    foods.append(food)
        except Exception as e:
            print(f"  Kaggle WARNING {ds['name']}: {e}")

    print(f"  Kaggle total: {len(foods)} foods")
    return foods
