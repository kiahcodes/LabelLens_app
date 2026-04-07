import hashlib

def hash_product(product_name: str, brand: str) -> str:
    """Creates a consistent short hash for a product."""
    key = f"{product_name.lower().strip()}:{brand.lower().strip()}"
    return hashlib.sha256(key.encode()).hexdigest()[:16]