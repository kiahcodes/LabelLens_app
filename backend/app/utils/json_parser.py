import json
import re
import logging

logger = logging.getLogger(__name__)


def safe_parse_json(text: str) -> dict:
    """Attempt to parse JSON from Gemini output, with cleanup fallbacks."""
    
    # Attempt 1: Direct parse
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        pass

    # Attempt 2: Find first { and last } and extract
    try:
        start = text.index('{')
        end = text.rindex('}') + 1
        return json.loads(text[start:end])
    except (ValueError, json.JSONDecodeError):
        pass

    # Attempt 3: Fix common issues (single quotes, trailing commas)
    try:
        cleaned = text
        # Replace single quotes (outside of already-double-quoted strings)
        cleaned = re.sub(r"(?<!\\)'", '"', cleaned)
        # Remove trailing commas before } or ]
        cleaned = re.sub(r',\s*([}\]])', r'\1', cleaned)
        return json.loads(cleaned)
    except json.JSONDecodeError:
        pass

    # Fallback: return a minimal safe structure
    logger.error(f"Could not parse Gemini JSON. Raw text (first 500 chars): {text[:500]}")
    return {
        "product_name": "Unknown",
        "brand": "",
        "product_type": "food",
        "overall_safety_score": 50,
        "verdict": "YELLOW",
        "label_honesty_score": 50,
        "label_honesty_issues": [],
        "ingredients": [],
        "disguised_ingredients_summary": [],
        "personalized_risks": ["Unable to fully analyze this product. Please try scanning again."],
        "allergen_alerts": [],
        "sustainability": {
            "score": 50,
            "carbon_footprint_level": "MEDIUM",
            "recyclable_packaging": None,
            "cruelty_free": None,
            "vegan": None,
            "sustainability_notes": ""
        },
        "summary": "Analysis incomplete due to a parsing error.",
        "chatbot_context": "Product analysis was incomplete."
    }