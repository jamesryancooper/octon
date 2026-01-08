from __future__ import annotations

from pathlib import Path
from typing import Final

from langgraph.graph.state import CompiledStateGraph

from .graph import build_glossary_graph

DEFAULT_MANIFEST_PATH: Final[str] = (
    "packages/workflows/docs_glossary/manifest.yaml"
)


def compile_glossary_graph(
    workspace_root: str | Path = ".",
    workflow_manifest_path: str | Path = DEFAULT_MANIFEST_PATH,
    workflow_entrypoint: str | None = None,
) -> CompiledStateGraph:
    workspace_root_path = Path(workspace_root).resolve()
    manifest_path = Path(workflow_manifest_path)
    if not manifest_path.is_absolute():
        manifest_path = workspace_root_path / manifest_path

    return build_glossary_graph(
        repo_root=workspace_root_path,
        workflow_manifest=manifest_path,
        entrypoint=workflow_entrypoint,
    )


