from fastapi import APIRouter, HTTPException, BackgroundTasks
from ..schemas.scan_schemas import ScanRequest
from ..services.gemini_service import analyze_product
from ..services.personalization import apply_personalization
from ..services.openfoodfacts import get_alternatives
from ..services.translate_service import translate_text
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

        # STEP 5: Translate user-facing analysis text when requested
        target_language = request.user_profile.preferred_language
        if target_language != 'en':
            result = await _translate_scan_result(result, target_language)
            result['scan_id'] = scan_id

        # STEP 6: Save in background
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


async def _translate_scan_result(result: dict, target_language: str) -> dict:
    translated = dict(result)

    for key in ('summary', 'chatbot_context'):
        translated[key] = await translate_text(
            translated.get(key, ''),
            target_language,
        )

    translated['personalized_risks'] = [
        await translate_text(risk, target_language)
        for risk in translated.get('personalized_risks', [])
    ]

    for assessment_key in ('pregnancy_assessment', 'baby_assessment'):
        assessment = translated.get(assessment_key)
        if isinstance(assessment, dict) and assessment.get('reason'):
            assessment = dict(assessment)
            assessment['reason'] = await translate_text(
                assessment['reason'],
                target_language,
            )
            translated[assessment_key] = assessment

    translated['allergen_alerts'] = [
        {
            **alert,
            'allergen': await translate_text(
                alert.get('allergen', ''),
                target_language,
            ),
            'found_in': await translate_text(
                alert.get('found_in', ''),
                target_language,
            ),
        }
        for alert in translated.get('allergen_alerts', [])
        if isinstance(alert, dict)
    ]

    translated['label_honesty_issues'] = [
        {
            **issue,
            'claim': await translate_text(
                issue.get('claim', ''),
                target_language,
            ),
            'reality': await translate_text(
                issue.get('reality', ''),
                target_language,
            ),
        }
        for issue in translated.get('label_honesty_issues', [])
        if isinstance(issue, dict)
    ]

    translated['disguised_ingredients_summary'] = [
        await _translate_disguised_ingredient(item, target_language)
        for item in translated.get('disguised_ingredients_summary', [])
    ]

    translated['ingredients'] = [
        await _translate_ingredient(ingredient, target_language)
        for ingredient in translated.get('ingredients', [])
    ]

    translated['alternatives'] = [
        await _translate_alternative(alternative, target_language)
        for alternative in translated.get('alternatives', [])
    ]

    sustainability = translated.get('sustainability')
    if isinstance(sustainability, dict):
        translated['sustainability'] = await _translate_string_fields(
            sustainability,
            target_language,
            ('note', 'summary', 'impact', 'reason'),
        )

    return translated


async def _translate_ingredient(
    ingredient: dict,
    target_language: str,
) -> dict:
    if not isinstance(ingredient, dict):
        return ingredient

    return await _translate_string_fields(
        ingredient,
        target_language,
        (
            'canonical_name',
            'true_chemical_name',
            'disguise_explanation',
            'allergen_type',
            'formulation',
            'health_impact',
            'usage_reason',
            'regulation_IN',
            'regulation_US',
            'regulation_EU',
            'regulation_WHO',
            'sustainability_note',
        ),
    )


async def _translate_disguised_ingredient(
    item: dict,
    target_language: str,
) -> dict:
    if not isinstance(item, dict):
        return item

    return await _translate_string_fields(
        item,
        target_language,
        (
            'canonical_name',
            'true_chemical_name',
            'explanation',
            'reason',
        ),
    )


async def _translate_alternative(
    alternative: dict,
    target_language: str,
) -> dict:
    if not isinstance(alternative, dict):
        return alternative

    return await _translate_string_fields(
        alternative,
        target_language,
        ('product_name', 'brand', 'reason', 'summary'),
    )


async def _translate_string_fields(
    data: dict,
    target_language: str,
    fields: tuple[str, ...],
) -> dict:
    translated = dict(data)
    for field in fields:
        value = translated.get(field)
        if isinstance(value, str) and value:
            translated[field] = await translate_text(value, target_language)
    return translated


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
        _create_scan_notification(scan_id, user_id, result)

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


def _create_scan_notification(scan_id: str, user_id: str, result: dict):
    try:
        product_name = result.get('product_name') or 'your product'
        verdict = result.get('verdict', 'YELLOW')
        score = result.get('overall_safety_score', 0)

        if verdict == 'GREEN':
            title = 'Scan looks safe'
            body = f'{product_name} scored {score}/100.'
        elif verdict == 'RED':
            title = 'Scan needs attention'
            body = f'{product_name} scored {score}/100. Review the risks.'
        else:
            title = 'Scan completed'
            body = f'{product_name} scored {score}/100. Check the analysis.'

        supabase.table('notifications').insert({
            'user_id': user_id,
            'title': title,
            'body': body,
            'type': 'scan_result',
        }).execute()
        logger.info(f'Notification created for scan {scan_id}')
    except Exception as e:
        logger.error(f'Failed to create notification for scan {scan_id}: {e}')
