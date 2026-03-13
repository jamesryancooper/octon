"""Contract test patterns for the three contract test files.

Adapt these patterns to your specific contracts and fixtures.
"""

# ============================================================
# File 1: test_contract_schemas.py
# ============================================================
#
# Uses jsonschema Draft202012Validator to test fixtures against schemas.

from collections.abc import Callable

from jsonschema import Draft202012Validator


def _validator(schema: dict) -> Draft202012Validator:
    return Draft202012Validator(schema)


def _subschema_validator(schema: dict, *path: str) -> Draft202012Validator:
    """Navigate into a nested schema to validate a sub-object."""
    subschema = schema
    for key in path:
        subschema = subschema[key]
    return Draft202012Validator(subschema)


def _errors(validator: Draft202012Validator, instance: dict) -> list:
    return sorted(validator.iter_errors(instance), key=lambda err: list(err.path))


# Test that valid fixtures produce zero errors:
def test_entity_accepts_valid_fixture(
    load_contract_schema: Callable[[str], dict],
    load_contract_fixture: Callable[[str], dict],
) -> None:
    validator = _validator(load_contract_schema("entity-v1.schema.json"))
    instance = load_contract_fixture("entity.valid-minimal.json")
    assert _errors(validator, instance) == []


# Test that invalid fixtures produce expected errors:
def test_entity_rejects_invalid_fixture(
    load_contract_schema: Callable[[str], dict],
    load_contract_fixture: Callable[[str], dict],
) -> None:
    validator = _validator(load_contract_schema("entity-v1.schema.json"))
    instance = load_contract_fixture("entity.invalid-missing-required.json")
    errors = _errors(validator, instance)
    assert errors


# ============================================================
# File 2: test_openapi_contract.py
# ============================================================

from pathlib import Path


def test_openapi_contains_operational_probes(contracts_dir: Path) -> None:
    text = (contracts_dir / "openapi-v1.yaml").read_text(encoding="utf-8")
    assert "/healthz:" in text
    assert "/readyz:" in text


# ============================================================
# File 3: test_pydantic_contract_models.py
# ============================================================

import pytest
from pydantic import ValidationError

# from {{PACKAGE_NAME}}.api.contracts import ResourceSubmitRequest
# from {{PACKAGE_NAME}}.models import EntityModel


def test_model_accepts_minimum_valid_payload() -> None:
    payload = {
        "schema_version": "1.0.0",
        # ... fill required fields
    }
    # model = EntityModel.model_validate(payload)
    # assert model.schema_version == "1.0.0"


def test_model_accepts_contract_fixture(
    load_contract_fixture: Callable[[str], dict],
) -> None:
    payload = load_contract_fixture("entity.valid-full.json")
    # model = EntityModel.model_validate(payload)
    # assert model is not None
