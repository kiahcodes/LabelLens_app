from groq import Groq
from ..config import settings
from ..prompts.scan_prompt import SCAN_SYSTEM_PROMPT, CHATBOT_SYSTEM_PROMPT
from ..utils.json_parser import safe_parse_json
import logging

logger = logging.getLogger(__name__)

client = Groq(api_key=settings.groq_api_key)


def _call_ai_sync(prompt: str) -> str:
    response = client.chat.completions.create(
        model="llama-3.1-8b-instant",  # 🔥 fast + reliable
        messages=[
            {
                "role": "system",
                "content": "You are a food safety analysis AI. Return ONLY valid JSON."
            },
            {
                "role": "user",
                "content": prompt
            },
        ],
    )

    return response.choices[0].message.content.strip()


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
        f"OCR TEXT:\n{ocr_text}\n\n"
        f"USER CONTEXT:\n{user_context}\n\n"
        f"Return ONLY valid JSON."
    )

    try:
        raw = _call_ai_sync(full_prompt)

        # Clean markdown if model adds it
        if raw.startswith("```"):
            raw = raw.split("```")[1]
            if raw.startswith("json"):
                raw = raw[4:]
            raw = raw.rsplit("```", 1)[0]

        return safe_parse_json(raw)

    except Exception as e:
        logger.error(f"AI analyze_product error: {e}")
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

    history = "\n".join(
        [f"{m['role'].upper()}: {m['content']}"
         for m in conversation_history[-6:]]
    )

    prompt = f"{system}\n\n{history}\n\nUSER: {message}"

    try:
        return _call_ai_sync(prompt)
    except Exception as e:
        logger.error(f"AI chatbot error: {e}")
        return "Something went wrong. Try again."