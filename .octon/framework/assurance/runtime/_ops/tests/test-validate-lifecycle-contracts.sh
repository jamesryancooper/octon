#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
VALIDATOR="$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-contracts.sh"
AUTHORITY_ZONE_VALIDATOR="$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-authority-zone-policy.sh"

pass_count=0
fail_count=0

pass() { printf 'PASS: %s\n' "$1"; pass_count=$((pass_count + 1)); }
fail() { printf 'FAIL: %s\n' "$1" >&2; fail_count=$((fail_count + 1)); }

new_fixture_repo() {
  local name="$1" root
  root="${TMPDIR:-/tmp}/octon-lifecycle-contract-${name}-$$-$RANDOM"
  mkdir -p "$root/.octon/inputs/additive/extensions/test-extension/context"
  mkdir -p "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycles"
  mkdir -p "$root/.octon/inputs/additive/extensions/test-extension/commands"
  mkdir -p "$root/.octon/inputs/additive/extensions/test-extension/skills/test-extension-skill"
  mkdir -p "$root/.octon/inputs/additive/extensions/test-extension/prompts/test-route"
  mkdir -p "$root/.octon/inputs/additive/extensions/test-extension/validation"
  mkdir -p "$root/.octon/framework/assurance/runtime/_ops/scripts"
  mkdir -p "$root/.octon/framework/orchestration/runtime/workflows"
  printf '%s\n' "$root"
}

write_fixture_support() {
  local root="$1"
  cat >"$root/.octon/inputs/additive/extensions/test-extension/pack.yml" <<'YAML'
pack_id: test-extension
source_id: bundled
version: "1.0.0"
content_entrypoints:
  context: context
  commands: commands
  skills: skills
  prompts: prompts
YAML
  cat >"$root/.octon/inputs/additive/extensions/test-extension/context/routing.contract.yml" <<'YAML'
dispatchers:
  - dispatcher_id: test-extension
    routes:
      - route_id: test-route
      - route_id: atomic-stage
      - route_id: atomic-commit
      - route_id: atomic-rollback
      - route_id: atomic-compensate
YAML
  cat >"$root/.octon/inputs/additive/extensions/test-extension/commands/manifest.fragment.yml" <<'YAML'
commands:
  - id: test-command
    path: test-command.md
YAML
  touch "$root/.octon/inputs/additive/extensions/test-extension/commands/test-command.md"
  cat >"$root/.octon/inputs/additive/extensions/test-extension/skills/manifest.fragment.yml" <<'YAML'
skills:
  - id: test-extension-skill
    path: test-extension-skill/
YAML
  cat >"$root/.octon/inputs/additive/extensions/test-extension/skills/registry.fragment.yml" <<'YAML'
skills:
  test-extension-skill:
    version: "1.0.0"
YAML
  touch "$root/.octon/inputs/additive/extensions/test-extension/skills/test-extension-skill/SKILL.md"
  cat >"$root/.octon/inputs/additive/extensions/test-extension/prompts/test-route/manifest.yml" <<'YAML'
prompt_set_id: test-extension-test-route
YAML
  cat >"$root/.octon/framework/orchestration/runtime/workflows/manifest.yml" <<'YAML'
workflows:
  - id: test-workflow
YAML
  cat >"$root/.octon/framework/assurance/runtime/_ops/scripts/test-validator.sh" <<'SH'
#!/usr/bin/env bash
exit 0
SH
  chmod +x "$root/.octon/framework/assurance/runtime/_ops/scripts/test-validator.sh"
}

write_valid_contract() {
  local root="$1"
  cat >"$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml" <<'YAML'
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "test-lifecycle"
owner_extension: "test-extension"
version: "1.0.0"
target:
  input: "target"
  manifest_path: "proposal.yml"
  status_field: "status"
  allowed_statuses: ["draft", "archived"]
input_bindings:
  target:
    source: "lifecycle.target"
  proposal_path:
    source: "lifecycle.target"
  source:
    source: "run.input.source"
states:
  - state_id: "review"
terminal_outcomes:
  - outcome_id: "archived"
    when:
      manifest_status: "archived"
validators:
  - validator_id: "test-validator"
    argv: ["bash", ".octon/framework/assurance/runtime/_ops/scripts/test-validator.sh", "--package", "{{target}}"]
gates:
  - gate_id: "test-gate"
    validator_id: "test-validator"
    required_before_routes: ["test-route"]
receipts:
  - receipt_id: "test-review"
    path: "support/proposal-review.md"
    required_fields: ["verdict"]
    verdict_field: "verdict"
loops:
  - loop_id: "test-loop"
    receipt_id: "test-review"
    verdict_field: "verdict"
    repeat_values: ["revision-required"]
    repeat_route_id: "test-route"
    terminal_values: ["accepted", "rejected"]
    max_iterations: 3
routes:
  - route_id: "test-route"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "route-completion-and-target"
      required_evidence_gates: ["test-gate"]
      required_receipts_before_dispatch: []
      required_receipts_before_completion: ["test-review"]
      replay_class: "idempotent-rerun"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override"]
    command_id: "test-command"
    skill_id: "test-extension-skill"
    prompt_set_id: "test-extension-test-route"
    required_inputs: ["source"]
    completion:
      expected_receipts: ["test-review"]
      expected_paths: ["support/proposal-review.md"]
      replan_required: true
    enter_when:
      manifest_status: "draft"
YAML
}

add_valid_phase_loop() {
  local root="$1" contract
  contract="$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  yq -i '
    .schema_version = "octon-extension-lifecycle-contract-v2" |
    .phase_loop = {
      "model_version": "phase-loop-v1",
      "phases": [
        {
          "phase_id": "review-phase",
          "mode": "loop",
          "owner_layer": "test-extension",
          "route_refs": ["test-route"],
          "receipt_refs": ["test-review"],
          "gate_refs": ["test-gate"],
          "validator_refs": ["test-validator"],
          "loop_refs": ["test-loop"],
          "terminal_refs": [],
          "entry_when": {"route_refs_authoritative": true},
          "exit_when": {"receipt_refs_complete": true},
          "exit_evidence_refs": ["test-review"],
          "re_entry_triggers": ["receipt-stale"],
          "backward_transitions": [{"to_phase_id": "review-phase", "when": {"receipt_stale": "test-review"}}],
          "loop_bounds": {"max_phase_iterations": 3, "max_route_dispatches": 3},
          "stop_conditions": [{"stop_class": "blocked-max-iterations", "when": {"loop_bound_exhausted": true}}],
          "authority_boundaries": ["scope-expansion"]
        },
        {
          "phase_id": "terminal-reporting",
          "mode": "terminal",
          "owner_layer": "runner",
          "route_refs": [],
          "receipt_refs": [],
          "gate_refs": [],
          "validator_refs": [],
          "loop_refs": [],
          "terminal_refs": ["archived"],
          "entry_when": {"terminal_or_blocked_verdict": true},
          "exit_when": {"final_report_emitted": true},
          "exit_evidence_refs": [],
          "re_entry_triggers": [],
          "backward_transitions": [],
          "loop_bounds": {"max_phase_iterations": 1, "max_route_dispatches": 0},
          "stop_conditions": [{"stop_class": "terminal", "when": {"terminal_or_blocked_verdict": true}}],
          "authority_boundaries": ["scope-expansion"]
        }
      ]
    }
  ' "$contract"
}

add_fixture_route() {
  local root="$1" route_id="$2" contract routing_contract
  contract="$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  routing_contract="$root/.octon/inputs/additive/extensions/test-extension/context/routing.contract.yml"
  yq -i ".routes += [(.routes[0] | .route_id = \"$route_id\")]" "$contract"
  yq -i ".dispatchers[0].routes += [{\"route_id\": \"$route_id\"}]" "$routing_contract"
}

