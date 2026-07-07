#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
HELPER="$SCRIPT_DIR/../scripts/cleanup-local-run-artifacts.sh"

fail() {
  echo "[FAIL] $*" >&2
  exit 1
}

assert_exists() {
  [[ -e "$1" ]] || fail "expected path to exist: $1"
}

assert_missing() {
  [[ ! -e "$1" ]] || fail "expected path to be removed: $1"
}

assert_fails() {
  local label="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    fail "$label should fail"
  fi
}

assert_output_contains() {
  local output="$1"
  local label="$2"
  shift 2
  local filtered="$output"
  local needle
  for needle in "$@"; do
    filtered="$(grep -F -- "$needle" <<<"$filtered" || true)"
  done
  [[ -n "$filtered" ]] || fail "$label"
}

assert_output_not_contains() {
  local output="$1"
  local label="$2"
  shift 2
  local filtered="$output"
  local needle
  for needle in "$@"; do
    filtered="$(grep -F -- "$needle" <<<"$filtered" || true)"
  done
  [[ -z "$filtered" ]] || fail "$label"
}

tmp_root="$(mktemp -d "${TMPDIR:-/tmp}/octon-local-run-artifacts.XXXXXX")"
trap 'rm -rf "$tmp_root"' EXIT
fixture_index=0

