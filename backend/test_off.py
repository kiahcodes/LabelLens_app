import asyncio
from app.services.openfoodfacts import get_alternatives

async def test():
    results = await get_alternatives('biscuits', 'food', min_score=0)
    print(f'Found {len(results)} alternatives')
    for r in results[:3]:
        print(r['product_name'], '|', r['brand'], '| score:', r['safety_score'])

asyncio.run(test())