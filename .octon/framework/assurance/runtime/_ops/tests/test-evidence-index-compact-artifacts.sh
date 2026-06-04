#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
TEST_NAME="$(basename "$0")"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-evidence-index-compact-artifacts.sh"

pass_count=0
fail_count=0

pass() {
  echo "PASS: $1"
  pass_count=$((pass_count + 1))
}

fail() {
  echo "FAIL: $1" >&2
  fail_count=$((fail_count + 1))
}

assert_success() {
  local label="$1"
  shift
  if "$@"; then
    pass "$label"
  else
    fail "$label"
  fi
}

assert_failure() {
  local label="$1"
  shift
  if "$@"; then
    fail "$label"
  else
    pass "$label"
  fi
}

make_bundle() {
  local fixture_root="$1"
  local bundle="$fixture_root/.octon/state/evidence/runs/workflows/test-run"
  mkdir -p "$bundle/logs"
  printf '# Program Lifecycle Run\nfinal_verdict: blocked-recoverable\n' >"$bundle/summary.md"
  printf 'status: blocked\nmessage: failed validator digest mismatch\nnext: retry\n' >"$bundle/recovery-log.yml"
  printf 'stdout: command started\nstderr: ERROR: command failed\nexit_code: 1\n' >"$bundle/logs/adapter.stderr.log"

  python3 - "$fixture_root" "$bundle" <<'PY'
import hashlib
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1]).resolve()
bundle = pathlib.Path(sys.argv[2]).resolve()

def rel(path):
    return str(path.resolve().relative_to(root))

def sha(path):
    return "sha256:" + hashlib.sha256(path.read_bytes()).hexdigest()

def line_sha(line):
    return "sha256:" + hashlib.sha256(line.encode()).hexdigest()

def estimate(path):
    size = path.stat().st_size
    return (size + 3) // 4

boundary = {
    "replaces_source_evidence": False,
    "authorizes_execution": False,
    "proposal_input_authority": "non-authoritative",
    "generated_output_authority": "derived-only",
    "raw_evidence_retained": True,
}

raw_sources = [
    bundle / "summary.md",
    bundle / "recovery-log.yml",
    bundle / "logs/adapter.stderr.log",
]

summaries = []
slices = []
for source in raw_sources:
    lines = source.read_text().splitlines()
    error_lines = [
        index for index, line in enumerate(lines)
        if "failed" in line.lower() or "error:" in line.lower() or "blocked" in line.lower()
    ]
    first = next((line for line in lines if line.strip()), None)
    last = next((line for line in reversed(lines) if line.strip()), None)
    summaries.append({
        "source_ref": rel(source),
        "source_sha256": sha(source),
        "byte_size": source.stat().st_size,
        "line_count": len(lines),
        "estimated_tokens": estimate(source),
        "summary_kind": ["failing-slice"] if error_lines else ["status-summary"],
        "failing_slice_count": len(error_lines),
        "first_nonempty_line_sha256": line_sha(first) if first else None,
        "last_nonempty_line_sha256": line_sha(last) if last else None,
        "prompt_echo_lines": 0,
        "command_output_lines": sum(1 for line in lines if "stdout" in line.lower() or "stderr" in line.lower()),
        "diff_lines": 0,
        "error_lines": len(error_lines),
        "read_raw_only_if": [
            "summary-hash-mismatch",
            "failing-slice-cannot-be-reconstructed",
            "validator-dispute",
            "replay-audit-request",
        ],
    })
    for ordinal, index in enumerate(error_lines, start=1):
        start = max(0, index - 2)
        end = min(len(lines), index + 3)
        slice_text = "\n".join(lines[start:end])
        slices.append({
            "slice_id": f"{source.stem}-{ordinal}",
            "source_ref": rel(source),
            "source_sha256": sha(source),
            "start_line": start + 1,
            "end_line": end,
            "line_count": end - start,
            "slice_sha256": "sha256:" + hashlib.sha256(slice_text.encode()).hexdigest(),
            "matched_line_sha256": line_sha(lines[index]),
            "reason": "failure-marker",
            "replay_ref": "source_ref+source_sha256+line-range",
            "rollback_ref": "retain-raw-source-and-delete-compact-artifacts",
        })

