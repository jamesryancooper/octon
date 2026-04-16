#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../../../../.." && pwd)"
PACK_ROOT="$REPO_ROOT/.octon/inputs/additive/extensions/octon-impact-map-and-validation-selector"

pass_count=0
fail_count=0

pass() { echo "PASS: $1"; pass_count=$((pass_count + 1)); }
fail() { echo "FAIL: $1" >&2; fail_count=$((fail_count + 1)); }

assert_success() {
  local name="$1"
  shift
  if "$@"; then
    pass "$name"
  else
    fail "$name"
  fi
}

case_shared_output_contract_lists_required_top_level_sections() {
  local contract="$PACK_ROOT/prompts/shared/output-contract.md"
  grep -Fq '## `impact_map`' "$contract"
  grep -Fq '## `minimum_credible_validation_set`' "$contract"
  grep -Fq '## `rationale_trace`' "$contract"
  grep -Fq '## `recommended_next_step`' "$contract"
}

case_shared_output_contract_lists_required_fields() {
  local contract="$PACK_ROOT/prompts/shared/output-contract.md"
  grep -Fq '`route_id`' "$contract"
  grep -Fq '`selected[]`' "$contract"
  grep -Fq '`omitted[]`' "$contract"
  grep -Fq '`primary`' "$contract"
}

case_every_prompt_manifest_references_shared_output_contract() {
  local manifest
  while IFS= read -r manifest; do
    grep -Fq 'path: "shared/output-contract.md"' "$manifest" || return 1
    grep -Fq 'path: "shared/next-step-routing-rules.md"' "$manifest" || return 1
    grep -Fq 'role_class: "maintenance-companion"' "$manifest" || return 1
  done < <(find "$PACK_ROOT/prompts" -name manifest.yml -type f | sort)
}

case_leaf_command_docs_list_expected_output_sections() {
  local command_file
  for command_file in \
    "$PACK_ROOT/commands/octon-impact-map-and-validation-selector-touched-paths.md" \
    "$PACK_ROOT/commands/octon-impact-map-and-validation-selector-proposal-packet.md" \
    "$PACK_ROOT/commands/octon-impact-map-and-validation-selector-refactor-target.md" \
    "$PACK_ROOT/commands/octon-impact-map-and-validation-selector-mixed-inputs.md"; do
    grep -Fq '`impact_map`' "$command_file" || return 1
    grep -Fq '`minimum_credible_validation_set`' "$command_file" || return 1
    grep -Fq '`rationale_trace`' "$command_file" || return 1
    grep -Fq '`recommended_next_step`' "$command_file" || return 1
  done
}

main() {
  assert_success "shared output contract lists all required top-level sections" case_shared_output_contract_lists_required_top_level_sections
  assert_success "shared output contract lists the required child fields" case_shared_output_contract_lists_required_fields
  assert_success "every prompt manifest references the shared output contract and routing rules" case_every_prompt_manifest_references_shared_output_contract
  assert_success "leaf command docs list the expected output sections" case_leaf_command_docs_list_expected_output_sections

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
