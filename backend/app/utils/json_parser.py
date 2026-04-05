import json
import re
import logging

logger = logging.getLogger(__name__)


def safe_parse_json(text: str) -> dict:
    # Attempt 1: direct parse
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        pass

    # Attempt 2: find first { and last }
    try:
        start = text.index('{')
        end = text.rindex('}') + 1
        return json.loads(text[start:end])
    except (ValueError, json.JSONDecodeError):
        pass

    # Attempt 3: fix trailing commas and single quotes
    try:
        cleaned = re.sub(r',\s*([}\]])', r'\1', text)
        return json.loads(cleaned)
    except json.JSONDecodeError:
        pass

    # Fallback: return safe minimal structure
    logger.error(f'Could not parse Gemini JSON. First 300 chars: {text[:300]}')
    return {
        'product_name': 'Unknown Product',
        'brand': '',
        'product_type': 'food',
        'overall_safety_score': 50,
        'verdict': 'YELLOW',
        'label_honesty_score': 50,
        'label_honesty_issues': [],
        'ingredients': [],
        'disguised_ingredients_summary': [],
        'personalized_risks': ['Unable to fully analyze. Please try scanning again.'],
        'allergen_alerts': [],
        'sustainability': {
            'score': 50,
            'carbon_footprint_level': 'MEDIUM',
            'recyclable_packaging': None,
            'cruelty_free': None,
            'vegan': None,
            'sustainability_notes': ''
        },
        'summary': 'Analysis incomplete due to a parsing error.',
        'chatbot_context': 'Product analysis was incomplete.'
    }