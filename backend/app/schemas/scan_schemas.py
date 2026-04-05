from pydantic import BaseModel
from typing import Optional

class UserProfile(BaseModel):
    allergies: list[str] = []
    is_pregnant: bool = False
    baby_mode: bool = False
    dietary_restrictions: list[str] = []
    skin_type: Optional[str] = None
    preferred_language: str = 'en'

class ScanRequest(BaseModel):
    ocr_text: str
    product_type: str
    user_profile: UserProfile
    user_id: str

class ChatbotRequest(BaseModel):
    message: str
    scan_context: str
    user_profile: dict
    conversation_history: list[dict] = []
    target_language: str = 'en'