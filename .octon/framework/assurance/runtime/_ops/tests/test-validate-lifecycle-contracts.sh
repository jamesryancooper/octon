#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
VALIDATOR="$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-contracts.sh"

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
    command_id: "test-command"
    skill_id: "test-extension-skill"
    prompt_set_id: "test-extension-test-route"
    required_inputs: ["source"]
    completion:
      expected_receipts: ["test-review"]
      expected_paths: ["support/proposal-review.md"]
      replan_required: true
    approval:
      required_by_default: true
      reason: "test route mutates durable fixtures"
    enter_when:
      manifest_status: "draft"
YAML
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
    atomic:
      stage_route_id: "atomic-stage"
      commit_route_id: "atomic-commit"
      rollback_route_id: "atomic-rollback"
      compensation_route_id: "atomic-compensate"
    completion:
      expected_receipts: ["program-summary"]
  - route_id: "atomic-stage"
    route_type: "extension"
  - route_id: "atomic-commit"
    route_type: "extension"
  - route_id: "atomic-rollback"
    route_type: "extension"
  - route_id: "atomic-compensate"
    route_type: "extension"
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

  root="$(new_fixture_repo valid-program-contract)"
  write_fixture_support "$root"
  write_valid_program_contract "$root"
  assert_success_contract "valid program lifecycle contract passes from lifecycles directory" "$root" ".octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"

  root="$(new_fixture_repo valid-program-atomic-contract)"
  write_fixture_support "$root"
  write_valid_atomic_program_contract "$root"
  assert_success_contract "valid program-atomic lifecycle contract passes with explicit atomic policy" "$root" ".octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"

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

  root="$(new_fixture_repo missing-approval-reason)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  yq -i 'del(.routes[0].approval.reason)' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "approval-required route without reason fails" "$root"

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
    yq -i '.program.recovery_policy.handlers."executor-failed".approval_required = "yes"' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"
    assert_failure_contract "invalid recovery handler approval flag fails" "$root" ".octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"

    root="$(new_fixture_repo invalid-recovery-recipe-missing-field)"
    write_fixture_support "$root"
    write_valid_atomic_program_contract "$root"
    yq -i '.program.recovery_policy.recipes = [{"blocker_class": "stale-receipt", "approval_required": false, "retry_budget": 1, "dependent_handling": "continue-independent", "post_attempt_validation": ["replan-live-state"], "replan_behavior": "after-attempt"}]' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"
    assert_failure_contract "recovery recipe missing required field fails" "$root" ".octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"

    root="$(new_fixture_repo invalid-recovery-recipe-idempotency)"
    write_fixture_support "$root"
    write_valid_atomic_program_contract "$root"
    yq -i '.program.recovery_policy.recipes = [{"blocker_class": "stale-receipt", "idempotency_class": "magic", "approval_required": false, "retry_budget": 1, "dependent_handling": "continue-independent", "post_attempt_validation": ["replan-live-state"], "replan_behavior": "after-attempt"}]' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"
    assert_failure_contract "invalid recovery recipe idempotency fails" "$root" ".octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"

    root="$(new_fixture_repo invalid-recovery-recipe-post-validation)"
    write_fixture_support "$root"
    write_valid_atomic_program_contract "$root"
    yq -i '.program.recovery_policy.recipes = [{"blocker_class": "stale-receipt", "idempotency_class": "idempotent-rerun", "approval_required": false, "retry_budget": 1, "dependent_handling": "continue-independent", "post_attempt_validation": ["trust-me"], "replan_behavior": "after-attempt"}]' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"
    assert_failure_contract "invalid recovery recipe post-attempt validation fails" "$root" ".octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"

    root="$(new_fixture_repo invalid-recovery-recipe-replan)"
    write_fixture_support "$root"
    write_valid_atomic_program_contract "$root"
    yq -i '.program.recovery_policy.recipes = [{"blocker_class": "stale-receipt", "idempotency_class": "idempotent-rerun", "approval_required": false, "retry_budget": 1, "dependent_handling": "continue-independent", "post_attempt_validation": ["replan-live-state"], "replan_behavior": "eventually"}]' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"
    assert_failure_contract "invalid recovery recipe replan behavior fails" "$root" ".octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"

    root="$(new_fixture_repo invalid-recovery-recipe-route)"
    write_fixture_support "$root"
    write_valid_atomic_program_contract "$root"
    yq -i '.program.recovery_policy.recipes = [{"blocker_class": "validation-failed", "recovery_route_id": "missing-route", "idempotency_class": "approval-gated-mutation", "approval_required": false, "retry_budget": 1, "dependent_handling": "continue-independent", "post_attempt_validation": ["replan-live-state"], "replan_behavior": "after-attempt"}]' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"
    assert_failure_contract "missing recovery recipe route fails" "$root" ".octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"

    root="$(new_fixture_repo invalid-non-recoverable-recipe-route)"
    write_fixture_support "$root"
    write_valid_atomic_program_contract "$root"
    yq -i '.program.recovery_policy.recipes = [{"blocker_class": "unsafe-resume", "recovery_route_id": "test-route", "idempotency_class": "non-recoverable", "approval_required": true, "retry_budget": 0, "dependent_handling": "fail-closed", "post_attempt_validation": ["replay-verify"], "replan_behavior": "none"}]' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"
    assert_failure_contract "non-recoverable recovery route fails" "$root" ".octon/inputs/additive/extensions/test-extension/context/lifecycles/proposal-program.contract.yml"

    registry_schema="$REPO_ROOT/.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/proposal-program-child-registry.schema.json"
    mutation_schema="$REPO_ROOT/.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/proposal-program-mutation.schema.json"
    scaffold_schema="$REPO_ROOT/.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/proposal-program-scaffold.schema.json"
    event_schema="$REPO_ROOT/.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/program-lifecycle-event.schema.json"
    lifecycle_schema="$REPO_ROOT/.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/extension-lifecycle-contract.schema.json"

    assert_schema_query_equals "registry identifier definition matches runtime" "$registry_schema" '."$defs".identifier.pattern' '^[a-z][a-z0-9-]*$'
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

    assert_schema_query_equals "mutation identifier definition matches runtime" "$mutation_schema" '."$defs".identifier.pattern' '^[a-z][a-z0-9-]*$'
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

    assert_schema_query_equals "scaffold identifier definition matches runtime" "$scaffold_schema" '."$defs".identifier.pattern' '^[a-z][a-z0-9-]*$'
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

    assert_schema_query_equals "event identifier definition matches runtime" "$event_schema" '."$defs".identifier.pattern' '^[a-z][a-z0-9-]*$'
    assert_schema_query_equals "event child id uses canonical identifier" "$event_schema" '.properties.child_id."$ref"' '#/$defs/identifier'
    assert_schema_query_equals "event route id uses canonical identifier pattern" "$event_schema" '.properties.route_id.pattern' '^[a-z][a-z0-9-]*$'

    assert_schema_query_equals "lifecycle recovery idempotency accepts non-recoverable" "$lifecycle_schema" '."$defs".programRecoveryRecipe.properties.idempotency_class.enum[] | select(. == "non-recoverable")' 'non-recoverable'
    assert_schema_query_equals "lifecycle recovery replan behavior supports after-attempt" "$lifecycle_schema" '."$defs".programRecoveryRecipe.properties.replan_behavior.enum[] | select(. == "after-attempt")' 'after-attempt'

    printf '\nPassed: %s\nFailed: %s\n' "$pass_count" "$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
