#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$(cd "$OPS_DIR/.." && pwd)"
ASSURANCE_DIR="$(cd "$RUNTIME_DIR/.." && pwd)"
FRAMEWORK_DIR="$(cd "$ASSURANCE_DIR/.." && pwd)"
OCTON_DIR="$(cd "$FRAMEWORK_DIR/.." && pwd)"
REPO_ROOT="$(cd "$OCTON_DIR/.." && pwd)"
CARGO_MANIFEST="$REPO_ROOT/.octon/framework/engine/runtime/crates/Cargo.toml"
REAL_CONTRACT="$REPO_ROOT/.octon/generated/effective/extensions/published/octon-proposal-packet-lifecycle/bundled-first-party/context/lifecycle.contract.yml"
REAL_REVIEW_GATE="$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh"

pass_count=0
fail_count=0
declare -a CLEANUP_DIRS=()

cleanup() {
  local dir
  for dir in "${CLEANUP_DIRS[@]}"; do
    [[ -n "$dir" ]] && rm -r "$dir"
  done
}
trap cleanup EXIT

pass() { printf 'PASS: %s\n' "$1"; pass_count=$((pass_count + 1)); }
fail() { printf 'FAIL: %s\n' "$1" >&2; fail_count=$((fail_count + 1)); }

new_fixture_repo() {
  local root
  root="$(mktemp -d "${TMPDIR:-/tmp}/proposal-lifecycle-v1.XXXXXX")"
  CLEANUP_DIRS+=("$root")
  mkdir -p "$root/.octon/generated/effective/extensions/published/octon-proposal-packet-lifecycle/bundled-first-party/context"
  mkdir -p "$root/.octon/framework/assurance/runtime/_ops/scripts"
  cp "$REAL_CONTRACT" "$root/.octon/generated/effective/extensions/published/octon-proposal-packet-lifecycle/bundled-first-party/context/lifecycle.contract.yml"
  cp "$REAL_REVIEW_GATE" "$root/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh"
  cat >"$root/.octon/generated/effective/extensions/catalog.effective.yml" <<'YAML'
schema_version: "octon-extension-effective-catalog-v7"
packs:
  - pack_id: "octon-proposal-packet-lifecycle"
    source_id: "bundled-first-party"
    capability_profiles:
      - "validation-surface"
      - "command-surface"
      - "skill-surface"
      - "prompt-bundle"
      - "routing-contract"
      - "lifecycle-contract"
    lifecycle_contracts:
      - lifecycle_id: "proposal-packet"
        projection_source_path: ".octon/generated/effective/extensions/published/octon-proposal-packet-lifecycle/bundled-first-party/context/lifecycle.contract.yml"
YAML
  printf '%s\n' "$root"
}

octon_cli() {
  local root="$1"
  shift
  OCTON_ROOT_DIR="$root" cargo run --quiet --manifest-path "$CARGO_MANIFEST" -p octon_kernel --bin octon -- "$@"
}

packet_dir() {
  local root="$1" name="$2"
  printf '%s/%s\n' "$root" "$name"
}

packet_digest() {
  local root="$1" name="$2"
  (
    cd "$root"
    bash ".octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh" \
      --package "$name" \
      --print-digest
  )
}

write_packet() {
  local root="$1" name="$2" status="$3"
  local dir
  dir="$(packet_dir "$root" "$name")"
  mkdir -p "$dir/support"
  cat >"$dir/proposal.yml" <<EOF
schema_version: "proposal-v1"
proposal_id: "$name"
title: "Lifecycle V1 $name"
summary: "Lifecycle V1 acceptance fixture."
proposal_kind: "architecture"
promotion_scope: "octon-internal"
promotion_targets:
  - ".octon/framework/example.md"
status: "$status"
lifecycle:
  temporary: true
  exit_expectation: "Promote and archive."
related_proposals: []
EOF
  cat >"$dir/README.md" <<EOF
# Lifecycle V1 $name
EOF
  cat >"$dir/support/implementation-grade-completeness-review.md" <<'EOF'
# Implementation-Grade Completeness Review

verdict: pass
unresolved_questions_count: 0
clarification_required: no
EOF
}

