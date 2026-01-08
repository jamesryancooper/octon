from __future__ import annotations

from pathlib import Path

import pytest

from ..run import (
    run_assessment_from_canonical_prompt,
    validate_canonical_prompt,
)

REPO_ROOT = Path(__file__).resolve().parents[5]
CANONICAL_PROMPT = (
    REPO_ROOT / "packages/workflows/architecture_assessment/00-overview.md"
)
WORKFLOW_MANIFEST = (
    REPO_ROOT / "packages/workflows/architecture_assessment/manifest.yaml"
)


def test_validate_canonical_prompt_requires_title_and_description() -> None:
    meta = validate_canonical_prompt(CANONICAL_PROMPT)

    assert meta["title"] == "Harmony Architecture Assessment"
    assert meta["description"].startswith("Guide for assessing")


def test_validate_canonical_prompt_errors_when_frontmatter_missing(tmp_path: Path) -> None:
    prompt_path = tmp_path / "prompt.md"
    prompt_path.write_text(
        """
# No frontmatter here
"""
    )

    with pytest.raises(ValueError):
        validate_canonical_prompt(prompt_path)


def test_run_assessment_from_canonical_prompt_produces_alignment_report() -> None:
    state = run_assessment_from_canonical_prompt(
        canonical_prompt_path=CANONICAL_PROMPT,
        workflow_manifest_path=WORKFLOW_MANIFEST,
        workflow_entrypoint="architecture-inventory",
        repo_root=REPO_ROOT,
        run_id="test-run",
    )

    assert state.alignment_report is not None
    assert state.issue_register is not None


def test_run_assessment_accepts_repo_relative_canonical_prompt() -> None:
    relative_prompt = "packages/workflows/architecture_assessment/00-overview.md"
    state = run_assessment_from_canonical_prompt(
        canonical_prompt_path=relative_prompt,
        workflow_manifest_path=WORKFLOW_MANIFEST,
        workflow_entrypoint="architecture-inventory",
        repo_root=REPO_ROOT,
        run_id="relative-run",
    )

    assert state.alignment_report is not None


def test_run_assessment_from_canonical_prompt_requires_assessment_config(
    tmp_path: Path,
) -> None:
    manifest_path = tmp_path / "manifest.yaml"
    manifest_path.write_text("version: 1\nsteps: []\n", encoding="utf-8")

    with pytest.raises(ValueError, match="assessment"):
        run_assessment_from_canonical_prompt(
            canonical_prompt_path=CANONICAL_PROMPT,
            workflow_manifest_path=manifest_path,
            repo_root=REPO_ROOT,
        )

