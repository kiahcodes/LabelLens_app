import httpx
from ..config import settings
import logging

logger = logging.getLogger(__name__)

LANGUAGE_CODE_MAP = {
    "hi": "hi",  # Hindi
    "gu": "gu",  # Gujarati
    "ta": "ta",  # Tamil
    "bn": "bn",  # Bengali
    "te": "te",  # Telugu
    "en": "en",  # English
}


async def translate_text(text: str, target_language: str) -> str:
    """Translate text using self-hosted LibreTranslate. Falls back to English on error."""
    if target_language == "en" or not text:
        return text

    target_code = LANGUAGE_CODE_MAP.get(target_language, "en")
    if target_code == "en":
        return text

    try:
        async with httpx.AsyncClient(timeout=8.0) as client:
            response = await client.post(
                f"{settings.libretranslate_url}/translate",
                json={
                    "q": text,
                    "source": "en",
                    "target": target_code,
                    "format": "text",
                },
            )
            data = response.json()
            return data.get("translatedText", text)
    except Exception as e:
        logger.warning(f"Translation failed, returning English: {e}")
        return text  # Graceful fallback