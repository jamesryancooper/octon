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

assert_success() {
  local label="$1" root="$2"
  if OCTON_ROOT_DIR="$root" bash "$VALIDATOR" --contract ".octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml" >/tmp/octon-lifecycle-contract.out 2>&1; then
    pass "$label"
  else
    cat /tmp/octon-lifecycle-contract.out >&2
    fail "$label"
  fi
}

assert_failure() {
  local label="$1" root="$2"
  if OCTON_ROOT_DIR="$root" bash "$VALIDATOR" --contract ".octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml" >/tmp/octon-lifecycle-contract.out 2>&1; then
    cat /tmp/octon-lifecycle-contract.out >&2
    fail "$label"
  else
    pass "$label"
  fi
}

main() {
  local root
  root="$(new_fixture_repo valid)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  assert_success "valid lifecycle contract passes" "$root"

  root="$(new_fixture_repo invalid-schema)"
  write_fixture_support "$root"
  write_valid_contract "$root"
  yq -i '.schema_version = "wrong"' "$root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  assert_failure "invalid schema version fails" "$root"

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

  printf '\nPassed: %s\nFailed: %s\n' "$pass_count" "$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
