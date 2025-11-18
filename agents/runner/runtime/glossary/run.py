from __future__ import annotations

import uuid
from pathlib import Path
from typing import Any, Dict

import yaml

from ..assessment.parsing import parse_frontmatter
from ..assessment.paths import resolve_manifest_path, resolve_repo_path
from .graph import build_glossary_graph
from .state import GlossaryGraphState, GlossaryState


def _validate_canonical_prompt(canonical_prompt_path: str | Path) -> Dict[str, str]:
    prompt_path = Path(canonical_prompt_path)
    if not prompt_path.exists():
        raise ValueError(f"Canonical prompt not found: {canonical_prompt_path}")
    content = prompt_path.read_text(encoding="utf-8")
    frontmatter, _ = parse_frontmatter(content)
    if not frontmatter:
        raise ValueError(
            f"Canonical prompt missing frontmatter: {canonical_prompt_path}"
        )
    title = frontmatter.get("title")
    description = frontmatter.get("description")
    if not title or not description:
        raise ValueError(
            f"Canonical prompt frontmatter must include 'title' and 'description': {canonical_prompt_path}"
        )
    return {"title": str(title), "description": str(description)}


def _load_glossary_config(manifest: Dict[str, Any]) -> Dict[str, Any]:
    glossary_cfg = manifest.get("glossary")
    if glossary_cfg is None:
        raise ValueError("Workflow manifest missing 'glossary' configuration block.")
    if not isinstance(glossary_cfg, dict):
        raise ValueError("glossary configuration must be a mapping.")

    docs_path = glossary_cfg.get("docs_path", "docs/harmony")
    if not isinstance(docs_path, str) or not docs_path.strip():
        raise ValueError("glossary.docs_path must be a non-empty string.")

    max_terms = glossary_cfg.get("max_terms", 25)
    min_term_length = glossary_cfg.get("min_term_length", 4)

    def _ensure_int(value: Any, field: str) -> int:
        if isinstance(value, int) and value > 0:
            return value
        raise ValueError(f"glossary.{field} must be a positive integer.")

    return {
        "docs_path": docs_path,
        "max_terms": _ensure_int(max_terms, "max_terms"),
        "min_term_length": _ensure_int(min_term_length, "min_term_length"),
    }


def run_docs_glossary_from_canonical_prompt(
    canonical_prompt_path: str | Path,
    workflow_manifest_path: str | Path,
    workflow_entrypoint: str | None = None,
    repo_root: str | Path = ".",
    run_id: str | None = None,
    flow_name: str = "docs_glossary",
) -> GlossaryState:
    """
    Execute the docs glossary flow using the provided canonical prompt and manifest.
    """

    canonical_path = resolve_repo_path(canonical_prompt_path, repo_root)
    _validate_canonical_prompt(canonical_path)

    manifest_path = resolve_manifest_path(workflow_manifest_path, repo_root)
    if not manifest_path.exists():
        raise ValueError(f"Workflow manifest not found at {manifest_path}")

    manifest_data = yaml.safe_load(manifest_path.read_text()) or {}
    glossary_config = _load_glossary_config(manifest_data)

    root_path = Path(repo_root).resolve()
    graph = build_glossary_graph(
        repo_root=root_path,
        workflow_manifest=manifest_path,
        entrypoint=workflow_entrypoint,
    )

    initial_state: GlossaryGraphState = {
        "run_id": run_id or str(uuid.uuid4()),
        "flow_name": flow_name,
        "workspace_root": str(root_path),
        "docs_path": glossary_config["docs_path"],
        "max_terms": glossary_config["max_terms"],
        "min_term_length": glossary_config["min_term_length"],
    }

    final_state = graph.invoke(initial_state)
    return GlossaryState(
        run_id=initial_state["run_id"],
        flow_name=flow_name,
        workspace_root=str(root_path),
        docs_path=glossary_config["docs_path"],
        max_terms=glossary_config["max_terms"],
        min_term_length=glossary_config["min_term_length"],
        files_scanned=final_state.get("files_scanned", 0),
        collected_terms=final_state.get("collected_terms", []),
        glossary_report=final_state.get("glossary_report"),
    )


