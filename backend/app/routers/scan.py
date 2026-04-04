from fastapi import APIRouter, HTTPException, BackgroundTasks
from pydantic import BaseModel
from typing import Optional
from ..services.gemini_service import analyze_product
from ..services.personalization import apply_personalization
from ..services.openfoodfacts import get_alternatives
from ..services.translate_service import translate_text
from ..utils.hash_utils import hash_product
import uuid
from datetime import datetime
from supabase import create_client
from ..config import settings
import logging

logger = logging.getLogger(__name__)
router = APIRouter(tags=["scan"])

supabase = create_client(settings.supabase_url, settings.supabase_service_role_key)


class UserProfile(BaseModel):
    allergies: list[str] = []
    is_pregnant: bool = False
    is_breastfeeding: bool = False
    baby_mode: bool = False
    dietary_restrictions: list[str] = []
    skin_type: Optional[str] = None
    preferred_language: str = "en"


class ScanRequest(BaseModel):
    ocr_text: str
    product_type: str  # "food" or "cosmetic"
    user_profile: UserProfile
    user_id: str


@router.post("/scan")
async def scan_product(request: ScanRequest, background_tasks: BackgroundTasks):
    """
    Main scan endpoint. Pipeline:
    1. Gemini analysis
    2. Personalization
    3. Fetch alternatives
    4. Save to DB (background)
    5. Return result
    """
    if len(request.ocr_text.strip()) < 10:
        raise HTTPException(
            status_code=400,
            detail="OCR text too short. Please scan the label more clearly."
        )

    try:
        # Step 1: Gemini analysis
        logger.info(f"Starting scan for user {request.user_id}, product_type={request.product_type}")
        gemini_result = await analyze_product(
            ocr_text=request.ocr_text,
            product_type=request.product_type,
            user_profile=request.user_profile.model_dump(),
        )

        # Step 2: Personalization
        personalized = apply_personalization(
            gemini_result=gemini_result,
            user_profile=request.user_profile.model_dump(),
        )

        # Step 3: Fetch alternatives (only for food)
        alternatives = []
        if request.product_type == "food":
            product_name = personalized.get("product_name", "")
            category = _infer_category(product_name, request.ocr_text)
            alternatives = await get_alternatives(
                category=category,
                product_type=request.product_type,
                min_score=personalized.get("overall_safety_score", 0),
            )
        
        personalized["alternatives"] = alternatives

        # Step 4: Generate scan ID
        scan_id = str(uuid.uuid4())
        personalized["scan_id"] = scan_id

        # Step 5: Save to DB in background (don't block the response)
        background_tasks.add_task(
            _save_scan,
            scan_id=scan_id,
            user_id=request.user_id,
            ocr_text=request.ocr_text,
            result=personalized,
        )

        return personalized

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Scan error: {e}", exc_info=True)
        raise HTTPException(
            status_code=500,
            detail=f"Analysis failed: {str(e)}"
        )


def _infer_category(product_name: str, ocr_text: str) -> str:
    """Simple keyword-based category inference for Open Food Facts queries."""
    text = (product_name + " " + ocr_text).lower()
    
    if any(w in text for w in ["biscuit", "cookie", "cracker"]):
        return "biscuits"
    if any(w in text for w in ["juice", "drink", "beverage", "soda", "cola"]):
        return "beverages"
    if any(w in text for w in ["chip", "snack", "wafer", "crisp"]):
        return "snacks"
    if any(w in text for w in ["chocolate", "candy", "sweet"]):
        return "chocolates"
    if any(w in text for w in ["noodle", "pasta", "macaroni"]):
        return "pastas"
    if any(w in text for w in ["sauce", "ketchup", "condiment"]):
        return "condiments"
    if any(w in text for w in ["cereal", "oat", "granola", "muesli"]):
        return "cereals"
    if any(w in text for w in ["bread", "toast", "loaf"]):
        return "breads"
    if any(w in text for w in ["oil", "ghee", "butter"]):
        return "oils"
    return "snacks"  # Default fallback


async def _save_scan(scan_id: str, user_id: str, ocr_text: str, result: dict):
    """Background task: save scan to Supabase and update community stats."""
    try:
        # Save to scan_history
        supabase.table("scan_history").insert({
            "id": scan_id,
            "user_id": user_id,
            "product_name": result.get("product_name", ""),
            "brand": result.get("brand", ""),
            "product_type": result.get("product_type", ""),
            "raw_ocr_text": ocr_text,
            "gemini_response": result,
            "overall_safety_score": result.get("overall_safety_score", 0),
            "verdict": result.get("verdict", "YELLOW"),
            "label_honesty_score": result.get("label_honesty_score", 50),
            "sustainability_score": result.get("sustainability", {}).get("score", 50),
            "scanned_at": datetime.utcnow().isoformat(),
        }).execute()

        # Update community stats
        product_hash = hash_product(
            result.get("product_name", ""), result.get("brand", "")
        )
        existing = (
            supabase.table("community_stats")
            .select("*")
            .eq("product_hash", product_hash)
            .execute()
        )
        
        if existing.data:
            row = existing.data[0]
            new_count = row["scan_count"] + 1
            new_avg = (
                row["avg_safety_score"] * row["scan_count"]
                + result.get("overall_safety_score", 0)
            ) / new_count
            supabase.table("community_stats").update({
                "scan_count": new_count,
                "avg_safety_score": new_avg,
                "last_updated": datetime.utcnow().isoformat(),
            }).eq("product_hash", product_hash).execute()
        else:
            supabase.table("community_stats").insert({
                "product_hash": product_hash,
                "product_name": result.get("product_name", ""),
                "brand": result.get("brand", ""),
                "scan_count": 1,
                "avg_safety_score": float(result.get("overall_safety_score", 0)),
                "verdict": result.get("verdict", "YELLOW"),
                "last_updated": datetime.utcnow().isoformat(),
            }).execute()

    except Exception as e:
        logger.error(f"Background save error: {e}", exc_info=True)


@router.get("/scan/{scan_id}")
async def get_scan(scan_id: str):
    result = supabase.table("scan_history").select("*").eq("id", scan_id).execute()
    if not result.data:
        raise HTTPException(status_code=404, detail="Scan not found")
    row = result.data[0]
    data = row["gemini_response"]
    data["scan_id"] = scan_id
    return data