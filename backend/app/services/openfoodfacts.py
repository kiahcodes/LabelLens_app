import httpx
import logging
from typing import Optional

logger = logging.getLogger(__name__)

OFF_BASE = "https://world.openfoodfacts.org"


async def get_alternatives(
    category: str,
    product_type: str,
    min_score: int = 0,
    limit: int = 5,
) -> list[dict]:
    """
    Fetch safer alternatives from Open Food Facts.
    Returns a list of alternative product dicts.
    """
    if product_type != "food":
        return []  # Open Food Facts is food-only

    try:
        params = {
            "action": "process",
            "tagtype_0": "categories",
            "tag_contains_0": "contains",
            "tag_0": category,
            "sort_by": "unique_scans_n",
            "page_size": 20,
            "json": 1,
            "fields": "product_name,brands,nutriscore_grade,ecoscore_grade,image_url,url,ingredients_n,nutriments",
        }

        async with httpx.AsyncClient(timeout=10.0) as client:
            response = await client.get(
                f"{OFF_BASE}/cgi/search.pl", params=params
            )
            data = response.json()

        products = data.get("products", [])
        alternatives = []

        for p in products:
            name = p.get("product_name", "").strip()
            brand = p.get("brands", "").split(",")[0].strip()
            if not name:
                continue

            # Estimate safety score from nutriscore
            nutriscore = p.get("nutriscore_grade", "").upper()
            score_map = {"A": 85, "B": 70, "C": 55, "D": 40, "E": 25}
            safety_score = score_map.get(nutriscore, 60)

            # Only include if higher than current product
            if safety_score <= min_score:
                continue

            image_url = p.get("image_url") or p.get("image_front_url")
            product_url = p.get("url", "")

            alternatives.append({
                "product_name": name,
                "brand": brand,
                "safety_score": safety_score,
                "green_ingredient_count": _estimate_green_count(p),
                "price_inr": None,  # Open Food Facts doesn't carry pricing
                "image_url": image_url,
                "product_url": product_url,
                "category": category,
            })

            if len(alternatives) >= limit:
                break

        return alternatives

    except Exception as e:
        logger.error(f"Open Food Facts error: {e}")
        return []


def _estimate_green_count(product: dict) -> int:
    """Rough estimate of green ingredients from ingredient count and nutriscore."""
    total = product.get("ingredients_n", 0) or 0
    grade = product.get("nutriscore_grade", "c").lower()
    ratio = {"a": 0.8, "b": 0.65, "c": 0.5, "d": 0.35, "e": 0.2}.get(grade, 0.5)
    return max(0, int(total * ratio))