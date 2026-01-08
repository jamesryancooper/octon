from __future__ import annotations

from pathlib import Path

from fastapi.testclient import TestClient

from ..server import app

client = TestClient(app)

REPO_ROOT = Path(__file__).resolve().parents[4]
CANONICAL_PROMPT = (
    REPO_ROOT / "packages/workflows/architecture_assessment/00-overview.md"
)
WORKFLOW_MANIFEST = (
    REPO_ROOT / "packages/workflows/architecture_assessment/manifest.yaml"
)


def test_healthz() -> None:
    response = client.get("/healthz")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_run_flow_endpoint_executes_architecture_flow() -> None:
    payload = {
        "runId": "test-http-run",
        "flowName": "architecture_assessment",
        "canonicalPromptPath": str(CANONICAL_PROMPT),
        "workflowManifestPath": str(WORKFLOW_MANIFEST),
        "workflowEntrypoint": "architecture-inventory",
        "workspaceRoot": str(REPO_ROOT),
    }

    response = client.post("/flows/run", json=payload)
    assert response.status_code == 200

    data = response.json()
    assert data["runtimeRunId"] == "test-http-run"
    assert data["metadata"]["flowName"] == "architecture_assessment"
    assert data["result"], "Expected alignment report or fallback message"


def test_run_flow_unknown_flow() -> None:
    payload = {
        "runId": "unknown-flow",
        "flowName": "unknown",
        "canonicalPromptPath": str(CANONICAL_PROMPT),
        "workflowManifestPath": str(WORKFLOW_MANIFEST),
    }
    response = client.post("/flows/run", json=payload)
    assert response.status_code == 404


def test_run_flow_requires_manifest_assessment_block(tmp_path: Path) -> None:
    manifest_path = tmp_path / "manifest.yaml"
    manifest_path.write_text("version: 1\nsteps: []\n", encoding="utf-8")

    payload = {
        "runId": "invalid-manifest",
        "flowName": "architecture_assessment",
        "canonicalPromptPath": str(CANONICAL_PROMPT),
        "workflowManifestPath": str(manifest_path),
        "workspaceRoot": str(REPO_ROOT),
    }

    response = client.post("/flows/run", json=payload)
    assert response.status_code == 400
    assert "assessment" in response.json()["detail"]

