from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    groq_api_key: str   # ✅ ADD THIS
    supabase_url: str
    supabase_service_role_key: str

    class Config:
        env_file = '.env'
        extra = 'ignore'

settings = Settings()

from supabase import create_client

supabase = create_client(
    settings.supabase_url,
    settings.supabase_service_role_key
)