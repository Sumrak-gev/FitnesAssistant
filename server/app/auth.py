from datetime import datetime, timedelta, timezone
from hashlib import sha256
from secrets import token_urlsafe
from threading import Lock
from time import monotonic
from uuid import UUID, uuid4

import jwt
from argon2 import PasswordHasher
from argon2.exceptions import VerificationError, InvalidHashError
from fastapi import APIRouter, Depends, HTTPException, Request, Response
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pydantic import BaseModel, ConfigDict, EmailStr, Field, SecretStr, field_validator
from sqlalchemy import func, select, update
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.config import get_settings
from app.database import get_session
from app.models import User, Device, RefreshToken

router = APIRouter(prefix="/auth", tags=["auth"])
hasher = PasswordHasher()
dummy_hash = hasher.hash(token_urlsafe(32))
bearer = HTTPBearer(auto_error=False)


class AuthInput(BaseModel):
    model_config = ConfigDict(extra="forbid")
    email: EmailStr
    password: SecretStr
    device_id: UUID
    device_name: str = Field(default="Android", min_length=1, max_length=120)

    @field_validator("password")
    @classmethod
    def password_length(cls, value):
        if not 10 <= len(value.get_secret_value()) <= 128:
            raise ValueError("Password length must be 10–128 characters")
        return value


class RegisterInput(AuthInput):
    display_name: str = Field(default="", max_length=100)


class RefreshInput(BaseModel):
    model_config = ConfigDict(extra="forbid")
    refresh_token: SecretStr
    device_id: UUID

    @field_validator("refresh_token")
    @classmethod
    def token_length(cls, value):
        if not 32 <= len(value.get_secret_value()) <= 256:
            raise ValueError("Invalid token")
        return value


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int
    user_id: UUID
    display_name: str


class RateLimiter:
    """Failed attempts by client IP and account; nginx adds a shared traffic cap."""
    def __init__(self):
        self.buckets = {}
        self.lock = Lock()

    def _keys(self, request: Request, account: str):
        address = request.client.host if request.client else "unknown"
        return (f"ip:{address}", f"account:{account.strip().lower()}")

    def check(self, request: Request, account: str):
        settings = get_settings()
        now = monotonic()
        with self.lock:
            self.buckets = {k: v for k, v in self.buckets.items() if v[0] > now}
            for key in self._keys(request, account):
                deadline, count = self.buckets.get(key, (now + settings.auth_window_seconds, 0))
                if count >= settings.auth_limit:
                    raise HTTPException(429, "Too many attempts", headers={"Retry-After": str(max(1, int(deadline - now)))})

    def failed(self, request: Request, account: str):
        settings = get_settings()
        now = monotonic()
        with self.lock:
            for key in self._keys(request, account):
                deadline, count = self.buckets.get(key, (now + settings.auth_window_seconds, 0))
                if len(self.buckets) < 20000 or key in self.buckets:
                    self.buckets[key] = (deadline, count + 1)


limiter = RateLimiter()


def unauthorized():
    return HTTPException(401, "Invalid credentials or session", headers={"WWW-Authenticate": "Bearer"})


def digest(token: str):
    return sha256(token.encode()).hexdigest()


def aware(value):
    return value.replace(tzinfo=timezone.utc) if value.tzinfo is None else value


def issue(session: Session, user: User, device: Device, family_id: UUID | None = None):
    settings = get_settings()
    now = datetime.now(timezone.utc)
    family_id = family_id or uuid4()
    raw = token_urlsafe(48)
    session.add(RefreshToken(device_id=device.id, family_id=family_id, token_hash=digest(raw),
                             expires_at=now + timedelta(days=settings.refresh_days)))
    access = jwt.encode({"sub": str(user.id), "device": str(device.id), "sid": str(family_id), "jti": str(uuid4()),
                         "iat": now, "exp": now + timedelta(minutes=settings.access_minutes),
                         "iss": "fitness-assistant", "aud": "fitness-android", "type": "access"},
                        settings.jwt_secret.get_secret_value(), algorithm="HS256")
    return TokenResponse(access_token=access, refresh_token=raw, user_id=user.id,
                         display_name=user.display_name, expires_in=settings.access_minutes * 60)


def attach_device(session, user, data):
    device = session.scalar(select(Device).where(Device.id == data.device_id).with_for_update())
    if device is not None and device.user_id != user.id:
        # IDs are scoped to an installation/account by the client. Never reassign ownership.
        raise HTTPException(409, "Device unavailable")
    if device is None:
        device = Device(id=data.device_id, user_id=user.id, name=data.device_name)
        session.add(device)
        session.flush()
    return device


