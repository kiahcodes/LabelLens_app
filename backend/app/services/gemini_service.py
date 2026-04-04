import google.generativeai as genai
from ..config import settings
from ..prompts.scan_prompt import SCAN_SYSTEM_PROMPT, CHATBOT_SYSTEM_PROMPT
from ..utils.json_parser import safe_parse_json
import logging

logger = logging.getLogger(__name__)

genai.configure(api_key=settings.gemini_api_key)

model = genai.GenerativeModel(
    model_name="gemini-2.0-flash",
    generation_config=genai.GenerationConfig(
        temperature=0.1,  # Low temperature for structured, consistent output
        max_output_tokens=8192,
    ),
)


async def analyze_product(
    ocr_text: str,
    product_type: str,
    user_profile: dict,
) -> dict:
    """Call Gemini to analyze a product label. Returns parsed JSON dict."""
    
    user_context = f"""
Product type: {product_type}
User allergies: {', '.join(user_profile.get('allergies', [])) or 'None'}
User is pregnant: {user_profile.get('is_pregnant', False)}
User has baby mode: {user_profile.get('baby_mode', False)}
Dietary restrictions: {', '.join(user_profile.get('dietary_restrictions', [])) or 'None'}
Skin type: {user_profile.get('skin_type', 'Not specified')}
"""
    
    full_prompt = f"""{SCAN_SYSTEM_PROMPT}

---
RAW OCR TEXT FROM LABEL:
{ocr_text}

---
USER CONTEXT:
{user_context}

Return ONLY the JSON object. No markdown. No code blocks. No explanation."""

    try:
        response = model.generate_content(full_prompt)
        raw_text = response.text.strip()
        
        # Remove any markdown code fences if present
        if raw_text.startswith("```"):
            raw_text = raw_text.split("```")[1]
            if raw_text.startswith("json"):
                raw_text = raw_text[4:]
            raw_text = raw_text.rsplit("```", 1)[0]
        
        parsed = safe_parse_json(raw_text)
        return parsed
        
    except Exception as e:
        logger.error(f"Gemini analyze_product error: {e}")
        raise


async def chatbot_response(
    message: str,
    scan_context: str,
    user_profile: dict,
    conversation_history: list[dict],
) -> str:
    """Call Gemini for chatbot response. Returns plain text."""
    
    system = CHATBOT_SYSTEM_PROMPT.format(
        scan_context=scan_context,
        user_profile=f"Pregnant: {user_profile.get('is_pregnant')}, Baby mode: {user_profile.get('baby_mode')}, Allergies: {user_profile.get('allergies', [])}",
    )
    
    # Build conversation for Gemini
    history_text = "\n".join(
        [f"{m['role'].upper()}: {m['content']}" for m in conversation_history[-6:]]
    )
    
    full_prompt = f"""{system}

CONVERSATION HISTORY:
{history_text}

USER: {message}
ASSISTANT:"""

    try:
        response = model.generate_content(full_prompt)
        return response.text.strip()
    except Exception as e:
        logger.error(f"Gemini chatbot error: {e}")
        return "I'm having trouble connecting right now. Please try again."