from __future__ import annotations

from pathlib import Path

import pytest

from ..run import run_docs_glossary_from_canonical_prompt

REPO_ROOT = Path(__file__).resolve().parents[5]
CANONICAL_PROMPT = (
    REPO_ROOT / "packages/prompts/assessment/glossary/docs-glossary.md"
)
WORKFLOW_MANIFEST = (
    REPO_ROOT
    / "packages/prompts/assessment/glossary/workflows/docs-glossary.yaml"
)


def test_run_docs_glossary_produces_report() -> None:
    state = run_docs_glossary_from_canonical_prompt(
        canonical_prompt_path=CANONICAL_PROMPT,
        workflow_manifest_path=WORKFLOW_MANIFEST,
        workflow_entrypoint="docs-glossary-collect",
        repo_root=REPO_ROOT,
        run_id="docs-glossary-test",
    )

    assert state.glossary_report is not None
    assert state.glossary_report.entries is not None
    assert state.glossary_report.stats.files_scanned >= 0


def test_run_docs_glossary_requires_glossary_config(tmp_path: Path) -> None:
    manifest_path = tmp_path / "manifest.yaml"
    manifest_path.write_text(
        "version: 1\nsteps:\n  - id: collect\n    name: Collect\n"
        "    prompt_path: noop.md\n    meta:\n      action: collect_terms\n      step_index: 1\n",
        encoding="utf-8",
    )

    with pytest.raises(ValueError, match="glossary"):
        run_docs_glossary_from_canonical_prompt(
            canonical_prompt_path=CANONICAL_PROMPT,
            workflow_manifest_path=manifest_path,
            repo_root=REPO_ROOT,
        )