write_review() {
  local root="$1" name="$2" verdict="$3" auth="$4" blockers="$5"
  local digest dir
  dir="$(packet_dir "$root" "$name")"
  digest="$(packet_digest "$root" "$name")"
  cat >"$dir/support/proposal-review.md" <<EOF
# Proposal Review

review_id: review-$name
reviewed_at: 2026-05-07T00:00:00Z
reviewer: v1-acceptance
verdict: $verdict
implementation_prompt_authorized: $auth
reviewed_packet_digest: $digest
open_blocking_findings_count: $blockers

## Approved Promotion Targets

- .octon/framework/example.md

## Exclusions

None.

## Blocking Findings

Open blocker count: $blockers.

## Nonblocking Findings

None.

## Final Route Recommendation

Proceed according to the recorded verdict.
EOF
}

write_incomplete_review() {
  local root="$1" name="$2"
  local digest dir
  dir="$(packet_dir "$root" "$name")"
  digest="$(packet_digest "$root" "$name")"
  cat >"$dir/support/proposal-review.md" <<EOF
# Proposal Review

review_id: review-$name
reviewed_at:
reviewer: v1-acceptance
verdict: revision-required
implementation_prompt_authorized: no
reviewed_packet_digest: $digest
open_blocking_findings_count: 1
EOF
}

write_receipt() {
  local root="$1" name="$2" rel="$3"
  shift 3
  mkdir -p "$(dirname "$(packet_dir "$root" "$name")/$rel")"
  printf '%s\n' "$@" >"$(packet_dir "$root" "$name")/$rel"
}

assert_plan_route() {
  local label="$1" root="$2" target="$3" expected="$4" output
  output="$(octon_cli "$root" lifecycle plan --lifecycle proposal-packet --target "$target")"
  if yq -e ".next_route.route_id == \"$expected\"" >/dev/null <<<"$output"; then
    pass "$label"
  else
    printf '%s\n' "$output" >&2
    fail "$label"
  fi
}

assert_plan_route_with_gate_pass() {
  local label="$1" root="$2" target="$3" expected="$4" output
  output="$(octon_cli "$root" lifecycle plan --lifecycle proposal-packet --target "$target")"
  if yq -e ".next_route.route_id == \"$expected\" and (.gate_results | length) > 0 and .gate_results[0].passed == true" >/dev/null <<<"$output"; then
    pass "$label"
  else
    printf '%s\n' "$output" >&2
    fail "$label"
  fi
}

assert_plan_terminal() {
  local label="$1" root="$2" target="$3" expected="$4" output
  output="$(octon_cli "$root" lifecycle plan --lifecycle proposal-packet --target "$target")"
  if yq -e ".terminal_outcome == \"$expected\" and .next_route == null and .final_verdict == \"completed\"" >/dev/null <<<"$output"; then
    pass "$label"
  else
    printf '%s\n' "$output" >&2
    fail "$label"
  fi
}

assert_plan_blocked() {
  local label="$1" root="$2" target="$3" output
  output="$(octon_cli "$root" lifecycle plan --lifecycle proposal-packet --target "$target")"
  if yq -e '.terminal_outcome == null and .next_route == null and .final_verdict == "blocked-no-route"' >/dev/null <<<"$output"; then
    pass "$label"
  else
    printf '%s\n' "$output" >&2
    fail "$label"
  fi
}

assert_review_gate_success() {
  local label="$1" root="$2" target="$3"
  if (
    cd "$root"
    bash ".octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh" \
      --package "$target" \
      --require-implementation-authorization >/tmp/octon-v1-review-gate.out 2>&1
  ); then
    pass "$label"
  else
    cat /tmp/octon-v1-review-gate.out >&2
    fail "$label"
  fi
}

assert_registry_generator_portable_surface() {
  local generator="$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh"
  if grep -Eq '(^|[[:space:]])(declare|typeset)[[:space:]]+-A([[:space:]]|$)' "$generator"; then
    fail "proposal registry generator avoids Bash 4 associative arrays"
  else
    pass "proposal registry generator avoids Bash 4 associative arrays"
  fi
}

