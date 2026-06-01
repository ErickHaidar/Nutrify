"""Open Food Facts API fetcher — free, no auth required."""
import time
import requests
from typing import Optional


OFF_BASE = "https://world.openfoodfacts.org"

# Indonesian food categories and common searches
INDONESIAN_CATEGORIES = [
    # Indonesian-specific categories
    "indonesian", "indonesian-main-dishes", "indonesian-snacks",
    "indonesian-soups", "indonesian-desserts", "indonesian-beverages",
    # General categories with high Indonesian coverage
    "rice-dishes", "noodles", "soups", "poultry-dishes",
    "fish-dishes", "vegetable-dishes", "eggs-dishes",
    "fruit-based-foods", "cereal-products", "legumes",
    "beverages", "milk-products", "snacks",
    "sauces-condiments", "breads", "pastries",
]

# Direct text searches for Indonesian foods
SEARCH_TERMS = [
    # Categories
    "nasi", "mie", "soto", "bakso", "rendang", "sate", "gado",
    "tempe", "tahu", "goreng", "sambal", "kecap", "kerupuk",
    "bubur", "lontong", "ketupat", "opor", "gulai", "pepes",
    "santan", "ubi", "singkong", "pisang goreng", "kue basah",
    "cendol", "dawet", "kolak", "es campur",
    # Protein sources
    "ayam goreng", "ikan bakar", "telur dadar", "udang", "cumi",
    # Staples
    "beras", "jagung", "kentang", "ketela",
    # Vegetables
    "kangkung", "bayam", "sawi", "brokoli", "wortel",
    # Fruits
    "pisang", "pepaya", "mangga", "nanas", "durian", "rambutan",
    # English (for cross-language coverage)
    "fried rice", "fried noodle", "meatball soup", "chicken porridge",
    "coconut rice", "peanut sauce", "sweet soy",
]

# Nutrition mapping: OFF nutrient names → common schema
NUTRIENT_MAP = {
    "energy-kcal_100g": "calories",
    "energy-kcal_serving": "calories",
    "proteins_100g": "protein",
    "carbohydrates_100g": "carbs",
    "fat_100g": "fat",
    "sugars_100g": "sugar",
    "salt_100g": "salt",
    "fiber_100g": "fiber",
}


def _search_off(query: str, page_size: int = 50, page: int = 1) -> Optional[list]:
    """Search Open Food Facts."""
    try:
        resp = requests.get(
            f"{OFF_BASE}/cgi/search.pl",
            params={
                "search_terms": query,
                "search_simple": 1,
                "json": 1,
                "page_size": page_size,
                "page": page,
                "action": "process",
                "sort_by": "unique_scans_n",
            },
            headers={"User-Agent": "Nutrify/1.0 (dataset pipeline; nutrify@example.com)"},
            timeout=15,
        )
        resp.raise_for_status()
        data = resp.json()
        return data.get("products", [])
    except Exception as e:
        print(f"    OFF search error '{query}': {e}")
        return None


def _search_off_by_category(category: str, page_size: int = 50) -> Optional[list]:
    """Search by category tag."""
    try:
        resp = requests.get(
            f"{OFF_BASE}/category/{category}.json",
            params={"page_size": page_size, "json": 1},
            headers={"User-Agent": "Nutrify/1.0 (dataset pipeline)"},
            timeout=15,
        )
        resp.raise_for_status()
        data = resp.json()
        return data.get("products", [])
    except Exception as e:
        print(f"    OFF category error '{category}': {e}")
        return None


def _parse_off_product(product: dict) -> Optional[dict]:
    """Parse Open Food Facts product to common schema."""
    name = product.get("product_name", "").strip()
    if not name or len(name) < 2:
        # Try generic name
        name = product.get("generic_name", "").strip()
    if not name or len(name) < 2:
        return None

    nutriments = product.get("nutriments", {})

    # Get calories
    cal = float(nutriments.get("energy-kcal_100g", 0) or 0)
    if cal <= 0:
        cal = float(nutriments.get("energy-kcal_serving", 0) or 0)

    # Get serving size
    serving_size = ""
    serving_qty = product.get("serving_quantity", "")
    serving_unit = product.get("serving_size", "")
    if serving_qty and serving_unit:
        serving_size = f"{serving_qty} {serving_unit}"
    elif serving_unit:
        serving_size = str(serving_unit)

    return {
        "name": name,
        "name_id": "",
        "serving_size": serving_size,
        "calories": cal,
        "protein_g": float(nutriments.get("proteins_100g", 0) or 0),
        "carbohydrate_g": float(nutriments.get("carbohydrates_100g", 0) or 0),
        "fat_g": float(nutriments.get("fat_100g", 0) or 0),
        "sugar_g": float(nutriments.get("sugars_100g", 0) or 0),
        "sodium_mg": float(nutriments.get("salt_100g", 0) or 0) * 400,  # salt → sodium approx
        "fiber_g": float(nutriments.get("fiber_100g", 0) or 0),
        "food_type": "",
        "source": "openfoodfacts",
    }


def fetch_openfoodfacts(max_per_search: int = 50, max_per_category: int = 100) -> list[dict]:
    """Fetch foods from Open Food Facts by searching and categories."""
    all_foods = {}
    seen_names = set()

    # Search by Indonesian terms
    print("  Searching by terms...")
    for query in SEARCH_TERMS:
        for page in [1, 2]:  # Get first 2 pages
            products = _search_off(query, page_size=max_per_search, page=page)
            if not products:
                break
            for p in products:
                food = _parse_off_product(p)
                if food and food["name"].lower() not in seen_names:
                    seen_names.add(food["name"].lower())
                    all_foods[len(all_foods)] = food
            time.sleep(0.15)  # Rate limit: ~6 req/s

    print(f"    Got {len(all_foods)} from search")

    # Search by Indonesian categories
    print("  Searching by categories...")
    for cat in INDONESIAN_CATEGORIES:
        products = _search_off_by_category(cat, page_size=max_per_category)
        if not products:
            continue
        for p in products:
            food = _parse_off_product(p)
            if food and food["name"].lower() not in seen_names:
                seen_names.add(food["name"].lower())
                all_foods[len(all_foods)] = food
        time.sleep(0.15)
        print(f"    Category '{cat}': +{len(all_foods)} total")

    foods = list(all_foods.values())
    print(f"  Open Food Facts total: {len(foods)} foods")
    return foods
