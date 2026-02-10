"""Root conftest.py pattern with session-scoped fixtures for schema and fixture loading.

This conftest provides reusable fixtures for loading JSON schemas from
docs/contracts/ and test fixtures from tests/contracts/fixtures/.
"""

import json
from collections.abc import Callable
from pathlib import Path

import pytest


@pytest.fixture(scope="session")
def repo_root() -> Path:
    return Path(__file__).resolve().parents[1]


@pytest.fixture(scope="session")
def contracts_dir(repo_root: Path) -> Path:
    return repo_root / "docs" / "contracts"


@pytest.fixture(scope="session")
def contract_fixtures_dir() -> Path:
    return Path(__file__).resolve().parent / "contracts" / "fixtures"


@pytest.fixture(scope="session")
def load_json() -> Callable[[Path], dict]:
    def _load(path: Path) -> dict:
        return json.loads(path.read_text(encoding="utf-8"))

    return _load


@pytest.fixture(scope="session")
def load_contract_schema(
    contracts_dir: Path,
    load_json: Callable[[Path], dict],
) -> Callable[[str], dict]:
    def _load(name: str) -> dict:
        return load_json(contracts_dir / name)

    return _load


@pytest.fixture(scope="session")
def load_contract_fixture(
    contract_fixtures_dir: Path,
    load_json: Callable[[Path], dict],
) -> Callable[[str], dict]:
    def _load(name: str) -> dict:
        return load_json(contract_fixtures_dir / name)

    return _load
