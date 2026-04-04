from fastapi import APIRouter, HTTPException
from supabase import create_client
from ..config import settings

router = APIRouter(tags=["history"])
supabase = create_client(settings.supabase_url, settings.supabase_service_role_key)


@router.get("/scan-history/{user_id}")
async def get_scan_history(user_id: str, limit: int = 20):
    result = (
        supabase.table("scan_history")
        .select("id, product_name, brand, product_type, verdict, overall_safety_score, scanned_at")
        .eq("user_id", user_id)
        .order("scanned_at", desc=True)
        .limit(limit)
        .execute()
    )
    return result.data or []