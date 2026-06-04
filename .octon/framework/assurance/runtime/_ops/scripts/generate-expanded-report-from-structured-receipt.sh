#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR:-$DEFAULT_OCTON_DIR}"
DEFAULT_ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"
ROOT_DIR="${ROOT_DIR:-$DEFAULT_ROOT_DIR}"
VALIDATOR="$SCRIPT_DIR/validate-structured-receipt-artifacts.sh"

REQUEST_PATH=""
OUTPUT_PATH=""

usage() {
  cat <<'USAGE'
usage:
  generate-expanded-report-from-structured-receipt.sh --request <expanded-report-request.yml> [--output <path>]

Validates an expanded-report-request compact artifact, verifies reachable source
digests through validate-structured-receipt-artifacts.sh, and emits a
deterministic Markdown report from the compact metadata and retained refs.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --request)
      REQUEST_PATH="${2:-}"
      shift 2
      ;;
    --output)
      OUTPUT_PATH="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$REQUEST_PATH" ]]; then
  echo "missing --request" >&2
  usage >&2
  exit 2
fi

ROOT_DIR="$ROOT_DIR" "$VALIDATOR" --artifact "$REQUEST_PATH" >/dev/null

request_json="$(yq -o=json '.' "$REQUEST_PATH")"

report="$(
  REQUEST_JSON="$request_json" REQUEST_PATH="$REQUEST_PATH" ROOT_DIR="$ROOT_DIR" python3 - <<'PY'
import json
import os
from pathlib import PurePosixPath

data = json.loads(os.environ["REQUEST_JSON"])
request_path = os.environ["REQUEST_PATH"]


def as_list(value):
    if isinstance(value, list):
        return value
    if value is None:
        return []
    return [value]


def render_list(items):
    rendered = []
    for item in items:
        rendered.append(f"- {item}")
    return rendered or ["- none"]


def digest_lines(records):
    if isinstance(records, dict):
        return [f"- {ref}: {digest}" for ref, digest in sorted(records.items())]
    lines = []
    for item in as_list(records):
        if isinstance(item, dict):
            ref = item.get("source_ref", "")
            digest = item.get("sha256", "")
            lines.append(f"- {ref}: {digest}")
    return lines or ["- none"]


def mapping_lines(mapping):
    if not isinstance(mapping, dict):
        return ["- none"]
    lines = []
    for key in sorted(mapping):
        lines.append(f"- {key}: {mapping[key]}")
    return lines or ["- none"]


artifact_id = data.get("artifact_id", "expanded-report")
summary = data.get("summary", "")
expanded = data.get("expanded_report", {})

lines = [
    "# Expanded Report",
    "",
    f"request_ref: {request_path}",
    f"artifact_id: {artifact_id}",
    f"artifact_kind: {data.get('artifact_kind', '')}",
    f"authority_status: {data.get('authority_status', '')}",
    "",
    "## Summary",
    "",
    summary if summary else "No summary field was provided; this report reconstructs from structured metadata and retained refs.",
    "",
    "## Source Refs",
    "",
    *render_list(as_list(data.get("source_refs"))),
    "",
    "## Source Digests",
    "",
    *digest_lines(data.get("source_digests")),
    "",
    "## Evidence Refs",
    "",
    *render_list(as_list(data.get("evidence_refs"))),
    "",
    "## Gate State",
    "",
    *mapping_lines(data.get("gate_state")),
    "",
    "## Blockers",
    "",
    *render_list(as_list(data.get("blockers"))),
    "",
    "## Unresolved Questions",
    "",
    *render_list(as_list(data.get("unresolved_questions"))),
    "",
    "## Changed Files",
    "",
    *render_list(as_list(data.get("changed_files"))),
    "",
    "## Rollback Refs",
    "",
    *render_list(as_list(data.get("rollback_refs"))),
    "",
    "## Validation",
    "",
    *mapping_lines(data.get("validation")),
    "",
    "## Freshness",
    "",
    *mapping_lines(data.get("freshness")),
    "",
    "## Failure Behavior",
    "",
    *mapping_lines(data.get("failure_behavior")),
    "",
    "## Authority Boundary",
    "",
    *mapping_lines(data.get("authority_boundary")),
    "",
    "## Reconstruction",
    "",
    f"output_mode: {expanded.get('output_mode', '')}",
    "",
    "reconstruction_sources:",
    *render_list(as_list(expanded.get("reconstruction_sources"))),
    "",
    "This report is an on-demand narrative reconstruction. It does not replace the canonical receipt, wrapper report, retained evidence, rollback evidence, authorization refs, policy, support proof, or closure proof.",
]

print("\n".join(lines))
PY
)"

if [[ -n "$OUTPUT_PATH" ]]; then
  mkdir -p "$(dirname -- "$OUTPUT_PATH")"
  printf '%s\n' "$report" >"$OUTPUT_PATH"
else
  printf '%s\n' "$report"
fi
