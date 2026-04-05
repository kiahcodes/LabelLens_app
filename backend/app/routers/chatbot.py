# from fastapi import APIRouter, HTTPException
# from pydantic import BaseModel
# from typing import Optional
# from ..services.gemini_service import chatbot_response
# from ..services.translate_service import translate_text

# router = APIRouter(tags=["chatbot"])


# class ChatbotRequest(BaseModel):
#     message: str
#     scan_context: str
#     user_profile: dict
#     conversation_history: list[dict] = []
#     target_language: str = "en"


# @router.post("/chatbot")
# async def chatbot(request: ChatbotRequest):
#     try:
#         response_text = await chatbot_response(
#             message=request.message,
#             scan_context=request.scan_context,
#             user_profile=request.user_profile,
#             conversation_history=request.conversation_history,
#         )

#         translated = response_text
#         if request.target_language != "en":
#             translated = await translate_text(response_text, request.target_language)

#         return {
#             "response_text": response_text,
#             "translated_text": translated,
#         }
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=str(e))

from fastapi import APIRouter
from ..schemas.scan_schemas import ChatbotRequest
from ..services.translate_service import translate_text

router = APIRouter(tags=['chatbot'])

@router.post('/chatbot')
async def chatbot(request: ChatbotRequest):
    # Mock response for now
    response_text = 'I can help you understand this product. Real AI coming soon!'

    translated = response_text
    if request.target_language != 'en':
        translated = await translate_text(response_text, request.target_language)

    return {
        'response_text': response_text,
        'translated_text': translated,
    }