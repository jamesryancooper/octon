"""Contract test patterns covering three test tiers.

These patterns are drawn from a production project and should be adapted
to your specific contracts and fixtures.
"""

# ============================================================
# Pattern 1: JSON Schema validation (test_contract_schemas.py)
# ============================================================
#
# Uses jsonschema library with Draft202012Validator.
# Tests that fixtures conform to (or violate) JSON schemas.

from collections.abc import Callable

from jsonschema import Draft202012Validator


def _validator(schema: dict) -> Draft202012Validator:
    return Draft202012Validator(schema)


def _subschema_validator(schema: dict, *path: str) -> Draft202012Validator:
    subschema = schema
    for key in path:
        subschema = subschema[key]
    return Draft202012Validator(subschema)


def _errors(validator: Draft202012Validator, instance: dict) -> list:
    return sorted(validator.iter_errors(instance), key=lambda err: list(err.path))


def test_entity_accepts_valid_fixture(
    load_contract_schema: Callable[[str], dict],
    load_contract_fixture: Callable[[str], dict],
) -> None:
    validator = _validator(load_contract_schema("entity-v1.schema.json"))
    instance = load_contract_fixture("entity.valid-minimal.json")

    assert _errors(validator, instance) == []


def test_entity_rejects_invalid_fixture(
    load_contract_schema: Callable[[str], dict],
    load_contract_fixture: Callable[[str], dict],
) -> None:
    validator = _validator(load_contract_schema("entity-v1.schema.json"))
    instance = load_contract_fixture("entity.invalid-missing-required.json")

    errors = _errors(validator, instance)
    assert errors  # at least one validation error


# ============================================================
# Pattern 2: OpenAPI contract checks (test_openapi_contract.py)
# ============================================================
#
# Text-based assertions on the OpenAPI YAML file to verify
# endpoint presence and enum consistency.

from pathlib import Path


def test_openapi_contains_operational_probe_endpoints(contracts_dir: Path) -> None:
    openapi_path = contracts_dir / "openapi-v1.yaml"
    text = openapi_path.read_text(encoding="utf-8")

    assert "/healthz:" in text
    assert "/readyz:" in text


def test_openapi_contains_resource_endpoints(contracts_dir: Path) -> None:
    openapi_path = contracts_dir / "openapi-v1.yaml"
    text = openapi_path.read_text(encoding="utf-8")

    # Assert your versioned paths are present:
    assert "/v1/resources:" in text
    assert "/v1/resources/{resource_id}:" in text


# ============================================================
# Pattern 3: Pydantic model tests (test_pydantic_contract_models.py)
# ============================================================
#
# Tests that Pydantic models accept valid fixtures and reject
# invalid ones, ensuring models align with JSON schemas.

import pytest
from pydantic import ValidationError

# from {{PACKAGE_NAME}}.api.contracts import ResourceSubmitRequest
# from {{PACKAGE_NAME}}.models import EntityModel


def test_model_accepts_valid_payload() -> None:
    payload = {
        "schema_version": "1.0.0",
        # ... minimal required fields
    }

    # model = EntityModel.model_validate(payload)
    # assert model.schema_version == "1.0.0"


def test_model_accepts_fixture(
    load_contract_fixture: Callable[[str], dict],
) -> None:
    payload = load_contract_fixture("entity.valid-full.json")

    # model = EntityModel.model_validate(payload)
    # assert model is not None


def test_request_model_rejects_duplicates() -> None:
    with pytest.raises(ValidationError):
        pass
        # ResourceSubmitRequest.model_validate({
        #     "prompt": "hello",
        #     "output_formats": ["ansi", "ansi"],  # duplicate
        # })
