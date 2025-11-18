from __future__ import annotations

import os
from functools import lru_cache
from pathlib import Path
from typing import Final

from langgraph.graph.state import CompiledStateGraph

from .graph_factory import DEFAULT_MANIFEST_PATH, compile_glossary_graph

ENV_WORKSPACE_ROOT: Final[str] = "FLOWKIT_GLOSSARY_WORKSPACE_ROOT"
ENV_WORKFLOW_MANIFEST: Final[str] = "FLOWKIT_GLOSSARY_WORKFLOW_MANIFEST"
ENV_WORKFLOW_ENTRYPOINT: Final[str] = "FLOWKIT_GLOSSARY_WORKFLOW_ENTRYPOINT"


def _default_workspace_root() -> Path:
    return Path(__file__).resolve().parents[4]


def _workspace_root_from_env() -> Path:
    env_value = os.environ.get(ENV_WORKSPACE_ROOT)
    if env_value:
        return Path(env_value).expanduser().resolve()
    return _default_workspace_root()


@lru_cache(maxsize=1)
def _build_graph() -> CompiledStateGraph:
    workspace_root = _workspace_root_from_env()
    manifest_path = os.environ.get(ENV_WORKFLOW_MANIFEST, DEFAULT_MANIFEST_PATH)
    entrypoint = os.environ.get(ENV_WORKFLOW_ENTRYPOINT)
    return compile_glossary_graph(
        workspace_root=workspace_root,
        workflow_manifest_path=manifest_path,
        workflow_entrypoint=entrypoint,
    )


def get_graph() -> CompiledStateGraph:
    return _build_graph()


graph = get_graph()


