"""
Dataset Pipeline Configuration
"""
import os

# Paths
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(BASE_DIR)
DOCS_DIR = os.path.join(PROJECT_DIR, "docs")
OUTPUT_DIR = os.path.join(BASE_DIR, "output")
CACHE_DIR = os.path.join(BASE_DIR, "cache")

# Input CSV files
EXISTING_CSVS = [
    os.path.join(DOCS_DIR, "nilai-gizi.csv"),
    os.path.join(DOCS_DIR, "makanan-lokal.csv"),
    os.path.join(DOCS_DIR, "nutrition.csv"),
]

# Output
FINAL_OUTPUT = os.path.join(OUTPUT_DIR, "foods_id_clean.csv")

# API Configuration (DeepSeek via Anthropic-compatible API)
ANTHROPIC_API_KEY = os.environ.get(
    "ANTHROPIC_API_KEY",
    "sk-2cd1b50c0541435098eb89d64d34147f"
)
ANTHROPIC_BASE_URL = os.environ.get(
    "ANTHROPIC_BASE_URL",
    "https://api.deepseek.com/anthropic"
)
AI_MODEL = "deepseek-chat"

# FatSecret API (OAuth 2.0)
FATSECRET_CLIENT_ID = os.environ.get(
    "FATSECRET_CLIENT_ID",
    "6482bdac6f9644bd8ae36dcf00ea1045"
)
FATSECRET_CLIENT_SECRET = os.environ.get(
    "FATSECRET_CLIENT_SECRET",
    "b505e3feec8d49159fd5132a7f059eec"
)

# USDA API
USDA_BASE_URL = "https://api.nal.usda.gov/fdc/v1"
USDA_API_KEY = os.environ.get("USDA_API_KEY", "DEMO_KEY")

# Processing
BATCH_SIZE = 20  # items per AI batch
MAX_RETRIES = 3
CACHE_ENABLED = True

# Food categories to prioritize
PRIORITY_CATEGORIES = [
    "base_food",       # telur rebus, kentang rebus, nasi putih
    "local_indonesian", # makanan khas Indonesia
    "student_common",   # makanan umum mahasiswa
    "beverage",        # minuman
    "snack",           # camilan
    "processed",       # makanan olahan
    "other",
]
