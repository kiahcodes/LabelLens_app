from fastapi import APIRouter
from ..schemas.scan_schemas import ScanRequest

router = APIRouter(tags=['scan'])

@router.post('/scan')
async def scan_product(request: ScanRequest):
    return {
        'scan_id': 'mock-001',
        'product_name': 'Test Product',
        'brand': 'Test Brand',
        'product_type': request.product_type,
        'overall_safety_score': 72,
        'verdict': 'GREEN',
        'label_honesty_score': 80,
        'label_honesty_issues': [],
        'ingredients': [],
        'disguised_ingredients_summary': [],
        'personalized_risks': [],
        'allergen_alerts': [],
        'sustainability': {
            'score': 60,
            'carbon_footprint_level': 'MEDIUM',
            'recyclable_packaging': None,
            'cruelty_free': None,
            'vegan': None,
            'sustainability_notes': 'No data yet'
        },
        'summary': 'This is a mock scan result for testing.',
        'chatbot_context': 'Mock product scanned.',
        'alternatives': []
    }