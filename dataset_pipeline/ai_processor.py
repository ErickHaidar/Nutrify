"""
AI-powered food dataset processor.
Handles: translation → Indonesian, cross-language dedup, base food identification, validation.
"""
import json
import hashlib
import os
import time
from typing import Optional

import pandas as pd
from anthropic import Anthropic

from config import (
    ANTHROPIC_API_KEY, ANTHROPIC_BASE_URL, AI_MODEL,
    BATCH_SIZE, MAX_RETRIES, CACHE_DIR
)

client = Anthropic(
    api_key=ANTHROPIC_API_KEY,
    base_url=ANTHROPIC_BASE_URL,
)

os.makedirs(CACHE_DIR, exist_ok=True)


def _cache_key(prefix: str, data: str) -> str:
    h = hashlib.sha256(data.encode()).hexdigest()[:16]
    return os.path.join(CACHE_DIR, f"{prefix}_{h}.json")


def _cache_get(prefix: str, data: str) -> Optional[dict]:
    path = _cache_key(prefix, data)
    if os.path.exists(path):
        with open(path, "r", encoding="utf-8") as f:
            return json.load(f)
    return None


def _cache_set(prefix: str, data: str, result: dict):
    path = _cache_key(prefix, data)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(result, f, ensure_ascii=False, indent=2)


def _call_ai(prompt: str, max_tokens: int = 4096) -> str:
    """Call DeepSeek API via Anthropic-compatible endpoint with retry."""
    for attempt in range(MAX_RETRIES):
        try:
            response = client.messages.create(
                model=AI_MODEL,
                max_tokens=max_tokens,
                messages=[{"role": "user", "content": prompt}],
                temperature=0.1,
            )
            for block in response.content:
                t = getattr(block, "type", "")
                if t == "text":
                    return block.text
                if t == "thinking":
                    return block.thinking
            # Fallback
            return str(response.content[-1])
        except Exception as e:
            if attempt == MAX_RETRIES - 1:
                raise
            wait = 2 ** attempt
            print(f"  Retry {attempt + 1}/{MAX_RETRIES} in {wait}s: {e}")
            time.sleep(wait)
    raise RuntimeError("AI call failed after retries")


def translate_foods(foods: list[dict]) -> list[dict]:
    """
    Translate food names to Indonesian. Batch process.
    Input: [{"name": "Boiled Egg", "serving_size": "1 item (50g)", ...}, ...]
    Output: same structure with Indonesian names.
    """
    if not foods:
        return foods

    results = []
    for i in range(0, len(foods), BATCH_SIZE):
        batch = foods[i:i + BATCH_SIZE]

        # Check cache for entire batch
        batch_key = json.dumps(batch, sort_keys=True, ensure_ascii=False)
        cached = _cache_get("translate", batch_key)
        if cached:
            results.extend(cached)
            continue

        names = [f["name"] for f in batch]
        names_list = "\n".join(f"{j+1}. {n}" for j, n in enumerate(names))

        prompt = f"""Kamu adalah ahli gizi dan penerjemah bahasa Indonesia.
Terjemahkan nama makanan berikut ke Bahasa Indonesia yang BAKU dan ALAMI.
Aturan PENTING:
1. Nama harus dalam Bahasa Indonesia (kecuali nama brand internasional)
2. Gunakan nama yang UMUM digunakan sehari-hari di Indonesia
3. Contoh yang benar:
   - "Boiled Egg" → "Telur Rebus"
   - "Steamed Rice" → "Nasi Putih"
   - "Fried Chicken" → "Ayam Goreng"
   - "French Fries" → "Kentang Goreng"
   - "Steamed Potato" → "Kentang Rebus"
   - "Grilled Fish" → "Ikan Bakar"
   - "Soy Milk" → "Susu Kedelai"
   - "Fried Banana" → "Pisang Goreng"
   - "Stir-fried Water Spinach" → "Cah Kangkung"
   - "Ice Tea" → "Es Teh"
   - "Omelette" → "Telur Dadar"
   - "White Bread" → "Roti Tawar"
   - "Fried Tempeh" → "Tempe Goreng"
   - "Fried Tofu" → "Tahu Goreng"

4. Jangan tambahkan keterangan dalam kurung
5. Jangan ubah nama yang SUDAH dalam Bahasa Indonesia

Daftar nama makanan:
{names_list}

Output HANYA dalam format JSON array persis seperti ini (tanpa teks lain):
[{{"index": 1, "name_id": "Telur Rebus"}}, {{"index": 2, "name_id": "Nasi Putih"}}, ...]"""

        print(f"  Translating batch {i//BATCH_SIZE + 1} ({len(batch)} items)...")
        response = _call_ai(prompt, max_tokens=2048)

        try:
            # Extract JSON from response
            response = response.strip()
            if response.startswith("```"):
                response = response.split("\n", 1)[1]
                if response.endswith("```"):
                    response = response[:-3]
            translations = json.loads(response)
        except json.JSONDecodeError:
            print(f"  ERROR parsing AI response: {response[:200]}")
            # Fallback: keep original names
            translations = [{"index": j+1, "name_id": n} for j, n in enumerate(names)]

        idx_map = {t["index"]: t["name_id"] for t in translations}
        batch_result = []
        for j, food in enumerate(batch):
            food_copy = dict(food)
            food_copy["name_id"] = idx_map.get(j + 1, food["name"])
            batch_result.append(food_copy)

        _cache_set("translate", batch_key, batch_result)
        results.extend(batch_result)

    return results