make_fixture() {
  fixture_index=$((fixture_index + 1))
  local root="$tmp_root/fixture-$fixture_index"
  mkdir -p "$root"
  git -C "$root" init >/dev/null
  git -C "$root" config core.excludesFile /dev/null
  printf '.DS_Store\n' >"$root/.gitignore"

  mkdir -p "$root/.octon/generated/effective/capabilities"
  cat >"$root/.octon/generated/effective/capabilities/generation.lock.yml" <<'LOCK'
schema_version: test-lock-v1
retained_receipt_ref: ".octon/state/evidence/validation/publication/capabilities/final.yml"
LOCK
  git -C "$root" add .gitignore .octon/generated/effective/capabilities/generation.lock.yml
  git -C "$root" -c user.name="Octon Test" -c user.email="octon@example.invalid" commit -m "test fixture" >/dev/null

  mkdir -p "$root/.octon/state/evidence/validation/publication/capabilities"
  printf 'receipt: final\n' >"$root/.octon/state/evidence/validation/publication/capabilities/final.yml"
  printf 'receipt: stale\n' >"$root/.octon/state/evidence/validation/publication/capabilities/stale.yml"

  mkdir -p "$root/.octon/state/control/execution/runs/publish-1"
  printf 'run: publish\n' >"$root/.octon/state/control/execution/runs/publish-1/run-manifest.yml"

  mkdir -p "$root/.octon/state/continuity/runs/service-build-1"
  printf 'run: service\n' >"$root/.octon/state/continuity/runs/service-build-1/state.yml"

  mkdir -p "$root/.octon/state/control/engine/agent/checkpoints"
  printf '{}\n' >"$root/.octon/state/control/engine/agent/checkpoints/runtime-agent-quorum-allow-1.json"

  mkdir -p "$root/.octon/state/control/execution/runs/lifecycle-proposal-program-1"
  printf 'checkpoint: local\n' >"$root/.octon/state/control/execution/runs/lifecycle-proposal-program-1/program-lifecycle-checkpoint.yml"
  printf 'ref: .octon/state/control/execution/runs/lifecycle-proposal-program-1/program-lifecycle-checkpoint.yml\n' >"$root/.octon/state/control/execution/runs/lifecycle-proposal-program-1/run-manifest.yml"

  mkdir -p "$root/.octon/state/continuity/runs/lifecycle-proposal-program-1-workflow"
  printf 'handoff: local\n' >"$root/.octon/state/continuity/runs/lifecycle-proposal-program-1-workflow/handoff.yml"

  mkdir -p "$root/.octon/state/evidence/control/execution"
  printf 'decision_ref: .octon/state/control/execution/runs/lifecycle-proposal-program-1/run-manifest.yml\n' >"$root/.octon/state/evidence/control/execution/authority-decision-lifecycle-proposal-program-1.yml"
  printf 'grant_ref: .octon/state/evidence/control/execution/authority-decision-lifecycle-proposal-program-1.yml\n' >"$root/.octon/state/evidence/control/execution/authority-grant-bundle-lifecycle-proposal-program-1.yml"

  mkdir -p "$root/.octon/state/evidence/external-index/runs"
  printf 'external-index: local\n' >"$root/.octon/state/evidence/external-index/runs/lifecycle-proposal-program-1.yml"

  mkdir -p "$root/.octon/state/control/execution/runs/workflow-engine-closed-1/checkpoints"
  cat >"$root/.octon/state/control/execution/runs/workflow-engine-closed-1/runtime-state.yml" <<'YAML'
schema_version: runtime-state-v2
run_id: workflow-engine-closed-1
state: closed
last_checkpoint_ref: .octon/state/control/execution/runs/workflow-engine-closed-1/checkpoints/execution-complete.yml
YAML
  cat >"$root/.octon/state/control/execution/runs/workflow-engine-closed-1/checkpoints/execution-complete.yml" <<'YAML'
schema_version: run-checkpoint-v1
run_id: workflow-engine-closed-1
checkpoint_id: execution-complete
status: materialized
YAML
  printf 'manifest: closed\n' >"$root/.octon/state/control/execution/runs/workflow-engine-closed-1/run-manifest.yml"
  mkdir -p "$root/.octon/state/continuity/runs/workflow-engine-closed-1"
  printf 'handoff: closed\n' >"$root/.octon/state/continuity/runs/workflow-engine-closed-1/handoff.yml"
  printf 'decision: closed\n' >"$root/.octon/state/evidence/control/execution/authority-decision-workflow-engine-closed-1.yml"
  printf 'grant: closed\n' >"$root/.octon/state/evidence/control/execution/authority-grant-bundle-workflow-engine-closed-1.yml"
  printf 'external-index: closed\n' >"$root/.octon/state/evidence/external-index/runs/workflow-engine-closed-1.yml"
  mkdir -p "$root/.octon/state/evidence/runs/workflow-engine-closed-1/checkpoints"
  printf 'retained execution evidence\n' >"$root/.octon/state/evidence/runs/workflow-engine-closed-1/checkpoints/execution-complete.yml"

  mkdir -p "$root/.octon/state/control/execution/runs/tool-1000-2000/checkpoints"
  cat >"$root/.octon/state/control/execution/runs/tool-1000-2000/runtime-state.yml" <<'YAML'
schema_version: runtime-state-v2
run_id: tool-1000-2000
state: denied
last_checkpoint_ref: .octon/state/control/execution/runs/tool-1000-2000/checkpoints/bound.yml
YAML
  printf 'checkpoint: denied\n' >"$root/.octon/state/control/execution/runs/tool-1000-2000/checkpoints/bound.yml"
  printf 'decision: denied\n' >"$root/.octon/state/evidence/control/execution/authority-decision-tool-1000-2000.yml"

  mkdir -p "$root/.octon/state/evidence/runs/services/tool-1000-2001"
  printf '{"schema_version":"execution-receipt-v3","request_id":"tool-1000-2001"}\n' >"$root/.octon/state/evidence/runs/services/tool-1000-2001/execution-receipt.json"
  printf '{"schema_version":"execution-request-v3","request":{"request_id":"tool-1000-2001"}}\n' >"$root/.octon/state/evidence/runs/services/tool-1000-2001/execution-request.json"
  printf '{"grant_id":"grant-tool-1000-2001"}\n' >"$root/.octon/state/evidence/runs/services/tool-1000-2001/grant-bundle.json"
  printf '{"status":"succeeded"}\n' >"$root/.octon/state/evidence/runs/services/tool-1000-2001/outcome.json"
  printf '{"decision":"ALLOW"}\n' >"$root/.octon/state/evidence/runs/services/tool-1000-2001/policy-decision.json"
  printf '{"side_effects":[]}\n' >"$root/.octon/state/evidence/runs/services/tool-1000-2001/side-effects.json"

  mkdir -p "$root/.octon/state/control/execution/runs/workflow-engine-running-1/checkpoints"
  cat >"$root/.octon/state/control/execution/runs/workflow-engine-running-1/runtime-state.yml" <<'YAML'
schema_version: runtime-state-v2
run_id: workflow-engine-running-1
state: running
last_checkpoint_ref: .octon/state/control/execution/runs/workflow-engine-running-1/checkpoints/execution-start.yml
YAML
  printf 'status: materialized\n' >"$root/.octon/state/control/execution/runs/workflow-engine-running-1/checkpoints/execution-start.yml"

  mkdir -p "$root/.octon/inputs/exploratory/proposals/architecture/archive-fixture"
  printf 'proposal_id: archive-fixture\nproposal_kind: architecture\n' >"$root/.octon/inputs/exploratory/proposals/architecture/archive-fixture/proposal.yml"
  mkdir -p "$root/.octon/inputs/exploratory/proposals/.archive/architecture/archive-fixture"
  printf 'proposal_id: archive-fixture\nproposal_kind: architecture\n' >"$root/.octon/inputs/exploratory/proposals/.archive/architecture/archive-fixture/proposal.yml"

  mkdir -p "$root/.octon/state/control/execution/runs/archive-proposal-stale-1/checkpoints"
  cat >"$root/.octon/state/control/execution/runs/archive-proposal-stale-1/runtime-state.yml" <<'YAML'
schema_version: runtime-state-v2
run_id: archive-proposal-stale-1
state: running
last_checkpoint_ref: .octon/state/control/execution/runs/archive-proposal-stale-1/checkpoints/execution-start.yml
YAML
  printf 'status: materialized\n' >"$root/.octon/state/control/execution/runs/archive-proposal-stale-1/checkpoints/execution-start.yml"
  cat >"$root/.octon/state/control/execution/runs/archive-proposal-stale-1/run-contract.yml" <<'YAML'
schema_version: run-contract-v1
run_id: archive-proposal-stale-1
objective_summary: Execute archive-proposal for archive fixture
scope_out:
  - .octon/inputs/exploratory/proposals/architecture/archive-fixture
  - .octon/inputs/exploratory/proposals/.archive/architecture/archive-fixture
YAML
  mkdir -p "$root/.octon/state/continuity/runs/archive-proposal-stale-1"
  printf 'handoff: archive stale\n' >"$root/.octon/state/continuity/runs/archive-proposal-stale-1/handoff.yml"
  printf 'decision: archive stale\n' >"$root/.octon/state/evidence/control/execution/authority-decision-archive-proposal-stale-1.yml"
  printf 'grant: archive stale\n' >"$root/.octon/state/evidence/control/execution/authority-grant-bundle-archive-proposal-stale-1.yml"
  printf 'external-index: archive stale\n' >"$root/.octon/state/evidence/external-index/runs/archive-proposal-stale-1.yml"
  mkdir -p "$root/.octon/state/evidence/runs/workflows/2026-06-15-archive-proposal-octon-inputs-exploratory-proposals-architecture-archive-fixture"
  cat >"$root/.octon/state/evidence/runs/workflows/2026-06-15-archive-proposal-octon-inputs-exploratory-proposals-architecture-archive-fixture/summary.md" <<'MARKDOWN'
- workflow_id: `archive-proposal`
- proposal_path: `.octon/inputs/exploratory/proposals/architecture/archive-fixture`
- archived_path: `.octon/inputs/exploratory/proposals/.archive/architecture/archive-fixture`
- final_verdict: `archived`
MARKDOWN

  mkdir -p "$root/.octon/state/control/execution/runs/archive-proposal-unsuperseded-1/checkpoints"
  cat >"$root/.octon/state/control/execution/runs/archive-proposal-unsuperseded-1/runtime-state.yml" <<'YAML'
schema_version: runtime-state-v2
run_id: archive-proposal-unsuperseded-1
state: running
last_checkpoint_ref: .octon/state/control/execution/runs/archive-proposal-unsuperseded-1/checkpoints/execution-start.yml
YAML
  printf 'status: materialized\n' >"$root/.octon/state/control/execution/runs/archive-proposal-unsuperseded-1/checkpoints/execution-start.yml"
  cat >"$root/.octon/state/control/execution/runs/archive-proposal-unsuperseded-1/run-contract.yml" <<'YAML'
schema_version: run-contract-v1
run_id: archive-proposal-unsuperseded-1
objective_summary: Execute archive-proposal for unsuperseded fixture
scope_out:
  - .octon/inputs/exploratory/proposals/architecture/unsuperseded-fixture
  - .octon/inputs/exploratory/proposals/.archive/architecture/unsuperseded-fixture
YAML

  mkdir -p "$root/.octon/state/evidence/runs/skills/closeout-worktree/run-1"
  printf 'wrapper-log: local\n' >"$root/.octon/state/evidence/runs/skills/closeout-worktree/run-1/log.yml"

  mkdir -p "$root/.octon/state/evidence/runs/skills/octon-proposal-lifecycle-closeout-packet/lifecycle-proposal-program-fixture-child"
  printf 'schema_version: lifecycle-interaction-request-v1\n' >"$root/.octon/state/evidence/runs/skills/octon-proposal-lifecycle-closeout-packet/lifecycle-proposal-program-fixture-child/lifecycle-interaction-request.json"
  printf 'schema_version: octon-proposal-worktree-hygiene-v1\n' >"$root/.octon/state/evidence/runs/skills/octon-proposal-lifecycle-closeout-packet/lifecycle-proposal-program-fixture-child/worktree-hygiene.yml"

  mkdir -p "$root/.octon/state/evidence/validation/analysis"
  cat >"$root/.octon/state/evidence/validation/analysis/retained-closeout-worktree-report.yml" <<'YAML'
schema_version: closeout-worktree-report-v1
source_refs:
  lifecycle_interaction_request:
    ref: .octon/state/evidence/runs/skills/octon-proposal-lifecycle-closeout-packet/lifecycle-proposal-program-fixture-child/lifecycle-interaction-request.json
  classifier_output:
    ref: .octon/state/evidence/runs/skills/octon-proposal-lifecycle-closeout-packet/lifecycle-proposal-program-fixture-child/worktree-hygiene.yml
YAML

  cat >"$root/.octon/state/evidence/validation/analysis/2026-07-07T00-00-00Z-closeout-worktree-fixture-archive-readiness.yml" <<'YAML'
schema_version: closeout-worktree-report-v1
retained_residue:
  - path: .octon/state/control/execution/runs/lifecycle-proposal-program-1/program-lifecycle-checkpoint.yml
    disposition: diagnostic residue path listing only
YAML

  mkdir -p "$root/.octon/inputs/exploratory/proposals/fixture-local"
  printf 'local finder metadata\n' >"$root/.octon/inputs/exploratory/proposals/fixture-local/.DS_Store"
  printf 'proposal input must stay\n' >"$root/.octon/inputs/exploratory/proposals/fixture-local/proposal.yml"

  mkdir -p "$root/.octon/state/evidence/runs/workflows/process-incoming-intake-fixture"
  cat >"$root/.octon/state/evidence/runs/workflows/process-incoming-intake-fixture/decision.md" <<'MARKDOWN'
## Intake Validator Findings

- excluded_noise:
  - .octon/inputs/exploratory/proposals/fixture-local/.DS_Store
MARKDOWN

  mkdir -p "$root/.octon/state/evidence/runs/workflows/lifecycle-fixture/reports"
  cat >"$root/.octon/state/evidence/runs/workflows/lifecycle-fixture/worktree-baseline.yml" <<'YAML'
untracked:
  - .octon/state/control/execution/runs/lifecycle-proposal-program-1/program-lifecycle-checkpoint.yml
YAML
  mkdir -p "$root/.octon/state/evidence/runs/workflows/lifecycle-fixture/workflow-execution"
  cat >"$root/.octon/state/evidence/runs/workflows/lifecycle-fixture/workflow-execution/execution-request.json" <<'JSON'
{
  "support_target_tuple_ref": ".octon/state/control/execution/runs/lifecycle-proposal-program-1/program-lifecycle-checkpoint.yml#support_target"
}
JSON
  cat >"$root/.octon/state/evidence/runs/workflows/lifecycle-fixture/workflow-execution/execution-receipt.json" <<'JSON'
{
  "effect_tokens": [
    ".octon/state/control/execution/runs/lifecycle-proposal-program-1/program-lifecycle-checkpoint.yml"
  ]
}
JSON
  cat >"$root/.octon/state/evidence/runs/workflows/lifecycle-fixture/workflow-execution/grant-bundle.json" <<'JSON'
{
  "governing_refs": {
    "run_checkpoint_ref": ".octon/state/control/execution/runs/lifecycle-proposal-program-1/program-lifecycle-checkpoint.yml"
  }
}
JSON
  cat >"$root/.octon/state/evidence/runs/workflows/lifecycle-fixture/workflow-execution/side-effects.json" <<'JSON'
{
  "side_effect_paths": [
    ".octon/state/control/execution/runs/lifecycle-proposal-program-1/program-lifecycle-checkpoint.yml"
  ]
}
JSON
  cat >"$root/.octon/state/evidence/runs/workflows/lifecycle-fixture/reports/classify-worktree-hygiene-report.md" <<'MARKDOWN'
- `.octon/state/control/execution/runs/lifecycle-proposal-program-1/program-lifecycle-checkpoint.yml`
MARKDOWN
  mkdir -p "$root/.octon/state/evidence/runs/workflows/lifecycle-fixture/stages/promote-proposal"
  cat >"$root/.octon/state/evidence/runs/workflows/lifecycle-fixture/stages/promote-proposal/execution-request.json" <<'JSON'
{
  "support_target_tuple_ref": ".octon/state/control/execution/runs/lifecycle-proposal-program-1/program-lifecycle-checkpoint.yml#support_target"
}
JSON
  cat >"$root/.octon/state/evidence/runs/workflows/lifecycle-fixture/stages/promote-proposal/execution-receipt.json" <<'JSON'
{
  "mutated_paths": [
    ".octon/state/control/execution/runs/lifecycle-proposal-program-1/program-lifecycle-checkpoint.yml"
  ]
}
JSON
  cat >"$root/.octon/state/evidence/runs/workflows/lifecycle-fixture/stages/promote-proposal/grant-bundle.json" <<'JSON'
{
  "governing_refs": {
    "run_checkpoint_ref": ".octon/state/control/execution/runs/lifecycle-proposal-program-1/program-lifecycle-checkpoint.yml"
  }
}
JSON
  cat >"$root/.octon/state/evidence/runs/workflows/lifecycle-fixture/stages/promote-proposal/side-effects.json" <<'JSON'
{
  "side_effect_paths": [
    ".octon/state/control/execution/runs/lifecycle-proposal-program-1/program-lifecycle-checkpoint.yml"
  ]
}
JSON

  mkdir -p "$root/.octon/state/evidence/runs/workflows/lifecycle-proposal-program-fixture"
  cat >"$root/.octon/state/evidence/runs/workflows/lifecycle-proposal-program-fixture/program-context-capsule.yml" <<'YAML'
source_refs:
  - artifact_role: program-control-checkpoint-diagnostic
    artifact_ref: .octon/state/control/execution/runs/lifecycle-proposal-program-1/program-lifecycle-checkpoint.yml
    required: false
YAML
  cat >"$root/.octon/state/evidence/runs/workflows/lifecycle-proposal-program-fixture/route-decision-receipt.yml" <<'YAML'
resume_source_refs:
  source_refs:
    - artifact_role: program-control-checkpoint-diagnostic
      artifact_ref: .octon/state/control/execution/runs/lifecycle-proposal-program-1/program-lifecycle-checkpoint.yml
      required: false
YAML
  cat >"$root/.octon/state/evidence/runs/workflows/lifecycle-proposal-program-fixture/compact-completion-capsule.yml" <<'YAML'
source_refs:
  - artifact_role: program-control-checkpoint-diagnostic
    artifact_ref: .octon/state/control/execution/runs/lifecycle-proposal-program-1/program-lifecycle-checkpoint.yml
    required: false
YAML
  cat >"$root/.octon/state/evidence/runs/workflows/lifecycle-proposal-program-fixture/no-dispatch-attempt-ledger.yml" <<'YAML'
attempts:
  - artifact_ref: .octon/state/control/execution/runs/lifecycle-proposal-program-1/program-lifecycle-checkpoint.yml
    required: false
YAML

  printf 'manual: true\n' >"$root/.octon/state/evidence/validation/analysis/manual.yml"

  mkdir -p "$root/.octon/state/evidence/local/terminal-closeout/fixture-change"
  printf '{}\n' >"$root/.octon/state/evidence/local/terminal-closeout/fixture-change/manifest.json"

  mkdir -p "$root/.octon/generated/cognition/projections/materialized/runs/publish-1"
  printf 'run_health: projection\n' >"$root/.octon/generated/cognition/projections/materialized/runs/publish-1/index.yml"

  echo "$root"
}

