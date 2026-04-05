import httpx
import logging

logger = logging.getLogger(__name__)

SUPPORTED_LANGUAGES = {'en', 'hi','gu'}


async def translate_text(text: str, target_language: str) -> str:
    """
    Translate English to Hindi using MyMemory API.
    Free, no API key, no deployment needed.
    Falls back to English if anything fails.
    """
    if not text:
        return text

    # English: return as-is, no API call needed
    if target_language == 'en' or target_language not in SUPPORTED_LANGUAGES:
        return text

    try:
        async with httpx.AsyncClient(timeout=8.0) as client:
            response = await client.get(
                'https://api.mymemory.translated.net/get',
                params={
                    'q': text,
                    'langpair': 'en|hi',
                },
            )
            data = response.json()
            translated = data.get('responseData', {}).get('translatedText', '')

            if translated and translated != text:
                return translated
            return text

    except Exception as e:
        logger.warning(f'Translation failed, showing English: {e}')
        return text  # always fallback gracefully