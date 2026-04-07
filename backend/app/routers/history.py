from fastapi import APIRouter, HTTPException
from supabase import create_client
from ..config import settings

router = APIRouter(tags=['history'])
supabase = create_client(
    settings.supabase_url,
    settings.supabase_service_role_key
)


@router.get('/scan-history/{user_id}')
async def get_scan_history(
    user_id: str, limit: int = 20
):
    """Returns summary list of past scans for a user."""
    result = (
        supabase.table('scan_history')
        .select(
            'id,product_name,brand,product_type,verdict,'
            'overall_safety_score,scanned_at'
        )
        .eq('user_id', user_id)
        .order('scanned_at', desc=True)
        .limit(limit)
        .execute()
    )
    return result.data or []


@router.get('/scan/{scan_id}')
async def get_scan(scan_id: str):
    """Returns full scan result by scan ID."""
    result = (
        supabase.table('scan_history')
        .select('*')
        .eq('id', scan_id)
        .execute()
    )
    if not result.data:
        raise HTTPException(
            status_code=404,
            detail='Scan not found'
        )
    row = result.data[0]
    data = row['gemini_response']
    data['scan_id'] = scan_id
    return data


@router.get('/community-stats/{product_hash}')
async def get_community_stats(product_hash: str):
    """Returns community scan count for a product."""
    result = (
        supabase.table('community_stats')
        .select('*')
        .eq('product_hash', product_hash)
        .execute()
    )
    if not result.data:
        return {'scan_count': 0, 'avg_safety_score': None}
    return result.data[0]

@router.get('/top-product')
async def get_top_product():
    result = (
        supabase.table('community_stats')
        .select('product_name,brand,scan_count,avg_safety_score')
        .order('scan_count', desc=True)
        .limit(1)
        .execute()
    )
    if not result.data:
        return {'message': 'No products scanned yet'}
    return result.data[0]