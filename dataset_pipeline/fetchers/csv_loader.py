"""Load and normalize existing CSV datasets to common schema."""
import pandas as pd
from config import EXISTING_CSVS


COMMON_COLUMNS = [
    "name", "name_id", "serving_size", "calories",
    "protein_g", "carbohydrate_g", "fat_g", "sugar_g",
    "sodium_mg", "fiber_g", "food_type", "source",
]


def _normalize_nilai_gizi(df: pd.DataFrame) -> pd.DataFrame:
    """Normalize nilai-gizi.csv (mixed EN/ID columns)."""
    records = []
    for _, row in df.iterrows():
        name = str(row.get("name", "")).strip()
        if not name or name == "nan":
            continue
        records.append({
            "name": name,
            "name_id": name,
            "serving_size": str(row.get("serving_size", "")).strip() if pd.notna(row.get("serving_size")) else "",
            "calories": float(row.get("energy_kcal", 0) or 0),
            "protein_g": float(row.get("protein_g", 0) or 0),
            "carbohydrate_g": float(row.get("carbohydrate_g", 0) or 0),
            "fat_g": float(row.get("fat_g", 0) or 0),
            "sugar_g": float(row.get("sugar_g", 0) or 0),
            "sodium_mg": float(row.get("sodium_mg", 0) or 0),
            "fiber_g": float(row.get("fiber_g", 0) or 0),
            "food_type": "",
            "source": "nilai-gizi.csv",
        })
    return pd.DataFrame(records, columns=COMMON_COLUMNS)


def _normalize_nutrition(df: pd.DataFrame) -> pd.DataFrame:
    """Normalize nutrition.csv (simple EN dataset)."""
    records = []
    for _, row in df.iterrows():
        name = str(row.get("name", "")).strip()
        if not name or name == "nan":
            continue
        records.append({
            "name": name,
            "name_id": name,
            "serving_size": "",
            "calories": float(row.get("calories", 0) or 0),
            "protein_g": float(row.get("proteins", 0) or 0),
            "carbohydrate_g": float(row.get("carbohydrate", 0) or 0),
            "fat_g": float(row.get("fat", 0) or 0),
            "sugar_g": 0.0,
            "sodium_mg": 0.0,
            "fiber_g": 0.0,
            "food_type": "",
            "source": "nutrition.csv",
        })
    return pd.DataFrame(records, columns=COMMON_COLUMNS)


def _normalize_makanan_lokal(df: pd.DataFrame) -> pd.DataFrame:
    """Normalize makanan-lokal.csv (already Indonesian)."""
    records = []
    for _, row in df.iterrows():
        name = str(row.get("name", "")).strip()
        if not name or name == "nan":
            continue
        records.append({
            "name": name,
            "name_id": name,  # already Indonesian
            "serving_size": str(row.get("serving_size", "")).strip() if pd.notna(row.get("serving_size")) else "",
            "calories": float(row.get("energy_kcal", 0) or 0),
            "protein_g": float(row.get("protein_g", 0) or 0),
            "carbohydrate_g": float(row.get("carbohydrate_g", 0) or 0),
            "fat_g": float(row.get("fat_g", 0) or 0),
            "sugar_g": float(row.get("sugar_g", 0) or 0),
            "sodium_mg": float(row.get("sodium_mg", 0) or 0),
            "fiber_g": float(row.get("fiber_g", 0) or 0),
            "food_type": "local_indonesian",
            "source": "makanan-lokal.csv",
        })
    return pd.DataFrame(records, columns=COMMON_COLUMNS)


def load_existing_csvs() -> pd.DataFrame:
    """Load all existing CSVs and normalize to common schema."""
    frames = []
    normalizers = {
        "nilai-gizi.csv": _normalize_nilai_gizi,
        "nutrition.csv": _normalize_nutrition,
        "makanan-lokal.csv": _normalize_makanan_lokal,
    }

    for path in EXISTING_CSVS:
        try:
            df = pd.read_csv(path)
            filename = path.split("\\")[-1].split("/")[-1]
            normalizer = normalizers.get(filename)
            if normalizer:
                normalized = normalizer(df)
                print(f"  Loaded {filename}: {len(normalized)} foods")
                frames.append(normalized)
        except Exception as e:
            print(f"  WARNING: Could not load {path}: {e}")

    if frames:
        result = pd.concat(frames, ignore_index=True)
        print(f"  Total from CSVs: {len(result)} foods")
        return result
    return pd.DataFrame(columns=COMMON_COLUMNS)
