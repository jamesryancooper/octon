"""Pydantic contract model patterns for the public API.

Pattern: All API payloads inherit ContractModel (extra="forbid"). Use Annotated
types with StringConstraints for pattern validation, Literal for enums, and Field
for defaults and numeric constraints. Add @field_validator for cross-field rules.
"""

from __future__ import annotations

from datetime import datetime
from typing import Annotated, Literal

from pydantic import AnyUrl, Field, StringConstraints, field_validator

# Import from your project's models.base module:
# from {{PACKAGE_NAME}}.models.base import ContractModel

from pydantic import BaseModel, ConfigDict


class ContractModel(BaseModel):
    """Strict pydantic model used for frozen contract payloads."""

    model_config = ConfigDict(extra="forbid")


# --- Type aliases for constrained identifiers ---

ResourceId = Annotated[str, StringConstraints(pattern=r"^res_[A-Za-z0-9]+$")]
OutputFormat = Literal["ansi", "gif", "mp4", "usd", "glb"]


# --- Request models ---


class ResourceSubmitRequest(ContractModel):
    """Example request model with field constraints."""

    prompt: Annotated[str, StringConstraints(min_length=1, max_length=2000)]
    style: str = "default"
    seed: int | None = Field(default=None, ge=0)
    duration_seconds: int = Field(default=6, ge=1, le=30)
    output_formats: list[OutputFormat] = Field(
        default_factory=lambda: ["ansi", "gif"], min_length=1
    )

    @field_validator("output_formats")
    @classmethod
    def validate_unique_output_formats(
        cls,
        value: list[OutputFormat],
    ) -> list[OutputFormat]:
        if len(set(value)) != len(value):
            raise ValueError("output_formats must not contain duplicates")
        return value


# --- Response models ---


class ErrorResponse(ContractModel):
    """Standard error envelope."""

    code: str
    message: str
    category: (
        Literal["validation", "authn", "authz", "rate_limit", "transient", "fatal"] | None
    ) = None
    retryable: bool = False
    details: dict[str, object] | None = None


class ResourceResponse(ContractModel):
    """Example response model with lifecycle state."""

    resource_id: str
    status: Literal["accepted", "queued", "running", "succeeded", "failed", "canceled"]
    progress: float = Field(ge=0, le=1)
    created_at: datetime
    updated_at: datetime | None = None
    error: ErrorResponse | None = None


# --- Operational response models ---


class HealthResponse(ContractModel):
    status: Literal["ok"] = "ok"
    service: str = "{{PROJECT_NAME}}-api"
    version: str = "1.0.0"


class ReadyResponse(ContractModel):
    status: Literal["ready", "not_ready"]
    checks: dict[str, Literal["ok", "degraded", "down"]]
