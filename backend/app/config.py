from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    gemini_api_key: str
    supabase_url: str
    supabase_service_role_key: str  # Use service role for server-side operations
    libretranslate_url: str = "https://your-libretranslate.onrender.com"

    class Config:
        env_file = ".env"

settings = Settings()