add_valid_proposal_packet_boundary_fixture() {
  local root="$1" contract
  contract="$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  add_valid_phase_loop "$root"
  add_fixture_route "$root" "closeout-packet"
  yq -i '
    .lifecycle_id = "proposal-packet" |
    .phase_loop.phases[0].phase_id = "closeout-and-hygiene" |
    .phase_loop.phases[0].route_refs = ["closeout-packet"] |
    .phase_loop.phases[0].receipt_refs = ["test-review"] |
    .phase_loop.phases[0].exit_evidence_refs = ["test-review"] |
    .phase_loop.phases[0].backward_transitions = [] |
    .phase_loop.phases[1].phase_id = "terminal-explanation-reporting" |
    .phase_loop.phases[1].backward_transitions = []
  ' "$contract"
}

write_valid_program_contract() {
  local root="$1"
  cat >"$root/.octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml" <<'YAML'
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-program"
owner_extension: "test-extension"
version: "1.0.0"
target:
  input: "program_packet_path"
  manifest_path: "proposal.yml"
  status_field: "status"
  allowed_statuses: ["accepted", "implemented", "archived"]
program:
  child_registry_path: "resources/child-packet-index.yml"
  child_lifecycle_id_default: "test-lifecycle"
  supported_execution_modes:
    - "sequential"
    - "parallel-independent"
    - "gated-parallel"
    - "approval-gated"
  recovery_policy:
    max_recovery_attempts: 2
    serialize_write_scope_conflicts: true
  authority_boundaries:
    parent_coordinates_only: true
    child_receipts_remain_child_owned: true
    child_promotion_targets_remain_child_owned: true
states:
  - state_id: "coordinate"
terminal_outcomes:
  - outcome_id: "archived"
    when:
      manifest_status: "archived"
receipts:
  - receipt_id: "program-summary"
    path: "support/program-summary.md"
routes:
  - route_id: "test-route"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "route-completion-and-target"
      required_evidence_gates: []
      required_receipts_before_dispatch: []
      required_receipts_before_completion: ["program-summary"]
      replay_class: "idempotent-rerun"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override"]
    completion:
      expected_receipts: ["program-summary"]
YAML
}

write_valid_atomic_program_contract() {
  local root="$1"
  cat >"$root/.octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml" <<'YAML'
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-program"
owner_extension: "test-extension"
version: "1.0.0"
target:
  input: "program_packet_path"
  manifest_path: "proposal.yml"
  status_field: "status"
  allowed_statuses: ["accepted", "implemented", "archived"]
program:
  child_registry_path: "resources/child-packet-index.yml"
  child_lifecycle_id_default: "test-lifecycle"
  supported_execution_modes:
    - "sequential"
    - "parallel-independent"
    - "program-atomic"
  atomic_policy:
    eligibility: "explicit-route-opt-in"
    require_declared_write_scopes: true
  recovery_policy:
    max_recovery_attempts: 2
    serialize_write_scope_conflicts: true
    handlers:
      executor-failed:
        max_attempts: 2
        replan_after_attempt: true
  closeout_policy:
    required_child_terminal_outcomes: ["archived", "rejected"]
    require_child_receipts_fresh: true
    require_aggregate_evidence: true
    enforce_authority_boundaries: true
  authority_boundaries:
    parent_coordinates_only: true
    child_receipts_remain_child_owned: true
    child_promotion_targets_remain_child_owned: true
states:
  - state_id: "coordinate"
terminal_outcomes:
  - outcome_id: "archived"
    when:
      manifest_status: "archived"
receipts:
  - receipt_id: "program-summary"
    path: "support/program-summary.md"
routes:
  - route_id: "test-route"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "route-completion-and-target"
      required_evidence_gates: []
      required_receipts_before_dispatch: []
      required_receipts_before_completion: ["program-summary"]
      replay_class: "idempotent-rerun"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override"]
    atomic:
      stage_route_id: "atomic-stage"
      commit_route_id: "atomic-commit"
      rollback_route_id: "atomic-rollback"
      compensation_route_id: "atomic-compensate"
    completion:
      expected_receipts: ["program-summary"]
  - route_id: "atomic-stage"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "program-mutation-envelope"
      required_evidence_gates: []
      required_receipts_before_dispatch: []
      required_receipts_before_completion: []
      replay_class: "idempotent"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override"]
  - route_id: "atomic-commit"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "program-mutation-envelope"
      required_evidence_gates: []
      required_receipts_before_dispatch: []
      required_receipts_before_completion: []
      replay_class: "idempotent"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override"]
  - route_id: "atomic-rollback"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "program-mutation-envelope"
      required_evidence_gates: []
      required_receipts_before_dispatch: []
      required_receipts_before_completion: []
      replay_class: "idempotent"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override"]
  - route_id: "atomic-compensate"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "program-mutation-envelope"
      required_evidence_gates: []
      required_receipts_before_dispatch: []
      required_receipts_before_completion: []
      replay_class: "idempotent"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override"]
YAML
}

assert_success_contract() {
  local label="$1" root="$2" contract_path="$3"
  if OCTON_ROOT_DIR="$root" bash "$VALIDATOR" --contract "$contract_path" >/tmp/octon-lifecycle-contract.out 2>&1; then
    pass "$label"
  else
    cat /tmp/octon-lifecycle-contract.out >&2
    fail "$label"
  fi
}

assert_failure_contract() {
  local label="$1" root="$2" contract_path="$3"
  if OCTON_ROOT_DIR="$root" bash "$VALIDATOR" --contract "$contract_path" >/tmp/octon-lifecycle-contract.out 2>&1; then
    cat /tmp/octon-lifecycle-contract.out >&2
    fail "$label"
  else
    pass "$label"
  fi
}

assert_success() {
  local label="$1" root="$2"
  assert_success_contract "$label" "$root" ".octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
}

assert_failure() {
  local label="$1" root="$2"
  assert_failure_contract "$label" "$root" ".octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
}

assert_authority_zone_policy_success() {
  local label="$1" root="$2" policy_path="$3"
  if OCTON_ROOT_DIR="$root" bash "$AUTHORITY_ZONE_VALIDATOR" "$policy_path" >/tmp/octon-authority-zone-policy.out 2>&1; then
    pass "$label"
  else
    cat /tmp/octon-authority-zone-policy.out >&2
    fail "$label"
  fi
}

assert_authority_zone_policy_failure() {
  local label="$1" root="$2" policy_path="$3"
  if OCTON_ROOT_DIR="$root" bash "$AUTHORITY_ZONE_VALIDATOR" "$policy_path" >/tmp/octon-authority-zone-policy.out 2>&1; then
    cat /tmp/octon-authority-zone-policy.out >&2
    fail "$label"
  else
    pass "$label"
  fi
}

assert_schema_contains() {
  local label="$1" path="$2" expected="$3"
  if grep -F "$expected" "$path" >/dev/null 2>&1; then
    pass "$label"
  else
    fail "$label"
  fi
}

assert_schema_query_equals() {
  local label="$1" path="$2" query="$3" expected="$4" actual
  actual="$(yq -r "$query // \"\"" "$path" 2>/dev/null | awk 'NF' || true)"
  if [[ "$actual" == "$expected" ]]; then
    pass "$label"
  else
    fail "$label: expected '$expected' got '$actual'"
  fi
}

