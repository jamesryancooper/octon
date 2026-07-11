#!/usr/bin/env python3
"""Validate the Revision 2 evidence appendix schema and semantic invariants."""

from __future__ import annotations

import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

import yaml
from jsonschema import Draft202012Validator, FormatChecker


PACKET_ROOT = Path(__file__).resolve().parent.parent
APPENDIX_PATH = PACKET_ROOT / "resources" / "evidence-appendix.yml"
SCHEMA_PATH = PACKET_ROOT / "resources" / "evidence-appendix-v1.schema.json"
REPO_ROOT = next(
    parent for parent in PACKET_ROOT.parents if (parent / ".git").exists()
)
EXTERNAL_PREFIXES = ("https://", "http://", "github://")
SHA256_PATTERN = re.compile(r"sha256:([0-9a-f]{64})(?![0-9a-f])")


def fail(messages: list[str]) -> None:
    for message in messages:
        print(f"ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def local_path(raw: str) -> Path | None:
    """Resolve a repository-local evidence path, or return None for external evidence."""
    if raw.startswith(EXTERNAL_PREFIXES):
        return None
    candidate = (REPO_ROOT / raw).resolve()
    try:
        candidate.relative_to(REPO_ROOT.resolve())
    except ValueError as error:
        raise ValueError(f"path escapes repository root: {raw}") from error
    return candidate


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> None:
    with SCHEMA_PATH.open(encoding="utf-8") as handle:
        schema = json.load(handle)
    with APPENDIX_PATH.open(encoding="utf-8") as handle:
        appendix = yaml.safe_load(handle)

    validator = Draft202012Validator(schema, format_checker=FormatChecker())
    schema_errors = sorted(
        validator.iter_errors(appendix),
        key=lambda error: tuple(str(part) for part in error.absolute_path),
    )
    if schema_errors:
        fail(
            [
                f"{'/'.join(str(part) for part in error.absolute_path) or '<root>'}: "
                f"{error.message}"
                for error in schema_errors
            ]
        )

    findings = appendix["findings"]
    expected_commit = appendix["repository_commit"]
    expected_environment = appendix["environment"]["environment_id"]
    expected_host = appendix["environment"]["host"]
    semantic_errors: list[str] = []
    seen_ids: set[str] = set()

    actual_commit = subprocess.run(
        ["git", "-C", str(REPO_ROOT), "rev-parse", "HEAD"],
        check=True,
        capture_output=True,
        text=True,
    ).stdout.strip()
    if actual_commit != expected_commit:
        semantic_errors.append(
            "appendix repository_commit does not match current repository HEAD: "
            f"{expected_commit} != {actual_commit}"
        )

    for index, finding in enumerate(findings):
        finding_id = finding["finding_id"]
        prefix = f"findings[{index}] {finding_id}"
        if finding_id in seen_ids:
            semantic_errors.append(f"{prefix}: duplicate finding_id")
        seen_ids.add(finding_id)

        if finding["repository_commit"] != expected_commit:
            semantic_errors.append(
                f"{prefix}: repository_commit differs from appendix repository_commit"
            )
        if finding["environment_id"] != expected_environment:
            semantic_errors.append(
                f"{prefix}: environment_id differs from appendix environment"
            )
        if finding["host"] != expected_host:
            semantic_errors.append(f"{prefix}: host differs from appendix environment")

        declared_digests: set[str] = set()
        for value in finding["configuration_digests"]:
            matches = SHA256_PATTERN.findall(value)
            if not matches:
                semantic_errors.append(
                    f"{prefix}: configuration_digest has no sha256:<64 lowercase hex> binding: {value}"
                )
            declared_digests.update(matches)

        for raw_path in finding["configuration_paths"]:
            try:
                path = local_path(raw_path)
            except ValueError as error:
                semantic_errors.append(f"{prefix}: {error}")
                continue
            if path is None:
                continue
            if not path.exists():
                semantic_errors.append(
                    f"{prefix}: configuration_path does not exist: {raw_path}"
                )
                continue
            if path.is_file():
                actual_digest = sha256_file(path)
                if actual_digest not in declared_digests:
                    semantic_errors.append(
                        f"{prefix}: current sha256 for {raw_path} is not recorded: "
                        f"sha256:{actual_digest}"
                    )

        for raw_ref in finding["file_refs"]:
            if raw_ref.startswith(EXTERNAL_PREFIXES):
                continue
            match = re.fullmatch(r"(.+):([1-9][0-9]*)", raw_ref)
            ref_path = match.group(1) if match else raw_ref
            line_number = int(match.group(2)) if match else None
            try:
                path = local_path(ref_path)
            except ValueError as error:
                semantic_errors.append(f"{prefix}: {error}")
                continue
            if path is None:
                continue
            if not path.exists():
                semantic_errors.append(f"{prefix}: file_ref does not exist: {raw_ref}")
                continue
            if line_number is not None:
                if not path.is_file():
                    semantic_errors.append(
                        f"{prefix}: line-qualified file_ref is not a file: {raw_ref}"
                    )
                    continue
                with path.open(encoding="utf-8", errors="replace") as handle:
                    line_count = sum(1 for _ in handle)
                if line_number > line_count:
                    semantic_errors.append(
                        f"{prefix}: file_ref line {line_number} exceeds "
                        f"{ref_path} line count {line_count}"
                    )

        if finding["fact_class"] == "architectural_inference":
            overclaimed = {"dynamic", "adversarial"}.intersection(
                finding["evidence_type"]
            )
            if overclaimed:
                semantic_errors.append(
                    f"{prefix}: architectural_inference may not claim "
                    f"{', '.join(sorted(overclaimed))} evidence"
                )

    if semantic_errors:
        fail(semantic_errors)

    print(
        "validated evidence appendix: "
        f"findings={len(findings)} schema=draft-2020-12 "
        "source_bindings=pass semantic_invariants=pass"
    )


if __name__ == "__main__":
    main()
