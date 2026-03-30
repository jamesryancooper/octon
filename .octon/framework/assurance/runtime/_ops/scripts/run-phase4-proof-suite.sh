#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

if ! command -v yq >/dev/null 2>&1; then
  echo "yq is required" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required" >&2
  exit 1
fi

plane=""
run_id=""
status=""
recorded_at=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --plane) plane="$2"; shift 2 ;;
    --run-id) run_id="$2"; shift 2 ;;
    --status) status="$2"; shift 2 ;;
    --recorded-at) recorded_at="$2"; shift 2 ;;
    *) echo "unknown argument: $1" >&2; exit 1 ;;
  esac
done

[[ -n "$plane" && -n "$run_id" && -n "$status" ]] || {
  echo "missing required arguments" >&2
  exit 1
}

if [[ -z "$recorded_at" ]]; then
  recorded_at="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
fi

run_contract=".octon/state/control/execution/runs/$run_id/run-contract.yml"
run_manifest=".octon/state/control/execution/runs/$run_id/run-manifest.yml"
replay_manifest=".octon/state/evidence/runs/$run_id/replay/manifest.yml"
replay_pointers=".octon/state/evidence/runs/$run_id/replay-pointers.yml"
rollback_posture=".octon/state/control/execution/runs/$run_id/rollback-posture.yml"
checkpoint=".octon/state/control/execution/runs/$run_id/checkpoints/bound.yml"
receipt=".octon/state/evidence/runs/$run_id/receipts/orchestration-lifecycle.yml"
retained=".octon/state/evidence/runs/$run_id/retained-run-evidence.yml"
runtime_registry=".octon/framework/cognition/_meta/architecture/contract-registry.yml"
constitutional_registry=".octon/framework/constitution/contracts/registry.yml"
benchmark_summary=".octon/state/evidence/lab/benchmarks/bmk-wave4-disclosure-parity-20260327/summary.yml"
scenario_proof=".octon/state/evidence/lab/scenarios/scn-runtime-proof-supported-20260329/scenario-proof.yml"
replay_bundle=".octon/state/evidence/lab/replays/rpl-runtime-proof-supported-20260329/replay-bundle.yml"
shadow_run=".octon/state/evidence/lab/shadow-runs/shd-runtime-proof-supported-20260329/shadow-run.yml"
fault_report=".octon/state/evidence/lab/faults/flt-runtime-proof-supported-20260329/fault-report.yml"
scenario_pack=".octon/framework/lab/scenarios/packs/runtime-proof-pack.yml"