@router.post("/register", response_model=TokenResponse, status_code=201)
def register(data: RegisterInput, response: Response, request: Request, session: Session = Depends(get_session)):
    limiter.check(request, str(data.email))
    user = User(email=str(data.email).lower(), display_name=data.display_name.strip(),
                password_hash=hasher.hash(data.password.get_secret_value()))
    try:
        session.add(user)
        session.flush()
        result = issue(session, user, attach_device(session, user, data))
        session.commit()
    except IntegrityError:
        session.rollback()
        limiter.failed(request, str(data.email))
        raise HTTPException(409, "Account or device unavailable") from None
    response.headers["Cache-Control"] = "no-store"
    return result


@router.post("/login", response_model=TokenResponse)
def login(data: AuthInput, response: Response, request: Request, session: Session = Depends(get_session)):
    limiter.check(request, str(data.email))
    user = session.scalar(select(User).where(func.lower(User.email) == str(data.email).lower(),
                                            User.deleted_at.is_(None), User.is_active.is_(True)))
    try:
        hasher.verify(user.password_hash if user else dummy_hash, data.password.get_secret_value())
    except (VerificationError, InvalidHashError):
        limiter.failed(request, str(data.email))
        raise unauthorized() from None
    if user is None:
        limiter.failed(request, str(data.email))
        raise unauthorized()
    if hasher.check_needs_rehash(user.password_hash):
        user.password_hash = hasher.hash(data.password.get_secret_value())
    try:
        device = attach_device(session, user, data)
        # A new login replaces previous sessions on this installation/account.
        session.execute(update(RefreshToken).where(RefreshToken.device_id == device.id,
            RefreshToken.revoked_at.is_(None)).values(revoked_at=datetime.now(timezone.utc)))
        result = issue(session, user, device)
        session.commit()
    except IntegrityError:
        session.rollback()
        raise HTTPException(409, "Device unavailable") from None
    response.headers["Cache-Control"] = "no-store"
    return result


def refresh_session(data, session):
    # Lock before reading token state: simultaneous refreshes cannot mint two children.
    device = session.scalar(select(Device).where(Device.id == data.device_id).with_for_update())
    token = session.scalar(select(RefreshToken).where(RefreshToken.token_hash == digest(data.refresh_token.get_secret_value())))
    if device is None or token is None or token.device_id != device.id:
        raise unauthorized()
    if token.revoked_at is not None:
        session.execute(update(RefreshToken).where(RefreshToken.family_id == token.family_id).values(revoked_at=datetime.now(timezone.utc)))
        session.commit()  # Replay revocation must survive the subsequent 401.
        raise unauthorized()
    if aware(token.expires_at) <= datetime.now(timezone.utc):
        raise unauthorized()
    user = session.get(User, device.user_id)
    if not user or not user.is_active or user.deleted_at is not None:
        raise unauthorized()
    return user, device, token


@router.post("/refresh", response_model=TokenResponse)
def refresh(data: RefreshInput, response: Response, request: Request, session: Session = Depends(get_session)):
    limiter.check(request, str(data.device_id))
    try:
        user, device, token = refresh_session(data, session)
    except HTTPException:
        limiter.failed(request, str(data.device_id))
        raise
    token.revoked_at = datetime.now(timezone.utc)
    result = issue(session, user, device, token.family_id)
    session.commit()
    response.headers["Cache-Control"] = "no-store"
    return result


@router.post("/logout", status_code=204)
def logout(data: RefreshInput, request: Request, session: Session = Depends(get_session)):
    limiter.check(request, str(data.device_id))
    try:
        _, _, token = refresh_session(data, session)
    except HTTPException:
        limiter.failed(request, str(data.device_id))
        raise
    session.execute(update(RefreshToken).where(RefreshToken.family_id == token.family_id).values(revoked_at=datetime.now(timezone.utc)))
    session.commit()


def current_session(credentials: HTTPAuthorizationCredentials | None = Depends(bearer), session: Session = Depends(get_session)):
    if credentials is None:
        raise unauthorized()
    try:
        claims = jwt.decode(credentials.credentials, get_settings().jwt_secret.get_secret_value(),
                            algorithms=["HS256"], issuer="fitness-assistant", audience="fitness-android",
                            options={"require": ["exp", "iat", "sub", "device", "sid", "type"]})
        if claims["type"] != "access":
            raise ValueError()
        user_id, device_id, family_id = UUID(claims["sub"]), UUID(claims["device"]), UUID(claims["sid"])
    except (jwt.PyJWTError, ValueError, TypeError):
        raise unauthorized() from None
    device = session.scalar(select(Device).where(Device.id == device_id, Device.user_id == user_id))
    user = session.get(User, user_id)
    live = session.scalar(select(RefreshToken.id).where(RefreshToken.device_id == device_id,
        RefreshToken.family_id == family_id, RefreshToken.revoked_at.is_(None),
        RefreshToken.expires_at > datetime.now(timezone.utc)).limit(1))
    if device is None or user is None or not user.is_active or user.deleted_at is not None or live is None:
        raise unauthorized()
    return user, device
