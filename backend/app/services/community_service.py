from supabase import create_client
from ..config import settings
from ..utils.hash_utils import hash_product
from datetime import datetime
import logging

logger = logging.getLogger(__name__)
supabase = create_client(
    settings.supabase_url,
    settings.supabase_service_role_key
)


def update_community_stats(
    product_name: str,
    brand: str,
    safety_score: int,
    verdict: str,
):
    """
    Increments scan count and updates average safety score
    for a product in community_stats table.
    """
    try:
        product_hash = hash_product(product_name, brand)
        existing = (
            supabase.table('community_stats')
            .select('*')
            .eq('product_hash', product_hash)
            .execute()
        )

        if existing.data:
            row = existing.data[0]
            new_count = row['scan_count'] + 1
            new_avg = (
                row['avg_safety_score'] * row['scan_count']
                + safety_score
            ) / new_count
            supabase.table('community_stats').update({
                'scan_count': new_count,
                'avg_safety_score': round(new_avg, 2),
                'last_updated': datetime.utcnow().isoformat(),
            }).eq('product_hash', product_hash).execute()
            logger.info(
                f'Community stats updated: {product_name} '
                f'count={new_count}'
            )
        else:
            supabase.table('community_stats').insert({
                'product_hash': product_hash,
                'product_name': product_name,
                'brand': brand,
                'scan_count': 1,
                'avg_safety_score': float(safety_score),
                'verdict': verdict,
                'last_updated': datetime.utcnow().isoformat(),
            }).execute()
            logger.info(
                f'Community stats created: {product_name}'
            )
    except Exception as e:
        logger.error(f'Community stats error: {e}')