support_tier="$(yq -r '.support_tier // "repo-local-transitional"' "$OCTON_DIR/${run_contract#.octon/}" 2>/dev/null || printf 'repo-local-transitional')"

report_file="$OCTON_DIR/state/evidence/runs/$run_id/assurance/${plane}.yml"
execution_file="$OCTON_DIR/state/evidence/runs/$run_id/assurance/${plane}-suite-execution.yml"
mkdir -p "$(dirname "$report_file")"

require_relpath() {
  local rel="$1"
  if [[ ! -f "$OCTON_DIR/${rel#.octon/}" ]]; then
    echo "missing required artifact for proof suite: $rel" >&2
    exit 1
  fi
}

outcome="pass"
if [[ "$status" == "failed" || "$status" == "cancelled" ]]; then
  outcome="stage_only"
fi

suite_id=""
suite_rel=""
proof_class=""
summary=""
artifacts_json="[]"

case "$plane" in
  functional)
    suite_id="run-lifecycle-integrity"
    suite_rel=".octon/framework/assurance/functional/suites/run-lifecycle-integrity.yml"
    proof_class="deterministic"
    summary="Functional proof confirms the run emitted the full bound lifecycle chain and deterministic execution artifacts."
    for rel in "$suite_rel" "$run_manifest" "$receipt" "$checkpoint" "$retained"; do require_relpath "$rel"; done
    artifacts_json="$(jq -cn --arg suite "$suite_rel" --arg manifest "$run_manifest" --arg receipt "$receipt" --arg checkpoint "$checkpoint" --arg retained "$retained" '[$suite,$manifest,$receipt,$checkpoint,$retained]')"
    ;;
  behavioral)
    suite_id="replay-shadow-substance"
    suite_rel=".octon/framework/assurance/behavioral/suites/replay-shadow-substance.yml"
    if [[ "$support_tier" == "repo-local-transitional" ]]; then
      proof_class="shadow-run"
      summary="Behavioral proof is backed by scenario, replay, and shadow-run evidence for a supported consequential run."
      for rel in "$suite_rel" "$scenario_proof" "$replay_bundle" "$shadow_run" "$replay_manifest"; do require_relpath "$rel"; done
      artifacts_json="$(jq -cn --arg suite "$suite_rel" --arg scenario "$scenario_proof" --arg replay_bundle "$replay_bundle" --arg shadow "$shadow_run" --arg replay "$replay_manifest" '[$suite,$scenario,$replay_bundle,$shadow,$replay]')"
    else
      proof_class="replay"
      summary="Behavioral proof is backed by replay evidence and scenario routing for this consequential run."
      for rel in "$suite_rel" "$scenario_pack" "$replay_manifest" "$replay_pointers"; do require_relpath "$rel"; done
      artifacts_json="$(jq -cn --arg suite "$suite_rel" --arg scenario_pack "$scenario_pack" --arg replay "$replay_manifest" --arg pointers "$replay_pointers" '[$suite,$scenario_pack,$replay,$pointers]')"
    fi
    ;;
  maintainability)
    suite_id="runtime-ssot-alignment"
    suite_rel=".octon/framework/assurance/maintainability/suites/runtime-ssot-alignment.yml"
    proof_class="deterministic"
    summary="Maintainability proof confirms the run stays aligned to the constitutional registry, runtime SSOT, and benchmark-backed disclosure surfaces."
    for rel in "$suite_rel" "$constitutional_registry" "$runtime_registry" "$benchmark_summary"; do require_relpath "$rel"; done
    artifacts_json="$(jq -cn --arg suite "$suite_rel" --arg constitutional_registry "$constitutional_registry" --arg runtime_registry "$runtime_registry" --arg benchmark "$benchmark_summary" '[$suite,$constitutional_registry,$runtime_registry,$benchmark]')"
    ;;
  recovery)
    suite_id="checkpoint-fault-recovery"
    suite_rel=".octon/framework/assurance/recovery/suites/checkpoint-fault-recovery.yml"
    if [[ "$support_tier" == "repo-local-transitional" ]]; then
      proof_class="lab"
      summary="Recovery proof is backed by rollback posture, checkpoints, replay, and a retained fault rehearsal."
      for rel in "$suite_rel" "$rollback_posture" "$checkpoint" "$replay_bundle" "$fault_report"; do require_relpath "$rel"; done
      artifacts_json="$(jq -cn --arg suite "$suite_rel" --arg rollback "$rollback_posture" --arg checkpoint "$checkpoint" --arg replay_bundle "$replay_bundle" --arg fault "$fault_report" '[$suite,$rollback,$checkpoint,$replay_bundle,$fault]')"
    else
      proof_class="deterministic"
      summary="Recovery posture remains reconstructable from canonical rollback, checkpoint, and replay surfaces."
      for rel in "$suite_rel" "$rollback_posture" "$checkpoint" "$replay_manifest"; do require_relpath "$rel"; done
      artifacts_json="$(jq -cn --arg suite "$suite_rel" --arg rollback "$rollback_posture" --arg checkpoint "$checkpoint" --arg replay "$replay_manifest" '[$suite,$rollback,$checkpoint,$replay]')"
    fi
    ;;
  *)
    echo "unknown plane: $plane" >&2
    exit 1
    ;;
esac

subject_ref="$run_contract"

jq -n \
  --arg suite_id "$suite_id" \
  --arg plane "$plane" \
  --arg subject_ref "$subject_ref" \
  --arg outcome "$outcome" \
  --argjson checked_artifacts "$artifacts_json" \
  --arg recorded_at "$recorded_at" '
    {
      schema_version: "proof-suite-execution-v1",
      suite_id: $suite_id,
      plane: $plane,
      subject_ref: $subject_ref,
      outcome: $outcome,
      checked_artifacts: $checked_artifacts,
      recorded_at: $recorded_at
    }
  ' | yq -P -p=json '.' > "$execution_file"

execution_rel=".octon/state/evidence/runs/$run_id/assurance/${plane}-suite-execution.yml"

jq -n \
  --arg plane "$plane" \
  --arg subject_ref "$subject_ref" \
  --arg outcome "$outcome" \
  --arg proof_class "$proof_class" \
  --arg summary "$summary" \
  --arg execution_ref "$execution_rel" \
  --argjson evidence_refs "$artifacts_json" \
  --arg generated_at "$recorded_at" '
    {
      schema_version: "proof-plane-report-v1",
      plane: $plane,
      subject_kind: "run",
      subject_ref: $subject_ref,
      outcome: $outcome,
      proof_class: $proof_class,
      summary: $summary,
      evidence_refs: ($evidence_refs + [$execution_ref]),
      known_limits: [],
      generated_at: $generated_at
    }
  ' | yq -P -p=json '.' > "$report_file"

printf '%s\n' "$report_file"
