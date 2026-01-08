from __future__ import annotations

from pathlib import Path
from typing import Final

from langgraph.graph.state import CompiledStateGraph

from .graph import build_assessment_graph
from .paths import resolve_manifest_path

DEFAULT_MANIFEST_PATH: Final[str] = (
    "packages/workflows/architecture_assessment/manifest.yaml"
)


def compile_assessment_graph(
    workspace_root: str | Path = ".",
    workflow_manifest_path: str | Path = DEFAULT_MANIFEST_PATH,
    workflow_entrypoint: str | None = None,
) -> CompiledStateGraph:
    """
    Compile the architecture assessment LangGraph from configuration.

    Args:
        workspace_root: Repository root used for resolving relative resources.
        workflow_manifest_path: Path to the workflow manifest YAML file.
        workflow_entrypoint: Optional node id to use as the entrypoint.

    Returns:
        CompiledGraph ready for invocation via LangGraph runtime or Studio.
    """
    workspace_root_path = Path(workspace_root).resolve()
    manifest_path = resolve_manifest_path(workflow_manifest_path, workspace_root_path)
    compiled_graph = build_assessment_graph(
        repo_root=str(workspace_root_path),
        workflow_manifest=str(manifest_path),
        entrypoint=workflow_entrypoint,
    )
    return compiled_graph


