from typing import Optional

from fastapi import APIRouter, Header, HTTPException
from supabase import create_client

from ..config import settings

router = APIRouter(tags=['account'])
supabase = create_client(
    settings.supabase_url,
    settings.supabase_service_role_key,
)


def _user_id_from_token(authorization: Optional[str]) -> str:
    if not authorization or not authorization.startswith('Bearer '):
        raise HTTPException(
            status_code=401,
            detail='Missing or invalid authorization header',
        )

    token = authorization.removeprefix('Bearer ').strip()
    if not token:
        raise HTTPException(status_code=401, detail='Missing access token')

    try:
        response = supabase.auth.get_user(token)
    except Exception as exc:
        raise HTTPException(
            status_code=401,
            detail='Invalid or expired access token',
        ) from exc

    if not response or not response.user:
        raise HTTPException(status_code=401, detail='Invalid access token')

    return response.user.id


@router.delete('/account')
async def delete_account(
    authorization: Optional[str] = Header(None),
):
    """Permanently delete the authenticated user and all related data."""
    user_id = _user_id_from_token(authorization)

    try:
        supabase.auth.admin.delete_user(user_id)
    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail=f'Failed to delete account: {exc}',
        ) from exc

    return {'status': 'deleted', 'user_id': user_id}