main() {
  local root output
  root="$(new_fixture_repo)"

  assert_registry_generator_portable_surface

  assert_plan_route "missing target routes to proposal creation" "$root" missing-packet create-proposal-packet

  mkdir -p "$(packet_dir "$root" partial-packet)/resources"
  printf '# Partial source\n' >"$(packet_dir "$root" partial-packet)/resources/source-context.md"
  assert_plan_route "partial target without manifest routes to proposal creation" "$root" partial-packet create-proposal-packet

  write_packet "$root" draft-packet draft
  assert_plan_route "draft routes to proposal review" "$root" draft-packet review-proposal-packet

  output="$(octon_cli "$root" lifecycle run --lifecycle proposal-packet --target missing-source-packet --run-id missing-source --executor mock --execute-routes --approval-policy unattended --max-steps 2)"
  if yq -e '.final_verdict == "blocked" and .selected_route.route_id == "create-proposal-packet"' >/dev/null <<<"$output" \
    && [[ -f "$root/.octon/state/evidence/runs/workflows/missing-source/create-proposal-packet-input-binding-blocked.yml" ]] \
    && [[ ! -f "$(packet_dir "$root" missing-source-packet)/proposal.yml" ]]; then
    pass "missing creation source blocks before packet creation"
  else
    printf '%s\n' "$output" >&2
    fail "missing creation source blocks before packet creation"
  fi

  printf 'source from set-file\n' >"$root/source-context.txt"
  output="$(octon_cli "$root" lifecycle run --lifecycle proposal-packet --target set-file-packet --run-id set-file-create --executor mock --execute-routes --approval-policy unattended --max-steps 1 --set-file source=source-context.txt)"
  if yq -e '.final_verdict == "blocked-max-steps"' >/dev/null <<<"$output" \
    && yq -e '.run_inputs.source == "source from set-file\n"' "$root/.octon/state/control/execution/runs/set-file-create/lifecycle-checkpoint.yml" >/dev/null \
    && grep -q 'source from set-file' "$(packet_dir "$root" set-file-packet)/resources/source-context.md"; then
    pass "set-file source input is bound, persisted, and used for creation"
  else
    printf '%s\n' "$output" >&2
    fail "set-file source input is bound, persisted, and used for creation"
  fi
  if octon_cli "$root" lifecycle run --lifecycle proposal-packet --target set-file-packet --run-id set-file-create --executor mock --execute-routes --approval-policy unattended --max-steps 1 --set source=different >/tmp/octon-v1-run-input-drift.out 2>&1; then
    cat /tmp/octon-v1-run-input-drift.out >&2
    fail "run id cannot change persisted creation inputs"
  else
    pass "run id cannot change persisted creation inputs"
  fi

  write_packet "$root" in-review-packet in-review
  assert_plan_route "in-review without review routes to proposal review" "$root" in-review-packet review-proposal-packet

  write_packet "$root" revision-packet in-review
  write_review "$root" revision-packet revision-required no 1
  assert_plan_route "complete revision-required review routes to revise" "$root" revision-packet revise-proposal-packet

  write_packet "$root" incomplete-revision-packet in-review
  write_incomplete_review "$root" incomplete-revision-packet
  assert_plan_blocked "incomplete revision-required review is blocked" "$root" incomplete-revision-packet

  write_packet "$root" accepted-packet accepted
  write_review "$root" accepted-packet accepted yes 0
  assert_plan_route_with_gate_pass "fresh accepted review routes to implementation prompt with strict gate" "$root" accepted-packet generate-implementation-prompt

  printf '\nChanged after review.\n' >>"$(packet_dir "$root" accepted-packet)/README.md"
  assert_plan_route "stale accepted review routes back to review" "$root" accepted-packet review-proposal-packet

  write_packet "$root" executable-packet accepted
  write_review "$root" executable-packet accepted yes 0
  touch "$(packet_dir "$root" executable-packet)/support/executable-implementation-prompt.md"
  assert_plan_route_with_gate_pass "executable prompt routes to run implementation with strict gate" "$root" executable-packet run-implementation

  write_packet "$root" promote-packet accepted
  write_review "$root" promote-packet accepted yes 0
  touch "$(packet_dir "$root" promote-packet)/support/executable-implementation-prompt.md"
  write_receipt "$root" promote-packet "support/implementation-run.md" \
    "verdict: pass" \
    "implemented_at: 2026-05-07T00:00:00Z" \
    "promotion_evidence_count: 1"
  assert_review_gate_success "strict review remains fresh after implementation-run receipt" "$root" promote-packet
  assert_plan_route_with_gate_pass "implementation-run receipt routes to promote with strict gate" "$root" promote-packet promote-proposal

  write_packet "$root" empty-implementation-field-packet accepted
  write_review "$root" empty-implementation-field-packet accepted yes 0
  touch "$(packet_dir "$root" empty-implementation-field-packet)/support/executable-implementation-prompt.md"
  write_receipt "$root" empty-implementation-field-packet "support/implementation-run.md" \
    "verdict: pass" \
    "implemented_at:" \
    "promotion_evidence_count: 1"
  assert_plan_blocked "empty implementation-run required field blocks promotion" "$root" empty-implementation-field-packet

  write_packet "$root" closeout-packet implemented
  write_receipt "$root" closeout-packet "support/implementation-conformance-review.md" \
    "verdict: pass" \
    "unresolved_items_count: 0"
  write_receipt "$root" closeout-packet "support/post-implementation-drift-churn-review.md" \
    "verdict: pass" \
    "unresolved_items_count: 0"
  assert_plan_route "implemented conformance and drift receipts route to closeout" "$root" closeout-packet closeout-proposal-packet

  write_receipt "$root" closeout-packet "support/proposal-closeout.md" \
    "verdict: pass" \
    "closed_at: 2026-05-07T00:00:00Z" \
    "archive_authorized: yes"
  assert_plan_route "closeout receipt routes to archive" "$root" closeout-packet archive-proposal

  write_packet "$root" empty-closeout-field-packet implemented
  write_receipt "$root" empty-closeout-field-packet "support/implementation-conformance-review.md" \
    "verdict: pass" \
    "unresolved_items_count: 0"
  write_receipt "$root" empty-closeout-field-packet "support/post-implementation-drift-churn-review.md" \
    "verdict: pass" \
    "unresolved_items_count: 0"
  write_receipt "$root" empty-closeout-field-packet "support/proposal-closeout.md" \
    "verdict: pass" \
    "closed_at:" \
    "archive_authorized: yes"
  assert_plan_blocked "empty closeout required field blocks archival" "$root" empty-closeout-field-packet

  write_packet "$root" rejected-packet rejected
  write_review "$root" rejected-packet rejected no 0
  assert_plan_terminal "complete fresh rejected review is terminal" "$root" rejected-packet rejected

  write_packet "$root" archived-packet archived
  assert_plan_terminal "archived packet is terminal no-op" "$root" archived-packet archived

  output="$(octon_cli "$root" lifecycle run --lifecycle proposal-packet --target revision-packet --run-id v1-loop --executor mock --max-iterations 1)"
  if yq -e '.final_verdict == "mock-route-executed"' >/dev/null <<<"$output"; then
    pass "mock revision loop executes once"
  else
    printf '%s\n' "$output" >&2
    fail "mock revision loop executes once"
  fi
  output="$(octon_cli "$root" lifecycle run --lifecycle proposal-packet --target revision-packet --run-id v1-loop --executor mock --max-iterations 1)"
  if yq -e '.final_verdict == "blocked-max-iterations"' >/dev/null <<<"$output"; then
    pass "max review iteration bound blocks repeat route"
  else
    printf '%s\n' "$output" >&2
    fail "max review iteration bound blocks repeat route"
  fi
  output="$(octon_cli "$root" lifecycle resume --run-id v1-loop)"
  if yq -e '.final_verdict == "blocked-max-iterations"' >/dev/null <<<"$output"; then
    pass "resume preserves exhausted loop bound"
  else
    printf '%s\n' "$output" >&2
    fail "resume preserves exhausted loop bound"
  fi

  write_packet "$root" execute-packet draft
  output="$(octon_cli "$root" lifecycle run --lifecycle proposal-packet --target execute-packet --run-id v2-execute --executor mock --execute-routes --approval-policy unattended --max-steps 12)"
	  if yq -e '.terminal_outcome == "archived" and .final_verdict == "completed"' >/dev/null <<<"$output" \
	    && grep -q '^status: archived$' "$(packet_dir "$root" execute-packet)/proposal.yml" \
	    && [[ -f "$(packet_dir "$root" execute-packet)/support/proposal-review.md" ]] \
	    && [[ -f "$(packet_dir "$root" execute-packet)/support/implementation-run.md" ]] \
	    && [[ -f "$(packet_dir "$root" execute-packet)/support/proposal-closeout.md" ]] \
	    && [[ -f "$root/.octon/state/evidence/runs/workflows/v2-execute/run-implementation-approval-override.yml" ]] \
	    && [[ -f "$root/.octon/state/evidence/runs/workflows/v2-execute/promote-proposal-approval-override.yml" ]] \
	    && [[ -f "$root/.octon/state/evidence/runs/workflows/v2-execute/archive-proposal-approval-override.yml" ]]; then
	    pass "execute-routes mock completes proposal lifecycle end to end"
  else
    printf '%s\n' "$output" >&2
    fail "execute-routes mock completes proposal lifecycle end to end"
  fi

  printf 'missing target end-to-end source\n' >"$root/missing-e2e-source.txt"
  output="$(octon_cli "$root" lifecycle run --lifecycle proposal-packet --target created-e2e-packet --run-id v2-create-e2e --executor mock --execute-routes --approval-policy unattended --max-steps 12 --set-file source=missing-e2e-source.txt)"
  if yq -e '.terminal_outcome == "archived" and .final_verdict == "completed"' >/dev/null <<<"$output" \
    && grep -q '^status: archived$' "$(packet_dir "$root" created-e2e-packet)/proposal.yml" \
    && [[ -f "$(packet_dir "$root" created-e2e-packet)/support/proposal-creation.md" ]] \
    && grep -q '^verdict: pass$' "$(packet_dir "$root" created-e2e-packet)/support/proposal-creation.md" \
    && grep -q 'missing target end-to-end source' "$(packet_dir "$root" created-e2e-packet)/resources/source-context.md"; then
    pass "execute-routes mock completes lifecycle from missing target creation"
  else
    printf '%s\n' "$output" >&2
    fail "execute-routes mock completes lifecycle from missing target creation"
  fi

  write_packet "$root" approval-packet draft
  output="$(octon_cli "$root" lifecycle run --lifecycle proposal-packet --target approval-packet --run-id v2-approval --executor mock --execute-routes --approval-policy minimize --max-steps 12)"
  if yq -e '.final_verdict == "approval-required" and .selected_route.route_id == "run-implementation"' >/dev/null <<<"$output" \
    && [[ -f "$root/.octon/state/evidence/runs/workflows/v2-approval/approval-required.yml" ]] \
    && grep -q '^route_execution_mode: adapter-executed$' "$root/.octon/state/evidence/runs/workflows/v2-approval/summary.md" \
    && grep -q '^adapter_route_status: approval-required$' "$root/.octon/state/evidence/runs/workflows/v2-approval/summary.md"; then
    pass "execute-routes pauses before durable implementation by default"
  else
    printf '%s\n' "$output" >&2
    fail "execute-routes pauses before durable implementation by default"
  fi

  write_packet "$root" promote-approval-packet accepted
  write_review "$root" promote-approval-packet accepted yes 0
  touch "$(packet_dir "$root" promote-approval-packet)/support/executable-implementation-prompt.md"
  write_receipt "$root" promote-approval-packet "support/implementation-run.md" \
    "verdict: pass" \
    "implemented_at: 2026-05-07T00:00:00Z" \
    "promotion_evidence_count: 1"
  output="$(octon_cli "$root" lifecycle run --lifecycle proposal-packet --target promote-approval-packet --run-id v2-promote-approval --executor mock --execute-routes --approval-policy minimize --max-steps 3)"
  if yq -e '.final_verdict == "approval-required" and .selected_route.route_id == "promote-proposal"' >/dev/null <<<"$output" \
    && [[ -f "$root/.octon/state/evidence/runs/workflows/v2-promote-approval/approval-required.yml" ]]; then
    pass "execute-routes pauses before durable promote by default"
  else
    printf '%s\n' "$output" >&2
    fail "execute-routes pauses before durable promote by default"
  fi

  printf '\nPassed: %s\nFailed: %s\n' "$pass_count" "$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