def deduplicate_cross_language(foods: list[dict]) -> list[dict]:
    """
    AI-powered cross-language deduplication.
    Detects: "Telur Rebus" == "Boiled Egg" == "ゆで卵" == "Oeuf Dur"
    Keeps the Indonesian version, merges metadata.
    """
    if len(foods) < 2:
        return foods

    results = []
    for i in range(0, len(foods), BATCH_SIZE * 2):
        batch = foods[i:i + BATCH_SIZE * 2]

        batch_key = json.dumps(batch, sort_keys=True, ensure_ascii=False)
        cached = _cache_get("dedup", batch_key)
        if cached:
            results.extend(cached)
            continue

        foods_text = "\n".join(
            f"{j+1}. {f.get('name_id', f.get('name', ''))} | "
            f"original: {f.get('name', '')} | "
            f"kalori: {f.get('calories', '?')} | "
            f"protein: {f.get('protein', '?')}g"
            for j, f in enumerate(batch)
        )

        prompt = f"""Kamu adalah ahli database makanan. Deteksi DUPLIKAT dalam daftar makanan ini.
DUPLIKAT = makanan yang SAMA meski beda bahasa/beda ejaan.

Contoh DUPLIKAT:
- "Telur Rebus" = "Boiled Egg" = "Hard Boiled Egg" → gabung jadi "Telur Rebus"
- "Nasi Putih" = "Steamed Rice" = "Cooked Rice" = "White Rice" → gabung jadi "Nasi Putih"
- "Ayam Goreng" = "Fried Chicken" = "Southern Fried Chicken" → gabung jadi "Ayam Goreng"
- "Susu Kedelai" = "Soy Milk" = "Soya Milk" → gabung jadi "Susu Kedelai"

Yang BUKAN duplikat:
- "Ayam Goreng" vs "Ayam Bakar" → BEDA (metode masak beda)
- "Nasi Putih" vs "Nasi Goreng" → BEDA
- "Telur Rebus" vs "Telur Dadar" → BEDA
- "Susu Sapi" vs "Susu Kedelai" → BEDA (sumber beda)

Aturan:
1. PRIORITASKAN nama Bahasa Indonesia jika ada duplikat
2. Jika tidak ada nama Indonesia, gunakan nama paling umum/baku
3. Ambil data nutrisi dari yang PALING LENGKAP
4. Jangan gabung makanan yang JELAS BERBEDA

Daftar makanan:
{foods_text}

Output HANYA dalam format JSON array (tanpa teks lain), berisi index duplikat yang harus DIHAPUS:
[{{"keep": 1, "remove": [2, 5]}}, {{"keep": 3, "remove": [7]}}]
Artinya: item 1 disimpan, item 2 dan 5 dihapus (duplikat dari 1).
Jika TIDAK ADA duplikat, return array kosong: []"""

        print(f"  Deduplicating batch {i//(BATCH_SIZE*2) + 1} ({len(batch)} items)...")
        response = _call_ai(prompt, max_tokens=2048)

        try:
            response = response.strip()
            if response.startswith("```"):
                response = response.split("\n", 1)[1]
                if response.endswith("```"):
                    response = response[:-3]
            duplicates = json.loads(response)
        except json.JSONDecodeError:
            print(f"  ERROR parsing dedup response: {response[:200]}")
            duplicates = []

        # Build remove set
        remove_indices = set()
        for dup in duplicates:
            for r in dup.get("remove", []):
                remove_indices.add(r - 1)  # Convert to 0-indexed

        batch_result = [f for j, f in enumerate(batch) if j not in remove_indices]
        _cache_set("dedup", batch_key, batch_result)
        results.extend(batch_result)

    return results