main() {
  local root
  root="$(new_fixture_repo valid)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  assert_success "valid lifecycle contract passes" "$root"

  root="$(new_fixture_repo valid-explicit-route-progression)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  yq -i '.execution_strategy = "route-progression"' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_success "valid explicit route-progression lifecycle contract passes" "$root"

  root="$(new_fixture_repo valid-v2-phase-loop)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  add_valid_phase_loop "$root"
  assert_success "valid v2 phase-loop lifecycle contract passes" "$root"

  root="$(new_fixture_repo valid-proposal-packet-boundary)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  add_valid_proposal_packet_boundary_fixture "$root"
  assert_success "valid proposal-packet boundary contract passes" "$root"

  root="$(new_fixture_repo invalid-proposal-target-lifecycle-outcome)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  add_valid_proposal_packet_boundary_fixture "$root"
  yq -i '.target_lifecycle_outcome = "cleaned"' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "proposal-packet target_lifecycle_outcome fails" "$root"

  root="$(new_fixture_repo invalid-proposal-stateful-closeout)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  add_valid_proposal_packet_boundary_fixture "$root"
  yq -i '.stateful_closeout = {}' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "proposal-packet stateful_closeout fails" "$root"

  root="$(new_fixture_repo invalid-proposal-hosted-landing-authorization)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  add_valid_proposal_packet_boundary_fixture "$root"
  yq -i '.landing_authorization_ref = "evidence://landing"' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "proposal-packet hosted landing authorization fails" "$root"

  root="$(new_fixture_repo invalid-proposal-branch-cleanup-authorization)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  add_valid_proposal_packet_boundary_fixture "$root"
  yq -i '.policy_refs.branch_cleanup_authorization_schema_ref = ".octon/framework/product/contracts/branch-cleanup-authorization-v1.schema.json"' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "proposal-packet branch cleanup authorization fails" "$root"

  root="$(new_fixture_repo invalid-proposal-cleanup-authority-route)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  add_valid_proposal_packet_boundary_fixture "$root"
  add_fixture_route "$root" "repo-hygiene-cleanup"
  assert_failure "proposal-packet cleanup authority route fails" "$root"

  root="$(new_fixture_repo invalid-proposal-closeout-route-ref)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  add_valid_proposal_packet_boundary_fixture "$root"
  add_fixture_route "$root" "closeout-change"
  yq -i '(.phase_loop.phases[] | select(.phase_id == "closeout-and-hygiene") | .route_refs) = ["closeout-change"]' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "proposal-packet closeout-and-hygiene route drift fails" "$root"

  root="$(new_fixture_repo invalid-v2-missing-phase-loop)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  yq -i '.schema_version = "octon-extension-lifecycle-contract-v2"' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "v2 lifecycle without phase_loop fails" "$root"

  root="$(new_fixture_repo invalid-phase-route-ref)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  add_valid_phase_loop "$root"
  yq -i '.phase_loop.phases[0].route_refs = ["missing-route"]' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "missing phase route ref fails" "$root"

  root="$(new_fixture_repo invalid-phase-receipt-ref)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  add_valid_phase_loop "$root"
  yq -i '.phase_loop.phases[0].receipt_refs = ["missing-review"]' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "missing phase receipt ref fails" "$root"

  root="$(new_fixture_repo invalid-phase-transition-ref)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  add_valid_phase_loop "$root"
  yq -i '.phase_loop.phases[0].backward_transitions[0].to_phase_id = "missing-phase"' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "missing phase backward transition target fails" "$root"

  root="$(new_fixture_repo invalid-terminal-phase-route)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  add_valid_phase_loop "$root"
  yq -i '.phase_loop.phases[1].route_refs = ["test-route"]' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "terminal phase route dispatch fails" "$root"

  root="$(new_fixture_repo invalid-phase-status-name)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  add_valid_phase_loop "$root"
  yq -i '.phase_loop.phases[0].phase_id = "draft"' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "phase id duplicating manifest status fails" "$root"

  root="$(new_fixture_repo valid-program-contract)"
  write_fixture_support "$root"
  write_valid_program_contract "$root"
  assert_success_contract "valid program lifecycle contract passes from lifecycles directory" "$root" ".octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"

  root="$(new_fixture_repo valid-explicit-orchestrated-program-contract)"
  write_fixture_support "$root"
  write_valid_program_contract "$root"
  yq -i '.execution_strategy = "orchestrated-replan-loop"' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"
  assert_success_contract "valid explicit orchestrated program lifecycle contract passes" "$root" ".octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"

  root="$(new_fixture_repo valid-program-atomic-contract)"
  write_fixture_support "$root"
  write_valid_atomic_program_contract "$root"
  assert_success_contract "valid program-atomic lifecycle contract passes with explicit atomic policy" "$root" ".octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"

  root="$(new_fixture_repo invalid-execution-strategy)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  yq -i '.execution_strategy = "linear"' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "invalid lifecycle execution strategy fails" "$root"

  root="$(new_fixture_repo invalid-program-route-progression)"
  write_fixture_support "$root"
  write_valid_program_contract "$root"
  yq -i '.execution_strategy = "route-progression"' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"
  assert_failure_contract "program lifecycle with route-progression fails" "$root" ".octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"

  root="$(new_fixture_repo invalid-orchestrated-without-program)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  yq -i '.execution_strategy = "orchestrated-replan-loop"' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "orchestrated lifecycle without program section fails" "$root"

  root="$(new_fixture_repo invalid-program-atomic-supported)"
  write_fixture_support "$root"
  write_valid_program_contract "$root"
  yq -i '.program.supported_execution_modes += ["program-atomic"]' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"
  assert_failure_contract "program-atomic without explicit atomic policy fails" "$root" ".octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"

  root="$(new_fixture_repo invalid-atomic-route-reference)"
  write_fixture_support "$root"
  write_valid_atomic_program_contract "$root"
  yq -i '.routes[0].atomic.stage_route_id = "missing-stage"' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"
  assert_failure_contract "missing atomic route reference fails" "$root" ".octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"

  root="$(new_fixture_repo invalid-atomic-self-reference)"
  write_fixture_support "$root"
  write_valid_atomic_program_contract "$root"
  yq -i '.routes[0].atomic.stage_route_id = "test-route"' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"
  assert_failure_contract "atomic self-reference fails" "$root" ".octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"

  root="$(new_fixture_repo invalid-program-registry-path)"
  write_fixture_support "$root"
  write_valid_program_contract "$root"
  yq -i '.program.child_registry_path = "../child-packet-index.yml"' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"
  assert_failure_contract "invalid program child registry path fails" "$root" ".octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"

  root="$(new_fixture_repo invalid-program-authority-boundary)"
  write_fixture_support "$root"
  write_valid_program_contract "$root"
  yq -i '.program.authority_boundaries.child_receipts_remain_child_owned = false' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"
  assert_failure_contract "program authority boundary false fails" "$root" ".octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"

  root="$(new_fixture_repo invalid-schema)"
  write_fixture_support "$root"
  write_valid_contract "$root"
    yq -i '.schema_version = "wrong"' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
    assert_failure "invalid schema version fails" "$root"

    root="$(new_fixture_repo duplicate-state-id)"
    write_fixture_support "$root"
    write_valid_contract "$root"
    yq -i '.states += [{"state_id": "review"}]' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
    assert_failure "duplicate state id fails" "$root"

    root="$(new_fixture_repo duplicate-route-id)"
    write_fixture_support "$root"
    write_valid_contract "$root"
    yq -i '.routes += [.routes[0]]' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
    assert_failure "duplicate route id fails" "$root"

    root="$(new_fixture_repo duplicate-receipt-id)"
    write_fixture_support "$root"
    write_valid_contract "$root"
    yq -i '.receipts += [.receipts[0]]' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
    assert_failure "duplicate receipt id fails" "$root"

    root="$(new_fixture_repo duplicate-validator-id)"
    write_fixture_support "$root"
    write_valid_contract "$root"
    yq -i '.validators += [.validators[0]]' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
    assert_failure "duplicate validator id fails" "$root"

    root="$(new_fixture_repo invalid-route)"
    write_fixture_support "$root"
    write_valid_contract "$root"
    yq -i '.routes[0].route_id = "missing-route"' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "missing route reference fails" "$root"

  root="$(new_fixture_repo invalid-validator)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  yq -i '.validators[0].argv = ["bash", "/tmp/not-allowed.sh"]' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "absolute validator path fails" "$root"

  root="$(new_fixture_repo invalid-target-manifest-path)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  yq -i '.target.manifest_path = "../proposal.yml"' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "invalid target manifest path fails" "$root"

  root="$(new_fixture_repo invalid-receipt-path)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  yq -i '.receipts[0].path = "/tmp/proposal-review.md"' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "invalid receipt path fails" "$root"

  root="$(new_fixture_repo invalid-on-fail-route)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  yq -i '.gates[0].on_fail_route_id = "missing-route"' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "missing gate fallback route fails" "$root"

  root="$(new_fixture_repo invalid-receipt-verdict)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  yq -i '.routes[0].enter_when = {"receipt_verdict": {"receipt_id": "missing-review", "value": "accepted"}}' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "missing receipt_verdict receipt fails" "$root"

  root="$(new_fixture_repo invalid-receipt-absent)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  yq -i '.routes[0].enter_when = {"receipt_absent": "missing-review"}' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "missing receipt_absent receipt fails" "$root"

  root="$(new_fixture_repo invalid-receipt-stale)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  yq -i '.routes[0].enter_when = {"receipt_stale": "missing-review"}' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "missing receipt_stale receipt fails" "$root"

  root="$(new_fixture_repo invalid-receipt-fresh)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  yq -i '.routes[0].enter_when = {"receipt_fresh": "missing-review"}' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "missing receipt_fresh receipt fails" "$root"

  root="$(new_fixture_repo invalid-receipt-complete)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  yq -i '.routes[0].enter_when = {"receipt_complete": "missing-review"}' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "missing receipt_complete receipt fails" "$root"

  root="$(new_fixture_repo invalid-receipt-field-equals)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  yq -i '.routes[0].enter_when = {"receipt_field_equals": {"receipt_id": "missing-review", "field": "verdict", "value": "pass"}}' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "missing receipt_field_equals receipt fails" "$root"

  root="$(new_fixture_repo invalid-completion-receipt)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  yq -i '.routes[0].completion.expected_receipts = ["missing-review"]' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "missing completion expected receipt fails" "$root"

  root="$(new_fixture_repo invalid-completion-path)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  yq -i '.routes[0].completion.expected_paths = ["../escape"]' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "invalid completion expected path fails" "$root"

  root="$(new_fixture_repo invalid-file-condition-path)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  yq -i '.routes[0].enter_when = {"file_present": "../escape"}' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "invalid file_present condition path fails" "$root"

  root="$(new_fixture_repo valid-context-condition-predicates)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  yq -i '.routes[0].enter_when = {"all": [{"blocker_present": "lifecycle-residue-cleanup-needed"}, {"cleanup_candidates_present": true}, {"hygiene_preflight_required": false}]}' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_success "valid context condition predicates pass" "$root"

  root="$(new_fixture_repo invalid-context-condition-bool)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  yq -i '.routes[0].enter_when = {"cleanup_candidates_present": "yes"}' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "invalid cleanup_candidates_present condition type fails" "$root"

  root="$(new_fixture_repo invalid-context-condition-blocker)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  yq -i '.routes[0].enter_when = {"blocker_present": "not-a-blocker"}' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "invalid blocker_present condition class fails" "$root"

  root="$(new_fixture_repo invalid-unsupported-condition-key)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  yq -i '.routes[0].enter_when = {"magic_condition": true}' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "unsupported condition key fails" "$root"

  root="$(new_fixture_repo invalid-phase-only-route-condition)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  yq -i '.routes[0].enter_when = {"route_refs_authoritative": true}' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "phase-only route condition key fails" "$root"

  root="$(new_fixture_repo invalid-completion-status)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  yq -i '.routes[0].completion.expected_manifest_status = "implemented"' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "invalid completion expected manifest status fails" "$root"

  root="$(new_fixture_repo invalid-freshness-digest-command)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  yq -i '.receipts[0].freshness = {"digest_command": ["bash", "/tmp/not-allowed.sh"], "digest_field": "reviewed_packet_digest"}' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "invalid freshness digest command path fails" "$root"

  root="$(new_fixture_repo missing-delegation-contract)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  yq -i 'del(.routes[0].delegation_contract)' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "route without delegation contract fails" "$root"

  root="$(new_fixture_repo legacy-route-approval)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  yq -i '.routes[0].approval.required_by_default = true' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "legacy route approval primitive fails" "$root"

  root="$(new_fixture_repo invalid-input-binding-source)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  yq -i '.input_bindings.proposal_path.source = "runtime.shell"' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "invalid lifecycle input binding source fails" "$root"

  root="$(new_fixture_repo missing-required-input-binding)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  yq -i 'del(.input_bindings.source)' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "missing required input binding fails" "$root"

  root="$(new_fixture_repo invalid-required-input-reference)"
  write_fixture_support "$root"
  write_valid_contract "$root"
    yq -i '.routes[0].required_inputs = ["missing-source"]' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
    assert_failure "invalid route required input reference fails" "$root"

    root="$(new_fixture_repo invalid-recovery-handler-blocker)"
    write_fixture_support "$root"
    write_valid_atomic_program_contract "$root"
    yq -i '.program.recovery_policy.handlers."not-a-blocker" = {"max_attempts": 1}' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"
    assert_failure_contract "invalid recovery handler blocker class fails" "$root" ".octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"

    root="$(new_fixture_repo invalid-recovery-handler-attempts)"
    write_fixture_support "$root"
    write_valid_atomic_program_contract "$root"
    yq -i '.program.recovery_policy.handlers."executor-failed".max_attempts = 11' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"
    assert_failure_contract "invalid recovery handler retry budget fails" "$root" ".octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"

    root="$(new_fixture_repo invalid-recovery-handler-approval)"
    write_fixture_support "$root"
    write_valid_atomic_program_contract "$root"
    yq -i '.program.recovery_policy.handlers."executor-failed".human_required = "yes"' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"
    assert_failure_contract "invalid recovery handler approval flag fails" "$root" ".octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"

    root="$(new_fixture_repo invalid-recovery-recipe-missing-field)"
    write_fixture_support "$root"
    write_valid_atomic_program_contract "$root"
    yq -i '.program.recovery_policy.recipes = [{"blocker_class": "stale-receipt", "human_required": false, "retry_budget": 1, "dependent_handling": "continue-independent", "post_attempt_validation": ["replan-live-state"], "replan_behavior": "after-attempt"}]' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"
    assert_failure_contract "recovery recipe missing required field fails" "$root" ".octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"

    root="$(new_fixture_repo invalid-recovery-recipe-idempotency)"
    write_fixture_support "$root"
    write_valid_atomic_program_contract "$root"
    yq -i '.program.recovery_policy.recipes = [{"blocker_class": "stale-receipt", "idempotency_class": "magic", "human_required": false, "retry_budget": 1, "dependent_handling": "continue-independent", "post_attempt_validation": ["replan-live-state"], "replan_behavior": "after-attempt"}]' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"
    assert_failure_contract "invalid recovery recipe idempotency fails" "$root" ".octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"

    root="$(new_fixture_repo invalid-recovery-recipe-post-validation)"
    write_fixture_support "$root"
    write_valid_atomic_program_contract "$root"
    yq -i '.program.recovery_policy.recipes = [{"blocker_class": "stale-receipt", "idempotency_class": "idempotent-rerun", "human_required": false, "retry_budget": 1, "dependent_handling": "continue-independent", "post_attempt_validation": ["trust-me"], "replan_behavior": "after-attempt"}]' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"
    assert_failure_contract "invalid recovery recipe post-attempt validation fails" "$root" ".octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"

    root="$(new_fixture_repo invalid-recovery-recipe-replan)"
    write_fixture_support "$root"
    write_valid_atomic_program_contract "$root"
    yq -i '.program.recovery_policy.recipes = [{"blocker_class": "stale-receipt", "idempotency_class": "idempotent-rerun", "human_required": false, "retry_budget": 1, "dependent_handling": "continue-independent", "post_attempt_validation": ["replan-live-state"], "replan_behavior": "eventually"}]' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"
    assert_failure_contract "invalid recovery recipe replan behavior fails" "$root" ".octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"

    root="$(new_fixture_repo invalid-recovery-recipe-route)"
    write_fixture_support "$root"
    write_valid_atomic_program_contract "$root"
    yq -i '.program.recovery_policy.recipes = [{"blocker_class": "validation-failed", "recovery_route_id": "missing-route", "idempotency_class": "approval-gated-mutation", "human_required": false, "retry_budget": 1, "dependent_handling": "continue-independent", "post_attempt_validation": ["replan-live-state"], "replan_behavior": "after-attempt"}]' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"
    assert_failure_contract "missing recovery recipe route fails" "$root" ".octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"

    root="$(new_fixture_repo invalid-recovery-recipe-no-dispatch)"
    write_fixture_support "$root"
    write_valid_atomic_program_contract "$root"
    yq -i '.program.recovery_policy.recipes = [{"blocker_class": "validation-failed", "idempotency_class": "approval-gated-mutation", "human_required": false, "retry_budget": 1, "dependent_handling": "continue-independent", "post_attempt_validation": ["replan-live-state"], "replan_behavior": "after-attempt"}]' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"
    assert_failure_contract "recoverable recovery recipe without route action or wait fails" "$root" ".octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"

    root="$(new_fixture_repo invalid-recovery-recipe-action)"
    write_fixture_support "$root"
    write_valid_atomic_program_contract "$root"
    yq -i '.program.recovery_policy.recipes = [{"blocker_class": "publication-drift", "recovery_action_id": "magic-action", "idempotency_class": "idempotent-rerun", "human_required": false, "retry_budget": 1, "dependent_handling": "pause-dependent", "post_attempt_validation": ["replan-live-state"], "replan_behavior": "after-attempt"}]' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"
    assert_failure_contract "unsupported recovery recipe action fails" "$root" ".octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"

    root="$(new_fixture_repo invalid-non-recoverable-recipe-route)"
    write_fixture_support "$root"
    write_valid_atomic_program_contract "$root"
    yq -i '.program.recovery_policy.recipes = [{"blocker_class": "unsafe-resume", "recovery_route_id": "test-route", "idempotency_class": "non-recoverable", "human_required": true, "retry_budget": 0, "dependent_handling": "fail-closed", "post_attempt_validation": ["replay-verify"], "replan_behavior": "none"}]' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"
    assert_failure_contract "non-recoverable recovery route fails" "$root" ".octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"

    root="$(new_fixture_repo invalid-recovery-recipe-zone)"
    write_fixture_support "$root"
    write_valid_atomic_program_contract "$root"
    yq -i '.program.recovery_policy.recipes = [{"blocker_class": "publication-drift", "recovery_action_id": "refresh-publication-projections", "idempotency_class": "idempotent-rerun", "human_required": false, "retry_budget": 1, "dependent_handling": "pause-dependent", "post_attempt_validation": ["replan-live-state"], "replan_behavior": "after-attempt", "allowed_authority_zones": ["octon-authored-governance"], "allowed_artifact_classes": ["authored-governance"], "operation_class": "refresh-generated-projection"}]' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"
    assert_failure_contract "approval-free durable authority zone recovery fails" "$root" ".octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"

    root="$(new_fixture_repo invalid-recovery-recipe-operation)"
    write_fixture_support "$root"
    write_valid_atomic_program_contract "$root"
    yq -i '.program.recovery_policy.recipes = [{"blocker_class": "publication-drift", "recovery_action_id": "refresh-publication-projections", "idempotency_class": "idempotent-rerun", "human_required": false, "retry_budget": 1, "dependent_handling": "pause-dependent", "post_attempt_validation": ["replan-live-state"], "replan_behavior": "after-attempt", "allowed_authority_zones": ["octon-generated-derived"], "allowed_artifact_classes": ["generated-derived"], "operation_class": "magic-operation"}]' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"
    assert_failure_contract "unsupported authority operation recovery fails" "$root" ".octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"

    assert_authority_zone_policy_success "source authority-zone policy passes" "$REPO_ROOT" ".octon/framework/constitution/contracts/authority/authority-zone-policy.yml"

    root="$(new_fixture_repo invalid-authority-zone-policy)"
    mkdir -p "$root/.octon/framework/constitution/contracts/authority"
    cp "$REPO_ROOT/.octon/framework/constitution/contracts/authority/authority-zone-policy.yml" "$root/.octon/framework/constitution/contracts/authority/authority-zone-policy.yml"
    yq -i '(.zones[] | select(.zone_id == "octon-authored-governance").approval_posture) = "pre-granted"' "$root/.octon/framework/constitution/contracts/authority/authority-zone-policy.yml"
    assert_authority_zone_policy_failure "authored governance pregrant policy fails" "$root" ".octon/framework/constitution/contracts/authority/authority-zone-policy.yml"

    registry_schema="$REPO_ROOT/.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/proposal-program-child-registry.schema.json"
    mutation_schema="$REPO_ROOT/.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/proposal-program-mutation.schema.json"
    scaffold_schema="$REPO_ROOT/.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/proposal-program-scaffold.schema.json"
    event_schema="$REPO_ROOT/.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/program-lifecycle-event.schema.json"
    packet_event_schema="$REPO_ROOT/.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/lifecycle-run-event.schema.json"
    cancellation_schema="$REPO_ROOT/.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/lifecycle-cancellation.schema.json"
    approval_guidance_schema="$REPO_ROOT/.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/lifecycle-human-exception-grant.schema.json"
    lifecycle_schema="$REPO_ROOT/.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/extension-lifecycle-contract.schema.json"
    route_request_schema="$REPO_ROOT/.octon/framework/engine/runtime/spec/lifecycle-route-execution-request-v1.schema.json"
    route_result_schema="$REPO_ROOT/.octon/framework/engine/runtime/spec/lifecycle-route-execution-result-v1.schema.json"

    assert_schema_query_equals "registry identifier definition matches runtime" "$registry_schema" '."$defs".identifier.pattern' '^[a-z][a-z0-9]*(-[a-z0-9]+)*$'
    for query in \
      '."$defs".child.properties.child_id."$ref"' \
      '."$defs".child.properties.dependencies.items."$ref"' \
      '."$defs".child.properties.phase_id."$ref"' \
      '."$defs".child.properties.group_id."$ref"' \
      '."$defs".child.properties.replacement_child_id."$ref"' \
      '."$defs".child.properties.replacement_for."$ref"' \
      '."$defs".child.properties.recovery_profile."$ref"' \
      '."$defs".child.properties.phase_commit_barrier."$ref"'; do
      assert_schema_query_equals "registry identifier field uses canonical identifier: $query" "$registry_schema" "$query" '#/$defs/identifier'
    done
    assert_schema_query_equals "registry rollback posture enum matches runtime" "$registry_schema" '."$defs".child.properties.rollback_posture.enum[] | select(. == "rollback-route")' 'rollback-route'
    assert_schema_query_equals "registry seed role enum matches runtime" "$registry_schema" '."$defs".child.properties.seed_role.enum[] | select(. == "seed-reference")' 'seed-reference'
    assert_schema_query_equals "registry required metadata supports change_profile" "$registry_schema" '."$defs".child.properties.required_metadata.items.enum[] | select(. == "change_profile")' 'change_profile'
    assert_schema_query_equals "registry readiness requirement id uses canonical identifier" "$registry_schema" '."$defs".readiness_requirement.properties.requirement_id."$ref"' '#/$defs/identifier'
    assert_schema_query_equals "registry predecessor constraint uses canonical identifier" "$registry_schema" '."$defs".predecessor_constraint.properties.predecessor_child_id."$ref"' '#/$defs/identifier'
    assert_schema_query_equals "registry successor constraint uses canonical identifier" "$registry_schema" '."$defs".successor_constraint.properties.successor_child_id."$ref"' '#/$defs/identifier'
    assert_schema_query_equals "registry cutover predecessor ids use canonical identifier" "$registry_schema" '."$defs".cutover_constraints.properties.required_predecessor_child_ids.items."$ref"' '#/$defs/identifier'
    assert_schema_query_equals "registry cutover forbidden claims include compatibility retirement" "$registry_schema" '."$defs".cutover_constraints.properties.forbidden_claims_until_ready.items.enum[] | select(. == "compatibility-retired")' 'compatibility-retired'

    assert_schema_query_equals "mutation identifier definition matches runtime" "$mutation_schema" '."$defs".identifier.pattern' '^[a-z][a-z0-9]*(-[a-z0-9]+)*$'
    for query in \
      '.properties.child_id."$ref"' \
      '.properties.replacement_child_id."$ref"' \
      '.properties.dependencies.items."$ref"' \
      '.properties.phase_id."$ref"' \
      '.properties.group_id."$ref"' \
      '.properties.recovery_profile."$ref"'; do
      assert_schema_query_equals "mutation identifier field uses canonical identifier: $query" "$mutation_schema" "$query" '#/$defs/identifier'
    done
    assert_schema_query_equals "mutation rollback posture enum matches runtime" "$mutation_schema" '.properties.rollback_posture.enum[] | select(. == "rollback-route")' 'rollback-route'

    assert_schema_query_equals "scaffold identifier definition matches runtime" "$scaffold_schema" '."$defs".identifier.pattern' '^[a-z][a-z0-9]*(-[a-z0-9]+)*$'
    assert_schema_query_equals "scaffold program id uses canonical identifier" "$scaffold_schema" '.properties.program_id."$ref"' '#/$defs/identifier'
    for query in \
      '."$defs".scaffold_child.properties.child_id."$ref"' \
      '."$defs".scaffold_child.properties.dependencies.items."$ref"' \
      '."$defs".scaffold_child.properties.phase_id."$ref"' \
      '."$defs".scaffold_child.properties.group_id."$ref"'; do
      assert_schema_query_equals "scaffold identifier field uses canonical identifier: $query" "$scaffold_schema" "$query" '#/$defs/identifier'
    done
    assert_schema_query_equals "scaffold rollback posture enum matches runtime" "$scaffold_schema" '."$defs".scaffold_child.properties.rollback_posture.enum[] | select(. == "rollback-route")' 'rollback-route'
    assert_schema_query_equals "scaffold seed role enum matches runtime" "$scaffold_schema" '."$defs".scaffold_child.properties.seed_role.enum[] | select(. == "seed-reference")' 'seed-reference'

    assert_schema_query_equals "event identifier definition matches runtime" "$event_schema" '."$defs".identifier.pattern' '^[a-z][a-z0-9]*(-[a-z0-9]+)*$'
    assert_schema_query_equals "event child id uses canonical identifier" "$event_schema" '.properties.child_id."$ref"' '#/$defs/identifier'
    assert_schema_query_equals "event route id uses canonical identifier pattern" "$event_schema" '.properties.route_id.pattern' '^[a-z][a-z0-9]*(-[a-z0-9]+)*$'
    assert_schema_query_equals "packet lifecycle event schema version declared" "$packet_event_schema" '.properties.schema_version.const' 'octon-lifecycle-run-event-v1'
    assert_schema_query_equals "packet lifecycle event supports cancellation events" "$packet_event_schema" '.properties.final_verdict.enum[] | select(. == "cancelled")' 'cancelled'
    assert_schema_query_equals "packet lifecycle event step kind includes route dispatch" "$packet_event_schema" '.properties.step_kind.enum[] | select(. == "route-dispatch")' 'route-dispatch'
    assert_schema_query_equals "packet lifecycle event supports phase category" "$packet_event_schema" '.properties.event_category.enum[] | select(. == "phase")' 'phase'
    assert_schema_query_equals "packet lifecycle event phase id uses lifecycle id pattern" "$packet_event_schema" '.properties.phase_id.pattern' '^[a-z][a-z0-9]*(-[a-z0-9]+)*$'
    assert_schema_query_equals "packet lifecycle event transition id links event and phase" "$packet_event_schema" '.properties.transition_id.pattern' '^[a-z][a-z0-9]*(-[a-z0-9]+)*:[a-z][a-z0-9]*(-[a-z0-9]+)*$'
    assert_schema_query_equals "lifecycle cancellation schema accepts shared cancellation marker" "$cancellation_schema" '.properties.schema_version.enum[] | select(. == "octon-lifecycle-cancellation-v1")' 'octon-lifecycle-cancellation-v1'
    assert_schema_query_equals "lifecycle cancellation schema accepts program cancellation evidence" "$cancellation_schema" '.properties.schema_version.enum[] | select(. == "octon-program-lifecycle-cancelled-v1")' 'octon-program-lifecycle-cancelled-v1'
    assert_schema_query_equals "human exception schema routes program child grants" "$approval_guidance_schema" '.properties.context_kind.enum[] | select(. == "program-child-route")' 'program-child-route'
    assert_schema_query_equals "human exception schema requires typed boundary" "$approval_guidance_schema" '.properties.human_only_boundary.enum[] | select(. == "scope-expansion")' 'scope-expansion'

    assert_schema_query_equals "lifecycle execution strategy accepts route-progression" "$lifecycle_schema" '.properties.execution_strategy.enum[] | select(. == "route-progression")' 'route-progression'
    assert_schema_query_equals "lifecycle contract schema accepts v2" "$lifecycle_schema" '.properties.schema_version.enum[] | select(. == "octon-extension-lifecycle-contract-v2")' 'octon-extension-lifecycle-contract-v2'
    assert_schema_query_equals "lifecycle contract schema declares phase_loop" "$lifecycle_schema" '.properties.phase_loop."$ref"' '#/$defs/phaseLoop'
    assert_schema_query_equals "phase loop model version declared" "$lifecycle_schema" '."$defs".phaseLoop.properties.model_version.const' 'phase-loop-v1'
    assert_schema_query_equals "phase loop terminal mode declared" "$lifecycle_schema" '."$defs".phase.properties.mode.enum[] | select(. == "terminal")' 'terminal'
    assert_schema_query_equals "lifecycle execution strategy accepts orchestrated-replan-loop" "$lifecycle_schema" '.properties.execution_strategy.enum[] | select(. == "orchestrated-replan-loop")' 'orchestrated-replan-loop'
    assert_schema_query_equals "lifecycle recovery idempotency accepts non-recoverable" "$lifecycle_schema" '."$defs".programRecoveryRecipe.properties.idempotency_class.enum[] | select(. == "non-recoverable")' 'non-recoverable'
    assert_schema_query_equals "lifecycle recovery replan behavior supports after-attempt" "$lifecycle_schema" '."$defs".programRecoveryRecipe.properties.replan_behavior.enum[] | select(. == "after-attempt")' 'after-attempt'
    assert_schema_query_equals "lifecycle recovery supports authority zone metadata" "$lifecycle_schema" '."$defs".programRecoveryRecipe.properties.allowed_authority_zones.items."$ref"' '#/$defs/authorityZone'
    assert_schema_query_equals "lifecycle recovery supports authority operation metadata" "$lifecycle_schema" '."$defs".programRecoveryRecipe.properties.operation_class."$ref"' '#/$defs/authorityOperationClass'
    assert_schema_query_equals "lifecycle recovery policy accepts blocker taxonomy" "$lifecycle_schema" '."$defs".programRecoveryPolicy.properties.blocker_taxonomy."$ref"' '#/$defs/programBlockerTaxonomy'
    assert_schema_query_equals "lifecycle blocker taxonomy declares hard-blocker class" "$lifecycle_schema" '."$defs".programBlockerTaxonomyClass.properties.class_id.enum[] | select(. == "hard-blocker")' 'hard-blocker'
    assert_schema_query_equals "lifecycle blocker taxonomy hard guard is const true" "$lifecycle_schema" '."$defs".programBlockerTaxonomyAuthorityGuards.properties.hard_blockers_fail_closed.const | tostring' 'true'
    assert_schema_query_equals "lifecycle blocker taxonomy parent summary guard is const false" "$lifecycle_schema" '."$defs".programBlockerTaxonomyAuthorityGuards.properties.parent_summary_satisfies_child_receipt.const | tostring' 'false'
    assert_schema_query_equals "lifecycle recovery preconditions support authority-zone-allowed" "$lifecycle_schema" '."$defs".programRecoveryRecipe.properties.preconditions.items.enum[] | select(. == "authority-zone-allowed")' 'authority-zone-allowed'
    assert_schema_query_equals "lifecycle recovery preconditions support hygiene receipt stale after live pass" "$lifecycle_schema" '."$defs".programRecoveryRecipe.properties.preconditions.items.enum[] | select(. == "hygiene-receipt-stale-after-live-pass")' 'hygiene-receipt-stale-after-live-pass'
    assert_schema_query_equals "lifecycle recovery actions support cleanup-current-run-artifacts" "$lifecycle_schema" '."$defs".programRecoveryRecipe.properties.recovery_action_id.enum[] | select(. == "cleanup-current-run-artifacts")' 'cleanup-current-run-artifacts'
    assert_schema_query_equals "lifecycle recovery blockers support authority-zone-denied" "$lifecycle_schema" '."$defs".programRecoveryRecipe.properties.blocker_class.enum[] | select(. == "authority-zone-denied")' 'authority-zone-denied'
    assert_schema_query_equals "route execution request carries phase id context" "$route_request_schema" '.properties.phase_id.pattern' '^[a-z][a-z0-9-]*$'
    assert_schema_query_equals "route execution result carries phase id context" "$route_result_schema" '.properties.phase_id.pattern' '^[a-z][a-z0-9-]*$'

    packet_contract="$REPO_ROOT/.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml"
    program_contract="$REPO_ROOT/.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml"
    assert_success_contract "source proposal-packet lifecycle contract passes" "$REPO_ROOT" ".octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml"
    assert_schema_query_equals "source proposal-packet lifecycle contract uses v2" "$packet_contract" '.schema_version' 'octon-extension-lifecycle-contract-v2'
    assert_schema_query_equals "source proposal-packet phase loop model declared" "$packet_contract" '.phase_loop.model_version' 'phase-loop-v1'
    assert_schema_query_equals "source proposal-packet implementation execution phase declared" "$packet_contract" '.phase_loop.phases[]? | select(.phase_id == "implementation-execution").route_refs[] | select(. == "run-packet-implementation")' 'run-packet-implementation'
    assert_schema_query_equals "source proposal-packet terminal phase does not dispatch" "$packet_contract" '.phase_loop.phases[]? | select(.phase_id == "terminal-explanation-reporting").route_refs | length' '0'
    assert_schema_query_equals "packet promote declares safe delegation contract" "$packet_contract" '.routes[]? | select(.route_id == "promote-proposal").delegation_contract.safe_delegation' 'true'
    assert_success_contract "source proposal-program lifecycle contract passes" "$REPO_ROOT" ".octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml"
    assert_schema_query_equals "program blocker taxonomy schema version declared" "$program_contract" '.program.recovery_policy.blocker_taxonomy.schema_version' 'octon-proposal-program-blocker-taxonomy-v1'
    assert_schema_query_equals "program blocker taxonomy routine class declared" "$program_contract" '.program.recovery_policy.blocker_taxonomy.classes[]? | select(.class_id == "routine-autonomous").class_id' 'routine-autonomous'
    assert_schema_query_equals "program blocker taxonomy soft class declared" "$program_contract" '.program.recovery_policy.blocker_taxonomy.classes[]? | select(.class_id == "soft-blocker").class_id' 'soft-blocker'
    assert_schema_query_equals "program blocker taxonomy hard class declared" "$program_contract" '.program.recovery_policy.blocker_taxonomy.classes[]? | select(.class_id == "hard-blocker").class_id' 'hard-blocker'
    assert_schema_query_equals "program blocker taxonomy preserves child receipt authority" "$program_contract" '.program.recovery_policy.blocker_taxonomy.authority_guards.child_receipts_remain_child_owned | tostring' 'true'
    assert_schema_query_equals "program blocker taxonomy rejects parent summary as child proof" "$program_contract" '.program.recovery_policy.blocker_taxonomy.authority_guards.parent_summary_satisfies_child_receipt | tostring' 'false'
    assert_schema_query_equals "program hard-blocker taxonomy defaults unknown blockers hard" "$program_contract" '.program.recovery_policy.blocker_taxonomy.classes[]? | select(.class_id == "hard-blocker").default_for_unknown_blocker_class | tostring' 'true'
    assert_schema_query_equals "program hard-blocker taxonomy includes unsafe resume" "$program_contract" '.program.recovery_policy.blocker_taxonomy.classes[]? | select(.class_id == "hard-blocker").examples[]? | select(.blocker_class == "unsafe-resume").blocker_class' 'unsafe-resume'
    assert_schema_query_equals "program hard-blocker taxonomy includes authority boundary ambiguity" "$program_contract" '.program.recovery_policy.blocker_taxonomy.classes[]? | select(.class_id == "hard-blocker").examples[]? | select(.blocker_class == "authority-boundary-ambiguous").blocker_class' 'authority-boundary-ambiguous'
    assert_schema_query_equals "program unsafe resume has no automatic recovery route" "$program_contract" '.program.recovery_policy.recipes[]? | select(.blocker_class == "unsafe-resume" and has("recovery_route_id")).blocker_class' ''
    assert_schema_query_equals "program unsafe resume has no automatic recovery action" "$program_contract" '.program.recovery_policy.recipes[]? | select(.blocker_class == "unsafe-resume" and has("recovery_action_id")).blocker_class' ''
    assert_schema_query_equals "program authority boundary ambiguity has no automatic recovery route" "$program_contract" '.program.recovery_policy.recipes[]? | select(.blocker_class == "authority-boundary-ambiguous" and has("recovery_route_id")).blocker_class' ''
    assert_schema_query_equals "program authority boundary ambiguity has no automatic recovery action" "$program_contract" '.program.recovery_policy.recipes[]? | select(.blocker_class == "authority-boundary-ambiguous" and has("recovery_action_id")).blocker_class' ''
    assert_schema_query_equals "program review route declared" "$program_contract" '.routes[]?.route_id | select(. == "review-program")' 'review-program'
    assert_schema_query_equals "program revise route declared" "$program_contract" '.routes[]?.route_id | select(. == "revise-program")' 'revise-program'
    assert_schema_query_equals "program review loop returns to revise" "$program_contract" '.loops[]? | select(.loop_id == "program-review-revision").repeat_route_id' 'revise-program'
    assert_schema_query_equals "program review gate uses strict review validator" "$program_contract" '.gates[]? | select(.gate_id == "program-review-authorization").validator_id' 'proposal-review-strict'
    assert_schema_query_equals "program review gate protects implementation orchestration prompt" "$program_contract" '.gates[]? | select(.gate_id == "program-review-authorization").required_before_routes[] | select(. == "generate-program-implementation-orchestration-prompt")' 'generate-program-implementation-orchestration-prompt'
    assert_schema_query_equals "program child readiness remains separate gate" "$program_contract" '.gates[]? | select(.gate_id == "program-child-proposal-readiness").validator_id' 'program-child-proposal-readiness'
    assert_schema_query_equals "program child readiness protects implementation orchestration prompt" "$program_contract" '.gates[]? | select(.gate_id == "program-child-proposal-readiness").required_before_routes[] | select(. == "generate-program-implementation-orchestration-prompt")' 'generate-program-implementation-orchestration-prompt'
    assert_schema_query_equals "program structure validator declared" "$program_contract" '.validators[]? | select(.validator_id == "program-structure").argv[] | select(. == ".octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh")' '.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh'
    assert_schema_query_equals "program structure gate protects implementation orchestration prompt" "$program_contract" '.gates[]? | select(.gate_id == "program-structure").required_before_routes[] | select(. == "generate-program-implementation-orchestration-prompt")' 'generate-program-implementation-orchestration-prompt'
    assert_schema_query_equals "program creation receipt declared" "$program_contract" '.receipts[]? | select(.receipt_id == "program-creation").path' 'support/program-creation.md'
    assert_schema_query_equals "program create expects creation receipt" "$program_contract" '.routes[]? | select(.route_id == "create-program").completion.expected_receipts[] | select(. == "program-creation")' 'program-creation'
    assert_schema_query_equals "program orchestration run receipt declared" "$program_contract" '.receipts[]? | select(.receipt_id == "program-implementation-orchestration-run").path' 'support/program-implementation-orchestration-run.md'
    assert_schema_query_equals "program conformance receipt declared" "$program_contract" '.receipts[]? | select(.receipt_id == "program-implementation-orchestration-conformance").path' 'support/program-implementation-orchestration-conformance-review.md'
    assert_schema_query_equals "program drift receipt declared" "$program_contract" '.receipts[]? | select(.receipt_id == "program-post-implementation-orchestration-drift").path' 'support/program-post-implementation-orchestration-drift-churn-review.md'
    assert_schema_query_equals "program verification loop expects conformance receipt" "$program_contract" '.routes[]? | select(.route_id == "run-program-verification-and-correction-loop").completion.expected_receipts[] | select(. == "program-implementation-orchestration-conformance")' 'program-implementation-orchestration-conformance'
    assert_schema_query_equals "program verification loop expects drift receipt" "$program_contract" '.routes[]? | select(.route_id == "run-program-verification-and-correction-loop").completion.expected_receipts[] | select(. == "program-post-implementation-orchestration-drift")' 'program-post-implementation-orchestration-drift'
    assert_schema_query_equals "program correction route requires finding blocker" "$program_contract" '.routes[]? | select(.route_id == "generate-program-correction-prompt").enter_when.all[]?.any[]? | select(.blocker_present == "validation-failed").blocker_present' 'validation-failed'
    assert_schema_query_equals "program closeout prompt requires aggregate conformance pass" "$program_contract" '.routes[]? | select(.route_id == "generate-program-closeout-prompt").enter_when.all[] | select(has("receipt_field_equals") and .receipt_field_equals.receipt_id == "program-implementation-orchestration-conformance" and .receipt_field_equals.field == "verdict").receipt_field_equals.value' 'pass'
    assert_schema_query_equals "program closeout prompt requires aggregate drift pass" "$program_contract" '.routes[]? | select(.route_id == "generate-program-closeout-prompt").enter_when.all[] | select(has("receipt_field_equals") and .receipt_field_equals.receipt_id == "program-post-implementation-orchestration-drift" and .receipt_field_equals.field == "verdict").receipt_field_equals.value' 'pass'
    assert_schema_query_equals "program promote uses existing workflow route" "$program_contract" '.routes[]? | select(.route_id == "promote-proposal").route_type' 'workflow'
    assert_schema_query_equals "program promote declares safe delegation contract" "$program_contract" '.routes[]? | select(.route_id == "promote-proposal").delegation_contract.safe_delegation' 'true'
    assert_schema_query_equals "program promote has no command binding" "$program_contract" '.routes[]? | select(.route_id == "promote-proposal" and has("command_id")).route_id' ''
    assert_schema_query_equals "program promote has no skill binding" "$program_contract" '.routes[]? | select(.route_id == "promote-proposal" and has("skill_id")).route_id' ''
    assert_schema_query_equals "program promote has no prompt binding" "$program_contract" '.routes[]? | select(.route_id == "promote-proposal" and has("prompt_set_id")).route_id' ''
    assert_schema_query_equals "program promote preserves child authority" "$program_contract" '.routes[]? | select(.route_id == "promote-proposal").enter_when.all[] | select(has("receipt_field_equals") and .receipt_field_equals.receipt_id == "program-implementation-orchestration-run" and .receipt_field_equals.field == "child_authority_preserved").receipt_field_equals.value' 'yes'
    assert_schema_query_equals "program archive uses existing workflow route" "$program_contract" '.routes[]? | select(.route_id == "archive-proposal").route_type' 'workflow'
    assert_schema_query_equals "program archive has no command binding" "$program_contract" '.routes[]? | select(.route_id == "archive-proposal" and has("command_id")).route_id' ''
    assert_schema_query_equals "program archive has no skill binding" "$program_contract" '.routes[]? | select(.route_id == "archive-proposal" and has("skill_id")).route_id' ''
    assert_schema_query_equals "program archive has no prompt binding" "$program_contract" '.routes[]? | select(.route_id == "archive-proposal" and has("prompt_set_id")).route_id' ''
    assert_schema_query_equals "program archive requires aggregate conformance pass" "$program_contract" '.routes[]? | select(.route_id == "archive-proposal").enter_when.all[] | select(has("receipt_field_equals") and .receipt_field_equals.receipt_id == "program-implementation-orchestration-conformance" and .receipt_field_equals.field == "verdict").receipt_field_equals.value' 'pass'
    assert_schema_query_equals "program archive requires aggregate drift pass" "$program_contract" '.routes[]? | select(.route_id == "archive-proposal").enter_when.all[] | select(has("receipt_field_equals") and .receipt_field_equals.receipt_id == "program-post-implementation-orchestration-drift" and .receipt_field_equals.field == "verdict").receipt_field_equals.value' 'pass'
    assert_schema_query_equals "program archive preserves child authority" "$program_contract" '.routes[]? | select(.route_id == "archive-proposal").enter_when.all[] | select(has("receipt_field_equals") and .receipt_field_equals.receipt_id == "proposal-closeout" and .receipt_field_equals.field == "child_authority_preserved").receipt_field_equals.value' 'yes'
    assert_schema_query_equals "program closeout receipt requires selected git route" "$program_contract" '.receipts[]? | select(.receipt_id == "proposal-closeout").required_fields[] | select(. == "selected_git_route")' 'selected_git_route'
    assert_schema_query_equals "program closeout receipt requires hygiene blocker class" "$program_contract" '.receipts[]? | select(.receipt_id == "proposal-closeout").required_fields[] | select(. == "worktree_hygiene_blocker_class")' 'worktree_hygiene_blocker_class'
    assert_schema_query_equals "program closeout receipt requires hygiene foreign path count" "$program_contract" '.receipts[]? | select(.receipt_id == "proposal-closeout").required_fields[] | select(. == "worktree_hygiene_foreign_path_count")' 'worktree_hygiene_foreign_path_count'
    assert_schema_query_equals "program closeout receipt requires hygiene fingerprint" "$program_contract" '.receipts[]? | select(.receipt_id == "proposal-closeout").required_fields[] | select(. == "worktree_hygiene_foreign_fingerprint")' 'worktree_hygiene_foreign_fingerprint'
    assert_schema_query_equals "program closeout receipt requires cleanup summary" "$program_contract" '.receipts[]? | select(.receipt_id == "proposal-closeout").required_fields[] | select(. == "cleanup_summary")' 'cleanup_summary'
    assert_schema_query_equals "program closeout receipt requires next route condition" "$program_contract" '.receipts[]? | select(.receipt_id == "proposal-closeout").required_fields[] | select(. == "next_route_condition")' 'next_route_condition'
    assert_schema_query_equals "no direct run-program-implementation route" "$program_contract" '.routes[]?.route_id | select(. == "run-program-implementation")' ''
    assert_schema_query_equals "program cleanup route is not accepted status-triggered" "$program_contract" '.routes[]? | select(.route_id == "cleanup-lifecycle-residue").enter_when.all[]?.any[]? | select(has("manifest_status") and .manifest_status == "accepted").manifest_status' ''
    assert_schema_query_equals "program cleanup route is not implemented status-triggered" "$program_contract" '.routes[]? | select(.route_id == "cleanup-lifecycle-residue").enter_when.all[]?.any[]? | select(has("manifest_status") and .manifest_status == "implemented").manifest_status' ''
    assert_schema_query_equals "program cleanup route can trigger from lifecycle residue blocker" "$program_contract" '.routes[]? | select(.route_id == "cleanup-lifecycle-residue").enter_when.all[]?.any[]? | select(has("blocker_present") and .blocker_present == "lifecycle-residue-cleanup-needed").blocker_present' 'lifecycle-residue-cleanup-needed
lifecycle-residue-cleanup-needed'
    assert_schema_query_equals "program cleanup route can trigger from cleanup candidates" "$program_contract" '.routes[]? | select(.route_id == "cleanup-lifecycle-residue").enter_when.all[]?.any[]? | select(has("cleanup_candidates_present")).cleanup_candidates_present' 'true
true'
    assert_schema_query_equals "program cleanup route can trigger from hygiene preflight" "$program_contract" '.routes[]? | select(.route_id == "cleanup-lifecycle-residue").enter_when.all[]?.any[]?.all[]? | select(has("hygiene_preflight_required")).hygiene_preflight_required' 'true'
    assert_schema_query_equals "program cleanup receipt tracks implementation blocking" "$program_contract" '.receipts[]? | select(.receipt_id == "lifecycle-residue-cleanup").required_fields[] | select(. == "implementation_blocking")' 'implementation_blocking'
    assert_schema_query_equals "program cleanup receipt tracks closeout blocking" "$program_contract" '.receipts[]? | select(.receipt_id == "lifecycle-residue-cleanup").required_fields[] | select(. == "closeout_blocking")' 'closeout_blocking'
    assert_schema_query_equals "program cleanup receipt tracks archive blocking" "$program_contract" '.receipts[]? | select(.receipt_id == "lifecycle-residue-cleanup").required_fields[] | select(. == "archive_blocking")' 'archive_blocking'

    printf '\nPassed: %s\nFailed: %s\n' "$pass_count" "$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
