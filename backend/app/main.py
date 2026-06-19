# from fastapi import FastAPI
# from fastapi.middleware.cors import CORSMiddleware
# from .routers import scan, chatbot, translate, history, notifications, alternatives
# from .config import settings

# app = FastAPI(title="SafeScan API", version="1.0.0")

# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],  # Restrict to your Flutter app domain in production
#     allow_credentials=True,
#     allow_methods=["*"],
#     allow_headers=["*"],
# )

# app.include_router(scan.router)
# app.include_router(chatbot.router)
# app.include_router(translate.router)
# app.include_router(history.router)
# app.include_router(notifications.router)
# app.include_router(alternatives.router)

# @app.get("/health")
# async def health():
#     return {"status": "ok", "version": "1.0.0"}
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from .routers import scan, chatbot, history, account
import asyncio

app = FastAPI(title='SafeScan API', version='1.0.0')

app.add_middleware(
    CORSMiddleware,
    allow_origins=['*'],
    allow_credentials=True,
    allow_methods=['*'],
    allow_headers=['*'],
)

app.include_router(scan.router)
app.include_router(chatbot.router)
app.include_router(history.router)
app.include_router(account.router)

@app.get('/health')
def health():
    return {'status': 'ok', 'version': '1.0.0'}

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=500,
        content={'detail': f'Internal error: {str(exc)}'}
    )