# from app.services.gemini_service import _call_ai_sync
# from app.utils.json_parser import safe_parse_json

# def test():
#     print("Calling Groq...")
#     raw = _call_ai_sync(
#         "List 3 food ingredients as JSON. "
#         "Format: {\"ingredients\": [\"Sugar\", \"Salt\", \"Water\"]}. "
#         "Return ONLY the JSON."
#     )
#     print("Raw:", raw)
#     parsed = safe_parse_json(raw)
#     print("Parsed:", parsed)
#     print("Working!")

# test()

import asyncio
from app.services.openfoodfacts import get_alternatives

async def test():
    results = await get_alternatives('biscuits', 'food', min_score=0)
    print(f'Found {len(results)} alternatives')
    for r in results[:len(results)]:
        print(r['product_name'], '|', r['brand'], '| score:', r['safety_score'])

asyncio.run(test())