def classify_food_type(name: str) -> str:
    """Classify food as base_food, local_indonesian, student_common, etc."""
    name_lower = name.lower().strip()

    # Base foods: single-ingredient, minimally processed
    base_patterns = [
        # Nasi & grains (plain)
        "nasi putih", "nasi merah", "nasi hitam", "nasi ketan",
        "ketan putih", "ketan hitam",
        "bubur beras", "bubur sumsum",
        "jagung rebus", "ubi rebus", "singkong rebus", "kentang rebus",
        "kentang kukus", "talas rebus", "sukun rebus",
        # Proteins - unprocessed
        "telur rebus", "telur ceplok", "telur dadar", "telur mata sapi",
        "telur orak-arik", "telur setengah matang",
        "ayam rebus", "ayam bakar", "ayam panggang", "ayam kukus",
        "dada ayam", "paha ayam", "sayap ayam",
        "ikan bakar", "ikan rebus", "ikan kukus", "ikan panggang",
        "daging sapi rebus", "daging sapi bakar", "daging sapi panggang",
        "tahu rebus", "tahu kukus", "tahu goreng",
        "tempe goreng", "tempe rebus", "tempe kukus", "tempe bakar",
        # Vegetables (plain/boiled/steamed/stir-fried simple)
        "bayam rebus", "kangkung rebus", "brokoli rebus", "brokoli kukus",
        "wortel rebus", "buncis rebus", "sawi rebus", "sawi putih",
        "kol rebus", "tomat", "mentimun", "kubis", "selada",
        "tauge", "kecambah", "labu siam", "pare", "terong",
        "kacang panjang", "kacang hijau", "kacang merah", "kacang tanah",
        "kacang kedelai", "edamame",
        "daun singkong", "daun pepaya", "daun kelor", "daun katuk",
        # Fruits (plain)
        "buah ", "pisang", "pepaya", "mangga", "jeruk", "apel",
        "semangka", "nanas", "alpukat", "jambu", "belimbing",
        "durian", "rambutan", "manggis", "salak", "sawo", "duku",
        "markisa", "sirsak", "nangka", "melon", "anggur", "stroberi",
        "kiwi", "pir", "leci", "kelengkeng", "kurma",
        # Plain drinks
        "air putih", "air mineral",
    ]
    if any(p in name_lower for p in base_patterns):
        return "base_food"

    # Local Indonesian dishes
    local_patterns = [
        # Masakan bersantan
        "rendang", "gulai", "opor", "kari", "sayur lodeh", "sayur asem",
        "sayur bening", "sayur santan", "sayur bayam", "sayur kangkung",
        "sayur sop", "sayur asam", "semur", "kalio",
        # Soto & sup
        "soto", "bakso", "rawon", "coto", "konro", "pallubasa",
        "sup ", "sop ", "timlo", "tekwan",
        # Sate
        "sate ", "satai ",
        # Nasi olahan
        "nasi goreng", "nasi uduk", "nasi kuning", "nasi liwet",
        "nasi pecel", "nasi rawon", "nasi campur", "nasi rames",
        "nasi padang", "nasi langgi", "nasi jamblang", "nasi krawu",
        "nasi kebuli", "nasi briyani", "nasi tumpeng", "nasi megono",
        "nasi bakar", "nasi timbel", "ketupat", "lontong",
        # Mie olahan
        "mie goreng", "mie rebus", "mie ayam", "mie kocok", "mie koclok",
        "mie aceh", "mie celor", "mie kangkung", "ifumie", "bihun goreng",
        "kwetiau", "bihun rebus", "soun", "misoa",
        # Gado-gado & pecel
        "gado-gado", "pecel", "karedok", "lotek", "rujak", "asinan",
        "tahu gejrot", "tahu kupat", "tahu campur", "tahu telur",
        "tahu tek", "tahu gunting", "ketoprak", "kupat tahu",
        # Lauk olahan
        "ayam goreng", "ayam geprek", "ayam penyet", "ayam taliwang",
        "ayam rica", "ayam balado", "ayam kalasan", "ayam betutu",
        "ayam lodho", "ayam pop", "ayam tangkap", "ayam kodok",
        "ayam woku", "ayam bumbu", "ayam kecap", "ayam mentega",
        "ikan goreng", "ikan asam", "ikan kuah", "ikan pesmol",
        "ikan rica", "ikan balado", "pepes ikan", "pepes ",
        "pindang", "pais ", "arsik",
        "udang goreng", "udang saus", "cumi goreng", "cumi saus",
        "perkedel", "bergedel", "rempeyek", "peyek", "bakwan",
        "martabak", "pastel", "risoles", "lumpia", "otak-otak",
        "pempek", "siomay", "batagor", "cilok", "cireng", "cimol",
        "combro", "misro", "lemper", "arem-arem", "nagasari",
        # Bubur & bubur manis
        "bubur ayam", "bubur kacang", "bubur ketan", "bubur candil",
        "kolak", "setup", "manisan",
        # Minuman tradisional
        "cendol", "dawet", "es cincau", "es campur", "es teler",
        "es buah", "es kacang", "bajigur", "bandrek", "wedang",
        "sekoteng", "bir pletok", "es doger", "es goyobod",
        # Jajanan pasar
        "kue ", "onde-onde", "klepon", "cucur", "serabi", "lupis",
        "putu", "lapis legit", "lapis ", "bolu ", "dadar gulung",
        "wingko", "getuk", "cenil", "tiwul", "gemblong",
        "wajik", "jenang", "dodol", "geplak", "yangko",
        "kerupuk", "kripik", "keripik", "emping", "melinjo",
        "peyek", "rempeyek",
        # Sambal
        "sambal", "sambel", "terasi",
    ]
    if any(p in name_lower for p in local_patterns):
        return "local_indonesian"

    # Beverage
    bev_patterns = [
        "es ", "jus ", "susu ", "kopi ", "teh ", "sirup",
        "minuman", "soda", "yogurt", "yoghurt", "smoothie",
        "milkshake", "coklat", "matcha", "latte", "cappuccino",
        "milk", "juice", "coffee", "tea ", "drink", "beverage",
        "float", "frappe", "frappuccino", "milo", "ovaltine",
        "sari ", "infused", "mocktail", "soda", "tonik",
    ]
    if any(p in name_lower for p in bev_patterns):
        return "beverage"

    # Snack / packaged / processed
    snack_patterns = [
        "keripik", "kripik", "kerupuk", "kue ", "roti ", "biskuit",
        "donat", "coklat", "permen", "wafer", "bolu", "muffin",
        "cupcake", "croissant", "pastry", "cracker", "chips",
        "snack", "camilan", "cemilan", "jajanan", "jajan ",
        "gorengan", "tahu isi", "pisang goreng", "pisang molen",
        "bakwan", "tempe mendoan", "risol", "pastel", "lumpia",
        "singkong goreng", "ubi goreng", "sukun goreng", "nugget",
        "sosis", "kornet", "burger", "pizza", "spaghetti",
        "makaroni", "french fries", "kentang goreng",
        "puding", "agar-agar", "jeli", "selai",
        "es krim", "ice cream", "gelato", "sorbet",
    ]
    if any(p in name_lower for p in snack_patterns):
        return "snack"

    # Catch-all for remaining Indonesian-named foods
    id_general = [
        "goreng", "rebus", "bakar", "panggang", "kukus", "tumis",
        "bumbu", "sambal", "santan", "kecap", "olahan", "masakan",
        "segar", "mentah", "kering", "masak", "sayur", "daun",
        "daging", "cincang", "giling", "iris", "potong",
        "bubuk", "butir", "suwir", "fillet", "paha", "dada",
    ]
    if any(p in name_lower for p in id_general):
        return "local_indonesian"

    return "other"


def validate_nutrition(food: dict) -> bool:
    """Basic nutrition validation."""
    cal = float(food.get("calories", 0) or 0)
    protein = float(food.get("protein", 0) or 0)
    carbs = float(food.get("carbohydrates", 0) or 0)
    fat = float(food.get("fat", 0) or 0)

    # Calories should be reasonable
    if cal <= 0 or cal > 2000:
        return False
    # Protein + Carbs + Fat should be roughly <= calories/4
    # (rough: 4 cal/g protein, 4 cal/g carbs, 9 cal/g fat)
    estimated_cal = protein * 4 + carbs * 4 + fat * 9
    if estimated_cal > 0 and (estimated_cal < cal * 0.5 or estimated_cal > cal * 2.5):
        return False
    return True
