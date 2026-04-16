#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../../.." && pwd)"
PACK_ROOT="$REPO_ROOT/.octon/inputs/additive/extensions/octon-pack-scaffolder"

pass_count=0
fail_count=0

pass() { echo "PASS: $1"; pass_count=$((pass_count + 1)); }
fail() { echo "FAIL: $1" >&2; fail_count=$((fail_count + 1)); }

assert_file() {
  local path="$1" label="$2"
  if [[ -f "$path" ]]; then
    pass "$label"
  else
    fail "$label"
  fi
}

assert_dir() {
  local path="$1" label="$2"
  if [[ -d "$path" ]]; then
    pass "$label"
  else
    fail "$label"
  fi
}

assert_equal() {
  local actual="$1" expected="$2" label="$3"
  if [[ "$actual" == "$expected" ]]; then
    pass "$label"
  else
    fail "$label (expected '$expected', got '$actual')"
  fi
}

assert_contains() {
  local path="$1" pattern="$2" label="$3"
  if grep -Fq -- "$pattern" "$path"; then
    pass "$label"
  else
    fail "$label"
  fi
}

assert_not_found() {
  local pattern="$1" label="$2"
  if rg -n --fixed-strings "$pattern" "$PACK_ROOT" >/dev/null 2>&1; then
    fail "$label"
  else
    pass "$label"
  fi
}

expected_commands=(
  octon-pack-scaffolder
  octon-pack-scaffolder-create-pack
  octon-pack-scaffolder-create-prompt-bundle
  octon-pack-scaffolder-create-skill
  octon-pack-scaffolder-create-command
  octon-pack-scaffolder-create-context-doc
  octon-pack-scaffolder-create-validation-fixture
)

expected_examples=(
  create-pack-minimal.md
  create-prompt-bundle-minimal.md
  create-skill-minimal.md
  create-command-minimal.md
  create-context-doc-minimal.md
  create-validation-fixture-minimal.md
)

main() {
  assert_file "$PACK_ROOT/pack.yml" "pack manifest exists"
  assert_file "$PACK_ROOT/README.md" "pack readme exists"
  assert_file "$PACK_ROOT/commands/manifest.fragment.yml" "commands manifest exists"
  assert_file "$PACK_ROOT/skills/manifest.fragment.yml" "skills manifest exists"
  assert_file "$PACK_ROOT/skills/registry.fragment.yml" "skills registry exists"
  assert_file "$PACK_ROOT/context/overview.md" "context overview exists"
  assert_file "$PACK_ROOT/context/output-shapes.md" "output shapes doc exists"
  assert_file "$PACK_ROOT/validation/README.md" "validation readme exists"
  assert_file "$PACK_ROOT/validation/compatibility.yml" "compatibility profile exists"
  assert_dir "$PACK_ROOT/validation/scenarios" "validation scenarios directory exists"
  assert_dir "$PACK_ROOT/validation/tests" "validation tests directory exists"

  assert_equal "$(yq -r '.pack_id' "$PACK_ROOT/pack.yml")" "octon-pack-scaffolder" "pack id matches"
  assert_equal "$(yq -r '.content_entrypoints.skills' "$PACK_ROOT/pack.yml")" "skills/" "skills entrypoint set"
  assert_equal "$(yq -r '.content_entrypoints.commands' "$PACK_ROOT/pack.yml")" "commands/" "commands entrypoint set"
  assert_equal "$(yq -r '.content_entrypoints.context' "$PACK_ROOT/pack.yml")" "context/" "context entrypoint set"
  assert_equal "$(yq -r '.content_entrypoints.validation' "$PACK_ROOT/pack.yml")" "validation/" "validation entrypoint set"
  assert_equal "$(yq -r '.content_entrypoints.prompts' "$PACK_ROOT/pack.yml")" "null" "prompts entrypoint starts null"
  assert_equal "$(yq -r '.content_entrypoints.templates' "$PACK_ROOT/pack.yml")" "null" "templates entrypoint starts null"

  assert_equal "$(yq -r '.commands | length' "$PACK_ROOT/commands/manifest.fragment.yml")" "7" "seven commands published"
  assert_equal "$(yq -r '.skills | length' "$PACK_ROOT/skills/manifest.fragment.yml")" "7" "seven skills published"
  assert_equal "$(yq -r '.skills | keys | length' "$PACK_ROOT/skills/registry.fragment.yml")" "7" "seven registry entries published"

  local command_id
  for command_id in "${expected_commands[@]}"; do
    assert_file "$PACK_ROOT/commands/${command_id}.md" "command file exists: $command_id"
    assert_dir "$PACK_ROOT/skills/${command_id}" "skill directory exists: $command_id"
    assert_file "$PACK_ROOT/skills/${command_id}/SKILL.md" "skill file exists: $command_id"
    assert_file "$PACK_ROOT/skills/${command_id}/references/phases.md" "skill phases exists: $command_id"
    assert_file "$PACK_ROOT/skills/${command_id}/references/io-contract.md" "skill io-contract exists: $command_id"
    assert_file "$PACK_ROOT/skills/${command_id}/references/validation.md" "skill validation exists: $command_id"
    assert_contains "$PACK_ROOT/skills/${command_id}/SKILL.md" "Additive only." "skill boundary text present: $command_id"
  done

  local example_file
  for example_file in "${expected_examples[@]}"; do
    assert_file "$PACK_ROOT/context/examples/$example_file" "context example exists: $example_file"
    assert_file "$PACK_ROOT/validation/scenarios/$example_file" "validation scenario exists: $example_file"
  done

  assert_contains "$PACK_ROOT/context/output-shapes.md" 'octon_version: "^0.6.25"' "output shapes pins current harness release"
  assert_contains "$PACK_ROOT/context/output-shapes.md" 'extensions_api_version: "1.0"' "output shapes pins extensions api version"
  assert_contains "$PACK_ROOT/context/output-shapes.md" 'content_entrypoints.prompts' "prompt entrypoint update rule documented"
  assert_contains "$PACK_ROOT/commands/octon-pack-scaffolder.md" "--target pack|prompt-bundle|skill|command|context-doc|validation-fixture" "root command documents explicit target surface"
  assert_contains "$PACK_ROOT/skills/octon-pack-scaffolder/SKILL.md" 'Do not touch `framework/**`, `instance/**`, `state/**`, or `generated/**`.' "root skill forbids non-additive writes"
  assert_contains "$PACK_ROOT/validation/README.md" "test-generated-pack-contracts.sh" "validation readme lists generated-pack contract test"
  assert_contains "$PACK_ROOT/validation/compatibility.yml" "publish-extension-state.sh" "compatibility profile includes extension publication script"

  if rg -n --fixed-strings '[TODO' "$PACK_ROOT" 2>/dev/null | grep -v '/validation/tests/' >/dev/null 2>&1; then
    fail "no TODO placeholders remain"
  else
    pass "no TODO placeholders remain"
  fi

  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  if [[ $fail_count -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
