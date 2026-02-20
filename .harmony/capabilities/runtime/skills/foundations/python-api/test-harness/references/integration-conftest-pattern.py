"""Integration conftest.py pattern with environment-gated fixtures.

Integration tests require RUN_INTEGRATION_TESTS=1 and use docker-compose
services. Fixtures provide database engines, message queue URLs, and
S3-compatible HTTP clients.

Adapt the IntegrationEndpoints fields and fixture set to match your
declared infrastructure dependencies.
"""

from __future__ import annotations

import os
from collections.abc import Iterator
from dataclasses import dataclass

import httpx
import pytest
from sqlalchemy import create_engine, text
from sqlalchemy.engine import Connection, Engine


@dataclass(frozen=True)
class IntegrationEndpoints:
    # Include only the services your project declares:
    postgres_dsn: str
    nats_url: str
    s3_endpoint: str


@pytest.fixture(scope="session")
def integration_enabled() -> bool:
    return os.getenv("RUN_INTEGRATION_TESTS") == "1"


@pytest.fixture(scope="session")
def require_integration(integration_enabled: bool) -> None:
    if not integration_enabled:
        pytest.skip("set RUN_INTEGRATION_TESTS=1 to run integration tests")


@pytest.fixture(scope="session")
def integration_endpoints() -> IntegrationEndpoints:
    return IntegrationEndpoints(
        postgres_dsn=os.getenv(
            "POSTGRES_DSN",
            "postgresql://postgres:postgres@localhost:5432/{{DB_NAME}}",
        ),
        nats_url=os.getenv("NATS_URL", "nats://localhost:4222"),
        s3_endpoint=os.getenv("S3_ENDPOINT", "http://localhost:9000"),
    )


# --- Database fixtures (include if postgres is declared) ---


@pytest.fixture(scope="session")
def db_engine(
    require_integration: None,
    integration_endpoints: IntegrationEndpoints,
) -> Iterator[Engine]:
    engine = create_engine(integration_endpoints.postgres_dsn, pool_pre_ping=True)

    try:
        with engine.connect() as connection:
            connection.execute(text("SELECT 1"))
    except Exception as exc:
        pytest.skip(f"postgres is not reachable for integration tests: {exc}")

    yield engine
    engine.dispose()


@pytest.fixture()
def db_connection(db_engine: Engine) -> Iterator[Connection]:
    with db_engine.connect() as connection:
        yield connection


# --- NATS fixtures (include if nats is declared) ---


@pytest.fixture(scope="session")
def nats_url(
    require_integration: None,
    integration_endpoints: IntegrationEndpoints,
) -> str:
    return integration_endpoints.nats_url


# --- S3 fixtures (include if s3/minio is declared) ---


@pytest.fixture(scope="session")
def s3_http_client(
    require_integration: None,
    integration_endpoints: IntegrationEndpoints,
) -> Iterator[httpx.Client]:
    with httpx.Client(base_url=integration_endpoints.s3_endpoint, timeout=2.0) as client:
        yield client
