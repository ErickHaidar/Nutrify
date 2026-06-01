"""USDA FoodData Central API fetcher."""
import time
import requests
from typing import Optional


USDA_BASE = "https://api.nal.usda.gov/fdc/v1"

# Common food search terms relevant to Indonesian diet
SEARCH_TERMS = [
    # Staples
    "rice white cooked", "egg boiled", "chicken breast", "beef",
    "potato boiled", "tofu fried", "tempeh", "fish grilled",
    "shrimp", "squid", "corn boiled", "sweet potato",
    "cassava", "spinach", "water spinach", "broccoli",
    "carrot", "cabbage", "green beans", "bean sprouts",
    # Prepared
    "fried rice", "fried chicken", "omelette", "noodle",
    "soup vegetable", "satay", "curry",
    # Beverages
    "milk whole", "soy milk", "coffee", "tea",
    "yogurt plain",
    # Fruits
    "banana", "papaya", "mango", "orange", "apple",
    "watermelon", "pineapple", "avocado", "guava",
    # Snacks
    "bread white", "cake", "banana fried",
]


def _search_foods(api_key: str, query: str, page_size: int = 10) -> Optional[list]:
    """Search USDA FoodData Central."""
    try:
        resp = requests.get(
            f"{USDA_BASE}/foods/search",
            params={
                "api_key": api_key,
                "query": query,
                "dataType": "Foundation,SR Legacy,Branded",
                "pageSize": page_size,
            },
            timeout=15,
        )
        if resp.status_code == 429:
            print("  USDA rate limit, waiting 60s...")
            time.sleep(60)
            return _search_foods(api_key, query, page_size)
        resp.raise_for_status()
        data = resp.json()
        return data.get("foods", [])
    except Exception as e:
        print(f"  USDA search error for '{query}': {e}")
        return None


def _parse_nutrient(food: dict, nutrient_id: int) -> float:
    """Extract specific nutrient value from USDA food."""
    for n in food.get("foodNutrients", []):
        if n.get("nutrientId") == nutrient_id:
            return float(n.get("value", 0) or 0)
    return 0.0


def _parse_usda_food(food: dict) -> dict:
    """Parse USDA food item to common schema."""
    name = food.get("description", food.get("brandName", "")).strip()
    if not name:
        # Try branded name
        brand = food.get("brandOwner", "")
        desc = food.get("description", "")
        name = f"{brand} {desc}".strip()

    # Serving size
    serving_size = ""
    portions = food.get("foodPortions", [])
    if portions:
        p = portions[0]
        amount = p.get("gramWeight", p.get("amount", ""))
        unit = p.get("modifier", "")
        if amount and unit:
            serving_size = f"{amount} {unit}"
        elif amount:
            serving_size = f"{amount}g"

    return {
        "name": name,
        "name_id": "",
        "serving_size": serving_size,
        "calories": _parse_nutrient(food, 1008),       # Energy (kcal)
        "protein_g": _parse_nutrient(food, 1003),       # Protein
        "carbohydrate_g": _parse_nutrient(food, 1005),  # Carbs
        "fat_g": _parse_nutrient(food, 1004),           # Total fat
        "sugar_g": _parse_nutrient(food, 2000),         # Sugars
        "sodium_mg": _parse_nutrient(food, 1093),       # Sodium
        "fiber_g": _parse_nutrient(food, 1079),         # Fiber
        "food_type": "",
        "source": "usda",
    }


def fetch_usda(api_key: str, max_per_search: int = 10) -> list[dict]:
    """Fetch foods from USDA FoodData Central."""
    if not api_key or api_key == "DEMO_KEY":
        print("  USDA: Using DEMO_KEY (limited to 30 req/hour).")
        print("  Get free API key at: https://fdc.nal.usda.gov/api-key-signup.html")

    all_foods = {}
    for query in SEARCH_TERMS:
        print(f"  USDA search: '{query}'")
        foods = _search_foods(api_key, query, max_per_search)
        if not foods:
            continue

        for food in foods:
            fdc_id = food.get("fdcId")
            if fdc_id and fdc_id not in all_foods:
                all_foods[fdc_id] = _parse_usda_food(food)

        time.sleep(0.35)  # Rate limit: 3 req/s

    foods = list(all_foods.values())
    print(f"  USDA total: {len(foods)} foods")
    return foods
