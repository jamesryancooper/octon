"""Typed application settings loaded from environment variables.

Pattern: pydantic-settings BaseSettings with aliased fields, SecretStr for
secrets, URL types for connection strings, and a cached singleton accessor.

Adapt the fields below to match your declared infrastructure dependencies.
"""

from __future__ import annotations

from functools import lru_cache
from typing import Annotated, Literal

from pydantic import AnyUrl, Field, PostgresDsn, RedisDsn, SecretStr, StringConstraints
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Validated runtime settings for local/dev/prod environments."""

    model_config = SettingsConfigDict(
        env_file=".env.local",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    app_env: Literal["local", "dev", "staging", "prod"] = Field(
        default="local", alias="APP_ENV"
    )

    # --- Include fields matching declared infrastructure dependencies ---

    # postgres
    postgres_dsn: PostgresDsn = Field(alias="POSTGRES_DSN")

    # nats
    nats_url: AnyUrl = Field(alias="NATS_URL")

    # redis
    redis_url: RedisDsn = Field(alias="REDIS_URL")

    # temporal
    temporal_hostport: Annotated[
        str,
        StringConstraints(pattern=r"^[A-Za-z0-9.-]+:[0-9]{2,5}$"),
    ] = Field(alias="TEMPORAL_HOSTPORT")

    # s3 / minio
    s3_endpoint: AnyUrl = Field(alias="S3_ENDPOINT")
    s3_access_key: Annotated[str, StringConstraints(min_length=1)] = Field(
        alias="S3_ACCESS_KEY"
    )
    s3_secret_key: SecretStr = Field(alias="S3_SECRET_KEY")
    s3_bucket: Annotated[
        str,
        StringConstraints(pattern=r"^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$"),
    ] = Field(alias="S3_BUCKET")


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    """Return cached validated settings instance."""

    return Settings()  # type: ignore[call-arg]
