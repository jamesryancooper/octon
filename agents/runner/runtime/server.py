from __future__ import annotations

import argparse
import logging
from pathlib import Path
from typing import Any, Callable, Dict

import uvicorn
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

from .assessment.run import run_assessment_from_canonical_prompt
from .glossary.run import run_docs_glossary_from_canonical_prompt

logger = logging.getLogger("flowkit.runner")

app = FastAPI(title="FlowKit Runner", version="0.1.0")


class FlowRunPayload(BaseModel):
    runId: str = Field(..., alias="runId")
    flowName: str
    canonicalPromptPath: str
    workflowManifestPath: str
    workflowEntrypoint: str | None = None
    workspaceRoot: str = "."
    params: Dict[str, Any] | None = None


class FlowRunResponse(BaseModel):
    result: Any
    metadata: Dict[str, Any]
    runtimeRunId: str
    artifacts: list[str] | None = None


FlowHandler = Callable[[FlowRunPayload], FlowRunResponse]


def _run_assessment(payload: FlowRunPayload) -> FlowRunResponse:
    state = run_assessment_from_canonical_prompt(
        canonical_prompt_path=payload.canonicalPromptPath,
        workflow_manifest_path=payload.workflowManifestPath,
        workflow_entrypoint=payload.workflowEntrypoint,
        repo_root=payload.workspaceRoot,
        run_id=payload.runId,
    )

    if state.alignment_report is not None:
        result: Any = state.alignment_report.model_dump()
    else:
        result = {
            "message": "ArchitectureAssessmentFlow completed (no alignment_report set)."
        }

    metadata = {
        "flowName": payload.flowName,
        "workflowManifestPath": str(
            Path(payload.workflowManifestPath)
        ),
        "canonicalPromptPath": payload.canonicalPromptPath,
        "repoRoot": payload.workspaceRoot,
    }

    return FlowRunResponse(
        result=result,
        metadata=metadata,
        runtimeRunId=state.run_id,
    )


def _run_docs_glossary(payload: FlowRunPayload) -> FlowRunResponse:
    state = run_docs_glossary_from_canonical_prompt(
        canonical_prompt_path=payload.canonicalPromptPath,
        workflow_manifest_path=payload.workflowManifestPath,
        workflow_entrypoint=payload.workflowEntrypoint,
        repo_root=payload.workspaceRoot,
        run_id=payload.runId,
        flow_name=payload.flowName,
    )

    if state.glossary_report is not None:
        result: Any = state.glossary_report.model_dump()
    else:
        result = {"message": "DocsGlossaryFlow completed without a glossary report."}

    metadata = {
        "flowName": payload.flowName,
        "workflowManifestPath": str(Path(payload.workflowManifestPath)),
        "canonicalPromptPath": payload.canonicalPromptPath,
        "repoRoot": payload.workspaceRoot,
    }

    return FlowRunResponse(
        result=result,
        metadata=metadata,
        runtimeRunId=state.run_id,
    )


FLOW_HANDLERS: Dict[str, FlowHandler] = {
    "architecture_assessment": _run_assessment,
    "docs_glossary": _run_docs_glossary,
}


@app.get("/healthz", tags=["system"])
def healthz() -> Dict[str, str]:
    """Simple readiness endpoint used by the FlowKit CLI."""
    return {"status": "ok"}


@app.post("/flows/run", response_model=FlowRunResponse, tags=["flows"])
def run_flow(payload: FlowRunPayload) -> FlowRunResponse:
    handler = FLOW_HANDLERS.get(payload.flowName)
    if handler is None:
        raise HTTPException(status_code=404, detail=f"Unknown flow '{payload.flowName}'")

    try:
        return handler(payload)
    except FileNotFoundError as exc:
        raise HTTPException(status_code=404, detail=str(exc)) from exc
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    except Exception as exc:  # pragma: no cover - defensive logging path
        logger.exception("Flow '%s' failed: %s", payload.flowName, exc)
        raise HTTPException(status_code=500, detail="Flow execution failed") from exc


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="FlowKit HTTP runner service.")
    parser.add_argument("--host", default="127.0.0.1", help="Host address to bind.")
    parser.add_argument("--port", type=int, default=8410, help="Port to bind.")
    parser.add_argument(
        "--log-level", default="info", help="Uvicorn log level (default: info)."
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    uvicorn.run(
        "agents.runner.runtime.server:app",
        host=args.host,
        port=args.port,
        log_level=args.log_level,
    )


if __name__ == "__main__":  # pragma: no cover
    main()

