
from groq import Groq
from ..config import settings
from ..prompts.scan_prompt import SCAN_SYSTEM_PROMPT, CHATBOT_SYSTEM_PROMPT
from ..utils.json_parser import safe_parse_json
import asyncio
import logging
import time
import os
import json
from datetime import date

logger = logging.getLogger(__name__)
client = Groq(api_key=settings.groq_api_key)

QUOTA_FILE = '/tmp/groq_quota.json'


def _get_daily_count() -> int:
    try:
        if not os.path.exists(QUOTA_FILE):
            return 0
        with open(QUOTA_FILE) as f:
            data = json.load(f)
        if data.get('date') != str(date.today()):
            return 0
        return data.get('count', 0)
    except Exception:
        return 0


def _increment_count():
    try:
        count = _get_daily_count() + 1
        with open(QUOTA_FILE, 'w') as f:
            json.dump({
                'date': str(date.today()),
                'count': count
            }, f)
        if count > 450:
            logger.warning(
                f'Groq quota high: {count} calls today. '
                f'Limit is ~500. Switch to demo mode if needed.')
    except Exception:
        pass

def _call_ai_sync(prompt: str, retries: int = 2) -> str:
    for attempt in range(retries + 1):
        try:
            response = client.chat.completions.create(
                model="llama-3.3-70b-versatile",
                messages=[
                    {
                        "role": "system",
                        "content": (
                            "You are an expert food and cosmetic safety analyst "
                            "with deep knowledge of ingredient toxicology, global "
                            "regulations (FSSAI India, FDA USA, EFSA EU, WHO), and "
                            "consumer health science. "
                            "You must fill EVERY field in the JSON schema with "
                            "accurate real factual data — never use placeholder "
                            "text like 'string'. "
                            "For regulation fields write the actual regulatory "
                            "status. For health_impact write the real health "
                            "effects. For formulation write the chemical nature. "
                            "Return ONLY valid JSON. No markdown. No explanation. "
                            "Start your response with { and end with }."
                        )
                    },
                    {
                        "role": "user",
                        "content": prompt
                    },
                ],
                max_tokens=8192,
                temperature=0.1,
            )
            _increment_count()  # ADD THIS LINE
            return response.choices[0].message.content.strip()

        except Exception as e:
            if attempt < retries:
                wait = 2 ** attempt  # exponential backoff
                logger.warning(
                    f"Groq attempt {attempt + 1} failed: {e}. "
                    f"Retrying in {wait}s..."
                )
                time.sleep(wait)
            else:
                logger.error(f"All Groq attempts failed: {e}")
                raise
def _call_chat_sync(prompt: str, retries: int = 2) -> str:
    for attempt in range(retries + 1):
        try:
            response = client.chat.completions.create(
                model="llama-3.3-70b-versatile",
                messages=[
                    {
                        "role": "system",
                        "content": (
                            "You are a helpful food and cosmetic safety assistant. "
                            "Answer clearly in plain conversational text. "
                            "No JSON. No markdown. No bullet points unless helpful."
                        )
                    },
                    {"role": "user", "content": prompt}
                ],
                max_tokens=1024,
                temperature=0.4,
            )
            _increment_count()
            return response.choices[0].message.content.strip()
        except Exception as e:
            if attempt < retries:
                time.sleep(2 ** attempt)
            else:
                raise

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
        f"OCR TEXT FROM LABEL:\n{ocr_text}\n\n"
        f"USER CONTEXT:\n{user_context}\n\n"
        f"Return ONLY valid JSON. Start with {{ and end with }}. "
        f"Fill every field with real data, never use 'string' as a value."
    )
    try:
        loop = asyncio.get_event_loop()
        raw = await loop.run_in_executor(
            None, _call_ai_sync, full_prompt)

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
        loop = asyncio.get_event_loop()
        return await loop.run_in_executor(
            None, _call_chat_sync, prompt)
    except Exception as e:
        logger.error(f"AI chatbot error: {e}")
        return "Something went wrong. Try again."