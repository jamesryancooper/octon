"""FastAPI app factory with operational probe endpoints.

Pattern: A create_app() factory that registers /healthz and /readyz before
any domain routes. Health and ready responses use ContractModel for strict
schema compliance.
"""

from __future__ import annotations

from typing import Literal

from fastapi import FastAPI, status
from pydantic import ConfigDict, Field

from {{PACKAGE_NAME}}.models.base import ContractModel


class HealthResponse(ContractModel):
    status: Literal["ok"] = "ok"
    service: str = "{{PROJECT_NAME}}-api"
    version: str = "1.0.0"


class ReadyResponse(ContractModel):
    status: Literal["ready", "not_ready"]
    checks: dict[str, Literal["ok", "degraded", "down"]]


def create_app() -> FastAPI:
    """Create a minimal API app with operational probe endpoints."""

    app = FastAPI(
        title="{{PROJECT_TITLE}} API",
        version="1.0.0",
        summary="v1 asynchronous API for {{PROJECT_DESCRIPTION}}.",
    )

    @app.get(
        "/healthz",
        response_model=HealthResponse,
        tags=["ops"],
        summary="Liveness probe endpoint.",
    )
    async def healthz() -> HealthResponse:
        return HealthResponse()

    @app.get(
        "/readyz",
        response_model=ReadyResponse,
        responses={status.HTTP_503_SERVICE_UNAVAILABLE: {"model": ReadyResponse}},
        tags=["ops"],
        summary="Readiness probe endpoint.",
    )
    async def readyz() -> ReadyResponse:
        return ReadyResponse(status="ready", checks={"config": "ok"})

    return app


app = create_app()
