"""FatSecret Platform API v3 fetcher using OAuth 2.0."""
import time
import requests
from typing import Optional


FATSECRET_TOKEN_URL = "https://oauth.fatsecret.com/connect/token"
FATSECRET_API_URL = "https://platform.fatsecret.com/rest/server.api"

# FatSecret food category IDs for common/base foods
CATEGORIES = {
    "dairy_eggs": 1,
    "meat_poultry": 2,
    "seafood": 3,
    "vegetables": 4,
    "fruits": 5,
    "grains_pasta": 6,
    "nuts_seeds": 7,
    "beverages": 8,
    "prepared_meals": 9,
}

COMMON_SEARCHES = [
    # Base foods — critical
    "egg", "chicken breast", "beef", "rice", "potato", "tofu",
    "tempeh", "fish", "shrimp", "squid", "corn", "sweet potato",
    "cassava", "spinach", "kangkung", "broccoli", "carrot",
    "cabbage", "green beans", "bean sprouts",
    # Prepared — Indonesian common
    "fried rice", "fried chicken", "soup", "porridge", "omelette",
    "fried noodle", "meatball", "satay", "curry", "rendang",
    # Beverages
    "milk", "soy milk", "coffee", "tea", "yogurt",
    # Snacks
    "bread", "cake", "biscuit", "fried banana", "spring roll",
    # Fruits
    "banana", "papaya", "mango", "orange", "apple", "watermelon",
    "pineapple", "avocado", "guava", "star fruit",
]


def _get_token(client_id: str, client_secret: str) -> Optional[str]:
    """Get OAuth 2.0 access token."""
    try:
        resp = requests.post(
            FATSECRET_TOKEN_URL,
            data={"grant_type": "client_credentials", "scope": "basic"},
            auth=(client_id, client_secret),
            headers={"Content-Type": "application/x-www-form-urlencoded"},
            timeout=15,
        )
        resp.raise_for_status()
        data = resp.json()
        return data.get("access_token")
    except Exception as e:
        print(f"  ERROR getting FatSecret token: {e}")
        return None


def _api_call(token: str, method: str, params: dict) -> Optional[dict]:
    """Make FatSecret API call."""
    params["method"] = method
    params["format"] = "json"
    try:
        resp = requests.get(
            FATSECRET_API_URL,
            params=params,
            headers={"Authorization": f"Bearer {token}"},
            timeout=15,
        )
        if resp.status_code == 429:
            print("  FatSecret rate limit, waiting 60s...")
            time.sleep(60)
            return _api_call(token, method, params)
        resp.raise_for_status()
        return resp.json()
    except Exception as e:
        print(f"  FatSecret API error ({method}): {e}")
        return None


def _parse_food_item(item: dict) -> dict:
    """Parse FatSecret food item to common schema."""
    servings = item.get("servings", {}).get("serving", [])
    if isinstance(servings, dict):
        servings = [servings]

    # Pick metric serving if available
    serving = servings[0] if servings else {}
    for s in servings:
        if s.get("metric_serving_unit") == "g":
            serving = s
            break

    cal = float(serving.get("calories", 0) or 0)
    protein = float(serving.get("protein", 0) or 0)
    carbs = float(serving.get("carbohydrate", 0) or 0)
    fat = float(serving.get("fat", 0) or 0)

    desc = item.get("food_description", "")
    serving_size = serving.get("metric_serving_amount", "")
    if serving_size:
        serving_size = f"{serving_size} {serving.get('metric_serving_unit', 'g')}"

    return {
        "name": item.get("food_name", "").strip(),
        "name_id": "",
        "serving_size": serving_size,
        "calories": cal,
        "protein_g": protein,
        "carbohydrate_g": carbs,
        "fat_g": fat,
        "sugar_g": float(serving.get("sugar", 0) or 0),
        "sodium_mg": float(serving.get("sodium", 0) or 0),
        "fiber_g": float(serving.get("fiber", 0) or 0),
        "food_type": "",
        "source": "fatsecret",
    }


def fetch_fatsecret(client_id: str, client_secret: str,
                    max_per_search: int = 50) -> list[dict]:
    """Fetch foods from FatSecret API by searching common terms."""
    token = _get_token(client_id, client_secret)
    if not token:
        print("  FatSecret: No token, skipping.")
        return []

    all_foods = {}
    for query in COMMON_SEARCHES:
        print(f"  FatSecret search: '{query}'")
        params = {
            "search_expression": query,
            "max_results": min(max_per_search, 50),
            "page_number": 0,
        }
        data = _api_call(token, "foods.search", params)
        if not data:
            continue

        foods_list = data.get("foods", {}).get("food", [])
        if isinstance(foods_list, dict):
            foods_list = [foods_list]

        for item in foods_list:
            food_id = item.get("food_id")
            if food_id and food_id not in all_foods:
                # Get detailed food info
                detail = _api_call(token, "food.get.v4", {"food_id": food_id})
                if detail:
                    food_item = detail.get("food", item)
                    all_foods[food_id] = _parse_food_item(food_item)
                else:
                    all_foods[food_id] = _parse_food_item(item)

        time.sleep(0.5)  # Rate limit: 2 req/s

    foods = list(all_foods.values())
    print(f"  FatSecret total: {len(foods)} foods")
    return foods
