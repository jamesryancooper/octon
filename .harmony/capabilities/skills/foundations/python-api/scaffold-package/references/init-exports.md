# `__init__.py` Export Conventions

Every `__init__.py` follows this pattern:

1. **Module docstring** describing the package's role.
2. **Imports** of public symbols from submodules.
3. **`__all__`** list enumerating exported names.

## Examples

### Package root (`src/{{PACKAGE_NAME}}/__init__.py`)

```python
"""{{PROJECT_NAME}} package."""
```

### `config/__init__.py`

```python
"""Typed configuration loading."""

from .settings import Settings, get_settings

__all__ = [
    "Settings",
    "get_settings",
]
```

### `observability/__init__.py`

```python
"""Structured logging and telemetry helpers."""

from .logging import (
    JsonLogFormatter,
    configure_structured_logging,
    get_correlation_id,
    set_correlation_id,
)

__all__ = [
    "JsonLogFormatter",
    "configure_structured_logging",
    "get_correlation_id",
    "set_correlation_id",
]
```

### `models/__init__.py`

```python
"""Contract-aligned domain models."""

from .base import ContractModel

__all__ = [
    "ContractModel",
]
```

### `api/__init__.py`

```python
"""Public HTTP contract and FastAPI entrypoints."""

from .app import app, create_app

__all__ = [
    "app",
    "create_app",
]
```

### Stub packages (`services/`, `workflows/`, `rendering/`)

```python
"""<Package description>."""
```

Keep stub `__init__.py` files minimal — just a docstring until the package
has public symbols to export.
