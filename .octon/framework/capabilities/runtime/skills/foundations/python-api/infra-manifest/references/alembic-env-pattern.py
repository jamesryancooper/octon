"""Alembic env.py pattern with psycopg URL normalization.

Key features:
- Reads POSTGRES_DSN or DATABASE_URL from environment
- Normalizes postgresql:// to postgresql+psycopg:// for SQLAlchemy + psycopg v3
- Uses NullPool for online migrations (avoids connection leaks)
- compare_type=True for detecting column type changes
"""

from __future__ import annotations

import os
from logging.config import fileConfig

from alembic import context
from sqlalchemy import engine_from_config
from sqlalchemy import pool


config = context.config

if config.config_file_name is not None:
    fileConfig(config.config_file_name)

target_metadata = None


def _normalize_sqlalchemy_url(raw_url: str) -> str:
    # .env.local uses postgresql://, but SQLAlchemy with psycopg v3
    # requires the explicit postgresql+psycopg:// dialect prefix.
    if raw_url.startswith("postgresql://"):
        return raw_url.replace("postgresql://", "postgresql+psycopg://", 1)
    return raw_url


def _configure_database_url() -> None:
    env_url = os.getenv("POSTGRES_DSN") or os.getenv("DATABASE_URL")
    if env_url:
        config.set_main_option("sqlalchemy.url", _normalize_sqlalchemy_url(env_url))


def run_migrations_offline() -> None:
    _configure_database_url()
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
        compare_type=True,
    )

    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online() -> None:
    _configure_database_url()
    connectable = engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    with connectable.connect() as connection:
        context.configure(
            connection=connection,
            target_metadata=target_metadata,
            compare_type=True,
        )

        with context.begin_transaction():
            context.run_migrations()


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