authorize_fixture() {
  local root="$1"
  local selected_path="${2:-}"
  local receipt="$tmp_root/receipt-$fixture_index.json"
  if [[ -n "$selected_path" ]]; then
    bash "$HELPER" --root "$root" --cleanup-path "$selected_path" --authorize "$receipt" >/dev/null
  else
    bash "$HELPER" --root "$root" --authorize "$receipt" >/dev/null
  fi
  echo "$receipt"
}

first_authorized_path() {
  python3 - "$1" <<'PY'
import json
import sys
from pathlib import Path

receipt = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
for item in receipt["authorized_paths"]:
    path = item["path"]
    if not path.endswith("/.DS_Store") and path != ".DS_Store":
        print(path)
        break
else:
    print(receipt["authorized_paths"][0]["path"])
PY
}

mutate_receipt() {
  local receipt="$1"
  local mode="$2"
  local value="${3:-}"
  python3 - "$receipt" "$mode" "$value" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
mode = sys.argv[2]
value = sys.argv[3]
receipt = json.loads(path.read_text(encoding="utf-8"))

if mode == "deny":
    receipt["authorization_result"] = "denied"
elif mode == "path":
    receipt["authorized_paths"][0]["path"] = value
elif mode == "proof_false":
    receipt["authorized_paths"][0]["proofs"][value] = False
elif mode == "expire":
    receipt.pop("valid_until_status_changes", None)
    receipt["expires_at"] = "2000-01-01T00:00:00Z"
elif mode == "schema_extra":
    receipt["unexpected_field"] = True
else:
    raise SystemExit(f"unknown mutation mode: {mode}")

path.write_text(json.dumps(receipt, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY
}

root="$(make_fixture)"
dry_run_output="$(bash "$HELPER" --root "$root")"
assert_output_contains "$dry_run_output" "dry-run did not report cleanup candidates" "cleanup_candidate"
assert_output_contains "$dry_run_output" "dry-run did not classify stale receipt" ".octon/state/evidence/validation/publication/capabilities/stale.yml"
assert_output_contains "$dry_run_output" "dry-run did not classify lifecycle runner residue" "proposal lifecycle runner residue"
assert_output_not_contains "$dry_run_output" "dry-run treated diagnostic hygiene path listing as a liveness reference" "protected" ".octon/state/control/execution/runs/lifecycle-proposal-program-1/program-lifecycle-checkpoint.yml"
assert_output_contains "$dry_run_output" "dry-run did not classify closeout skill run residue" "closeout skill run residue"
assert_output_contains "$dry_run_output" "dry-run did not protect route-local closeout interaction request referenced by retained evidence" "protected" ".octon/state/evidence/runs/skills/octon-proposal-lifecycle-closeout-packet/lifecycle-proposal-program-fixture-child/lifecycle-interaction-request.json"
assert_output_contains "$dry_run_output" "dry-run did not protect route-local closeout classifier referenced by retained evidence" "protected" ".octon/state/evidence/runs/skills/octon-proposal-lifecycle-closeout-packet/lifecycle-proposal-program-fixture-child/worktree-hygiene.yml"
assert_output_not_contains "$dry_run_output" "dry-run treated retained closeout interaction request as cleanup candidate" "cleanup_candidate" ".octon/state/evidence/runs/skills/octon-proposal-lifecycle-closeout-packet/lifecycle-proposal-program-fixture-child/lifecycle-interaction-request.json"
assert_output_not_contains "$dry_run_output" "dry-run treated retained closeout classifier as cleanup candidate" "cleanup_candidate" ".octon/state/evidence/runs/skills/octon-proposal-lifecycle-closeout-packet/lifecycle-proposal-program-fixture-child/worktree-hygiene.yml"
assert_output_contains "$dry_run_output" "dry-run did not classify closed workflow-engine run residue" "closed workflow-engine run residue: workflow-engine-closed-1"
assert_output_contains "$dry_run_output" "dry-run did not classify terminal tool control residue" "terminal service tool invocation residue: tool-1000-2000"
assert_output_contains "$dry_run_output" "dry-run did not classify terminal service evidence residue" "terminal service tool invocation residue: tool-1000-2001"
assert_output_contains "$dry_run_output" "dry-run did not retain running workflow control state for manual review" "manual_review" ".octon/state/control/execution/runs/workflow-engine-running-1/runtime-state.yml"
assert_output_not_contains "$dry_run_output" "dry-run treated running workflow control state as cleanup candidate" "cleanup_candidate" ".octon/state/control/execution/runs/workflow-engine-running-1/runtime-state.yml"
assert_output_contains "$dry_run_output" "dry-run did not classify stale archive-proposal starter residue" "stale archive-proposal starter residue superseded by durable archive evidence: archive-proposal-stale-1"
assert_output_contains "$dry_run_output" "dry-run did not retain unsuperseded archive-proposal starter for manual review" "manual_review" ".octon/state/control/execution/runs/archive-proposal-unsuperseded-1/runtime-state.yml"
assert_output_not_contains "$dry_run_output" "dry-run treated unsuperseded archive-proposal starter as cleanup candidate" "cleanup_candidate" ".octon/state/control/execution/runs/archive-proposal-unsuperseded-1/runtime-state.yml"
assert_output_contains "$dry_run_output" "dry-run did not retain durable workflow evidence for manual review" "manual_review" ".octon/state/evidence/runs/workflow-engine-closed-1/checkpoints/execution-complete.yml"
assert_output_contains "$dry_run_output" "dry-run did not classify local filesystem metadata" "local_filesystem_metadata" ".octon/inputs/exploratory/proposals/fixture-local/.DS_Store"
assert_output_not_contains "$dry_run_output" "dry-run treated proposal input file as cleanup candidate" "cleanup_candidate" ".octon/inputs/exploratory/proposals/fixture-local/proposal.yml"
assert_output_contains "$dry_run_output" "dry-run did not protect referenced receipt" "protected" ".octon/state/evidence/validation/publication/capabilities/final.yml"
assert_output_contains "$dry_run_output" "dry-run did not surface manual-review artifact" "manual_review" ".octon/state/evidence/validation/analysis/manual.yml"
assert_output_contains "$dry_run_output" "dry-run did not protect terminal closeout local evidence sink" "manual_review" ".octon/state/evidence/local/terminal-closeout/fixture-change/manifest.json"
assert_output_contains "$dry_run_output" "dry-run did not route generated run-health projection to manual review" "generated_run_health_projection"

root="$(make_fixture)"
target_metadata_path=".octon/inputs/exploratory/proposals/fixture-local/.DS_Store"
target_receipt="$(authorize_fixture "$root" "$target_metadata_path")"
python3 - "$target_receipt" "$target_metadata_path" <<'PY'
import json
import sys
from pathlib import Path

receipt = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
target = sys.argv[2]
paths = [item["path"] for item in receipt["authorized_paths"]]
if paths != [target]:
    raise SystemExit(f"targeted receipt authorized unexpected paths: {paths}")
item = receipt["authorized_paths"][0]
if item["class"] != "local_filesystem_metadata":
    raise SystemExit(f"targeted receipt used unexpected class: {item['class']}")
PY
bash "$HELPER" --root "$root" --cleanup-path "$target_metadata_path" --authorization "$target_receipt" >/dev/null
assert_missing "$root/$target_metadata_path"
assert_exists "$root/.octon/inputs/exploratory/proposals/fixture-local/proposal.yml"
assert_exists "$root/.octon/state/evidence/validation/publication/capabilities/stale.yml"
assert_exists "$root/.octon/state/control/execution/runs/publish-1/run-manifest.yml"

root="$(make_fixture)"
active_run_output="$(bash "$HELPER" --root "$root" --active-run-id lifecycle-proposal-program-1)"
assert_output_contains "$active_run_output" "active run checkpoint was not protected" "protected" "active_run_state" ".octon/state/control/execution/runs/lifecycle-proposal-program-1/program-lifecycle-checkpoint.yml"
assert_output_contains "$active_run_output" "active run continuity artifact was not protected" "protected" "active_run_state" ".octon/state/continuity/runs/lifecycle-proposal-program-1-workflow/handoff.yml"
assert_output_contains "$active_run_output" "active run authority decision was not protected" "protected" "active_run_state" ".octon/state/evidence/control/execution/authority-decision-lifecycle-proposal-program-1.yml"
active_receipt="$tmp_root/active-receipt-$fixture_index.json"
bash "$HELPER" --root "$root" --active-run-id lifecycle-proposal-program-1 --authorize "$active_receipt" >/dev/null
bash "$HELPER" --root "$root" --active-run-id lifecycle-proposal-program-1 --authorization "$active_receipt" >/dev/null
assert_exists "$root/.octon/state/control/execution/runs/lifecycle-proposal-program-1/program-lifecycle-checkpoint.yml"
assert_exists "$root/.octon/state/continuity/runs/lifecycle-proposal-program-1-workflow/handoff.yml"
assert_exists "$root/.octon/state/evidence/control/execution/authority-decision-lifecycle-proposal-program-1.yml"
assert_missing "$root/.octon/state/control/execution/runs/publish-1/run-manifest.yml"

root="$(make_fixture)"
terminal_parent_run_id="lifecycle-proposal-program-fixture-20260620T132759Z"
terminal_attempt_run_id="lifecycle-proposal-program-fixture-20260620t1327-attempt-6-workflow-66808b729c300e05"
mkdir -p "$root/.octon/state/control/execution/runs/$terminal_attempt_run_id/context"
printf 'status: current terminal attempt\n' >"$root/.octon/state/control/execution/runs/$terminal_attempt_run_id/context/status.yml"
mkdir -p "$root/.octon/state/continuity/runs/$terminal_attempt_run_id-bind-profile"
printf 'handoff: current terminal attempt\n' >"$root/.octon/state/continuity/runs/$terminal_attempt_run_id-bind-profile/handoff.yml"
terminal_attempt_output="$(bash "$HELPER" --root "$root" --active-run-id "$terminal_parent_run_id")"
assert_output_contains "$terminal_attempt_output" "derived terminal attempt context was not protected" "protected" "active_run_state" ".octon/state/control/execution/runs/$terminal_attempt_run_id/context/status.yml"
assert_output_contains "$terminal_attempt_output" "derived terminal attempt continuity state was not protected" "protected" "active_run_state" ".octon/state/continuity/runs/$terminal_attempt_run_id-bind-profile/handoff.yml"
assert_output_not_contains "$terminal_attempt_output" "derived terminal attempt context was treated as cleanup candidate" "cleanup_candidate" ".octon/state/control/execution/runs/$terminal_attempt_run_id/context/status.yml"
terminal_attempt_receipt="$tmp_root/terminal-attempt-receipt-$fixture_index.json"
bash "$HELPER" --root "$root" --active-run-id "$terminal_parent_run_id" --authorize "$terminal_attempt_receipt" >/dev/null
bash "$HELPER" --root "$root" --active-run-id "$terminal_parent_run_id" --authorization "$terminal_attempt_receipt" >/dev/null
assert_exists "$root/.octon/state/control/execution/runs/$terminal_attempt_run_id/context/status.yml"
assert_exists "$root/.octon/state/continuity/runs/$terminal_attempt_run_id-bind-profile/handoff.yml"

root="$(make_fixture)"
active_workflow_output="$(bash "$HELPER" --root "$root" --active-run-id workflow-engine-closed-1)"
assert_output_contains "$active_workflow_output" "active workflow runtime state was not protected" "protected" "active_run_state" ".octon/state/control/execution/runs/workflow-engine-closed-1/runtime-state.yml"
assert_output_contains "$active_workflow_output" "active workflow continuity artifact was not protected" "protected" "active_run_state" ".octon/state/continuity/runs/workflow-engine-closed-1/handoff.yml"
assert_output_contains "$active_workflow_output" "active workflow authority decision was not protected" "protected" "active_run_state" ".octon/state/evidence/control/execution/authority-decision-workflow-engine-closed-1.yml"
workflow_active_receipt="$tmp_root/active-workflow-receipt-$fixture_index.json"
bash "$HELPER" --root "$root" --active-run-id workflow-engine-closed-1 --authorize "$workflow_active_receipt" >/dev/null
bash "$HELPER" --root "$root" --active-run-id workflow-engine-closed-1 --authorization "$workflow_active_receipt" >/dev/null
assert_exists "$root/.octon/state/control/execution/runs/workflow-engine-closed-1/runtime-state.yml"
assert_exists "$root/.octon/state/continuity/runs/workflow-engine-closed-1/handoff.yml"
assert_exists "$root/.octon/state/evidence/control/execution/authority-decision-workflow-engine-closed-1.yml"

root="$(make_fixture)"
in_repo_receipt="$root/.octon/state/evidence/runs/skills/repo-hygiene-cleanup/lifecycle-proposal-program-fixture/cleanup-authorization.json"
bash "$HELPER" --root "$root" --authorize "$in_repo_receipt" >/dev/null
bash "$HELPER" --root "$root" --authorization "$in_repo_receipt" >/dev/null
assert_exists "$in_repo_receipt"
assert_missing "$root/.octon/state/evidence/validation/publication/capabilities/stale.yml"
assert_missing "$root/.octon/state/control/execution/runs/publish-1/run-manifest.yml"
assert_exists "$root/.octon/state/evidence/validation/publication/capabilities/final.yml"

root="$(make_fixture)"
receipt="$(authorize_fixture "$root")"
grep -F '"schema_version": "repo-hygiene-cleanup-authorization-v1"' "$receipt" >/dev/null || fail "authorization receipt has wrong schema version"
bash "$HELPER" --root "$root" --authorization "$receipt" >/dev/null
assert_missing "$root/.octon/state/evidence/validation/publication/capabilities/stale.yml"
assert_missing "$root/.octon/state/control/execution/runs/publish-1/run-manifest.yml"
assert_missing "$root/.octon/state/continuity/runs/service-build-1/state.yml"
assert_missing "$root/.octon/state/control/engine/agent/checkpoints/runtime-agent-quorum-allow-1.json"
assert_missing "$root/.octon/state/control/execution/runs/lifecycle-proposal-program-1/program-lifecycle-checkpoint.yml"
assert_missing "$root/.octon/state/continuity/runs/lifecycle-proposal-program-1-workflow/handoff.yml"
assert_missing "$root/.octon/state/evidence/control/execution/authority-decision-lifecycle-proposal-program-1.yml"
assert_missing "$root/.octon/state/evidence/control/execution/authority-grant-bundle-lifecycle-proposal-program-1.yml"
assert_missing "$root/.octon/state/evidence/external-index/runs/lifecycle-proposal-program-1.yml"
assert_missing "$root/.octon/state/control/execution/runs/workflow-engine-closed-1/runtime-state.yml"
assert_missing "$root/.octon/state/continuity/runs/workflow-engine-closed-1/handoff.yml"
assert_missing "$root/.octon/state/evidence/control/execution/authority-decision-workflow-engine-closed-1.yml"
assert_missing "$root/.octon/state/evidence/control/execution/authority-grant-bundle-workflow-engine-closed-1.yml"
assert_missing "$root/.octon/state/evidence/external-index/runs/workflow-engine-closed-1.yml"
assert_missing "$root/.octon/state/control/execution/runs/archive-proposal-stale-1/runtime-state.yml"
assert_missing "$root/.octon/state/continuity/runs/archive-proposal-stale-1/handoff.yml"
assert_missing "$root/.octon/state/evidence/control/execution/authority-decision-archive-proposal-stale-1.yml"
assert_missing "$root/.octon/state/evidence/control/execution/authority-grant-bundle-archive-proposal-stale-1.yml"
assert_missing "$root/.octon/state/evidence/external-index/runs/archive-proposal-stale-1.yml"
assert_exists "$root/.octon/state/control/execution/runs/archive-proposal-unsuperseded-1/runtime-state.yml"
assert_exists "$root/.octon/state/evidence/runs/workflows/2026-06-15-archive-proposal-octon-inputs-exploratory-proposals-architecture-archive-fixture/summary.md"
assert_exists "$root/.octon/state/evidence/runs/workflow-engine-closed-1/checkpoints/execution-complete.yml"
assert_exists "$root/.octon/state/control/execution/runs/workflow-engine-running-1/runtime-state.yml"
assert_missing "$root/.octon/state/evidence/runs/skills/closeout-worktree/run-1/log.yml"
assert_exists "$root/.octon/state/evidence/runs/skills/octon-proposal-lifecycle-closeout-packet/lifecycle-proposal-program-fixture-child/lifecycle-interaction-request.json"
assert_exists "$root/.octon/state/evidence/runs/skills/octon-proposal-lifecycle-closeout-packet/lifecycle-proposal-program-fixture-child/worktree-hygiene.yml"
assert_missing "$root/.octon/inputs/exploratory/proposals/fixture-local/.DS_Store"
assert_exists "$root/.octon/inputs/exploratory/proposals/fixture-local/proposal.yml"
assert_exists "$root/.octon/state/evidence/validation/publication/capabilities/final.yml"
assert_exists "$root/.octon/state/evidence/validation/analysis/manual.yml"
assert_exists "$root/.octon/state/evidence/local/terminal-closeout/fixture-change/manifest.json"
assert_exists "$root/.octon/generated/cognition/projections/materialized/runs/publish-1/index.yml"

root="$(make_fixture)"
bash "$HELPER" --root "$root" --confirm >/dev/null
assert_missing "$root/.octon/state/evidence/validation/publication/capabilities/stale.yml"
assert_missing "$root/.octon/inputs/exploratory/proposals/fixture-local/.DS_Store"
assert_exists "$root/.octon/inputs/exploratory/proposals/fixture-local/proposal.yml"
assert_exists "$root/.octon/state/evidence/validation/publication/capabilities/final.yml"

assert_fails "--fail-on-manual" bash "$HELPER" --root "$root" --fail-on-manual

root="$(make_fixture)"
assert_fails "missing authorization receipt" bash "$HELPER" --root "$root" --authorization "$root/missing.json"

root="$(make_fixture)"
malformed="$tmp_root/malformed.json"
printf '{not-json\n' >"$malformed"
assert_fails "malformed authorization receipt" bash "$HELPER" --root "$root" --authorization "$malformed"

root="$(make_fixture)"
receipt="$(authorize_fixture "$root")"
mutate_receipt "$receipt" deny
assert_fails "denied authorization receipt" bash "$HELPER" --root "$root" --authorization "$receipt"

root="$(make_fixture)"
receipt="$(authorize_fixture "$root")"
mutate_receipt "$receipt" schema_extra
assert_fails "schema-invalid authorization receipt" bash "$HELPER" --root "$root" --authorization "$receipt"

root="$(make_fixture)"
receipt="$(authorize_fixture "$root")"
mutate_receipt "$receipt" expire
assert_fails "expired authorization receipt" bash "$HELPER" --root "$root" --authorization "$receipt"

root="$(make_fixture)"
receipt="$(authorize_fixture "$root")"
mkdir -p "$root/.octon/state/control/execution/runs/publish-2"
printf 'run: publish\n' >"$root/.octon/state/control/execution/runs/publish-2/run-manifest.yml"
assert_fails "stale status and path-set authorization receipt" bash "$HELPER" --root "$root" --authorization "$receipt"

root="$(make_fixture)"
receipt="$(authorize_fixture "$root")"
mutate_receipt "$receipt" path ".octon/state/evidence/validation/publication/capabilities/final.yml"
assert_fails "path-mismatched protected authorization receipt" bash "$HELPER" --root "$root" --authorization "$receipt"

root="$(make_fixture)"
receipt="$(authorize_fixture "$root")"
candidate="$(first_authorized_path "$receipt")"
git -C "$root" add "$candidate"
git -C "$root" -c user.name="Octon Test" -c user.email="octon@example.invalid" commit -m "track cleanup candidate" >/dev/null
assert_fails "tracked path authorization receipt" bash "$HELPER" --root "$root" --authorization "$receipt"

root="$(make_fixture)"
receipt="$(authorize_fixture "$root")"
candidate="$(first_authorized_path "$receipt")"
printf 'ref: %s\n' "$candidate" >"$root/tracked-reference.yml"
git -C "$root" add tracked-reference.yml
git -C "$root" -c user.name="Octon Test" -c user.email="octon@example.invalid" commit -m "reference cleanup candidate" >/dev/null
assert_fails "referenced path authorization receipt" bash "$HELPER" --root "$root" --authorization "$receipt"

root="$(make_fixture)"
receipt="$(authorize_fixture "$root")"
mutate_receipt "$receipt" path ".octon/state/evidence/validation/analysis/manual.yml"
assert_fails "manual-review durable evidence authorization receipt" bash "$HELPER" --root "$root" --authorization "$receipt"

root="$(make_fixture)"
receipt="$(authorize_fixture "$root")"
mutate_receipt "$receipt" path ".octon/state/control/custom.yml"
assert_fails "active control authorization receipt" bash "$HELPER" --root "$root" --authorization "$receipt"

root="$(make_fixture)"
receipt="$(authorize_fixture "$root")"
mutate_receipt "$receipt" path ".octon/inputs/exploratory/proposals/fixture-local/proposal.yml"
assert_fails "proposal input file authorization receipt" bash "$HELPER" --root "$root" --authorization "$receipt"

root="$(make_fixture)"
receipt="$(authorize_fixture "$root")"
mutate_receipt "$receipt" path ".octon/generated/effective/capabilities/generation.lock.yml"
assert_fails "generated authority authorization receipt" bash "$HELPER" --root "$root" --authorization "$receipt"

root="$(make_fixture)"
receipt="$(authorize_fixture "$root")"
mutate_receipt "$receipt" path ".octon/generated/cognition/projections/materialized/runs/publish-1/index.yml"
assert_fails "generated run-health authorization receipt" bash "$HELPER" --root "$root" --authorization "$receipt"

root="$(make_fixture)"
receipt="$(authorize_fixture "$root")"
mutate_receipt "$receipt" path ".octon/state/evidence/local/terminal-closeout/fixture-change/manifest.json"
assert_fails "terminal closeout local evidence sink authorization receipt" bash "$HELPER" --root "$root" --authorization "$receipt"

root="$(make_fixture)"
receipt="$(authorize_fixture "$root")"
mutate_receipt "$receipt" proof_false "not_ignored_or_user_owned_residue"
assert_fails "ignored or user-owned residue authorization proof" bash "$HELPER" --root "$root" --authorization "$receipt"

root="$(make_fixture)"
bounded_scan_output="$(OCTON_CLEANUP_REFERENCE_SCAN_PATTERN_LIMIT=1 bash "$HELPER" --root "$root" --summary-only)"
assert_output_contains "$bounded_scan_output" "bounded reference scan did not report fail-safe status" "reference_scan_status: bounded-overprotect"
assert_output_contains "$bounded_scan_output" "bounded reference scan did not over-protect cleanup-safe local residue" "protected_referenced:"
assert_output_not_contains "$bounded_scan_output" "bounded reference scan treated retained publication residue as cleanup candidate" "cleanup_candidate" ".octon/state/evidence/validation/publication/capabilities/stale.yml"

root="$(make_fixture)"
python3 - "$root" <<'PY'
import sys
from pathlib import Path

root = Path(sys.argv[1])
publication_dir = root / ".octon/state/evidence/validation/publication/extensions"
publication_dir.mkdir(parents=True, exist_ok=True)
for index in range(3000):
    (publication_dir / f"large-bounded-{index:04d}.yml").write_text(
        f"receipt: large-bounded-{index:04d}\n",
        encoding="utf-8",
    )
PY
large_bounded_scan_output="$(HELPER="$HELPER" ROOT="$root" python3 - <<'PY'
import os
import subprocess

env = os.environ.copy()
env["OCTON_CLEANUP_REFERENCE_SCAN_PATTERN_LIMIT"] = "1"
completed = subprocess.run(
    ["bash", os.environ["HELPER"], "--root", os.environ["ROOT"], "--summary-only"],
    check=True,
    capture_output=True,
    env=env,
    text=True,
    timeout=60,
)
print(completed.stdout, end="")
PY
)"
assert_output_contains "$large_bounded_scan_output" "large bounded reference scan did not report fail-safe status" "reference_scan_status: bounded-overprotect"
assert_output_contains "$large_bounded_scan_output" "large bounded reference scan did not retain manual-review residue" "manual_review:"
python3 - "$large_bounded_scan_output" <<'PY'
import re
import sys

output = sys.argv[1]
match = re.search(r"protected_referenced:\s*([0-9]+)", output)
if not match:
    raise SystemExit("missing protected_referenced summary")
if int(match.group(1)) < 3000:
    raise SystemExit(f"large bounded reference scan protected too few paths: {match.group(1)}")
PY

root="$(make_fixture)"
python3 - "$root" <<'PY'
import sys
from pathlib import Path

root = Path(sys.argv[1])
publication_dir = root / ".octon/state/evidence/validation/publication/extensions"
publication_dir.mkdir(parents=True, exist_ok=True)
for index in range(3000):
    path = publication_dir / f"large-complete-{index:04d}.yml"
    path.write_text(f"receipt: large-complete-{index:04d}\n", encoding="utf-8")
(root / "tracked-large-reference.yml").write_text(
    "ref: .octon/state/evidence/validation/publication/extensions/large-complete-0042.yml\n",
    encoding="utf-8",
)
PY
git -C "$root" add tracked-large-reference.yml
git -C "$root" -c user.name="Octon Test" -c user.email="octon@example.invalid" commit -m "reference large cleanup candidate" >/dev/null
large_complete_scan_output="$(HELPER="$HELPER" ROOT="$root" python3 - <<'PY'
import os
import subprocess

env = os.environ.copy()
env["OCTON_CLEANUP_REFERENCE_SCAN_PATTERN_LIMIT"] = "10000"
completed = subprocess.run(
    ["bash", os.environ["HELPER"], "--root", os.environ["ROOT"], "--summary-only"],
    check=True,
    capture_output=True,
    env=env,
    text=True,
    timeout=20,
)
print(completed.stdout, end="")
PY
)"
assert_output_contains "$large_complete_scan_output" "large complete reference scan did not finish" "reference_scan_status: complete"
python3 - "$large_complete_scan_output" <<'PY'
import re
import sys