raw_summary = {
    "schema_version": "octon-raw-log-summary-v1",
    "run_id": "test-run",
    "producer": "lifecycle-program-controller",
    "generated_at": "2026-06-03T00:00:00Z",
    "authority_boundary": boundary,
    "token_ceiling": 2000,
    "default_reader_preference": "prefer-compact-summary-then-handle-only-raw-ref",
    "source_count": len(summaries),
    "summaries": summaries,
    "failure_behavior": [
        "fail-closed-on-source-missing",
        "fail-closed-on-source-digest-mismatch",
        "fail-closed-on-failing-slice-reconstruction-mismatch",
        "escalate-before-reading-raw-log-body",
    ],
}
slice_manifest = {
    "schema_version": "octon-failing-slice-manifest-v1",
    "run_id": "test-run",
    "producer": "lifecycle-program-controller",
    "generated_at": "2026-06-03T00:00:00Z",
    "authority_boundary": boundary,
    "reconstruction_rule": "Read source_ref, verify source_sha256, join inclusive start_line..end_line with newline, then match slice_sha256.",
    "no_failure_observed": not slices,
    "slices_truncated": 0,
    "slices": slices,
}

(bundle / "raw-log-summary.yml").write_text(json.dumps(raw_summary, indent=2) + "\n")
(bundle / "failing-slice-manifest.yml").write_text(json.dumps(slice_manifest, indent=2) + "\n")

source_artifacts = []
for source in raw_sources:
    source_artifacts.append({
        "artifact_role": "raw-log" if source.suffix == ".log" else "program-summary",
        "artifact_ref": rel(source),
        "sha256": sha(source),
        "byte_size": source.stat().st_size,
        "estimated_tokens": estimate(source),
        "model_visible_relevance": "handle-only-by-default",
        "default_reader": "raw-ref-handle",
        "read_raw_only_if": [
            "summary-hash-mismatch",
            "failing-slice-cannot-be-reconstructed",
            "validator-dispute",
            "replay-audit-request",
        ],
        "freshness_state": "digest-bound",
    })

index = {
    "schema_version": "octon-evidence-index-v1",
    "run_id": "test-run",
    "producer": "lifecycle-program-controller",
    "generated_at": "2026-06-03T00:00:00Z",
    "authority_boundary": boundary,
    "reader_preferences": {
        "planner": "read evidence-index.yml first; use raw refs only for validator disputes",
        "recovery": "read raw-log-summary.yml and failing-slice-manifest.yml before raw logs",
        "closeout": "verify compact digests, then dereference raw evidence only when required",
        "raw_body_policy": "handle-only-by-default",
        "raw_body_escalation_required": True,
    },
    "source_artifacts": source_artifacts,
    "compact_artifacts": [
        {
            "artifact_role": "raw-log-summary",
            "artifact_ref": rel(bundle / "raw-log-summary.yml"),
            "sha256": sha(bundle / "raw-log-summary.yml"),
            "source_artifact_count": len(raw_sources),
            "validation": "validate-evidence-index-compact-artifacts.sh",
        },
        {
            "artifact_role": "failing-slice-manifest",
            "artifact_ref": rel(bundle / "failing-slice-manifest.yml"),
            "sha256": sha(bundle / "failing-slice-manifest.yml"),
            "source_artifact_count": len(raw_sources),
            "validation": "validate-evidence-index-compact-artifacts.sh",
        },
    ],
    "failure_behavior": raw_summary["failure_behavior"],
}
(bundle / "evidence-index.yml").write_text(json.dumps(index, indent=2) + "\n")
PY
}

main() {
  local tmp
  tmp="$(mktemp -d)"
  trap "rm -rf '$tmp'" EXIT

  local valid_root="$tmp/valid"
  make_bundle "$valid_root"
  assert_success "valid compact evidence bundle passes" \
    bash "$VALIDATOR" --root "$valid_root" --bundle ".octon/state/evidence/runs/workflows/test-run"

  local digest_root="$tmp/digest-mismatch"
  make_bundle "$digest_root"
  printf 'tampered raw evidence\n' >>"$digest_root/.octon/state/evidence/runs/workflows/test-run/recovery-log.yml"
  assert_failure "raw source digest mismatch fails closed" \
    bash "$VALIDATOR" --root "$digest_root" --bundle ".octon/state/evidence/runs/workflows/test-run"

  local slice_root="$tmp/slice-mismatch"
  make_bundle "$slice_root"
  python3 - "$slice_root/.octon/state/evidence/runs/workflows/test-run/failing-slice-manifest.yml" <<'PY'
import json
import pathlib
import sys
path = pathlib.Path(sys.argv[1])
data = json.loads(path.read_text())
data["slices"][0]["slice_sha256"] = "sha256:" + ("0" * 64)
path.write_text(json.dumps(data, indent=2) + "\n")
PY
  assert_failure "failing slice reconstruction mismatch fails closed" \
    bash "$VALIDATOR" --root "$slice_root" --bundle ".octon/state/evidence/runs/workflows/test-run"

  echo
  echo "$TEST_NAME: passed=$pass_count failed=$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
