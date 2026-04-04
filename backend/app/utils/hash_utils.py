import hashlib


def hash_product(product_name: str, brand: str) -> str:
    """Create a consistent hash for community stats deduplication."""
    key = f"{product_name.lower().strip()}:{brand.lower().strip()}"
    return hashlib.sha256(key.encode()).hexdigest()[:16]