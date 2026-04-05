from google import genai
from ..config import settings
from ..prompts.scan_prompt import SCAN_SYSTEM_PROMPT, CHATBOT_SYSTEM_PROMPT
from ..utils.json_parser import safe_parse_json
import asyncio
import logging

logger = logging.getLogger(__name__)
client = genai.Client(api_key=settings.gemini_api_key)


def _call_gemini_sync(prompt: str) -> str:
    """Synchronous Gemini call — runs in thread pool to avoid Windows async issues."""
    response = client.models.generate_content(
        model='gemini-2.0-flash',
        contents=prompt,
    )
    return response.text.strip()


async def analyze_product(
    ocr_text: str,
    product_type: str,
    user_profile: dict,
) -> dict:
    user_context = f"""
Product type: {product_type}
User allergies: {', '.join(user_profile.get('allergies', [])) or 'None'}
User is pregnant: {user_profile.get('is_pregnant', False)}
User has baby mode: {user_profile.get('baby_mode', False)}
Dietary restrictions: {', '.join(user_profile.get('dietary_restrictions', [])) or 'None'}
Skin type: {user_profile.get('skin_type', 'Not specified')}
"""
    full_prompt = (
        f"{SCAN_SYSTEM_PROMPT}\n\n"
        f"RAW OCR TEXT FROM LABEL:\n{ocr_text}\n\n"
        f"USER CONTEXT:\n{user_context}\n\n"
        f"Return ONLY the JSON object. No markdown. No code blocks."
    )
    try:
        # Run synchronous Gemini call in thread pool
        # This fixes the Windows + Python 3.13 connection drop issue
        loop = asyncio.get_event_loop()
        raw = await loop.run_in_executor(None, _call_gemini_sync, full_prompt)

        if raw.startswith(''):
            raw = raw.split('')[1]
            if raw.startswith('json'):
                raw = raw[4:]
            raw = raw.rsplit('```', 1)[0]

        return safe_parse_json(raw)

    except Exception as e:
        logger.error(f'Gemini analyze_product error: {e}')
        raise


async def chatbot_response(
    message: str,
    scan_context: str,
    user_profile: dict,
    conversation_history: list,
) -> str:
    system = CHATBOT_SYSTEM_PROMPT.format(
        scan_context=scan_context,
        user_profile=(
            f"Pregnant: {user_profile.get('is_pregnant')}, "
            f"Baby mode: {user_profile.get('baby_mode')}, "
            f"Allergies: {user_profile.get('allergies', [])}"
        ),
    )
    history = '\n'.join(
        [f"{m['role'].upper()}: {m['content']}"
         for m in conversation_history[-6:]]
    )
    full_prompt = (
        f"{system}\n\nCONVERSATION:\n{history}\n\n"
        f"USER: {message}\nASSISTANT:"
    )
    try:
        loop = asyncio.get_event_loop()
        return await loop.run_in_executor(
            None, _call_gemini_sync, full_prompt)
    except Exception as e:
        logger.error(f'Gemini chatbot error: {e}')
        return 'I am having trouble connecting. Please try again.'