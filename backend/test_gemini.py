# from google import genai

# client = genai.Client(api_key="AIzaSyCjBg8qzKcdOFpm1yF-S72gI8A1c3XMKNw")

# response = client.models.generate_content(
#     model="gemini-2.5-flash",
#     contents="Say hello in 5 words"
# )

# print(response.text)

from app.services.gemini_service import _call_gemini_sync
from app.utils.json_parser import safe_parse_json

def test():
    print("Calling Gemini... (takes 5-10 seconds)")
    
    raw = _call_gemini_sync(
        "List 3 common food ingredients as a JSON array. "
        "Example format: [\"Sugar\", \"Salt\", \"Water\"]. "
        "Return ONLY the JSON array."
    )
    print("Raw response:", raw)
    print("Gemini is working!")

test()