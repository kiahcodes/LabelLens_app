from google import genai

client = genai.Client(api_key="AIzaSyCjBg8qzKcdOFpm1yF-S72gI8A1c3XMKNw")

response = client.models.generate_content(
    model="gemini-2.5-flash",
    contents="Say hello in 5 words"
)

print(response.text)