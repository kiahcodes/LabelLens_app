# from google import genai

# client = genai.Client(api_key="AIzaSyCjBg8qzKcdOFpm1yF-S72gI8A1c3XMKNw")

# response = client.models.generate_content(
#     model="gemini-2.5-flash",
#     contents="Say hello in 5 words"
# )

# print(response.text)

from app.services.gemini_service import analyze_product
import asyncio

async def test():
    result = await analyze_product(
        ocr_text="Sugar, Palm Oil, TBHQ",
        product_type="food",
        user_profile={}
    )
    print(result)

asyncio.run(test())