output = sys.argv[1]
protected = re.search(r"protected_referenced:\s*([0-9]+)", output)
cleanup = re.search(r"cleanup_candidates:\s*([0-9]+)", output)
if not protected or int(protected.group(1)) < 1:
    raise SystemExit("large complete reference scan did not protect the tracked reference")
if not cleanup or int(cleanup.group(1)) < 1:
    raise SystemExit("large complete reference scan did not leave unreferenced candidates cleanup-eligible")
PY

root="$(make_fixture)"
fake_git_bin="$tmp_root/fake-git-bin-$fixture_index"
mkdir -p "$fake_git_bin"
real_git="$(command -v git)"
cat >"$fake_git_bin/git" <<EOF
#!/usr/bin/env bash
found_grep=0
found_z=0
for arg in "\$@"; do
  [[ "\$arg" == "grep" ]] && found_grep=1
  [[ "\$arg" == "-z" ]] && found_z=1
done
if [[ "\$found_grep" == "1" && "\$found_z" == "1" ]]; then
  exit 137
fi
exec "$real_git" "\$@"
EOF
chmod +x "$fake_git_bin/git"
failed_scan_output="$(PATH="$fake_git_bin:$PATH" OCTON_CLEANUP_REFERENCE_SCAN_PATTERN_LIMIT=10000 bash "$HELPER" --root "$root" --summary-only)"
assert_output_contains "$failed_scan_output" "failed reference scan did not report fail-safe status" "reference_scan_status: failed-overprotect"
assert_output_contains "$failed_scan_output" "failed reference scan did not overprotect cleanup candidates" "cleanup_candidates: 0"
assert_output_not_contains "$failed_scan_output" "failed reference scan treated residue as cleanup candidate" "cleanup_candidate" ".octon/state/evidence/validation/publication/capabilities/stale.yml"

echo "[OK] cleanup-local-run-artifacts helper preserves referenced evidence and requires validating cleanup authorization receipts"
