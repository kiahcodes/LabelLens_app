from fastapi import APIRouter
from ..schemas.scan_schemas import ChatbotRequest
from ..services.gemini_service import chatbot_response
from ..services.translate_service import translate_text
import logging

router = APIRouter(tags=['chatbot'])
logger = logging.getLogger(__name__)


@router.post('/chatbot')
async def chatbot(request: ChatbotRequest):
    try:
        response_text = await chatbot_response(
            message=request.message,
            scan_context=request.scan_context,
            user_profile=request.user_profile,
            conversation_history=request.conversation_history,
        )
        translated = response_text
        if request.target_language == 'hi':
            translated = await translate_text(response_text, 'hi')

        return {
            'response_text': response_text,
            'translated_text': translated,
        }
    except Exception as e:
        logger.error(f'Chatbot error: {e}')
        return {
            'response_text': 'Sorry, could not process that. Please try again.',
            'translated_text': 'Sorry, could not process that. Please try again.',
        }