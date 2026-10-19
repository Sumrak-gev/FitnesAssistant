from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

from app.database import check_database

app = FastAPI(title="Fitness Assistant API", version="0.1.0")


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
