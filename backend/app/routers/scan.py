from fastapi import APIRouter, HTTPException, BackgroundTasks
from ..schemas.scan_schemas import ScanRequest
from ..services.gemini_service import analyze_product
from ..services.personalization import apply_personalization
from ..services.openfoodfacts import get_alternatives
from ..config import settings
from supabase import create_client
import uuid
import logging
from datetime import datetime

router = APIRouter(tags=['scan'])
logger = logging.getLogger(__name__)
supabase = create_client(
    settings.supabase_url,
    settings.supabase_service_role_key
)


@router.post('/scan')
async def scan_product(
    request: ScanRequest,
    background_tasks: BackgroundTasks,
):
    if len(request.ocr_text.strip()) < 10:
        raise HTTPException(
            status_code=400,
            detail='OCR text too short. Hold the camera closer to the label.'
        )

    try:
        logger.info(
            f'Scan started: user={request.user_id} '
            f'type={request.product_type}'
        )

        # STEP 1: AI analysis (Groq classifies category too)
        result = await analyze_product(
            ocr_text=request.ocr_text,
            product_type=request.product_type,
            user_profile=request.user_profile.model_dump(),
        )

        # STEP 2: Personalization
        result = apply_personalization(
            result,
            request.user_profile.model_dump()
        )

        # STEP 3: Alternatives using AI-classified category
        if request.product_type == 'food':
            category = result.get('product_category', 'snacks')
            logger.info(f'AI classified category: {category}')
            result['alternatives'] = await get_alternatives(
                category=category,
                product_type=request.product_type,
                min_score=result.get('overall_safety_score', 0),
            )
        else:
            result['alternatives'] = []

        # STEP 4: Assign scan ID
        scan_id = str(uuid.uuid4())
        result['scan_id'] = scan_id

        # STEP 5: Save in background
        background_tasks.add_task(
            _save_scan,
            scan_id,
            request.user_id,
            request.ocr_text,
            result
        )

        logger.info(
            f'Scan complete: {scan_id} '
            f'category={category if request.product_type == "food" else "N/A"} '
            f'verdict={result.get("verdict")} '
            f'score={result.get("overall_safety_score")}'
        )
        return result

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f'Scan error: {e}', exc_info=True)
        raise HTTPException(
            status_code=500,
            detail=f'Analysis failed: {str(e)}'
        )


async def _save_scan(
    scan_id: str,
    user_id: str,
    ocr_text: str,
    result: dict
):
    try:
        supabase.table('scan_history').insert({
            'id': scan_id,
            'user_id': user_id,
            'product_name': result.get('product_name', ''),
            'brand': result.get('brand', ''),
            'product_type': result.get('product_type', ''),
            'raw_ocr_text': ocr_text,
            'gemini_response': result,
            'overall_safety_score': result.get(
                'overall_safety_score', 0),
            'verdict': result.get('verdict', 'YELLOW'),
            'label_honesty_score': result.get(
                'label_honesty_score', 50),
            'sustainability_score': result.get(
                'sustainability', {}).get('score', 50),
            'scanned_at': datetime.utcnow().isoformat(),
        }).execute()
        logger.info(f'Scan saved to DB: {scan_id}')

        from ..services.community_service import \
            update_community_stats
        update_community_stats(
            product_name=result.get('product_name', ''),
            brand=result.get('brand', ''),
            safety_score=result.get('overall_safety_score', 0),
            verdict=result.get('verdict', 'YELLOW'),
        )
    except Exception as e:
        logger.error(f'Failed to save scan {scan_id}: {e}')