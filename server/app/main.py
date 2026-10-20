from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from sqlalchemy.exc import SQLAlchemyError
from contextlib import asynccontextmanager
from typing import Any

from app.database import check_database
from app.config import get_settings
from app.auth import router as auth_router
from app.sync import router as sync_router


@asynccontextmanager
async def lifespan(app):
    get_settings()  # Fail startup if database credentials or signing secret are absent.
    yield


class ErrorResponse(BaseModel):
    detail: str | dict[str, Any]


app = FastAPI(title="Fitness Assistant API", version="0.2.0", lifespan=lifespan,
    responses={code: {"model": ErrorResponse} for code in (401, 409, 410, 422, 429, 503)})
app.include_router(auth_router)
app.include_router(sync_router)


class SettingsCORS:
    def __init__(self, app):
        self.app = app

    async def __call__(self, scope, receive, send):
        if scope["type"] == "http" and any(key == b"origin" for key, _ in scope["headers"]):
            middleware = CORSMiddleware(self.app, allow_origins=get_settings().cors_origins,
                allow_methods=["GET", "POST"], allow_headers=["Authorization", "Content-Type"])
            return await middleware(scope, receive, send)
        return await self.app(scope, receive, send)


app.add_middleware(SettingsCORS)


@app.exception_handler(RequestValidationError)
async def validation_error(request, exc):
    # FastAPI's default validation response includes rejected input, including passwords.
    return JSONResponse(status_code=422, content={"detail": "Invalid request"})


@app.exception_handler(SQLAlchemyError)
async def database_error(request, exc):
    return JSONResponse(status_code=503, content={"detail": "Database unavailable"})


class HealthResponse(BaseModel):
    status: str


@app.get("/health", response_model=HealthResponse, tags=["health"])
def health() -> HealthResponse:
    """Liveness: this process can serve requests without a database connection."""
    return HealthResponse(status="ok")


@app.get("/health/db", response_model=HealthResponse, tags=["health"])
def database_health() -> HealthResponse:
    """Readiness: verify the configured PostgreSQL connection."""
    try:
        check_database()
    except Exception:
        # Do not expose DSNs, credentials, hostnames or driver error messages.
        raise HTTPException(status_code=503, detail="Database unavailable") from None
    return HealthResponse(status="ok")
