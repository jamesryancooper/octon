"""Structured logging helpers with correlation ID propagation.

Pattern: JSON log formatter with context-variable-based correlation IDs
for async-safe request tracing. Optional fields (trace_id, span_id, etc.)
are included only when attached to the LogRecord.
"""

from __future__ import annotations

import json
import logging
from contextvars import ContextVar
from datetime import UTC, datetime
from typing import Any

_correlation_id: ContextVar[str | None] = ContextVar("correlation_id", default=None)


def set_correlation_id(value: str | None) -> None:
    """Attach a correlation id to the current execution context."""

    _correlation_id.set(value)


def get_correlation_id() -> str | None:
    """Read the active correlation id from the current execution context."""

    return _correlation_id.get()


class JsonLogFormatter(logging.Formatter):
    """Emit logs in newline-delimited JSON."""

    def format(self, record: logging.LogRecord) -> str:
        payload: dict[str, Any] = {
            "timestamp": datetime.now(UTC).isoformat(),
            "level": record.levelname.lower(),
            "logger": record.name,
            "message": record.getMessage(),
        }

        correlation_id = get_correlation_id()
        if correlation_id is not None:
            payload["correlation_id"] = correlation_id

        for optional_field in ("trace_id", "span_id", "job_id", "component"):
            value = getattr(record, optional_field, None)
            if value is not None:
                payload[optional_field] = value

        if record.exc_info:
            payload["exception"] = self.formatException(record.exc_info)

        return json.dumps(payload, separators=(",", ":"))


def configure_structured_logging(level: int = logging.INFO) -> None:
    """Configure root logger to emit structured JSON logs."""

    handler = logging.StreamHandler()
    handler.setFormatter(JsonLogFormatter())

    root_logger = logging.getLogger()
    root_logger.handlers.clear()
    root_logger.setLevel(level)
    root_logger.addHandler(handler)
